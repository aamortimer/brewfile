#!/bin/bash

declare -a phpVersions=("7.0" "7.1" "7.2" "7.3")
brewApache=FALSE
multiplePHP=FALSE

command_exists () {
	command -v "$1" >/dev/null 2>&1
}

##
# Setup SSH
##
read -p "Setup SSH keys (Y/n)?" choice
case "$choice" in
	n|N )
		echo "Skipping SSH keys"
	;;
	* )
		echo "Setting up SSH keys"
		read -p "Enter your email address: " email

		ssh-keygen -t rsa -b 4096 -C "$email"
	;;
esac

##
# XCode command line tools
##
echo "Checking to see if we need to install xcode command line tools"

if command_exists xcode-select; then
	echo "XCode command line tools already installed"
else
	xcode-select --install
fi

printf "\n=================\n\n"


##
# Install brew and brew file
##
echo "Checking to see if we need to brew"

if command_exists brew; then
	echo "Brew already installed"
else
 	echo "Installing brew and brew file"
	/usr/bin/ruby -e "$(curl -fsSL https://raw.github.com/rcmdnk/homebrew-file/install/install.sh | sh)"

	brew file set_repo
	brew file init
fi

printf "\n=================\n\n"


##
# Local apache
##
read -p "Install brew apache (Y/n)?" choice
case "$choice" in
	n|N )
		echo "Skipping brew apache"
	;;
	* )
		brewApache=TRUE

		echo "Installing brew apache, please enter sudo password"
		sudo apachectl stop
		sudo launchctl unload -w /System/Library/LaunchDaemons/org.apache.httpd.plist 2>/dev/null

		brew install httpd
		sudo brew services start httpd
	;;
esac

printf "\n=================\n\n"

##
# Multple PHP and switcher
##
if [[ $brewApache == "TRUE" ]]; then
	read -p "Install multiple PHP versions and switcher (Y/n)?" choice
	case "$choice" in
		n|N )
			echo "Skipping multiple PHP version and switcher install"
		;;
		* )
			multiplePHP=TRUE

			echo "Installing multiple PHP version and switcher"

			brew tap 'exolnet/homebrew-deprecated'

			for i in "${phpVersions[@]}"
			do
				brew install php@$i
			done

			curl -L https://gist.githubusercontent.com/rhukster/f4c04f1bf59e0b74e335ee5d186a98e2/raw > /usr/local/bin/sphp
			chmod +x /usr/local/bin/sphp
		;;
	esac

	printf "\n=================\n\n"
fi

##
# DNSmasq
##
read -p "Install DNSmasq (Y/n)?" choice
case "$choice" in
	n|N )
		echo "Skipping DNSmasq"
	;;
	* )
		echo "Installing dnsmasq, local domain will be setup to use *.site URL's"
		brew install dnsmasq

		echo 'address=/.site/127.0.0.1' > /usr/local/etc/dnsmasq.conf
		sudo brew services start dnsmasq
		sudo mkdir -v /etc/resolver
		sudo bash -c 'echo "nameserver 127.0.0.1" > /etc/resolver/site'
	;;
esac

printf "\n=================\n\n"

##
# APCu
##
if [[ $brewApache == "TRUE" ]]; then
	read -p "Install APCu (Y/n)?" choice
	case "$choice" in
		n|N )
			echo "Skipping APCu"
		;;
		* )
			echo "Installing APCu"
			if [[ $multiplePHP == "FALSE" ]]; then
				for i in "${phpVersions[@]}"
				do
					sphp $1
					pecl uninstall -r apcu
					pecl install apcu
				done
			else
				pecl uninstall -r apcu
				pecl install apcu
			fi
		;;
	esac

	printf "\n=================\n\n"

	read -p "Install PHP YAML (Y/n)?" choice
	case "$choice" in
		n|N )
			echo "Skipping PHP YAML"
		;;
		* )
			echo "Installing PHP YAML"
			if [[ $multiplePHP == "TRUE" ]]; then
				for i in "${phpVersions[@]}"
				do
					sphp $1
					pecl uninstall -r yaml
					pecl install yaml
				done
			else
				pecl uninstall -r yaml
				pecl install yaml
			fi
		;;
	esac

	printf "\n=================\n\n"

	read -p "Install XDebug (Y/n)?" choice
	case "$choice" in
		n|N )
			echo "Skipping XDebug"
		;;
		* )

			echo "Installing Xdebug Toggler for OSX"
			echo "View (https://github.com/w00fz/xdebug-osx) for usage instructions."

			curl -L https://gist.githubusercontent.com/rhukster/073a2c1270ccb2c6868e7aced92001cf/raw > /usr/local/bin/xdebug

			if [[ $multiplePHP == "TRUE" ]]; then
				for i in "${phpVersions[@]}"
				do
					sphp $1
					pecl uninstall -r xdebug
					pecl install xdebug
				done
			fi
		;;
	esac
fi

printf "\n=================\n\n"

echo "******************** Done ********************"
