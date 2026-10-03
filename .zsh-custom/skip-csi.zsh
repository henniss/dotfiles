function skip-csi-sequence() {
  local key
  while read -sk key && (( $((#key)) < 0x40 || $((#key)) > 0x7E )); do
    # empty body
  done
}

zle -N skip-csi-sequence
bindkey '\e[' skip-csi-sequence

