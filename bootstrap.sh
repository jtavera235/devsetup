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
# Install packages from Brewfile
#####################################

echo "Installing Brewfile packages..."
brew bundle

#####################################
# Install Rust
#####################################

if ! command -v rustc &>/dev/null; then
    echo "Installing Rust..."
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
fi

#####################################
# Setup language environments
#####################################

echo "Configuring language environments..."

# ---------- Go ----------

if ! grep -q "GOPATH" "$SHELL_RC"; then
cat <<'EOF' >> "$SHELL_RC"

# Go environment
export GOPATH=$HOME/go
export PATH=$PATH:$GOPATH/bin
EOF
fi

# ---------- Rust ----------

if ! grep -q ".cargo/env" "$SHELL_RC"; then
cat <<'EOF' >> "$SHELL_RC"

# Rust environment
source "$HOME/.cargo/env"
EOF
fi

# ---------- Java ----------

if ! grep -q "JAVA_HOME" "$SHELL_RC"; then
cat <<'EOF' >> "$SHELL_RC"

# Java environment
export JAVA_HOME=$(/usr/libexec/java_home)
export PATH=$JAVA_HOME/bin:$PATH
EOF
fi

#####################################
# Create SSH key
#####################################

SSH_KEY="$HOME/.ssh/id_ed25519"

if [[ ! -f "$SSH_KEY" ]]; then
    echo "Creating SSH key..."
    ssh-keygen -t ed25519 -C "<email>" -f "$SSH_KEY" -N ""
fi

#####################################
# Language verification
#####################################

echo ""
echo "==================================="
echo "Verifying language installations"
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

verify "Go" "go version"
verify "Rust" "rustc --version"
verify "Java" "java -version"

echo ""
echo "==================================="
echo "Bootstrap complete!"
echo ""
echo "Reload your shell:"
echo "source $SHELL_RC"
echo ""
echo "Add SSH key to GitHub:"
echo "pbcopy < ~/.ssh/id_ed25519.pub"
echo "==================================="
