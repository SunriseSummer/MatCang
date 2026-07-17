# Heat equation — Crank–Nicolson with a factor-once LU

March the 1-D heat equation `u_t = u_xx` (Dirichlet boundaries, `sin(πx)`
initial data) to `t = 0.1` and compare against the exact solution
`e^{−π²t} sin(πx)`.

## The mathematics

Crank–Nicolson averages the explicit and implicit Euler stencils:

```
(I + Δt/2 K) u_{n+1} = (I − Δt/2 K) u_n
```

It is unconditionally stable and second-order in both Δt and h. The
left-hand matrix never changes, so the professional pattern is **factor once,
back-substitute every step**:

```
A = P L U                      lu(a)          — once
w = Pᵀ b                       permutation transpose = inverse
L z = w                        solveTriangular(l, w, Lower, diag: UnitDiag)
U u' = z                       solveTriangular(u, z, Upper)
```

## How matcang is used

`lu` exposes the P/L/U factors; `solveTriangular` (LAPACK `dtrtrs`) does the
two O(n²) back-substitutions per step — no O(n³) work after the first
factorisation. The example also validates the pipeline against a fresh dense
`solve` (agrees to ~1e-15) and checks the per-step amplitude decay against the
theoretical `e^{−π²Δt}`.

## Running

```bash
cjpm run
```

## What the end-to-end test checks

Exits non-zero unless the LU pipeline matches a direct solve to 1e-10, the
per-step decay tracks theory to 1e-5, and the final profile matches the
analytic solution to 1e-4.
