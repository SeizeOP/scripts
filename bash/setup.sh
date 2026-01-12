#!/usr/bin/env bash

######################################################################################################### Author: SeizeOP (HD)
#	 _   _______ _      ______         _     _____          _        _ _   _____           _       _   	# Script Name: setup.sh	
#	| | | |  _  ( )     | ___ \       | |   |_   _|        | |      | | | /  ___|         (_)     | |  	# Description: Script to setup a system with my custom dotfile and scripts.
#	| |_| | | | |/ ___  | |_/ /__  ___| |_    | | _ __  ___| |_ __ _| | | \ `--.  ___ _ __ _ _ __ | |_ 	# Github: https://SeizeOP/scripts/bash/seup.sh
#	|  _  | | | | / __| |  __/ _ \/ __| __|   | || '_ \/ __| __/ _` | | |  `--. \/ __| '__| | '_ \| __|	# License: https://SeizeOP/scripts/LICENSE
#	| | | | |/ /  \__ \ | | | (_) \__ \ |_   _| || | | \__ \ || (_| | | | /\__/ / (__| |  | | |_) | |_ 	# Contributers: SeizeOP
#	\_| |_/___/   |___/ \_|  \___/|___/\__|  \___/_| |_|___/\__\__,_|_|_| \____/ \___|_|  |_| .__/ \__|	#
#                                                                                        	| |        	#
#                                                                                        	|_|        	#
# 																										#
#########################################################################################################

# Detect OS from /etc/os-release
if [[ -f /etc/os-release ]]; then
    . /etc/os-release 
    DISTRO_NAME="$NAME"
    DISTRO_ID="$ID"
    echo -e "Detected OS: $DISTRO_NAME ($DISTRO_ID)"
else
    echo -e "Cannot detect OS version. /etc/os-release not found"
    DISTRO_NAME="unknown"
    DISTRO_ID="unknown"
fi

# Warn user if script is run on an unsupported distrobution.
case $DISTRO_ID in
	unknown)
		echo -e "Cannot detect OS version. /etc/os-release not found"
		echo ""
		echo -e "This script supports ONLY distrobutions based on Fedora, Debian/Ubuntu, and Arch Linux." 
		echo "If you know that your system is based on one of these supported distrobutions you may proceed with running this script."
		echo "Otherwise, it is reccomended to exit the script now."
		echo ""
		echo -e "Continue to Run HD's post install script?"
		select strictreply in "Yes" "No"; do
			case $relaxedreply in
				Yes | YES | yes | Y | y )
					echo "Continuing to load script..." ; break ;;
				No | NO | no | n )
					echo "Exiting script..."
					kill -9 $(ps aux | grep '[s]etup.sh' | awk '{print $2}')
				esac
		done
esac

# Update System
echo -e "\e[1;31mIt is reccomended that the system is fully up to date when running this script.\e[0m Check for updates now?"
select strictreply in "Yes" "No"; do
    relaxedreply=${strictreply:-$REPLY}
    case $relaxedreply in
		Yes | YES | yes | Y | y )
			case $DISTRO_ID in
				arch|endeavoros|garuda|manjaro)
					echo -e "Updating Pacman packages..."
					sudo pacman -Syu ; break ;;
				bazzite|ublue)
					echo "Updating OSTree..."
					sudo rpm-ostree upgrade
					echo -e "\e[1;31mPlease reboot to apply any newly downloaded OSTree\e[0m" 
					echo "" ; break ;;
	    		debian|ubuntu|mint|zorin)
					echo -e "Updating APT packages..."
					sudo apt update
					sudo apt upgrade -y 
					echo "" ; break ;;
				fedora|redhat)
					echo -e "Updating RPM packages..." 
					sudo dnf upgrade --refresh -y 
					echo "" ; break ;;
				opensuse-leap)
					echo -e "Updating Zypper packages..."
					sudo zypper refresh -y
					sudo zypper update -y 
					echo "" ; break ;;
				opensuse-tumbleweed)
					echo -e "Updating Zypper packages..."
					sudo zypper refresh -y
					sudo zypper dist-upgrade -y 
					echo "" ; break;;
			esac
	esac
	case $relaxedreply in
		No | NO | no | n )
			echo "skipping system update..." ; break ;;
	esac
	case $relaxedreply in
		* ) 
			echo "Please answer yes or no."; break ;;
    esac
done
#    FLATPAK_CMD=$(which flatpak)

### Setup 3rd Party Repositories if necessary ###
echo "Some external repositories may be needed for proper installation of custom configurations." 
echo "Would you like to enable these repositories now?"
echo ""
echo -e "Selecting Yes to enabling 3rd party repositories will do \e[1;33mone\e[0m of the following:"
echo -e "\e[1;32m1.\e[0m Enable several COPRs on Fedora" 
echo -e "\e[1;32m2.\e[0m Install an AUR helper on Arch based systems" 
echo -e "\e[1;32m3.\e[0m Enable several PPAs on Ubuntu based systems"
echo ""
select strictreply in "Yes" "No"; do
    relaxedreply=${strictreply:-$REPLY}
    case $relaxedreply in
		Yes | YES | yes | Y | y )
		# If on Fedora, enable Fedora COPRs
			case $DISTRO_ID in
				fedora|redhat)
					sudo dnf copr enable erikreider/SwayNotificationCenter
					sudo dnf copr enable sdegler/hyprland
					sudo dnf copr enable yalter/niri
					break ;;
			esac
		# If on Arch, Install an AUR helper
			case $DISTRO_ID in
				arch|endeavoros|garuda|manjaro)		
					sudo pacman -Sy yay 		
					break ;;
			esac
		# If on Ubuntu enable Ubuntu PPAs
	esac
	case $relaxedreply in
		No | NO | no | n )  
			echo -e "skipping system update..."
			echo ; break ;;
	esac
	case $relaxedreply in
		* )  echo -e "Please answer yes or no.";;
	esac
done

############################
### Install Dependencies ###
############################
#
### List packages to be installed ###
apt_packages=(sway swaync waybar waypaper wlogout kitty rofi-wayland emacs tealdeer)
dnf_packages=(hyprland hyprpaper hyprlock sway niri swaync waybar waypaper wlogout kitty rofi-wayland emacs tealdeer)
arch_packages=(hyprland hyprpaper hyprlock sway niri)
suse_packages=(hyprland hyprpaper hyprlock sway niri)
#flatpak_packages=$(be.alexandervanhee.gradia com.belmoussaoui.Authenticator com.github.tchx84.Flatseal io.github.flattool.Warehouse)

echo "Woud you like to (re)install the packages required for dotfiles configurations?"
select strictreply in "Yes" "No"; do
	relaxedreply=${strictreply:-$REPLY}
    case $relaxedreply in
		Yes | YES | yes | Y | y )
			case $DISTRO_ID in
				arch|endeavoros|garuda|manjaro)
					sudo pacman -Sy $arch_packages
					echo "" ; break ;;
				debian|ubuntu|mint|zorin)
					sudo apt install $apt_packages -y
					echo "" ; break ;;
				fedora|redhat)
					sudo dnf install $dnf_packages -y
					echo "" ; break ;;
				opensuse|opensuse-tumbleweed|opensuse-leap)
					sudo zypper install $suse_packages
			esac
	esac
	case $relaxedreply in
		No | NO | no | n )  
			echo "skipping installation of dependencies..." 
			echo "" ; break ;;
	esac
done

###########################################
### Clone the required git repositories ###
###########################################
#
### dotfiles repo
echo "Install preconfigured dotfiles?"
select strictreply in "Yes" "No"; do
    relaxedreply=${strictreply:-$REPLY}
    case $relaxedreply in
		Yes | YES | yes | Y | y ) 
	    	git clone git@github.com:SeizeOP/dots.git ~/dotfiles/ ; break ;;
		No | NO | no | n )
			echo "skipping download of preconfigured dotfiles..." ; break ;;
		* )
			echo -e "Please answer yes or no.";;
    esac
done

### scripts repo
echo "Woud you like to the install additional shell scripts to add system functionality?"
echo ""
echo -e "NOTE: Required for some Wlogout functionality, and launch scripts."
select strictreply in "Yes" "No"; do
    relaxedreply=${strictreply:-$REPLY}
    case $relaxedreply in
	Yes | YES | yes | Y | y ) 
	    git clone git@github.com:SeizeOP/scripts.git ~/scripts/ ; break ;;
	No | NO | no | n )
		echo "skipping download of scripts repo..." ; break ;;
	* )
		echo "Please answer yes or no.";;
    esac
done


### Create the required symlinks ### 
echo "Generate symlinks from ~/dotfiles/[subdir] -> ~/.config/[subdir]?" 
echo ""
echo -e "NOTE: This WILL overwrite existing files under ~/.config/[subdir]. Make backups if necessary before running."
echo -e "NOTE: Some system configurations may not function properly if not symlinked either manually or via this script."
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
	No | NO | no | n ) 
		echo "Skipping symlink creation..." ; break ;;
	* ) 
		echo -e "Please answer yes or no.";;
    esac
done

### Create custom .desktop files ###
echo "Generate custom desktop files for Emacs and Overrides-gui?"
select strictreply in "Yes" "No"; do
    relaxedreply=${strictreply:-$REPLY}
    case $relaxedreply in
	Yes | YES | yes | Y | y )
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
	No | NO | no | N | n )
		echo -e "Skipping Desktop File Creation."; break;;
	* )
		echo -e "Please answer yes or no.";;
    esac
done

### Start Custom Waybar ###
echo -e "Launch Waybar with custom configurations now?"
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
			echo "Custom Waybar configuration not loaded for $USER."
	    fi ; break;;
	No | NO | no | N | n )
		echo "Skipping Waybar Configuration laoding..."; break;;
	* )
		echo -e "Please answer yes or no.";;
    esac
done