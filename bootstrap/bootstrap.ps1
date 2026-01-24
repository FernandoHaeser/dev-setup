Write-Host "🚀 Dev Setup - Windows"

$ErrorActionPreference = 'Stop'

try {
  [Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor [Net.SecurityProtocolType]::Tls12
} catch {}

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

$repoRawBase = "https://raw.githubusercontent.com/fernandohaeser/dev-setup/main"
$tempRoot = Join-Path $env:TEMP ("dev-setup-" + [Guid]::NewGuid().ToString('n'))

try {
  New-Item -ItemType Directory -Path $tempRoot | Out-Null

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

  if ($env:SETUP_TERMINAL -eq "true") {
    $terminalDir = Join-Path $tempRoot 'terminal'
    New-Item -ItemType Directory -Path $terminalDir | Out-Null
    $terminalScript = Join-Path $terminalDir 'windows.ps1'
    Invoke-WebRequest -Uri "$repoRawBase/terminal/windows.ps1" -UseBasicParsing -OutFile $terminalScript
    & $terminalScript
  }
} finally {
  if (Test-Path $tempRoot) {
    Remove-Item -Path $tempRoot -Recurse -Force -ErrorAction SilentlyContinue
  }
}

Write-Host "✅ Setup concluído"
