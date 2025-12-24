#!/bin/bash
# Dotfiles install script
# Creates symlinks from ~ to this directory

DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "Installing dotfiles from $DOTFILES_DIR"

# Create symlinks
ln -sf "$DOTFILES_DIR/zshrc" ~/.zshrc
ln -sf "$DOTFILES_DIR/zsh" ~/.zsh

echo "Done! Restart your terminal or run: source ~/.zshrc"
