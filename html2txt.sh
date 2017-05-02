#!/bin/sh

w3m \
  -o color=0 \
  -o tabstop=4 \
  -o display_link=1 \
  -o display_link_number=1 \
  -o fix_width_conv=1 \
  -o fold_textarea=0 \
  -o fold_line=1 \
  -O utf-8 \
  -dump "$@"

