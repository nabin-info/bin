#!/bin/sh
exec 2>/dev/null
paths="${PATH//:/ }"
{ find ${paths} -type f -name '*ctl' -print \
    | awk -F/ '{print $(NF)}'
  man -k ctl \
    | awk '$1 ~ /^[^[:blank:]]+ctl$/ {print $1}' 
} \
  | sort -u \
  | column 
