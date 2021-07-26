**WARNING**: this project has been retired.
For a Rust-based alternative, see
[BurntSushi/quickcheck](https://github.com/BurntSushi/quickcheck).

# quickcheck

Property-based, type-based testing for Nim.

```nim
import unittest, quickcheck, algorithm

test "some invariants of the `reversed` function":
  check satisfy do (xs: string) -> bool:
    xs.reversed.reversed == xs

  check satisfy do (xs, ys: string) -> bool:
    (xs & ys).reversed == ys.reversed & xs.reversed
```

```
  +++ OK, passed 100 quick checks.
  +++ OK, passed 100 quick checks.
[OK] some invariants of the `reversed` function
```

It works with [`unittest`](https://nim-lang.org/docs/unittest.html), as a
standalone library (and probably with `testament`) and is inspired by
[QuickCheck](https://hackage.haskell.org/package/QuickCheck) and
[SmallCheck](https://hackage.haskell.org/package/smallcheck) (see below).

## Inspiring projects

-   [QuickCheck](https://hackage.haskell.org/package/QuickCheck) (Haskell)
-   [SmallCheck](https://hackage.haskell.org/package/smallcheck) (Haskell)

## References

-   [Claessen, K.; Hughes, J. QuickCheck. SIGPLAN Not. 2011, 46 (4), 53–64.](https://doi.org/10.1145/1988042.1988046)
