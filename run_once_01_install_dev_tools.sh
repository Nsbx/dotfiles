#!/bin/bash

# run_once_01_install_dev_tools.sh
# =============================================================================
# Installation des outils de développement

# Charger les fonctions de logging
source ~/.utils/logging.sh

log_section "Installation des outils de développement"

# Mise à jour initiale
log_info "Mise à jour du système..."
run_silent "sudo apt-get update"

# Installation des dépendances nécessaires
log_info "Installation des dépendances système..."
run_silent "sudo apt-get install -y software-properties-common curl wget gnupg2" "Installation des dépendances"

# Ajout du PPA PHP
if ! grep -q "ondrej/php" /etc/apt/sources.list.d/*; then
    log_pending "Ajout du PPA Ondrej PHP..."
    if run_silent "sudo add-apt-repository -y ppa:ondrej/php && sudo apt-get update"; then
        log_success "PPA PHP ajouté avec succès"
    else
        log_error "Échec de l'ajout du PPA PHP"
        exit 1
    fi
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
    if run_silent "sudo apt-get install -y $package"; then
        log_install_done "$package"
    else
        log_error "Échec de l'installation de $package"
    fi
done

# Installation de Composer
if ! command_exists composer; then
    log_install_start "Composer"
    log_pending "Téléchargement du script d'installation..."
    
    EXPECTED_CHECKSUM="$(php -r 'copy("https://composer.github.io/installer.sig", "php://stdout");')"
    php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
    ACTUAL_CHECKSUM="$(php -r "echo hash_file('sha384', 'composer-setup.php');")"
    
    if [ "$EXPECTED_CHECKSUM" != "$ACTUAL_CHECKSUM" ]; then
        log_error "Échec de la vérification du checksum de Composer"
        rm composer-setup.php
        exit 1
    fi
    
    if run_silent "php composer-setup.php --quiet && sudo mv composer.phar /usr/local/bin/composer"; then
        rm composer-setup.php
        log_install_done "Composer"
    else
        log_error "Échec de l'installation de Composer"
        rm composer-setup.php
        exit 1
    fi
fi

# Installation de Symfony CLI
if ! command_exists symfony; then
    log_install_start "Symfony CLI"
    if run_silent "curl -sS https://get.symfony.com/cli/installer | bash && sudo mv ~/.symfony5/bin/symfony /usr/local/bin/symfony"; then
        log_install_done "Symfony CLI"
    else
        log_error "Échec de l'installation de Symfony CLI"
    fi
fi

# Installation de Node.js via NVM
if ! command_exists nvm; then
    log_install_start "NVM"
    if run_silent "curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash"; then
        # Charger NVM
        export NVM_DIR="$HOME/.nvm"
        [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
        
        # Ajouter NVM au shell si nécessaire
        if ! grep -q "NVM_DIR" "$HOME/.zshrc"; then
            log_info "Configuration de NVM dans .zshrc..."
            {
                echo 'export NVM_DIR="$HOME/.nvm"'
                echo '[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"'
                echo '[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"'
            } >> "$HOME/.zshrc"
        fi
        
        log_install_done "NVM"
        
        # Installer la dernière version LTS de Node.js
        log_install_start "Node.js LTS"
        if run_silent "nvm install --lts && nvm use --lts"; then
            log_install_done "Node.js LTS"
        else
            log_error "Échec de l'installation de Node.js"
        fi
    else
        log_error "Échec de l'installation de NVM"
    fi
fi

log_done "Installation des outils de développement terminée !"

# Afficher les versions installées
log_section "Versions installées"
if command_exists php; then
    log_version "PHP" "$(php -v 2>/dev/null | grep -Eo 'PHP [0-9]+\.[0-9]+\.[0-9]+' | head -1 | cut -d' ' -f2)"
fi

if command_exists composer; then
    log_version "Composer" "$(composer --version 2>/dev/null | grep -Eo '[0-9]+\.[0-9]+\.[0-9]+')"
fi

if command_exists symfony; then
    log_version "Symfony CLI" "$(symfony version --no-ansi 2>/dev/null | grep -Eo '[0-9]+\.[0-9]+\.[0-9]+')"
fi

if command_exists node; then
    log_version "Node.js" "$(node -v)"
fi

if command_exists npm; then
    log_version "NPM" "$(npm -v)"
fi
