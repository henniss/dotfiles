# TARGET=$(mktemp -d)
TARGET="$HOME"
git config core.worktree "${TARGET}"
git config status.showUntrackedFiles no
git reset --hard
