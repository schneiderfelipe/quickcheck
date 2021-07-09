import unittest, quickcheck


# https://github.com/nim-lang/Nim/issues/18466
template fail(conditions: auto): auto =
  ## A convenience meaning the exact opposite of `check`.
  check(not (conditions))


suite "Trivial functionality":
  test "pass a successful trivial property":
    check satisfy do () -> bool:
      true

  test "don't pass a failing trivial property":
    fail satisfy do () -> bool:
      false


suite "Simple properties with parameters":
  test "pass a simple property with an ignored parameter":
    check satisfy do (_: int) -> bool:
      true

  test "pass a simple property with a used parameter":
    check satisfy do (n: range[0..50]) -> bool:
      0 <= n and n <= 50

  test "pass a simple property with more than one parameter":
    check satisfy do (n: int8) -> bool:
      2 * int(n) mod 2 == 0 # convert to avoid overflow
