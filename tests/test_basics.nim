import
  sugar,
  unittest

import quickcheck

suite "Arbitrary types":
  test "Integers are arbitraries":
    check int is Arbitrary

suite "Testable types":
  test "Booleans are testable":
    for b in [true, false]:
      check b is Testable

  test "Zero-argument functions returning booleans are testable":
    for b in [true, false]:
      check (() => b) is Testable

  test "Single-argument functions returning booleans are testable":
    for b in [true, false]:
      check ((n: int) => b) is Testable

  test "Properties are testable":
    for b in [true, false]:
      check property(b) is Testable
      check property(() => b) is Testable
      check property((n: int) => b) is Testable

suite "Basic usage examples":
  test "satify accepts booleans":
    check satisfy true

  test "satify accepts zero-argument functions":
    check satisfy () => true

  test "satify accepts single-argument functions":
    check satisfy (x: int) => true

  test "satify accepts properties":
    check satisfy property(true)
    check satisfy property(() => true)
    check satisfy property((x: int) => true)

suite "Using options":
  test "satify accepts an integer parameter":
    check satisfy(10) do: true
    check satisfy(10) do () -> bool: true
    check satisfy(10) do (x: int) -> bool:
      true
