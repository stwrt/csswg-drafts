#!/bin/sh
# The "Build specs" / issues / markdown / index steps of build-specs.yml, run
# in place so the tree can be served as-is.
set -e
for file in ./*/Overview.html; do
  cp "$file" "$(dirname "$file")/index.html"
done
for file in ./*/Overview.bs; do
  echo "==> Building $file"
  TIMESTAMP="$(git log -1 --format=%at -- "$file")"
  SHORT_DATE="$(date --date=@"$TIMESTAMP" --utc +%F)"
  bikeshed -f spec "$file" "${file%Overview.bs}index.html" --md-date="$SHORT_DATE" --md-Text-Macro="BUILTBYGITHUBCI foo"
done
for file in ./*/*.bsi ./*/issues-*.txt; do
  [ -f "$file" ] || continue
  bikeshed issues-list "$file" || true
done
python ./bin/build-markdown.py
python ./bin/build-index.py
rm -rf ./.git ./.gitattributes ./.gitignore ./.dockerignore
