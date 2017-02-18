#!/bin/bash
repeat() { local n="$1" s= ; while ((n--)) ; do s+="$2" ; done ; printf '%s' "$s" ; }

center() {
  # determine string lengths length
  local -i cols=$(tput cols) ;: ${cols:=${COLUMNS:-80}} 
  local -r msg="$*" ; local -r -i len="${#msg}"  
  local -i pad="$(( (cols - len) / 2 ))"

  # Define the line-drawing characters
  local -a top=( $'\u0020' $'\u2554' $'\u2550' $'\u2557' $'\u0020' $'\u000a' )
  local -a cen=( $'\u2550' $'\u2563' $'\u0020' $'\u2560' $'\u2550' $'\u000a' )
  local -a bot=( $'\u0020' $'\u255a' $'\u2550' $'\u255d' $'\u0020' $'\u000a' )

  # Expand the padding characters
  for line in top cen bot ; do local -n args=${line}
    args[0]="$(repeat $((pad-1)) "${args[0]}")" 
    args[2]="$(repeat $((len-0)) "${args[2]}")"
    args[4]="$(repeat $((pad-1)) "${args[4]}")"
  done
  cen[2]="${msg}"  ; # fill in the actual message and print
  printf '%s' "${top[@]}" "${cen[@]}" "${bot[@]}"
}

center "$@"
