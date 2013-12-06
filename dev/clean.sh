#!/bin/bash
#Script to compile user's dev website. Pushes current branch to website.
sublimeWeb=$(cd $(dirname $0)/.. && pwd)
. $sublimeWeb/dev/core.sh

mode=$1

$sublimeWeb/dev/exec-remote.sh "
export sublimeWeb=$serverRoot/$serverSublimeWeb
. \$sublimeWeb/dev/core.sh

for project_ in \"\${projects[@]}\"
do
    if [ -z \"\${build[\$project_]+defined}\" ]; then continue; fi
    if [ -e Sublime-web/clean-\${build[\$project_]}.sh ]    #use custom script if available
    then
        Sublime-web/clean-\${build[\$project_]}.sh \$project_ $mode
    elif [ -e ../$serverSublimeWeb/admin/clean-\${build[\$project_]}.sh ]
    then
        ../$serverSublimeWeb/admin/clean-\${build[\$project_]}.sh \$project_ $mode
    fi
done
"
