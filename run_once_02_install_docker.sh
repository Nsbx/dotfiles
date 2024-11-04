#!/bin/bash

# run_once_02_install_docker.sh
# =============================================================================
# Installation et configuration de Docker

# Charger les fonctions de logging
source ~/.utils/logging.sh

log_section "Installation de Docker"

# Installation des prérequis
run_silent "sudo apt-get update && sudo apt-get install -y ca-certificates curl gnupg" \
    "Prérequis installés" \
    "Échec de l'installation des prérequis"

# Configuration du repository Docker
log_pending "Configuration du repository Docker..."
run_silent "sudo install -m 0755 -d /etc/apt/keyrings" \
    "Dossier keyrings créé" \
    "Échec de la création du dossier keyrings"

run_silent "curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg" \
    "Clé GPG Docker ajoutée" \
    "Échec de l'ajout de la clé GPG Docker"

run_silent "sudo chmod a+r /etc/apt/keyrings/docker.gpg" \
    "Permissions de la clé GPG mises à jour" \
    "Échec de la mise à jour des permissions de la clé GPG"

# Ajout du repository Docker
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Installation de Docker
run_silent "sudo apt-get update" \
    "Repository Docker mis à jour" \
    "Échec de la mise à jour du repository Docker"

run_silent "sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin" \
    "Docker installé avec succès" \
    "Échec de l'installation de Docker"

# Configuration des permissions
run_silent "sudo groupadd -f docker" \
    "Groupe docker créé" \
    "Échec de la création du groupe docker"

run_silent "sudo usermod -aG docker $USER" \
    "Utilisateur ajouté au groupe docker" \
    "Échec de l'ajout de l'utilisateur au groupe docker"

run_silent "sudo chown root:docker /var/run/docker.sock" \
    "Permissions docker.sock mises à jour" \
    "Échec de la mise à jour des permissions docker.sock"

# Configuration du démarrage automatique
DOCKER_START_CMD='\n# Démarrage automatique de Docker
if ! service docker status >/dev/null 2>&1; then
    sudo service docker start &>/dev/null
fi'

# Ajout aux fichiers de profil
for profile_file in "$HOME/.bashrc" "$HOME/.zshrc" "$HOME/.profile" "$HOME/.bash_profile"; do
    if [ -f "$profile_file" ] && ! grep -q "service docker start" "$profile_file"; then
        echo -e "$DOCKER_START_CMD" >> "$profile_file"
        log_success "Démarrage automatique ajouté à $(basename $profile_file)"
    fi
done

# Application des permissions
run_silent "sudo service docker restart" \
    "Service Docker redémarré" \
    "Échec du redémarrage de Docker"

run_silent "sudo chmod 666 /var/run/docker.sock" \
    "Permissions docker.sock mises à jour" \
    "Échec de la mise à jour des permissions docker.sock"

log_done "Installation de Docker terminée !"

# Afficher les versions installées
log_section "Versions installées"
if command_exists docker; then
    log_version "Docker" "$(docker --version | cut -d' ' -f3 | tr -d ',')"
    log_version "Docker Compose" "$(docker compose version --short)"
    
    if docker ps >/dev/null 2>&1; then
        log_success "Docker est fonctionnel !"
    else
        log_warning "Si Docker ne fonctionne pas, exécutez : wsl --shutdown"
    fi
fi
