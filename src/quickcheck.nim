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
  Property[T: Arbitrary, R: Property | bool] = object
    ## A `Property` is a representation of a statement about some data.
    ## Properties are curried by default.
    test: T -> R

  Testable* = concept t
    ## A `Testable` is any type that can be converted to a `Property`
    property(t) is Property


func property*(p: Property): auto =
  ## Return the given `Property`.
  p

func property*[T; R: Property | bool](f: T -> R): auto =
  ## A `Property` with a single input.
  Property[T,R](test: f)


proc evaluate[T](p: Property[T,bool]): (bool, T) =
  ## Evaluate a property with a single input once.
  let x = some(T)
  (p.test(x), x)


proc satisfy*(b: bool): bool =
  if not b:
    return false
  return true

proc satisfy*[T](n: Natural, p: Property[T,bool]): bool =
  var (flag, x) = evaluate p
  for i in 1..n:
    if not flag:
      echo &"Failed test no. {i}."
      echo &"there exists {x} such that"
      return false
    (flag, x) = evaluate p
  echo &"Passed {n} tests."
  return true

proc satisfy*(n: Natural, t: Testable): bool =
  ## Convert a `Testable` into a `Property` and determine whether the
  ## `Property` is satisfied.
  satisfy(n, property t)

proc satisfy*(t: Testable): bool =
  ## Convert a `Testable` into a `Property` and determine whether the
  ## `Property` is satisfied. By default, 100 tests are attempted.
  satisfy(100, t)
