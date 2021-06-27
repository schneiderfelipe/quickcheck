import unittest, quickcheck

suite "Basic usage examples":
  test "satify accepts booleans":
    check satisfy true
    check not satisfy false
