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
		echo -e "Cannot detect OS version. \e[1;31m/etc/os-release\e[0m not found"
		echo ""
		echo -e "This script supports ONLY distrobutions based on Fedora, Debian/Ubuntu, OpenSUSE, and Arch Linux." 
		echo "If you know that your system is based on one of these supported distrobutions you may proceed with running this script."
		echo "Otherwise, it is reccomended to exit the script now."
		echo ""
		echo "Portions of this script will work on unsupported disrobutions. However package installation and update will not work."
		echo -e "Continue to Run HD's post install script?"
		select strictreply in "Yes" "No"; do
			case $relaxedreply in
				Yes | YES | yes | Y | y )
					echo "Continuing to load script..."
					echo "" ; break ;;
				No | NO | no | n )
					echo "Exiting script..."
					kill -9 $(ps aux | grep '[s]etup.sh' | awk '{print $2}')
				esac
			case $relaxedreply in
				* ) 
					echo "Please answer \e[1;32myes\e[0m or \e[1;31mno\e[0m."; break ;;
    		esac
		done
esac

# Update System
echo "It is reccomended that the system is fully up to date when running this script."
echo -e "\e[1;31mCheck for updates now?\e[0m"
select strictreply in "Yes" "No"; do
    relaxedreply=${strictreply:-$REPLY}
    case $relaxedreply in
		Yes | YES | yes | Y | y )
			case $DISTRO_ID in
				arch|endeavoros|garuda|manjaro)
					echo "Updating Pacman packages..."
					sudo pacman -Syu
					echo "" ; break ;;
				bazzite|ublue|secureblue)
					echo -e "Updating OSTree..."
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
			echo -e "\e[1;33mskipping system update...\e[0m" 
			echo "" ; break ;;
		* ) 
			echo -e "Please answer \e[1;32myes\e[0m or \e[1;31mno\e[0m."
    esac
done

### Setup 3rd Party Repositories if necessary ###
echo "Some external repositories may be needed for proper installation of custom configurations." 
echo "Would you like to enable these repositories now?"
echo ""
echo -e "Selecting Yes to enabling 3rd party repositories will do \e[1;33mone\e[0m of the following:"
echo -e "\e[1;32m1.\e[0m Enable several COPRs and 3rd party repositories on Fedora" 
echo -e "\e[1;32m2.\e[0m Install an AUR helper on Arch based systems" 
echo -e "\e[1;32m3.\e[0m Enable several PPAs on Ubuntu based systems"
echo -e "\e[1;32m4.\e[0m Enable several 3rd party repositories on Bazzite/Ublue systems" 
echo ""
select strictreply in "Yes" "No"; do
    relaxedreply=${strictreply:-$REPLY}
    case $relaxedreply in
		Yes | YES | yes | Y | y )
			case $DISTRO_ID in
				fedora|redhat)
					# If on Fedora, enable Fedora COPRs
					sudo dnf copr enable erikreider/SwayNotificationCenter
					sudo dnf copr enable sdegler/hyprland
					sudo dnf copr enable yalter/niri
					# enable brave browser non-COPR repo for fedora
					sudo dnf install dnf-plugins-core -y
					sudo config-manager addrepo --from-repofile=https://brave-browser-rpm-release.s3.brave.com/brave-browser.repo
					echo "" ; break ;;
			esac
		# if on Bazzite enable Brave browser repo
			case $DISTRO_ID in
				bazzite|ublue)
					run0 curl -fsSLo /etc/yum.repos.d/brave-browser.repo https://brave-browser-rpm-release.s3.brave.com/brave-browser.repo
			esac
		# If on Arch, Install an AUR helper
			case $DISTRO_ID in
				arch|endeavoros|garuda|manjaro)		
					sudo pacman -Sy yay 		
					echo "" ; break ;;
			esac
		# If on Ubuntu enable Ubuntu PPAs, Universe, and Restricted repositories
			case $DISTRO_ID in
				debian|ubuntu|mint|zorin)
					sudo add-apt-repository universe
					sudo add-apt-repository restricted
					echo "" ; break ;;
			esac
		# If on Opensuse add 3rd party repositories
			case $DISTRO_ID in
				opensuse|opensuse-tumbleweed|opensuse-leap)
					sudo zypper addrepo https://brave-browser-rpm-release.s3.brave.com/brave-browser.repo
					echo "" ; break ;;
			esac
	esac
	case $relaxedreply in
		No | NO | no | n )  
			echo -e "\e[1;33mSkipping 3rd party repo setup...\e[0m"
			echo "" ; break ;;
		* )
			echo -e "Please answer \e[1;32myes\e[0m or \e[1;31mno\e[0m."
	esac
done

### Install Dependencies ###
apt_packages=(sway swaylock swaync waybar waypaper wlogout kitty rofi-wayland emacs tealdeer)
dnf_packages=(brave-browser emacs hyprland hyprlock hyprpaper niri ptyxis sway swaync waybar waypaper wlogout kitty rofi-wayland tealdeer)
arch_packages=(hyprland hyprpaper hyprlock sway swaync niri brave-bin)
suse_packages=(hyprland hyprpaper hyprlock sway niri)
ublue_packages=(brave-browser)
flatpak_packages=(com.belmoussaoui.Authenticator com.github.tchx84.Flatseal io.github.flattool.Warehouse com.nextcloud.desktopclient.nextcloud com.obsproject.Studio org.audacityteam.Audacity)

echo "Woud you like to (re)install the packages required for dotfiles configurations?"
select strictreply in "Yes" "No"; do
	relaxedreply=${strictreply:-$REPLY}
    case $relaxedreply in
		Yes | YES | yes | Y | y )
			case $DISTRO_ID in
				arch|endeavoros|garuda|manjaro)
					sudo pacman -Sy "${arch_packages[@]}"
					echo "" ; break ;;
				debian|ubuntu|mint|zorin)
					sudo apt install $apt_packages -y
					echo "" ; break ;;
				fedora|redhat)
					sudo dnf install "${dnf_packages[@]}" -y
					echo "" ; break ;;
				opensuse|opensuse-tumbleweed|opensuse-leap)
					sudo zypper install "${suse_packages[@]}"
					echo "" ; break ;;
				bazzite|ublue)
					run0 install brave-browser
					echo "" ; break ;;
			esac
	esac
	case $relaxedreply in
		No | NO | no | n )  
			echo -e "\e[1;33mSkipping installation of dependencies...\e[0m" 
			echo "" ; break ;;
		* )
			echo -e "Please answer \e[1;32myes\e[0m or \e[1;31mno\e[0m."
	esac
done

### Optionally install additional Flatpak packages ###
if command -v flatpak &> /dev/null; then
	echo "Would you like to install additional Flatpak packages?"
	select strictreply in "Yes" "No"; do
    	relaxedreply=${strictreply:-$REPLY}
    	case $relaxedreply in
			Yes | YES | yes | Y | y )
				flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
				flatpak install $flatpak_packages
				echo "" ; break ;;
			No | NO | no | n )  
				echo -e "\e[1;33mSkipping Flatpak package installation...\e[0m"
				echo "" ; break ;;
			* )
				echo -e "Please answer \e[1;32myes\e[0m or \e[1;31mno\e[0m."
		esac
	done
else
	echo ""
	break
fi
### Clone the required git repositories ###
echo "Install preconfigured dotfiles?"
select strictreply in "Yes" "No"; do
    relaxedreply=${strictreply:-$REPLY}
    case $relaxedreply in
		Yes | YES | yes | Y | y ) 
	    	git clone git@github.com:SeizeOP/dots.git ~/dotfiles/ 
			echo "" ; break ;;
		No | NO | no | n )
			echo -e "\e[1;33mSkipping download of preconfigured dotfiles...\e[0m" 
			echo "" ; break ;;
		* )
			echo -e "Please answer \e[1;32myes\e[0m or \e[1;31mno\e[0m."
    esac
done

echo "Woud you like to the install additional shell scripts to add system functionality?"
echo ""
echo -e "\e[1;31mNOTE:\e[0m Required for some Wlogout functionality, and launch scripts."
select strictreply in "Yes" "No"; do
    relaxedreply=${strictreply:-$REPLY}
    case $relaxedreply in
		Yes | YES | yes | Y | y ) 
	    	git clone git@github.com:SeizeOP/scripts.git ~/scripts/ ; break ;;
		No | NO | no | n )
			echo -e "\e[1;33mSkipping download of scripts repo...\e[0m" 
			echo "" ; break ;;
		* )
			echo -e "Please answer \e[1;32myes\e[0m or \e[1;31mno\e[0m."
    esac
done

### Create the required symlinks ### 
echo "Generate symlinks from ~/dotfiles/[subdir] -> ~/.config/[subdir]?" 
echo ""
echo -e "\e[1;31mNOTE:\e[0m This WILL overwrite existing files under ~/.config/[subdir]. Make backups if necessary before running."
echo -e "\e[1;31mNOTE:\e[0m Some system configurations may not function properly if not symlinked either manually or via this script."
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
		echo -e "\e[1;33mSkipping symlink creation...\e[0m" 
		echo "" ; break ;;
	* ) 
		echo -e "Please answer \e[1;32myes\e[0m or \e[1;31mno\e[0m."
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
		echo -e "\e[1;33mSkipping Desktop File Creation...\e[0m"
		echo "" ; break;;
	* )
		echo -e "Please answer \e[1;32myes\e[0m or \e[1;31mno\e[0m."
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
			echo ""
	    fi ; break;;
	No | NO | no | N | n )
		echo -e "\e[1;33mSkipping Waybar Configuration laoding...\e[0m"
		echo "" ; break;;
	* )
		echo -e "Please answer \e[1;32myes\e[0m or \e[1;31mno\e[0m."
    esac
done

# Script completion message
echo "Thank you for using HD's post install script."
echo "A reeboot may be necessary to fully apply changes made by this script."
echo ""
