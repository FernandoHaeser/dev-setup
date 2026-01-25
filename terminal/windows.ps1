# TERMINAL DEV SETUP - WINDOWS

$ErrorActionPreference = 'Stop'

try {
    Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass -Force
} catch {}

Write-Host "Iniciando setup do terminal..." -ForegroundColor Cyan

if (!(Get-Command winget -ErrorAction SilentlyContinue)) {
    Write-Warning "Winget não encontrado. Tentando instalar o App Installer (winget)..."
    $tmp = Join-Path $env:TEMP ("dev-setup-" + [Guid]::NewGuid().ToString('n'))
    New-Item -ItemType Directory -Path $tmp | Out-Null
    try {
        $vclibs = Join-Path $tmp 'Microsoft.VCLibs.x64.14.00.Desktop.appx'
        Invoke-WebRequest -Uri 'https://aka.ms/Microsoft.VCLibs.x64.14.00.Desktop.appx' -UseBasicParsing -OutFile $vclibs
        try { Add-AppxPackage -Path $vclibs -ErrorAction SilentlyContinue } catch {}

        $bundle = Join-Path $tmp 'Microsoft.DesktopAppInstaller.msixbundle'
        Invoke-WebRequest -Uri 'https://aka.ms/getwinget' -UseBasicParsing -OutFile $bundle
        Add-AppxPackage -Path $bundle -ErrorAction SilentlyContinue
    } catch {
        Write-Warning "Não foi possível instalar o winget automaticamente: $($_.Exception.Message)"
    } finally {
        Remove-Item -Path $tmp -Recurse -Force -ErrorAction SilentlyContinue
    }
}

if (Get-Command winget -ErrorAction SilentlyContinue) {
    foreach ($pkg in @(
        @{ id = 'Microsoft.WindowsTerminal'; name = 'Windows Terminal' },
        @{ id = 'Microsoft.PowerShell'; name = 'PowerShell' },
        @{ id = 'JanDeDobbeleer.OhMyPosh'; name = 'Oh My Posh' },
        @{ id = 'Neofetch.Neofetch'; name = 'Neofetch' },
        @{ id = 'Fastfetch-cli.Fastfetch'; name = 'Fastfetch' }
    )) {
        try {
            winget install --id $pkg.id -e --silent --source winget --accept-source-agreements --accept-package-agreements
        } catch {
            Write-Warning "Falha ao instalar $($pkg.name) via winget: $($_.Exception.Message)"
        }
    }
} else {
    Write-Warning "Winget ainda não está disponível. Vou configurar o profile do PowerShell, mas não consigo instalar Windows Terminal/Oh My Posh/Neofetch automaticamente sem winget."
}

Install-Module PSReadLine -Force -SkipPublisherCheck -Scope CurrentUser
Install-Module Terminal-Icons -Force -SkipPublisherCheck -Scope CurrentUser

function Get-DevSetupProfilePath {
    $docs = [Environment]::GetFolderPath('MyDocuments')
    $ps7ProfilePath = Join-Path (Join-Path $docs 'PowerShell') 'Microsoft.PowerShell_profile.ps1'
    $ps5ProfilePath = Join-Path (Join-Path $docs 'WindowsPowerShell') 'Microsoft.PowerShell_profile.ps1'

    # Prefer PowerShell 7 profile to avoid Windows PowerShell (5.1) ExecutionPolicy surprises.
    if (Get-Command pwsh -ErrorAction SilentlyContinue) {
        return $ps7ProfilePath
    }

    # Fallback: current host profile (usually Windows PowerShell profile when running in 5.1).
    $currentUserPolicy = $null
    try { $currentUserPolicy = Get-ExecutionPolicy -Scope CurrentUser } catch {}
    if ($currentUserPolicy -eq 'Restricted' -and $PROFILE -eq $ps5ProfilePath) {
        Write-Warning "Seu PowerShell está com ExecutionPolicy=Restricted para o usuário. Vou pular a escrita do profile para evitar o erro 'execução de scripts foi desabilitada'."
        Write-Warning "Abra o PowerShell 7 (pwsh) ou rode: Set-ExecutionPolicy -Scope CurrentUser RemoteSigned"
        return $null
    }

    return $PROFILE
}

$profilePath = Get-DevSetupProfilePath
if (-not $profilePath) {
    Write-Host "Setup do terminal concluído (sem alterar o profile)." -ForegroundColor Yellow
    return
}

$profileDir = Split-Path $profilePath

if (!(Test-Path $profileDir)) {
    New-Item -ItemType Directory -Path $profileDir -Force | Out-Null
}

@'
# ================================
# PROFILE DEV - PowerShell
# ================================

# Prompt bonito
if (Get-Command oh-my-posh -ErrorAction SilentlyContinue) {
    if (Test-Path "$env:POSH_THEMES_PATH\jandedobbeleer.omp.json") {
        oh-my-posh init pwsh --config "$env:POSH_THEMES_PATH\jandedobbeleer.omp.json" | Invoke-Expression
    } else {
        oh-my-posh init pwsh | Invoke-Expression
    }
}

# Ícones em pastas
Import-Module Terminal-Icons -ErrorAction SilentlyContinue

# Autocomplete melhor
if (Get-Module -ListAvailable -Name PSReadLine) {
    Set-PSReadLineOption -PredictionSource History
    Set-PSReadLineOption -PredictionViewStyle ListView
    Set-PSReadLineKeyHandler -Key Tab -Function Complete
}

# Fastfetch/Neofetch ao abrir
if (Get-Command fastfetch -ErrorAction SilentlyContinue) {
    fastfetch
} elseif (Get-Command neofetch -ErrorAction SilentlyContinue) {
    neofetch
}

# Aliases úteis
Set-Alias ll ls
Set-Alias g git
Set-Alias py python
if (Test-Path "C:\\Program Files\\Microsoft VS Code\\Code.exe") {
    Set-Alias code "C:\\Program Files\\Microsoft VS Code\\Code.exe"
}

# Git branch no prompt
$env:POSH_GIT_ENABLED = $true
'@ | Out-File -Encoding UTF8 $profilePath

Write-Host "Setup concluído! Reinicie o Windows Terminal." -ForegroundColor Green
