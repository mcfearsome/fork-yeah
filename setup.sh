#!/bin/bash

# fork-yeah Setup Script
# Detects OS, checks dependencies, and installs fork-yeah for Claude Code

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
FORK_YEAH_DIR="$HOME/.claude-code/forks"
CONFIG_DIR="$HOME/.config/fork-yeah"

# Print colored message
print_msg() {
    local color=$1
    shift
    echo -e "${color}$@${NC}"
}

print_header() {
    print_msg "$BLUE" "\n========================================="
    print_msg "$BLUE" "$@"
    print_msg "$BLUE" "=========================================\n"
}

print_success() { print_msg "$GREEN" "✓ $@"; }
print_error() { print_msg "$RED" "✗ $@"; }
print_warning() { print_msg "$YELLOW" "⚠ $@"; }
print_info() { print_msg "$BLUE" "ℹ $@"; }

# Detect OS
detect_os() {
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        if grep -q Microsoft /proc/version 2>/dev/null; then
            echo "wsl"
        else
            echo "linux"
        fi
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        echo "macos"
    elif [[ "$OSTYPE" == "cygwin" ]] || [[ "$OSTYPE" == "msys" ]]; then
        echo "windows"
    else
        echo "unknown"
    fi
}

# Detect package manager
detect_package_manager() {
    if command -v apt-get &> /dev/null; then
        echo "apt"
    elif command -v yum &> /dev/null; then
        echo "yum"
    elif command -v dnf &> /dev/null; then
        echo "dnf"
    elif command -v brew &> /dev/null; then
        echo "brew"
    elif command -v pacman &> /dev/null; then
        echo "pacman"
    else
        echo "unknown"
    fi
}

# Check if command exists
command_exists() {
    command -v "$1" &> /dev/null
}

# Check dependencies
check_dependencies() {
    print_header "Checking Dependencies"

    local all_good=true
    local missing_deps=()

    # Required dependencies
    local deps=("git" "python3" "jq")

    for dep in "${deps[@]}"; do
        if command_exists "$dep"; then
            print_success "$dep is installed"
        else
            print_error "$dep is NOT installed"
            all_good=false
            missing_deps+=("$dep")
        fi
    done

    # Check tmux separately (optional but recommended)
    if command_exists tmux; then
        print_success "tmux is installed (recommended)"
        TMUX_AVAILABLE=true
    else
        print_warning "tmux is NOT installed (optional but recommended)"
        TMUX_AVAILABLE=false
    fi

    if [ "$all_good" = false ]; then
        print_error "\nMissing required dependencies: ${missing_deps[*]}"
        return 1
    fi

    return 0
}

# Install tmux
install_tmux() {
    local os=$(detect_os)
    local pkg_mgr=$(detect_package_manager)

    print_header "Installing tmux"

    print_info "Detected OS: $os"
    print_info "Package manager: $pkg_mgr"

    case $pkg_mgr in
        apt)
            print_info "Installing tmux via apt..."
            sudo apt-get update && sudo apt-get install -y tmux
            ;;
        yum|dnf)
            print_info "Installing tmux via $pkg_mgr..."
            sudo $pkg_mgr install -y tmux
            ;;
        brew)
            print_info "Installing tmux via Homebrew..."
            brew install tmux
            ;;
        pacman)
            print_info "Installing tmux via pacman..."
            sudo pacman -S --noconfirm tmux
            ;;
        *)
            print_error "Unable to automatically install tmux."
            print_info "Please install tmux manually for your system:"
            print_info "  - Debian/Ubuntu: sudo apt-get install tmux"
            print_info "  - RHEL/CentOS: sudo yum install tmux"
            print_info "  - Fedora: sudo dnf install tmux"
            print_info "  - macOS: brew install tmux"
            print_info "  - Arch: sudo pacman -S tmux"
            return 1
            ;;
    esac

    if command_exists tmux; then
        print_success "tmux installed successfully!"
        return 0
    else
        print_error "tmux installation failed"
        return 1
    fi
}

# Prompt user to install tmux
prompt_tmux_install() {
    print_warning "\ntmux is not installed but highly recommended for the best experience."
    print_info "tmux enables powerful terminal multiplexing for fork management."

    read -p "Would you like to install tmux now? [y/N] " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        install_tmux
        return $?
    else
        print_info "Skipping tmux installation. fork-yeah will use fallback mode."
        return 0
    fi
}

# Create directory structure
setup_directories() {
    print_header "Setting Up Directories"

    mkdir -p "$FORK_YEAH_DIR"
    mkdir -p "$CONFIG_DIR"

    print_success "Created $FORK_YEAH_DIR"
    print_success "Created $CONFIG_DIR"
}

# Copy configuration files
setup_config() {
    print_header "Setting Up Configuration"

    # Copy default config if it doesn't exist
    if [ ! -f "$CONFIG_DIR/config.yaml" ]; then
        cp "$SCRIPT_DIR/config/config.yaml" "$CONFIG_DIR/config.yaml"
        print_success "Created default config at $CONFIG_DIR/config.yaml"
    else
        print_info "Config already exists at $CONFIG_DIR/config.yaml"
    fi

    # Copy tmux config if tmux is available
    if [ "$TMUX_AVAILABLE" = true ]; then
        if [ ! -f "$CONFIG_DIR/tmux.conf" ]; then
            cp "$SCRIPT_DIR/config/tmux.conf" "$CONFIG_DIR/tmux.conf"
            print_success "Created tmux config at $CONFIG_DIR/tmux.conf"
        else
            print_info "tmux config already exists at $CONFIG_DIR/tmux.conf"
        fi
    fi
}

# Make scripts executable
setup_scripts() {
    print_header "Setting Up Scripts"

    chmod +x "$SCRIPT_DIR/src"/*.sh 2>/dev/null || true
    chmod +x "$SCRIPT_DIR/src"/*.py 2>/dev/null || true

    print_success "Made scripts executable"
}

# Install Claude Code skill
setup_claude_skill() {
    print_header "Setting Up Claude Code Integration"

    local claude_skills_dir="$HOME/.claude-code/skills"

    # Create skills directory if it doesn't exist
    mkdir -p "$claude_skills_dir"

    # Create symlink to fork-yeah skill
    if [ -L "$claude_skills_dir/fork-yeah" ]; then
        print_info "fork-yeah skill already linked"
    else
        ln -sf "$SCRIPT_DIR" "$claude_skills_dir/fork-yeah"
        print_success "Linked fork-yeah skill to Claude Code"
    fi
}

# Display final instructions
show_completion() {
    print_header "Setup Complete!"

    print_success "fork-yeah has been installed successfully!"
    print_info "\nYou can now use fork-yeah in Claude Code with these commands:"
    print_info "  /fork create <number>  - Create N parallel branches"
    print_info "  /fork list             - Show all active forks"
    print_info "  /fork switch <id>      - Switch to a fork branch"
    print_info "  /fork tree             - Visualize fork hierarchy"

    if [ "$TMUX_AVAILABLE" = true ]; then
        print_success "\ntmux is available - you'll get the full experience!"
    else
        print_warning "\ntmux is not available - using fallback mode"
        print_info "For the best experience, install tmux:"
        print_info "  You can run this setup script again after installing tmux"
    fi

    print_info "\nConfiguration files:"
    print_info "  $CONFIG_DIR/config.yaml"
    [ "$TMUX_AVAILABLE" = true ] && print_info "  $CONFIG_DIR/tmux.conf"

    print_info "\nFork data will be stored in:"
    print_info "  $FORK_YEAH_DIR"

    print_msg "$GREEN" "\nHappy forking! 🍴"
}

# Main installation flow
main() {
    print_msg "$BLUE" "
╔═══════════════════════════════════════════╗
║                                           ║
║           🍴  fork-yeah  🍴               ║
║   Claude Code Fork Management Plugin     ║
║                                           ║
╚═══════════════════════════════════════════╝
"

    # Detect OS
    OS=$(detect_os)
    print_info "Detected OS: $OS"

    # Check dependencies
    if ! check_dependencies; then
        print_error "\nPlease install missing dependencies and run setup again."
        exit 1
    fi

    # Handle tmux
    if [ "$TMUX_AVAILABLE" = false ]; then
        prompt_tmux_install
    fi

    # Setup
    setup_directories
    setup_config
    setup_scripts
    setup_claude_skill

    # Done!
    show_completion
}

# Run main
main "$@"
