#!/bin/bash

# Couleurs et styles
BLUE='\033[0;34m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'
BOLD='\033[1m'

echo -e "\n${BOLD}🐳 Installation de Docker...${NC}\n"

# Installation des prérequis
echo -e "📦 ${YELLOW}Installation des prérequis...${NC}"
sudo apt-get update >/dev/null 2>&1
sudo apt-get install -y ca-certificates curl gnupg >/dev/null 2>&1

# Ajout de la clé GPG officielle de Docker
echo -e "🔑 ${YELLOW}Ajout de la clé GPG Docker...${NC}"
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg

# Ajout du repository Docker
echo -e "📝 ${YELLOW}Configuration du repository Docker...${NC}"
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Mise à jour et installation de Docker
echo -e "🐋 ${YELLOW}Installation de Docker...${NC}"
sudo apt-get update >/dev/null 2>&1
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin >/dev/null 2>&1

# Configuration des permissions
echo -e "👤 ${YELLOW}Configuration des permissions utilisateur...${NC}"
sudo groupadd -f docker
sudo usermod -aG docker $USER

# Configuration du démarrage automatique de Docker
echo -e "🔄 ${YELLOW}Configuration du démarrage automatique...${NC}"
DOCKER_START_CMD='\n# Démarrage automatique de Docker\nif ! service docker status >/dev/null 2>&1; then\n    sudo service docker start &>/dev/null\nfi'

# Liste des fichiers de profil à vérifier
PROFILE_FILES=("$HOME/.bashrc" "$HOME/.zshrc" "$HOME/.profile" "$HOME/.bash_profile")

# Ajouter la commande de démarrage dans chaque fichier de profil s'il existe
for profile_file in "${PROFILE_FILES[@]}"; do
    if [ -f "$profile_file" ] && ! grep -q "service docker start" "$profile_file"; then
        echo -e "$DOCKER_START_CMD" >> "$profile_file"
    fi
done

echo -e "\n✨ ${GREEN}Installation de Docker terminée !${NC} 🎉\n"

echo -e "${YELLOW}Versions installées :${NC}"
echo -e "Docker : $(docker --version)"
echo -e "Docker Compose : $(docker compose version)"
