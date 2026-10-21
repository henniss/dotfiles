# kubectl helpers. Command shortcuts are functions, not aliases, so they resolve
# at call time and are usable from inside other functions regardless of
# definition order.
k()  { if command -v kubecolor >/dev/null 2>&1; then kubecolor "$@"; else kubectl "$@"; fi ; }
y()  { k -o yaml "$@" ; }
j()  { k -o json "$@" ; }
kn() { kubens "$@" ; }
kc() { kubectx "$@" ; }

alias k8s-images="kubectl get pods -A -o jsonpath='{..image}' | tr -s '[:space:]' '\n' | sort -u"

k8s_list_noncore_resource_versions() {
	k api-versions | command grep -vF 'k8s.io/' | command grep '.*\..*\/.*' | cut -d '/' -f 1 | sort -u
}

k8s_list_all_resources_for_api_group() {
	local api_group="${1?}"
	for name in $(k api-resources --api-group $api_group -o name --no-headers ) ; do printf "# %s\n" $name ; k get $name -A ; done
}

k8s_get_owner() {
    local resource="${1?}"
    # Get resource kind and name from argument, e.g. pod/foo
    local kind=$(echo "$resource" | cut -d '/' -f 1)
    local name=$(echo "$resource" | cut -d '/' -f 2)
    # Get the ownerReferences list from resource metadata
    local owner=$(kubectl get "$kind" "$name" -o json | jq -r '.metadata.ownerReferences[0] // empty')
    if [[ -n "$owner" ]]; then
        local owner_kind=$(echo "$owner" | jq -r '.kind')
        local owner_name=$(echo "$owner" | jq -r '.name')
        # lowercase owner_kind in a zsh-compatible way
        owner_kind_lower=$(print -r -- "$owner_kind" | tr '[:upper:]' '[:lower:]')
        echo "${owner_kind_lower}/$owner_name"
    else
        echo ""
        return 1
    fi
}

# Walk a resource's ownerReferences recursively. See ~/bin/kowner.sh.
kowner() { zsh "$HOME/bin/kowner.sh" "$@" ; }

klogs_x_sample() {
	local x="${1?}"
	for deploy in $(k get deploy -n "${x}" -o name) ; do printf "# %s\n# k logs %s -n "${x}" --all-containers\n" $deploy $deploy; k logs $deploy -n "${x}" --all-containers | head ; printf "\n" ; done
}

pod_container_ids () {
  local POD="${1?Usage: pod_container_ids POD}"
  kubectl -o json get pod/${POD?} | jq -c '
    [.status.containerStatuses[]? | {(.name): (.containerID | gsub("^.*://"; ""))}] | add
  '
}

pod_to_node () {
  local POD="${1?Usage: pod_to_node POD}"
  kubectl -o json get pod/${POD?} | jq -r '.spec.nodeName'
}

nodes_by_type () {
	j get nodes | jq -r ".items[] | select(.metadata.labels[\"node.kubernetes.io/instance-type\"] == \"${1?}\") | .metadata.name"
}

pods_on_node () {
        local node="${1?}"
        shift
        local include_ds=false
        local all_statuses=false
        local arg
        for arg in "$@"
        do
                [[ "$arg" == "--ds" ]] && include_ds=true
                [[ "$arg" == "--all" ]] && all_statuses=true
        done
        kubectl get pods --all-namespaces --field-selector spec.nodeName="$node" -o json 2> /dev/null | jq -r --argjson include_ds "$include_ds" --argjson all_statuses "$all_statuses" '
              def is_ds: (.metadata.ownerReferences // []) | any(.kind == "DaemonSet");
              ["NAMESPACE","NAME","STATUS","GPU_REQ"],
              (.items[]
                | select($all_statuses or (.status.phase == "Running" or .status.phase == "Pending"))
                | select($include_ds or (is_ds | not))
                | [.metadata.namespace, .metadata.name, .status.phase,
                   ([.spec.containers[].resources.requests["nvidia.com/gpu"]] | map(select(. != null)) | join(","))]
              )
              | @tsv' | column -t -s $'\t'
}

who_is_using_my_nodes () {
  local node
  local type="${1?}"
  shift
  for node in $(nodes_by_type "${type?}") ; do
    echo "=== $node ==="
    pods_on_node "$node" "$@"
  done
}

# These contribute to the resources a node autoscaler expects to use, when trying to find an instance type.
kube_daemonset_resources() {
	kubectl get ds -A -o custom-columns='NS:.metadata.namespace,DS:.metadata.name,CPU:.spec.template.spec.containers[*].resources.requests.cpu,MEM:.spec.template.spec.containers[*].resources.requests.memory'
}

# kube-node-requests <node-name>
#
# Sums the resource requests (cpu, memory, and any other resource type,
# e.g. nvidia.com/gpu) declared by containers of all pods that are
# currently Running (not Pending, not Succeeded/Failed) on the given node.
kube-node-requests() {
  emulate -L zsh
  setopt local_options pipefail

  local node="$1"
  if [[ -z "$node" ]]; then
    echo "Usage: kube-node-requests <node-name>" >&2
    return 1
  fi

  if ! command -v kubectl >/dev/null 2>&1; then
    echo "kube-node-requests: kubectl not found" >&2
    return 1
  fi
  if ! command -v jq >/dev/null 2>&1; then
    echo "kube-node-requests: jq not found" >&2
    return 1
  fi

  local pod_json
  pod_json="$(kubectl get pods --all-namespaces \
    --field-selector "spec.nodeName=${node},status.phase=Running" \
    -o json)" || return 1

  local pod_count
  pod_count="$(jq '.items | length' <<< "$pod_json")"
  echo "Node: ${node}  (running pods: ${pod_count})"

  jq -r '
    # Parse a Kubernetes quantity string (e.g. "500m", "2", "128Mi", "1.5G")
    # into a plain base-unit number (cores for cpu, bytes for memory, etc).
    def parse_quantity:
      if . == null then 0
      else
        (tostring) as $s
        | if ($s | test("^[+-]?[0-9]*\\.?[0-9]+([eE][+-]?[0-9]+)?$")) then
            ($s | tonumber)
          else
            ($s | capture("^(?<num>[+-]?[0-9]*\\.?[0-9]+)(?<suf>[A-Za-z]+)$")) as $c
            | ($c.num | tonumber) as $n
            | ({
                "Ki": pow(2;10), "Mi": pow(2;20), "Gi": pow(2;30),
                "Ti": pow(2;40), "Pi": pow(2;50), "Ei": pow(2;60),
                "n": pow(10;-9), "u": pow(10;-6), "m": pow(10;-3),
                "k": pow(10;3),  "M": pow(10;6),  "G": pow(10;9),
                "T": pow(10;12), "P": pow(10;15), "E": pow(10;18)
              }[$c.suf] // 1) as $mult
            | $n * $mult
          end
      end;

    def humanize_bytes:
      . as $b
      | if $b >= pow(2;30) then (($b / pow(2;30) * 100 | round) / 100 | tostring) + "Gi"
        elif $b >= pow(2;20) then (($b / pow(2;20) * 100 | round) / 100 | tostring) + "Mi"
        elif $b >= pow(2;10) then (($b / pow(2;10) * 100 | round) / 100 | tostring) + "Ki"
        else ($b | tostring) + "B"
        end;

    [ .items[] | .spec.containers[] | .resources.requests // {} | to_entries[] ]
    | group_by(.key)
    | map({ key: .[0].key, total: (map(.value | parse_quantity) | add) })
    | sort_by(.key)
    | .[]
    | if .key == "cpu" then
        "cpu\t" + (.total | tostring) + " cores  (" + ((.total * 1000 | round | tostring)) + "m)"
      elif .key == "memory" or (.key | test("storage")) then
        .key + "\t" + (.total | tostring) + "  (" + (.total | humanize_bytes) + ")"
      else
        .key + "\t" + (.total | tostring)
      end
    ' <<< "$pod_json" \
  | { command -v column >/dev/null 2>&1 && column -t -s $'\t' || cat }
}

# Extract labels from a stream of JSON label objects and allow the user to select any
# to append to a named variable as a comma-separated selector.
# usage: j get pod | meta | jq '.labels' | stack_labels HARRIS
function stack_labels() {
	local TARGET=${1?}

	expand() print -r -- ${(P)1}
	assign() : ${(P)1::=$2}

	local input
	input=$(cat | jq -sr '[.[] | select(. != null) | to_entries[]] | map("\(.key)=\(.value)") | unique[]')
	if [[ -z "$input" ]]; then
		echo "stack_labels: no labels found" >&2
		return 1
	fi
	local new_labels=$(printf '%s\n' "$input" | fzf -m | join ,)
	local joined=$(echo "$(expand $TARGET)\n$new_labels" | sed '/^$/d' | join ,)
	assign $TARGET "$joined"
}

# From a variable created with stack_labels, give the user the option to unselect some labels.
function unstack_labels() {
	local TARGET=${1?}

	expand() print -r -- ${(P)1}
	assign() : ${(P)1::=$2}

	assign $TARGET $(expand $TARGET | tr ',' '\n' | fzf -m --sync --bind start:select-all | join ,)
}

# Incomplete helper to turn a selector.matchLabels section into a comma-separated list of labels.
function selector_to_labels() {
	jq -r '[to_entries | .[] | "\(.key)=\(.value)"] | join(",")'
}

# From a set of resources, extract all of the labels and present them in CSV.
function k8s_labels_to_csv() {
	# other useful sources: .metadata.annotations
	local SRC=${1:-".metadata.labels"}
	jq -r '. as $origin
| [( .items[]? // .)'$SRC' // {} | keys[]] | unique as $keys
| (["name"] + $keys,$origin.items[] as $row
| [$row.metadata.name] + ($keys | map($row'$SRC'[.]))) | @csv' | csvtk transpose }

# pretty-print the above.
node_labels() {
	csv_labels nodes
}

# pretty-print the above.
csv_labels() {
  local less_version=$(less --version | head -n1 | awk '{print $2}' | awk -F. '{printf "%d%03d", $1, $2}')
  local less_args=""
  local pretty_output
  pretty_output=$(j get "${1?}" | k8s_labels_to_csv | csvtk pretty)
  if [[ $less_version -ge 590000 ]]; then
    local col1_width
    col1_width=$(printf '%s\n' "$pretty_output" | awk '{match($0, /  /); if (RSTART > max) max = RSTART} END{print max - 1}')
    less_args="--header 1,${col1_width:-20}"
  fi
  printf '%s\n' "$pretty_output" | less $less_args
}
