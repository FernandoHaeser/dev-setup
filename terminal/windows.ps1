# TERMINAL DEV SETUP - WINDOWS

$ErrorActionPreference = 'Stop'

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
    winget install --id Microsoft.WindowsTerminal -e --silent --accept-source-agreements --accept-package-agreements
    winget install --id Microsoft.PowerShell -e --silent --accept-source-agreements --accept-package-agreements
    winget install --id JanDeDobbeleer.OhMyPosh -e --silent --accept-source-agreements --accept-package-agreements
    winget install --id Neofetch.Neofetch -e --silent --accept-source-agreements --accept-package-agreements
} else {
    Write-Warning "Winget ainda não está disponível. Vou configurar o profile do PowerShell, mas não consigo instalar Windows Terminal/Oh My Posh/Neofetch automaticamente sem winget."
}

Install-Module PSReadLine -Force -SkipPublisherCheck -Scope CurrentUser
Install-Module Terminal-Icons -Force -SkipPublisherCheck -Scope CurrentUser

$profilePath = $PROFILE
$profileDir = Split-Path $profilePath

if (!(Test-Path $profileDir)) {
    New-Item -ItemType Directory -Path $profileDir
}

@"
# ================================
# PROFILE DEV - PowerShell
# ================================

# Prompt bonito
if (Get-Command oh-my-posh -ErrorAction SilentlyContinue) {
    if (Test-Path "\$env:POSH_THEMES_PATH\\jandedobbeleer.omp.json") {
        oh-my-posh init pwsh --config "\$env:POSH_THEMES_PATH\\jandedobbeleer.omp.json" | Invoke-Expression
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

# Neofetch ao abrir
if (Get-Command neofetch -ErrorAction SilentlyContinue) { neofetch }

# Aliases úteis
Set-Alias ll ls
Set-Alias g git
Set-Alias py python
if (Test-Path "C:\\Program Files\\Microsoft VS Code\\Code.exe") {
    Set-Alias code "C:\\Program Files\\Microsoft VS Code\\Code.exe"
}

# Git branch no prompt
\$env:POSH_GIT_ENABLED = \$true
"@ | Out-File -Encoding UTF8 $profilePath

Write-Host "Setup concluído! Reinicie o Windows Terminal." -ForegroundColor Green
