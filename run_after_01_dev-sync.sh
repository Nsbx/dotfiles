#!/bin/bash

# Couleurs
GREEN='\033[0;32m'
NC='\033[0m'

if command -v unison >/dev/null 2>&1; then
    echo -e "${GREEN}🔄 Lancement de la synchronisation dev...${NC}"
    unison dev-sync
else
    echo "⚠️  Unison n'est pas installé. Veuillez d'abord exécuter le script d'installation."
fi
