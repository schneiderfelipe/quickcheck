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

QuickCheck is a library for random testing of program properties.
The programmer provides a specification of the program, in the form of properties which functions should satisfy, and QuickCheck then tests that the properties hold in a large number of randomly generated cases.
Specifications are expressed in Nim, using combinators provided by QuickCheck.
QuickCheck provides combinators to define properties, observe the distribution of test data, and define test data generators.

## Inspiring projects

- [QuickCheck](https://hackage.haskell.org/package/QuickCheck) (Haskell)
