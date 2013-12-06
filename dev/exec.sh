#!/bin/bash
#script to exec args and log output
sublimeWeb=$(cd $(dirname $0)/.. && pwd)
lock=dev.lock
. $sublimeWeb/dev/core.sh

#copy output to log
exec &> >(tee -a $log)

#exec args in background
echo "[$(date)]$ $@"
eval "$@" &
pid=$!

#Handle the build cancel signal while waiting
trapTerm()
{
    killTree $pid
    echo -e "[Cancelled]\n"
    exec &> /dev/null
}
trap trapTerm TERM
wait $pid
