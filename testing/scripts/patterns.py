"""Single source for every prose pattern in check-consistency.sh.

WHY THIS FILE EXISTS, which is a defect rather than a preference. The patterns used to be written
twice: once in the fixture block and once in the check that scans the corpus. Two consequences,
both of which happened before anyone noticed either.

A measurement was reported from a pattern that was not the one in the repository, because the
fixture copy had a verb the shipped copy lacked. The number was real and nothing anyone could run
would reproduce it.

And the fixture silently covered less than it appeared to: it held five register patterns while the
corpus check shipped eight, so `modulo`, `by construction` and `trivially` were enforced against
every file here and tested against nothing. A green fixture asserted coverage it did not have.

Neither was findable by reading, because both copies were correct on their own. Importing from one
place removes the class rather than guarding against it: there is no second copy to drift.

Each entry is (label, compiled). The label names the pattern for a reader; checks that report
candidates print it, and the fixture ignores it.
"""

import re

VERB = r"(?i:reported|confirmed|acknowledged|agreed|noted|raised|flagged)"

PATTERNS = {
    # Case-sensitive deliberately: capitalization is the whole discriminator, since a proper noun
    # resolves to someone a reader could go and ask and a bare article does not. An ignore-case
    # flag here deletes the only property under test while still printing plausible output.
    "attribution": [
        ("named peer",   re.compile(rf"{VERB} by (?:the )?[A-Z][a-z]+")),
        ("per the owner", re.compile(r"(?i:per the) \w+ (?i:owner)")),
        # An intervening noun is the common phrasing and the original required the verb to follow
        # the name directly, so "As the Usher session confirmed" never matched. Found by writing
        # the first fixture case this pattern ever had.
        ("as X confirmed", re.compile(rf"[Aa]s (?:the )?[A-Z][a-z]+(?:\s+\w+)? {VERB}")),
    ],
    # A hit is a violation by definition, which is why this is the one family where PASS carries
    # real weight and a count is honestly reportable.
    "dashes": [
        ("em or en dash",      re.compile(r"[\u2014\u2013]")),
        # Any non-space before the connector, not only a letter: the previous left-hand class was
        # `[a-zA-Z,)"]`, so a connector following bold (`**X** - y`) or a code span was invisible.
        # The check substitutes a placeholder for a stripped code span rather than deleting it,
        # which is what keeps a non-space in that position.
        ("double hyphen",      re.compile(r"(?<=\S) -- (?=\S)")),
        ("space-hyphen-space", re.compile(r"(?<=\S) - (?=\S)")),
    ],
    # Candidate-raising: a hit is a candidate, never a defect count.
    "register": [
        ("falls out of",    re.compile(r"\b(?:falls?|fell|drops?|dropped) out of\b", re.I)),
        ("what this buys",  re.compile(r"\bwhat (?:this|it|that) buys\b", re.I)),
        ("turns on",        re.compile(r"\b(?:turns?|turned) on\b(?= whether| the question| how| what| which)", re.I)),
        ("cashes out as",   re.compile(r"\bcash(?:es|ed)? out as\b", re.I)),
        ("modulo",          re.compile(r"\bmodulo\b|\bup to (?:renaming|isomorphism|a constant)\b", re.I)),
        ("on pain of",      re.compile(r"\bon pain of\b", re.I)),
        ("by construction", re.compile(r"\bby construction\b", re.I)),
        ("trivially",       re.compile(r"\btrivially\b", re.I)),
    ],
    # Candidate-raising. Requiring a deictic is a deliberate trade: it excludes the two faces that
    # name a destination rather than pointing at one, and it costs full exposure to the face where
    # the location word points at the system instead of the file. A verb list makes the opposite
    # trade. Neither dominates; the choice follows what the corpus contains.
    "selfref": [
        ("worth stating",  re.compile(r"worth[\s]+(?:stating|recording|noting|naming|writing)", re.I)),
        ("stated rather than", re.compile(r"(?:is|are)[\s]+(?:stated|recorded|written|held|noted)(?:[\s]+\S+){0,3}?[\s]+rather[\s]+than", re.I)),
        ("placement",      re.compile(r"(?:held|kept|stated|written|recorded|placed|inlined?|sits?|lives?|belongs?)[\s]+(?:inline|here)(?:[\s]+\S+){0,3}?[\s]+rather[\s]+than", re.I)),
    ],
}


def compiled(name):
    """Every compiled pattern for one family, without labels."""
    return [p for _, p in PATTERNS[name]]
