#!/bin/bash
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
        sudo apt install -y curl wget git zsh vim htop
        elif [ "$BASE_DISTRO" == "Arch" ]; then
        sudo pacman -S --noconfirm curl wget git zsh vim htop
    fi
}

function clone_dotfiles() {
    git clone https://github.com/zbejas/dotfiles.git ~/dotfiles
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
    curl -sSfL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh
}

function last_patches() {
    # Change shell
    if [ "$SHELL" != "/bin/zsh" ]; then
        chsh -s $(which zsh)
    fi
    
    # Copy .zshrc from dotfiles (overwrites existing .zshrc)
    cp dotfiles/zsh/.zshrc ~/.zshrc
}

echo "Updating repositories..."
update_repos

echo "Installing packages..."
install_packages

echo "Cloning dotfiles..."
clone_dotfiles

echo "Installing Oh My Zsh..."
install_oh_my_zsh

echo "Installing Zsh plugins..."
install_zsh_autosuggestions
install_zsh_syntax_highlighting

echo "Installing FZF..."
install_fzf

echo "Installing Zoxide..."
install_zoxide

echo "Downloading SSH key..."
download_ssh_key

echo "Running last patches..."
last_patches

echo "Setup complete!"
