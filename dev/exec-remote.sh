#!/bin/bash
#Run a command on the server
sublimeWeb=$(cd $(dirname $0)/.. && pwd)
. $sublimeWeb/dev/core.sh

ssh -tt -oLogLevel=quiet $user@$server "
set -u
set -e
cd $serverRoot/$project-dev-$user
$@
"