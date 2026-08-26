#!/usr/bin/env bash
# ==============================================================================
#  Hermes Stack Installer (All-In-One Automated Setup)
#  Components: Hermes Agent + Hermes WebUI + 9Router + OmniRoute
#  Author: matinbeigi
#  Repository: https://github.com/m4tinbeigi-official/hermes-stack-installer
# ==============================================================================

set -e

# Color definitions
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m' # No Color

# Default Port Configuration (No Conflict Design)
PORT_WEBUI=8787
PORT_9ROUTER=20128
PORT_OMNIROUTE=20129

AUTO_CONFIRM=false
FORCE_REINSTALL=false

for arg in "$@"; do
    case $arg in
        -y|--yes)
            AUTO_CONFIRM=true
            ;;
        --reinstall)
            FORCE_REINSTALL=true
            ;;
    esac
done

TOTAL_STEPS=7
CURRENT_STEP=0

# Directory the user actually invoked the installer from (before any `cd`).
RUN_DIR="$(pwd)"

banner() {
    clear 2>/dev/null || true
    echo -e "${CYAN}${BOLD}"
    echo "  ██╗  ██╗███████╗██████╗ ███╗   ███╗███████╗███████╗"
    echo "  ██║  ██║██╔════╝██╔══██╗████╗ ████║██╔════╝██╔════╝"
    echo "  ███████║█████╗  ██████╔╝██╔████╔██║█████╗  ███████╗"
    echo "  ██╔══██║██╔══╝  ██╔══██╗██║╚██╔╝██║██╔══╝  ╚════██║"
    echo "  ██║  ██║███████╗██║  ██║██║ ╚═╝ ██║███████╗███████║"
    echo "  ╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝╚═╝     ╚═╝╚══════╝╚══════╝"
    echo -e "   🚀 Automated Full-Stack AI Agent & Gateway Installer${NC}"
    echo -e "   Hermes Agent • Hermes WebUI • 9Router • OmniRoute\n"
}

step_header() {
    CURRENT_STEP=$((CURRENT_STEP + 1))
    echo ""
    echo -e "${BLUE}${BOLD}┌──[ ${CYAN}Step ${CURRENT_STEP}/${TOTAL_STEPS}${BLUE} ]───────────────────────────────────────────────────────┐${NC}"
    echo -e "${BLUE}${BOLD}│ ${PURPLE}$1${NC}"
    echo -e "${BLUE}${BOLD}└──────────────────────────────────────────────────────────────────┘${NC}"
}

log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[✔]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[!]${NC} $1"
}

log_error() {
    echo -e "${RED}[✖]${NC} $1"
}

# Generate a random API key without relying on any single tool being present.
generate_api_key() {
    if command -v openssl &>/dev/null; then
        echo "sk-$(openssl rand -hex 16)"
    elif [ -r /dev/urandom ]; then
        echo "sk-$(head -c 16 /dev/urandom | od -An -tx1 | tr -d ' \n')"
    else
        echo "sk-$(date +%s%N)$$"
    fi
}

ask_prompt() {
    local prompt_text="$1"
    local default_ans="$2"
    if [ "$AUTO_CONFIRM" = true ]; then
        echo "$default_ans"
        return
    fi
    read -p "$prompt_text [$default_ans]: " user_ans
    echo "${user_ans:-$default_ans}"
}

# 1. Detect OS and Architecture
detect_system() {
    log_info "Detecting Operating System and Architecture..."
    OS="$(uname -s)"
    ARCH="$(uname -m)"

    case "$OS" in
        Linux*)
            if [ -f /etc/os-release ]; then
                . /etc/os-release
                DISTRO=$ID
            else
                DISTRO="unknown"
            fi
            SYS_TYPE="linux"
            ;;
        Darwin*)
            SYS_TYPE="macos"
            DISTRO="macos"
            ;;
        CYGWIN*|MINGW*|MSYS*)
            SYS_TYPE="windows"
            DISTRO="windows"
            ;;
        *)
            SYS_TYPE="unknown"
            DISTRO="unknown"
            ;;
    esac

    log_success "System detected: ${BOLD}$SYS_TYPE ($DISTRO) - $ARCH${NC}"
}

# 2. Package Manager & Prerequisites
install_prerequisites() {
    step_header "Checking System Prerequisites"

    if [ "$SYS_TYPE" = "macos" ]; then
        if ! command -v brew &>/dev/null; then
            log_warn "Homebrew is not installed. Installing Homebrew..."
            /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        fi
        
        # Check Node.js
        if ! command -v node &>/dev/null; then
            log_info "Installing Node.js..."
            brew install node
        fi
        # Check Python3
        if ! command -v python3 &>/dev/null; then
            log_info "Installing Python 3..."
            brew install python
        fi
        # Check git & curl
        command -v git &>/dev/null || brew install git
        command -v curl &>/dev/null || brew install curl

    elif [ "$SYS_TYPE" = "linux" ]; then
        local PKG_MANAGER=""
        if command -v apt-get &>/dev/null; then
            PKG_MANAGER="apt"
        elif command -v dnf &>/dev/null; then
            PKG_MANAGER="dnf"
        elif command -v pacman &>/dev/null; then
            PKG_MANAGER="pacman"
        fi

        log_info "Package manager found: $PKG_MANAGER"
        
        # Install basic tools
        if [ "$PKG_MANAGER" = "apt" ]; then
            sudo apt-get update -y
            sudo apt-get install -y curl git python3 python3-pip python3-venv build-essential
            if ! command -v node &>/dev/null; then
                log_info "Installing Node.js via NodeSource..."
                curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
                sudo apt-get install -y nodejs
            fi
        elif [ "$PKG_MANAGER" = "dnf" ]; then
            sudo dnf install -y curl git python3 python3-pip nodejs npm make gcc-c++
        elif [ "$PKG_MANAGER" = "pacman" ]; then
            sudo pacman -Sy --noconfirm curl git python python-pip nodejs npm base-devel
        else
            log_warn "Unknown Linux package manager. Please ensure curl, git, python3, and nodejs are installed."
        fi
    fi

    # Install uv (super fast python package installer)
    if ! command -v uv &>/dev/null; then
        log_info "Installing uv (fast Python installer)..."
        curl -LsSf https://astral.sh/uv/install.sh | sh
        export PATH="$HOME/.local/bin:$HOME/.cargo/bin:$PATH"
    fi

    log_success "Prerequisites check complete."
}

# 3. Handle Hermes Agent Installation
install_hermes_agent() {
    step_header "Installing Hermes Agent (Autonomous CLI Core)"
    local HERMES_EXISTS=false
    if command -v hermes &>/dev/null; then
        HERMES_EXISTS=true
    fi

    if [ "$HERMES_EXISTS" = true ] && [ "$FORCE_REINSTALL" = false ]; then
        log_warn "Hermes Agent is already installed at: $(which hermes)"
        local ans=$(ask_prompt "Do you want to reinstall/reset Hermes Agent? (y/N)" "n")
        if [[ ! "$ans" =~ ^[Yy]$ ]]; then
            log_info "Skipping Hermes Agent reinstallation."
            return
        fi
    fi

    log_info "Installing Hermes Agent..."
    curl -fsSL https://hermes-agent.nousresearch.com/install.sh | bash
    export PATH="$HOME/.local/bin:$PATH"
    log_success "Hermes Agent installed successfully."
}

# 4. Handle 9Router Installation
install_9router() {
    step_header "Installing 9Router (AI Gateway - Port $PORT_9ROUTER)"
    local NINE_EXISTS=false
    if command -v 9router &>/dev/null; then
        NINE_EXISTS=true
    fi

    if [ "$NINE_EXISTS" = true ] && [ "$FORCE_REINSTALL" = false ]; then
        log_warn "9Router is already installed at: $(which 9router)"
        local ans=$(ask_prompt "Do you want to reinstall 9Router? (y/N)" "n")
        if [[ ! "$ans" =~ ^[Yy]$ ]]; then
            log_info "Skipping 9Router reinstallation."
            return
        fi
    fi

    log_info "Installing 9Router globally via npm..."
    npm install -g 9router
    log_success "9Router installed successfully (Default Port: $PORT_9ROUTER)."
}

# 5. Handle OmniRoute / omnirouter Installation
install_omniroute() {
    step_header "Installing OmniRoute (Multi-Model Router - Port $PORT_OMNIROUTE)"
    local OMNI_EXISTS=false
    if command -v omniroute &>/dev/null || command -v omnirouter &>/dev/null; then
        OMNI_EXISTS=true
    fi

    if [ "$OMNI_EXISTS" = true ] && [ "$FORCE_REINSTALL" = false ]; then
        log_warn "OmniRoute is already installed."
        local ans=$(ask_prompt "Do you want to reinstall OmniRoute? (y/N)" "n")
        if [[ ! "$ans" =~ ^[Yy]$ ]]; then
            log_info "Skipping OmniRoute reinstallation."
            return
        fi
    fi

    log_info "Installing OmniRoute globally via npm..."
    npm install -g omniroute
    log_success "OmniRoute installed successfully (Configured Port: $PORT_OMNIROUTE to avoid conflicts)."
}

# 6. Handle Hermes WebUI Installation
install_hermes_webui() {
    step_header "Installing Hermes WebUI (Web Dashboard - Port $PORT_WEBUI)"
    log_info "Installing / Updating Hermes WebUI..."
    curl -fsSL https://raw.githubusercontent.com/m4tinbeigi-official/hermes-webui-installer/main/install.sh | bash || true
    log_success "Hermes WebUI ready on port $PORT_WEBUI."
}

# 7. Bridge & Connect All Components
configure_connections() {
    step_header "Connecting Services & Generating Management Scripts"

    local HERMES_CONFIG_DIR="$HOME/.hermes"
    local HERMES_CONFIG_FILE="$HERMES_CONFIG_DIR/config.yaml"
    mkdir -p "$HERMES_CONFIG_DIR"

    # Configure custom endpoints in Hermes Agent config if needed
    if [ ! -f "$HERMES_CONFIG_FILE" ]; then
        API_KEY="$(generate_api_key)"
        cat <<EOF > "$HERMES_CONFIG_FILE"
model:
  default: custom:gemini-2.5-flash
  provider: custom
  base_url: http://127.0.0.1:$PORT_9ROUTER/v1
  api_key: $API_KEY
agent:
  max_turns: 90
terminal:
  backend: local
  timeout: 180
EOF
        log_success "Created default Hermes Agent configuration mapped to 9Router ($PORT_9ROUTER)."
    else
        log_info "Existing config.yaml found at $HERMES_CONFIG_FILE."
        API_KEY="$(grep -E '^\s*api_key:' "$HERMES_CONFIG_FILE" | head -n1 | sed -E 's/^\s*api_key:\s*//')"
    fi

    # Create launch scripts in user bin / scripts directory
    local STACK_DIR="$HOME/.hermes-stack"
    mkdir -p "$STACK_DIR"

    # 1. start-all.sh
    cat << 'EOF' > "$STACK_DIR/start.sh"
#!/usr/bin/env bash
PORT_WEBUI=8787
PORT_9ROUTER=20128
PORT_OMNIROUTE=20129

echo -e "\033[1;34m[Starting Hermes Stack Services...]\033[0m"

# 1. Start 9Router
if command -v 9router &>/dev/null; then
    if ! lsof -i:$PORT_9ROUTER &>/dev/null; then
        nohup 9router -p $PORT_9ROUTER -n > "$HOME/.hermes/9router.log" 2>&1 &
        echo -e "\033[1;32m✔ 9Router started on port $PORT_9ROUTER (PID: $!)\033[0m"
    else
        echo -e "\033[1;33m! 9Router is already running on port $PORT_9ROUTER\033[0m"
    fi
fi

# 2. Start OmniRoute on separate port
if command -v omniroute &>/dev/null; then
    if ! lsof -i:$PORT_OMNIROUTE &>/dev/null; then
        PORT=$PORT_OMNIROUTE nohup omniroute serve --port $PORT_OMNIROUTE > "$HOME/.hermes/omniroute.log" 2>&1 &
        echo -e "\033[1;32m✔ OmniRoute started on port $PORT_OMNIROUTE (PID: $!)\033[0m"
    else
        echo -e "\033[1;33m! OmniRoute is already running on port $PORT_OMNIROUTE\033[0m"
    fi
fi

# 3. Start Hermes WebUI
if [ -f "$HOME/.hermes-webui/server.js" ] || [ -f "$HOME/.hermes/webui/server.js" ]; then
    echo -e "\033[1;32m✔ Hermes WebUI is available at http://127.0.0.1:$PORT_WEBUI\033[0m"
fi

echo -e "\n\033[1;36mAll services are running!\033[0m"
echo -e "WebUI:      \033[1;32mhttp://127.0.0.1:$PORT_WEBUI\033[0m"
echo -e "9Router:    \033[1;32mhttp://127.0.0.1:$PORT_9ROUTER\033[0m"
echo -e "OmniRoute:  \033[1;32mhttp://127.0.0.1:$PORT_OMNIROUTE\033[0m"
EOF
    chmod +x "$STACK_DIR/start.sh"

    # 2. stop-all.sh
    cat << 'EOF' > "$STACK_DIR/stop.sh"
#!/usr/bin/env bash
echo -e "\033[1;31m[Stopping Hermes Stack Services...]\033[0m"
pkill -f "9router" || true
pkill -f "omniroute" || true
pkill -f "hermes-webui" || true
echo -e "\033[1;32m✔ All services stopped.\033[0m"
EOF
    chmod +x "$STACK_DIR/stop.sh"

    # 3. status.sh
    cat << 'EOF' > "$STACK_DIR/status.sh"
#!/usr/bin/env bash
echo -e "\033[1;34m=== Hermes Stack Service Status ===\033[0m"
check_port() {
    local name="$1"
    local port="$2"
    if lsof -i:"$port" &>/dev/null; then
        echo -e "  \033[1;32m● RUNNING\033[0m - $name (Port: $port)"
    else
        echo -e "  \033[1;31m○ STOPPED\033[0m - $name (Port: $port)"
    fi
}
check_port "Hermes WebUI" 8787
check_port "9Router" 20128
check_port "OmniRoute" 20129
EOF
    chmod +x "$STACK_DIR/status.sh"

    # Symlink to ~/.local/bin if available
    mkdir -p "$HOME/.local/bin"
    ln -sf "$STACK_DIR/start.sh" "$HOME/.local/bin/hermes-stack-start" 2>/dev/null || true
    ln -sf "$STACK_DIR/stop.sh" "$HOME/.local/bin/hermes-stack-stop" 2>/dev/null || true
    ln -sf "$STACK_DIR/status.sh" "$HOME/.local/bin/hermes-stack-status" 2>/dev/null || true

    log_success "Management scripts created at $STACK_DIR."
}

# 8. Write the final dashboard/credentials info file, next to where the user ran the script
write_dashboard_info() {
    step_header "Writing Dashboard Links & Credentials"

    local info_file="$RUN_DIR/dashboard-info.txt"

    {
        echo "Hermes Stack - Dashboard Links & Credentials"
        echo "Generated: $(date '+%Y-%m-%d %H:%M:%S')"
        echo "=============================================="
        echo ""
        echo "Hermes WebUI : http://127.0.0.1:$PORT_WEBUI"
        echo "9Router API  : http://127.0.0.1:$PORT_9ROUTER"
        echo "OmniRoute API: http://127.0.0.1:$PORT_OMNIROUTE"
        echo ""
        if [ -n "${API_KEY:-}" ]; then
            echo "Hermes Agent API key (used to authenticate against 9Router): $API_KEY"
        else
            echo "No password/API key was found or generated for these services."
        fi
        echo ""
        echo "Management:"
        echo "  Start : \$HOME/.hermes-stack/start.sh  (or hermes-stack-start)"
        echo "  Stop  : \$HOME/.hermes-stack/stop.sh   (or hermes-stack-stop)"
        echo "  Status: \$HOME/.hermes-stack/status.sh (or hermes-stack-status)"
        echo "  CLI   : hermes"
    } > "$info_file"

    log_success "Dashboard info written to $info_file"
}

# Execution Pipeline
main() {
    banner
    detect_system
    install_prerequisites
    install_hermes_agent
    install_9router
    install_omniroute
    install_hermes_webui
    configure_connections
    write_dashboard_info

    echo -e "\n${GREEN}${BOLD}════════════════════════════════════════════════════════════════${NC}"
    echo -e "${GREEN}${BOLD}  🎉 HERMES FULL STACK INSTALLATION COMPLETE${NC}"
    echo -e "${GREEN}${BOLD}════════════════════════════════════════════════════════════════${NC}"
    echo -e "  ${BOLD}Hermes WebUI:${NC}   ${CYAN}http://127.0.0.1:$PORT_WEBUI${NC}"
    echo -e "  ${BOLD}9Router API:${NC}    ${CYAN}http://127.0.0.1:$PORT_9ROUTER${NC}"
    echo -e "  ${BOLD}OmniRoute API:${NC}  ${CYAN}http://127.0.0.1:$PORT_OMNIROUTE${NC}"
    if [ -n "${API_KEY:-}" ]; then
        echo -e "  ${BOLD}API Key:${NC}        ${YELLOW}$API_KEY${NC}"
    fi
    echo -e "\n  ${BOLD}Commands:${NC}"
    echo -e "  - Start Stack:  ${YELLOW}~/.hermes-stack/start.sh${NC} (or hermes-stack-start)"
    echo -e "  - Stop Stack:   ${YELLOW}~/.hermes-stack/stop.sh${NC} (or hermes-stack-stop)"
    echo -e "  - Status:       ${YELLOW}~/.hermes-stack/status.sh${NC} (or hermes-stack-status)"
    echo -e "  - CLI Agent:    ${YELLOW}hermes${NC}"
    echo -e "\n  ${BOLD}All links and credentials saved to:${NC}"
    echo -e "  ${PURPLE}$RUN_DIR/dashboard-info.txt${NC}\n"
}

main "$@"
