ds(){screen -d -m "$@";}
space(){ds \emacs "$@";}


# Options passed to LESS
# ignore case when searching, quit if just one screen, disables init/deinit, something to do with color,
export LESS=-iFXR

# Something to do with ^M showing up instead of newline.
stty icrnl

# Enable VirtualEnvWrapper and set the needed variables.
export WORKON_HOME=$HOME/envs
export PROJECT_HOME=$HOME/gitlab
source /usr/bin/virtualenvwrapper.sh

# If you come from bash you might have to change your $PATH.
export PATH=$HOME/bin:$PATH

# something like this *should* work:
#http://unix.stackexchange.com/questions/15228/zsh-tab-completion-only-complete-files-and-not-binaries
#http://stackoverflow.com/questions/26618892/only-suggest-executables-and-not-directories-when-typing-dot-slash-in-zsh
#https://www.zsh.org/mla/users/2009/msg00410.html
zstyle ':completion:*:-command-:*' ignored-patterns '(#i)*.exe' '(#i)*.dll' '(#i)*.rtf'

# Path to your oh-my-zsh installation.
export ZSH=/home/henniss/.oh-my-zsh

# Set name of the theme to load. Optionally, if you set this to "random"
# it'll load a random theme each time that oh-my-zsh is loaded.
# See https://github.com/robbyrussell/oh-my-zsh/wiki/Themes
ZSH_THEME="robbyrussell"

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion. Case
# sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment the following line to disable bi-weekly auto-update checks.
# DISABLE_AUTO_UPDATE="true"

# Uncomment the following line to change how often to auto-update (in days).
# export UPDATE_ZSH_DAYS=13

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# The optional three formats: "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load? (plugins can be found in ~/.oh-my-zsh/plugins/*)
# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(git colored-man-pages gitignore pip)

source $ZSH/oh-my-zsh.sh

hash -d win=/cygdrive/c/Users/henniss/
hash -d vs="/cygdrive/c/Users/henniss/Documents/Visual Studio 2015"

# User configuration

unsetopt AUTO_CD

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='mvim'
# fi

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

# ssh
# export SSH_KEY_PATH="~/.ssh/rsa_id"

# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"

alias fix="\emacs -Q -nw"
alias emacs="fix"
alias config='/usr/bin/git --git-dir=$HOME/.cfg/ --work-tree=$HOME'