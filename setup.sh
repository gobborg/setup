!# /usr/bin/bash
set -eox pipefail

# make it scream at me when I need to manually do sth
play_tone() {
	ffplay -f lavfi -i "sine=frequency=800:duration=0.8" -autoexit -nodisp &>/dev/null
	sleep 0.5
}

play_alert() {
	# Record current audio settings
	WAS_MUTED="$(amixer -D pulse sget Master | grep '\[off\]' || true)"
	WAS_LEVEL="$(amixer -D pulse sget Master | grep -Po '(?<=\[)\d+%(?=\])' | head -n 1)"
	# Set to full volume
	amixer -D pulse sset Master 100% &>/dev/null
	amixer -D pulse sset Master unmute &>/dev/null
	# Play alert
	for i in {1..4}; do
	play_tone
	done
	# Restore previous audio settings
	echo "Restoring audio ($WAS_LEVEL, $(if test -z "$WAS_MUTED"; then echo "not "; fi)muted)"
	amixer -D pulse sset Master "$WAS_LEVEL" &>/dev/null
	if test -z "$WAS_MUTED"; then
	amixer -D pulse sset Master unmute &>/dev/null
	else
	amixer -D pulse sset Master mute &>/dev/null
	fi
}

printDivider() {
	printf %"$COLUMNS"s |tr " " "-"
	printf "\n"
}

# set clock to 24h and timezone to JST
localectl set-locale LC_TIME="en_GB.UTF-8"
timedatectl set-timezone Japan

# apple force apps to not bounce

# remove installed packages for testing: fedora
dnf remove ant awscli bat consul docker-compose docker-distribution git java-1.8.0-openjdk kafka mysql neofetch npm postgresql python3-ipython tldr tmux tree vim-enhanced

# install packages: fedora
dnf install ant awscli bat consul docker-compose docker-distribution git java-1.8.0-openjdk kafka mysql neofetch npm postgresql python3-ipython tldr tmux tree vim-enhanced

# install npm packages
#sudo npm -i 

# get git config (this will overwrite any existing ${HOME}/.gitconfig file
curl -fsSL https://raw.githubusercontent.com/gobborg/dotfiles/main/.gitconfig --output ${HOME}/.gitconfig

# set up ssh keygen
if [ -n ${HOME}/.ssh ]; then
	echo "${HOME}/.ssh exists"
else
	mkdir -p ${HOME}/.ssh
fi
if [ -n ${HOME}/.ssh/config ]; then
	echo "${HOME}/.ssh/config exists. Truncating contents."
	truncate -s 0 ${HOME}/.ssh/config
else
	touch ${HOME}/.ssh/config
fi
play_alert # scream
read -p 'What is the email address to associate with this GitHub account?' githubEmail
ssh-keygen -t ed25519 -C "$githubEmail"
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_ed25519

# git clone other dotfiles (this will repeat getting the .gitconfig but that's ok) and symlink them to the appropriate locations
mkdir ${HOME}/dotfiles
git clone https://github.com/gobborg/dotfiles.git ${HOME}/dotfiles # can't use ssh until the public key is copied into the GH account in the git config
ln -sv ${HOME}/dotfiles/* ${HOME}/
git config --global user.email "$githubEmail"

# check python version and alias it
if [[ $(python --version) == "Python 3"* ]]; then
	echo "alias py=$(which python)" >>${HOME}/.bash_aliases;
else dnf install python && echo "alias py=$(which python)" >>${HOME}/.bash_aliases;
fi

source .bashrc
