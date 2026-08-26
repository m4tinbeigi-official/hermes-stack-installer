# ==============================================================================
#  Hermes Stack Installer for Windows (PowerShell)
#  Components: Hermes Agent + Hermes WebUI + 9Router + OmniRoute
#  Repository: https://github.com/m4tinbeigi-official/hermes-stack-installer
# ==============================================================================

param(
    [switch]$Yes,
    [switch]$Reinstall
)

$ErrorActionPreference = "Stop"

$PORT_WEBUI = 8787
$PORT_9ROUTER = 20128
$PORT_OMNIROUTE = 20129

$HermesDir  = Join-Path $env:USERPROFILE ".hermes"
$StackDir   = Join-Path $env:USERPROFILE ".hermes-stack"
$WebUIDir   = Join-Path $env:USERPROFILE "hermes-webui"
$ConfigFile = Join-Path $HermesDir "config.yaml"

# The final links/credentials file is written next to where this script is run from.
$RunDir   = (Get-Location).Path
$InfoFile = Join-Path $RunDir "dashboard-info.txt"

$TotalSteps = 7
$CurrentStep = 0

# ---- Pretty console helpers --------------------------------------------------------
function Write-Banner {
    Write-Host ""
    Write-Host '  __  __                                  ____  _             _    ' -ForegroundColor Cyan
    Write-Host ' |  \/  | ___ _ __ _ __ ___   ___  ___    / ___|| |_ __ _  ___| | __' -ForegroundColor Cyan
    Write-Host ' | |\/| |/ _ \ ''__| ''_ ` _ \ / _ \/ __|   \___ \| __/ _` |/ __| |/ /' -ForegroundColor Cyan
    Write-Host ' | |  | |  __/ |  | | | | | |  __/\__ \    ___) | || (_| | (__|   < ' -ForegroundColor Cyan
    Write-Host ' |_|  |_|\___|_|  |_| |_| |_|\___||___/   |____/ \__\__,_|\___|_|\_\' -ForegroundColor Cyan
    Write-Host ""
    Write-Host "        Automated Full-Stack AI Agent & Gateway Installer" -ForegroundColor Magenta
    Write-Host "        Hermes Agent  -  Hermes WebUI  -  9Router  -  OmniRoute" -ForegroundColor DarkGray
    Write-Host ""
}

function Step-Header($title) {
    $script:CurrentStep++
    Write-Host ""
    Write-Host ("+-- [ Step $CurrentStep/$TotalSteps ] " + ("-" * 50)) -ForegroundColor Blue
    Write-Host "|  $title" -ForegroundColor White
    Write-Host ("+" + ("-" * 68)) -ForegroundColor Blue
}

function Log-Info    { param($m) Write-Host "  -> $m" -ForegroundColor Cyan }
function Log-Success { param($m) Write-Host "  [OK] $m" -ForegroundColor Green }
function Log-Warn    { param($m) Write-Host "  [!]  $m" -ForegroundColor Yellow }
function Log-Error   { param($m) Write-Host "  [X]  $m" -ForegroundColor Red }

function Confirm-Reinstall($name) {
    if ($Reinstall) { return $true }
    if ($Yes) { return $false }
    $ans = Read-Host "  $name is already installed. Reinstall/reset it? (y/N)"
    return ($ans -match '^[Yy]$')
}

# 1. Prerequisites -------------------------------------------------------------
function Install-Prerequisites {
    Step-Header "Checking System Prerequisites"

    if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
        Log-Warn "git not found. Installing via winget..."
        winget install --id Git.Git -e --source winget --accept-package-agreements --accept-source-agreements | Out-Null
    }
    Log-Success "git is ready"

    if (-not (Get-Command node -ErrorAction SilentlyContinue)) {
        Log-Warn "Node.js not found. Installing via winget..."
        winget install --id OpenJS.NodeJS.LTS -e --source winget --accept-package-agreements --accept-source-agreements | Out-Null
    }
    if (-not (Get-Command node -ErrorAction SilentlyContinue)) {
        Log-Error "Node.js is required but could not be installed automatically."
        Log-Error "Install it from https://nodejs.org and rerun this script."
        exit 1
    }
    Log-Success "Node.js is ready ($(node --version))"

    if (-not (Get-Command python -ErrorAction SilentlyContinue)) {
        Log-Warn "Python not found. Installing via winget..."
        winget install --id Python.Python.3.12 -e --source winget --accept-package-agreements --accept-source-agreements | Out-Null
    }
    if (-not (Get-Command python -ErrorAction SilentlyContinue)) {
        Log-Warn "Python still not found. Install it from https://python.org and rerun."
    } else {
        Log-Success "Python is ready ($(python --version))"
    }

    Log-Success "Prerequisites check complete"
}

# 2. Hermes Agent ---------------------------------------------------------------
function Install-HermesAgent {
    Step-Header "Installing Hermes Agent (Autonomous CLI Core)"
    $exists = Get-Command hermes -ErrorAction SilentlyContinue
    if ($exists -and -not (Confirm-Reinstall "Hermes Agent")) {
        Log-Info "Skipping Hermes Agent reinstallation"
        return
    }
    Log-Info "Installing Hermes Agent via pip..."
    pip install --upgrade hermes-agent | Out-Null
    Log-Success "Hermes Agent installed"
}

# 3. 9Router ---------------------------------------------------------------------
function Install-9Router {
    Step-Header "Installing 9Router (AI Gateway - Port $PORT_9ROUTER)"
    $exists = Get-Command 9router -ErrorAction SilentlyContinue
    if ($exists -and -not (Confirm-Reinstall "9Router")) {
        Log-Info "Skipping 9Router reinstallation"
        return
    }
    Log-Info "Installing 9Router globally via npm..."
    npm install -g 9router --silent | Out-Null
    Log-Success "9Router installed (port $PORT_9ROUTER)"
}

# 4. OmniRoute ---------------------------------------------------------------------
function Install-OmniRoute {
    Step-Header "Installing OmniRoute (Multi-Model Router - Port $PORT_OMNIROUTE)"
    $exists = (Get-Command omniroute -ErrorAction SilentlyContinue) -or (Get-Command omnirouter -ErrorAction SilentlyContinue)
    if ($exists -and -not (Confirm-Reinstall "OmniRoute")) {
        Log-Info "Skipping OmniRoute reinstallation"
        return
    }
    Log-Info "Installing OmniRoute globally via npm..."
    npm install -g omniroute --silent | Out-Null
    Log-Success "OmniRoute installed (port $PORT_OMNIROUTE)"
}

# 5. Hermes WebUI ---------------------------------------------------------------------
# Mirrors https://github.com/m4tinbeigi-official/hermes-webui-installer/blob/main/install.sh:
# it's a Python app (venv + requirements.txt + bootstrap.py), not an npm package.
function Install-HermesWebUI {
    Step-Header "Installing Hermes WebUI (Web Dashboard - Port $PORT_WEBUI)"

    if (Test-Path (Join-Path $WebUIDir ".git")) {
        if (-not (Confirm-Reinstall "Hermes WebUI")) {
            Log-Info "Updating existing Hermes WebUI checkout..."
            Push-Location $WebUIDir
            git pull --quiet 2>$null
            Pop-Location
        } else {
            Remove-Item -Recurse -Force $WebUIDir
            Log-Info "Cloning Hermes WebUI..."
            git clone --quiet https://github.com/nesquena/hermes-webui.git $WebUIDir
        }
    } else {
        Log-Info "Cloning Hermes WebUI..."
        git clone --quiet https://github.com/nesquena/hermes-webui.git $WebUIDir
    }

    $venvDir = Join-Path $WebUIDir ".venv"
    $venvPython = Join-Path $venvDir "Scripts\python.exe"
    if (-not (Test-Path $venvPython)) {
        Log-Info "Creating Python virtual environment..."
        python -m venv $venvDir
    }

    Log-Info "Upgrading pip and build tools..."
    & $venvPython -m pip install --quiet --upgrade pip setuptools wheel

    $requirementsFile = Join-Path $WebUIDir "requirements.txt"
    if (Test-Path $requirementsFile) {
        Log-Info "Installing WebUI requirements..."
        & $venvPython -m pip install --quiet -r $requirementsFile
    }
    Log-Info "Installing optional companion parsers..."
    & $venvPython -m pip install --quiet psutil edge-tts python-docx openpyxl python-pptx

    $script:WebUIVenvPython = $venvPython
    Log-Success "Hermes WebUI ready (port $PORT_WEBUI)"
}

# 6. Bridge & connect everything ----------------------------------------------------
function Configure-Connections {
    Step-Header "Connecting Services & Generating Management Scripts"
    New-Item -ItemType Directory -Force -Path $HermesDir | Out-Null
    New-Item -ItemType Directory -Force -Path $StackDir | Out-Null

    $script:ApiKey = $null
    if (-not (Test-Path $ConfigFile)) {
        $script:ApiKey = "sk-" + [Guid]::NewGuid().ToString("N")
        @"
model:
  default: custom:gemini-2.5-flash
  provider: custom
  base_url: http://127.0.0.1:$PORT_9ROUTER/v1
  api_key: $script:ApiKey
agent:
  max_turns: 90
terminal:
  backend: local
  timeout: 180
"@ | Set-Content -Path $ConfigFile -Encoding UTF8
        Log-Success "Created Hermes Agent config mapped to 9Router (port $PORT_9ROUTER)"
    } else {
        Log-Info "Existing config.yaml found at $ConfigFile"
        $line = Select-String -Path $ConfigFile -Pattern '^\s*api_key:\s*(\S+)' -ErrorAction SilentlyContinue
        if ($line) { $script:ApiKey = $line.Matches[0].Groups[1].Value }
    }

    $webUIVenvPython = Join-Path $WebUIDir ".venv\Scripts\python.exe"

    # start.ps1
    @"
`$PORT_WEBUI = $PORT_WEBUI
`$PORT_9ROUTER = $PORT_9ROUTER
`$PORT_OMNIROUTE = $PORT_OMNIROUTE

Write-Host '[Starting Hermes Stack Services...]' -ForegroundColor Cyan

if (Get-Command 9router -ErrorAction SilentlyContinue) {
    Start-Process -WindowStyle Hidden -FilePath 9router -ArgumentList "-p `$PORT_9ROUTER -n" -RedirectStandardOutput "`$env:USERPROFILE\.hermes\9router.log"
    Write-Host "  [OK] 9Router started on port `$PORT_9ROUTER" -ForegroundColor Green
}
if (Get-Command omniroute -ErrorAction SilentlyContinue) {
    Start-Process -WindowStyle Hidden -FilePath omniroute -ArgumentList "serve --port `$PORT_OMNIROUTE" -RedirectStandardOutput "`$env:USERPROFILE\.hermes\omniroute.log"
    Write-Host "  [OK] OmniRoute started on port `$PORT_OMNIROUTE" -ForegroundColor Green
}
if (Test-Path "$webUIVenvPython") {
    Push-Location "$WebUIDir"
    Start-Process -WindowStyle Hidden -FilePath "$webUIVenvPython" -ArgumentList "bootstrap.py" -RedirectStandardOutput "`$env:USERPROFILE\.hermes\webui.log"
    Pop-Location
    Write-Host "  [OK] Hermes WebUI started on port `$PORT_WEBUI" -ForegroundColor Green
}

Write-Host ""
Write-Host "All services launched." -ForegroundColor Cyan
Write-Host "WebUI:      http://127.0.0.1:`$PORT_WEBUI"
Write-Host "9Router:    http://127.0.0.1:`$PORT_9ROUTER"
Write-Host "OmniRoute:  http://127.0.0.1:`$PORT_OMNIROUTE"
"@ | Set-Content -Path (Join-Path $StackDir "start.ps1") -Encoding UTF8

    # stop.ps1
    @"
Write-Host '[Stopping Hermes Stack Services...]' -ForegroundColor Red
Get-Process node,9router,omniroute,python -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue
Write-Host 'All services stopped.' -ForegroundColor Green
"@ | Set-Content -Path (Join-Path $StackDir "stop.ps1") -Encoding UTF8

    # status.ps1
    @"
function Check-Port(`$name, `$port) {
    `$inUse = Get-NetTCPConnection -LocalPort `$port -ErrorAction SilentlyContinue
    if (`$inUse) {
        Write-Host "  [RUNNING] `$name (Port: `$port)" -ForegroundColor Green
    } else {
        Write-Host "  [STOPPED] `$name (Port: `$port)" -ForegroundColor Red
    }
}
Write-Host '=== Hermes Stack Service Status ===' -ForegroundColor Cyan
Check-Port 'Hermes WebUI' $PORT_WEBUI
Check-Port '9Router' $PORT_9ROUTER
Check-Port 'OmniRoute' $PORT_OMNIROUTE
"@ | Set-Content -Path (Join-Path $StackDir "status.ps1") -Encoding UTF8

    Log-Success "Management scripts created at $StackDir"
}

# 7. Write the final dashboard/credentials info file --------------------------------
function Write-DashboardInfo {
    Step-Header "Writing Dashboard Links & Credentials"
    $lines = @()
    $lines += "Hermes Stack - Dashboard Links & Credentials"
    $lines += "Generated: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
    $lines += "=============================================="
    $lines += ""
    $lines += "Hermes WebUI : http://127.0.0.1:$PORT_WEBUI"
    $lines += "9Router API  : http://127.0.0.1:$PORT_9ROUTER"
    $lines += "OmniRoute API: http://127.0.0.1:$PORT_OMNIROUTE"
    $lines += ""
    if ($script:ApiKey) {
        $lines += "Hermes Agent API key (used to authenticate against 9Router): $script:ApiKey"
    } else {
        $lines += "No password/API key was found or generated for these services."
    }
    $lines += ""
    $lines += "Management:"
    $lines += "  Start : $StackDir\start.ps1"
    $lines += "  Stop  : $StackDir\stop.ps1"
    $lines += "  Status: $StackDir\status.ps1"
    $lines += "  CLI   : hermes"

    Set-Content -Path $InfoFile -Value $lines -Encoding UTF8
    Log-Success "Dashboard info written to $InfoFile"
}

# Execution Pipeline ------------------------------------------------------------------
function Main {
    Write-Banner
    Install-Prerequisites
    Install-HermesAgent
    Install-9Router
    Install-OmniRoute
    Install-HermesWebUI
    Configure-Connections
    Write-DashboardInfo

    Write-Host ""
    Write-Host ("*" * 70) -ForegroundColor Green
    Write-Host "  HERMES FULL STACK INSTALLATION COMPLETE" -ForegroundColor Green
    Write-Host ("*" * 70) -ForegroundColor Green
    Write-Host ""
    Write-Host "  Dashboard WebUI  : " -NoNewline -ForegroundColor White
    Write-Host "http://127.0.0.1:$PORT_WEBUI" -ForegroundColor Cyan
    Write-Host "  9Router API      : " -NoNewline -ForegroundColor White
    Write-Host "http://127.0.0.1:$PORT_9ROUTER" -ForegroundColor Cyan
    Write-Host "  OmniRoute API    : " -NoNewline -ForegroundColor White
    Write-Host "http://127.0.0.1:$PORT_OMNIROUTE" -ForegroundColor Cyan
    if ($script:ApiKey) {
        Write-Host "  API Key          : " -NoNewline -ForegroundColor White
        Write-Host "$script:ApiKey" -ForegroundColor Yellow
    }
    Write-Host ""
    Write-Host "  Start Stack : " -NoNewline -ForegroundColor DarkGray
    Write-Host "$StackDir\start.ps1" -ForegroundColor Gray
    Write-Host "  Stop Stack  : " -NoNewline -ForegroundColor DarkGray
    Write-Host "$StackDir\stop.ps1" -ForegroundColor Gray
    Write-Host "  Status      : " -NoNewline -ForegroundColor DarkGray
    Write-Host "$StackDir\status.ps1" -ForegroundColor Gray
    Write-Host ""
    Write-Host "  All links and credentials saved to:" -ForegroundColor White
    Write-Host "  $InfoFile" -ForegroundColor Magenta
    Write-Host ""
    Write-Host ("*" * 70) -ForegroundColor Green
    Write-Host ""
}

Main
