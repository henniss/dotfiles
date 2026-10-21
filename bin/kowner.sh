#!/usr/bin/env zsh
#
# kowner.sh — walk a Kubernetes resource's ownerReferences recursively.
#
# Usage:
#   source kowner.sh
#   kowner <type>/<name> [-n namespace]
#
# Examples:
#   kowner pod/my-app-7f8b9c-abcde
#   kowner replicaset/my-app-7f8b9c -n prod
#
# Requires: kubectl, jq

kowner() {
  emulate -L zsh
  local resource="" namespace=""

  while (( $# )); do
    case "$1" in
      -n|--namespace)
        namespace="$2"
        shift 2
        ;;
      -h|--help)
        print "Usage: kowner <type>/<name> [-n namespace]"
        return 0
        ;;
      *)
        [[ -z "$resource" ]] && resource="$1"
        shift
        ;;
    esac
  done

  if [[ -z "$resource" ]]; then
    print -u2 "Usage: kowner <type>/<name> [-n namespace]"
    return 1
  fi

  if ! command -v jq >/dev/null 2>&1; then
    print -u2 "kowner: requires 'jq' to be installed"
    return 1
  fi

  if ! command -v kubectl >/dev/null 2>&1; then
    print -u2 "kowner: requires 'kubectl' to be installed"
    return 1
  fi

  if [[ -z "$namespace" ]]; then
    namespace="$(kubectl config view --minify -o jsonpath='{..namespace}' 2>/dev/null)"
    [[ -z "$namespace" ]] && namespace="default"
  fi

  typeset -gA _kowner_seen
  _kowner_seen=()
  _kowner_walk "$resource" "$namespace" 0
}

_kowner_walk() {
  emulate -L zsh
  local resource="$1" namespace="$2" depth="$3"
  local indent
  indent="$(printf '%*s' $((depth * 2)) '')"

  local key="${namespace}/${resource:l}"
  if [[ -n "${_kowner_seen[$key]}" ]]; then
    print "${indent}(circular reference back to ${resource} in namespace ${namespace}, stopping)"
    return 0
  fi
  _kowner_seen[$key]=1

  local json
  json="$(kubectl get "$resource" -n "$namespace" -o json 2>&1)"
  if (( $? != 0 )); then
    print -u2 "${indent}✗ ${resource} (namespace: ${namespace}) — ${json}"
    return 1
  fi

  local kind name
  kind="$(print -r -- "$json" | jq -r '.kind')"
  name="$(print -r -- "$json" | jq -r '.metadata.name')"

  if (( depth == 0 )); then
    print "${kind}/${name}  (namespace: ${namespace})"
  fi

  local owners_json owner_count
  owners_json="$(print -r -- "$json" | jq -c '.metadata.ownerReferences // []')"
  owner_count="$(print -r -- "$owners_json" | jq 'length')"

  if (( owner_count == 0 )); then
    print "${indent}  └─ no ownerReferences — this is a root object"
    return 0
  fi

  local i
  for (( i = 0; i < owner_count; i++ )); do
    local owner okind oname orole
    owner="$(print -r -- "$owners_json" | jq -c ".[$i]")"
    okind="$(print -r -- "$owner" | jq -r '.kind')"
    oname="$(print -r -- "$owner" | jq -r '.name')"
    orole="$(print -r -- "$owner" | jq -r 'if .controller == true then "controller" else "owner" end')"

    print "${indent}  └─ owned by ${okind}/${oname}  (${orole})"
    _kowner_walk "${okind}/${oname}" "$namespace" $((depth + 1))
  done
}

kowner ${@}
