#!/usr/bin/env bash

# User setup script to properly create symbolic links and start systemd services when cloning the Scripts and dots repository onto the same system.
#

# Detect OS from /etc/os-release
if [[ -f /etc/os-release ]]; then
    . /etc/os-release 
    DISTRO_NAME="$NAME"
    DISTRO_ID="$ID"
    echo "Detected OS: $DISTRO_NAME ($DISTRO_ID)"
else
    echo "Cannot detect OS version. /etc/os-release not found"
    DISTRO_NAME="unknown"
    DISTRO_ID="unknown"
fi
  
#####################
### Update System ###
#####################
echo "It is reccomended that the system is fully up to date when running this script. Check for updates now?"
select strictreply in "Yes" "No"; do
    relaxedreply=${strictreply:-$REPLY}
    case $relaxedreply in
	Yes | YES | yes | Y | y )  ; break ;;
	case $DISTRO_ID in
	    debian|ubuntu|mint)
		echo "Updating APT packages..."
		sudo apt update
		sudo apt upgrade -y
	No | NO | no | n ) echo "skipping system update..." ; break ;;
	* ) echo "Please answer yes or no.";;
    esac
done
clear
    # Determine which package manager(s) is installed
    APT_CMD=$(which apt)
    DNF_CMD=$(which dnf)
    RPM_OSTREE_CMD=$(which rpm-ostree)
    YUM_CMD=$(command -v yum)
    PACMAN_CMD=$(command -v pacman)
    YAY_CMD=$(command -v yay)
    FLATPAK_CMD=$(which flatpak)

read -p "Woud you like to (re)install the packages required for dotfiles configurations?" -n 1 -r
if [[ $REPLY =~ ^[Yy]$ ]] 
then 
    # Determine which package manager(s) is installed
    APT_CMD=$(which apt)
    DNF_CMD=$(which dnf)
    RPM_OSTREE_CMD=$(which rpm-ostree)
    YUM_CMD=$(which yum)
    PACMAN_CMD=$(which pacman)
    YAY_CMD=$(which yay)
    FLATPAK_CMD=$(which flatpak)
    PIP_CMD=$(which pip)
    
#######################

#################################################
### Setup 3rd Party Repositories if necessary ###
#################################################

# If on Fedora enable Fedora COPRs
sudo dnf copr enable erikreider/SwayNotificationCenter
sudo dnf copr enable sdegler/hyprland
sudo dnf copr enable yalter/niri

# If on Ubuntu enable Ubuntu PPAs 

############################
### Install Dependencies ###
############################

    # Variables to install the neccesary packages in each supported package manager.
    dnf_packages=$(hyprland hyprpaper hyprlock sway swaync waybar waypaper wlogout kitty rofi-wayland emacs tealdeer)
    flatpak_packages=$(be.alexandervanhee.gradia com.belmoussaoui.Authenticator com.github.tchx84.Flatseal io.github.flattool.Warehouse)
    # use one of the following package managers in a custom preference order to install packages and update the system.
    if [[ ! -z $DNF_CMD ]]; then
	sudo dnf upgrade
	sudo dnf install "${dnf_packages[@]}"
    elif [[ ! -z $RPM_OSTREE_CMD ]]; then
	rpm-ostree upgrade
	rpm-ostree install "${rpm-ostree_packages[@]}"
    elif [[ ! -z $APT_CMD ]]; then
	sudo apt upgrade
	sudo apt install $apt_packages
    else
	echo "Could not find a supported package manager..."
    fi
fi

###########################################
### Clone the required git repositories ###
###########################################
#
## dotfiles repo
echo "Install preconfigured dotfiles?"
select strictreply in "Yes" "No"; do
    relaxedreply=${strictreply:-$REPLY}
    case $relaxedreply in
	Yes | YES | yes | Y | y ) 
	    git clone git@github.com:SeizeOP/dots.git ~/dotfiles/ ; break ;;
	No | NO | no | n ) echo "skipping download of preconfigured dotfiles..." ; break ;;
	* ) echo "Please answer yes or no.";;
    esac
done
clear

#
## scripts repo
echo "Woud you like to the install additional shell scripts to add system functionality?"
echo ""
echo "NOTE: Required for some Wlogout functionality, and launch scripts."
select strictreply in "Yes" "No"; do
    relaxedreply=${strictreply:-$REPLY}
    case $relaxedreply in
	Yes | YES | yes | Y | y ) 
	    git clone git@github.com:SeizeOP/scripts.git ~/scripts/ ; break ;;
	No | NO | no | n ) echo "skipping download of scripts repo..." ; break ;;
	* ) echo "Please answer yes or no.";;
    esac
done
clear

###########################################

##################################
## Create the required symlinks ## 
##################################
#
## dotfiles repo [subdirectory] -> ~/.config/[subdirectory]
echo "Generate symlinks from ~/dotfiles/[subdir] -> ~/.config/[subdir]?" 
echo ""
echo "NOTE: This WILL overwrite existing files under ~/.config/[subdir]. Make backups if necessary before running."
echo "NOTE: Some system configurations may not function properly if not symlinked either manually or via this script."
select strictreply in "Yes" "No"; do
    relaxedreply=${strictreply:-$REPLY}
    case $relaxedreply in
	Yes | YES | yes | Y | y ) 
	    ln -snf ~/dotfiles/emacs/ ~/.config/emacs 
	    ln -snf ~/dotfiles/niri/ ~/.config/niri 
	    ln -snf ~/dotfiles/nwg-wrapper/ ~/.config/nwg-wrapper 
	    ln -snf ~/dotfiles/rofi/ ~/.config/rofi 
	    ln -snf ~/dotfiles/sway-dracula/ ~/.config/sway
	    ln -snf ~/dotfiles/waybar-dracula/ ~/dotfiles/waybar
	    ln -snf ~/dotfiles/waybar/ ~/.config/waybar
	    ln -snf ~/dotfiles/wlogout/ ~/.config/wlogout
	    break ;;
	No | NO | no | n ) echo "Skipping symlink creation..." ; break ;;
	* ) echo "Please answer yes or no.";;
    esac
done
clear

####################################
### Create custom .desktop files ###
####################################
echo "Generate custom desktop files for Emacs and Overrides-gui?"
select strictreply in "Yes" "No"; do
    relaxedreply=${strictreply:-$REPLY}
    case $relaxedreply in
	Yes | YES | yes | Y | y )
	    # Overrides GUI Desktop entry
	    cat > ~/.local/share/applications/emacs.desktop <<EOF
[Desktop Entry]
Categories=Development;TextEditor;
Comment=Edit text
Exec=emacsclient -ca "" %F
GenericName=Text Editor
Icon=~/dotfiles/emacs/images/emacs-desktop.png
MimeType=text/english;text/plain;text/x-makefile;text/x-c++hdr;text/x-c++src;text/x-chdr;text/x-csrc;text/x-java;text/x-moc;text/x-pascal;text/x-tcl;text/x-tex;application/x-shellscript;text/x-c;text/x-c++;
Name=HDmacs
StartupNotify=true
StartupWMClass=Emacs
Terminal=false
Type=Application
EOF
	    # Overrides GUI Desktop entry
	    cat > ~/.local/share/applications/overrides-gui.desktop <<EOF
[Desktop Entry]
Name=Overrides GUI
Comment=Simple GUI for system toggles and themeng
Exec=/home/user/.local/bin/overrides-gui
Icon=face-cool
Type=Application
Terminal=false
EOF
	break ;;
	No | NO | no | N | n ) echo "Skipping Desktop File Creation."; break;;
	* ) echo "Please answer yes or no.";;
    esac
done
clear
###########################

###########################
### Start Custom Waybar ###
###########################
echo "Launch Waybar with custom configurations now?"
select strictreply in "Yes" "No"; do
    relaxedreply=${strictreply:-$REPLY}
    case $relaxedreply in
	Yes | YES | yes | Y | y )
	    if pgrep -x "Hyprland" > /dev/null; then
		waybar -c ~/dotfiles/waybar/config.jsonc -s ~/.config/waybar/style.css & disown
	    elif pgrep -x "niri" > /dev/null; then
		waybar -c ~/dotfiles/niri-waybar/config.jsonc -s ~/dotfiles/niri-waybar/style.css & disown
	    elif pgrep -x "sway" > /dev/null; then
		waybar -c ~/dotfiles/swaybar-dracula/config.jsonc -s ~/dotfiles/swaybar-dracula/style.css & disown
	    else 
		waybar & disown 
		 echo "Custom Waybar configuration not loaded for user."
	    fi; break;;
	No | NO | no | N | n ) echo "Skipping Waybar Configuration laoding."; break;;
	* ) echo "Please answer yes or no.";;
    esac
done
clear
###########################
