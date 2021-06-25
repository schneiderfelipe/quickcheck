# This is just an example to get you started. You may wish to put all of your
# tests into a single file, or separate them into multiple `test1`, `test2`
# etc. files (better names are recommended, just make sure the name starts with
# the letter 't').
#
# To run these tests, simply execute `nimble test`.

import unittest

import quickcheck

suite "arbitraries":
  test "arbitrary signed integers":
    check arbitrary(int8) is int8
    check arbitrary(int16) is int16
    check arbitrary(int32) is int32
    check arbitrary(int64) is int64
    check arbitrary(int) is int

  test "arbitrary unsigned integers":
    check arbitrary(uint8) is uint8
    check arbitrary(uint16) is uint16
    check arbitrary(uint32) is uint32
    check arbitrary(uint64) is uint64
    check arbitrary(uint) is uint

  test "arbitrary floats":
    check arbitrary(float32) is float32
    check arbitrary(float64) is float64
    check arbitrary(float) is float

  test "arbitrary chars":
    check arbitrary(char) is char

  test "arbitrary strings":
    check arbitrary(string) is string

  test "arbitrary arrays":
    check arbitrary(array[10, int]) is array

  test "arbitrary sequences":
    check arbitrary(seq[int]) is seq

  # TODO: bitsets

  test "arbitrary type aliases":
    type MyInteger = int
    check arbitrary(MyInteger) is MyInteger

  test "arbitrary distinct types":
    type Dollars = distinct float
    # TODO: make it work
    # check arbitrary(Dollars) is Dollars

  test "arbitrary enums":
    type CompassDirections = enum
      cdNorth, cdEast, cdSouth, cdWest
    check arbitrary(CompassDirections) is CompassDirections

  # TODO: tuples

  test "arbitrary objects":
    type Animal = object
      name, species: string
      age: int
    # TODO: make it work
    # check arbitrary(Animal) is Animal