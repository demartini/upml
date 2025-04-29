#!/bin/bash

_upml_completions() {
  local options=(
    --dry-run -d
    --no-discord -n
    --logfile -l
    --set-webhook -s
    --show-config -c
    --help -h
    --version -v
  )
  mapfile -t COMPREPLY < <(compgen -W "${options[*]}" -- "${COMP_WORDS[1]}")
}

complete -F _upml_completions upml
