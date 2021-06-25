import strformat
import sugar
import terminal
import typetraits
import random

const prefix = "  "

# TODO: define and use coarbitrary?

template arbitrary*(T: typedesc): auto =
  var result: T
  when compiles(rand(T)):
    # Matches integers, etc.
    result = rand(T)
  elif compiles(rand(low(T)..high(T))):
    # Matches floats, etc.
    result = rand(low(T)..high(T))
  elif compiles(elementType(result)):
    # Matches sequences, strings, etc.
    for _ in 0'u8..<arbitrary(uint8):
      result.add arbitrary(elementType(result))
  else:
    raise newException(ValueError, &"could not generate arbitrary {T}, please open an issue at https://github.com/schneiderfelipe/quickcheck/issues/new")
  result

template arbitrary*(T: typedesc[array]): auto =
  var result: T
  for i in low(T)..high(T):
    result[i] = arbitrary(elementType(result))
  result






proc failed[T](i:int, x: T, raised = false) =
  let headline = if not raised: "Failed" else: "Raised"
  let s = if i > 1: "s" else: ""
  stdout.styledWriteLine(styleBright, fgMagenta, prefix, "*** ", resetStyle, &"{headline}! Falsifiable (after {i} test{s}):")

  var line: string = prefix & prefix
  line.addQuoted(x)
  echo line


proc succeeded(n: int) =
  stdout.styledWriteLine(styleBright, fgCyan, prefix, "+++ ", resetStyle, &"OK, passed {n} tests.")


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
