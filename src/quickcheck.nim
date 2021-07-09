import macros, random, strformat


proc rebuildType(ty: NimNode): NimNode =
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


macro test(f: proc): bool =
  ## Test `f` once.
  let ty = getType f
  let n = len(ty) - 2 # Number of parameters

  # debugEcho treeRepr ty
  # debugEcho n

  assert ty.kind == nnkBracketExpr
  # assert ty[0].kind == nnkSym and ty[0].strVal == "proc"  # `f` is a `proc`
  assert ty[1].kind == nnkSym and ty[1].strVal == "bool" # `f` should return a `bool`.
  for i in 2..<n+2:
    assert ty[i].kind in {nnkSym, nnkBracketExpr} # all parameters should be symbols or bracket expressions (for the case of ranges)

  result = newCall(f)
  var pty: NimNode
  for i in 2..<n+2:
    pty = rebuildType ty[i]
    result.add quote do:
      rand(`pty`)

  # debugEcho treeRepr result


proc satisfy*(f: proc): bool =
  ## Test a property.
  randomize()
  for i in 0..<1000:
    if not test f:
      return false
  return true
