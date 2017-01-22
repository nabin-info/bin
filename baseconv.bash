#!/bin/bash
progname="$(basename "$0")"
usage() { cat <<END_OF_HELP

    Usage:  ${progname} <ibase> <obase> [arg1..argN]

END_OF_HELP
exit 1
}


## Base Lookup Tables (support case-insensitive input)
declare -A c2i=()
c2i[0]=0  c2i[1]=1  c2i[2]=2  c2i[3]=3  c2i[4]=4  c2i[5]=5  c2i[6]=6  c2i[7]=7
c2i[8]=8  c2i[9]=9  c2i[a]=10 c2i[b]=11 c2i[c]=12 c2i[d]=13 c2i[e]=14 c2i[f]=15
c2i[g]=16 c2i[h]=17 c2i[i]=18 c2i[j]=19 c2i[k]=20 c2i[l]=21 c2i[m]=22 c2i[n]=23
c2i[o]=24 c2i[p]=25 c2i[q]=26 c2i[r]=27 c2i[s]=28 c2i[t]=29 c2i[u]=30 c2i[v]=31
c2i[w]=32 c2i[x]=33 c2i[y]=34 c2i[z]=35 c2i[A]=10 c2i[B]=11 c2i[C]=12 c2i[D]=13 
c2i[E]=14 c2i[F]=15 c2i[G]=16 c2i[H]=17 c2i[I]=18 c2i[J]=19 c2i[K]=20 c2i[L]=21 
c2i[M]=22 c2i[N]=23 c2i[O]=24 c2i[P]=25 c2i[Q]=26 c2i[R]=27 c2i[S]=28 c2i[T]=29 
c2i[U]=30 c2i[V]=31 c2i[W]=32 c2i[X]=33 c2i[Y]=34 c2i[Z]=35 

declare -a i2c=("0" "1" "2" "3" "4" "5" "6" "7" 
                "8" "9" "a" "b" "c" "d" "e" "f" 
                "g" "h" "i" "j" "k" "l" "m" "n"
                "o" "p" "q" "r" "s" "t" "u" "v"
                "w" "x" "y" "z"                )

## word2value parses input in $ibase
word2value() {
  [[ -z "$1" ]] && return
  local -i v=0
  local -i i=0
  local word=$1
  local ichr=

  for (( i = 0 ; i < ${#word} ; i++ )) 
  do 
    ichr=${word:${i}:1}
    ((v = (v * ibase) + ${c2i[$ichr]}))
  done
  echo ${v}
}

## value2word writes output in $obase
value2word() {
  [[ -z "$1" ]] && return
  local -i n=0
  local -i i=0
  local -i x=0
  local -i value=$1
  local -i v=${value}
  local word=

  ## find n as number of digits required in obase
  while (( value > (obase ** n) - 1 )) 
  do 
    (( n += 1 ))
  done

  ## build word that is 'n' chars in length
  while ((v > 0 && n > 0)) 
  do
    (( x = obase ** (n - 1) ))
    (( i = 0 ))
    while (( (v - x) >= 0 ))
    do
      (( i += 1 ))
      (( v -= x ))
    done
    word=${word}${i2c[$i]}
    #echo "${n}x${i}:[${v}]: ${word}" >&2
    (( n -= 1 ))
  done
  #echo ":: [${v} remainder]: ${word}" >&2

  ## output trailing 0's
  while (( n > 0 ))
  do 
    word=${word}0
    ((n -= 1))
  done
  echo ${word:-0}

}

#main()
{
declare -i ibase=$1
shift
declare -i obase=$1
shift

[[ -z "$ibase" ]] && usage
[[ -z "$obase" ]] && usage
(( obase < 2 )) || (( obase > 35 )) && usage
(( ibase < 2 )) || (( ibase > 35 )) && usage

for arg in "$@"
do
  val="$(word2value ${arg})"
  echo "$(value2word ${val})"
done
}
