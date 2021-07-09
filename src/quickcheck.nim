import macros, random, results, strformat, terminal, typetraits
export ok


type
  EvalResult*[T] =
    Result[bool, (T, string)]
    ## Result of a single property evaluation. The error part contains an
    ## evaluation counter-example and an optional message.

  TrialState = enum
    ## Final state of a `TrialResult`.
    Success, GaveUp, Failure #, NoExpectedFailure
  TrialResult = object
    ## Result of a complete property trial.
    case state: TrialState:
    of Failure:
      exception: ref Exception
    else:
      discard
    evals, succs, skips: Natural
    # , fails?


template skip*[T](R: type EvalResult[T], x: T, s = ""): EvalResult[T] =
  ## Convenience to skip checks.
  R.err (x, s)


template skip*[T](R: type EvalResult[T], s = ""): EvalResult[T] =
  ## Convenience to skip checks when the current parameter is not important.
  var x: T
  R.skip(x, s)


template skip*(R: type EvalResult[void], s = ""): EvalResult[void] =
  ## Convenience to skip checks when the current parameter is not important.
  var r: (void, string)
  r[1] = s
  R.err r


converter toBool(r: TrialResult): bool =
  ## Convert a `TrialResult` to `bool`.
  case r.state:
  of Success: return true
  of Failure, GaveUp: return false


proc trigger(r: TrialResult): bool =
  ## Display a `TrialResult`, return its equivalent `bool` value and, if
  ## applicable, raise an exception.
  func s(n: Natural): string =
    if n > 1 or n == 0:
      "s"
    else:
      ""


  proc displayMsg(pref, msg: string, prefFg: ForegroundColor) =
    stdout.styledWriteLine(styleBright, prefFg, "  ", pref, resetStyle, msg)


  proc displaySucc(succ: Natural) =
    displayMsg("+++ ", &"OK, passed {succ} quick check{s(succ)}.", fgCyan)


  proc displayGave(succ: Natural) =
    displayMsg("*** ", &"Gave up! Passed only {succ} quick check{s(succ)}.", fgMagenta)


  proc displayFail(headline: string, n: Natural) =
    displayMsg("*** ", &"{headline}! Falsifiable (after {n} quick check{s(n)}):", fgMagenta)
    # TODO: in order to show a counter-example, we can enhance the result
    # type to return the given parameters.


  case r.state:
  of Success:
    displaySucc(r.succs)
  of Failure:
    # TODO: in order to show a counter-example, we can enhance the result
    # type to return the given parameters.
    if isNil(r.exception):
      displayFail("Failed", r.evals)
    else:
      displayFail("Raised", r.evals)
      raise r.exception
  of GaveUp:
    displayGave(r.succs)

  r.toBool


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


# TODO: support strings and functions
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


func getTypeOfParamsImpl(f: NimNode): NimNode =
  let
    ty = getType f
    # Number of parameters of `f`
    n = len(ty) - 2

  validateProcType(ty, n)

  if n > 0:
    result = newPar()
    for i in 2..<n+2:
      result.add toUntyped ty[i]
  else:
    result = quote do:
      void


macro getTypeOfParams(f: proc): typedesc =
  getTypeOfParamsImpl(f)


macro eval(f: proc): auto =
  ## Evaluate function `f` once with arbitrary arguments. If
  ## `f` does not return an `EvalResult[T]`, it will be wrapped in it, i.e.,
  ## `EvalResult[T].ok f(...)`.
  func getRetType(f: NimNode): NimNode =
    let
      ty = getType f
      # Number of parameters of `f`
      n = len(ty) - 2

    validateProcType(ty, n)

    result = ty[1]


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

    let typ = getTypeOfParamsImpl(f)
    if getRetType(f).strVal == "bool":
      result = quote do:
        EvalResult[`typ`].ok `result`

  callWithSome f


# TODO: we currently ignore left values.
proc satisfy*(f: proc): bool =
  ## Check a property. This means evaluating it many times and check if they
  ## all succeed.
  proc satisfyImpl(f: proc): TrialResult =
    type T = getTypeOfParams(f)
    const
      maxsuccs = 100
      maxevals = 1000
    var
      evals = 1
      succs = 0
      res: EvalResult[T]
    while evals <= maxevals:
      try:
        res = eval f
      except:
        return TrialResult(state: Failure, evals: evals, succs: succs,
            exception: getCurrentException())
      if res.isOk:
        if not res.get:
          return TrialResult(state: Failure, evals: evals, succs: succs,
              exception: getCurrentException())
        inc succs
      if succs >= maxsuccs:
        return TrialResult(state: Success, evals: evals, succs: succs)
      inc evals
    return TrialResult(state: GaveUp, evals: evals, succs: succs)


  trigger satisfyImpl f


# TODO: we use a template because we what things to be lazy: if `p` is not
# satisfied, we should still evaluating `f`.
template `==>`*(p, f: bool): auto =
  ## Produce a new property that meaning "`p` implies `f`".
  if not p:
    typeof(result).skip "precondition fails"
  else:
    typeof(result).ok f
