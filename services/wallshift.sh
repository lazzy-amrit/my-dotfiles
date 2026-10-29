#!/usr/bin/env bash
# wallshift.sh — smooth cross-fade wallpaper cycler for xwallpaper (i3 / X11)
# Lives at ~/.config/services/wallshift.sh alongside the other service scripts.
#
# Caches every fade's frames to disk PERMANENTLY. The blend (ImageMagick
# convert) only ever runs once per wallpaper pair — every cycle after that is
# just reading tiny cached PNGs and calling xwallpaper, which is near-zero CPU.
# Good for weak/no-GPU machines where re-blending every single transition
# would be wasteful.
set -euo pipefail

### CONFIG — tweak these ###
WALLPAPER_DIR="${WALLSHIFT_DIR:-$HOME/Pictures/Wallpapers}"
INTERVAL=1800          # seconds a wallpaper stays before the next fade starts
FADE_STEPS=20         # blend frames per transition (higher = smoother, more cache space)
FADE_DURATION=1.2     # total seconds the fade itself should take
RANDOM_ORDER=false    # true = shuffle once at startup, false = alphabetical loop
CACHE_DIR="$HOME/.cache/wallshift"   # persistent — survives reboots
LOCK_FILE="$HOME/.cache/wallshift.lock"
### END CONFIG ###

mkdir -p "$CACHE_DIR"

# Prevent duplicate instances — if this gets autostarted with exec_always on
# every i3 reload/restart, a second copy would otherwise stack on top of the
# first and both would fight over xwallpaper. This makes re-runs a no-op.
exec 200>"$LOCK_FILE"
flock -n 200 || { echo "wallshift already running, exiting"; exit 0; }

command -v xwallpaper >/dev/null || { echo "xwallpaper not found"; exit 1; }
command -v convert >/dev/null || {
  echo "ImageMagick 'convert' not found — install with: sudo pacman -S imagemagick"
  exit 1
}

read -r SCREEN_W SCREEN_H < <(xrandr --current | awk '/\*/{print $1; exit}' | tr 'x' ' ')
SCREEN_W=${SCREEN_W:-1920}
SCREEN_H=${SCREEN_H:-1080}

mapfile -t WALLPAPERS < <(find "$WALLPAPER_DIR" -maxdepth 1 -type f \
  \( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' \) | sort)

(( ${#WALLPAPERS[@]} >= 2 )) || {
  echo "Need at least 2 images in $WALLPAPER_DIR"
  exit 1
}

if $RANDOM_ORDER; then
  mapfile -t WALLPAPERS < <(printf '%s\n' "${WALLPAPERS[@]}" | shuf)
fi

FRAME_DELAY=$(awk -v d="$FADE_DURATION" -v s="$FADE_STEPS" 'BEGIN{printf "%.3f", d/s}')

prep() {
  convert "$1" -resize "${SCREEN_W}x${SCREEN_H}^" -gravity center -extent "${SCREEN_W}x${SCREEN_H}" "$2"
}

# Unique, content-aware cache key: changes automatically if you replace/edit
# a wallpaper file (mtime is part of the hash) or resolution changes.
pair_key() {
  local from="$1" to="$2"
  {
    echo "$from:$(stat -c%Y "$from")"
    echo "$to:$(stat -c%Y "$to")"
    echo "${SCREEN_W}x${SCREEN_H}:${FADE_STEPS}"
  } | md5sum | cut -d' ' -f1
}

# Build the frame set for a pair ONLY if it isn't already cached.
build_frames() {
  local from="$1" to="$2" dir="$3"
  mkdir -p "$dir"
  prep "$from" "$dir/a.png"
  prep "$to"   "$dir/b.png"
  for (( i=1; i<=FADE_STEPS; i++ )); do
    local pct=$(( i * 100 / FADE_STEPS ))
    printf -v fname "%s/frame-%03d.png" "$dir" "$i"
    convert "$dir/a.png" "$dir/b.png" \
      -define compose:args="$pct" -compose blend -composite \
      "$fname"
  done
  rm -f "$dir/a.png" "$dir/b.png"
  touch "$dir/.complete"
}

fade() {
  local from="$1" to="$2"
  local key dir
  key=$(pair_key "$from" "$to")
  dir="$CACHE_DIR/$key"

  if [[ ! -f "$dir/.complete" ]]; then
    build_frames "$from" "$to" "$dir"
  fi

  for (( i=1; i<=FADE_STEPS; i++ )); do
    printf -v fname "%s/frame-%03d.png" "$dir" "$i"
    xwallpaper --zoom "$fname"
    sleep "$FRAME_DELAY"
  done
  xwallpaper --zoom "$to"   # lock in the crisp original, not the last blend
}

idx=0
total=${#WALLPAPERS[@]}
xwallpaper --zoom "${WALLPAPERS[0]}"

while true; do
  sleep "$INTERVAL"
  next=$(( (idx + 1) % total ))
  fade "${WALLPAPERS[$idx]}" "${WALLPAPERS[$next]}"
  idx=$next
done
