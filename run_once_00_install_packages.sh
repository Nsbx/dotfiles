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
        run_silent "sudo apt-get install -y $pkg" \
            "$pkg installé avec succès" \
            "Échec de l'installation de $pkg"
    else
        log_install_skip "$pkg"
    fi
}

# Mettre à jour les dépôts
log_info "Mise à jour de la liste des paquets..."
run_silent "sudo apt-get update" \
    "Dépôts mis à jour" \
    "Échec de la mise à jour des dépôts"

# Installer les packages de base
for pkg in curl neofetch git htop; do
    install_pkg "$pkg"
done

###> ZSH ###
log_section "Configuration de l'environnement ZSH"
install_pkg "zsh"

# Configuration de zsh-autosuggestions
if [ ! -d ~/.zsh/zsh-autosuggestions ]; then
    log_install_start "zsh-autosuggestions"
    run_silent "git clone -q https://github.com/zsh-users/zsh-autosuggestions ~/.zsh/zsh-autosuggestions" \
        "zsh-autosuggestions installé avec succès" \
        "Échec de l'installation de zsh-autosuggestions"
else
    log_install_skip "zsh-autosuggestions"
fi

# Installation de Starship
if ! command_exists starship; then
    log_install_start "Starship prompt"
    run_silent "curl -sS https://starship.rs/install.sh | sh -s -- -y" \
        "Starship prompt installé avec succès" \
        "Échec de l'installation de Starship prompt"
else
    log_install_skip "Starship prompt"
fi

# Définir zsh comme shell par défaut
if [ "$SHELL" != "/usr/bin/zsh" ]; then
    log_pending "Configuration de ZSH comme shell par défaut"
    run_silent "sudo chsh -s $(which zsh) $USER" \
        "ZSH est maintenant votre shell par défaut" \
        "Échec du changement de shell par défaut"
    
    if ! grep -q "exec zsh" ~/.bashrc; then
        echo -e "\n# Launch Zsh\nif [ -t 1 ]; then\n  exec zsh\nfi" >> ~/.bashrc
        log_success "Configuration bashrc mise à jour"
    fi
fi

# S'assurer que zsh est listé dans /etc/shells
if ! grep -q "$(which zsh)" /etc/shells; then
    run_silent "command -v zsh | sudo tee -a /etc/shells" \
        "ZSH ajouté à /etc/shells" \
        "Erreur lors de l'ajout de ZSH à /etc/shells"
fi

log_done "Installation terminée avec succès !"

# Afficher les versions installées
log_section "Versions installées"
command_exists git && log_version "Git" "$(git --version | cut -d' ' -f3)"
command_exists zsh && log_version "ZSH" "$(zsh --version | cut -d' ' -f2)"
command_exists starship && log_version "Starship" "$(starship --version | cut -d' ' -f2)"
