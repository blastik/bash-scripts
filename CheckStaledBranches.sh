#!/bin/sh
set -e -u
git ls-remote -h 'https://github.com/blastik/bash-scripts' | while read sha ref; do
  # test if $sha is merged
  E=`git cat-file -t "$sha" 2>&1`
  test $? -ne 0 -a "${E#*git cat-file: *}" = "could not get object info" && continue
  git branch --merged "$sha" && printf ':%s\0' "$ref"
done
