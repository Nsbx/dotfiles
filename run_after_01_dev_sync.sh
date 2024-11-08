#!/bin/bash

# run_after_01_dev-sync.sh
# =============================================================================
# Script de synchronisation des dossiers de développement

# Charger les fonctions de logging
source ~/.utils/logging.sh

log_section "Synchronisation des dossiers de développement"

# Vérifier que unison est installé
if ! command_exists unison; then
    log_error "Unison n'est pas installé"
    log_info "Exécutez d'abord le script de configuration de l'environnement"
    exit 1
fi

# Vérifier que le profil existe
if [ ! -f ~/.unison/dev-sync.prf ]; then
    log_error "Le profil Unison 'dev-sync' n'existe pas"
    exit 1
fi

# Lancer la synchronisation
log_pending "Synchronisation en cours..."

if output=$(unison dev-sync -auto -batch 2>&1); then
    log_done "Synchronisation terminée avec succès"
else
    # En cas d'erreur, afficher les détails de manière formatée
    log_error "Erreur lors de la synchronisation"
    echo "$output" | while read -r line; do
        [[ -n "$line" ]] && log_error "  $line"
    done
    exit 1
fi
