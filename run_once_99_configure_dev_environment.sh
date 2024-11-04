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
run_silent "mkdir -p '$DEV_DIR'" \
    "Dossier dev créé dans $DEV_DIR" \
    "Échec de la création du dossier dev"

# Créer le dossier Windows
run_silent "mkdir -p '$WINDOWS_DIR'" \
    "Dossier Windows créé dans $WINDOWS_DIR" \
    "Échec de la création du dossier Windows"

# Installer unison si nécessaire
if ! command_exists unison; then
    log_install_start "Unison"
    run_silent "sudo apt-get update && sudo apt-get install -y unison" \
        "Unison installé avec succès" \
        "Échec de l'installation d'Unison"
else
    log_install_skip "Unison"
fi

# Ajouter le script au PATH
for shell_rc in "$HOME/.bashrc" "$HOME/.zshrc"; do
    if [ -f "$shell_rc" ] && ! grep -q "$HOME/bin" "$shell_rc"; then
        echo 'export PATH="$HOME/bin:$PATH"' >> "$shell_rc"
        log_success "PATH mis à jour dans $(basename $shell_rc)"
    fi
done

log_done "Configuration terminée !"

# Afficher les informations de configuration
log_section "Informations de configuration"
echo -e "\nPour synchroniser vos dossiers, utilisez la commande : unison dev-sync"
echo -e "\nVos dossiers de développement sont :"
log_version "Linux" "$DEV_DIR"
log_version "Windows" "$WINDOWS_DIR"

if command_exists unison; then
    log_version "Unison" "$(unison -version | head -n1 | cut -d' ' -f3)"
fi
