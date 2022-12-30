#!/bin/bash

firefox -url file:///home/eraser/diskwiper_gui/status.html & xdotool search --sync --onlyvisible --class "Firefox" windowactivate key F11
xdotool key Tab
xdotool key KP_Enter
