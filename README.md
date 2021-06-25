# quickcheck

Property-based testing for Nim

```nim
import quickcheck
import unittest, sugar, sequtils

test "some map invariants":
  check quick do (s: string) -> bool:
    s.map(c => c) == s

  check quick do (a: seq[int], f: int -> int) -> bool:
    a.map(f).len == a.len
```

```
  +++ OK, passed 100 tests.
  +++ OK, passed 100 tests.
[OK] some map invariants
```

## Inspiring projects

- [QuickCheck](https://hackage.haskell.org/package/QuickCheck) (Haskell)
