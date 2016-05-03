#!/bin/bash

debug=off
time=10
while getopts dt: opt
do
    case "$opt" in
        d)  debug=on;;
        t)  time="$OPTARG";;
        \?)   # unknown flag
            echo >&2 \
                "usage: $0 [-v] [-e entrypoint] [parameter ...]"
            exit 1;;
    esac
done
shift `expr $OPTIND - 1`

CONTAINER=$(docker ps | grep $1)
[ ${debug} == "on" ] && echo "CONTAINER: ${CONTAINER}"

if [ -n "${CONTAINER}" ]; then
  docker restart --time ${time} $1
fi
