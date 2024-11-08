#!/bin/bash

# dot_utils/logging.sh
# =============================================================================
# Fonctions de logging uniformisées pour les scripts d'installation

# Déclaration des tableaux associatifs
declare -A LOG_COLORS
declare -A LOG_ICONS

# Couleurs et styles
LOG_COLORS=(
    [default]="\033[0m"      # Pas de couleur
    [black]="\033[0;30m"     # Noir
    [red]="\033[0;31m"       # Rouge
    [green]="\033[0;32m"     # Vert
    [yellow]="\033[0;33m"    # Jaune
    [blue]="\033[0;34m"      # Bleu
    [purple]="\033[0;35m"    # Violet
    [cyan]="\033[0;36m"      # Cyan
    [white]="\033[0;37m"     # Blanc
    [bold]="\033[1m"         # Gras
    [dim]="\033[2m"          # Diminué
    [underline]="\033[4m"    # Souligné
)

# Emojis pour les différents types de messages
LOG_ICONS=(
    [info]="ℹ️"             # Information générale
    [success]="✅"          # Succès
    [warning]="⚠️"         # Avertissement
    [error]="❌"           # Erreur
    [pending]="⏳"         # En cours
    [done]="🎉"           # Terminé
    [setup]="🔧"          # Configuration
    [install]="📦"         # Installation
    [update]="🔄"         # Mise à jour
    [config]="⚙️"         # Configuration
    [docker]="🐋"         # Docker
    [database]="🗄️"       # Base de données
    [security]="🔒"        # Sécurité
    [network]="🌐"         # Réseau
    [folder]="📁"         # Dossier
    [file]="📄"           # Fichier
    [php]="🐘"           # PHP
    [node]="⬢"           # Node.js
    [git]="🔱"           # Git
)

# Fonction de log principale
log() {
    local level=$1
    local message=$2
    local color=${3:-default}
    local icon=${LOG_ICONS[$level]:-"ℹ️"}
    
    echo -e "${LOG_COLORS[$color]}${icon} ${message}${LOG_COLORS[default]}"
}

# Wrapper pour les différents niveaux de log
log_info() {
    log "info" "$1" "blue"
}

log_success() {
    log "success" "$1" "green"
}

log_warning() {
    log "warning" "$1" "yellow"
}

log_error() {
    log "error" "$1" "red"
}

log_pending() {
    log "pending" "$1" "cyan"
}

log_done() {
    log "done" "$1" "green"
}

# Fonctions spécifiques pour les installations
log_install_start() {
    log "install" "Installation de $1..." "blue"
}

log_install_done() {
    log "success" "$1 installé avec succès" "green"
}

log_install_skip() {
    log "info" "$1 est déjà installé" "dim"
}

# Fonction pour afficher une section
log_section() {
    echo -e "\n${LOG_COLORS[bold]}${LOG_ICONS[setup]} $1${LOG_COLORS[default]}\n"
}

# Fonction pour les opérations silencieuses avec gestion des logs
run_silent() {
    local command=$1
    local success_msg=${2:-"Opération réussie"}
    local error_msg=${3:-"Une erreur est survenue"}
    
    if eval "$command" >/dev/null 2>&1; then
        log_success "$success_msg"
        return 0
    else
        log_error "$error_msg"
        return 1
    fi
}

# Fonction pour vérifier si une commande existe
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Fonction pour afficher les versions installées
log_version() {
    local tool=$1
    local version=$2
    echo -e "${LOG_COLORS[dim]}$tool:${LOG_COLORS[default]} $version"
}
