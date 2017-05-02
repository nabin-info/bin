#!/bin/bash
# vim: set sw=2 ts=2 sts=0 et ai fdm=indent:

## Helper Functions  

is_atty() { [[ -t ${1:-0} ]] ; }
is_tidy() { [[ ${TIDY:-0} = 1 ]] ; }
is_verb() { [[ ${VERBOSE:-0} = 1 ]] ; }

out() { printf "$@" ; }
err() { out "$@" 1>&2 ; }
die() { err 'die: %s\n' "${1:-unspecified}" ; exit ${2:-1} ; }

ack() {
  local a='' q="${1:?usage: ack <prompt>}"
  isatty || die " (not a tty) while prompting: ${q}"
  while true ; do read -r -p "${q} " a
    case "${a^^}" in 
      N|NO) return 1 ;;
      Y|YE|YES) return 0 ;;
      *) continue ;;
    esac
  done
}

vim_home() { vim -e -X -T dumb --cmd 'echo $VIMRUNTIME' -c 'q' 2>&1 ; }

list_filetypes() { die "list_filetypes() not implemented" ; }

list_colorschemes() {
  find "${VIM_HOME}/colors" \
       "${HOME}/.vim/colors" \
       -name "*.vim" \
    2>/dev/null \
    | sed 's:^.*/\(.\+\)\.vim$:\1:' \
    | sort -u
  exit 0
}

################################################################################
usage() { cat >&2 <<"END_OF_USAGE"
  Usage:  vim2html [opts] <infile>
  Options:
    -h        Print this help message
    -L        List available ':colorscheme's
    -b        Use a black background (:set bg=dark)
    -w        Use a white background (:set bg=light)
    -n        Output line numbers (:set nu)
    -s        Output CSS
    -x        Output XHTML
    -o <ex>   Output files to directory: <ex>'
    -c <cs>   (:colorscheme <colorscheme>)
    -f <ft>   (:set ft=<filetype>)
    -t <ts>   (:set ts=<ts> sw=<ts> sts=0)
    -j <df>   Output dynamic folds using (:set fdm=<df>)
END_OF_USAGE
  exit 127
}

## main() 
{
  : ${HOME:=$(cd ~ ; pwd)}
  : ${VIM_HOME:=$(vim_home)}

  ## Parse Options  
  [[ $# -lt 1 ]] && usage
  while getopts ":hLbwnsxc:o:f:t:j:" options
  do
    case $options in
      h) usage ;;
      L) list_colorschemes ;;
      b) v_bg="dark" ;;
      c) v_cs="${OPTARG}" ;;
      f) v_ft="${OPTARG}" ;;
      j) v_df="${OPTARG}" ;;
      n) v_nu=1 ;;
      o) DEST="${OPTARG}" ;;
      s) v_ss=1 ;;
      t) v_ts="${OPTARG}" ;;
      w) v_bg="light" ;;
      x) v_xs=1 ;;
      *) err "ERROR: unknown switch " ; 
         usage ;;
    esac
  done
  shift $((OPTIND - 1))

  DEST="${DEST%%/}"
  ## Convert Files 
  for infile in "$@"
  do
    [[ -d "$infile" ]] && { 
      err "${infile} is a directory" 
      continue
    }
    [[ -r "$infile" ]] || { 
      err "${infile} is not readable" 
      continue 
    }

    ## Setup Redirection (for -o <xn>) 
    if [[ -n "${DEST}" ]]
    then 
      outfile="${DEST}/${infile}.html"
      mkdir -p "$(dirname "${outfile}")"
      [[ "$outfile" = "$infile" ]] && die 'SCRIPT ERROR, $infile == $outfile'
      err "Writing '$infile' to '$outfile'"
      exec 5>"$outfile"
    else 
      exec 5>&1
    fi

    ## Default Settings  
    #: ${v_cs:=default}   ## always a safe choice ...
    : ${v_cs:=scame}   ## this is a good light theme
    : ${v_ts:=4}
    : ${v_ss:=1}
    : ${v_xs:=0}

    ## Craft vimscript and pipe to ex  
    {
      ## This block generates a vimscript we pipe to ex
      [[ -n "_yes_" ]] && echo 'set nocompatible'
      [[ -n "_yes_" ]] && echo 'set t_Co=256'
      #[[ -n "_yes_" ]] && echo 'set t_Sf=<Esc>[3%dm'
      #[[ -n "_yes_" ]] && echo 'set t_Sb=<Esc>[4%dm'

      [[ -n "$v_bg" ]] && echo "set bg=${v_bg}"

      [[ -n "$v_ts" ]] && echo "set ts=${v_ts} sw=${v_ts} sts=0 et"

      [[ -n "$v_ss" ]] && echo "let g:html_use_css=${v_ss}"

      [[ -n "$v_xs" ]] && echo "let g:html_use_xhtml=${v_xs}"

      [[ -n "$v_nu" ]] && echo "let g:html_number_lines=${v_nu}"
      [[ -n "$v_nu" ]] && echo "let g:html_line_ids=${v_nu}"

      [[ -n "$v_df" ]] || echo "let g:html_ignore_folding=1"
      [[ -n "$v_df" ]] && echo 'let g:html_ignore_folding=0'
      [[ -n "$v_df" ]] && echo 'let g:html_dynamic_folds=1'
      [[ -n "$v_df" ]] && echo 'let g:html_no_fold_column=0'
      [[ -n "$v_df" ]] && echo "set fde=${v_df#*::}"
      [[ -n "$v_df" ]] && echo "set fdm=${v_df%%::*} fml=3"

      [[ -n "$v_ft" ]] && echo "set ft=${v_ft}"

      [[ -n "$v_cs" ]] && echo "colorscheme ${v_cs}"
      [[ -n "_yes_" ]] && echo 'syntax on'
      [[ -n "$v_cs" ]] && echo "colorscheme ${v_cs}"

      [[ -n "_yes_" ]] && echo 'let g:html_no_progress=1'
      [[ -n "_yes_" ]] && echo 'let g:html_ignore_conceal=1'
      [[ -n "_yes_" ]] && echo 'let g:html_expand_tabs=1'
      [[ -n "_yes_" ]] && echo 'let g:html_use_encoding=UTF-8'
      [[ -n "_yes_" ]] && echo 'let g:html_no_pre=0'
      [[ -n "_yes_" ]] && echo 'let g:html_pre_wrap=0'
      [[ -n "_yes_" ]] && echo 'runtime! syntax/2html.vim'
      [[ -n "_yes_" ]] && echo 'w !cat >&5'
      [[ -n "_yes_" ]] && echo 'qa!'
    } | { 
      vim -e -s -n -N -u NONE -X -- "${infile}" 1>/dev/null 
    }

    ## Close Redirection 
    exec 5>&-
    ## because of the way loading 2html.vim behaves, I had to do all that
    ## nasty redirection.
  done

  exit 0
}

## Scatch Paper Section  
  #  -U NONE -g -f --cmd ":set guipty" \

  ## WARNING:  only 10 '-c' commands are allowed!
  #vim -E -n -X -N \
  # -s -u NONE \
  # -c 'let g:html_no_progress = 1' \
  # -c 'let g:html_ignore_folding = 1' \
  # -c 'let g:html_ignore_conceal = 1' \
  # -c 'let g:html_use_xhtml = 1' \
  # -c 'let g:html_use_css = 1' \
  # -c 'let g:html_pre_wrap = 0' \
  # -c 'syntax on' \
  # -c 'colorscheme desert' \
  # -c 'set ft=yang' \
  # -c 'runtime! syntax/2html.vim' \
  # -c 'wqa!' \
  # -- "${infile}"
