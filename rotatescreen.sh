#!/bin/bash
# switch screen orientation
export DISPLAY=:0.0
VAR1=$(xrandr |grep '+0+0 left')
if [[ ! $VAR1 ]]; then
  xrandr -o 1
else
  xrandr -o 0
fi
