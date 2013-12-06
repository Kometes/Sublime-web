#!/bin/bash
#project build script
sublimeWeb=$(cd $(dirname $0)/.. && pwd)
. $sublimeWeb/dev/core.sh

if [ $# -eq 0 ]
then
    echo "Usage: $self <project> <build-mode>"
    exit_ "$0 $*" 1
fi

project_=$1
mode=$2

mkdir -p ../$project_-dev-$user/build/$mode
pushd ../$project_-dev-$user/build/$mode > /dev/null
echo "$server:$(pwd)$ make ${cmakeTarget[$project_]-}"
eval "${cmake[$project_]} -DCMAKE_BUILD_TYPE=$mode ${cmakeOpt[$project_]-} ${cmakeSrc[$project_]}"
make ${cmakeTarget[$project_]-}
popd > /dev/null
