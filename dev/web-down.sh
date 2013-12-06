#!/bin/bash
#script to bring website up/down for maintenance
sublimeWeb=$(cd $(dirname $0)/.. && pwd)
. $sublimeWeb/dev/core.sh

$sublimeWeb/dev/exec-remote.sh "
export sublimeWeb=$serverRoot/$serverSublimeWeb

if [ -e Sublime-web/web-down.sh ]   #use custom script if available
then    
    Sublime-web/web-down.sh $@
else
    ../$serverSublimeWeb/admin/web-down.sh $@
fi
"
