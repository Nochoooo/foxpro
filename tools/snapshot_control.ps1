[CmdletBinding()]
param()
$ErrorActionPreference = 'Stop'

$Control = 'C:\FOXPRO_CONTROL'
$Stamp = Get-Date -Format 'yyyyMMdd_HHmmss'
$Run = Join-Path "$Control\RUNS" "CONTROL_$Stamp"
$Norm = 'C:\NORMATIV'

if(!(Test-Path -LiteralPath $Norm -PathType Container)){ throw "Missing results directory: $Norm" }
New-Item -ItemType Directory -Force -Path $Run | Out-Null

function Copy-IfExists($src,$dst){
  if(Test-Path -LiteralPath $src){
    New-Item -ItemType Directory -Force -Path (Split-Path -Parent $dst) | Out-Null
    Copy-Item -LiteralPath $src -Destination $dst -Recurse -Force
  }
}

Write-Host "Saving control run to $Run"
Copy-IfExists $Norm (Join-Path $Run 'NORMATIV')
Copy-IfExists 'C:\FOXPRO_CONTROL\DAT' (Join-Path $Run 'DAT')
Copy-IfExists 'C:\CEX' (Join-Path $Run 'CEX')
Copy-IfExists 'C:\PDO\CEX' (Join-Path $Run 'PDO_CEX')
Copy-IfExists 'C:\FOXPRO_CONTROL\ADMINSTR' (Join-Path $Run 'ADMINSTR')

$manifest = Join-Path $Run 'SHA256SUMS.txt'
Get-ChildItem -LiteralPath $Run -File -Recurse | Get-FileHash -Algorithm SHA256 |
  ForEach-Object { "$($_.Hash)  $($_.Path.Substring($Run.Length + 1))" } |
  Set-Content -LiteralPath $manifest -Encoding ASCII

Write-Host ''
Write-Host 'CONTROL SNAPSHOT SAVED:'
Write-Host $Run
Write-Host "Manifest: $manifest"
