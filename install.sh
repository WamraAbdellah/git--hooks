#!/bin/bash

# install-hooks.sh
# Script to install Git hooks from a central repository

set -e

# Configuration
HOOKS_REPO_URL="https://github.com/WamraAbdellah/git--hooks.git"
HOOKS_REPO_BRANCH="main"
TEMP_DIR="/tmp/git-hooks-$$"
HOOKS_DIR=".git/hooks"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

log() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1"
    exit 1
}

# Check if we're in a Git repository
if [ ! -d ".git" ]; then
    error "Not in a Git repository. Please run this script from the root of your Git project."
fi

# Check if git is available
if ! command -v git &> /dev/null; then
    error "Git is not installed or not in PATH"
fi

log "Installing Git hooks from: $HOOKS_REPO_URL"

# Create temporary directory
mkdir -p "$TEMP_DIR"
trap "rm -rf $TEMP_DIR" EXIT

# Clone the hooks repository
log "Cloning hooks repository..."
if ! git clone --depth 1 --branch "$HOOKS_REPO_BRANCH" "$HOOKS_REPO_URL" "$TEMP_DIR/hooks-repo" &>/dev/null; then
    error "Failed to clone hooks repository: $HOOKS_REPO_URL"
fi

# Check if hooks directory exists in the repo
HOOKS_SOURCE="$TEMP_DIR/hooks-repo/hooks"
if [ ! -d "$HOOKS_SOURCE" ]; then
    error "No 'hooks' directory found in the repository"
fi

# Create .git/hooks directory if it doesn't exist
mkdir -p "$HOOKS_DIR"

# Backup existing hooks
BACKUP_DIR=".git/hooks-backup-$(date +%Y%m%d-%H%M%S)"
if ls "$HOOKS_DIR"/* &>/dev/null; then
    log "Backing up existing hooks to: $BACKUP_DIR"
    mkdir -p "$BACKUP_DIR"
    cp -r "$HOOKS_DIR"/* "$BACKUP_DIR"/ 2>/dev/null || true
fi

# Install new hooks
log "Installing hooks..."
INSTALLED_COUNT=0

for hook_file in "$HOOKS_SOURCE"/*; do
    if [ -f "$hook_file" ]; then
        hook_name=$(basename "$hook_file")
        
        # Skip non-hook files (like README, etc.)
        if [[ ! "$hook_name" =~ ^(pre-commit|post-commit|pre-push|post-receive|pre-receive|update|post-update|pre-rebase|post-checkout|post-merge|pre-auto-gc|post-rewrite|commit-msg|prepare-commit-msg|applypatch-msg|pre-applypatch|post-applypatch)$ ]]; then
            warn "Skipping non-hook file: $hook_name"
            continue
        fi
        
        # Copy hook file
        cp "$hook_file" "$HOOKS_DIR/$hook_name"
        
        # Make executable
        chmod +x "$HOOKS_DIR/$hook_name"
        
        log "Installed: $hook_name"
        ((INSTALLED_COUNT++))
    fi
done

# Install configuration file if it exists
CONFIG_FILE="$TEMP_DIR/hooks-repo/hooks-config.sh"
if [ -f "$CONFIG_FILE" ]; then
    cp "$CONFIG_FILE" "$HOOKS_DIR/"
    log "Installed configuration file: hooks-config.sh"
fi

# Success message
if [ $INSTALLED_COUNT -gt 0 ]; then
    log "Successfully installed $INSTALLED_COUNT Git hook(s)"
    log "Hooks are now active for this repository"
else
    warn "No valid Git hooks found in the repository"
fi

# Show installed hooks
log "Installed hooks:"
ls -la "$HOOKS_DIR" | grep -E "^-.*x.*" | awk '{print "  - " $9}' || echo "  (none)"