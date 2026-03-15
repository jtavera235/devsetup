#!/usr/bin/env bash

set -euo pipefail

echo "==================================="
echo "Starting machine bootstrap"
echo "Date: $(date)"
echo "==================================="

#####################################
# Detect shell config
#####################################

if [[ -n "${ZSH_VERSION:-}" ]] || [[ "$SHELL" == *"zsh"* ]]; then
    SHELL_RC="$HOME/.zshrc"
else
    SHELL_RC="$HOME/.bashrc"
fi

echo "Using shell config: $SHELL_RC"

#####################################
# Install Homebrew
#####################################

if ! command -v brew &>/dev/null; then
    echo "Installing Homebrew..."

    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

    if [[ -d /opt/homebrew ]]; then
        eval "$(/opt/homebrew/bin/brew shellenv)"
    else
        eval "$(/usr/local/bin/brew shellenv)"
    fi
else
    echo "Homebrew already installed"
fi

brew update

#####################################
# Install Rust
#####################################
if command -v rustc &>/dev/null; then
    echo "Rust already installed: $(rustc --version)"
else
    echo "Installing Rust..."
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
fi

#####################################
# Install Go
#####################################

if ! command -v go &>/dev/null; then
    echo "Installing Go..."
    brew install go
else
    echo "Go already installed"
fi

#####################################
# Install Rust
#####################################

echo "Checking Rust installation..."

if command -v rustc >/dev/null 2>&1; then
    echo "Rust already installed: $(rustc --version)"
else
    echo "Installing Rust via rustup..."

    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs -o rustup-init.sh
    sh rustup-init.sh -y --no-modify-path

    # Load cargo environment so rustc works immediately
    if [ -f "$HOME/.cargo/env" ]; then
        source "$HOME/.cargo/env"
    fi

    rm rustup-init.sh
fi


#####################################
# Install Docker Desktop
#####################################
echo "Verifying Docker Installation"

if ! command -v docker &>/dev/null; then
    echo "Installing Docker Desktop..."
    brew install --cask docker
else
    echo "Docker already installed"
fi


#####################################
# Create SSH key
#####################################

SSH_KEY="$HOME/.ssh/id_ed25519"

if [[ ! -f "$SSH_KEY" ]]; then
    echo "Creating SSH key..."
    ssh-keygen -t ed25519 -C "<email>" -f "$SSH_KEY" -N ""
else
    echo "SSH key already generated"
fi

#####################################
# Install Claude Code CLI
#####################################

if command -v claude &>/dev/null; then
    echo "Claude CLI already installed: $(claude --version)"
else
    echo "Installing Claude CLI..."
    curl -fsSL https://claude.ai/install.sh | bash

    # Ensure path is loaded
    echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.zshrc && source ~/.zshrc
    echo "Claude installed: $(claude --version)"
fi

#####################################
# Installation verification
#####################################

echo ""
echo "==================================="
echo "Verifying installations"
echo "==================================="

verify() {
    local name=$1
    local cmd=$2

    if output=$($cmd 2>&1); then
        echo "✔ $name installed: $output"
    else
        echo "✘ $name installation failed"
        exit 1
    fi
}

verify "Claude CLI" "claude --version"
verify "Go" "go version"
verify "Rust" "rustc --version"
echo ""
echo "==================================="
echo "Bootstrap complete!"
echo ""
echo "Reload your shell:"
echo ""
echo "Add SSH key to GitHub:"
echo "pbcopy < ~/.ssh/id_ed25519.pub"
echo "==================================="
