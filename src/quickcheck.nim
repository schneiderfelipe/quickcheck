import
  strformat,
  sugar,
  terminal

import quickcheck/arbitrary
export arbitrary

const prefix = "  "

proc failed[T](i: int, x: T, raised = false) =
  let headline = if not raised: "Failed" else: "Raised"
  let s = if i > 1: "s" else: ""
  stdout.styledWriteLine(styleBright, fgMagenta, prefix, "*** ", resetStyle,
      &"{headline}! Falsifiable (after {i} test{s}):")

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
      failed(i, x, raised = true)
      raise

  var x: T
  const n = 100
  for i in 1..n:
    x = arbitrary(T)
    if not test(i, x):
      failed(i, x)
      return false
  succeeded(n)
  return true
