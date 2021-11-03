#!/bin/bash

set -eu

RESTORE_UID=$(stat -c %u .)
sudo chown -R "$UID" .

git config --global user.email "eggyal+update.bot@gmail.com"
git config --global user.name "Update Bot"

sudo apt-get update -qq \
    && cp "$MOLD_BUILD_DEPS" /tmp \
    && sed "s/=.*$//g" "/tmp/$MOLD_BUILD_DEPS" \
        | xargs apt-get install -qqsV \
        | awk '$1 == "Conf" { gsub(/:.*/, "", $2); gsub(/^\(/, "", $3); print $2 "=" $3 }' \
        | sort -sut= -k1,1 - "/tmp/$MOLD_BUILD_DEPS" \
    > "$MOLD_BUILD_DEPS"

git add -A
git diff-index --quiet HEAD \
    || git commit -qm 'Update mold build dependencies'

curl -fsSL --proto '=https' --tlsv1.2 "https://api.github.com/repos/$MOLD_GITHUB_REPO/releases/latest" \
    | jq -r .tarball_url \
> "$MOLD_TARBALL_URL"

git add -A
git diff-index --quiet HEAD \
    || git commit -qm 'Update mold'

sudo chown -R "$RESTORE_UID" .

exit 0
