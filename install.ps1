Write-Host "========================================"
Write-Host "🚀 Dev Setup - Inicialização (Windows)"
Write-Host "========================================"

$ErrorActionPreference = 'Stop'

# Garante TLS moderno para downloads HTTPS em ambientes antigos
try {
  [Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor [Net.SecurityProtocolType]::Tls12
} catch {}

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

$repoRawBase = "https://raw.githubusercontent.com/fernandohaeser/dev-setup/main"
$tempRoot = Join-Path $env:TEMP ("dev-setup-" + [Guid]::NewGuid().ToString('n'))

try {
  New-Item -ItemType Directory -Path $tempRoot | Out-Null

  if ($installTerminal) {
    Write-Host "🖥️ Configurando terminal..."
    $terminalDir = Join-Path $tempRoot 'terminal'
    New-Item -ItemType Directory -Path $terminalDir | Out-Null

    $terminalScript = Join-Path $terminalDir 'windows.ps1'
    Invoke-WebRequest -Uri "$repoRawBase/terminal/windows.ps1" -UseBasicParsing -OutFile $terminalScript
    try { Unblock-File -Path $terminalScript -ErrorAction SilentlyContinue } catch {}
    & $terminalScript
  }

  Write-Host "🧠 Configurando VS Code..."
  $vscodeDir = Join-Path $tempRoot 'vscode'
  New-Item -ItemType Directory -Path $vscodeDir | Out-Null

  Invoke-WebRequest -Uri "$repoRawBase/vscode/setup.js" -UseBasicParsing -OutFile (Join-Path $vscodeDir 'setup.js')
  Invoke-WebRequest -Uri "$repoRawBase/vscode/settings.json" -UseBasicParsing -OutFile (Join-Path $vscodeDir 'settings.json')

  Push-Location $vscodeDir
  try {
    node .\setup.js
  } finally {
    Pop-Location
  }

  Write-Host "----------------------------------------"
  Write-Host "🔎 Verificando instalações"
  foreach ($cmd in @('winget', 'node', 'git', 'code')) {
    if (Get-Command $cmd -ErrorAction SilentlyContinue) {
      Write-Host "✅ $cmd"
    } else {
      Write-Host "⚠️  $cmd não encontrado (pode exigir reinício do terminal/Windows)"
    }
  }
  if ($installTerminal) {
    foreach ($cmd in @('wt', 'oh-my-posh', 'neofetch')) {
      if (Get-Command $cmd -ErrorAction SilentlyContinue) {
        Write-Host "✅ $cmd"
      } else {
        Write-Host "⚠️  $cmd não encontrado (pode exigir reinício do terminal/Windows)"
      }
    }
  }
} finally {
  if (Test-Path $tempRoot) {
    Remove-Item -Path $tempRoot -Recurse -Force -ErrorAction SilentlyContinue
  }
}

Write-Host "========================================"
Write-Host "✅ Setup concluído! Reinicie o terminal."
Write-Host "========================================"
