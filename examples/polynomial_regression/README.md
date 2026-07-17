# Polynomial regression — Runge's function and the price of ill-conditioning

Fit polynomials of rising degree to samples of Runge's function
`1 / (1 + 25x²)` on `[-1, 1]` and watch two classic numerical-analysis lessons
play out in the printed table.

## The mathematics

A degree-`p` least-squares fit solves `min ‖V c − y‖₂` where `V` is the
Vandermonde design matrix `V[i][j] = xᵢʲ`. Two things happen as `p` grows:

1. **The residual falls** — more basis functions, better approximation (though
   Runge's function famously resists global polynomials near the interval ends;
   even degree 10 leaves visible error, which is why splines exist).
2. **`cond(V)` explodes** — monomials on `[-1, 1]` become nearly linearly
   dependent, so the Vandermonde condition number grows exponentially with
   degree (~800× from degree 2 to 10 here). Squaring it via the normal
   equations `VᵀV c = Vᵀy` would be numerically ruinous; matcang's `lstsq`
   avoids that entirely by solving through the SVD (LAPACK `dgelsd`).

## How matcang is used

- `Matrix.build` constructs the Vandermonde matrix from a closure.
- `matcang.linalg.lstsq` computes the SVD-based least-squares fit.
- `matcang.linalg.cond` reports the 2-norm condition number.
- Residuals via the `*` operator and `Vector.norm`.

## Running

```bash
cjpm run
```

## What the end-to-end test checks

Exits non-zero unless the RMS residual decreases monotonically with degree, the
degree-10 fit reduces the degree-2 residual at least 3×, and the condition
number grows by orders of magnitude (the conditioning lesson actually shows up).
