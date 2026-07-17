# Pattern recognition — PCA + k-means clustering

An unsupervised pipeline that discovers structure in unlabelled data: reduce its
dimensionality with **Principal Component Analysis (PCA)**, then group it with
**k-means**. Together they underpin classical pattern recognition, from
eigenfaces to document clustering.

## The mathematics

Given a data matrix `X` (samples × features):

1. **PCA** — centre the columns, form the covariance `C = Xcᵀ Xc / (n−1)`, and
   take the eigenvectors of `C` belonging to the largest eigenvalues. Projecting
   onto the top two eigenvectors gives the 2-D representation that preserves the
   most variance.
2. **k-means** — Lloyd's iteration: assign each point to its nearest centroid,
   then recompute centroids as cluster means, and repeat.

The dataset is three well-separated Gaussian blobs in 4-D, so the recovered
clusters should match the true classes.

## How matcang is used

- Covariance is `centered.t * centered` (BLAS `dgemm`) scaled by `1/(n−1)`.
- The principal directions come from `matcang.linalg.eigSymmetric` (LAPACK
  `dsyev`); the projection is another matrix product.
- k-means works over `Matrix.row(i)` as `Vector`s, using vector subtraction for
  distances and vector addition/scaling for centroid means.

See [`src/main.cj`](src/main.cj).

## Running

```bash
cjpm run
```

Expected output:

```
Pattern recognition — PCA + k-means
  samples             : 120 in 4-D
  eigenvalues (asc)   : [0.31..., 0.34..., 6.27..., 10.20...]
  variance explained  : 96...% by 2 components
  clustering purity   : 100.000000%
OK
```

## What the end-to-end test checks

Exits non-zero unless the top two principal components explain at least 80% of
the variance **and** the clustering purity (fraction of points agreeing with
their cluster's majority true label) is at least 90%.
