#!/bin/bash

BLOCKS=(' ' '⣀' '⣄' '⣤' '⣦' '⣶' '⣷' '⣿')

/opt/homebrew/bin/cava -p ~/Developer/dotfiles/sketchybar/cava | while IFS= read -r line; do
  BAR=""
  IFS=';' read -ra VALUES <<<"$line"
  for val in "${VALUES[@]}"; do
    [[ "$val" =~ ^[0-9]+$ ]] || continue
    BAR+="${BLOCKS[$val]}"
  done

  [ -n "$BAR" ] && sketchybar --set spotify.audio label="$BAR"
done
