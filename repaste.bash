#!/bin/bash
{ 
  pburl="${1:?Usage: $0 <url>}"
  pbtype=${pburl%%://*} 
  pbhost=${pburl##*://}
  pbhost=${pbhost%%/*}
  : ${VERBOSE:=1}
  verb() { [[ ${VERBOSE} -eq 1 ]] && printf "$@" >&2 ; }
  absurl() { 
    if [[ "${1:0:1}" = "/" ]] ; then
      printf "%s://%s%s\n" ${pbtype} ${pbhost} ${1:?badargs}
    else
      printf "%s\n" "${1:?badargs}"
    fi
  }
  for v in pburl pbtype pbhost ; do 
    verb '%s=%s\n' "${v}" "$(eval echo \${$v})"
  done

  pbhtml="$(curl -s -L "${pburl}")"
  
  es=( 
      's,^.* href="\(/raw/[^"]\+\)".*$,\1,p'    # pastebin
      's,^.* href="\([^"]*raw[^"]*\)".*$,\1,p'  # kde._something_
  )
  
  for e in "${es[@]}"
  do
    rawurl="$(sed -n "${e}" <<< "${pbhtml}")"
    [[ -z "${rawurl}" ]] && continue
    rawurl="$(absurl "${rawurl}")"

    rawhtml="$(curl -s -L "${rawurl}")"
    [[ -z "${rawhtml}" ]] && continue

    for v in rawurl ; do 
      verb '%s=%s\n' "${v}" "$(eval echo \${$v})"
    done

    ixiourl="$(curl -s -F 'f:1=<-' ix.io <<< "${rawhtml}")"
    [[ -z "${ixiourl}" ]] && {
      printf 'TODO: handle a failed ix.io upload request\n' >&2
      exit 1
    }
    
    printf 'Fixed that for you:  %s\n' "${ixiourl}"
    exit 0
  done
}
