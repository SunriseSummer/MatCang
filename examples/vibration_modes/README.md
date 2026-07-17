# Vibration modes — a generalised eigenproblem

The natural frequencies of a mechanical structure are a **generalised**
eigenvalue problem. For a chain of masses connected by springs, Newton's law
`M ẍ = −K x` with `x = v·e^{iωt}` gives

```
K v = ω² M v,
```

where `K` is the (tridiagonal) stiffness matrix and `M` the (diagonal) mass
matrix. This is the shape of every structural-modes / normal-modes calculation.
matcang solves it directly with `eigSymmetricGeneralized`.

## The mathematics

For a fixed–fixed chain of `N` equal masses `m` and equal springs `k`, the
frequencies are known in closed form:

```
ω_j² = (4k/m) · sin²( j·π / (2(N+1)) ),   j = 1 … N.
```

The example checks the computed spectrum against this exact formula, verifies
the eigen-equation `K v = ω² M v` for every mode, and confirms the mode shapes
are **M-orthogonal** (`vᵢᵀ M vⱼ = 0` for `i ≠ j`) — the physical orthogonality
of normal modes.

## How matcang is used

- `Matrix.build` assembles the tridiagonal `K` and diagonal `M`;
- `matcang.linalg.eigSymmetricGeneralized` (LAPACK `dsygvd`) returns the
  ascending eigenvalues `ω²` and the mode shapes as columns;
- matrix–vector products verify the modes.

See [`src/main.cj`](src/main.cj).

## Running

```bash
cjpm run
```

## What the end-to-end test checks

Exits non-zero unless the computed frequencies match the closed-form formula to
`1e-9`, every mode satisfies `K v = ω² M v`, and distinct modes are
M-orthogonal.
