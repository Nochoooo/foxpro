[CmdletBinding()]
param()
$ErrorActionPreference = 'Stop'

$Repo = Split-Path -Parent $PSScriptRoot
$Control = 'C:\FOXPRO_CONTROL'
$Admin = "$Control\ADMINSTR"
$Dat = "$Control\DAT"
$Mirror = "$Control\NET_MIRROR"
$Restricted = "$Control\NET_RESTRICTED"
$Runs = "$Control\RUNS"
$Cex = 'C:\CEX'
$Norm = 'C:\NORMATIV'
$Pdo = 'C:\PDO'

Write-Host "Repository: $Repo"

function Copy-Tree($src,$dst){
  if(!(Test-Path -LiteralPath $src)){ throw "Missing source directory: $src" }
  New-Item -ItemType Directory -Force -Path $dst | Out-Null
  Copy-Item -LiteralPath (Join-Path $src '*') -Destination $dst -Recurse -Force
}

function Test-LfsPointer($file){
  if(!(Test-Path -LiteralPath $file -PathType Leaf)){ throw "Missing file: $file" }
  $fs = [System.IO.File]::OpenRead($file)
  try {
    $buf = New-Object byte[] 64
    $n = $fs.Read($buf,0,$buf.Length)
  } finally { $fs.Dispose() }
  if($n -gt 0){
    $head = [System.Text.Encoding]::UTF8.GetString($buf,0,$n)
    return $head.StartsWith('version https://git-lfs.github.com/spec/v1')
  }
  return $false
}

function Clear-Directory($dir){
  if(Test-Path -LiteralPath $dir){
    Get-ChildItem -LiteralPath $dir -Force | Remove-Item -Recurse -Force
  } else {
    New-Item -ItemType Directory -Force -Path $dir | Out-Null
  }
}

Write-Host 'Checking repository prerequisites...'
if(!(Test-Path -LiteralPath "$Repo\PDO" -PathType Container)){ throw 'Repository PDO directory is missing.' }
if(!(Test-Path -LiteralPath "$Repo\ADMINSTR" -PathType Container)){ throw 'Repository ADMINSTR directory is missing.' }
if(!(Test-Path -LiteralPath "$Repo\dat" -PathType Container)){ throw 'Repository dat directory is missing.' }
if(!(Test-Path -LiteralPath "$Repo\Cex\puti.DBF" -PathType Leaf)){ throw 'Repository Cex\puti.DBF is missing.' }
if(!(Test-Path -LiteralPath "$Repo\NORMATIV" -PathType Container)){ throw 'Repository NORMATIV directory is missing.' }

# NORMATIV is stored in Git LFS. A missing Git LFS checkout would leave pointer files.
$probeFiles = @(
  "$Repo\NORMATIV\NORMMATO.DBF",
  "$Repo\NORMATIV\NORMMATO.CDX"
)
foreach($probe in $probeFiles){
  if(Test-LfsPointer $probe){
    throw "Git LFS content is not materialized: $probe. Install Git LFS and run 'git lfs pull' before setup."
  }
}

$dirs = @($Control,$Admin,$Dat,$Mirror,$Restricted,$Runs,$Cex,$Norm,$Pdo,"$Norm\OPER","$Norm\TEMP","$Control\SOURCE_PRG")
foreach($d in $dirs){ New-Item -ItemType Directory -Force -Path $d | Out-Null }

# This is a dedicated isolated-PC environment. Rebuild the working copies on every setup
# so an earlier run cannot contaminate the control run.
Write-Host 'Cleaning previous local working copies...'
Clear-Directory $Admin
Clear-Directory $Dat
Clear-Directory $Cex
Clear-Directory $Norm
Clear-Directory $Pdo
Clear-Directory "$Control\NET_MIRROR"
Clear-Directory "$Control\NET_RESTRICTED"
Clear-Directory "$Control\SOURCE_PRG"

Write-Host 'Copying PDO...'
Copy-Tree "$Repo\PDO" $Pdo
Write-Host 'Copying ADMINSTR...'
Copy-Tree "$Repo\ADMINSTR" $Admin
Write-Host 'Copying dat...'
Copy-Tree "$Repo\dat" $Dat
Write-Host 'Copying NORMATIV...'
Copy-Tree "$Repo\NORMATIV" $Norm
Write-Host 'Copying CEX PUTI...'
Copy-Item "$Repo\Cex\puti.DBF" "$Cex\PUTI.DBF" -Force
if(Test-Path -LiteralPath "$Repo\Cex\puti.CDX"){ Copy-Item "$Repo\Cex\puti.CDX" "$Cex\PUTI.CDX" -Force }

Write-Host 'Backing up original PUTI...'
$backup="$Control\PUTI_BEFORE_CONTROL"
Clear-Directory $backup
Copy-Item "$Cex\PUTI.DBF" "$backup\PUTI.DBF.original" -Force
if(Test-Path -LiteralPath "$Cex\PUTI.CDX"){ Copy-Item "$Cex\PUTI.CDX" "$backup\PUTI.CDX.original" -Force }

Write-Host 'Copying source PRG for audit...'
Copy-Item "$Repo\*.prg" "$Control\SOURCE_PRG" -Force -ErrorAction SilentlyContinue

function Patch-PutiDbf($path){
  $bytes = [System.IO.File]::ReadAllBytes($path)
  if($bytes.Length -lt 33){ throw "Invalid DBF: $path" }

  $recordCount = [BitConverter]::ToUInt32($bytes,4)
  $headerLen = [BitConverter]::ToUInt16($bytes,8)
  $recordLen = [BitConverter]::ToUInt16($bytes,10)
  if($headerLen -lt 33 -or $recordLen -lt 2){ throw "Invalid DBF header: $path" }

  $fieldCount = [int](($headerLen - 33) / 32)
  $fields = @()
  $recordOffset = 1   # first byte of each DBF record is the deletion flag

  for($i=0; $i -lt $fieldCount; $i++){
    $desc = 32 + ($i * 32)
    $nameBytes = New-Object byte[] 11
    [Array]::Copy($bytes,$desc,$nameBytes,0,11)
    $zero = [Array]::IndexOf($nameBytes,[byte]0)
    if($zero -lt 0){ $zero = 11 }
    $name = [System.Text.Encoding]::ASCII.GetString($nameBytes,0,$zero).Trim().ToUpperInvariant()
    $len = [int]$bytes[$desc + 16]
    $fields += [pscustomobject]@{Name=$name; Offset=$recordOffset; Length=$len}
    $recordOffset += $len
  }

  $ind = $fields | Where-Object Name -eq 'IND_ARM' | Select-Object -First 1
  $imAdr = $fields | Where-Object Name -eq 'IM_ADR' | Select-Object -First 1
  $adres = $fields | Where-Object Name -eq 'ADRES' | Select-Object -First 1
  if($null -eq $ind -or $null -eq $imAdr -or $null -eq $adres){
    $names = ($fields | ForEach-Object Name) -join ', '
    throw "PUTI.DBF fields IND_ARM/IM_ADR/ADRES not found. Fields: $names"
  }

  $cp = [System.Text.Encoding]::GetEncoding(1251)
  $changes = @{
    'AD_START' = 'C:\PDO\CEX\'
    'AD_NORM'  = 'C:\NORMATIV\'
    'AD_NORMS' = 'C:\FOXPRO_CONTROL\NET_MIRROR\'
    'AD_VIG'   = 'C:\FOXPRO_CONTROL\DAT\'
    'AD_NETR'  = 'C:\FOXPRO_CONTROL\NET_RESTRICTED\'
  }

  $changed = 0
  for([uint32]$r=0; $r -lt $recordCount; $r++){
    $roff = $headerLen + ([int64]$r * $recordLen)
    if($roff + $recordLen -gt $bytes.Length){ break }

    $indText = $cp.GetString($bytes,$roff + $ind.Offset,$ind.Length).Trim()
    $indValue = 0
    if(-not [int]::TryParse($indText,[ref]$indValue)){ continue }
    if($indValue -ne 20){ continue }

    $im = $cp.GetString($bytes,$roff + $imAdr.Offset,$imAdr.Length).Trim().ToUpperInvariant()
    if(-not $changes.ContainsKey($im)){ continue }

    $newBytes = $cp.GetBytes($changes[$im])
    if($newBytes.Length -gt $adres.Length){ throw "Path is too long for ADRES field: $($changes[$im])" }
    [Array]::Clear($bytes,$roff + $adres.Offset,$adres.Length)
    for($j=0; $j -lt $newBytes.Length; $j++){ $bytes[$roff + $adres.Offset + $j] = $newBytes[$j] }
    for($j=$newBytes.Length; $j -lt $adres.Length; $j++){ $bytes[$roff + $adres.Offset + $j] = 0x20 }
    $changed++
  }

  [System.IO.File]::WriteAllBytes($path,$bytes)
  Write-Host "PUTI patched: $changed ARM 20 records changed."
  if($changed -eq 0){ throw 'No ARM 20 path records were changed in PUTI.DBF.' }
}

Write-Host 'Configuring C:\CEX\PUTI.DBF for ARM 20...'
Patch-PutiDbf "$Cex\PUTI.DBF"

Write-Host ''
Write-Host 'Local paths configured:'
Write-Host '  ad_start = C:\PDO\CEX\'
Write-Host '  ad_norm  = C:\NORMATIV\'
Write-Host '  ad_normS = C:\FOXPRO_CONTROL\NET_MIRROR\'
Write-Host '  ad_vig   = C:\FOXPRO_CONTROL\DAT\'
Write-Host '  ad_netR  = C:\FOXPRO_CONTROL\NET_RESTRICTED\'
Write-Host ''
Write-Host 'IMPORTANT: keep the isolated PC disconnected from the corporate network.'
Write-Host 'Do NOT run C:\PDO\N_NSI.bat.'
Write-Host 'Setup completed successfully.'
