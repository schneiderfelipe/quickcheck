import random
import strformat
import sugar
import typetraits

# # TODO: define and use coarbitrary?

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


func fail[T](i:int, x: T, headline = "Failed"): string =
  let s = if i > 1: "s" else: ""
  result = &"*** {headline}! Falsifiable (after {i} test{s}):\n"
  result.addQuoted(x)


func success(n: int): string =
  &"+++ OK, passed {n} tests."


proc quick*[T](f: T -> bool): bool =
  template test(i: int, x: T): bool =
    try:
      f(x)
    except:
      debugEcho fail(i, x, "Raised")
      raise

  var x: T
  const n = 100
  for i in 1..n:
    x = arbitrary(T)
    if not test(i, x):
      debugEcho fail(i, x)
      return false
  debugEcho success(n)
  return true
