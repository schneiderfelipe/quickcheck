import macros, random, strformat


func rebuildType(ty: NimNode): NimNode =
  ## Reconstruct code for type from a `NimNode` for type.
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
  ## Generate code for a call to a function `f` with random arguments.
  let
    ty = getType f

    # Number of parameters of `f`
    n = len(ty) - 2


  # Validate `NimNode`:
  # - `f` must be a `proc`
  # - `f` must return a `bool`
  # - `f` parameters should be symbols or bracket expressions (for the case of ranges)
  ty.expectKind nnkBracketExpr
  ty[0].expectKind nnkSym
  assert ty[0].strVal == "proc"
  ty[1].expectKind nnkSym
  assert ty[1].strVal == "bool"
  for i in 2..<n+2:
    ty[i].expectKind {nnkSym, nnkBracketExpr}


  result = newCall(f)
  var pty: NimNode
  for i in 2..<n+2:
    pty = rebuildType ty[i]
    result.add quote do:
      rand(`pty`)


macro test(f: proc): bool =
  ## Test `f` once with random arguments.
  randCall(f)


proc satisfy*(f: proc): bool =
  ## Test a property.
  for i in 0..<100:
    if not test f:
      return false
  return true
