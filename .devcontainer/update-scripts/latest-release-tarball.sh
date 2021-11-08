#!/bin/bash

set -eu

curl -fsSL --proto '=https' --tlsv1.2 "https://api.github.com/repos/$1/releases/latest" \
    | jq -r .tarball_url
