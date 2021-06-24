# This is just an example to get you started. You may wish to put all of your
# tests into a single file, or separate them into multiple `test1`, `test2`
# etc. files (better names are recommended, just make sure the name starts with
# the letter 't').
#
# To run these tests, simply execute `nimble test`.

import sugar
import unittest

import quickcheck

suite "utilities":
  test "arbitraries":
    check arbitrary(char) is char
    check arbitrary(string) is string

import algorithm
suite "usage":
  test "can reverse strings":
    quickcheck ((s: string) -> bool => s.reversed.reversed == s)
