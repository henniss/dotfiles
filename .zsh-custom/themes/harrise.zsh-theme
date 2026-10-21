
# %(?:X:Y) Ternary expression on the exit status of the last command
EXIT_STATUS_ERROR="%(?:%{$fg_bold[green]%}%1{>%} :%{$fg_bold[red]%}%1{>%} )"

# %c: trailing component of the current working directory
CYAN_LAST_PATH_COMPONENT="%{$fg[cyan]%}%c%{$reset_color%}"

# Provide a short override for laptops.
if [[ "$HOST" =~ (.*-MacBook-Pro.local|.*-MBP.localdomain) ]] ; then HOST_OVERRIDE=MB; fi
LEADING_HOST="%{$fg[green]%}${HOST_OVERRIDE:-$HOST}%{$reset_color%}"

if [[ -d $ZSH/plugins/kube-ps1 ]] && (( ${plugins[(Ie)kube-ps1]} )) ; then KUBE_PS1='$(kube_ps1) '; fi

ZSH_THEME_GIT_PROMPT_PREFIX="%{$fg_bold[blue]%}git:(%{$fg[red]%}"
ZSH_THEME_GIT_PROMPT_SUFFIX="%{$reset_color%} "
ZSH_THEME_GIT_PROMPT_DIRTY="%{$fg[blue]%}) %{$fg[yellow]%}%1{✗%}"
ZSH_THEME_GIT_PROMPT_CLEAN="%{$fg[blue]%})"

_tmux_depth_prompt() {
  [[ -v HENNISS_TMUX_SHELL_DEPTH ]] || return
  print -n "%{$fg[yellow]%}[${HENNISS_TMUX_SHELL_DEPTH}]%{$reset_color%}"
}

PROMPT="$LEADING_HOST ${KUBE_PS1:-}$EXIT_STATUS_ERROR $CYAN_LAST_PATH_COMPONENT"' $(_tmux_depth_prompt) $(git_prompt_info)'
