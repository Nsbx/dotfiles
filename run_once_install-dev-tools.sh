#!/bin/bash

# Couleurs et styles
BLUE='\033[0;34m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'
BOLD='\033[1m'

echo -e "\n${BOLD}🚀 Installation des outils de développement...${NC}\n"

# Fonction pour vérifier si une commande existe
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Mise à jour initiale
echo -e "🔄 ${YELLOW}Mise à jour du système...${NC}"
sudo apt-get update >/dev/null 2>&1

# Installation des dépendances nécessaires
echo -e "📦 ${YELLOW}Installation des dépendances...${NC}"
sudo apt-get install -y software-properties-common curl wget gnupg2 >/dev/null 2>&1

# Ajout du PPA PHP
if ! grep -q "ondrej/php" /etc/apt/sources.list.d/*; then
    echo -e "🔧 ${YELLOW}Ajout du PPA Ondrej PHP...${NC}"
    sudo add-apt-repository -y ppa:ondrej/php >/dev/null 2>&1
    sudo apt-get update >/dev/null 2>&1
fi

# Installation de PHP et extensions communes
echo -e "🐘 ${YELLOW}Installation de PHP et extensions...${NC}"
sudo apt-get install -y php8.2 php8.2-cli php8.2-common php8.2-curl php8.2-mbstring \
    php8.2-xml php8.2-zip php8.2-bcmath php8.2-intl php8.2-mysql php8.2-sqlite3 >/dev/null 2>&1

# Installation de Composer
if ! command_exists composer; then
    echo -e "🎼 ${YELLOW}Installation de Composer...${NC}"
    EXPECTED_CHECKSUM="$(php -r 'copy("https://composer.github.io/installer.sig", "php://stdout");')"
    php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
    ACTUAL_CHECKSUM="$(php -r "echo hash_file('sha384', 'composer-setup.php');")"
    
    if [ "$EXPECTED_CHECKSUM" != "$ACTUAL_CHECKSUM" ]; then
        echo -e "❌ ${RED}Échec de la vérification du checksum de Composer${NC}"
        rm composer-setup.php
        exit 1
    fi
    
    php composer-setup.php --quiet
    rm composer-setup.php
    sudo mv composer.phar /usr/local/bin/composer
fi

# Installation de Symfony CLI
if ! command_exists symfony; then
    echo -e "🎵 ${YELLOW}Installation de Symfony CLI...${NC}"
    curl -sS https://get.symfony.com/cli/installer | bash >/dev/null 2>&1
    # Déplacer le binaire symfony dans un répertoire global
    sudo mv ~/.symfony5/bin/symfony /usr/local/bin/symfony
fi

# Installation de Node.js via NVM
if ! command_exists nvm; then
    echo -e "📦 ${YELLOW}Installation de NVM...${NC}"
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash >/dev/null 2>&1
    
    # Charger NVM
    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
    
    # Ajouter NVM au shell
    if ! grep -q "NVM_DIR" "$HOME/.zshrc"; then
        echo 'export NVM_DIR="$HOME/.nvm"' >> "$HOME/.zshrc"
        echo '[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"' >> "$HOME/.zshrc"
        echo '[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"' >> "$HOME/.zshrc"
    fi
    
    # Installer la dernière version LTS de Node.js
    echo -e "⬢ ${YELLOW}Installation de Node.js LTS...${NC}"
    nvm install --lts >/dev/null 2>&1
    nvm use --lts >/dev/null 2>&1
fi

echo -e "\n✨ ${GREEN}Installation terminée !${NC} 🎉\n"

# Afficher les versions installées
echo -e "${BOLD}Versions installées :${NC}"
echo -e "PHP: $(php -v | grep -Eo 'PHP [0-9]+\.[0-9]+\.[0-9]+' | head -1)"
echo -e "Composer: $(composer --version | grep -Eo '[0-9]+\.[0-9]+\.[0-9]+')"
echo -e "Symfony CLI: $(symfony version | grep -Eo '[0-9]+\.[0-9]+\.[0-9]+')"
echo -e "Node.js: $(node -v)"
echo -e "NPM: $(npm -v)"

