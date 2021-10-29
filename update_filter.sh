#!/bin/bash
#
# Copyright 2021 The Triple Banana Authors. All rights reserved.
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.

# exit when any command fails
set -e

#checkout bromite
git clone https://github.com/bromite/filters.git bromite

echo "" >> BASE

UPSTREAM_BASE=$(git -C bromite rev-parse HEAD)
if [[ $(cat BASE) = $UPSTREAM_BASE ]]; then
    echo "Don't need to update"
    exit 1
fi

NEXT_VERSION=$(cat metadata.json | jq -r '.version'| awk -F. -v OFS=. 'NF==1{print ++$NF}; NF>1{if(length($NF+1)>length($NF))$(NF-1)++; $NF=sprintf("%0*d", length($NF), ($NF+1)%(10^length($NF))); print}')

cp bromite/filters.dat $NEXT_VERSION.filter
vim -c "set binary" -c "%s/wcslog.js/wcslog.ts/g" -c "wq" $NEXT_VERSION.filter
zip -9 $NEXT_VERSION.filter.zip $NEXT_VERSION.filter

#update version field
jq --arg version $NEXT_VERSION --indent 4 '.version = $version' metadata.json > metadata.json.tmp
mv metadata.json.tmp metadata.json

#update size field
FILTER_SIZE=$(ls -l $NEXT_VERSION.filter | awk '{print $5}')
jq --argjson size $FILTER_SIZE --indent 4 '.size= $size' metadata.json > metadata.json.tmp
mv metadata.json.tmp metadata.json

#update base
echo $UPSTREAM_BASE > BASE

git config --global user.name "GitHub Actions"
git config --global user.email "github-actions[bot]@users.noreply.github.com"
git add BASE
git add $NEXT_VERSION.filter
git add $NEXT_VERSION.filter.zip
git add metadata.json
git checkout -B release
git commit -m "Release $NEXT_VERSION"
git push -f https://$GITHUB_TOKEN@github.com/jdragonbae/filter.git

curl \
    -X POST \
    -H "Authorization: token $GITHUB_TOKEN" \
    -H "Accept: application/vnd.github.v3+json" \
    https://api.github.com/repos/jdragonbae/filter/pulls \
    -d '{"title":"Release '${NEXT_VERSION}'", "head":"release","base":"gh-pages"}'
