
EXIT_STATUS_ERROR="%(?:%{$fg_bold[green]%}%1{>%} :%{$fg_bold[red]%}%1{>%} )"

CYAN_LAST_PATH_COMPONENT="%{$fg[cyan]%}%c%{$reset_color%}"

ZSH_THEME_GIT_PROMPT_PREFIX="%{$fg_bold[blue]%}git:(%{$fg[red]%}"
ZSH_THEME_GIT_PROMPT_SUFFIX="%{$reset_color%} "
ZSH_THEME_GIT_PROMPT_DIRTY="%{$fg[blue]%}) %{$fg[yellow]%}%1{✗%}"
ZSH_THEME_GIT_PROMPT_CLEAN="%{$fg[blue]%})"

PROMPT="$EXIT_STATUS_ERROR $CYAN_LAST_PATH_COMPONENT"' $(git_prompt_info)'
