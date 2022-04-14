import unittest, quickcheck, algorithm, sugar

# randomize


# https://github.com/nim-lang/Nim/issues/18466
template fail(conditions: auto): auto =
  ## A convenience meaning the exact opposite of `check`.
  check(not (conditions))


suite "Trivial functionality":
  test "a successful trivial property":
    check satisfy do () -> bool:
      true

  test "a failing trivial property":
    fail satisfy do () -> bool:
      false

  test "sugar syntax works as well":
    check satisfy () => true
    fail satisfy () => false


suite "Simple properties with parameters":
  test "a simple property with an ignored parameter":
    check satisfy do (_: int) -> bool:
      true

  test "a simple property with a single parameter":
    check satisfy do (n: range[0..50]) -> bool:
      0 <= n and n <= 50

  test "a simple property with more than one parameter":
    check satisfy do (n: int8, m: range[1'i8..high(int8)]) -> bool:
      # `range[1...]` is used to avoid division by zero
      m * int(n) mod m == 0 # convert to avoid overflow


suite "Simple properties that return a result type":
  test "a simple property that returns a result type that is always `Ok`":
    check satisfy do (_: int) -> EvalResult[int]:
      EvalResult[int].ok true

  test "a simple property that returns a result type that is *not* always `Ok`":
    check satisfy do (n, m: int8) -> EvalResult[(int8, int8)]:
      if m == 0:
        EvalResult[(int8, int8)].skip (n, m), "avoid division by zero"
      else:
        EvalResult[(int8, int8)].ok m * int(n) mod m == 0 # convert to avoid overflow


suite "Properties with preconditions":
  test "a property with a precondition for integers":
    check satisfy do (n, m: int8) -> EvalResult[(int8, int8)]:
      # `==>` is used to avoid division by zero
      m != 0 ==>
        m * int(n) mod m == 0 # convert to avoid overflow

  test "a property with a precondition for sequences that fails":
    expect(IndexDefect): discard satisfy do (xs: seq[int], n: range[0'i8..high(
        int8)]) -> auto:
      xs[n] == xs[n..^1][0]

  test "a property with a precondition for sequences that succeeds":
    check satisfy do (xs: seq[int], n: range[0'i8..high(int8)]) -> EvalResult[(
        seq[int], range[0'i8..high(int8)])]:
      # `==>` is used to avoid index out of range
      n < len(xs) ==>
        xs[n] == xs[n..^1][0]

  # test "a property with an impossible precondition":
  #   fail satisfy do () -> EvalResult[void]:
  #     false ==> true

  test "a property with a rare precondition":
    fail satisfy do (n: uint8) -> EvalResult[uint8]:
      n in {2, 3, 5, 23, 42} ==> true


suite "Simple use cases":
  test "some invariants of the `reversed` function":
    check satisfy do (xs: string) -> bool:
      xs.reversed.reversed == xs

    fail satisfy do (xs, ys: string) -> bool:
      (xs & ys).reversed == xs.reversed & ys.reversed

    check satisfy do (xs, ys: string) -> bool:
      (xs & ys).reversed == ys.reversed & xs.reversed
