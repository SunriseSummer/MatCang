# Robust fitting — RANSAC, and why the try* API exists

Fit a line to data whose tail is garbage: 40 points on `y = 2x + 1` plus 15
gross outliers. Plain least squares is dragged far off; **RANSAC** recovers the
truth by consensus.

## The mathematics

Repeat: draw a minimal sample (two points), fit the exact line through it,
count how many points fall within a tolerance band (the *consensus set*), and
keep the best. Finally refit with least squares on the winning consensus only.
Outliers can never dominate, because a candidate line through junk earns a tiny
consensus.

## The try* API in its natural habitat

A minimal sample is degenerate whenever the same point is drawn twice (or two
points share an x): the 2×2 system is singular. Inside a hot sampling loop the
right treatment is *skip and resample* — not exception handling. That is
exactly what the non-throwing variant expresses:

```cangjie
let candidate = trySolve(system, rhs)   // ?Vector
if (candidate.isNone()) { continue }    // degenerate sample: skip
```

The run prints how many degenerate samples were skipped this way.

## Running

```bash
cjpm run
```

Expected: RANSAC recovers `y ≈ 2.000x + 0.998` (error ~0.002) while plain
least squares is off by ~1.8; the consensus set contains the 40 true inliers.

## What the end-to-end test checks

Exits non-zero unless RANSAC lands within 0.05 of the true parameters, plain
least squares is at least 5× worse, degenerate samples actually occurred (the
`trySolve -> None` path ran), and the consensus set is near-complete.
