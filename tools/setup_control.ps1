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

$dirs = @($Control,$Admin,$Dat,$Mirror,$Restricted,$Runs,$Cex,$Norm,$Pdo,"$Norm\OPER","$Norm\TEMP")
foreach($d in $dirs){ New-Item -ItemType Directory -Force -Path $d | Out-Null }

function Copy-Tree($src,$dst){
  if(!(Test-Path $src)){ throw "Missing source directory: $src" }
  New-Item -ItemType Directory -Force -Path $dst | Out-Null
  Copy-Item "$src\*" $dst -Recurse -Force
}

Write-Host 'Copying PDO...'
Copy-Tree "$Repo\PDO" $Pdo
Write-Host 'Copying ADMINSTR...'
Copy-Tree "$Repo\ADMINSTR" $Admin
if(Test-Path "$Repo\dat"){ Write-Host 'Copying dat...'; Copy-Tree "$Repo\dat" $Dat }
Write-Host 'Copying CEX PUTI...'
Copy-Item "$Repo\Cex\puti.DBF" "$Cex\PUTI.DBF" -Force
if(Test-Path "$Repo\Cex\puti.CDX"){ Copy-Item "$Repo\Cex\puti.CDX" "$Cex\PUTI.CDX" -Force }

$backup="$Control\PUTI_BEFORE_CONTROL"
New-Item -ItemType Directory -Force -Path $backup | Out-Null
Copy-Item "$Cex\PUTI.DBF" "$backup\PUTI.DBF.original" -Force
if(Test-Path "$Cex\PUTI.CDX"){ Copy-Item "$Cex\PUTI.CDX" "$backup\PUTI.CDX.original" -Force }

# Make a best-effort local copy of source for audit/reference; do not edit original PRG here.
if(Test-Path "$Repo\*.prg"){ Copy-Item "$Repo\*.prg" "$Control\SOURCE_PRG" -Force -ErrorAction SilentlyContinue }

# Patch PUTI.DBF using Python helper. This does not require Visual FoxPro.
Write-Host 'Configuring C:\CEX\PUTI.DBF for ARM 20...'
$py = "$PSScriptRoot\patch_puti.py"
python "$py" "$Cex\PUTI.DBF"
if($LASTEXITCODE -ne 0){ throw 'PUTI.DBF patch failed.' }

Write-Host ''
Write-Host 'Local paths configured:'
Write-Host '  ad_start = C:\PDO\CEX\'
Write-Host '  ad_norm  = C:\NORMATIV\'
Write-Host '  ad_normS = C:\FOXPRO_CONTROL\NET_MIRROR\'
Write-Host '  ad_vig   = C:\FOXPRO_CONTROL\DAT\'
Write-Host '  ad_netR  = C:\FOXPRO_CONTROL\NET_RESTRICTED\'
Write-Host ''
Write-Host 'IMPORTANT: do not run PDO\N_NSI.bat on the isolated PC.'
Write-Host 'The prepared environment is local to C:.'
