#!/bin/sh
# Build the drafts listed in $SPECS ("all" = every spec directory) into $1
# and write an index. Mirrors the spec-building step of the CI workflow.
set -e
out=${1:-/out}
mkdir -p "$out"
if [ "$SPECS" = "all" ]; then
  SPECS=$(for d in */; do d=${d%/}; if [ -f "$d/Overview.bs" ] || [ -f "$d/Overview.html" ]; then echo "$d"; fi; done)
fi
failed=""
for d in $SPECS; do
  echo "==> Building $d"
  mkdir -p "$out/$d"
  cp -r "$d"/. "$out/$d/"
  if [ -f "$d/Overview.bs" ]; then
    bikeshed -f spec "$d/Overview.bs" "$out/$d/index.html" --md-Text-Macro="BUILTBYGITHUBCI foo" \
      || { echo "!! $d failed"; failed="$failed $d"; }
  else
    cp "$d/Overview.html" "$out/$d/index.html"
  fi
done
for f in *.css *.png *.gif *.js; do [ -f "$f" ] && cp "$f" "$out/"; done
{
  echo '<!doctype html><meta charset=utf-8><title>CSS Working Group Editor Drafts</title>'
  echo '<link rel=stylesheet href="/default.css"><style>body{max-width:50em;margin:2em auto;font-family:sans-serif}li{margin:.3em 0}</style>'
  echo '<h1>CSS Working Group Editor Drafts</h1><ul>'
  for d in $SPECS; do
    [ -f "$out/$d/index.html" ] || continue
    t=$(sed -n 's/.*<title>\(.*\)<\/title>.*/\1/p' "$out/$d/index.html" | head -1)
    echo "<li><a href=\"/$d/\">${t:-$d}</a></li>"
  done
  echo '</ul>'
} > "$out/index.html"
echo "==> Built $(echo $SPECS | wc -w) spec(s)${failed:+; failed:$failed}"
