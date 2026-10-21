# Install oh-my-zsh if it's missing. Customizations live in ~/.zsh-custom
# (ZSH_CUSTOM), outside ~/.oh-my-zsh, so this doesn't clash with the checkout.
# KEEP_ZSHRC stops the installer from replacing the tracked .zshrc.
if [ ! -d "$HOME/.oh-my-zsh" ]; then
  KEEP_ZSHRC=yes RUNZSH=no sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
fi

# TARGET=$(mktemp -d)
TARGET="$HOME"
git config core.worktree "${TARGET}"
git config status.showUntrackedFiles no
git reset --hard
