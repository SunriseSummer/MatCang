# SVD image compression — low-rank approximation

Compress a grayscale image by keeping only the largest components of its
**singular value decomposition (SVD)**. This is the canonical demonstration of
the Eckart–Young theorem: the best rank-`k` approximation of a matrix (in the
Frobenius and spectral norms) is exactly its truncated SVD.

## The mathematics

For an image `A = U Σ Vᵀ` with singular values `σ₁ ≥ σ₂ ≥ …`, the rank-`k`
truncation is

```
A_k = Σ_{i=1..k} σᵢ uᵢ vᵢᵀ
```

Its relative Frobenius error obeys the Eckart–Young identity

```
‖A − A_k‖_F / ‖A‖_F = sqrt(1 − captured energy),
   captured energy = (σ₁² + … + σ_k²) / (σ₁² + … + σ_r²).
```

Because the test image is smooth, its singular values decay rapidly, so a handful
of components reconstruct it almost exactly while storing far fewer numbers.

## How matcang is used

- `matcang.linalg.svd` (LAPACK `dgesdd`) factorises the image once.
- Each rank-`k` reconstruction is rebuilt with matrix products
  `U_k · diag(σ_k) · V_kᵀ` using matcang's `*`.
- `Matrix.frobeniusNorm` (BLAS `dnrm2`) measures the reconstruction error.

See [`src/main.cj`](src/main.cj).

## Running

```bash
cjpm run
```

Expected output:

```
SVD image compression — 64x64 smooth image
    sigma[0] = 32.9..., sigma[1] = 9.6..., sigma[2] = 1.0..., ...
  rank   energy      rel.error   predicted   compression
  1      0.92...     0.28...     0.28...     31.7x
  2      0.998...    0.033...    0.033...    15.8x
  4      1.000000    0.000000    0.000000    7.9x
  ...
OK
```

## What the end-to-end test checks

Exits non-zero unless a rank-8 approximation captures more than 99% of the
image's energy **and**, for every tested rank, the measured relative error
matches the Eckart–Young prediction `sqrt(1 − energy)` to within `1e-9`. The
latter is a stringent check that the SVD factors `U`, `Σ`, `Vᵀ` are correct.
