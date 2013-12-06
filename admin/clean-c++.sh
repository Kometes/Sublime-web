#!/bin/bash
#project clean script
sublimeWeb=$(cd $(dirname $0)/.. && pwd)
. $sublimeWeb/dev/core.sh

if [ $# -eq 0 ]
then
    echo "Usage: $self <project> <build-mode>"
    exit_ "$0 $*" 1
fi

project_=$1
mode=$2

pushd ../$project_-dev-$user > /dev/null
echo "$server:$(pwd)$ rm build/$mode"
rm -rf build/$mode
popd > /dev/null
