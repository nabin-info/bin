#!/bin/sh
# Thomas E. Dickey knows his xterm:
#   http://invisible-island.net/xterm/ctlseqs/ctlseqs.html
# 
Label() { printf '%14s: ' "$1" ; } 
colorCell() { printf '[]' ; }          

# Usage: mapColorN <colorN> <red> <green> <blue> 
mapColorN() { printf '\033]4;%d;rgb:%02x/%02x/%02x\033\' $1 $2 $3 $4 ; }

# Usage: setFgColorN <colorN>
setFgColorN()   { printf '\033[38;5;%d%s' $1 m ; }
setBgColorN()   { printf '\033[48;5;%d%s' $1 m ; }

# Usage: setFgColorN <red> <green> <blue>
setFgColorRGB() { printf '\033[38;2;%d;%d;%d%s' $1 $2 $3 m ; }
setBgColorRGB() { printf '\033[48;2;%d;%d;%d%s' $1 $2 $3 m ; }

setAttrNull()   { printf '\033[0m' ; }


showTrueColors() {
  let 'n = 72'
  let 'w = n * 2'
  let 'c = 0'
  let 'pass = 1'
  while [ $c -lt $w ]
  do
    let 'b = c * 255 / w'
    let 'r = 255 - b'
    let 'g = c * 510 / w'
    [ "$g" -gt 255 ] && let 'g = 510 - g'
    let 'G = 255 - g'
    let 'B = 255 - b'
    let 'R = 255 - r'
    case $pass in 
      1) setFgColorRGB $r $g $b ; setBgColorRGB $R $G $B ;;
      2) setFgColorRGB $r $g $b ; setBgColorRGB $R $G $B ;;
      3) setFgColorRGB $r $g $b ; setBgColorRGB $R $G $B ;;
    esac
    printf ' '
    setAttrNull
    let 'c = c + 1'
    let 'm = n * (c / n)'  ; # poor mans modulo
    [ $c -eq $m ] && { let 'pass = pass + 1' ; printf '\n' ; }
    [ $c -gt $w ] && break
  done
  printf '\n'
}

mapCubeColors() {
  # ISO-8613-3 (xterm closest color matching)
  # Label 'Define 6x6x6 Cubes'
  for g in 0 1 2 3 4 5 ; do
    for r in 0 1 2 3 4 5 ; do
      for b in 0 1 2 3 4 5 ; do
        let 'R = (85 * r) / 2'
        let 'G = (85 * g) / 2'
        let 'B = (85 * b) / 2'
        let 'N = (36 * r) + (6 * g) + b + 16'
        mapColorN $N $R $G $B
      done
    done
  done
}

mapGrayColors() {
  #Label "Define Grays"
  for N in   0   1   2   3   4   5   6   7   8   9 \
            10  11  12  13  14  15  16  17  18  19 \
            20  21  22  23  24
  do 
    let 'I = (10 * N) + 8'
    mapColorN $N $I $I $I
  done
}

showNormalColors() {
  Label '[0:8] Normal'
  for N in   0   1   2   3   4   5   6   7 
  do
    setBgColorN $N 
    colorCell
  done
  setAttrNull
  printf "\n"
}

showBrightColors() {
  Label '[8:16] Bright'
  for N in   8   9  10  11  12  13  14  15
  do
    setBgColorN $N 
    colorCell
  done
  setAttrNull
  printf "\n"
}

showGrayColors() {
  Label '[232:254] Gray'
  for N in         232 233 234 235 236 237 238 239 \
           240 241 242 243 244 245 246 247 248 249 \
           250 251 252 253 254
  do 
    setBgColorN $N 
    colorCell 
  done
  setAttrNull
  printf "\n"
}

showCubeColors() {
  setAttrNull
  Label '6x6x6 Cubes'
  printf '\n'
  for g in 0 1 2 3 4 5 ; do
    for r in 0 1 2 3 4 5 ; do
      for b in 0 1 2 3 4 5 ; do
        let 'N = (36 * r) + (6 * g) + b + 16'
        setBgColorN $N 
        colorCell
      done
      setAttrNull
      printf ' '
    done
    printf '\n'
  done
  setAttrNull
  printf '\n'
}


showTerminfo() {
  echo "$(tty): ${TERM} [$(tput cols)x$(tput lines)] "
  stty | tr '\r\n' '  '
  echo
}


## main() 
{
  setAttrNull
  showTerminfo
  #mapCubeColors
  #mapGrayColors
  showNormalColors
  showBrightColors
  showGrayColors
  showCubeColors
  showTrueColors
  setAttrNull
}

