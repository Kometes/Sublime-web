#!/bin/bash
#script to reload public/dev websites 
sublimeWeb=$(cd $(dirname $0)/.. && pwd)
. $sublimeWeb/dev/core.sh

sudo service apache2 reload
