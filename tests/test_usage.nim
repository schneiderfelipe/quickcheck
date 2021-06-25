import algorithm
import sugar
import unittest

import quickcheck

suite "usage":
  test "can reverse strings":
    quickcheck ((s: string) -> bool => s.reversed.reversed == s)
