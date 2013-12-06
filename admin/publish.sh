#!/bin/bash
#script to publish project to public website 
sublimeWeb=$(cd $(dirname $0)/.. && pwd)
. $sublimeWeb/dev/core.sh

#push dist branch from dev to origin
echo "$server:$(pwd)$ git push origin dist"
ignoreError git branch dist > /dev/null 2>&1    #create branch if it doesn't exist

restore()
{
    git symbolic-ref HEAD refs/heads/$branch    #restore branch
    git reset -q
    if [ -e $buildDir/.gitignore.bak ]
    then
        mv -f $buildDir/.gitignore.bak .gitignore   #restore gitignore
    fi
}
trap "trapExit; restore" EXIT
git symbolic-ref HEAD refs/heads/dist       #switch branch without changing work tree
git reset -q
if [ -e .gitignore.dist ]
then
    cp -f .gitignore $buildDir/.gitignore.bak   #append dist gitignore
    cat .gitignore.dist >> .gitignore
fi

git add -A
git diff-index --quiet HEAD || git commit -am '' --allow-empty-message #commit if changed

trap trapExit EXIT
restore

git push -f origin dist
git branch -q -u origin/dist dist           #set up remote tracking

#bring site down if it isn't already before updating files
down=0; [ -e $apache/sites-enabled/999-$site-down.conf ] && down=1
if [ $down != 1 ]; then $sublimeWeb/admin/web-down.sh; fi

#pull dist branch from origin to public
pushd ../$project > /dev/null
echo "$server:$(pwd)$ git checkout dist"
git fetch origin
git checkout -q -f dist
git reset --hard origin/dist
popd > /dev/null

#bring site back up if we took it down 
if [ $down != 1 ]; then $sublimeWeb/admin/web-down.sh up; else $sublimeWeb/admin/web-reload.sh; fi
