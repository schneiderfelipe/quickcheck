import
  strformat,
  sugar,
  terminal

import quickcheck/arbitrary
export arbitrary

const prefix = "  "

proc failed(i: int, xs: tuple, raised = false) =
  let headline = if not raised: "Failed" else: "Raised"
  let s = if i > 1: "s" else: ""
  stdout.styledWriteLine(styleBright, fgMagenta, prefix, "*** ", resetStyle,
      &"{headline}! Falsifiable (after {i} test{s}):")

  for x in xs.fields:
    var line: string = prefix & prefix
    line.addQuoted(x)
    echo line

proc succeeded(n: int) =
  stdout.styledWriteLine(styleBright, fgCyan, prefix, "+++ ", resetStyle,
      &"OK, passed {n} tests.")

proc quick*[T](f: T -> bool): bool =
  proc test(i: int, x: T): bool =
    try:
      f(x)
    except:
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
  proc test(i: int, x: S, y: T): bool =
    try:
      f(x, y)
    except:
      failed(i, (x, y), raised = true)
      raise

  var x: S
  var y: T
  const n = 100
  for i in 1..n:
    x = arbitrary(S)
    y = arbitrary(T)
    if not test(i, x, y):
      failed(i, (x, y))
      return false
  succeeded(n)
  return true
