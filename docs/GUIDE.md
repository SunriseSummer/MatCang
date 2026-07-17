# User guide

A tour of matcang from first import to real computation. For exhaustive
signatures see [`API.md`](API.md); for the architecture see [`DESIGN.md`](DESIGN.md).

## 1. Setting up a project

Add matcang and the OpenBLAS runtime to your module's `cjpm.toml`:

```toml
[package]
  cjc-version = "1.0.5"
  name = "myapp"
  version = "1.0.0"
  output-type = "executable"

# one entry per platform you build on/for — each links the prebuilt OpenBLAS
# shipped under third_party/openblas/lib/<platform>/ (path relative to your module)
[target.x86_64-unknown-linux-gnu]
  link-option = "-L<matcang>/third_party/openblas/lib/linux_x86_64 -lopenblas"

[target.x86_64-w64-mingw32]
  link-option = "-L<matcang>/third_party/openblas/lib/windows_x86_64 -lopenblas"

[target.aarch64-apple-darwin]
  link-option = "-L<matcang>/third_party/openblas/lib/macos_arm64 -lopenblas"

[dependencies]
  matcang = { path = "<matcang>/matcang" }
```

(Any example's `cjpm.toml` is a ready-made template.) At runtime the OpenBLAS
shared library must be discoverable: `cjpm run` handles it automatically; for a
directly-executed binary add the platform lib directory to `LD_LIBRARY_PATH`
(Linux) / `PATH` or the exe directory (Windows) — macOS needs nothing thanks to
`@loader_path`. See `docs/PLATFORMS.md`.

## 2. Imports

Import exactly what you use (recommended):

```cangjie
import matcang.core.{Matrix, Vector}
import matcang.linalg.{solve, svd, eigSymmetric}
import matcang.blas.gemm
```

…or pull in everything for quick work and exploration:

```cangjie
import matcang.prelude.*
```

## 3. Creating matrices and vectors

```cangjie
let a = Matrix([[1.0, 2.0], [3.0, 4.0]])            // literal, row by row
let ai = Matrix([[1, 2], [3, 4]])                   // integer literals work too
let a2 = Matrix.fromRows([[1.0, 2.0], [3.0, 4.0]])  // explicit factory, same thing
let b = Matrix.fromColumns([[1.0, 0.0], [0.0, 1.0]])// from columns
let z = Matrix.zeros(3, 3)
let i = Matrix.identity(4)
let d = Matrix.fromDiagonal([1.0, 2.0, 3.0])
let g = Matrix.build(3, 3) { i, j => Float64(i + j) } // element-wise rule
let r = Matrix.randomNormal(100, 20, std: 0.1)        // reproducible

let v = Vector.of([1.0, 2.0, 3.0])
let t = Vector.linspace(0.0, 1.0, 11)                 // 0.0, 0.1, ... 1.0
let e = Vector.basis(5, 2)                            // [0,0,1,0,0]
```

Read and write elements with `[]`:

```cangjie
let x = a[0, 1]      // 2.0
a[0, 1] = 9.0
let firstRow = a.row(0)
```

## 4. Arithmetic

Operators read like mathematics. `*` between two matrices is the matrix product
(BLAS `dgemm`); `*` with a scalar scales; `+`/`-` are element-wise.

```cangjie
let c = a * b            // matrix product
let s = a + b            // element-wise sum
let scaled = 2.0 * a     // scalar on either side (left form: import ScalarOps)
let y = a * v            // matrix-vector product (dgemv)
let h = a.hadamard(b)    // element-wise product
let at = a.t             // transpose
```

Reductions and norms use BLAS where it helps:

```cangjie
a.sum(); a.mean(); a.frobeniusNorm()
v.dot(w); v.norm(); v.norm1(); v.normInf()
```

Functional transforms return new values:

```cangjie
let relu = a.map { x => if (x > 0.0) { x } else { 0.0 } }
let combined = a.zipWith(b) { p, q => p * q + 1.0 }
```

## 4b. Slicing, stacking and broadcasting

Ranges index rectangular views (always copies), matrices stack, and axis
reductions/broadcasts replace hand-written loops:

```cangjie
let s  = m[1..3, 0..2]          // rows 1-2, cols 0-1; steps work too: m[0..=4 : 2, 0..3]
let r0 = m[0, 0..m.cols]        // a row slice as a Vector
let c2 = m[0..m.rows, 2]        // a column slice as a Vector
let big = Matrix.vstack([a, b]) // and hstack([a, b])

let mu = m.colMeans()           // also rowMeans / rowSums / colSums
let centered = m.addRowVector(-mu)   // broadcast: subtract the mean from every row
let z = m.flatten()             // all entries as one Vector
let colM = v.toColumnMatrix()   // Vector <-> Matrix bridges (and toRowMatrix)
```

## 5. Solving linear systems

```cangjie
import matcang.linalg.{solve, solveMatrix, inverse, determinant}

let a = Matrix.fromRows([[3.0, 2.0], [1.0, 2.0]])
let x = solve(a, Vector.of([5.0, 5.0]))   // one right-hand side
let X = solveMatrix(a, identity)          // many right-hand sides
let det = determinant(a)
```

Prefer `solve` over forming `inverse(a) * b`: it is faster and more accurate.

Specialised systems have faster, sharper solvers:

```cangjie
import matcang.linalg.{solveSPD, solveTriangular, lu, matrixPower}
import matcang.core.{Triangle, Transpose}

let x = solveSPD(spd, b)                 // Cholesky-based (dposv), ~2x LU speed
let y = solveTriangular(l, b, uplo: Triangle.Lower)   // back-substitution
let f = lu(a)                            // exposed factors: a == f.p * f.l * f.u
let a10 = matrixPower(a, 10)             // repeated squaring; k may be negative
```

## 6. Factorisations

```cangjie
import matcang.linalg.{cholesky, qr, svd}

let l = cholesky(spd)          // spd = l lᵀ, l lower-triangular
let f = qr(a)                  // a = f.q * f.r
let d = svd(a)                 // a = d.u * diag(d.s) * d.vt
```

`svd` returns singular values in descending order — handy for rank, energy and
low-rank approximation (see the `svd_compression` example).

## 7. Eigenvalues

```cangjie
import matcang.linalg.{eigSymmetric, eigenvalues}

// symmetric: real eigenvalues (ascending) + orthonormal eigenvectors (columns)
let e = eigSymmetric(covariance)
let largest = e.values[e.values.size - 1]
let leadingVector = e.vectors.col(e.values.size - 1)

// general (non-symmetric): complex spectrum
let spectrum = eigenvalues(a)   // Array<Complex>
```

For PCA, form the covariance and take the top eigenvectors — exactly what
`pattern_recognition` does.

## 8. Least squares and pseudo-inverse

```cangjie
import matcang.linalg.{lstsq, pinv, matrixRank, cond}

// fit coefficients to an over-determined design matrix
let coefficients = lstsq(design, observations)
let ainv = pinv(a)              // Moore–Penrose
let rank = matrixRank(a)
let kappa = cond(a)             // 2-norm condition number
```

## 9. Explicit BLAS for performance

When you need transpose flags, scalar multipliers or want to avoid intermediate
allocations, drop to `matcang.blas`:

```cangjie
import matcang.blas.{gemm, gemv, axpy}
import matcang.core.Transpose

let g = gemm(a, b, transA: Transpose.Trans, alpha: 2.0)  // 2 · aᵀ b
let y = gemv(a, x, transA: Transpose.Trans)              // aᵀ x
let r = axpy(3.0, x, y)                                  // 3x + y
```

## 10. Threads and backend info

```cangjie
import matcang.{setNumThreads, getConfig, getNumProcs}

setNumThreads(4)
println(getConfig())     // e.g. "OpenBLAS 0.3.33 ... Haswell ..."
```

## 10b. try* variants: branch instead of catch

Every data-dependent failure (singular, not positive definite, no convergence)
has a non-throwing twin returning `?T`. Shape errors still throw — those are
bugs, not data:

```cangjie
import matcang.linalg.{trySolve, tryInverse, pinv}

if (let Some(x) <- trySolve(a, b)) {        // branch on solvability
    use(x)
} else {
    fallback()
}
let generalised = tryInverse(a) ?? pinv(a)  // graceful degradation in one line
```

Reach for `try*` in sampling/estimation loops (e.g. RANSAC minimal samples —
see `examples/robust_fitting`); keep the throwing forms for straight-line
mathematical code where failure is exceptional.

## 11. Handling errors

Shape and numerical problems raise typed exceptions:

```cangjie
import matcang.core.{DimensionMismatchException, SingularMatrixException}
import matcang.linalg.solve

try {
    let x = solve(a, b)
} catch (e: SingularMatrixException) {
    println("matrix is singular: ${e}")
} catch (e: DimensionMismatchException) {
    println("shape error: ${e}")
}
```

## 12. Next steps

Read the [`examples/`](../examples) — each is a compact, verified program that
puts several of these pieces together into a real algorithm. `examples/api_tour`
sweeps every API area in one runnable file; `examples/als_recommender` shows a
larger, multi-component application. Performance suites live in
[`bench/`](../bench) (`cd bench && cjpm run`).
