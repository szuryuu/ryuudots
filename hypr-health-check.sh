#!/bin/bash

# Hyprland Health Check Script
# Comprehensive system check for Hyprland setup

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Symbols
CHECK="✓"
CROSS="✗"
WARN="⚠"
INFO="ℹ"

# Counters
PASS=0
FAIL=0
WARN_COUNT=0

print_header() {
  echo -e "${BLUE}╔════════════════════════════════════════════════════════════════╗${NC}"
  echo -e "${BLUE}║${NC}                   ${CYAN}HYPRLAND HEALTH CHECK${NC}                    ${BLUE}║${NC}"
  echo -e "${BLUE}╚════════════════════════════════════════════════════════════════╝${NC}"
  echo
}

print_section() {
  echo -e "\n${PURPLE}=== $1 ===${NC}"
}

check_status() {
  local name="$1"
  local status="$2"
  local extra_info="$3"

  printf "%-25s " "$name:"
  if [ "$status" = "pass" ]; then
    echo -e "${GREEN}$CHECK Running${NC} $extra_info"
    ((PASS++))
  elif [ "$status" = "fail" ]; then
    echo -e "${RED}$CROSS Not Running${NC} $extra_info"
    ((FAIL++))
  elif [ "$status" = "warn" ]; then
    echo -e "${YELLOW}$WARN Warning${NC} $extra_info"
    ((WARN_COUNT++))
  else
    echo -e "${CYAN}$INFO $status${NC} $extra_info"
  fi
}

check_command() {
  local name="$1"
  local cmd="$2"

  if command -v "$cmd" &>/dev/null; then
    local version=$(${cmd} --version 2>/dev/null | head -1 | cut -d' ' -f2-3 2>/dev/null || echo "")
    check_status "$name" "pass" "($version)"
  else
    check_status "$name" "fail" "(not installed)"
  fi
}

check_process() {
  local name="$1"
  local process="$2"

  if pgrep -x "$process" >/dev/null 2>&1; then
    local pid=$(pgrep -x "$process" | head -1)
    check_status "$name" "pass" "(PID: $pid)"
  else
    check_status "$name" "fail"
  fi
}

check_service() {
  local name="$1"
  local service="$2"

  if systemctl --user is-active --quiet "$service" 2>/dev/null; then
    check_status "$name" "pass"
  else
    check_status "$name" "fail"
  fi
}

check_file() {
  local name="$1"
  local file="$2"

  if [ -f "$file" ]; then
    check_status "$name" "pass"
  elif [ -d "$file" ]; then
    check_status "$name" "pass" "(directory)"
  else
    check_status "$name" "fail" "(not found)"
  fi
}

check_hyprland_specific() {
  local name="$1"
  local cmd="$2"

  if command -v hyprctl &>/dev/null && hyprctl version &>/dev/null; then
    local result=$(eval "$cmd" 2>/dev/null)
    if [ -n "$result" ]; then
      check_status "$name" "pass" "($result)"
    else
      check_status "$name" "warn" "(no output)"
    fi
  else
    check_status "$name" "fail" "(hyprctl not available)"
  fi
}

# Main checks
print_header

# Core System
print_section "CORE SYSTEM"
check_command "yay (AUR Helper)" "yay"
check_process "Hyprland" "Hyprland"
if command -v hyprctl &>/dev/null && hyprctl version &>/dev/null; then
  version=$(hyprctl version | head -1 | cut -d' ' -f2)
  check_status "Hyprland Version" "pass" "($version)"
else
  check_status "Hyprland Version" "fail"
fi

# Display & Compositor
print_section "DISPLAY & COMPOSITOR"
check_hyprland_specific "Monitors" "hyprctl monitors | grep -c 'Monitor'"
check_hyprland_specific "Workspaces" "hyprctl workspaces | grep -c 'workspace'"
check_command "XDG Portal" "xdg-desktop-portal"
check_process "XDG Portal Hyprland" "xdg-desktop-portal-hyprland"

# Audio System
print_section "AUDIO SYSTEM"
check_service "PipeWire" "pipewire"
check_service "PipeWire Pulse" "pipewire-pulse"
check_service "WirePlumber" "wireplumber"
check_command "PulseAudio Control" "pactl"
if command -v pactl &>/dev/null; then
  default_sink=$(pactl get-default-sink 2>/dev/null)
  if [ -n "$default_sink" ]; then
    check_status "Default Audio Sink" "pass" "($default_sink)"
  else
    check_status "Default Audio Sink" "warn" "(not set)"
  fi
fi

# UI Components
print_section "UI COMPONENTS"
check_process "Waybar" "waybar"
check_process "Mako" "mako"
check_process "Polkit GNOME" "polkit-gnome-authentication-agent-1"
check_command "Fuzzel" "fuzzel"
check_command "Wlogout" "wlogout"

# Wallpaper & Theming
print_section "WALLPAPER & THEMING"
check_process "SWWW Daemon" "swww-daemon"
if command -v swww &>/dev/null && pgrep -x "swww-daemon" >/dev/null; then
  current_wallpaper=$(swww query 2>/dev/null | head -1 | cut -d':' -f2 | xargs)
  if [ -n "$current_wallpaper" ]; then
    check_status "Current Wallpaper" "pass" "($(basename "$current_wallpaper"))"
  else
    check_status "Current Wallpaper" "warn" "(none set)"
  fi
else
  check_status "Current Wallpaper" "fail" "(swww not running)"
fi

# System Tools
print_section "SYSTEM TOOLS"
check_command "Brightness Control" "brightnessctl"
check_command "Player Control" "playerctl"
check_command "Hyprpicker" "hyprpicker"
check_command "Hyprlock" "hyprlock"
check_process "Hypridle" "hypridle"

# Screenshots & Clipboard
print_section "SCREENSHOTS & CLIPBOARD"
check_command "Grim" "grim"
check_command "Slurp" "slurp"
check_command "Swappy" "swappy"
check_command "Clipboard History" "cliphist"
check_process "Clipboard Manager" "wl-paste"

# File Management
print_section "FILE MANAGEMENT"
check_command "Nautilus" "nautilus"
check_process "Udiskie" "udiskie"
check_command "GVfs MTP" "gio"

# Applications
print_section "APPLICATIONS"
check_command "Kitty Terminal" "kitty"
check_command "Firefox" "firefox"
check_command "Nano Editor" "nano"

# Theming Tools
print_section "THEMING TOOLS"
check_command "nwg-look (GTK)" "nwg-look"
check_command "qt5ct" "qt5ct"
check_command "qt6ct" "qt6ct"
check_command "Kvantum" "kvantummanager"

# Font Check
print_section "FONTS"
if command -v fc-list &>/dev/null; then
  fira_count=$(fc-list | grep -i "fira" | wc -l)
  hack_count=$(fc-list | grep -i "hack" | wc -l)
  noto_count=$(fc-list | grep -i "noto" | wc -l)

  check_status "Fira Fonts" $([ $fira_count -gt 0 ] && echo "pass" || echo "warn") "($fira_count found)"
  check_status "Hack Nerd Fonts" $([ $hack_count -gt 0 ] && echo "pass" || echo "warn") "($hack_count found)"
  check_status "Noto Fonts" $([ $noto_count -gt 0 ] && echo "pass" || echo "warn") "($noto_count found)"
else
  check_status "Font Check" "fail" "(fc-list not available)"
fi

# Configuration Files
print_section "CONFIGURATION FILES"
check_file "Hyprland Config" "$HOME/.config/hypr/hyprland.conf"
check_file "Waybar Config" "$HOME/.config/waybar/config"
check_file "Mako Config" "$HOME/.config/mako/config"
check_file "Kitty Config" "$HOME/.config/kitty/kitty.conf"
check_file "Fuzzel Config" "$HOME/.config/fuzzel/fuzzel.ini"

# Assets
print_section "ASSETS"
check_file "Hyprdots Assets" "$HOME/.local/share/hyprdots"
check_file "Config Assets" "$HOME/.config/assets"

# Wayland Environment
print_section "WAYLAND ENVIRONMENT"
check_status "WAYLAND_DISPLAY" $([ -n "$WAYLAND_DISPLAY" ] && echo "pass" || echo "fail") "($WAYLAND_DISPLAY)"
check_status "XDG_CURRENT_DESKTOP" $([ "$XDG_CURRENT_DESKTOP" = "Hyprland" ] && echo "pass" || echo "warn") "($XDG_CURRENT_DESKTOP)"
check_status "XDG_SESSION_TYPE" $([ "$XDG_SESSION_TYPE" = "wayland" ] && echo "pass" || echo "warn") "($XDG_SESSION_TYPE)"

# Qt/GTK Wayland Support
print_section "WAYLAND SUPPORT"
check_command "Qt5 Wayland" "qt5-wayland"
check_command "Qt6 Wayland" "qt6-wayland"
check_status "QT_QPA_PLATFORM" $([ "$QT_QPA_PLATFORM" = "wayland" ] && echo "pass" || echo "warn") "($QT_QPA_PLATFORM)"

# Summary
print_section "SUMMARY"
total=$((PASS + FAIL + WARN_COUNT))
echo -e "Total Checks: ${CYAN}$total${NC}"
echo -e "Passed: ${GREEN}$PASS${NC}"
echo -e "Failed: ${RED}$FAIL${NC}"
echo -e "Warnings: ${YELLOW}$WARN_COUNT${NC}"

echo
if [ $FAIL -eq 0 ]; then
  if [ $WARN_COUNT -eq 0 ]; then
    echo -e "${GREEN}🎉 Perfect! All systems are running smoothly!${NC}"
  else
    echo -e "${YELLOW}⚠ System is mostly healthy but has some warnings to review.${NC}"
  fi
else
  echo -e "${RED}❌ Some components are not working. Please check the failed items above.${NC}"
fi

# Quick fixes suggestions
if [ $FAIL -gt 0 ] || [ $WARN_COUNT -gt 0 ]; then
  echo
  print_section "QUICK FIXES"
  echo -e "${CYAN}Common fixes:${NC}"
  echo "• Restart services: systemctl --user restart pipewire pipewire-pulse wireplumber"
  echo "• Restart Waybar: pkill waybar && waybar &"
  echo "• Start SWWW: swww init"
  echo "• Restart Mako: pkill mako && mako &"
  echo "• Check logs: journalctl --user -xe"
fi

echo
echo -e "${BLUE}Health check completed at $(date)${NC}"
