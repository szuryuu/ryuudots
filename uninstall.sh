#!/bin/bash

# Hyprdots Uninstall Script
# This script helps restore your previous configurations

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

# Define directories
DOTFILES_DIR="$(dirname "$(realpath "$0")")"
CONFIG_DIR="$HOME/.config"
BACKUP_DIR="$CONFIG_DIR/backup"
ASSETS_DIR="$HOME/.local/share/hyprdots"

print_info "Hyprdots Uninstall Script"
echo "=================================="

# Check if backup directory exists
if [ ! -d "$BACKUP_DIR" ]; then
  print_error "No backup directory found at $BACKUP_DIR"
  print_info "Cannot restore previous configurations."
  exit 1
fi

# Show available backups
print_info "Available backup directories:"
echo
backup_count=$(ls -1 "$BACKUP_DIR" 2>/dev/null | wc -l)

if [ "$backup_count" -eq 0 ]; then
  print_error "No backups found in $BACKUP_DIR"
  exit 1
fi

# List backups with numbers
counter=1
declare -a backup_list=()
for backup in $(ls -1t "$BACKUP_DIR"); do
  echo "  $counter) $backup"
  backup_list+=("$backup")
  ((counter++))
done

echo
echo "Options:"
echo "  r) Remove hyprdots configs (no restore)"
echo "  c) Cancel"
echo

# Get user choice
while true; do
  read -p "Enter your choice (number/r/c): " choice

  case $choice in
  [1-9]*)
    if [ "$choice" -le "${#backup_list[@]}" ] && [ "$choice" -ge 1 ]; then
      selected_backup="${backup_list[$((choice - 1))]}"
      break
    else
      print_error "Invalid number. Please choose between 1-${#backup_list[@]}"
    fi
    ;;
  r | R)
    selected_backup=""
    break
    ;;
  c | C)
    print_info "Uninstall cancelled."
    exit 0
    ;;
  *)
    print_error "Invalid choice. Please enter a number, 'r', or 'c'"
    ;;
  esac
done

# Configurations to remove
configs_to_remove=(
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

# Remove current hyprdots configurations
print_info "Removing current hyprdots configurations..."
for config in "${configs_to_remove[@]}"; do
  config_path="$CONFIG_DIR/$config"
  if [ -e "$config_path" ]; then
    print_info "Removing $config_path"
    rm -rf "$config_path"
  fi
done

# Remove assets
if [ -d "$ASSETS_DIR" ]; then
  print_info "Removing assets from $ASSETS_DIR"
  rm -rf "$ASSETS_DIR"
fi

# Remove GTK and Qt configs created by installer
print_info "Removing theme configurations..."
if [ -f "$HOME/.config/gtk-3.0/settings.ini" ]; then
  rm -f "$HOME/.config/gtk-3.0/settings.ini"
fi

if [ -f "$HOME/.config/qt5ct/qt5ct.conf" ]; then
  rm -f "$HOME/.config/qt5ct/qt5ct.conf"
fi

print_success "Hyprdots configurations removed successfully!"

# Restore from backup if selected
if [ -n "$selected_backup" ]; then
  print_info "Restoring from backup: $selected_backup"

  backup_path="$BACKUP_DIR/$selected_backup"

  if [ -d "$backup_path" ]; then
    # Restore configurations
    for item in "$backup_path"/*; do
      if [ -e "$item" ]; then
        item_name=$(basename "$item")
        dest_path="$CONFIG_DIR/$item_name"

        print_info "Restoring $item_name"
        cp -r "$item" "$dest_path"
      fi
    done

    print_success "Backup restored successfully!"
  else
    print_error "Backup directory not found: $backup_path"
    exit 1
  fi
else
  print_info "No backup restoration selected."
fi

echo
print_info "Uninstall completed!"
print_info "What you may want to do next:"
echo "1. Log out and back in, or reboot"
echo "2. Reconfigure your display manager if needed"
echo "3. Check your configurations in ~/.config/"

# Optional: Ask if user wants to remove packages
echo
read -p "Do you want to remove hyprdots-related packages? (y/N): " remove_packages

if [[ $remove_packages =~ ^[Yy]$ ]]; then
  print_info "Removing hyprdots packages..."
  print_warning "This will remove packages that might be used by other applications!"
  echo "Packages to remove:"
  echo "- hyprland hyprpaper hyprlock hypridle"
  echo "- waybar mako fuzzel wlogout"
  echo "- cava spotify-player"
  echo "- catppuccin themes and related packages"
  echo
  read -p "Are you sure you want to continue? (y/N): " confirm_remove

  if [[ $confirm_remove =~ ^[Yy]$ ]]; then
    # List of packages to remove (optional, user-specific)
    packages_to_remove=(
      "hyprland"
      "hyprpaper"
      "hyprlock"
      "hypridle"
      "waybar"
      "mako"
      "fuzzel"
      "wlogout"
      "cava"
      "spotify-player"
      "catppuccin-gtk-theme-mocha"
      "catppuccin-cursors-mocha"
      "swww"
    )

    print_info "Removing packages..."
    for package in "${packages_to_remove[@]}"; do
      if pacman -Q "$package" &>/dev/null; then
        print_info "Removing $package"
        yay -Rns --noconfirm "$package" 2>/dev/null || print_warning "Failed to remove $package"
      fi
    done

    print_success "Package removal completed!"
  else
    print_info "Package removal cancelled."
  fi
else
  print_info "Packages kept installed."
fi

echo
print_success "Hyprdots uninstall process completed!"
print_info "Thank you for trying hyprdots!"
