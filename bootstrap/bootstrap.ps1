Write-Host "🚀 Dev Setup - Windows"

if (!(Get-Command winget -ErrorAction SilentlyContinue)) {
  Write-Error "Winget não encontrado. Atualize o Windows."
  exit 1
}

if (!(Get-Command node -ErrorAction SilentlyContinue)) {
  winget install OpenJS.NodeJS.LTS -e --silent
}

if (!(Get-Command git -ErrorAction SilentlyContinue)) {
  winget install Git.Git -e --silent
}

if (!(Get-Command code -ErrorAction SilentlyContinue)) {
  winget install Microsoft.VisualStudioCode -e --silent
}

$BASE = "$env:USERPROFILE\dev-setup"

if (!(Test-Path $BASE)) {
  git clone https://github.com/fernandohaeser/dev-setup $BASE
}

Set-Location "$BASE\vscode"
node setup.js

if ($env:SETUP_TERMINAL -eq "true") {
  Set-Location "$BASE\terminal"
  .\windows.ps1
}

Write-Host "✅ Setup concluído"
