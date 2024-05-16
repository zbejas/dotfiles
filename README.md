
# My Dotfiles

This repository contains my personal dotfiles that I use to customize my console experience and other settings.

**WARNING:** The install script adds my ssh key to your authorized keys. If you don't want that, you can remove the line from the script, or edit the `authorized_keys` file after the script has run.

## Installation

  Run the following command in your terminal:

  ```bash
  bash -c "$(curl -fsSL https://raw.githubusercontent.com/zbejas/dotfiles/master/install.sh)"
  ```

  This will clone the repository to `~/.dotfiles` and run the install script.
