#!/bin/bash
#Script to compile and publish project to public website. Pushes current branch to website.
sublimeWeb=$(cd $(dirname $0)/.. && pwd)
. $sublimeWeb/dev/core.sh

#push current branch to origin
for project_ in "${projects[@]}"
do
    pushd ../$project_ > /dev/null
    echo "$(pwd)$ git push ${remote_origin[$project_]} $branch"
    git add -A
    git diff-index --quiet HEAD || git commit -a #commit if changed
    git push ${remote_origin[$project_]} $branch
    popd > /dev/null
done

#push untracked user config to dev
rsync $projectDir/Sublime-web/user-config.sh $user@$server:$serverRoot/$project-dev-$user/Sublime-web/

$sublimeWeb/dev/exec-remote.sh "
export sublimeWeb=$serverRoot/$serverSublimeWeb
. \$sublimeWeb/dev/core.sh

#pull current branch from origin to dev
for project_ in \"\${projects[@]}\"
do
    pushd ../\$project_-dev-$user > /dev/null
    echo \"$server:\$(pwd)$ git checkout $branch\"
    git fetch origin
    set +e
    git branch $branch origin/$branch > /dev/null 2>&1  #create branch if it doesn't exist
    set -e
    git symbolic-ref HEAD refs/heads/$branch            #switch branch without changing work tree
    git reset --hard origin/$branch
    git submodule update --init
    popd > /dev/null
done

#build release
for project_ in \"\${projects[@]}\"
do
    if [ -z \"\${build[\$project_]+defined}\" ]; then continue; fi
    if [ -e Sublime-web/build-\${build[\$project_]}.sh ]    #use custom script if available
    then
        Sublime-web/build-\${build[\$project_]}.sh \$project_ release
    elif [ -e ../$serverSublimeWeb/admin/build-\${build[\$project_]}.sh ]
    then
        ../$serverSublimeWeb/admin/build-\${build[\$project_]}.sh \$project_ release
    fi
done

../$serverSublimeWeb/admin/publish.sh

#post-build
if [ -e Sublime-web/post-build.sh ]; then Sublime-web/post-build.sh publish; fi
"
