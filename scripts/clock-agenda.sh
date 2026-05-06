#!/bin/bash
# Waybar custom/clock module: bar text shows the time, tooltip shows
# today's gcalcli agenda. The agenda is cached so we only call gcalcli
# every few minutes regardless of how often waybar polls.

CACHE="$HOME/.cache/gcalcli-agenda"
CACHE_TTL=300  # seconds
mkdir -p "$(dirname "$CACHE")"

now=$(date +%s)
mtime=$(stat -c %Y "$CACHE" 2>/dev/null || echo 0)
if [ ! -s "$CACHE" ] || [ $((now - mtime)) -gt "$CACHE_TTL" ]; then
    if gcalcli --nocolor agenda > "$CACHE.tmp" 2>/dev/null; then
        mv "$CACHE.tmp" "$CACHE"
    else
        rm -f "$CACHE.tmp"
    fi
fi

TEXT=$(date '+%A %d %B %H:%M:%S')

if [ -s "$CACHE" ]; then
    TOOLTIP=$(sed 's/&/\&amp;/g; s/</\&lt;/g; s/>/\&gt;/g' "$CACHE")
else
    TOOLTIP="agenda unavailable"
fi

jq -nc --arg text "$TEXT" --arg tooltip "$TOOLTIP" '{text: $text, tooltip: $tooltip}'
