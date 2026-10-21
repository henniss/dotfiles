tf() { terraform "$@" ; }

alias tf_prep='tfswitch && terraform init && terraform get -update'
alias tf_upgrade='tfswitch && terraform init -upgrade && terraform providers lock -platform=darwin_arm64 -platform=linux_amd64'

# Accepts output from terraform plan, and summarizes the most important parts
alias tfshort="terraform plan -no-color | command grep -e \"#.*will be\" -e \"#.*must be\" -e \"^Plan:\" -e \"Warning:\" -e \"Error:\" --color=never"

# Accepts as input the output from tf state list, and prunes it to show only the modules.
alias reduce_to_modules="sed -n 's/\(.*\)\(module\)\(\.[^\.]*\)\..*/\1\2\3/p' | sort -u"
# Accepts as $1 a jq expression that evaluates to a boolean value, and applies it to select over all resources in a tf state json (received on stdin).
# It then uses pick to prune the input down to just the targets of interest.
search_tf_state () { jq 'pick(. | getpath(path( .resources[] | select('$1')))) | walk(
  if type == "array"
  then map(select(. != null))
  else .
  end
)'
}

# Run this targeting a terraform install directory; it will resolve all local (non-git) module paths and produce a list, suitable for passing to git log
get_tf_module_paths() {
	local tf_dir="${1:-$PWD}"
	if ( type grealpath > /dev/null) ; then realpath=grealpath; else realpath=realpath; fi
	local modules_json="$tf_dir/.terraform/modules/modules.json"
	[ -f "$modules_json" ] || { echo "Cannot find modules.json in $tf_dir/.terraform/modules/" >&2; return 1; }
	for p in $(jq -r '.Modules[] | select(.Source | startswith("git") | not) | .Dir' "$modules_json"); do
		$realpath "$tf_dir/$p"
	done
}

# Given tf state objects on stdin (e.g. from `tf state pull | jq ...`), print the
# module directories that own them.
tfstateobj_to_module() (
	set -e
	local modules=$(jq -sr '.[].module')
	local shortmodules=$(echo "$modules" | sed -e 's/module\.//g' -e 's/\[[^.]*\]//g' | sort -u)
	for sm in ${(f)shortmodules}; do
		cat .terraform/modules/modules.json | jq -r --arg module "$sm" '.Modules[] | select(.Key == $module).Dir'
	done
)

# Symlink the shared pre-commit config into the current repo and install the hook.
function pc_init () { ln -s $(realpath ~/.pre-commit-config.yaml) . ; pre-commit install ; }
