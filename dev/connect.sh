#!/bin/bash
#script to connect to server with terminal
sublimeWeb=$(cd $(dirname $0)/.. && pwd)
. $sublimeWeb/dev/core.sh
ssh $user@$server
