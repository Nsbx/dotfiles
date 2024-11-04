#!/bin/bash

# Couleurs et styles
BLUE='\033[0;34m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'
BOLD='\033[1m'

# Configuration
DEV_DIR="$HOME/dev"
WINDOWS_DIR="/mnt/n/Dev"
UNISON_DIR="$HOME/.unison"

# Créer le dossier de développement
echo -e "📁 Création du dossier dev dans ${BLUE}$DEV_DIR${NC}..."
mkdir -p "$DEV_DIR"

# Créer le dossier Windows s'il n'existe pas
echo -e "📁 Vérification du dossier Windows dans ${BLUE}$WINDOWS_DIR${NC}..."
mkdir -p "$WINDOWS_DIR"

# Couleurs
GREEN='\033[0;32m'
NC='\033[0m'

echo -e "${GREEN}🔄 Synchronisation en cours...${NC}"
unison dev-sync

EOL

# Rendre le script exécutable
chmod +x "$SYNC_SCRIPT"

# Installer unison si ce n'est pas déjà fait
if ! command -v unison >/dev/null 2>&1; then
    echo -e "📦 Installation de ${BLUE}unison${NC}..."
    sudo apt-get update >/dev/null 2>&1
    sudo apt-get install -y unison >/dev/null 2>&1
fi

# Ajouter le script au PATH si nécessaire
if ! grep -q "$HOME/bin" "$HOME/.bashrc"; then
    echo 'export PATH="$HOME/bin:$PATH"' >> "$HOME/.bashrc"
    echo 'export PATH="$HOME/bin:$PATH"' >> "$HOME/.zshrc"
fi

echo -e "\n✨ ${GREEN}Configuration terminée !${NC} 🎉\n"
echo -e "Pour synchroniser vos dossiers, utilisez la commande : ${BOLD}unison dev-sync${NC}"
echo -e "Vos dossiers de développement sont :"
echo -e "  - Linux : ${BLUE}$DEV_DIR${NC}"
echo -e "  - Windows : ${BLUE}$WINDOWS_DIR${NC}"
