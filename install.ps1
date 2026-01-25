Write-Host "========================================"
Write-Host "🚀 Dev Setup - Inicialização (Windows)"
Write-Host "========================================"

$ErrorActionPreference = 'Stop'

# Permite execução de scripts nesta sessão (não altera a máquina permanentemente)
try {
  Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass -Force
} catch {}

# Garante TLS moderno para downloads HTTPS em ambientes antigos
try {
  [Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor [Net.SecurityProtocolType]::Tls12
} catch {}

function Test-Command {
  param([Parameter(Mandatory = $true)][string]$Name)
  return [bool](Get-Command $Name -ErrorAction SilentlyContinue)
}

function New-TempDir {
  $dir = Join-Path $env:TEMP ("dev-setup-" + [Guid]::NewGuid().ToString('n'))
  New-Item -ItemType Directory -Path $dir | Out-Null
  return $dir
}

function Download-File {
  param(
    [Parameter(Mandatory = $true)][string]$Uri,
    [Parameter(Mandatory = $true)][string]$OutFile
  )
  Invoke-WebRequest -Uri $Uri -UseBasicParsing -OutFile $OutFile
}

function Install-Msi {
  param([Parameter(Mandatory = $true)][string]$Path)
  $p = Start-Process -FilePath "msiexec.exe" -ArgumentList @('/i', $Path, '/qn', '/norestart') -Wait -PassThru
  if ($p.ExitCode -ne 0) {
    throw "Falha ao instalar MSI (ExitCode=$($p.ExitCode)): $Path"
  }
}

function Install-Exe {
  param(
    [Parameter(Mandatory = $true)][string]$Path,
    [Parameter(Mandatory = $true)][string[]]$Args
  )
  $p = Start-Process -FilePath $Path -ArgumentList $Args -Wait -PassThru
  if ($p.ExitCode -ne 0) {
    throw "Falha ao instalar EXE (ExitCode=$($p.ExitCode)): $Path"
  }
}

function Ensure-Winget {
  if (Test-Command 'winget') { return $true }

  Write-Host "📦 Winget não encontrado. Tentando instalar o App Installer (winget)..."
  $tmp = New-TempDir
  try {
    $vclibs = Join-Path $tmp 'Microsoft.VCLibs.x64.14.00.Desktop.appx'
    Download-File -Uri 'https://aka.ms/Microsoft.VCLibs.x64.14.00.Desktop.appx' -OutFile $vclibs
    try { Add-AppxPackage -Path $vclibs -ErrorAction SilentlyContinue } catch {}

    $bundle = Join-Path $tmp 'Microsoft.DesktopAppInstaller.msixbundle'
    Download-File -Uri 'https://aka.ms/getwinget' -OutFile $bundle
    Add-AppxPackage -Path $bundle -ErrorAction Stop
  } catch {
    Write-Warning "Não foi possível instalar o winget automaticamente: $($_.Exception.Message)"
    return $false
  } finally {
    Remove-Item -Path $tmp -Recurse -Force -ErrorAction SilentlyContinue
  }

  Start-Sleep -Seconds 2
  return (Test-Command 'winget')
}

function Ensure-Node {
  param([Parameter(Mandatory = $true)][bool]$UseWinget)
  if (Test-Command 'node') { return }

  if ($UseWinget) {
    Write-Host "📦 Instalando Node.js (winget)..."
    try {
      winget install OpenJS.NodeJS.LTS -e --silent --source winget --accept-source-agreements --accept-package-agreements
    } catch {
      Write-Warning "Falha ao instalar via winget, usando fallback (MSI): $($_.Exception.Message)"
    }

    if (Test-Command 'node') { return }
  }

  Write-Host "📦 Instalando Node.js (MSI)..."
  $tmp = New-TempDir
  try {
    $index = Invoke-RestMethod -Uri 'https://nodejs.org/dist/index.json'
    $lts = $index | Where-Object { $_.lts -ne $false } | Select-Object -First 1
    if (-not $lts) { throw 'Não foi possível determinar a versão LTS do Node.js.' }

    $v = $lts.version.TrimStart('v')
    $msiUrl = "https://nodejs.org/dist/$($lts.version)/node-$v-x64.msi"
    $msiPath = Join-Path $tmp "node-$v-x64.msi"
    Download-File -Uri $msiUrl -OutFile $msiPath
    Install-Msi -Path $msiPath
  } finally {
    Remove-Item -Path $tmp -Recurse -Force -ErrorAction SilentlyContinue
  }
}

function Ensure-Git {
  param([Parameter(Mandatory = $true)][bool]$UseWinget)
  if (Test-Command 'git') { return }

  if ($UseWinget) {
    Write-Host "📦 Instalando Git (winget)..."
    try {
      winget install Git.Git -e --silent --source winget --accept-source-agreements --accept-package-agreements
    } catch {
      Write-Warning "Falha ao instalar via winget, usando fallback (EXE): $($_.Exception.Message)"
    }

    if (Test-Command 'git') { return }
  }

  Write-Host "📦 Instalando Git (EXE)..."
  $tmp = New-TempDir
  try {
    $exeUrl = 'https://github.com/git-for-windows/git/releases/latest/download/Git-64-bit.exe'
    $exePath = Join-Path $tmp 'git-installer.exe'
    Download-File -Uri $exeUrl -OutFile $exePath
    Install-Exe -Path $exePath -Args @('/VERYSILENT', '/NORESTART')
  } finally {
    Remove-Item -Path $tmp -Recurse -Force -ErrorAction SilentlyContinue
  }
}

function Ensure-VSCode {
  param([Parameter(Mandatory = $true)][bool]$UseWinget)
  if (Test-Command 'code') { return }

  if ($UseWinget) {
    Write-Host "📦 Instalando VS Code (winget)..."
    try {
      winget install Microsoft.VisualStudioCode -e --silent --source winget --accept-source-agreements --accept-package-agreements
    } catch {
      Write-Warning "Falha ao instalar via winget, usando fallback (EXE): $($_.Exception.Message)"
    }

    if (Test-Command 'code') { return }
  }

  Write-Host "📦 Instalando VS Code (EXE)..."
  $tmp = New-TempDir
  try {
    $exeUrl = 'https://update.code.visualstudio.com/latest/win32-x64-user/stable'
    $exePath = Join-Path $tmp 'vscode-installer.exe'
    Download-File -Uri $exeUrl -OutFile $exePath
    Install-Exe -Path $exePath -Args @(
      '/VERYSILENT',
      '/NORESTART',
      '/MERGETASKS=!runcode,addcontextmenufiles,addcontextmenufolders,associatewithfiles,addtopath'
    )
  } finally {
    Remove-Item -Path $tmp -Recurse -Force -ErrorAction SilentlyContinue
  }
}

 $usingWinget = Ensure-Winget

$installTerminal = Read-Host "Deseja instalar/configurar o TERMINAL? (s/n)"
$installTerminal = $installTerminal.ToLower() -eq "s"

Ensure-Node -UseWinget:$usingWinget
Ensure-Git -UseWinget:$usingWinget
Ensure-VSCode -UseWinget:$usingWinget

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
    if (Test-Command 'pwsh') {
      & pwsh -NoProfile -ExecutionPolicy Bypass -File $terminalScript
    } else {
      & powershell.exe -NoProfile -ExecutionPolicy Bypass -File $terminalScript
    }
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
