import unittest, quickcheck

suite "Basic functionality":
  test "can test a trivial property":
    check satisfy do (x: int) -> bool:
      true
