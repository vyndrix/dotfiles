#!/bin/bash

INFO="$(osascript -e '
  tell application "Spotify"
    set trackArtist to artist of current track
    set trackName to name of current track
    set trackState to player state
    return trackState & trackArtist & trackName
  end tell
')"

STATE="$(echo "$INFO" | cut -d ',' -f 1)"
ARTIST="$(echo "$INFO" | cut -d ',' -f 2)"
TRACK="$(echo "$INFO" | cut -d ',' -f 3)"

/usr/bin/logger -t "sketchybar" "entered media.sh with state: $STATE, artist: $ARTIST, track: $TRACK"

if [ "$STATE" = "playing" ]; then
  sketchybar --set "$NAME" label="$ARTIST - $TRACK" drawing=on
else
  sketchybar --set "$NAME" drawing=off
fi
