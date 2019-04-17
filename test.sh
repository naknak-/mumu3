#!/bin/bash
TestString() {
    local str="$1" seed="$2" expect="$3" func=${func:-murmur3}
    local result=0x$( $func "$str" "$seed" )
    if [[ -z "$expect" ]];  then echo "bad params: $@"; exit 0; fi
    if (( result == $expect ))
    then (( test_ok++ )) 
    else 
        printf "%-50s [seed %10s] expected %10s got %10s\n" "$str" "$seed" "$expect" "$result"
        (( test_fail++ ))
    fi
}

time {
  test_ok=0 test_fail=0
  TestString "" 0 0
  TestString "" 1 0x514E28B7
  TestString "" 0xffffffff 0x81F16F39
  # bash can't store NULL in a string -- TestString "\0\0\0\0" 0 0x2362F9DE
  TestString "abcd" 0x9747b28c 0xF0478627
  TestString "abc" 0x9747b28c 0xC84A62DD
  TestString "ab" 0x9747b28c 0x74875592
  TestString "a" 0x9747b28c 0x7FA09EA6
  TestString "Hello, world!" 0x9747b28c 0x24884CBA
  TestString "ππππππππ" 0x9747b28c 0xD58063C1
  TestString "€𠳏b✗a"            0 0xda7915bd
  #don't store length in a byte and overflow at 255 as OpenBSD's canonical BCrypt implementation did
  TestString $( printf a%.0s {1..256} ) 0x9747b28c 0x37405BDC

  (( test_fail == 0 )) && [[ -r /dev/urandom ]] && type -P murmur >/dev/null && \
    for s in $( tr -dc a-z</dev/urandom |fold -w43 |grep . |head -1000 ); do 
      TestString $s 0 $( echo -n $s | murmur 2>/dev/null )
    done

  echo "ok $test_ok fail $test_fail"
}
