# Finite element method — the 1-D Poisson equation

Solve the boundary value problem

```
−u''(x) = f(x)   on (0, 1),    u(0) = u(1) = 0
```

with the **finite element method (FEM)** using piecewise-linear (P1) elements —
the "hello world" of computational PDEs and the basis of engineering simulation.

## The mathematics

The interval is divided into `n` equal elements. On each element the weak form
contributes a local stiffness matrix `(1/h)[[1, −1], [−1, 1]]`, which is
assembled into a global tridiagonal system `K u = b`. The load vector uses
`bᵢ = h · f(xᵢ)`. With `f(x) = π² sin(π x)` the exact solution is
`u(x) = sin(π x)`, so the discretisation error can be measured exactly.

P1 elements are second-order accurate, so halving the mesh size `h` should cut
the maximum error by a factor of about four.

## How matcang is used

- The global stiffness matrix is **assembled** element by element into a
  `Matrix` (the authentic FEM workflow, not a hand-written tridiagonal).
- The system is solved with `matcang.linalg.solve` (LAPACK `dgesv`).

See [`src/main.cj`](src/main.cj), function `solvePoisson`.

## Running

```bash
cjpm run
```

Expected output:

```
Finite element method — 1D Poisson  -u'' = pi^2 sin(pi x)
  mesh  20 elements: max error = 0.00205...
  mesh  40 elements: max error = 0.00051...
  mesh  80 elements: max error = 0.00012...
  refinement ratio (coarse/fine)  : 4.00...
  refinement ratio (fine/finer)   : 4.00...
OK
```

## What the end-to-end test checks

Exits non-zero unless the finest mesh matches the analytic solution to better
than `1e-3` **and** the error ratios confirm the expected O(h²) convergence
(each refinement reduces the error by at least 3×). This validates both the
assembly and the solver.
