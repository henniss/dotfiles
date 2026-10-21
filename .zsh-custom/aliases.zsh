# Loaded automatically by oh-my-zsh (ZSH_CUSTOM=~/.zsh-custom), in alphabetical
# order, after its built-in lib/ so these override them.

# ---------------------------------------------------------------------------
# Portable wrappers: prefer GNU tools (Homebrew g-prefixed on macOS) when present
# ---------------------------------------------------------------------------
if command -v gdate >/dev/null 2>&1; then
  _date() { gdate "$@"; }
else
  _date() { date "$@"; }
fi

if sed --version >/dev/null 2>&1; then
  _sed_i() { sed -i "$@"; }
else
  _sed_i() { sed -i '' "$@"; }
fi

# GNU-preferring grep (ggrep on macOS) for functions that need GNU-only features
# like -z or -P, and to stay immune to the interactive `grep` alias.
if command -v ggrep >/dev/null 2>&1; then
  _grep() { ggrep "$@"; }
else
  _grep() { command grep "$@"; }
fi

# Ergonomic ERE sed (GNU gsed on macOS) without shadowing `sed`.
if command -v gsed >/dev/null 2>&1; then
  esed() { gsed -E "$@"; }
else
  esed() { sed -E "$@"; }
fi

# Dialect-changing aliases (grep -P, sed -E, the `date` shadow) intentionally live
# at the end of ~/.zshrc as interactive-only aliases, so they never bake into the
# functions/theme sourced here. See the "interactive-only dialect aliases" block.

# ---------------------------------------------------------------------------
# General
# ---------------------------------------------------------------------------
alias yclip='pbcopy'
alias ll="ls -l"
alias la="ls -a"
alias ls2="tree -L 2 --gitignore"
alias du1='du -h -d1 -x | sort -h'
alias c='code'
alias python="python3"
alias pip="pip3"
alias csvpp='csvtk pretty | less --header 1'

if ! type bat > /dev/null 2>&1 && type batcat > /dev/null 2>&1; then
  alias bat='batcat'
fi

# Tired of struggling with shell quoting? This takes the contents of the clipboard escapes it for use in sh/bash/zsh.
if [[ "$OSTYPE" == "darwin"* ]]; then
  alias pbquote="pbpaste | jq -rRs '@sh'"
elif command -v xclip >/dev/null 2>&1; then
  alias pbquote="xclip -selection clipboard -o | jq -rRs '@sh'"
elif command -v xsel >/dev/null 2>&1; then
  alias pbquote="xsel --clipboard --output | jq -rRs '@sh'"
fi

# The bare `date` shadow alias lives at the end of ~/.zshrc (interactive-only)
# so it can't bake into functions that call `date +FMT` (e.g. tbackup). The named
# date_* variants below don't shadow a real command, so they're safe to keep here.
alias date_utc="_date -u --rfc-3339=second"
alias date_z="_date -u --rfc-3339=second"
alias date_london="TZ='Europe/London' _date --rfc-3339=second"
alias date_la="TZ='America/Los_Angeles' _date --rfc-3339=second"
alias date_unix="_date +%s"

function gi() { curl -sLw "\n" https://www.toptal.com/developers/gitignore/api/$@ ;}

# Join lines using delimiter $1.
join() { paste -s -d ${1?} -}

randstring() { cat /dev/urandom | LC_ALL=C tr -dc 'a-z0-9' | fold -w ${1:-8} | head -n 1 }

hfmt() {
numfmt --to=iec-i "$@"
}

genpass() {
  local length=${1:-32}
  openssl rand -base64 "$length" | tr -d "=+/" | cut -c1-"$length"
}

tbackup() {
  local file="${1?}"
  cp "$file" "${file}.$(date +%Y%m%d_%H%M%S).bak"
}

stripansi() {
  sed "s/$(printf '\033')\[[0-9;]*m//g"
}

autocolor() {
    if [ -t 1 ]; then
        cat          # stdout is a TTY, pass through unchanged
    else
        stripansi
    fi
}

# Renders a dotfile on stdin to a temporary location, and open it
render() {
  if [[ "$OSTYPE" != darwin* ]]; then echo "render: macOS only" >&2; return 1; fi
  data="$HOME/Documents/graphviz"
  mkdir -p "$data/dot" "$data/img"
  dotfile="$(mktemp "$data/dot/XXXXXX")"
  pngfile="$(mktemp "$data/img/XXXXXX").png"
  cat > "$dotfile"
  dot -Tpng -o"$pngfile" "$dotfile"
  open "$pngfile"
}

pkggo() {
  if [[ "$OSTYPE" != darwin* ]]; then echo "pkggo: macOS only" >&2; return 1; fi
  open $(printf "https://pkg.go.dev/%s" "${1?}")
}

# Curl the address $1, but resolve it using $2. Useful for curling load-balancers that aren't configured to respond to requests for their internal lb domain name.
curl_alt_connect () { curl --connect-to $1:443:$2:443 https://$1 }

exec_in_docker () {
	docker exec --interactive --tty ${1?} ${2:-"/bin/sh"}
}

# SYNOPSIS
#   manopt command opt
#
# DESCRIPTION
#   Returns the portion of COMMAND's man page describing option OPT.
#   Note: Result is plain text - formatting is lost.
#
#   OPT may be a short option (e.g., -F) or long option (e.g., --fixed-strings);
#   specifying the preceding '-' or '--' is OPTIONAL - UNLESS with long option
#   names preceded only by *1* '-', such as the actions for the `find` command.
#
#   Matching is exact by default; to turn on prefix matching for long options,
#   quote the prefix and append '.*', e.g.: `manopt find '-exec.*'` finds
#   both '-exec' and 'execdir'.
#
# EXAMPLES
#   manopt ls l           # same as: manopt ls -l
#   manopt sort reverse   # same as: manopt sort --reverse
#   manopt find -print    # MUST prefix with '-' here.
#   manopt find '-exec.*' # find options *starting* with '-exec'
manopt() {
  local cmd=$1 opt=$2
  [[ $opt == -* ]] || { (( ${#opt} == 1 )) && opt="-$opt" || opt="--$opt"; }
  man "$cmd" | col -b | awk -v opt="$opt" -v RS= -v ORS='\n\n' '
    found && ($0 ~ /^[[:blank:]]+-/ || $0 ~ /^[^[:blank:]]/) { found=0 }
    found { print; next }
    $0 ~ "(^|,)[[:blank:]]+" opt "([[:punct:][:space:]]|$)" { found=1; print }
  '
}

check_keypair() {
    local private_key="$1"
    local public_key="$2"

    if [[ -z "$private_key" || -z "$public_key" ]]; then
        echo "Usage: check_keypair <private_key> <public_key>" >&2
        return 1
    fi

    if [[ ! -f "$private_key" ]]; then
        echo "Error: private key not found: $private_key" >&2
        return 1
    fi

    if [[ ! -f "$public_key" ]]; then
        echo "Error: public key not found: $public_key" >&2
        return 1
    fi

    local derived
    derived=$(ssh-keygen -y -f "$private_key" 2>&1) || {
        echo "Error: could not read private key: $derived" >&2
        return 1
    }

    local stored
    stored=$(awk '{print $1, $2}' "$public_key")

    if [[ "$derived" == "$stored" ]]; then
        echo "OK: keys match"
        return 0
    else
        echo "MISMATCH: keys do not match" >&2
        echo "derived: $derived" >&2
        echo "stored: $stored" >&2
        return 1
    fi
}

# ---------------------------------------------------------------------------
# less toggles
#
# by default:
# -R: --RAW-CONTROL-CHARS: enables color
# -S: --chop-long-lines
# -X: --no-init (don't clear screen on exit)
# -i: --ignore-case (intelligently)
# -N: --line-numbers
# ---------------------------------------------------------------------------
lw() {
  old=$LESS
  if [[ $LESS =~ .*S.* ]] ; then
    new=$(printf "%s" "$LESS" | tr -d 'S')
  else
    new=$(printf "%sS" "$LESS")
  fi
  export LESS="$new"
  printf "LESS was '%s', now '%s'\n" $old $new
}
lnum() {
  old=$LESS
  if [[ $LESS =~ .*N.* ]] ; then
    new=$(printf "%s" "$LESS" | tr -d 'N')
  else
    new=$(printf "%sN" "$LESS")
  fi
  export LESS="$new"
  printf "LESS was '%s', now '%s'\n" $old $new
}

# ---------------------------------------------------------------------------
# JSON / YAML
#
# Regex dialects to keep in mind: jq uses Oniguruma (PCRE-like: \d, lookaround,
# named captures `(?<name>…)`), while mikefarah yq uses Go RE2 (no backreferences,
# no lookaround). Don't reach for lookaround in a yq filter.
# ---------------------------------------------------------------------------
alias y2j='yq -o=json eval'
alias j2y='yq -P'

# Invoke yq, merging all files into one. Useful for output from helm template
yqm() { yq $@ ea '. as $item ireduce ({}; . * $item )' }

jq_whereis() {
	jq '[path(.. | '$1' | select(. != null)) | walk(if type == "number" then 0 else . end)] | unique'
}

jqallpaths () {
	jq -r 'path(..)
	| map(
		if (type=="number") then "[\(. )]"
		elif contains(".") then "[\"\(. )\"]"
		else .
		end
	  )
	| to_entries
	| map(
		if .key == 0 or (.value | startswith("[")) then .value
		else "." + .value
		end
	  )
	| join("")'
}

yqallpaths () {
	y2j | jqallpaths
}

meta () {
	jq '( .items[]? // .) |  .metadata | pick (.name, .labels, .annotations)'
}

flatten_kv () {
    jq -sr '[.[] | to_entries[]] | map(@text "\(.key)=\(.value)") | unique[]'
}

# ---------------------------------------------------------------------------
# git
# ---------------------------------------------------------------------------
alias good="git bisect good"
alias bad="git bisect bad"

gitrel() ( set -e ; toplevel="$(git rev-parse --show-toplevel)" ; realpath --relative-to "${toplevel?}" ${1?} ; )

# "(r)epo (r)oot"
rr () {
	TOP=$(git rev-parse --show-toplevel) || return
	cd "$TOP"
}

# Create a worktree, cd into it, and launch a named Claude session in one shot
# Usage: wt nanochat sched
wt() {
  local repo=$(basename $(git rev-parse --show-toplevel))
  local purpose=$1
  local dir="../${repo}-${purpose}"
  git worktree add "$dir" -b "feature/${purpose}"
  cd "$dir"
  claude --name "${repo}-${purpose}"
}

# List all worktrees for the current repo
alias wtls='git worktree list'

# Remove a worktree by purpose name (run from any worktree of the repo)
# Usage: wtrm sched
wtrm() {
  local repo=$(basename $(git rev-parse --show-toplevel 2>/dev/null || echo $(pwd)))
  local dir="../${repo}-${1}"
  git worktree remove "$dir"
}

# ---------------------------------------------------------------------------
# tmux
# ---------------------------------------------------------------------------

# Start or attach to a named tmux session
# Usage: tm nanochat-workshop
tm() {
  tmux new -As "$1"
}

tmuxr() { tmux new-session -As0 ; }

# Launch tmux with a 2x2 tiled layout.
# Prints the current tmux prefix key in pane 1 (top-right).
# Usage: tmux-quad [session-name]  (default session name: quad)
tmux-quad() {
    local session="${1:-quad}"

    # Attach if session already exists
    if tmux has-session -t "$session" 2>/dev/null; then
        tmux attach-session -t "$session"
        return
    fi

    tmux new-session -d -s "$session"

    # Split into 4 panes: top-left, top-right, bottom-left, bottom-right
    tmux split-window -h -t "$session"          # left | right
    tmux split-window -v -t "$session:{start}.{left}"      # split left vertically
    tmux split-window -v -t "$session:{start}.{right}"      # split right vertically

    # In pane 1 (top-right), print the tmux prefix key
    local prefix
    prefix=$(tmux show-options -g prefix | awk '{print $2}')
    tmux send-keys -t "$session:{start}.{top-right}" "echo 'tmux prefix: $prefix'" Enter

    # Select pane top-left as active
    tmux select-pane -t "$session:{start}.{top-left}"

    tmux attach-session -t "$session"
}
alias tq="tmux-quad"
