#!/usr/bin/env python3
"""Independent finite cross-check of the parametric pair-sum identity."""

from __future__ import annotations

from collections import Counter
from itertools import combinations


def left(a: int, b: int, c: int) -> list[int]:
    return [0, a + b, a + c, b + c]


def right(a: int, b: int, c: int) -> list[int]:
    return [a, b, c, a + b + c]


def pair_sums(xs: list[int]) -> Counter[int]:
    return Counter(xs[i] + xs[j] for i, j in combinations(range(len(xs)), 2))


def main() -> None:
    checked = 0
    for a in range(1, 20):
        for b in range(a + 1, 25):
            for c in range(b + 1, 30):
                lhs = left(a, b, c)
                rhs = right(a, b, c)
                assert len(set(lhs)) == 4
                assert len(set(rhs)) == 4
                assert set(lhs) != set(rhs)
                assert pair_sums(lhs) == pair_sums(rhs)
                checked += 1

    assert left(1, 2, 3) == [0, 3, 4, 5]
    assert right(1, 2, 3) == [1, 2, 3, 6]
    print(f"cross-check passed for {checked} parameter triples")


if __name__ == "__main__":
    main()
