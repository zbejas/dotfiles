#!/bin/bash

SCRIPT_VERSION="1.0.5"

# Detect the operating system
if [ -f /etc/os-release ]; then
    . /etc/os-release
    OS=$NAME
    elif type lsb_release >/dev/null 2>&1; then
    OS=$(lsb_release -si)
else
    OS=$(uname -s)
fi

# Check if the operating system is Debian or Arch based
if [ "$OS" = "Debian GNU/Linux" ] || [ "$OS" = "Ubuntu" ]; then
    BASE_DISTRO="Debian"
    elif [ "$OS" = "Arch Linux" ] || [ "$OS" = "Manjaro Linux" ]; then
    BASE_DISTRO="Arch"
else
    echo "Unsupported operating system: $OS"
    
    echo "Please select the base distribution of the operating system (this affects the package manager):"
    echo "1. Debian"
    echo "2. Arch"
    echo "You can also quit the script by pressing Ctrl+C"
    read -p "Enter the number of the base distribution: " BASE_DISTRO_NUM
    
    if [ "$BASE_DISTRO_NUM" = "1" ]; then
        BASE_DISTRO="Debian"
        elif [ "$BASE_DISTRO_NUM" = "2" ]; then
        BASE_DISTRO="Arch"
    else
        echo "Invalid base distribution selected"
        exit 1
    fi
fi

function update_repos() {
    if [ "$BASE_DISTRO" == "Debian" ]; then
        sudo apt update
        elif [ "$BASE_DISTRO" == "Arch" ]; then
        sudo pacman -Sy
    fi
}

function install_packages() {
    if [ "$BASE_DISTRO" == "Debian" ]; then
        sudo apt install -y curl wget git grc zsh vim htop btop
        elif [ "$BASE_DISTRO" == "Arch" ]; then
        sudo pacman -S --noconfirm curl wget git grc zsh vim htop btop
    fi
}

function clone_dotfiles() {
    git clone https://github.com/zbejas/dotfiles.git ~/dotfiles
}

function force_clone_dotfiles() {
    rm -rf ~/dotfiles
    clone_dotfiles
}

function install_oh_my_zsh() {
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
}

function install_zsh_autosuggestions() {
    git clone https://github.com/zsh-users/zsh-autosuggestions ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions
}

function install_zsh_syntax_highlighting() {
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ~/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting
}

function download_ssh_key() {
    curl -sSfL https://github.com/zbejas.keys >> ~/.ssh/authorized_keys
}

function install_fzf() {
    if [ "$BASE_DISTRO" = "Debian" ]; then
        git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf && ~/.fzf/install
        elif [ "$BASE_DISTRO" = "Arch" ]; then
        sudo pacman -S --noconfirm fzf
    fi
}

function install_zoxide() {
    if [ "$BASE_DISTRO" = "Debian" ]; then
        curl -sSfL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh
        elif [ "$BASE_DISTRO" = "Arch" ]; then
        sudo pacman -S --noconfirm zoxide
    fi
}

function check_script_version() {
    LATEST_VERSION=$(curl -sSfL https://raw.githubusercontent.com/zbejas/dotfiles/master/install.sh | grep -o 'SCRIPT_VERSION=".*"' | cut -d'"' -f2 | head -n 1)
    INSTALLED_VERSION=$(cat ~/dotfiles/install.sh | grep -o 'SCRIPT_VERSION=".*"' | cut -d'"' -f2 | head -n 1)
    
    echo "Installed version: $INSTALLED_VERSION"
    echo "Latest version: $LATEST_VERSION"
    
    # return 0 if the versions are the same
    if [ "$INSTALLED_VERSION" = "$LATEST_VERSION" ]; then
        return 0
    else
        return 1
    fi
}

function last_patches() {
    if [ "$SHELL" != "/bin/zsh" ] && [ "$SHELL" != "/usr/bin/zsh" ]; then
        chsh -s $(which zsh)
    else
        echo "Shell is already set to Zsh"
    fi
    
    read -p "Do you want to overwrite the current .zshrc file? (y/N): " CHOICE
    
    if [ "$CHOICE" = "y" ] || [ "$CHOICE" = "Y" ]; then
        echo "Copying .zshrc..."
        cp ~/dotfiles/zsh/.zshrc ~/.zshrc
    else
        echo "Skipping .zshrc overwrite"
    fi
}

function check_if_installed() {
    if [ -d ~/dotfiles ]; then
        echo "Dotfiles are already cloned"
        if check_script_version; then
            return 0
        else
            echo "The script is outdated"
            force_clone_dotfiles
            
            echo "Dotfiles have been updated. Runnning the script..."
            
            read -p "Install now? (y/N): " CHOICE
            if [ "$CHOICE" = "y" ] || [ "$CHOICE" = "Y" ]; then
                bash ~/dotfiles/install.sh --skip-check
                exit 0
            else
                exit 0
            fi
        fi
    fi
}

# Script starts here
if [ "$1" = "--skip-check" ]; then
    echo "Skipping check..."
else
    check_if_installed
fi

echo "Updating repositories..."
update_repos

echo "Installing packages..."
install_packages

echo "Cloning dotfiles..."
clone_dotfiles

echo "Installing Oh My Zsh..."
# make sure the user exits the shell, check if they read by pressing enter
echo "!!!!!!!!!!!!!!!!!!!!!!!! IMPORTANT NOTE !!!!!!!!!!!!!!!!!!!!!!!!"
read -p "WARNING: Please exit the Zsh shell after installation by using the command 'exit'. Press Enter to continue..."
install_oh_my_zsh



echo "Installing Zsh plugins..."
install_zsh_autosuggestions
install_zsh_syntax_highlighting

echo "Installing FZF..."
install_fzf

echo "Installing Zoxide..."
install_zoxide

echo "Downloading SSH key..."
read -p "Do you want to download the SSH key? (y/N): " CHOICE
if [ "$CHOICE" = "y" ] || [ "$CHOICE" = "Y" ]; then
    download_ssh_key
else
    echo "Skipping SSH key download"
fi

echo "Running last patches..."
last_patches

echo "Setup complete!"
