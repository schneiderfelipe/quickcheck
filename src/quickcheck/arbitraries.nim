import
  random,
  strformat,
  sugar,
  tables,
  typetraits

# TODO: check how quickcheck defines arbitrary for typical types in Haskell
# TODO: define and use coarbitrary?

# TODO: support nestedness and generic types. Recursive types requires some
# type of depth analysis.

# TODO: ensure good char and string arbitraries.

# TODO: transform arbitrary into a proc/func, not a template. We want the
# user to overload it if she wants.
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
    raise newException(ValueError, &"could not generate arbitrary {$T}, please open an issue at https://github.com/schneiderfelipe/quickcheck/issues/new")
  result

template arbitrary*(T: typedesc[array]): auto =
  var result: T
  for i in low(T)..high(T):
    result[i] = arbitrary(elementType(result))
  result

# TODO: generalize to functions of arbitrary inputs?
# TODO: generalize to functions of arbitrary outputs?
proc arbitrary*[R, S](T: typedesc[R -> S]): auto =
  var cache: Table[R, S]
  let result = proc(x: R): S =
    if x notin cache:
      cache[x] = arbitrary(S)
    cache[x]
  result
