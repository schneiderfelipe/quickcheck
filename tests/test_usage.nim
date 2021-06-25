import algorithm
import random
import sugar
import unittest

import quickcheck

# func debugTrace[T](x: T): T =
#   debugEcho x
#   x

randomize()

suite "usage":
  test "can reverse strings":
    quickcheck ((s: string) -> bool => s.reversed.reversed == s)

  test "can take five":
    func take5[T](xs: openArray[T]): seq[T] =
      # if len(xs) > 5:
        xs[0..<5]
      # else:
      #   xs
    quickcheck ((s: string) -> bool => len(s.take5) <= 5)
