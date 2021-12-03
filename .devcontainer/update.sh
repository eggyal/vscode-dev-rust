#!/bin/bash

set -eu

BUILD_CONTEXT="build-context"
MOLD_GITHUB_REPO="rui314/mold"
MOLD_TARBALL_URL="mold.url"
MOLD_BUILD_DEPS="mold.build-packages"
PACKAGES="packages"

cd -- "$( dirname -- "${BASH_SOURCE[0]}" )"

git config --global user.email "eggyal+update.bot@gmail.com"
git config --global user.name "Update Bot"

(
    unlink "$BUILD_CONTEXT/$MOLD_BUILD_DEPS"
    update-scripts/latest-packages.sh > "$BUILD_CONTEXT/$MOLD_BUILD_DEPS"
) < "$BUILD_CONTEXT/$MOLD_BUILD_DEPS"

git add -A
git diff-index --quiet HEAD \
    || git commit -qm 'Update mold build dependencies'

update-scripts/latest-release-tarball.sh "$MOLD_GITHUB_REPO" \
> "$BUILD_CONTEXT/$MOLD_TARBALL_URL"

git add -A
git diff-index --quiet HEAD \
    || git commit -qm 'Update mold'

(
    unlink "$BUILD_CONTEXT/$PACKAGES"
    update-scripts/latest-packages.sh > "$BUILD_CONTEXT/$PACKAGES"
) < "$BUILD_CONTEXT/$PACKAGES"

git add -A
git diff-index --quiet HEAD \
    || git commit -qm 'Update packages'

exit 0
