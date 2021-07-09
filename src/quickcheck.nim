import macros, random, results, strformat

# TODO: it is better to use a more meaningful API and not `err`. Some ideas:
# - EvalResult.skip
# - EvalResult.fail/err
export ok, err


type EvalResult* = Result[bool, string] # TODO: string for now


func rebuildType(ty: NimNode): NimNode =
  ## Reconstruct code for a type, from a `NimNode` for the same type. This is
  ## required to avoid problems with `typed` parameters in macros.
  case ty.kind:
  of nnkSym:
    return ident(ty.strVal)
  of nnkBracketExpr:
    if ty[0].kind == nnkSym and ty[0].strVal == "range":
      let
        start = ty[1]
        stop = ty[2]
      return quote do:
        range[`start`..`stop`]
  else:
    discard
  raise newException(ValueError, &"could not handle type: {repr ty}")


func randCall(f: NimNode): NimNode =
  ## Generate code for a call to a function `f` with random arguments. If `f`
  ## does not return an `EvalResult`, it will be wrapped in it, i.e.,
  ## `EvalResult.ok f(...)`.
  let
    ty = getType f

    # Number of parameters of `f`
    n = len(ty) - 2


  # Validate `NimNode`:
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


  result = newCall(f)
  var pty: NimNode
  for i in 2..<n+2:
    pty = rebuildType ty[i]
    result.add quote do:
      rand(`pty`)

  if ty[1].strVal == "bool":
    result = quote do:
      EvalResult.ok `result`


macro eval(f: proc): EvalResult =
  ## Evaluate `f` once with random arguments. If `f` does not return an
  ## `EvalResult`, it will be wrapped in it, i.e., `EvalResult.ok f(...)`.
  randCall(f)


proc satisfy*(f: proc): bool =
  ## Test a property. This means evaluating it many times and check if they
  ## all succeed.
  var res: EvalResult
  for i in 0..<1000:
    res = eval f
    if res.isOk and not res.get():
      # TODO: we currently ignore `err`
      return false
  return true


# TODO: we use a template because we what things to be lazy: if `p` is not
# satisfied, we should still evaluating `f`.
template `==>`*(p, f: bool): EvalResult =
  ## Produce a new property that meaning "`p` implies `f`".
  if not p:
    EvalResult.err "skip due to unsatisfied predicate"
  else:
    EvalResult.ok f
