# TODO: support shrinking (see e.g.,
# https://raw.githubusercontent.com/leepike/SmartCheck/master/paper/paper.pdf
# and
# https://hackage.haskell.org/package/QuickCheck-2.14.2/docs/Test-QuickCheck.html#v:genericShrink)

# TODO: support smallcheck-like checks as well (i.e., exaustiveness up to a
# number of tests instead of random ones): "If a program fails to meet its
# specification in some cases, it almost always fails in some simple case."

# TODO: support control over tests inside the tests themselves by returning
# an Option[bool]: if the value is some(), use it for the test, if it's
# none(bool), ignore. Filtering can be supported on top of that (idea: by
# using templates that force returning none(bool)).

# TODO: long-shot: support forAll, exists and existsUnique (currently we only
# envision the equivalent of forAll, see
# https://hackage.haskell.org/package/smallcheck-1.2.1/docs/Test-SmallCheck.html#g:1)

# TODO: other excellent ideas from SmallCheck: `over`, `==>`.

import quickcheck/arbitraries
export arbitrary

import quickcheck/properties
export quick
