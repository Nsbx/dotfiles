#!/bin/bash

# run_once_99_configure_dev_environment.sh
# =============================================================================
# Configuration de l'environnement de développement

# Charger les fonctions de logging
source ~/.utils/logging.sh

# Configuration
DEV_DIR="$HOME/dev"
WINDOWS_DIR="/mnt/n/Dev"
UNISON_DIR="$HOME/.unison"

log_section "Configuration de l'environnement de développement"

# Créer le dossier de développement
log_pending "Création du dossier dev..."
if run_silent "mkdir -p '$DEV_DIR'"; then
    log_success "Dossier dev créé dans $DEV_DIR"
else
    log_error "Échec de la création du dossier dev"
    exit 1
fi

# Créer le dossier Windows
log_pending "Vérification du dossier Windows..."
if run_silent "mkdir -p '$WINDOWS_DIR'"; then
    log_success "Dossier Windows vérifié dans $WINDOWS_DIR"
else
    log_error "Échec de la création du dossier Windows"
    exit 1
fi

# Installer unison
if ! command_exists unison; then
    log_install_start "Unison"
    if run_silent "sudo apt-get update && sudo apt-get install -y unison"; then
        log_install_done "Unison"
    else
        log_error "Échec de l'installation d'Unison"
        exit 1
    fi
else
    log_install_skip "Unison"
fi

# Configuration du PATH
if ! grep -q "$HOME/bin" "$HOME/.bashrc"; then
    log_pending "Configuration du PATH..."
    echo 'export PATH="$HOME/bin:$PATH"' >> "$HOME/.bashrc"
    echo 'export PATH="$HOME/bin:$PATH"' >> "$HOME/.zshrc"
    log_success "PATH mis à jour"
fi

log_done "Configuration terminée !"

log_section "Informations de l'environnement"
log_info "Pour synchroniser vos dossiers, utilisez la commande: unison dev-sync"
echo -e "\nVos dossiers de développement sont :"
log_version "Linux" "$DEV_DIR"
log_version "Windows" "$WINDOWS_DIR"

if command_exists unison; then
    log_version "Unison" "$(unison -version | head -n1 | cut -d' ' -f3)"
fi
