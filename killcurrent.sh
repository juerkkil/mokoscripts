#!/bin/bash
# Kill active X window if it's not either virtual keyboard or gsm client
export DISPLAY=:0.0
N=$(xprop -id $(xprop -root | awk '/_NET_ACTIVE_WINDOW\(WINDOW\)/{print $NF}')|awk '/WM_NAME\(STRING\)/{print $NF}')
if [[ $N == '' ]];then
  N=$(xprop -id $(xprop -root | awk '/_NET_ACTIVE_WINDOW\(WINDOW\)/{print $NF}')|awk '/WM_CLASS\(STRING\)/{print $NF}')
  echo $N
fi
if [[ $N != '"zhone"' && $N != '"kapula"' && $N != 'Keyboard"' ]];then
  kill -9  `xprop -id $(xprop -root | awk '/_NET_ACTIVE_WINDOW\(WINDOW\)/{print $NF}') | awk '/_NET_WM_PID\(CARDINAL\)/{print $NF}'`
echo moi
fi
