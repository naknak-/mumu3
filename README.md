This code implements [MurmurHash3](https://github.com/aappleby/smhasher/wiki/MurmurHash3)'s [32-bit hashing function](https://github.com/aappleby/smhasher/blob/master/src/MurmurHash3.cpp#L94) in pure bash.  

For short strings, bash can be 10 times faster than a C implementation, because there is no executable overhead.

As string length increases, the bash implementation exhibits a quadratic increase in runtime.  This is because indexing strings in bash is linear in the size of the index.

**Benchmarks** (seconds, lower is better; `*` = best):
```
                                bash-utf8    bash-ascii       C
  20000 hashes, ASCII words        1.86         1.58 *      19.17
1000 hashes, 100 bytes UTF8        1.01         0.36 *       0.91
         1 hash,  1KB  UTF8        0.020        0.009        0.002 *        
         1 hash, 10KB  UTF8        1.63         0.77         0.005 *
         1 hash, 20KB  UTF8        6.31         3.02         0.010 *
```

**Usage**
```
source mumu3-32-utf8.sh

source test.sh # optional!

mumu "€𠳏b✗a" # prints da7915bd
echo "$hash"  # hash=3665368509, 0xda7915bd in decimal

mumu "€𠳏b✗a" 0xABCDEF      # with initial seed
mumu "€𠳏b✗a" "" ""         # no initial seed, suppress output, output in $hash only
mumu "€𠳏b✗a" "" "%d\n"     # prints 3665368509: non-empty third argument is a printf format
mumu "€𠳏b✗a" "" "0x%08X\n" # prints 0xDA7915BD
```

**Notes**

- test.sh needs a reference implementation (recommend Peter Scott's [MurmurHash3 in C](https://github.com/PeterScott/murmur3)) to perform random tests.  If absent, only the hardcoded tests are performed.
- the ASCII-only version is much shorter, but only slightly faster for ASCII-only input, because the UTF8 version will fall back to the faster ASCII-only algorithm if the input allows it.  ASCII function can still hash UTF8 inputs, but gives different results than a reference implementation, due to byte ordering issues.
