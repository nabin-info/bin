#!/bin/bash
declare -i uni0=${1:-0x2500}
declare -i uniN=${2:-0x2600}

fast_chr () {
    local __octal
    local __char
    printf -v __octal '%03o' $1
    printf -v __char \\$__octal
    REPLY=$__char
}

function unichr {
    # $1 MUST be a a number
    local -i c=$1   # Ordinal of char
    local -i l=0    # Byte ctr
    local -i o=63   # Ceiling
    local -i p=128  # Accum. bits
    local s=''   # Output string
     
    # ASCII Characters
    (( c < 0x80 )) && { 
        fast_chr "$c"
        printf "$REPLY"
        return
    }

    while (( c > o )); do
        fast_chr $(( t = 0x80 | c & 0x3f ))
        s="$REPLY$s"
        (( c >>= 6, l++, p += o+1, o>>=1 ))
    done

    fast_chr $(( t = p | c ))
    printf "$REPLY$s"
}

for (( u = uni0; u < uniN; u++ )); do
    unichr $u
done
