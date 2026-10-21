# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:$HOME/.local/bin:/usr/local/bin:$PATH
export PATH="$HOME/go/bin:$HOME/bin:$HOME/.local/bin:$PATH"

# You may need to manually set your language environment
export LANG=en_US.UTF-8

# Track shell nesting depth inside tmux; block Ctrl-D only at the outermost shell (depth 0).
if [[ -n "$TMUX" ]]; then
  if [[ -v HENNISS_TMUX_SHELL_DEPTH ]]; then
    (( HENNISS_TMUX_SHELL_DEPTH++ ))
  else
    HENNISS_TMUX_SHELL_DEPTH=0
  fi
  export HENNISS_TMUX_SHELL_DEPTH
  if [[ $HENNISS_TMUX_SHELL_DEPTH -eq 0 ]]; then
    set -o ignoreeof
    IGNOREEOF=9999
  fi
fi

# -R: RAW-CONTROL-CHARS: enables color
# -S: chop-long-lines
# -X: no-init (don't clear screen on exit)
# -i: --ignore-case (intelligently)
export LESS="-RSXi"

# Path to your Oh My Zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time Oh My Zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
ZSH_THEME="harrise"

# Set list of themes to pick from when loading at random
# Setting this variable when ZSH_THEME=random will cause zsh to load
# a theme from this variable instead of looking in $ZSH/themes/
# If set to an empty array, this variable will have no effect.
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
HYPHEN_INSENSITIVE="true"

# Uncomment one of the following lines to change the auto-update behavior
# zstyle ':omz:update' mode disabled  # disable automatic updates
# zstyle ':omz:update' mode auto      # update automatically without asking
# zstyle ':omz:update' mode reminder  # just remind me to update when it's time

# Uncomment the following line to change the frequency the auto-updater is run (in days).
# zstyle ':omz:update' frequency 13

# Uncomment the following line to set how old an update must be before it's applied, manually or via the auto-updater (in days).
# zstyle ':omz:update' cooldown 10

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS="true"

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# You can also set it to another string to have that shown instead of the default red dots.
# e.g. COMPLETION_WAITING_DOTS="%F{yellow}waiting...%f"
# Caution: this setting can cause issues with multiline prompts in zsh < 5.7.1 (see #5765)
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder
ZSH_CUSTOM="$HOME/.zsh-custom"

# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(git)
if [[ -d $ZSH/plugins/kube-ps1 ]] && command -v kubectl >/dev/null 2>&1; then plugins+=(kube-ps1); fi

source $ZSH/oh-my-zsh.sh

# User configuration

zmodload zsh/pcre
setopt rematchpcre
# Sanity check that PCRE is active in zsh `=~` (lookahead is PCRE-only):
#   [[ "foobar" =~ 'foo(?=bar)' ]] && echo active

export HISTSIZE=5000000
export SAVEHIST=5000000

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='nvim'
# fi
export EDITOR='vim'

# Compilation flags
# export ARCHFLAGS="-arch $(uname -m)"

# Set personal aliases, overriding those provided by Oh My Zsh libs,
# plugins, and themes. Aliases can be placed here, though Oh My Zsh
# users are encouraged to define aliases within a top-level file in
# the $ZSH_CUSTOM folder, with .zsh extension. Examples:
# - $ZSH_CUSTOM/aliases.zsh
# - $ZSH_CUSTOM/macos.zsh
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"
unsetopt autocd
# "The -f option freezes the tty (i.e. terminal or terminal emulator), and -u unfreezes it. When the tty is frozen, no changes made to the tty settings by external programs will be honored by the shell, except for changes in the size of the screen; the shell will simply reset the settings to their previous values as soon as each command exits or is suspended. "
{ ttyctl -f ; echo "tty frozen, \`ttyctl -u\` to unfreeze it." ; }

# ---------------------------------------------------------------------------
# Interactive-only dialect aliases
#
# These change the default regex dialect / behavior of core tools. They live
# here, at the very end of .zshrc (after oh-my-zsh.sh has sourced all custom
# functions and the theme), so they are parsed *after* everything else and can
# never bake into a function or the prompt. Functions that need a specific
# dialect call `command grep`, `_sed_i`, etc. explicitly.
# ---------------------------------------------------------------------------
if [[ -o interactive ]]; then
  # PCRE grep on the command line. GNU grep supports -P directly; on macOS use
  # Homebrew's ggrep (`brew install grep`). Stock BSD grep has no -P.
  if grep --version 2>/dev/null | command grep -q 'GNU grep'; then
    alias grep='grep -P'
  elif command -v ggrep >/dev/null 2>&1; then
    alias grep='ggrep -P'
  fi

  # rfc-3339 timestamps by default; needs GNU date (`brew install coreutils`).
  if date --version >/dev/null 2>&1 || command -v gdate >/dev/null 2>&1; then
    alias date="_date --rfc-3339=second"
  fi

  # ERE sed by default is DISABLED. Before enabling, note that interactive
  # sed-based aliases (e.g. reduce_to_modules) recursively pick up this alias and
  # would break their BRE \( \) capture groups. Enable only after auditing those.
  #alias sed='gsed -E'
fi

# ---------------------------------------------------------------------------
# nl2cmd: natural language -> shell command, into the edit buffer (not run)
#
# Type a plain-English description on the command line (e.g. "print all
# untracked files in this git repo"), press the binding, and an ephemeral
# `claude -p` call REPLACES the buffer with a single shell command. Nothing is
# executed -- you review it and press Enter yourself, exactly like editing a
# recalled history line.
#
# Tunables (override in the environment before this file, or after sourcing):
#   NL2CMD_KEY    key binding chord              (default: ^X^G  == Ctrl-X Ctrl-G)
#   NL2CMD_MODEL  model passed to `claude`       (default: haiku; try sonnet)
# ---------------------------------------------------------------------------
if [[ -o interactive ]] && command -v claude >/dev/null 2>&1; then
  : ${NL2CMD_KEY:='^X^G'}
  : ${NL2CMD_MODEL:=haiku}
  case "$OSTYPE" in
    darwin*) _nl2cmd_os=macOS ;;
    *)       _nl2cmd_os=Linux ;;
  esac
  NL2CMD_SYSTEM_PROMPT="Translate the user request into ONE shell command for zsh on ${_nl2cmd_os}. Output ONLY the command: no prose, no markdown fences, no backticks, no wrapping quotes. Never refuse; always emit your single best guess."
  unset _nl2cmd_os

  nl2cmd-widget() {
    emulate -L zsh
    local req=$BUFFER
    if [[ -z ${req//[[:space:]]/} ]]; then
      zle -M "nl2cmd: type a description first, then press the binding."
      return 0
    fi

    zle -M "nl2cmd: asking claude ($NL2CMD_MODEL)…"
    zle -R   # flush the message to screen before we block on the API call

    local out rc
    out=$(claude -p "$req" \
            --system-prompt "$NL2CMD_SYSTEM_PROMPT" \
            --model "$NL2CMD_MODEL" \
            --tools '' </dev/null 2>/dev/null)
    rc=$?

    # Defensive cleanup: drop CRs, fence lines (```/```lang) and blank lines,
    # then trim surrounding whitespace and a stray leading "$ " prompt.
    out=${out//$'\r'/}
    out=$(print -r -- "$out" | command sed -e '/^[[:space:]]*```/d' -e '/^[[:space:]]*$/d')
    out="${out#"${out%%[![:space:]]*}"}"   # ltrim
    out="${out%"${out##*[![:space:]]}"}"   # rtrim
    out=${out#\$ }

    if (( rc != 0 )) || [[ -z $out ]]; then
      zle -M "nl2cmd: no command produced (claude exit $rc) — buffer unchanged."
      return 0
    fi

    BUFFER=$out
    CURSOR=${#BUFFER}
    zle -M ""   # clear the status line
  }
  zle -N nl2cmd-widget
  bindkey "$NL2CMD_KEY" nl2cmd-widget
fi
