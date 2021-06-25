import random
import sugar
import typetraits

# # TODO: define and use coarbitrary?

template arbitrary*(T: typedesc): auto =
  var result: T
  when compiles(rand(T)):
    result = rand(T)
  elif compiles(rand(low(T)..high(T))):
    result = rand(low(T)..high(T))
  elif compiles(elementType(result)):
    for _ in 0'u8..<arbitrary(uint8):
      result.add arbitrary(elementType(result))
  else:
    raise newException(ValueError, "cannot generate arbitrary " & $T)
  # debugEcho result
  result

template arbitrary*(T: typedesc[array]): auto =
  var result: T
  for i in low(T)..high(T):
    result[i] = arbitrary(elementType(result))
  result

# proc arbitrary*(_: typedesc[string]): string =
#   for _ in 0..<10:
#     result.add arbitrary(char)

import unittest
proc quickcheck*[T](test: T -> bool) =
  for _ in 0..<100:
    check test(arbitrary(T))
