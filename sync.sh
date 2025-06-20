#!/bin/bash

# Sync Configs Script
# Syncs edited configs from ~/.config back to hyprdots repository

set -e # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Helper functions
print_info() {
  echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
  echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
  echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
  echo -e "${RED}[ERROR]${NC} $1"
}

# Check if we're in hyprdots directory
if [[ ! -f "install.sh" ]] || [[ ! -d "hypr" ]]; then
  print_error "Please run this script from the hyprdots directory!"
  exit 1
fi

print_info "Starting config sync from ~/.config to hyprdots repository..."

# Configuration directories to sync
configs=(
  "hypr"
  "kitty"
  "waybar"
  "mako"
  "fuzzel"
  "wlogout"
  "cava"
  "spotify-player"
  "gtk-4.0"
)

# Sync each configuration
for config in "${configs[@]}"; do
  source_dir="$HOME/.config/$config/"
  dest_dir="./$config/"

  if [ -d "$source_dir" ]; then
    print_info "Syncing $config..."

    # Create destination directory if it doesn't exist
    mkdir -p "$dest_dir"

    # Sync with rsync
    if rsync -av --delete "$source_dir" "$dest_dir"; then
      print_success "✓ $config synced successfully"
    else
      print_error "✗ Failed to sync $config"
    fi
  else
    print_warning "⚠ $source_dir not found, skipping..."
  fi
done

print_success "Config sync completed!"
print_info "You can now commit changes"
#echo "  git add ."
#echo "  git commit -m 'Update configs with personal changes'"
#echo "  git push"
