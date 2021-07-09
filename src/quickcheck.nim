import macros, random, results, strformat, typetraits
export ok


template skip*[T, E](R: type Result[T, E], x: auto): Result[T, E] =
  ## Convenience to skip tests. Synonymous to `Result.err`.
  R.err x


type EvalResult* =
  Result[bool, string] # TODO: string for now
  ## Result of a property evaluation.


template someImpl(T: typedesc): auto =
  ## Generic implementation of `some`.
  var res: T
  when compiles rand(T):
    # Match integers, ranges, etc.
    res = rand(T)
  elif compiles rand(low(T)..high(T)):
    # Match floats, enums without holes, etc.
    res = rand(low(T)..high(T))
  elif compiles elementType res:
    # Match sequences, strings, etc. (but not arrays)
    for _ in 0'u8..<some(uint8):
      res.add some(elementType res)
  else:
    raise newException(ValueError, &"could not generate arbitrary {$T}, please open an issue at https://github.com/schneiderfelipe/quickcheck/issues/new")
  res


proc some*(T: typedesc): T =
  ## Generate an arbitrary value of type `T`.
  someImpl T


# https://forum.nim-lang.org/t/8205#52769
func toUntyped(n: NimNode): NimNode =
  ## Untype a given typed `NimNode`.
  ##
  ## This is used to reconstruct code for types, from a `NimNode` for the
  ## given type. This is required to avoid problems with `typed` parameters
  ## in macros.
  func toUntypedGeneric(n: NimNode): NimNode =
    ## Fallback for `toUntyped`.
    if len(n) == 0:
      result = n
    else:
      result = newTree n.kind
      for ch in n:
        result.add ch.toUntyped

  case n.kind:
  of nnkSym:
    result = ident n.strVal
  of nnkBracketExpr:
    # Required so that we avoid "Error: 'range' expects one type parameter".
    # Maybe related: https://github.com/nim-lang/Nim/issues/15833
    n[0].expectKind nnkSym
    case n[0].strVal:
    of "range":
      let
        start = n[1]
        stop = n[2]
      result = quote do:
        range[`start`..`stop`]
    else:
      result = n.toUntypedGeneric
  else:
    result = n.toUntypedGeneric


macro eval(f: proc): EvalResult =
  ## Evaluate function `f` once with arbitrary arguments. If
  ## `f` does not return an `EvalResult`, it will be wrapped in it, i.e.,
  ## `EvalResult.ok f(...)`.
  func validateProcType(ty: NimNode, n: Natural) =
    # - `f` must be a `proc`
    # - `f` must return either a `bool` or a `Result`
    # - `f` parameters should be symbols or bracket expressions (for the case of ranges)
    ty.expectKind nnkBracketExpr
    ty[0].expectKind nnkSym
    assert ty[0].strVal == "proc"
    ty[1].expectKind nnkSym
    assert ty[1].strVal in ["bool", "Result"]
    for i in 2..<n+2:
      ty[i].expectKind {nnkSym, nnkBracketExpr}

  func callWithSome(f: NimNode): NimNode =
    let
      ty = getType f

      # Number of parameters of `f`
      n = len(ty) - 2

    validateProcType(ty, n)

    result = newCall f
    var pty: NimNode
    for i in 2..<n+2:
      pty = toUntyped ty[i]
      result.add quote do:
        some(`pty`)

    if ty[1].strVal == "bool":
      result = quote do:
        EvalResult.ok `result`

  callWithSome f


proc satisfy*(f: proc): bool =
  ## Test a property. This means evaluating it many times and check if they
  ## all succeed.
  var res: EvalResult
  for i in 0..<1000:
    res = eval f
    if res.isOk and not res.get:
      # TODO: we currently ignore left values.
      return false
  return true


# TODO: we use a template because we what things to be lazy: if `p` is not
# satisfied, we should still evaluating `f`.
template `==>`*(p, f: bool): EvalResult =
  ## Produce a new property that meaning "`p` implies `f`".
  if not p:
    EvalResult.skip "precondition fails"
  else:
    EvalResult.ok f
