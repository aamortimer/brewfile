# Setup 
New mac setup

## Install
You can install this project by either running:

```bash
/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/aamortimer/brewfile/master/install.sh | sh)"
```

or

```bash
mkdir -p ~/Sites/brefile
cd ~/Sites
git clone https://github.com/aamortimer/brewfile.git
cd ~/Sites/brewfile
./install.sh
```

The above will guide you through setting up the following.

* Installs XCode command line tools if not already installed
* Install brew and homebrew file if not already installed (https://github.com/rcmdnk/homebrew-file)
* **Optionally** installs brew apache
* **Optionally** installs multiple versions of PHP
* **Optionally** installs multiple versions of [DNSmasq](http://www.thekelleys.org.uk/dnsmasq/doc.html)
* **Optionally** installs [APCu](http://php.net/manual/en/book.apcu.php) for PHP
* **Optionally** installs [PHP YAML](http://php.net/manual/en/book.yaml.php)
* **Optionally** installs [XDebug](hhttps://xdebug.org/) and [Xdebug Toggler for OSX](https://github.com/w00fz/xdebug-osx)
* **Optionally** Creates SSH key

> The Apache PHP setup comes from the following guide [macOS 10.14 Mojave Apache Setup: Multiple PHP Versions
](https://getgrav.org/blog/macos-mojave-apache-multiple-php-versions)


### Brew file recommendations
Install brew wrap [brew wrap](https://homebrew-file.readthedocs.io/en/latest/brew-wrap.html) to keep the brew file updates

```bash
curl -L https://raw.githubusercontent.com/rcmdnk/homebrew-file/master/etc/brew-wrap > $(brew --prefix)/etc/brew-wrap
```

To enable it, just read this file in your `.bashrc` or any of your setup file:

```bash
if [ -f $(brew --prefix)/etc/brew-wrap ];then
  source $(brew --prefix)/etc/brew-wrap
fi
```

If you are using multiple Mac in the same time, it is good to have a cron job like:


```
30 12 * * * brew file update
```

This command installs new packages which were installed in another Mac at a lunch time (12:30) every day.

## Bash Completions
Bash completions are added via the brewfile to enable them add the following to your `.bashrc` file

```bash
brew_completion=$(brew --prefix 2>/dev/null)/etc/bash_completion
if [ $? -eq 0 ] && [ -f "$brew_completion" ];then
  source $brew_completion
fi
```

## Zsh
Install with:

```
brew install zsh
brew install zsh-completions
brew install zsh-syntax-highlighting
```

and then add the following to your settings in your `.zshrc`:

```bash
for d in "/share/zsh-completions" "/share/zsh/zsh-site-functions";do
  brew_completion=$(brew --prefix 2>/dev/null)$d
  if [ $? -eq 0 ] && [ -d "$brew_completion" ];then
    fpath=($brew_completion $fpath)
  fi
done
autoload -U compinit
compinit
```
