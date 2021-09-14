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
# - Git commitizen (cz) and go mockery generators
#
# Notes:
#
# - If installing full Xcode, it's better to install that first from the app
#   store before running the bootstrap script. Otherwise, Homebrew can't access
#   the Xcode libraries as the agreement hasn't been accepted yet.
#
# Reading:
#
# - http://lapwinglabs.com/blog/hacker-guide-to-setting-up-your-mac
# - https://gist.github.com/MatthewMueller/e22d9840f9ea2fee4716
# - https://news.ycombinator.com/item?id=8402079
# - http://notes.jerzygangi.com/the-best-pgp-tutorial-for-mac-os-x-ever/

# helpers
function echo_ok() { echo -e '\033[1;32m'"$1"'\033[0m'; }
function echo_warn() { echo -e '\033[1;33m'"$1"'\033[0m'; }
function echo_error() { echo -e '\033[1;31mERROR: '"$1"'\033[0m'; }

echo_ok "Install starting. You may be asked for your password (for sudo)."

# requires xcode and tools!
xcode-select -p || exit "XCode must be installed! (use the app store)"

# homebrew
export HOMEBREW_CASK_OPTS="--appdir=/Applications"
if hash brew &>/dev/null; then
	echo_ok "Homebrew already installed. Getting updates..."
	brew update
	brew doctor
else
	echo_warn "Installing homebrew..."
	ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
fi

# Update homebrew recipes
brew update

# Install GNU core utilities (those that come with OS X are outdated)
brew tap homebrew/dupes
brew install coreutils
brew install gnu-sed --with-default-names
brew install gnu-tar --with-default-names
brew install gnu-indent --with-default-names
brew install gnu-which --with-default-names
brew install gnu-grep --with-default-names

# Install GNU `find`, `locate`, `updatedb`, and `xargs`, g-prefixed
brew install findutils

# Install Bash 4
brew install bash


PACKAGES=(
	awscli
	aws-elasticbeanstalk
	bash-completion
	bash-git-prompt
	cask
	curl
	git
	go-delve/delve/delve
	hstr
	jq
	kubernetes-cli
	kubernetes-helm
	pandoc
    nvm
	python3
	ssh-copy-id
	terraform
	terminal-notifier
	the_silver_searcher
	thefuck
	tree
	wget
	xz
	zsh
	zsh-autosuggestions
	zsh-completions
	zsh-syntax-highlighting
)

echo_ok "Installing packages..."
brew install "${PACKAGES[@]}"

echo_ok "Cleaning up..."
brew cleanup

echo_ok "Installing cask..."
# brew install caskroom/cask/brew-cask
brew tap caskroom/cask

CASKS=(
	appcleaner
	appzapper
	cakebrew
	cyberduck
	docker
	firefox
	flycut
	github
	gitter
	google-chrome
	iterm2
	keybase
	microsoft-teams
	qlstephen
	sequel-pro
	simplenote
	slack
	spotify
	spotify-notifications
	visual-studio-code
    balenaetcher
    bitwarden
    brave
    flux
    postman
    rectangle
    tunnelblick
    veracrypt
    vlc
)

echo_ok "Installing cask apps..."
brew cask install "${CASKS[@]}"

# brew cask quicklook
echo_ok "Installing QuickLook Plugins..."
brew cask install \
	qlcolorcode qlmarkdown qlprettypatch qlstephen \
	qlimagesize \
	quicklook-csv quicklook-json epubquicklook

echo_ok "Installing fonts..."
brew tap caskroom/fonts
FONTS=(
	font-clear-sans
	font-consolas-for-powerline
	font-dejavu-sans-mono-for-powerline
	font-fira-code
	font-fira-mono-for-powerline
	font-inconsolata
	font-inconsolata-for-powerline
	font-liberation-mono-for-powerline
	font-menlo-for-powerline
	font-roboto
    font-source-code-pro
    font-source-code-pro-for-powerline
)
brew cask install "${FONTS[@]}"

echo_ok "Installing global npm packages..."
npm install -g spaceship-prompt

echo_ok "Installing oh my zsh..."

if [[ ! -f ~/.zshrc ]]; then
	echo ''
	echo '##### Installing oh-my-zsh...'
	curl -L https://github.com/robbyrussell/oh-my-zsh/raw/master/tools/install.sh | sh

	cp ~/.zshrc ~/.zshrc.orig
	cp ~/.oh-my-zsh/templates/zshrc.zsh-template ~/.zshrc
	chsh -s /bin/zsh
fi

echo_ok "Configuring Github"

# if [[ ! -f ~/.ssh/id_rsa ]]; then
# 	echo ''
# 	echo '##### Please enter your github username: '
# 	read github_user
# 	echo '##### Please enter your github email address: '
# 	read github_email

# 	# setup github
# 	if [[ $github_user && $github_email ]]; then
# 		# setup config
# 		git config --global user.name "$github_user"
# 		git config --global user.email "$github_email"
# 		git config --global github.user "$github_user"
# 		# git config --global github.token your_token_here
# 		git config --global color.ui true
# 		git config --global push.default current
# 		# VS Code support
# 		git config --global core.editor "code --wait"

# 		# set rsa key
# 		curl -s -O http://github-media-downloads.s3.amazonaws.com/osx/git-credential-osxkeychain
# 		chmod u+x git-credential-osxkeychain
# 		sudo mv git-credential-osxkeychain "$(dirname $(which git))/git-credential-osxkeychain"
# 		git config --global credential.helper osxkeychain

# 		# generate ssh key
# 		cd ~/.ssh || exit
# 		ssh-keygen -t rsa -C "$github_email"
# 		pbcopy <~/.ssh/id_rsa.pub
# 		echo ''
# 		echo '##### The following rsa key has been copied to your clipboard: '
# 		cat ~/.ssh/id_rsa.pub
# 		echo '##### Follow step 4 to complete: https://help.github.com/articles/generating-ssh-keys'
# 		ssh -T git@github.com
# 	fi
# fi

echo_ok "Configuring OSX..."

# Set fast key repeat rate
# The step values that correspond to the sliders on the GUI are as follow (lower equals faster):
# KeyRepeat: 120, 90, 60, 30, 12, 6, 2
# InitialKeyRepeat: 120, 94, 68, 35, 25, 15
defaults write NSGlobalDomain KeyRepeat -int 6
defaults write NSGlobalDomain InitialKeyRepeat -int 25

# Always show scrollbars

# Require password as soon as screensaver or sleep mode starts
defaults write com.apple.screensaver askForPassword -int 1
defaults write com.apple.screensaver askForPasswordDelay -int 0

# Show filename extensions by default
# defaults write NSGlobalDomain AppleShowAllExtensions -bool true

# Expanded Save menu
defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode -bool true
defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode2 -bool true

# Expanded Print menu
defaults write NSGlobalDomain PMPrintingExpandedStateForPrint -bool true
defaults write NSGlobalDomain PMPrintingExpandedStateForPrint2 -bool true

# Enable tap-to-click
# defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true
# defaults -currentHost write NSGlobalDomain com.apple.mouse.tapBehavior -int 1

# Disable "natural" scroll
defaults write NSGlobalDomain com.apple.swipescrolldirection -bool false

# Finder: allow quitting via ⌘ + Q; doing so will also hide desktop icons
defaults write com.apple.finder QuitMenuItem -bool true

# Finder: show all filename extensions
defaults write NSGlobalDomain AppleShowAllExtensions -bool true

# Finder: show status bar
defaults write com.apple.finder ShowStatusBar -bool true

# Finder: show path bar
defaults write com.apple.finder ShowPathbar -bool true

# Display full POSIX path as Finder window title
defaults write com.apple.finder _FXShowPosixPathInTitle -bool true

# Keep folders on top when sorting by name
defaults write com.apple.finder _FXSortFoldersFirst -bool true

# When performing a search, search the current folder by default
# defaults write com.apple.finder FXDefaultSearchScope -string "SCcf"

# Avoid creating .DS_Store files on network or USB volumes
defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true
defaults write com.apple.desktopservices DSDontWriteUSBStores -bool true

defaults write com.apple.finder WarnOnEmptyTrash -bool false

# Set the icon size of Dock items to 72 pixels
defaults write com.apple.dock tilesize -int 36

# Speed up Mission Control animations
defaults write com.apple.dock expose-animation-duration -float 0.1

defaults write com.apple.mail AddressesIncludeNameOnPasteboard -bool false

# Disable the warning when changing a file extension
defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false

echo_ok 'Running OSX Software Updates...'
sudo softwareupdate -i -a

echo_ok "Creating folder structure..."
#[[ ! -d Wiki ]] && mkdir Wiki
#[[ ! -d Workspace ]] && mkdir Workspace

echo_ok "Bootstrapping complete"
