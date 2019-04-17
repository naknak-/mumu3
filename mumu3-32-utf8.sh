#!/bin/bash
mumu() { # MurmurHash3 32-bit.  Return value in $hash
  local -r key="${1?usage: murmur3 key [seed] [printf format or '' to suppress output]}" 
  local -r seed=$(( ${2:-0} )) fmt=${3-"%08x\n"} mask=$((0xffffffff))
  # https://github.com/aappleby/smhasher/blob/master/src/MurmurHash3.cpp#L94
  # https://github.com/PeterScott/murmur3/blob/master/murmur3.c#L71
  local -r mix='k=k*0xcc9e2d51&mask, h=(h^((k<<15|k>>17)*0x1b873593))&mask, h=(i+=4)<=len ? ((h<<13|h>>19)*5+0xe6546b64)&mask : h'
  local -r fmix='h^=len, h^=h>>16, h*=0x85ebca6b, h^=(h&mask)>>13, h=h*0xc2b2ae35 & mask, h^=h>>16, hash=h'
  local i=0 h=$seed k len
  if [[ $key == *[![:ascii:]]* ]]
  then # https://rosettacode.org/wiki/UTF-8_encode_and_decode
    local hexkey="" width c toUTF8='&0x3f|0x80'
    while printf -v c %d "'${key:(i++):1}" && ((c));do 
      if   (( c<0x80    ));then (( width=2 ))
      elif (( c<0x800   ));then ((                     c=(c>>6 &0x1f|0xc0)<<8 |(c$toUTF8), width=4 ))
      elif (( c<0x10000 ));then (( c=(c>>12&0x0f|0xe0)<<16 | (c>>6$toUTF8)<<8 |(c$toUTF8), width=6 ))
      else (( c=(c>>18&0x07|0xf0)<<24 | (c>>12$toUTF8)<<16 | (c>>6$toUTF8)<<8 |(c$toUTF8), width=8 ))
      fi
      printf -v c %0${width}x $c
      hexkey+=$c
    done
    len=$(( ${#hexkey} / 2 ))
    i=0
    while (( i < len )); do
      (( k=0x${hexkey:(i*2+6):2}${hexkey:(i*2+4):2}${hexkey:(i*2+2):2}${hexkey:(i*2):2}, $mix ))
    done
  else # just ascii
    len=${#key}
    while (( i < len )); do
      printf -v k %02x "'${key:(i+3):1}" "'${key:(i+2):1}" "'${key:(i+1):1}" "'${key:(i):1}" 
      (( k=0x$k, $mix ))
    done
  fi
  (( $fmix ))
  [[ -n $fmt ]] && printf $fmt $hash 
}
