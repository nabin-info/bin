#!/bin/sh

usage () { 
cat <<EOF
Simple shell script that downloads all the media files on a page.

Usage: ${0##*/} <url> [ [url] ...]
EOF
}

[ $# -gt 0 ] || usage

urls () { 
  curl -L -s "$@" \
    | grep -E -o "['\"][^'\"]*\\.(jpeg|jpg|png|gif|webm|mp3|mp4|ogg)[\"']" \
    | sed "s/^[\"']//;s/[\"']$//"  \
    | sort 
}

urls "$@"
