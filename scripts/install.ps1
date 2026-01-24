Write-Host "========================================"
Write-Host "🚀 Dev Setup - Inicialização (Windows)"
Write-Host "========================================"

if (!(Get-Command winget -ErrorAction SilentlyContinue)) {
  Write-Error "Winget não encontrado. Atualize o Windows."
  exit 1
}

$installTerminal = Read-Host "Deseja instalar/configurar o TERMINAL? (s/n)"
$installTerminal = $installTerminal.ToLower() -eq "s"

if (!(Get-Command node -ErrorAction SilentlyContinue)) {
  Write-Host "📦 Instalando Node.js..."
  winget install OpenJS.NodeJS.LTS -e --silent
}

if (!(Get-Command git -ErrorAction SilentlyContinue)) {
  Write-Host "📦 Instalando Git..."
  winget install Git.Git -e --silent
}

if (!(Get-Command code -ErrorAction SilentlyContinue)) {
  Write-Host "📦 Instalando VS Code..."
  winget install Microsoft.VisualStudioCode -e --silent
}

$BASE = "$env:USERPROFILE\dev-setup"

if (!(Test-Path $BASE)) {
  Write-Host "⬇️ Baixando repositório..."
  git clone https://github.com/fernandohaeser/dev-setup $BASE
}

if ($installTerminal) {
  Write-Host "🖥️ Configurando terminal..."
  Set-Location "$BASE\terminal"
  .\windows.ps1
}

Write-Host "🧠 Configurando VS Code..."
Set-Location "$BASE\vscode"
node setup.js

Write-Host "========================================"
Write-Host "✅ Setup concluído! Reinicie o terminal."
Write-Host "========================================"
