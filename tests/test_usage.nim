import algorithm
import math
import sequtils
import sugar

import unittest

import quickcheck

# func debugTrace[T](x: T): T =
#   debugEcho x
#   x

suite "usage":
  test "fnord":
    check 1 == 0

  test "quick fnord":
    check quick ((_: int) => 1 == 0)

  test "quick fnord2":
    check quick do (_: int) -> auto:
      1 == 0

  test "squares are positive":
    check quick ((i: int) => i^2 > 0)

  test "can reverse strings":
    check quick ((s: string) => s.reversed.reversed == s)

  test "can take five":
    func take5[T](xs: openArray[T]): seq[T] =
      let ys = xs.filter(x => x in {'a'..'e'})
      if len(ys) > 5:
        ys[0..<5]
      else:
        @ys
    check:
      quick ((s: string) => len(s.take5) <= 5)
      quick ((s: string) => s.take5.all(x => x in {'a'..'d'}))
      quick ((s: string) => s.take5.all(x => x in {'a'..'e'}))
