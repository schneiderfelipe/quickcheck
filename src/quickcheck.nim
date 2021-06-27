import
  random,
  strformat,
  sugar


type
  Arbitrary* = concept a
    ## An `Arbitrary` type is any type `T` for which `some(T)` returns an
    ## arbitrary value of type `T`.
    some(typeof(a)) is typeof(a)

proc some*(_: typedesc[int]): int =
  ## Generate an arbitrary `int`.
  rand(int)


type
  Property[T: Arbitrary | void] = object
    ## A `Property` is a representation of a statement about some data.
    test: T -> bool

func property*(b: bool): auto =
  ## A `Property` without any input, constructed from a `bool`.
  Property[void](test: () => b)

func property*(f: () -> bool): auto =
  ## A `Property` without any input.
  Property[void](test: f)

func property*[T](f: T -> bool): auto =
  ## A `Property` with a single input.
  Property[T](test: f)

func property*(p: Property): auto =
  ## Return the given `Property`.
  p

proc evaluate(p: Property[void]): bool =
  ## Evaluate a property without any input once.
  p.test()

proc evaluate[T](p: Property[T]): bool =
  ## Evaluate a property with a single input once.
  p.test(some(T))


type
  Testable* = concept t
    ## A `Testable` is any type that can be converted to a `Property`
    property(t) is Property

proc satisfy*(n: Natural, t: Testable): bool =
  ## Convert a `Testable` into a `Property` and determine whether the
  ## `Property` is satisfied.
  let p = property t
  for i in 1..n:
    if not evaluate p:
      echo &"Failed after {i} tests."
      return false
  echo &"Passed {n} tests."
  return true

proc satisfy*(t: Testable): bool =
  ## Convert a `Testable` into a `Property` and determine whether the
  ## `Property` is satisfied. By default, 100 tests are attempted.
  satisfy(100, t)
