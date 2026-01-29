#!/usr/bin/env bash

# Author: SeizeOP (HD)
# Script Name: update.sh	
# Description: Script to update Linux based systems.
# Github: https://SeizeOP/scripts/bash/update.sh
# License: https://SeizeOP/scripts/LICENSE
# Contributers: SeizeOP
if [[ -f /etc/os-release ]]; then
    . /etc/os-release 
    DISTRO_NAME="$NAME"
    DISTRO_ID="$ID"
    echo -e "Detected OS: \e[1;32m$DISTRO_NAME\e[0m ($DISTRO_ID)"
    echo ""
else
    echo -e "Cannot detect OS version. /etc/os-release not found"
    DISTRO_NAME="unknown"
    DISTRO_ID="unknown"
fi
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
echo -e "\e[1;31mCheck for updates now?\e[0m"
select strictreply in "Yes" "No" "Quit"; do
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
	    if command -v brew &> /dev/null; then
		echo -e "Updating Brew packages..."
		brew update && brew upgrade
		echo ""
	    else
		echo ""
	    fi ; break ;;
	esac
    	case $relaxedreply in
	    Quit | QUIT | quit | Q | q )
		echo -e "\e[1;31mExiting script...\e[0m"
		kill -9 $(ps aux | grep '[u]pdate.sh' | awk '{print $2}')
	esac
	case $relaxedreply in
	    No | NO | no | n )
		echo -e "\e[1;33mskipping system update...\e[0m" 
		echo "" ; break ;;
	    * ) 
		echo -e "Please answer \e[1;32myes\e[0m or \e[1;31mno\e[0m."
    esac
done
