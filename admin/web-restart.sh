#!/bin/bash
#script to restart web server
sublimeWeb=$(cd $(dirname $0)/.. && pwd)
. $sublimeWeb/dev/core.sh

sudo service apache2 restart
