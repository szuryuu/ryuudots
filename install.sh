#!/bin/bash

# Hyprdots Installation Script
# Repository: https://github.com/jamlotrasoiaf/hyprdots.git

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
BACKUP_DIR="$CONFIG_DIR/backup/$(date +%Y%m%d_%H%M%S)"

print_info "Starting Hyprdots installation..."
print_info "Dotfiles directory: $DOTFILES_DIR"
print_info "Config directory: $CONFIG_DIR"
print_info "Backup directory: $BACKUP_DIR"

# Create necessary directories
mkdir -p "$CONFIG_DIR"
mkdir -p "$BACKUP_DIR"

# Check if running on Arch Linux
if ! grep -q "ID=arch" /etc/os-release 2>/dev/null; then
  print_warning "This script is designed for Arch Linux. Continuing anyway..."
fi

# Install yay if not present (Arch-specific)
if ! command -v yay &>/dev/null; then
  print_info "yay not found. Installing yay..."
  sudo pacman -S --needed git base-devel
  git clone https://aur.archlinux.org/yay.git /tmp/yay
  (cd /tmp/yay && makepkg -si --noconfirm)
  rm -rf /tmp/yay
  print_success "yay installed successfully"
else
  print_info "yay is already installed"
fi

# Install required packages
print_info "Installing required packages..."
yay -S --noconfirm \
  hyprland \
  hyprpaper \
  hyprlock \
  hypridle \
  xdg-desktop-portal-hyprland \
  kitty \
  waybar \
  mako \
  fuzzel \
  wlogout \
  cava \
  spotify-player \
  swww \
  grim slurp \
  brightnessctl \
  playerctl \
  cliphist \
  polkit-gnome \
  pipewire wireplumber \
  ttf-fira-code-nerd \
  ttf-jetbrains-mono-nerd \
  noto-fonts \
  noto-fonts-emoji \
  catppuccin-gtk-theme-mocha \
  catppuccin-cursors-mocha \
  qt5-wayland \
  qt6-wayland \
  nvidia \
  nvidia-utils \
  vulkan-tools \
  vulkan-icd-loader \
  vulkan-intel

print_success "Packages installed successfully"

# Configuration directories to process
declare -A configs=(
  ["hypr"]="$CONFIG_DIR/hypr"
  ["kitty"]="$CONFIG_DIR/kitty"
  ["waybar"]="$CONFIG_DIR/waybar"
  ["mako"]="$CONFIG_DIR/mako"
  ["fuzzel"]="$CONFIG_DIR/fuzzel"
  ["wlogout"]="$CONFIG_DIR/wlogout"
  ["cava"]="$CONFIG_DIR/cava"
  ["spotify-player"]="$CONFIG_DIR/spotify-player"
  ["gtk-4.0"]="$CONFIG_DIR/gtk-4.0"
)

# Backup and copy configuration files
print_info "Processing configuration files..."
for src in "${!configs[@]}"; do
  dest="${configs[$src]}"
  src_path="$DOTFILES_DIR/$src"

  if [ -d "$src_path" ] || [ -f "$src_path" ]; then
    print_info "Processing: $src"

    # Backup existing config if it exists
    if [ -e "$dest" ]; then
      backup_name="$(basename "$dest")"
      print_warning "Backing up existing $dest"
      mv "$dest" "$BACKUP_DIR/$backup_name"
    fi

    # Copy new config
    cp -r "$src_path" "$dest"
    print_success "Copied $src to $dest"
  else
    print_warning "Source $src_path not found. Skipping."
  fi
done

# Copy assets
print_info "Processing assets..."
ASSETS_DIR="$HOME/.local/share/hyprdots"
mkdir -p "$ASSETS_DIR"

if [ -d "$DOTFILES_DIR/assets" ]; then
  cp -r "$DOTFILES_DIR/assets"/* "$ASSETS_DIR/"
  print_success "Assets copied to $ASSETS_DIR"
fi

# Make scripts executable
print_info "Setting executable permissions for scripts..."
find "$CONFIG_DIR" -name "*.sh" -exec chmod +x {} \;
find "$CONFIG_DIR" -name "*.py" -exec chmod +x {} \;

# Special configurations
print_info "Applying special configurations..."

# GTK theme configuration
mkdir -p "$HOME/.config/gtk-3.0"
cat >"$HOME/.config/gtk-3.0/settings.ini" <<EOF
[Settings]
gtk-theme-name=Catppuccin-Mocha-Standard-Blue-Dark
gtk-icon-theme-name=Papirus-Dark
gtk-font-name=Noto Sans 11
gtk-cursor-theme-name=catppuccin-mocha-dark-cursors
gtk-cursor-theme-size=24
gtk-toolbar-style=GTK_TOOLBAR_BOTH
gtk-toolbar-icon-size=GTK_ICON_SIZE_LARGE_TOOLBAR
gtk-button-images=1
gtk-menu-images=1
gtk-enable-event-sounds=1
gtk-enable-input-feedback-sounds=1
gtk-xft-antialias=1
gtk-xft-hinting=1
gtk-xft-hintstyle=hintfull
EOF

# Qt theme configuration
mkdir -p "$HOME/.config/qt5ct"
cat >"$HOME/.config/qt5ct/qt5ct.conf" <<EOF
[Appearance]
color_scheme_path=/usr/share/qt5ct/colors/darker.conf
custom_palette=false
icon_theme=Papirus-Dark
standard_dialogs=default
style=kvantum-dark

[Fonts]
fixed=@Variant(\0\0\0@\0\0\0\x12\0J\0\x65\0t\0\x42\0r\0\x61\0i\0n\0s\0 \0M\0o\0n\0o@$\0\0\0\0\0\0\xff\xff\xff\xff\x5\x1\0\x32\x10)
general=@Variant(\0\0\0@\0\0\0\x12\0N\0o\0t\0o\0 \0S\0\x61\0n\0s@$\0\0\0\0\0\0\xff\xff\xff\xff\x5\x1\0\x32\x10)

[Interface]
activate_item_on_single_click=1
buttonbox_layout=0
cursor_flash_time=1000
dialog_buttons_have_icons=1
double_click_interval=400
gui_effects=@Invalid()
keyboard_scheme=2
menus_have_icons=true
show_shortcuts_in_context_menus=true
stylesheets=@Invalid()
toolbutton_style=4
underline_shortcut=1
wheel_scroll_lines=3

[SettingsWindow]
geometry=@ByteArray(\x1\xd9\xd0\xcb\0\x3\0\0\0\0\x2\x80\0\0\x1\x90\0\0\x5\x7f\0\0\x4\x37\0\0\x2\x80\0\0\x1\x90\0\0\x5\x7f\0\0\x4\x37\0\0\0\0\0\0\0\0\a\x80\0\0\x2\x80\0\0\x1\x90\0\0\x5\x7f\0\0\x4\x37)
EOF

# Enable services
print_info "Enabling services..."
systemctl --user enable --now pipewire pipewire-pulse wireplumber

# Final instructions
print_success "Installation completed successfully!"
echo
print_info "Final steps:"
echo "1. Log out and select Hyprland from your display manager"
echo "2. Or reboot your system"
echo "3. Your old configurations have been backed up to: $BACKUP_DIR"
echo
print_info "Optional post-installation steps:"
echo "- Run 'nwg-look' to configure GTK themes"
echo "- Run 'qt5ct' to configure Qt5 themes"
echo "- Check waybar and other configs in ~/.config/"
echo
print_warning "If you encounter any issues, check the backup directory for your old configs."

print_info "Installation script completed!"
print_info "You can create uninstall.sh separately if needed."
