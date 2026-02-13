#!/usr/bin/env bash
# =============================================================================
# Scaffold Installer
# =============================================================================
# One-liner install:
#   curl -fsSL https://raw.githubusercontent.com/sakebomb/scaffold/main/install.sh | bash
#
# What it does:
#   1. Downloads scaffold CLI + templates to ~/.scaffold/
#   2. Creates a symlink in ~/.local/bin/scaffold (or /usr/local/bin if --global)
#   3. You can then run 'scaffold' from any directory
#
# Options:
#   SCAFFOLD_HOME=~/custom/path  Override install location (default: ~/.scaffold)
#   SCAFFOLD_BRANCH=feat/xyz     Install from a specific branch (default: main)
# =============================================================================
set -euo pipefail

# --- Configuration ---
REPO="sakebomb/scaffold"
BRANCH="${SCAFFOLD_BRANCH:-main}"
INSTALL_DIR="${SCAFFOLD_HOME:-$HOME/.scaffold}"
BIN_DIR="${HOME}/.local/bin"

# --- Colors ---
if [[ -t 1 ]]; then
  GREEN='\033[0;32m' RED='\033[0;31m' BOLD='\033[1m' DIM='\033[2m' RESET='\033[0m'
else
  GREEN='' RED='' BOLD='' DIM='' RESET=''
fi

info()    { echo -e "${DIM}$*${RESET}"; }
success() { echo -e "${GREEN}$*${RESET}"; }
error()   { echo -e "${RED}$*${RESET}" >&2; }

# --- Preflight ---
if ! command -v git &>/dev/null; then
  error "git is required but not installed."
  exit 1
fi

echo -e "${BOLD}Scaffold Installer${RESET}"
echo ""

# --- Download ---
if [[ -d "$INSTALL_DIR/.git" ]]; then
  info "Updating existing installation at $INSTALL_DIR..."
  (cd "$INSTALL_DIR" && git pull --ff-only origin "$BRANCH" 2>/dev/null) || {
    info "Pull failed — re-cloning..."
    rm -rf "$INSTALL_DIR"
    git clone --depth 1 --branch "$BRANCH" "https://github.com/$REPO.git" "$INSTALL_DIR"
  }
else
  if [[ -d "$INSTALL_DIR" ]]; then
    info "Removing existing non-git installation..."
    rm -rf "$INSTALL_DIR"
  fi
  info "Cloning scaffold to $INSTALL_DIR..."
  git clone --depth 1 --branch "$BRANCH" "https://github.com/$REPO.git" "$INSTALL_DIR"
fi

# --- Make executable ---
chmod +x "$INSTALL_DIR/scaffold"

# --- Symlink to PATH ---
mkdir -p "$BIN_DIR"

if [[ -L "$BIN_DIR/scaffold" || -f "$BIN_DIR/scaffold" ]]; then
  rm -f "$BIN_DIR/scaffold"
fi
ln -s "$INSTALL_DIR/scaffold" "$BIN_DIR/scaffold"

# --- Verify PATH ---
echo ""
if echo "$PATH" | tr ':' '\n' | grep -qF "$BIN_DIR"; then
  success "scaffold installed successfully!"
  info "  Location: $INSTALL_DIR"
  info "  Symlink:  $BIN_DIR/scaffold"
  info "  Version:  $(scaffold --version 2>/dev/null || echo 'unknown')"
else
  success "scaffold installed to $INSTALL_DIR"
  echo ""
  echo -e "${RED}Warning:${RESET} $BIN_DIR is not in your PATH."
  echo "Add this to your shell profile (~/.bashrc, ~/.zshrc, etc.):"
  echo ""
  echo "  export PATH=\"\$HOME/.local/bin:\$PATH\""
  echo ""
  echo "Then restart your shell or run: source ~/.bashrc"
fi

echo ""
info "Usage:"
info "  cd my-project && scaffold          # New project"
info "  cd existing-project && scaffold --migrate  # Add to existing"
info "  scaffold --help                    # See all options"
