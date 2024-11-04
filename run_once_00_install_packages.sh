#!/bin/bash

# run_once_00_install_packages.sh
# =============================================================================
# Installation des packages de base

# Charger les fonctions de logging
source ~/.utils/logging.sh

log_section "Installation des dépendances"

# Fonction d'installation de package
install_pkg() {
    local pkg=$1
    if ! dpkg-query -W -f='${Status}' "$pkg" 2>/dev/null | grep -q "installed"; then
        log_install_start "$pkg"
        if run_silent "sudo apt-get install -y $pkg"; then
            log_install_done "$pkg"
        else
            log_error "Échec de l'installation de $pkg"
            return 1
        fi
    else
        log_install_skip "$pkg"
    fi
}

# Mettre à jour les dépôts
log_info "Mise à jour de la liste des paquets..."
run_silent "sudo apt-get update" "Mise à jour des dépôts"

# Installer les packages de base
log_section "Installation des paquets de base"
for pkg in curl neofetch git htop; do
    install_pkg "$pkg"
done

###> ZSH ###
log_section "Configuration de l'environnement ZSH"
install_pkg "zsh"

# Configuration de zsh-autosuggestions
if [ ! -d ~/.zsh/zsh-autosuggestions ]; then
    log_install_start "zsh-autosuggestions"
    if run_silent "git clone -q https://github.com/zsh-users/zsh-autosuggestions ~/.zsh/zsh-autosuggestions"; then
        log_install_done "zsh-autosuggestions"
    else
        log_error "Échec de l'installation de zsh-autosuggestions"
    fi
else
    log_install_skip "zsh-autosuggestions"
fi

# Installation de Starship
if ! command_exists starship; then
    log_install_start "Starship prompt"
    if run_silent "curl -sS https://starship.rs/install.sh | sh -s -- -y"; then
        log_install_done "Starship prompt"
    else
        log_error "Échec de l'installation de Starship"
    fi
else
    log_install_skip "Starship prompt"
fi

# Définir zsh comme shell par défaut
if [ "$SHELL" != "/usr/bin/zsh" ]; then
    log_pending "Configuration de ZSH comme shell par défaut"
    if run_silent "sudo chsh -s $(which zsh) $USER"; then
        log_success "ZSH est maintenant votre shell par défaut"
    else
        log_error "Échec du changement de shell par défaut"
    fi
fi

log_done "Installation terminée avec succès !"

# Afficher les versions installées
log_section "Versions installées"
command_exists git && log_version "Git" "$(git --version | cut -d' ' -f3)"
command_exists zsh && log_version "ZSH" "$(zsh --version | cut -d' ' -f2)"
command_exists starship && log_version "Starship" "$(starship --version | cut -d' ' -f2)"
