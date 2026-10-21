# Named bundles of repos under ~/Code, keyed by bundle name, e.g.
#   GWT_BUNDLES[web]="frontend backend shared-lib"
typeset -gA GWT_BUNDLES

# The omz git plugin aliases gwt to `git worktree`; replace it with the function below.
unalias gwt 2>/dev/null

# gwt: create a worktree for the current repo under ~/worktrees/<name>/<repo>
# With --bundle=<bundle>, create a worktree for each repo in that bundle instead.
gwt() {
  local bundle

  while [[ $# -gt 0 ]]; do
    case "$1" in
      --bundle=*) bundle="${1#--bundle=}"; shift ;;
      --bundle)   bundle="$2"; shift 2 ;;
      *)          break ;;
    esac
  done

  if [[ -n "$bundle" ]]; then
    if [[ -z "${GWT_BUNDLES[$bundle]}" ]]; then
      echo "Unknown bundle: $bundle (known: ${(k)GWT_BUNDLES})" >&2
      return 1
    fi
    if [[ $# -ne 1 ]]; then
      echo "Usage: gwt --bundle=<bundle> <name>" >&2
      return 1
    fi
    local -a repos
    repos=(${=GWT_BUNDLES[$bundle]})
    gwt-bulk -n "$1" "${repos[@]/#/$HOME/Code/}"
    return
  fi

  if [[ $# -ne 1 ]]; then
    echo "Usage: gwt <name>" >&2
    return 1
  fi

  local name="$1"
  local repo_root
  repo_root=$(git rev-parse --show-toplevel 2>/dev/null) || {
    echo "Not inside a git repository" >&2
    return 1
  }

  local repo_name
  repo_name=$(basename "$repo_root")

  local worktree_path=~/worktrees/$name/$repo_name
  mkdir -p ~/worktrees/$name

  if git show-ref --verify --quiet "refs/heads/$name"; then
    git worktree add "$worktree_path" "$name"
  else
    git worktree add -b "$name" "$worktree_path"
  fi
}

# gwt-bulk: run gwt across multiple repos
# Usage: gwt-bulk -n <name> <repo1> [repo2 ...]
gwt-bulk() {
  local name
  local repos=()

  while [[ $# -gt 0 ]]; do
    case "$1" in
      -n) name="$2"; shift 2 ;;
      *)  repos+=("$1"); shift ;;
    esac
  done

  if [[ -z "$name" ]]; then
    echo "Usage: gwt-bulk -n <name> <repo1> [repo2 ...]" >&2
    return 1
  fi

  if [[ ${#repos[@]} -eq 0 ]]; then
    echo "At least one repo path required" >&2
    return 1
  fi

  for repo in "${repos[@]}"; do
    pushd "$repo" > /dev/null || { echo "Cannot cd into $repo" >&2; continue; }
    gwt "$name"
    popd > /dev/null
  done
}

gwt-prune() {
  local base="$HOME/Code"
  if ! [[ -d "$base" ]] ; then
    echo "$base not found" >&2
    return 1
  fi

  for d in "$base/"*"/"; do ( cd "$d" ; git worktree prune 2>/dev/null ; ) ; done
}
