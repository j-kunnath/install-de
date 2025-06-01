#!/bin/bash

# Ensure script is run as root
if [[ "$EUID" -ne 0 ]]; then
  echo "Please run this script as root (e.g., sudo $0)"
  exit 1
fi

# Check if whiptail is installed
if ! command -v whiptail >/dev/null 2>&1; then
  echo "Installing whiptail for menu interface..."
  apt update && apt install -y whiptail
fi

# Menu options
CHOICE=$(whiptail --title "Desktop Environment Installer" --menu "Choose a desktop environment to install:" 20 78 10 \
"1" "GNOME" \
"2" "KDE Plasma" \
"3" "XFCE" \
"4" "LXQt" \
"5" "LXDE" \
"6" "Cinnamon" \
"7" "MATE" \
"8" "Budgie" \
"9" "Enlightenment" \
"10" "i3 (Tiling WM)" \
"11" "Openbox" 3>&1 1>&2 2>&3)

# Cancelled
if [ $? -ne 0 ]; then
  echo "Installation cancelled."
  exit 1
fi

# Match choice to package
case $CHOICE in
  1) pkg="gnome gnome-session gnome-terminal nautilus network-manager-gnome gdm3 gnome-control-center gnome-tweaks gnome-shell-extensions" ;;
  2) pkg="kde-plasma-desktop dolphin konsole plasma-nm sddm" ;;
  3) pkg="xfce4 xfce4-terminal thunar network-manager-gnome lightdm xfce4-settings xfce4-appfinder" ;;
  4) pkg="lxqt lxqt qterminal pcmanfm-qt network-manager-gnome lightdm lxqt-policykit lxqt-config" ;;
  5) pkg="lxde lxde-core lxterminal pcmanfm network-manager-gnome lightdm" ;;
  6) pkg="cinnamon-desktop-environment cinnamon cinnamon-core nemo gnome-terminal network-manager-gnome lightdm cinnamon-control-center" ;;
  7) pkg="mate-desktop-environment mate-desktop-environment-core mate-terminal caja network-manager-gnome lightdm mate-control-center" ;;
  8) pkg="budgie-desktop budgie-desktop gnome-terminal nautilus network-manager-gnome lightdm" ;;
  9) pkg="enlightenment terminology pcmanfm network-manager-gnome lightdm" ;;
  10) pkg="i3 rofi xfce4-terminal thunar network-manager-gnome lightdm lxappearance clipit gvfs xdg-utils feh" ;;
  11) pkg="openbox lxappearance clipit gvfs xdg-utils feh tint2" ;;
  *) echo "Unknown selection"; exit 1 ;;
esac

echo "Updating package lists..."
apt update

echo "Installing $pkg and lightdm (display manager)..."
apt install -y $pkg lightdm
systemctl enable NetworkManager
systemctl enable lightdm
apt autoremove --purge
echo "Installation complete. Reboot to start the desktop environment."
