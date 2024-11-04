#!/bin/bash

# run_once_02_install_docker.sh
# =============================================================================
# Installation et configuration de Docker

# Charger les fonctions de logging
source ~/.utils/logging.sh

log_section "Installation de Docker"

# Installation des prérequis
log_info "Installation des prérequis..."
run_silent "sudo apt-get update && sudo apt-get install -y ca-certificates curl gnupg"

# Ajout de la clé GPG officielle de Docker
log_pending "Ajout de la clé GPG Docker..."
run_silent "sudo install -m 0755 -d /etc/apt/keyrings"
if run_silent "curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg"; then
    run_silent "sudo chmod a+r /etc/apt/keyrings/docker.gpg"
    log_success "Clé GPG Docker ajoutée"
else
    log_error "Échec de l'ajout de la clé GPG Docker"
    exit 1
fi

# Ajout du repository Docker
log_pending "Configuration du repository Docker..."
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Installation de Docker
log_install_start "Docker et ses composants"
if run_silent "sudo apt-get update && sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin"; then
    log_install_done "Docker et ses composants"
else
    log_error "Échec de l'installation de Docker"
    exit 1
fi

# Configuration des permissions
log_pending "Configuration des permissions utilisateur..."
run_silent "sudo groupadd -f docker"
run_silent "sudo usermod -aG docker $USER"
run_silent "sudo chown root:docker /var/run/docker.sock"

# Configuration du démarrage automatique
log_pending "Configuration du démarrage automatique..."
DOCKER_START_CMD='\n# Démarrage automatique de Docker
if ! service docker status >/dev/null 2>&1; then
    sudo service docker start &>/dev/null
fi'

# Liste des fichiers de profil à vérifier
PROFILE_FILES=("$HOME/.bashrc" "$HOME/.zshrc" "$HOME/.profile" "$HOME/.bash_profile")

# Ajouter la commande de démarrage dans chaque fichier de profil
for profile_file in "${PROFILE_FILES[@]}"; do
    if [ -f "$profile_file" ] && ! grep -q "service docker start" "$profile_file"; then
        log_info "Ajout du démarrage automatique dans $(basename $profile_file)"
        echo -e "$DOCKER_START_CMD" >> "$profile_file"
    fi
done

# Redémarrage et application des permissions
log_pending "Application des permissions..."
run_silent "sudo service docker restart"
run_silent "sudo chmod 666 /var/run/docker.sock"

log_done "Installation de Docker terminée !"

# Afficher les versions installées
log_section "Versions installées"
if command_exists docker; then
    log_version "Docker" "$(docker --version | cut -d' ' -f3 | tr -d ',')"
    log_version "Docker Compose" "$(docker compose version --short)"
fi

# Test de Docker
if docker ps >/dev/null 2>&1; then
    log_success "Docker est fonctionnel !"
else
    log_warning "Si Docker ne fonctionne pas, exécutez : wsl --shutdown"
fi
