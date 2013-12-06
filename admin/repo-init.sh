#!/bin/bash
#script to setup initial public/dev git repos
sublimeWeb=$(cd $(dirname $0)/.. && pwd)
. $sublimeWeb/dev/core.sh

if [ $# -ne 2 ]
then
    cat <<EOF
Usage: $self <project> (root | public | <username>)

ex. $self foo public
    $self foo bob
EOF
    exit_ "$0 $*" 1
fi

project_=$1
user_=$2

rootRepo=$serverRoot/$project_.git

root()
{
    if [ -e $rootRepo ]
    then
        echo "Root repo already exists. Skipping create of '$rootRepo'."
        return
    fi

    mkdir $rootRepo
    pushd $rootRepo > /dev/null
    chmod g+ws .
    git init --bare --shared
    git config --unset receive.denyNonFastForwards
    chown -R git.dev .
    popd > /dev/null

    mkdir -p $serverRepo
    ln -s $rootRepo $serverRepo/$project_.git
}

public()
{   
    public=$serverRoot/$project_
    if [ -e $public/.git ]
    then
        echo "Public repo already exists. Skipping create of '$public'."
        return
    fi
        
    mkdir -p $public
    pushd $public > /dev/null
    chmod g+ws .
    git init --shared
    git remote add origin file://$rootRepo
    empty=`git ls-remote origin`
    if [ -z "$empty" ]
    then
        git add -A
        git commit -am 'init' --allow-empty
        git push origin master
    else
        git pull origin master
    fi
    git config --unset receive.denyNonFastForwards
    chmod -R g+w .
    chown -R git.dev .
    popd > /dev/null
}

dev()
{
    dev=$serverRoot/$project_-dev-$user_
    if [ -e $dev/.git ]
    then
        echo "Dev repo for user '$user_' already exists. Skipping create of '$dev'."
        return
    fi
    
    mkdir -p $dev
    pushd $dev > /dev/null
    chmod g+ws .
    git init --shared
    git remote add origin file://$rootRepo
    empty=`git ls-remote origin`
    if [ -z "$empty" ]
    then
        git add -A
        git commit -am 'init' --allow-empty
        git push origin master
    else
        git pull origin master
    fi
    git config --unset receive.denyNonFastForwards
    git config receive.denycurrentbranch ignore
    chmod -R g+w .
    chown -R $user_.dev .
    popd > /dev/null

    ln -s $dev $serverRepo/$project_-dev-$user_
}

root
if [ $user_ != "root" ]
then
    if [ $user_ == "public" ]; then public; else dev; fi
fi
