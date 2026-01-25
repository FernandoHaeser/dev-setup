Write-Host "🚀 Dev Setup - Windows"

$ErrorActionPreference = 'Stop'

try {
  Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass -Force
} catch {}

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
  if ([string]::IsNullOrWhiteSpace($Uri)) {
    throw "Download-File: Uri vazio."
  }
  if ([string]::IsNullOrWhiteSpace($OutFile)) {
    throw "Download-File: OutFile vazio."
  }
  if ($Uri -notmatch '^https?://') {
    throw "Download-File: Uri inválido: $Uri"
  }
  $parent = Split-Path -Parent $OutFile
  if ($parent -and -not (Test-Path $parent)) {
    New-Item -ItemType Directory -Path $parent -Force | Out-Null
  }
  Invoke-WebRequest -Uri $Uri -UseBasicParsing -OutFile $OutFile
}

function Refresh-SessionPath {
  try {
    $machine = [Environment]::GetEnvironmentVariable('Path', 'Machine')
    $user = [Environment]::GetEnvironmentVariable('Path', 'User')
    if ($machine -or $user) {
      $env:Path = @($machine, $user, $env:Path) -join ';'
    }
  } catch {}
}

function Add-ToPathIfExists {
  param([Parameter(Mandatory = $true)][string]$Dir)
  if (-not (Test-Path $Dir)) { return }
  $parts = $env:Path -split ';' | Where-Object { $_ -and $_.Trim() -ne '' }
  if ($parts -contains $Dir) { return }
  $env:Path = "$Dir;$env:Path"
}

function Ensure-ToolOnPath {
  param(
    [Parameter(Mandatory = $true)][string]$Exe,
    [Parameter(Mandatory = $true)][string[]]$CandidateDirs
  )
  Refresh-SessionPath
  foreach ($d in $CandidateDirs) {
    Add-ToPathIfExists -Dir $d
  }
  return (Test-Command $Exe)
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
    try {
      winget install OpenJS.NodeJS.LTS -e --silent --source winget --accept-source-agreements --accept-package-agreements
    } catch {
      Write-Warning "Falha ao instalar Node via winget, usando fallback (MSI): $($_.Exception.Message)"
    }

    if (Test-Command 'node') { return }

    $nodeDirs = @(
      (Join-Path $env:ProgramFiles 'nodejs'),
      (Join-Path $env:LOCALAPPDATA 'Programs\nodejs')
    )
    if (Ensure-ToolOnPath -Exe 'node' -CandidateDirs $nodeDirs) { return }
  }

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
    try {
      winget install Git.Git -e --silent --source winget --accept-source-agreements --accept-package-agreements
    } catch {
      Write-Warning "Falha ao instalar Git via winget, usando fallback (EXE): $($_.Exception.Message)"
    }

    if (Test-Command 'git') { return }

    $gitDirs = @(
      (Join-Path $env:ProgramFiles 'Git\cmd'),
      (Join-Path ${env:ProgramFiles(x86)} 'Git\cmd')
    )
    if (Ensure-ToolOnPath -Exe 'git' -CandidateDirs $gitDirs) { return }
  }

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
    try {
      winget install Microsoft.VisualStudioCode -e --silent --source winget --accept-source-agreements --accept-package-agreements
    } catch {
      Write-Warning "Falha ao instalar VS Code via winget, usando fallback (EXE): $($_.Exception.Message)"
    }

    if (Test-Command 'code') { return }

    $codeDirs = @(
      (Join-Path $env:LOCALAPPDATA 'Programs\Microsoft VS Code\bin'),
      (Join-Path $env:ProgramFiles 'Microsoft VS Code\bin')
    )
    if (Ensure-ToolOnPath -Exe 'code' -CandidateDirs $codeDirs) { return }
  }

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

Ensure-Node -UseWinget:$usingWinget
Ensure-Git -UseWinget:$usingWinget
Ensure-VSCode -UseWinget:$usingWinget

$repoRawBase = "https://raw.githubusercontent.com/fernandohaeser/dev-setup/main"
$tempRoot = Join-Path $env:TEMP ("dev-setup-" + [Guid]::NewGuid().ToString('n'))

try {
  New-Item -ItemType Directory -Path $tempRoot | Out-Null

  if ($env:SETUP_TERMINAL -eq "true") {
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
  if ($env:SETUP_TERMINAL -eq "true") {
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

Write-Host "✅ Setup concluído"
