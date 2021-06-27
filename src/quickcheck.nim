import sugar

type
  Property[T] = object
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
  p.test(1)

type
  Testable* = concept a
    ## A `Testable` is any type that can be converted to a `Property`
    property(a) is Property

proc satisfy*(t: Testable): bool =
  ## Convert a `Testable` into a `Property` and determine whether the
  ## `Property` is satisfied.
  let p = property t
  evaluate p
