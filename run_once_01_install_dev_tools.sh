#!/bin/bash

# run_once_01_install_dev_tools.sh
# =============================================================================
# Installation des outils de développement

# Charger les fonctions de logging
source ~/.utils/logging.sh

log_section "Installation des outils de développement"

# Mise à jour initiale
run_silent "sudo apt-get update" \
    "Dépôts mis à jour" \
    "Échec de la mise à jour des dépôts"

# Installation des dépendances nécessaires
run_silent "sudo apt-get install -y software-properties-common curl wget gnupg2" \
    "Dépendances système installées" \
    "Échec de l'installation des dépendances système"

# Ajout du PPA PHP
if ! grep -q "ondrej/php" /etc/apt/sources.list.d/*; then
    log_pending "Configuration du repository PHP..."
    run_silent "sudo add-apt-repository -y ppa:ondrej/php && sudo apt-get update" \
        "Repository PHP ajouté avec succès" \
        "Échec de l'ajout du repository PHP"
fi

# Installation de PHP et extensions
log_section "Installation de PHP et extensions"

PHP_PACKAGES=(
    "php8.2"
    "php8.2-cli"
    "php8.2-common"
    "php8.2-curl"
    "php8.2-mbstring"
    "php8.2-xml"
    "php8.2-zip"
    "php8.2-bcmath"
    "php8.2-intl"
    "php8.2-mysql"
    "php8.2-sqlite3"
)

for package in "${PHP_PACKAGES[@]}"; do
    log_install_start "$package"
    run_silent "sudo apt-get install -y $package" \
        "$package installé avec succès" \
        "Échec de l'installation de $package"
done

# Installation de Composer
if ! command_exists composer; then
    log_install_start "Composer"
    
    # Téléchargement et vérification
    EXPECTED_CHECKSUM="$(php -r 'copy("https://composer.github.io/installer.sig", "php://stdout");')"
    php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
    ACTUAL_CHECKSUM="$(php -r "echo hash_file('sha384', 'composer-setup.php');")"
    
    if [ "$EXPECTED_CHECKSUM" != "$ACTUAL_CHECKSUM" ]; then
        log_error "Vérification du checksum Composer échouée"
        rm composer-setup.php
        exit 1
    fi
    
    run_silent "php composer-setup.php --quiet && sudo mv composer.phar /usr/local/bin/composer" \
        "Composer installé avec succès" \
        "Échec de l'installation de Composer"
    rm composer-setup.php
fi

# Installation de Symfony CLI
if ! command_exists symfony; then
    log_install_start "Symfony CLI"
    run_silent "curl -sS https://get.symfony.com/cli/installer | bash && sudo mv ~/.symfony5/bin/symfony /usr/local/bin/symfony" \
        "Symfony CLI installé avec succès" \
        "Échec de l'installation de Symfony CLI"
fi

# Installation de Node.js via NVM
if ! command_exists nvm; then
    log_install_start "NVM"
    run_silent "curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash" \
        "NVM installé avec succès" \
        "Échec de l'installation de NVM"
    
    # Charger NVM
    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
    
    # Configuration de NVM dans zshrc
    if ! grep -q "NVM_DIR" "$HOME/.zshrc"; then
        {
            echo 'export NVM_DIR="$HOME/.nvm"'
            echo '[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"'
            echo '[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"'
        } >> "$HOME/.zshrc"
        log_success "Configuration NVM ajoutée à .zshrc"
    fi
    
    # Installation de Node.js LTS
    log_install_start "Node.js LTS"
    run_silent "nvm install --lts && nvm use --lts" \
        "Node.js LTS installé avec succès" \
        "Échec de l'installation de Node.js"
fi

log_done "Installation des outils de développement terminée !"

# Afficher les versions installées
log_section "Versions installées"
command_exists php && log_version "PHP" "$(php -v 2>/dev/null | grep -Eo 'PHP [0-9]+\.[0-9]+\.[0-9]+' | head -1 | cut -d' ' -f2)"
command_exists composer && log_version "Composer" "$(composer --version 2>/dev/null | grep -Eo '[0-9]+\.[0-9]+\.[0-9]+')"
command_exists symfony && log_version "Symfony CLI" "$(symfony version --no-ansi 2>/dev/null | grep -Eo '[0-9]+\.[0-9]+\.[0-9]+')"
command_exists node && log_version "Node.js" "$(node -v)"
command_exists npm && log_version "NPM" "$(npm -v)"
