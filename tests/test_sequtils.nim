import
  random,
  sequtils,
  sugar

import unittest

import quickcheck

suite "sequtils":
  test "length of concat is the sum of lengths":
    check quick (xs, ys: seq[int]) => concat(xs, ys).len == xs.len + ys.len

  test "length of filter is the same as count":
    check quick do (xs: string, x: char) -> bool:
      count(xs, x) == xs.filter(w => w == x).len

  test "cycle multiplies length":
    # `Natural` in this case gives OverflowDefect! Use a range instead:
    # check quick do (xs: seq[float], n: Natural) -> bool:
    check quick do (xs: seq[float], n: range[0..1000]) -> bool:
      cycle(xs, n).len == n * xs.len

  test "cycle is the same as repeat for a single item":
    check quick do (s: string, n: range[0..1000]) -> bool:
      cycle([s], n) == repeat(s, n)

  test "some deduplicate invariants":
    check quick do (xs: seq[string]) -> bool:
      deduplicate(xs).len <= xs.len

    check quick do (xs: seq[string]) -> bool:
      let dedup = deduplicate(xs)
      deduplicate(dedup) == dedup

  test "some map invariants":
    check quick do (s: string) -> bool:
      s.map(c => c) == s

    check quick do (a: seq[int], f: int -> int) -> bool:
      a.map(f).len == a.len

    check quick do (a: array[100, int], f: int -> int, g: int -> int) -> bool:
      a.map(f).map(g) == a.map(x => g(f(x)))
