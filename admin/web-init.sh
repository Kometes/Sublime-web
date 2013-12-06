#!/bin/bash
#script to setup initial public/dev git repos
sublimeWeb=$(cd $(dirname $0)/.. && pwd)
. $sublimeWeb/dev/core.sh

if [ $# -ne 4 ]
then
    cat <<EOF
Usage: $self <project> <domain> (public | <username>) <framework>

Frameworks: [cppcms, django]

ex. $self foo foo.com public cppcms
    $self foo foo.com bob cppcms
EOF
    exit_ "$0 $*" 1
fi

project_=$1
domain=$2
user_=$3
framework=$4

public()
{   
    pushd $apache/sites-available > /dev/null    
    if [ -e $project_.conf ]
    then
        echo "Public website already exists. Skipping create of '999-$project_.conf'."
        popd > /dev/null
        return
    fi

    echo "Use app-$framework $project_ $serverRoot/$project_ $project_ public 2 15" > 999-$project_.conf
    cat > $project_.inc <<EOF
ServerName $domain
ServerAlias *.$domain
EOF

    cat > 999-$project_-down.conf <<EOF
#web-down mode
#public site available for private development
Use app-$framework $project_-down-dev $serverRoot/$project_ $project_ private 1 4

#display down message on public site
Use app-$framework $project_-down $serverRoot/$project_ $project_ public 2 15
EOF
    cat > $project_-down.inc <<EOF
ServerName $domain
ServerAlias *.$domain
EOF
    cat > $project_-down-dev.inc <<EOF
ServerName dev.$domain
ServerAlias *.dev.$domain
EOF

    a2ensite 999-$project_ > /dev/null
    popd > /dev/null
}

dev()
{
    pushd $apache/sites-available > /dev/null
    dev=$project_-dev-$user_
    if [ -e $dev.conf ]
    then
        echo "Dev website for user '$user_' already exists. Skipping create of '000-$dev.conf'."
        popd > /dev/null
        return
    fi

    echo "Use app-$framework $dev $serverRoot/$dev $project_ private 1 4" > 000-$dev.conf
    cat > $dev.inc <<EOF
ServerName $user_.dev.$domain
ServerAlias *.$user_.dev.$domain
EOF

    a2ensite 000-$dev > /dev/null
    popd > /dev/null
}

public
if [ $user_ != "public" ]; then dev; fi

$sublimeWeb/admin/web-restart.sh
