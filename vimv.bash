#!/bin/bash
{
  tempsh="$(mktemp).sh"
  touch "${tempsh:?blank tempfile name}"
  cleanup() { rm "${tempsh}" ; }
  trap cleanup EXIT QUIT

  oldfn="$(find . -type f                \
           | sort --version-sort         \
           | sed -e 's,^\./,,'           \
                 -e 's,'\'',-,g'         \
                 -e 's/^.*$/'\''\0'\''/' \
          )"

  newfn="$(echo "${oldfn}"               \
           | tr -d '[](){},"\!'\'        \
           | sed -e 's/[_ ]\+/_/g'       \
                 -e 's/[-:]\+/-/g'       \
                 -e 's/_*-_*/-/g'        \
                 -e 's/^\s*/;'\''/g'     \
                 -e 's/\s*$/'\'';/g'     \
          )"

cat >>"${tempsh}"  <<END_OF_HEADER
##################################################################
# You are editing an sh script (${tempsh}) which was created by 
# "${0}" run in "$(pwd)".  THIS SCRIPT IS DELETED UPON EXIT.
# Suggested Usage:
#   * Remove lines for filenames you do not want to change.
#   * Alter auto-generated filenames in the new column
#   * Use ^V to enter blockwise selection mode in vim
#   * Use ^G to move cursor to next new filename
#   * Use ZQ to quit without asking to save the file
#   * Use ZX to execute the script and show output
##################################################################

END_OF_HEADER

paste -- <((echo "${oldfn}"))   \
         <((echo "${newfn}"))   \
     | sed -e 's/^/mv -nv ;/'   \
     | column -s ';' -t         \
     | tr -d '\t'               \
     >> "${tempsh}"

vim \
    +'set nowrap ma noro noswf nobk shcf=-c ft=sh ' \
    +'nnoremap <C-G> :/^mv /:normal $2F'\''zs<CR>' \
    +'nnoremap ZX :%!sh<CR>' \
    "${tempsh}"

}
