#!/bin/bash

set -eu

ORIGINAL=$(cat)

sudo apt-get update -qq
UPDATED=$(
    printf "%s" "$ORIGINAL" \
        | sed "s/=.*$//g" \
        | xargs apt-get install -qqsV \
        | awk '$1 == "Conf" { gsub(/:.*/, "", $2); gsub(/^\(/, "", $3); print $2 "=" $3 }' \
)

printf "%s\n%s" "$UPDATED" "$ORIGINAL" | sort -sut= -k1,1
