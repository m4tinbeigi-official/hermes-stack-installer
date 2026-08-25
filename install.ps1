# ==============================================================================
#  Hermes Stack Installer for Windows (PowerShell)
#  Components: Hermes Agent + Hermes WebUI + 9Router + OmniRoute
# ==============================================================================

param(
    [switch]$Yes,
    [switch]$Reinstall
)

Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host "       🚀 Hermes Stack Installer (Windows / PowerShell)    " -ForegroundColor Green
Write-Host "==========================================================" -ForegroundColor Cyan

# 1. Check Node.js and npm
if (-not (Get-Command node -ErrorAction SilentlyContinue)) {
    Write-Host "[!] Node.js not found. Please install Node.js (https://nodejs.org) and rerun." -ForegroundColor Yellow
    Exit 1
}

# 2. Check Python
if (-not (Get-Command python -ErrorAction SilentlyContinue)) {
    Write-Host "[!] Python not found. Please install Python 3.10+ (https://python.org) and add to PATH." -ForegroundColor Yellow
}

# 3. Check Hermes Agent
Write-Host "[INFO] Installing / Updating Hermes Agent..." -ForegroundColor Blue
pip install --upgrade hermes-agent

# 4. Install 9Router
Write-Host "[INFO] Installing 9Router..." -ForegroundColor Blue
npm install -g 9router

# 5. Install OmniRoute
Write-Host "[INFO] Installing OmniRoute..." -ForegroundColor Blue
npm install -g omniroute

# 6. Install Hermes WebUI
Write-Host "[INFO] Setting up Hermes WebUI..." -ForegroundColor Blue
git clone https://github.com/m4tinbeigi-official/hermes-webui.git "$env:USERPROFILE\.hermes-webui" -ErrorAction SilentlyContinue
Set-Location "$env:USERPROFILE\.hermes-webui"
npm install --production

Write-Host "`n✔ All components installed successfully!" -ForegroundColor Green
Write-Host "Run 9Router: 9router -p 20128" -ForegroundColor Yellow
Write-Host "Run OmniRoute: omniroute serve --port 20129" -ForegroundColor Yellow
Write-Host "Run Hermes CLI: hermes" -ForegroundColor Yellow
