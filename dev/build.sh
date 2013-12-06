#!/bin/bash
#Script to compile user's dev website. Pushes current branch to website.
sublimeWeb=$(cd $(dirname $0)/.. && pwd)
. $sublimeWeb/dev/core.sh

mode=$1

#push dev branch to dev
for project_ in "${projects[@]}"
do
    pushd ../$project_ > /dev/null
    echo "$(pwd)$ git push ${remote_dev[$project_]} dev"
    ignoreError git branch dev > /dev/null 2>&1 #create branch if it doesn't exist

    restore()
    {
        git symbolic-ref HEAD refs/heads/$branch    #restore branch
        git reset -q
    }
    trap "trapExit; restore" EXIT
    git symbolic-ref HEAD refs/heads/dev        #switch branch without changing work tree
    git reset -q

    git add -A
    git diff-index --quiet HEAD || git commit -am '' --allow-empty-message #commit if changed
    
    trap trapExit EXIT
    restore

    git push -f ${remote_dev[$project_]} dev
    git branch -q -u ${remote_dev[$project_]}/dev dev   #set up remote tracking
    popd > /dev/null
done

#push untracked user config to dev
rsync $projectDir/Sublime-web/user-config.sh $user@$server:$serverRoot/$project-dev-$user/Sublime-web/

$sublimeWeb/dev/exec-remote.sh "
export sublimeWeb=$serverRoot/$serverSublimeWeb
. \$sublimeWeb/dev/core.sh

#checkout dev branch on dev
for project_ in \"\${projects[@]}\"
do
    pushd ../\$project_-dev-$user > /dev/null
    echo \"$server:\$(pwd)$ git checkout dev\"
    git checkout -q -f dev
    git submodule update --init
    popd > /dev/null
done

#build
for project_ in \"\${projects[@]}\"
do
    if [ -z \"\${build[\$project_]+defined}\" ]; then continue; fi
    if [ -e Sublime-web/build-\${build[\$project_]}.sh ]    #use custom script if available
    then
        Sublime-web/build-\${build[\$project_]}.sh \$project_ $mode
    elif [ -e ../$serverSublimeWeb/admin/build-\${build[\$project_]}.sh ]
    then
        ../$serverSublimeWeb/admin/build-\${build[\$project_]}.sh \$project_ $mode
    fi
done

#post-build
if [ -e Sublime-web/post-build.sh ]; then Sublime-web/post-build.sh $mode; fi
"
