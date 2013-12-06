#!/bin/bash
#script to bring website up/down for maintenance
sublimeWeb=$(cd $(dirname $0)/.. && pwd)
. $sublimeWeb/dev/core.sh

down="down"
if [ $# -ge 1 ]; then down=$1; fi

down()
{
    echo Taking down public website
    a2dissite 999-$site > /dev/null
    a2ensite 999-$site-down > /dev/null
}

up()
{
    echo Bringing up public website
    a2dissite 999-$site-down > /dev/null
    a2ensite 999-$site > /dev/null
}

if [ $down == "down" ]; then down; else up; fi

$sublimeWeb/admin/web-restart.sh
