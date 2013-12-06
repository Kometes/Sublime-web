#script provides env setup and common methods
set -u #exit on uninit var
set -e #exit on error

self=`basename $0`
projectDir=$(pwd)
#get project name from dir, ignore dev tag on server
project=`basename $projectDir | sed 's/\(.*\)-dev-.*/\1/'`
#Get user from project dir. Only valid on server, client uses user-config.sh.
user=`basename $projectDir | sed 's/.*-dev-\(.*\)/\1/'`
site=$project
buildDir=$projectDir/build
log=$buildDir/dev.log
branch=`git rev-parse --abbrev-ref HEAD 2>/dev/null || true`

declare -A exports
declare -A remote_origin
declare -A remote_dev
declare -A build
declare -A cmake
declare -A cmakeSrc
declare -A cmakeOpt
declare -A cmakeTarget

. $projectDir/Sublime-web/project-config.sh
if [ -f $projectDir/Sublime-web/user-config.sh ]; then . $projectDir/Sublime-web/user-config.sh; fi

serverSublimeWeb=`basename $sublimeWeb`
if [[ $extProjects =~ $serverSublimeWeb ]]; then serverSublimeWeb+=-dev-$user; fi

#build projects list
projects=()
for extProject in $(echo $extProjects | sed $'s/,/\\\n/g')
do
    if [ -z "$extProject" ]; then continue; fi
    projects+=("$extProject")
done
projects+=("$project")

#set default project settings
for project_ in "${projects[@]}"
do
    if [ -z "${remote_origin[$project_]+defined}" ]; then remote_origin[$project_]=origin; fi
    if [ -z "${remote_dev[$project_]+defined}" ]; then remote_dev[$project_]=dev; fi
done

#killTree pid sig
killTree()
{
    local pid=$1
    local sig=${2:-TERM}

    for child in $(pgrep -P $pid)
    do
        killTree $child $sig
    done
    kill -$sig $pid

    #wait a moment for process to die gracefully, otherwise force kill until dead
    timeout=3
    start=$(date +%s)
    while ps -p $pid > /dev/null
    do
        if [ $(($(date +%s)-start)) -le $timeout ]; then continue; fi
        kill -KILL $pid
        start=$(date +%s)
    done
}

stacktrace()
{
    # Hide the stacktrace() call.
    local -i start=$(( ${1:-0} + 1 ))
    local -i end=${#BASH_SOURCE[@]}
    local -i i=0
    local -i j=0
     
    echo "Stacktrace (last called on top):"
    for ((i=$start; i < $end; i++)); do
        j=$(( $i - 1 ))
        local function="$FUNCNAME[$i]"
        local file="$BASH_SOURCE[$i]"
        local line="$BASH_LINENO[$j]"
        echo "    $function() in $file:$line"
    done
}

exit_()
{
    trap - EXIT
    local cmd=$(echo "$1" | xargs) error=$2
    if [ ${lock+defined} ]; then rm -f $buildDir/$lock; fi
    if [ "$error" -eq 0 ]; then return; fi
    echo "Error: command exited with code $error: \"$cmd\""
    stacktrace 1
    exit $error
}

trapExit()
{
    local cmd="$BASH_COMMAND" error=$?
    if [ ${lock+defined} ]; then rm -f $buildDir/$lock; fi
    if [ "$error" -eq 0 ]; then return; fi
    echo "Error: command exited with code $error: \"$cmd\""
    stacktrace 1
}

ignoreError()
{
    set +e
    eval "$@"
    cmd="$@" error=$?
    set -e
}

mkdir -p $buildDir
if [ ${lock+defined} ]
then
    if [ ! -f $buildDir/$lock ]
    then
        touch $buildDir/$lock
    else
        echo "Build script already running. Delete '$buildDir/$lock'."
        unset lock
        exit_ "$0 $*" 1
    fi
fi

trap trapExit EXIT
