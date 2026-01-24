# TERMINAL DEV SETUP - WINDOWS

Write-Host "Iniciando setup do terminal..." -ForegroundColor Cyan

if (!(Get-Command winget -ErrorAction SilentlyContinue)) {
    Write-Error "Winget não encontrado. Atualize o Windows."
    exit
}

winget install --id Microsoft.WindowsTerminal -e --silent

winget install --id Microsoft.PowerShell -e --silent

winget install JanDeDobbeleer.OhMyPosh -s winget --silent

winget install --id Neofetch.Neofetch -e --silent

Install-Module PSReadLine -Force -SkipPublisherCheck
Install-Module Terminal-Icons -Force -SkipPublisherCheck

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
oh-my-posh init pwsh --config "\$env:POSH_THEMES_PATH\\jandedobbeleer.omp.json" | Invoke-Expression

# Ícones em pastas
Import-Module Terminal-Icons

# Autocomplete melhor
Set-PSReadLineOption -PredictionSource History
Set-PSReadLineOption -PredictionViewStyle ListView
Set-PSReadLineKeyHandler -Key Tab -Function Complete

# Neofetch ao abrir
neofetch

# Aliases úteis
Set-Alias ll ls
Set-Alias g git
Set-Alias py python
Set-Alias code "C:\\Program Files\\Microsoft VS Code\\Code.exe"

# Git branch no prompt
\$env:POSH_GIT_ENABLED = \$true
"@ | Out-File -Encoding UTF8 $profilePath

Write-Host "Setup concluído! Reinicie o Windows Terminal." -ForegroundColor Green
