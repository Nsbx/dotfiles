#!/bin/bash

# Couleurs
GREEN='\033[0;32m'
NC='\033[0m'

if output=$(unison dev-sync 2>&1); then
    # Si la synchronisation réussit, n'afficher que le succès
    echo -e "${GREEN}✅ Synchronisation terminée${NC}"
else
    # En cas d'erreur, afficher le message d'erreur
    echo -e "${RED}❌ Erreur de synchronisation :${NC}"
    echo "$output"
    exit 1
fi
