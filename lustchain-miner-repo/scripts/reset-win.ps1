# Reset local Lustchain data (Windows)
$ErrorActionPreference = "Stop"
$DATADIR = Join-Path $env:USERPROFILE "lustdata"
docker rm -f lust-geth 2>$null | Out-Null
Start-Sleep -s 1
Remove-Item $DATADIR -Recurse -Force -ErrorAction SilentlyContinue
Write-Host "Reset done. Re-run scripts/lust-win.ps1"
