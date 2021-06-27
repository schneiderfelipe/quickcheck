import
  sugar,
  unittest

import quickcheck


suite "Arbitrary types":
  test "Integers are arbitraries":
    check int is Arbitrary


suite "Testable types":
  test "Single-argument functions returning booleans are testable":
    for b in [true, false]:
      check ((n: int) => b) is Testable

  test "Properties are testable":
    for b in [true, false]:
      check property((n: int) => b) is Testable


suite "Basic usage examples":
  test "satisfy accepts booleans":
    check satisfy true

  test "satisfy accepts single-argument functions":
    check satisfy (x: int) => true

  test "satisfy accepts properties":
    check satisfy property((x: int) => true)


suite "Using options":
  test "satisfy accepts an integer parameter":
    check satisfy(10) do (x: int) -> bool:
      true


# suite "Use case: properties of addition on integers":
#   test "closure":
#     check satisfy do (n, m: int) -> auto:
#       n + m is int
