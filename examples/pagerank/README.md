# PageRank — the eigenvector that ranked the web

Compute the PageRank of a small 8-page web: the stationary distribution of the
"random surfer" Markov chain, i.e. the dominant eigenvector of the Google
matrix. This is the algorithm that launched a search engine — and a perfect
showcase of how much structure one eigenvector can carry.

## The mathematics

From the column-stochastic link matrix `M` and damping factor `d = 0.85`, the
Google matrix is `G = d·M + (1−d)/n · E`. The rank vector `r` satisfies
`G r = r`, `∑ rᵢ = 1` — found here two independent ways:

1. **Power iteration**: `r ← d·(M r) + (1−d)/n`, repeated until the update
   stalls (guaranteed to converge since `G` is a primitive stochastic matrix).
2. **Direct solve**: `(I − d·M) r = (1−d)/n · 1`, one call to `solve`.

## How matcang is used

- The iteration body is a matrix-vector product with scalar broadcast:
  `m * r * DAMPING + teleport` — BLAS `dgemv` under the operators.
- The cross-check uses `matcang.linalg.solve` (LAPACK `dgesv`).
- Convergence is measured with `Vector.norm1`, the winner with `argAbsMax`.

## Running

```bash
cjpm run
```

Expected output: convergence in ~36 iterations, residual ~1e-13, ranks summing
to 1, page 2 (the hub everyone links to) on top with ~34% of the rank mass, and
agreement between iteration and direct solve to 1e-9.

## What the end-to-end test checks

Exits non-zero unless the iterate is a true fixed point of `G`, matches the
direct linear-solve solution, forms a probability distribution, and ranks the
hub first.
