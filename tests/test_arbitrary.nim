# This is just an example to get you started. You may wish to put all of your
# tests into a single file, or separate them into multiple `test1`, `test2`
# etc. files (better names are recommended, just make sure the name starts with
# the letter 't').
#
# To run these tests, simply execute `nimble test`.

import unittest

import quickcheck

suite "arbitrary primitives":
  test "arbitrary signed integers":
    check arbitrary(int8) is int8
    check arbitrary(int16) is int16
    check arbitrary(int32) is int32
    check arbitrary(int64) is int64
    check arbitrary(int) is int

    check arbitrary(int8) != arbitrary(int8)
    check arbitrary(int16) != arbitrary(int16)
    check arbitrary(int32) != arbitrary(int32)
    check arbitrary(int64) != arbitrary(int64)
    check arbitrary(int) != arbitrary(int)

  test "arbitrary unsigned integers":
    check arbitrary(uint8) is uint8
    check arbitrary(uint16) is uint16
    check arbitrary(uint32) is uint32
    check arbitrary(uint64) is uint64
    check arbitrary(uint) is uint

    check arbitrary(uint8) != arbitrary(uint8)
    check arbitrary(uint16) != arbitrary(uint16)
    check arbitrary(uint32) != arbitrary(uint32)
    check arbitrary(uint64) != arbitrary(uint64)
    check arbitrary(uint) != arbitrary(uint)

  test "arbitrary floats":
    check arbitrary(float32) is float32
    check arbitrary(float64) is float64
    check arbitrary(float) is float

    check arbitrary(float32) != arbitrary(float32)
    check arbitrary(float64) != arbitrary(float64)
    check arbitrary(float) != arbitrary(float)

  test "arbitrary chars":
    check arbitrary(char) is char

    check arbitrary(char) != arbitrary(char)

suite "arbitrary containers":
  test "arbitrary strings":
    check arbitrary(string) is string

    check arbitrary(string) != arbitrary(string)

  test "arbitrary arrays":
    const n = 10
    check arbitrary(array[n, int]) is array
    check arbitrary(array[n, uint]) is array
    check arbitrary(array[n, float]) is array
    check arbitrary(array[n, char]) is array
    check arbitrary(array[n, string]) is array

    check arbitrary(array[n, int]) != arbitrary(array[n, int])
    check arbitrary(array[n, uint]) != arbitrary(array[n, uint])
    check arbitrary(array[n, float]) != arbitrary(array[n, float])
    check arbitrary(array[n, char]) != arbitrary(array[n, char])
    check arbitrary(array[n, string]) != arbitrary(array[n, string])

  test "arbitrary sequences":
    check arbitrary(seq[int]) is seq
    check arbitrary(seq[uint]) is seq
    check arbitrary(seq[float]) is seq
    check arbitrary(seq[char]) is seq
    check arbitrary(seq[string]) is seq

    check arbitrary(seq[int]) != arbitrary(seq[int])
    check arbitrary(seq[uint]) != arbitrary(seq[uint])
    check arbitrary(seq[float]) != arbitrary(seq[float])
    check arbitrary(seq[char]) != arbitrary(seq[char])
    check arbitrary(seq[string]) != arbitrary(seq[string])

  # Bitsets?

suite "arbitrary user-defined types":
  test "arbitrary type aliases":
    type MyInteger = int
    check arbitrary(MyInteger) is MyInteger

    check arbitrary(MyInteger) != arbitrary(MyInteger)

  # test "arbitrary distinct types":
  #   type Dollars = distinct float
  #   check arbitrary(Dollars) is Dollars

  #   check arbitrary(Dollars) != arbitrary(Dollars)

  test "arbitrary enums":
    type Letter = enum
      A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q, R, S, T, U, V, X, Y, W, Z
    check arbitrary(Letter) is Letter

    check arbitrary(Letter) != arbitrary(Letter)

  # Tuples?

  # test "arbitrary objects":
  #   type Animal = object
  #     name, species: string
  #     age: int
  #   check arbitrary(Animal) is Animal

  #   check arbitrary(Animal) != arbitrary(Animal)
