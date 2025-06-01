install_enlightenment_debian() {
    # Update system
    echo -e "\033[1;34m[1/7] Updating system packages...\033[0m"
    sudo apt update && sudo apt upgrade -y

    # Install Enlightenment with explicit session dependencies
    echo -e "\033[1;34m[2/7] Installing Enlightenment with dependencies...\033[0m"
    sudo apt install -y \
        enlightenment \
        enlightenment-data \
        enlightenment-common \
        terminology \
        dbus-x11 \  # Critical for X11 session management
        xserver-xorg-core \
        xserver-xorg \
        lightdm \
        lightdm-gtk-greeter

    # Install core components
    echo -e "\033[1;34m[3/7] Installing core components...\033[0m"
    sudo apt install -y \
        econnman \
        pcmanfm \
        network-manager \
        network-manager-gnome \
        plymouth \
        plymouth-themes

    # Create proper Enlightenment session file
    echo -e "\033[1;34m[4/7] Configuring Enlightenment session...\033[0m"
    sudo mkdir -p /usr/share/xsessions
    cat <<EOF | sudo tee /usr/share/xsessions/enlightenment.desktop >/dev/null
[Desktop Entry]
Name=Enlightenment
Comment=Enlightenment Desktop Environment
Exec=/usr/bin/enlightenment_start
Type=Application
DesktopNames=Enlightenment
EOF

    # Configure LightDM
    echo -e "\033[1;34m[5/7] Configuring LightDM...\033[0m"
    sudo systemctl enable lightdm
    sudo mkdir -p /etc/lightdm/lightdm.conf.d
    cat <<EOF | sudo tee /etc/lightdm/lightdm.conf.d/50-enlightenment.conf >/dev/null
[Seat:*]
greeter-session=lightdm-gtk-greeter
user-session=enlightenment
autologin-user=$USER
EOF

    # Configure environment variables
    echo -e "\033[1;34m[6/7] Setting environment variables...\033[0m"
    echo "export XDG_CURRENT_DESKTOP=Enlightenment" | sudo tee /etc/profile.d/enlightenment.sh >/dev/null

    # Configure Plymouth
    echo -e "\033[1;34m[7/7] Configuring Plymouth...\033[0m"
    sudo plymouth-set-default-theme -R spinner

    echo -e "\n\033[1;32mInstallation complete! Testing Enlightenment session...\033[0m"
    echo -e "Trying to start Enlightenment without reboot first...\n"
    
    # Test session without reboot
    if startx /usr/bin/enlightenment_start -- :0; then
        echo -e "\033[1;32mEnlightenment started successfully! You can now reboot.\033[0m"
    else
        echo -e "\033[1;31mEnlightenment failed to start. Checking logs...\033[0m"
        journalctl -xe --no-pager | grep -i enlightenment
        echo -e "\nCheck ~/.xsession-errors for more details"
    fi
}
