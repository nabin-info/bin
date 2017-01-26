#!/bin/sh
exec 2>/dev/null
paths_="$(IFS=":" ; for p in $PATH ; do printf '%s ' $p ; done)"
paths=
for path_ in ${paths_} ; do
  dup=
  for path in ${paths} ; do
    [ "$path" = "$path_" ] && dup="$path"
  done
  [ -z "$dup" ] && paths="${paths} ${path_}"
done
find ${paths} "$@" -maxdepth 1 -executable \! -type d 
