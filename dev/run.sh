#!/bin/bash
#script to debug current site in browser
sublimeWeb=$(cd $(dirname $0)/.. && pwd)
. $sublimeWeb/dev/core.sh

osascript -e '
    tell application "'$browser'"
        activate
        tell application "System Events" to keystroke "r" using {command down, shift down}
    end tell
'
