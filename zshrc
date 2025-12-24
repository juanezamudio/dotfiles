autoload -Uz compinit && compinit

# ====================
# Source custom config
# ====================
source ~/.zsh/exports.zsh
source ~/.zsh/aliases.zsh
source ~/.zsh/functions.zsh

# ====================
# Tool initializers
# ====================

# Google Cloud SDK
if [ -f '/Users/jzamudio/Downloads/google-cloud-sdk/path.zsh.inc' ]; then . '/Users/jzamudio/Downloads/google-cloud-sdk/path.zsh.inc'; fi
if [ -f '/Users/jzamudio/Downloads/google-cloud-sdk/completion.zsh.inc' ]; then . '/Users/jzamudio/Downloads/google-cloud-sdk/completion.zsh.inc'; fi

# NVM
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

# Envman
[ -s "$HOME/.config/envman/load.sh" ] && source "$HOME/.config/envman/load.sh"

# SDKMAN - must be at the end
export SDKMAN_DIR="$HOME/.sdkman"
[[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"
