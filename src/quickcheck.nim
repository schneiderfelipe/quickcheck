import random
import sugar
import typetraits

# # TODO: define and use coarbitrary?

template arbitrary*(T: typedesc): auto =
  var result: T
  when compiles(rand(T)):
    # Matches integers, etc.
    result = rand(T)
  elif compiles(rand(low(T)..high(T))):
    # Matches floats, etc.
    result = rand(low(T)..high(T))
  elif compiles(elementType(result)):
    # Matches sequences, strings, etc.
    for _ in 0'u8..<arbitrary(uint8):
      result.add arbitrary(elementType(result))
  else:
    raise newException(ValueError, "could not generate arbitrary " & $T & ", please open an issue at https://github.com/schneiderfelipe/quickcheck/issues/new")
  result

template arbitrary*(T: typedesc[array]): auto =
  var result: T
  for i in low(T)..high(T):
    result[i] = arbitrary(elementType(result))
  result

import unittest
proc quickcheck*[T](test: T -> bool) =
  const n = 100
  for i in 0..<n:
    try:
      check test(arbitrary(T))
    except:
      echo "*** Failed! Falsifiable (after " & $i & " test):"
      return
  echo "+++ OK, passed " & $n & " tests."
