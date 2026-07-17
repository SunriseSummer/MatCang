# Spectral partitioning — cutting a graph with an eigenvector

Split a graph into its two natural communities using nothing but the signs of
one eigenvector. Spectral graph theory at its most magical, and the seed of
modern spectral clustering.

## The mathematics

For a graph with adjacency `A` and degree matrix `D`, the Laplacian `L = D − A`
is symmetric positive-semidefinite and its spectrum encodes connectivity:

- `λ₀ = 0` always, with the constant vector as eigenvector; the multiplicity of
  0 counts connected components.
- `λ₁`, the **algebraic connectivity** (Fiedler value), is positive iff the
  graph is connected and small when the graph nearly falls apart.
- The corresponding **Fiedler vector** solves a relaxation of the minimum-cut
  problem: thresholding it at 0 yields a partition that approximately minimises
  the number of edges cut.

The demo graph is two dense 6-node communities joined by two bridge edges, so
the sign cut should recover the planted communities exactly — and the printed
Fiedler vector visibly switches sign precisely at the bridge.

## How matcang is used

- The Laplacian is assembled as `Matrix.fromDiagonal(a.rowSums().toArray()) - a`
  — the new axis-reduction API doing graph theory in one line.
- `matcang.linalg.eigSymmetric` (LAPACK `dsyev`) delivers the ascending spectrum
  and orthonormal eigenvectors; column 1 is the Fiedler vector.

## Running

```bash
cjpm run
```

Expected: `λ₀ ≈ 0`, Fiedler value ≈ 0.50, a perfect 6/6 split with 0 mismatches,
and a Fiedler vector whose negative half is exactly community one.

## What the end-to-end test checks

Exits non-zero unless the spectrum has the expected structure (zero eigenvalue,
positive Fiedler value) and the sign cut reproduces the planted communities with
zero mismatches (accounting for the eigenvector's arbitrary global sign).
