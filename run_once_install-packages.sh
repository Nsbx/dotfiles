#!/bin/bash

# Couleurs et styles
BLUE='\033[0;34m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color
BOLD='\033[1m'

echo -e "\n${BOLD}🚀 Démarrage de l'installation des dépendances...${NC}\n"

install_pkg() {
    pkg=$1
    if ! dpkg-query -W -f='${Status}' "$pkg" 2>/dev/null | grep -q "installed"; then
        echo -e "📦 Installation de ${BLUE}$pkg${NC}..."
        sudo apt-get install -y "$pkg" >/dev/null 2>&1
    else
        echo -e "✅ ${GREEN}$pkg${NC} est déjà installé"
    fi
}

install_pkgs() {
    for pkg in $1; do
        install_pkg "$pkg"
    done
}

# Mettre à jour les dépôts
echo -e "\n🔄 ${YELLOW}Mise à jour de la liste des paquets...${NC}"
sudo apt-get update >/dev/null 2>&1

# Installer les packages de base
echo -e "\n🛠️  ${YELLOW}Installation des paquets de base...${NC}"
install_pkgs "curl neofetch git htop"

###> ZSH ###
echo -e "\n🐚 ${YELLOW}Configuration de l'environnement ZSH...${NC}"
install_pkg "zsh"

# Configuration de zsh-autosuggestions
if [ ! -d ~/.zsh/zsh-autosuggestions ]; then
    echo -e "🔌 Installation de ${BLUE}zsh-autosuggestions${NC}..."
    mkdir -p ~/.zsh >/dev/null 2>&1
    git clone -q https://github.com/zsh-users/zsh-autosuggestions ~/.zsh/zsh-autosuggestions >/dev/null 2>&1
else
    echo -e "✅ ${GREEN}zsh-autosuggestions${NC} est déjà installé"
fi

# Installation de Starship
if ! command -v starship >/dev/null 2>&1; then
    echo -e "🚀 Installation de ${BLUE}Starship prompt${NC}..."
    curl -sS https://starship.rs/install.sh | sh -s -- -y >/dev/null 2>&1
else
    echo -e "✅ ${GREEN}Starship${NC} est déjà installé"
fi

# Définir zsh comme shell par défaut si ce n'est pas déjà le cas
if [ "$SHELL" != "/usr/bin/zsh" ]; then
    echo -e "🔧 Configuration de ${BLUE}ZSH${NC} comme shell par défaut..."
    chsh -s $(which zsh) >/dev/null 2>&1
fi
###> ZSH ###

echo -e "\n✨ ${GREEN}Installation terminée avec succès !${NC} 🎉\n"
