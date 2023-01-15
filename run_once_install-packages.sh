#!/bin/sh
echo "Installing dependencies..."

install_pkgs() {
  pkgs=$1
  install=false
  for pkg in $pkgs; do
    install_pkg $pkg
    install=false
  done
}

install_pkg() {
  pkg=$1
  status="$(dpkg-query -W --showformat='${db:Status-Status}' "$pkg" 2>&1)"
  if [ ! $? = 0 ] || [ ! "$status" = installed ]; then
    install=true
    break
  fi

  if "$install"; then
    sudo apt install $pkg -qq
    echo "Installing $pkg"
  else
    echo "$pkg Already installed"
  fi
}

install_pkgs 'curl neofetch git htop'

###> ZSH ###
install_pkg 'zsh'

if ! [ -f ~/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh ]; then
    git clone https://github.com/zsh-users/zsh-autosuggestions ~/.zsh/zsh-autosuggestions
fi

if ! [ -x "$(command -v starship)" ]; then
    curl -sS https://starship.rs/install.sh | sh
fi
###> ZSH ###
