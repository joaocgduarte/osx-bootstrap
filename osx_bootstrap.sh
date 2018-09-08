#!/usr/bin/env bash
# 
# Bootstrap script for setting up a new OSX machine
# 
# This should be idempotent so it can be run multiple times.
#
# Some apps don't have a cask and so still need to be installed by hand. These
# include:
#
# - Newton (app store)
# - ClipMenu
# - Asana
#
# Notes:
#
# - If you already have any of the casks apps installed,
#   the script will throw an error and won't install any casks apps.
#
# Reading:
#
# - http://lapwinglabs.com/blog/hacker-guide-to-setting-up-your-mac
# - https://gist.github.com/MatthewMueller/e22d9840f9ea2fee4716
# - https://news.ycombinator.com/item?id=8402079
# - http://notes.jerzygangi.com/the-best-pgp-tutorial-for-mac-os-x-ever/
# 
# TO DO: 
#
# Try to install AppleStore apps with `mas`
# Think about mackup to restore configs

log_header() {
    echo ""
    echo "---  $1  ---"
    echo "---------------------------------------------"   
}

log_line() {
    echo "### $1 #"
}

log_line "Starting bootstrapping"

log_header "Installing XCode command line tools"
xcode-select --install

# Check for Homebrew, install if we don't have it
if test ! $(which brew); then
    log_header "Installing homebrew..."
    ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
fi

log_header "Update brew recipes"
brew update

log_header "Install GNU core utilities" #(those that come with OS X are outdated)
brew install coreutils
brew install gnu-sed --with-default-names
brew install gnu-tar --with-default-names
brew install gnu-indent --with-default-names
brew install gnu-which --with-default-names
brew install grep --with-default-names

log_header "Install GNU find, locate, updatedb, and xargs, g-prefixed"
brew install findutils

log_header "Install Bash 4"
brew install bash

PACKAGES=(
    ack
    autoconf
    automake
    composer
    ffmpeg
    gettext
    git
    graphviz
    imagemagick
    libjpeg
    node
    nvm
    pkg-config
    python
    ssh-copy-id
    terminal-notifier
    tree
    wget
    z
    zsh
    zsh-completions
)

log_header "Installing brew packages..."
brew install ${PACKAGES[@]}

log_line "Cleaning up brew..."
brew cleanup

log_line "Installing cask..."
brew tap caskroom/cask

CASKS=(
    alfred
    appcleaner
    beardedspice
    boostnote
    brave
    day-o
    docker
    dropbox
    etcher
    evernote
    firefox
    flux
    filezilla
    franz
    google-chrome
    iterm2
    keybase
    kitematic
    openemu
    openoffice
    postman
    synergy
    skype
    spectacle
    spotify
    the-unarchiver
    tunnelblick
    visual-studio-code
    vlc
)

log_header "Installing cask apps..."
brew cask install ${CASKS[@]}

log_line "Cleaning up cask..."
brew cask cleanup

log_header "Installing fonts..."
brew tap caskroom/fonts
FONTS=(
    font-clear-sans
    font-inconsolata
    font-lato
    font-roboto
    font-source-code-pro
    font-source-code-pro-for-powerline
)
brew cask install ${FONTS[@]}

log_header "Install rvm"
mkdir -p ~/.rvm/src && cd ~/.rvm/src && rm -rf ./rvm && \
git clone --depth 1 https://github.com/rvm/rvm.git && \
cd rvm && ./install

log_header "Installing Ruby gems"
RUBY_GEMS=(
    sass
)
sudo gem install ${RUBY_GEMS[@]}

# log_text "Installing global npm packages..."
# npm install marked -g

log_header "Configuring OSX..."

# Set fast key repeat rate
defaults write NSGlobalDomain KeyRepeat -int 0

# Require password as soon as screensaver or sleep mode starts
defaults write com.apple.screensaver askForPassword -int 1
defaults write com.apple.screensaver askForPasswordDelay -int 0

# Show filename extensions by default
defaults write NSGlobalDomain AppleShowAllExtensions -bool true

# Disable "natural" scroll
defaults write NSGlobalDomain com.apple.swipescrolldirection -bool false

# Show battery percentage
defaults write com.apple.menuextra.battery ShowPercent YES

# Set dock preferences
defaults write com.apple.dock tilesize -int 32
defaults write com.apple.dock magnification -bool true
defaults write com.apple.dock mineffect -string 'scale'
killall Dock

# Show full path in finder title
defaults write com.apple.finder _FXShowPosixPathInTitle -bool true

log_header "Creating folder structure..."
[[ ! -d ~/sites ]] && mkdir ~/sites

log_header "Installing oh-my-zsh"
sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"

log_line "Bootstrapping complete"