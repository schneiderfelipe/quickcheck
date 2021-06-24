import random
import sugar

proc arbitrary*(_: typedesc[char]): char =
  rand(chr(32)..chr(128))

# TODO: define and use coarbitrary

proc arbitrary*(_: typedesc[string]): string =
  for _ in 0..<10:
    result.add arbitrary(char)

import unittest
proc quickcheck*[T](test: T -> bool) =
  for _ in 0..<100:
    check test(arbitrary(T))
