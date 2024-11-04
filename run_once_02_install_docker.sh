#!/bin/bash

# run_once_02_install_docker.sh
# =============================================================================
# Configuration de Docker Desktop pour WSL

# Charger les fonctions de logging
source ~/.utils/logging.sh

log_section "Configuration de Docker Desktop"

# Vérifier si nous sommes dans WSL
if ! grep -qi microsoft /proc/version; then
    log_error "Ce script est conçu pour être exécuté dans WSL"
    exit 1
fi

# Vérifier si Docker Desktop est installé sur Windows
if ! command -v docker.exe &> /dev/null; then
    log_warning "Docker Desktop ne semble pas être installé sur Windows"
    log_info "Veuillez installer Docker Desktop depuis : https://www.docker.com/products/docker-desktop/"
    log_info "Après l'installation :"
    log_info "1. Ouvrez Docker Desktop"
    log_info "2. Allez dans Settings > Resources > WSL Integration"
    log_info "3. Activez l'intégration pour votre distribution WSL"
    exit 1
fi

log_done "Configuration de Docker Desktop terminée !"

# Afficher les informations de version
log_section "Versions installées"
if command -v docker.exe &> /dev/null; then
    log_version "Docker Desktop" "$(docker.exe --version | cut -d' ' -f3 | tr -d ',')"
    log_version "Docker Compose" "$(docker-compose.exe version --short)"
    
    if docker.exe ps &>/dev/null; then
        log_success "Docker Desktop est fonctionnel !"
    else
        log_warning "Docker Desktop ne semble pas être en cours d'exécution"
        log_info "Veuillez démarrer Docker Desktop sur Windows"
    fi
fi

# Instructions finales
log_section "Instructions supplémentaires"
echo -e "\nPour utiliser Docker Desktop :"
echo "1. Assurez-vous que Docker Desktop est en cours d'exécution sur Windows"
echo "2. Vérifiez que l'intégration WSL est activée dans les paramètres"
echo "3. Redémarrez votre terminal WSL pour appliquer les modifications"