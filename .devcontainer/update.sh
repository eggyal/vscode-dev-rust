#!/bin/bash

set -eu

BUILD_CONTEXT="build-context"
PACKAGES="packages"

cd -- "$( dirname -- "${BASH_SOURCE[0]}" )"

git config --global user.email "eggyal+update.bot@gmail.com"
git config --global user.name "Update Bot"

(
    unlink "$BUILD_CONTEXT/$PACKAGES"
    update-scripts/latest-packages.sh > "$BUILD_CONTEXT/$PACKAGES"
) < "$BUILD_CONTEXT/$PACKAGES"

git add -A
git diff-index --quiet HEAD \
    || git commit -qm 'Update packages'

exit 0
