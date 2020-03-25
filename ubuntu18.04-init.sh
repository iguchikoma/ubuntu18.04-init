#!/bin/bash
set -uvx

# Setup screen
# Memo: For useful management, install screen
function setup-screen() {

  ls ~/.screenrc ||\
  git clone https://github.com/iguchikoma/screen.git ~/screen
  mv ~/screen/.screen* ~/
  rm -rf ~/screen

  # for screen copy to clipboard
  touch ~/.screen-exchange

}

# Setup tmux
# Ref: https://qiita.com/ysuzuki19/items/58cd8ac6a79849308fef
function setup-tmux() {
  sudo apt-get update
  sudo apt-get install -y tmux
}

# Setup utility
function setup-util() {
  sudo apt-get update
  sudo apt-get install -y tree
}

# Setup git
# Ref: https://qiita.com/noraworld/items/8546c44d1ec6d739493f
function setup-git() {

  ls ~/.git-prompt.sh ||\
  ( wget https://raw.githubusercontent.com/git/git/master/contrib/completion/git-prompt.sh &&\
  mv git-prompt.sh ~/.git-prompt.sh )

  git config --global user.email "iguchi.t@gmail.com"
  git config --global user.name "Takashi Iguchi"
  grep '# git config' ~/.bashrc ||\
  cat <<'EOF' >>~/.bashrc

# git config
. ~/.git-prompt.sh
export GIT_PS1_SHOWDIRTYSTATE=1
export PS1='\[\033[32m\]\u@\h\[\033[00m\]:\[\033[34m\]\w\[\033[31m\]$(__git_ps1)\[\033[00m\]\$ '
EOF

}

# Setup ls color
# Memo: For easy to see, install ls color
function setup-ls-color() {

  ls ~/.dircolors ||\
  ( wget https://raw.githubusercontent.com/seebi/dircolors-solarized/master/dircolors.ansi-universal &&\
  mv dircolors.ansi-universal ~/.dircolors )

  grep '# ls color config' ~/.bashrc ||\
  cat <<'EOF' >>~/.bashrc

# ls color config (add here)
if [ -f ~/.dircolors ]; then
    if type dircolors > /dev/null 2>&1; then
        eval $(dircolors ~/.dircolors)
    fi
fi
EOF

}

# Setup .bash_profile
# For using pyenv, pyenv-virtualenv, creae .bash_profile
function setup-bash-profile() {

  touch ~/.bash_profile
  cat <<'EOF' >>~/.bash_profile

# if running bash
if [ -n "$BASH_VERSION" ]; then
    # include .bashrc if it exists
    if [ -f "$HOME/.bashrc" ]; then
        . "$HOME/.bashrc"
    fi
fi
EOF

}

# Setup pyenv
# For using python code (e.g. Grafana init, etc.), install pyenv
function setup-pyenv() {

  ls ~/.pyenv ||\
  git clone https://github.com/pyenv/pyenv.git ~/.pyenv

  grep '# pyenv init' ~/.bash_profile ||\
  cat <<'EOF' >>~/.bash_profile

# pyenv init
# ref: https://github.com/pyenv/pyenv
export PYENV_ROOT=$HOME/.pyenv
export PATH=$PYENV_ROOT/bin:$PATH

if command -v pyenv 1>/dev/null 2>&1; then
  eval "$(pyenv init -)"
fi
EOF

}

# Setup pyenv-virtualenv
# For using python code (e.g. Grafana init, etc.), install pyenv-virtualenv
function setup-pyenv-virtualenv() {

  ls $HOME/.pyenv/plugins/pyenv-virtualenv ||\
  git clone https://github.com/pyenv/pyenv-virtualenv.git $HOME/.pyenv/plugins/pyenv-virtualenv

  grep '# pyenv-virtualenv init' ~/.bash_profile ||\
  cat <<'EOF' >>~/.bash_profile

# pyenv-virtualenv init
# ref: https://github.com/pyenv/pyenv-virtualenv
eval "$(pyenv virtualenv-init -)"
EOF

}

# Setup apt package
# Install some library which use pyenv, pyenv-virtualenv, script etc.
function setup-apt-package() {

  sudo apt-get update
  sudo apt-get -y install build-essential zlib1g-dev libssl-dev libbz2-dev libreadline-dev libsqlite3-dev jq

}

# Setup Docker
# ref: https://docs.docker.com/install/linux/docker-ce/ubuntu/
function setup-docker(){

  sudo apt-get remove docker docker-engine docker.io containerd runc
  sudo apt-get update
  sudo apt-get install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg-agent \
    software-properties-common
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
  sudo add-apt-repository \
     "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
     $(lsb_release -cs) \
     stable"
  sudo apt-get update
  sudo apt-get install -y docker-ce docker-ce-cli containerd.io

}

# Setup docker's log rotate
function setup-docker-logrotate(){

  sudo grep '/var/lib/docker/containers' /etc/logrotate.d/docker ||\
  sudo tee /etc/logrotate.d/docker <<EOF
/var/lib/docker/containers/*/*.log {
    rotate ${LOGROTATE_FILES_MAX_COUNT:-6}
    copytruncate
    missingok
    notifempty
    compress
    delaycompress
    maxsize ${LOGROTATE_MAX_SIZE:-100M}
    # daily
    dateext
    dateformat -%Y%m%d-%s
    # create 0644 root root
}
EOF
}

# Setup to enable non sudo docker command
function setup-non-sudo-docker(){

  sudo usermod -aG docker $USER

}

# Setup Docker compose
function setup-docker-compose(){

  export compose='1.24.0'
  sudo curl -L https://github.com/docker/compose/releases/download/${compose}/docker-compose-`uname -s`-`uname -m` -o /usr/local/bin/docker-compose
  sudo chmod 0755 /usr/local/bin/docker-compose

}

# Setup nodejs and npm
# ref: https://qiita.com/_takeshi_24/items/224d00e5a026dbb76716
function setup-nodejs(){

  sudo apt-get update
  sudo apt-get install -y nodejs
  sudo apt-get install -y npm
  sudo npm cache clean
  sudo npm install -g n
  sudo n stable
  sudo npm update -g npm

}

# Main Function
function main() {
  : "Start to configure ubuntu18.04"

  setup-screen
  setup-tmux
  setup-util
  setup-git
  setup-ls-color
  setup-bash-profile
  setup-pyenv
  setup-pyenv-virtualenv
  setup-apt-package
  setup-docker
  setup-docker-logrotate
  setup-non-sudo-docker
  setup-docker-compose
  setup-nodejs

  : "Done for the configuration for ubuntu18.04"
}

main
