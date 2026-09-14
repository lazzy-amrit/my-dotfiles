ÿ#!/bin/bash

STEP=0.05
OUTPUT="HDMI-1"

CUR=$(xrandr --verbose | awk '/Brightness/ {print $2; exit}')

if [ -z "$CUR" ]; then
  CUR=1
fi

if [ "$1" = "up" ]; then
  NEW=$(awk "BEGIN {print $CUR + $STEP}")
else
  NEW=$(awk "BEGIN {print $CUR - $STEP}")
fi

# clamp 0.1 - 1.0
NEW=$(awk "BEGIN {
  if ($NEW > 1) print 1;
  else if ($NEW < 0.1) print 0.1;
  else print $NEW
}")

xrandr --output "$OUTPUT" --brightness "$NEW"

notify-send "Brightness" "HDMI-1: $NEW"
