#!/bin/bash

# Minimal Debian Desktop Environment Installer with GUI Package Managers
# Installs core DE components + native GUI package manager for each environment

# Check root
if [ "$(id -u)" -ne 0 ]; then
    echo "Please run as root."
    exit 1
fi

# Install dialog if missing
if ! command -v dialog &> /dev/null; then
    apt update
    apt install -y dialog
fi

# Update package lists
apt update

install_minimal_de() {
    local de_name="$1"
    shift
    local core_packages=("$@")
    shift ${#core_packages[@]}
    local package_manager=("$@")
    
    dialog --infobox "Installing minimal $de_name with ${package_manager[0]}..." 3 70
    apt install -y --no-install-recommends "${core_packages[@]}" "${package_manager[@]}" > /dev/null 2>&1
    
    # Common essentials for all DEs
    local common_packages=(
        network-manager-gnome
        policykit-1-gnome
        pulseaudio
        xdg-utils
        xdg-user-dirs
        fonts-noto
        firmware-linux-nonfree
        lightdm
    )
    apt install -y --no-install-recommends "${common_packages[@]}" > /dev/null 2>&1
    
    dialog --msgbox "Minimal $de_name installed with:\n- Core desktop\n- ${package_manager[0]}\n- Network manager\n- Display settings" 8 70
}

install_budgie_debian() {
    # Update the system
    sudo apt update && sudo apt upgrade -y

    # Install Budgie Desktop and core components
    sudo apt install -y \
        budgie-desktop-environment \
        budgie-indicator-applet \
        budgie-core \
        lightdm \
        network-manager-gnome \
        gnome-software \
        gnome-terminal \
        nautilus \
        plymouth \
        plymouth-themes

    # Configure LightDM as display manager
    sudo systemctl enable lightdm

    # Install additional recommended packages
    sudo apt install -y \
        gnome-disk-utility \
        gnome-system-monitor \
        gnome-control-center \
        gnome-screenshot \
        gedit \
        eog \
        evince \
        pulseaudio \
        pavucontrol

    # Install and enable NetworkManager
    sudo apt install -y network-manager
    sudo systemctl enable NetworkManager
    sudo systemctl start NetworkManager

    # Configure Budgie session
    if [ ! -f /usr/share/xsessions/budgie-desktop.desktop ]; then
        cat <<EOF | sudo tee /usr/share/xsessions/budgie-desktop.desktop >/dev/null
[Desktop Entry]
Name=Budgie Desktop
Comment=Budgie Desktop Environment
Exec=budgie-desktop
TryExec=budgie-desktop
Type=Application
EOF
    fi

    # Set Budgie as default session for lightdm
    sudo sed -i '/^\[Seat:\*\]/a user-session=budgie-desktop' /etc/lightdm/lightdm.conf

    # Configure Plymouth (boot splash)
    sudo plymouth-set-default-theme -R spinner

    # Clean up
    sudo apt autoremove -y

    echo "Budgie Desktop Environment installation complete!"
    echo "The system will now reboot to start Budgie."
    
    # Reboot the system
    sudo reboot
}

install_gnome_debian() {
    # Update the system
    echo "Updating system packages..."
    sudo apt update && sudo apt upgrade -y

    # Install GNOME Desktop (full installation)
    echo "Installing GNOME Desktop Environment..."
    sudo apt install -y \
        task-gnome-desktop \
        gnome-shell \
        gnome-session \
        gnome-terminal \
        gnome-tweaks \
        gnome-software \
        gnome-control-center \
        gnome-backgrounds \
        gdm3 \
        network-manager-gnome \
        nautilus \
        eog \
        evince \
        gedit \
        plymouth \
        plymouth-themes

    # Install additional recommended GNOME applications
    echo "Installing additional GNOME applications..."
    sudo apt install -y \
        gnome-system-monitor \
        gnome-disk-utility \
        gnome-screenshot \
        gnome-calculator \
        gnome-characters \
        gnome-clocks \
        gnome-font-viewer \
        gnome-logs \
        gnome-maps \
        gnome-weather \
        gnome-sound-recorder \
        sushi \
        seahorse \
        totem \
        cheese

    # Enable GDM3 display manager
    echo "Configuring GDM3 display manager..."
    sudo systemctl enable gdm3

    # Install and enable NetworkManager
    echo "Configuring NetworkManager..."
    sudo apt install -y network-manager
    sudo systemctl enable NetworkManager
    sudo systemctl start NetworkManager

    # Configure Plymouth (boot splash)
    echo "Configuring Plymouth boot splash..."
    sudo plymouth-set-default-theme -R spinner

    # Set GNOME as default session
    echo "Setting GNOME as default session..."
    sudo update-alternatives --set x-session-manager /usr/bin/gnome-session

    # Install GNOME extensions (optional)
    echo "Installing GNOME extension manager..."
    sudo apt install -y gnome-shell-extension-manager

    # Clean up
    echo "Cleaning up..."
    sudo apt autoremove -y

    echo ""
    echo "GNOME Desktop Environment installation complete!"
    echo "The system will now reboot to start GNOME."
    echo ""
    
    # Reboot the system
    sudo reboot
}

install_lxde_debian() {
    # Update the system
    echo "[1/6] Updating system packages..."
    sudo apt update && sudo apt upgrade -y

    # Install LXDE core components
    echo "[2/6] Installing LXDE desktop environment..."
    sudo apt install -y \
        lxde-core \
        lxappearance \
        lxinput \
        lxpanel \
        lxrandr \
        lxsession \
        lxtask \
        lightdm \
        network-manager-gnome \
        synaptic \
        plymouth \
        plymouth-themes

    # Install recommended additional applications
    echo "[3/6] Installing recommended applications..."
    sudo apt install -y \
        pcmanfm \
        lxterminal \
        gpicview \
        leafpad \
        xarchiver \
        gnome-disk-utility \
        gnome-system-monitor \
        pulseaudio \
        pavucontrol

    # Configure LightDM as display manager
    echo "[4/6] Configuring LightDM..."
    sudo systemctl enable lightdm
    sudo sed -i 's/^#autologin-user=.*/autologin-user='$USER'/' /etc/lightdm/lightdm.conf 2>/dev/null || \
        echo -e "[Seat:*]\nautologin-user=$USER" | sudo tee -a /etc/lightdm/lightdm.conf >/dev/null

    # Enable NetworkManager
    echo "[5/6] Configuring NetworkManager..."
    sudo systemctl enable NetworkManager
    sudo systemctl start NetworkManager

    # Configure Plymouth (boot splash)
    echo "[6/6] Configuring Plymouth..."
    sudo plymouth-set-default-theme -R spinner

    # Clean up
    sudo apt autoremove -y

    echo ""
    echo "LXDE installation complete!"
    echo "The system will now reboot to start LXDE."
    echo ""

    # Reboot the system
    sudo reboot
}

install_lxqt_debian() {
    # Update system
    echo "[1/6] Updating system packages..."
    sudo apt update && sudo apt upgrade -y

    # Install LXQt core components
    echo "[2/6] Installing LXQt desktop environment..."
    sudo apt install -y \
        lxqt-core \
        lxqt-config \
        lxqt-panel \
        lxqt-session \
        lxqt-qtplugin \
        pcmanfm-qt \
        qterminal \
        sddm \
        network-manager-qt \
        plasma-discover \
        plymouth \
        plymouth-themes

    # Install recommended applications
    echo "[3/6] Installing recommended applications..."
    sudo apt install -y \
        featherpad \
        qlipper \
        qps \
        lximage-qt \
        lxqt-archiver \
        pavucontrol-qt \
        kwrite \
        kde-spectacle \
        systemsettings

    # Configure SDDM as display manager
    echo "[4/6] Configuring SDDM..."
    sudo systemctl enable sddm

    # Enable NetworkManager
    echo "[5/6] Configuring NetworkManager..."
    sudo systemctl enable NetworkManager
    sudo systemctl start NetworkManager

    # Configure Plymouth (boot splash)
    echo "[6/6] Configuring Plymouth..."
    sudo plymouth-set-default-theme -R spinner

    # Clean up
    sudo apt autoremove -y

    echo ""
    echo "LXQt installation complete!"
    echo "The system will now reboot to start LXQt."
    echo ""

    # Reboot the system
    sudo reboot
}

install_enlightenment_debian() {
    # Update system
    echo -e "\033[1;34m[1/6] Updating system packages...\033[0m"
    sudo apt update && sudo apt upgrade -y

    # Install Enlightenment and core components
    echo -e "\033[1;34m[2/6] Installing Enlightenment desktop environment...\033[0m"
    sudo apt install -y \
        enlightenment \
        terminology \
        econnman \
        pcmanfm \
        evince \
        mousepad \
        gpicview \
        lxappearance \
        lightdm \
        plymouth \
        plymouth-themes

    # Install additional recommended packages
    echo -e "\033[1;34m[3/6] Installing recommended applications...\033[0m"
    sudo apt install -y \
        elementary-icon-theme \
        tango-icon-theme \
        xarchiver \
        galculator \
        parole \
        epiphany-browser \
        network-manager \
        network-manager-gnome

    # Configure LightDM as display manager
    echo -e "\033[1;34m[4/6] Configuring LightDM...\033[0m"
    sudo systemctl enable lightdm
    sudo sed -i 's/^#autologin-user=.*/autologin-user='$USER'/' /etc/lightdm/lightdm.conf 2>/dev/null || \
        echo -e "[Seat:*]\nautologin-user=$USER" | sudo tee -a /etc/lightdm/lightdm.conf >/dev/null

    # Configure Enlightenment as default session
    echo -e "\033[1;34m[5/6] Configuring Enlightenment session...\033[0m"
    sudo update-alternatives --set x-session-manager /usr/bin/enlightenment_start

    # Configure Plymouth (boot splash)
    echo -e "\033[1;34m[6/6] Configuring Plymouth...\033[0m"
    sudo plymouth-set-default-theme -R spinner

    # Clean up
    sudo apt autoremove -y

    echo -e "\n\033[1;32mEnlightenment installation complete!\033[0m"
    echo -e "The system will now reboot to start Enlightenment.\n"
    
    # Reboot the system
    sudo reboot
}


while true; do
    choice=$(dialog --clear --backtitle "Debian Minimal Desktop + Package Managers" \
        --title "Select Desktop Environment" \
        --menu "Choose with arrow keys, Enter to select:" \
        20 70 12 \
        1 "GNOME + GNOME Software" \
        2 "KDE Plasma + Discover" \
        3 "Xfce + Synaptic" \
        4 "LXQt + Muon" \
        5 "LXDE + GDebi" \
        6 "MATE + Software Boutique" \
        7 "Cinnamon + MintInstall" \
        8 "Budgie + GNOME Software" \
        9 "Enlightenment + AppCenter" \
        10 "Install Complete" \
        2>&1 >/dev/tty)

    case $choice in
        1) install_minimal_de "GNOME" \
            gnome-core gnome-shell-extensions nautilus gdm3 \
            gnome-software ;;
        
        2) install_minimal_de "KDE Plasma" \
            plasma-desktop dolphin plasma-nm kscreen sddm \
            discover ;;
        
        3) install_minimal_de "Xfce" \
            xfce4 xfce4-goodies thunar lightdm-gtk-greeter \
            synaptic gdebi ;;
        
        4) install_lxqt_debian ;;
        
        5) install_lxde_debian \
            gdebi ;;
        
        6) install_minimal_de "MATE" \
            mate-core caja mate-control-center lightdm-gtk-greeter \
            software-boutique ;;
        
        7) install_minimal_de "Cinnamon" \
            cinnamon-core nemo cinnamon-control-center lightdm-gtk-greeter \
            mintinstall ;;
        
        8) install_minimal_de "Budgie" \
            budgie-core nautilus lightdm-gtk-greeter \
            gnome-software ;;
        
        9) install_enlightenment_debian \
            appcenter ;;
        
        10)
            # Post-install configuration
            dialog --infobox "Finalizing installation..." 3 50
            
            # Set display manager
            if [ -f /usr/sbin/gdm3 ]; then
                systemctl enable gdm3
            elif [ -f /usr/sbin/sddm ]; then
                systemctl enable sddm
            else
                systemctl enable lightdm
            fi
            
            # Enable services
            systemctl set-default graphical.target
            systemctl enable NetworkManager
            systemctl start NetworkManager
            
            # Clean up
            apt autoremove -y
            apt clean
            
            dialog --msgbox "Installation complete!\n\nReboot to start your new desktop environment.\n\nEach DE includes its native package manager." 10 60
            clear
            exit 0
            ;;
        *)
            clear
            exit 1
            ;;
    esac
done
