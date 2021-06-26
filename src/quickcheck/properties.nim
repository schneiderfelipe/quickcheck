import
  strformat,
  sugar,
  terminal

import arbitraries

const prefix = "  "

# TODO: receive some kind of Reason object that stores the reasons of the
# failure.
proc failed(i: int, xs: tuple, raised = false) =
  let
    headline = if not raised: "Failed" else: "Raised"
    s = if i > 1: "s" else: ""
  # TODO: I think the output in case of error is fine, but we need shrinking.
  stdout.styledWriteLine(styleBright, fgMagenta, prefix, "*** ", resetStyle,
      &"{headline}! Falsifiable (after {i} quick test{s}):")

  # TODO: print something like:
  #
  # there exists [0,1] such that
  #   condition is false
  #
  # or
  #
  # there exists [0,1] such that
  #   reverse x = [1,0]
  #
  # or
  #
  # Failed test no. 4.
  # there exists 4 such that
  #   condition is false
  #
  # or
  #
  # Failed test no. 12.
  # there are at least two arguments satisfying the property:
  #   for 0
  #     condition is true
  #   for 1
  #     property is vacuously true because
  #       there exists -1 such that
  #         condition is false

  for x in xs.fields:
    var line: string = prefix & prefix
    when compiles($x):
      line.addQuoted(x)
    else:
      line &= $typeof(x)
    echo line

proc succeeded(n: int) =
  # TODO: Maybe improve output in case of success? What extras can we write?
  stdout.styledWriteLine(styleBright, fgCyan, prefix, "+++ ", resetStyle,
      &"OK, passed {n} quick tests.")

# TODO: functions should not need to return bool, as long as they return other
# properties. So we need a Property type, defined as a function that returns a
# bool or another property. Or, this is the Testable type and the Property
# type is something else.

# TODO: too much repeated code in quick procs. We might need a single one or
# two, the current design doesn't scale well.
proc quick*[T](f: T -> bool): bool =
  template test(i: int, x: T): bool =
    try:
      f(x)
    except:
      # TODO: should this be `finally:`?
      failed(i, (x,), raised = true)
      raise

  var x: T
  const n = 100
  for i in 1..n:
    x = arbitrary(T)
    if not test(i, x):
      failed(i, (x,))
      return false
  succeeded(n)
  return true

proc quick*[S, T](f: (S, T) -> bool): bool =
  template test(i: int, x: S, y: T): bool =
    try:
      f(x, y)
    except:
      # TODO: should this be `finally:`?
      failed(i, (x, y), raised = true)
      raise

  var
    x: S
    y: T
  const n = 100
  for i in 1..n:
    x = arbitrary(S)
    y = arbitrary(T)
    if not test(i, x, y):
      failed(i, (x, y))
      return false
  succeeded(n)
  return true

proc quick*[R, S, T](f: (R, S, T) -> bool): bool =
  template test(i: int, x: R, y: S, z: T): bool =
    try:
      f(x, y, z)
    except:
      # TODO: should this be `finally:`?
      failed(i, (x, y, z), raised = true)
      raise

  var
    x: R
    y: S
    z: T
  const n = 100
  for i in 1..n:
    x = arbitrary(R)
    y = arbitrary(S)
    z = arbitrary(T)
    if not test(i, x, y, z):
      failed(i, (x, y, z))
      return false
  succeeded(n)
  return true
