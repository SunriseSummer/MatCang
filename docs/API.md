# API reference

All signatures use Cangjie syntax. `!` marks a named parameter; `= v` a default.

- [matcang.core](#matcangcore) — `Matrix`, `Vector`, `Complex`, enums, errors
- [matcang.blas](#matcangblas) — explicit-control BLAS
- [matcang.linalg](#matcanglinalg) — linear algebra over LAPACK
- [matcang](#matcang-root) — control API + raw bindings

---

## matcang.core

### `class Matrix`

Dense, row-major matrix of `Float64`. Arithmetic returns fresh matrices.

**Fields / properties**

| Member | Type | Notes |
|--------|------|-------|
| `rows`, `cols` | `Int64` | dimensions |
| `data` | `Array<Float64>` | row-major buffer (`data[i*cols+j]`), shared for zero-copy interop |
| `size` | `Int64` | `rows * cols` |
| `shape` | `(Int64, Int64)` | `(rows, cols)` |
| `isSquare`, `isEmpty` | `Bool` | |
| `t` | `Matrix` | transpose (accessor for `transpose()`) |

**Constructors & factories**

```cangjie
init(rowsData: Array<Array<Float64>>)   // literal rows: Matrix([[1.0, 2.0], [3.0, 4.0]])
init(rowsData: Array<Array<Int64>>)     // integer literals: Matrix([[1, 2], [3, 4]])
init(rows: Int64, cols: Int64)                          // zeros
init(rows: Int64, cols: Int64, data: Array<Float64>)    // wrap a row-major buffer
static func zeros(rows: Int64, cols: Int64): Matrix
static func ones(rows: Int64, cols: Int64): Matrix
static func filled(rows: Int64, cols: Int64, value: Float64): Matrix
static func identity(n: Int64): Matrix
static func fromDiagonal(values: Array<Float64>): Matrix
static func build(rows: Int64, cols: Int64, f: (Int64, Int64) -> Float64): Matrix
static func fromRows(rowsData: Array<Array<Float64>>): Matrix
static func fromColumns(colsData: Array<Array<Float64>>): Matrix
static func random(rows: Int64, cols: Int64, seed!: UInt64 = 42): Matrix
static func randomNormal(rows: Int64, cols: Int64, mean!: Float64 = 0.0,
                         std!: Float64 = 1.0, seed!: UInt64 = 42): Matrix
```

**Element access, rows & columns**

```cangjie
operator func [](i: Int64, j: Int64): Float64
operator func [](i: Int64, j: Int64, value!: Float64): Unit
func row(i: Int64): Vector
func col(j: Int64): Vector
func setRow(i: Int64, v: Vector): Unit
func setColumn(j: Int64, v: Vector): Unit
func diagonal(): Vector
func trace(): Float64            // square only
```

**Slicing & stacking** (slices copy; ranges may be open/closed/stepped)

```cangjie
operator func [](rowRange: Range<Int64>, colRange: Range<Int64>): Matrix  // m[1..3, 0..2]
operator func [](i: Int64, colRange: Range<Int64>): Vector                // row slice
operator func [](rowRange: Range<Int64>, j: Int64): Vector                // column slice
static func vstack(parts: Array<Matrix>): Matrix     // stack top-to-bottom
static func hstack(parts: Array<Matrix>): Matrix     // stack left-to-right
```

**Axis reductions & broadcasting**

```cangjie
func rowSums(): Vector           func colSums(): Vector
func rowMeans(): Vector          func colMeans(): Vector
func addRowVector(v: Vector): Matrix   // add v (len cols) to every row
func addColVector(v: Vector): Matrix   // add v (len rows) to every column
func flatten(): Vector                 // row-major copy of all entries
```

**Transforms & functional helpers**

```cangjie
func copy(): Matrix
func transpose(): Matrix
func reshape(newRows: Int64, newCols: Int64): Matrix   // shares storage
func map(f: (Float64) -> Float64): Matrix
func mapIndexed(f: (Int64, Int64, Float64) -> Float64): Matrix
func zipWith(other: Matrix, f: (Float64, Float64) -> Float64): Matrix
func forEach(f: (Float64) -> Unit): Unit
```

**Reductions**

```cangjie
func sum(): Float64
func mean(): Float64
func min(): Float64
func max(): Float64
func frobeniusNorm(): Float64    // via BLAS dnrm2
```

**Operators** (BLAS-backed where marked)

| Expression | Meaning |
|------------|---------|
| `a * b` | matrix product (BLAS `dgemm`) |
| `a * x` | matrix-vector product (BLAS `dgemv`), `x: Vector` |
| `a * s`, `s * a` | scalar scaling (left form needs `import matcang.core.ScalarOps`) |
| `a + b`, `a - b` | element-wise |
| `a + s`, `a - s`, `a / s` | scalar broadcast |
| `-a` | negation |
| `a == b`, `a != b` | element-wise equality |
| `a.hadamard(b)` | element-wise product |
| `a.matmul(b)` | explicit alias for `a * b` |
| `a.approxEquals(b, tol!: Float64 = 1e-9)` | tolerant comparison |

**Conversions**: `toArray(): Array<Float64>`, `to2D(): Array<Array<Float64>>`,
`toString(): String`.

### `class Vector`

Dense 1-D `Float64` vector. Same immutable-by-default arithmetic style.

```cangjie
init(size: Int64)                 // zeros
init(data: Array<Float64>)
static func zeros/ones(size): Vector
static func filled(size, value): Vector
static func of(values: Array<Float64>): Vector
static func build(size: Int64, f: (Int64) -> Float64): Vector
static func linspace(start: Float64, stop: Float64, count: Int64): Vector
static func basis(size: Int64, i: Int64): Vector
static func random(size: Int64, seed!: UInt64 = 42): Vector

operator func [](i): Float64        // and []=(i, value!)
operator func [](range: Range<Int64>): Vector   // slice (copies)
static func concat(parts: Array<Vector>): Vector
func toColumnMatrix(): Matrix       // n x 1
func toRowMatrix(): Matrix          // 1 x n
prop size: Int64
func dot(other: Vector): Float64    // BLAS ddot
func norm(): Float64                // BLAS dnrm2 (2-norm)
func norm1(): Float64               // BLAS dasum
func normInf(): Float64
func sum/mean/min/max(): Float64
func argAbsMax(): Int64             // BLAS idamax
func map/mapIndexed/zipWith/forEach(...)
func hadamard(rhs: Vector): Vector
func approxEquals(rhs: Vector, tol!: Float64 = 1e-9): Bool
// operators: + - (vectors), * / + - (scalar), unary -, == !=,
//            and s * v (left form needs `import matcang.core.ScalarOps`)
```

### `struct Complex`

Immutable complex value type: `re`, `im`; `+ - * /`, unary `-`, `==`, `!=`;
`conjugate()`, `abs()`, `arg()`; statics `zero()`, `one()`, `i()`.

### Enums

`Transpose { NoTrans | Trans | ConjTrans }`,
`Triangle { Upper | Lower }`,
`Side { Left | Right }`,
`Diagonal { NonUnit | UnitDiag }` — each with `toCblas(): Int32` and
`toChar(): Int8`.

### Exceptions

All library failures derive from `MatCangException`:

| Exception | Raised when |
|-----------|-------------|
| `DimensionMismatchException` | operand shapes are incompatible (caller bug) |
| `NonSquareMatrixException`   | a square matrix is required (caller bug) |
| `SingularMatrixException`    | matrix is singular / not positive definite (data) |
| `ConvergenceException`       | an iterative routine failed to converge (data) |
| `BlasArgumentException`      | LAPACK rejected an argument (internal; should not occur) |

Data-dependent cases also have non-throwing `try*` twins (see the linalg
section); contract violations always throw.

---

## matcang.blas

Explicit-control BLAS; results are freshly allocated, inputs untouched.

```cangjie
func gemm(a: Matrix, b: Matrix, transA!: Transpose = NoTrans,
          transB!: Transpose = NoTrans, alpha!: Float64 = 1.0): Matrix   // α op(a) op(b)
func gemmInto(a: Matrix, b: Matrix, c: Matrix, transA!: Transpose = NoTrans,
          transB!: Transpose = NoTrans, alpha!: Float64 = 1.0,
          beta!: Float64 = 0.0): Unit    // c = α op(a) op(b) + β c, allocation-free
func syrk(a: Matrix, trans!: Transpose = NoTrans, alpha!: Float64 = 1.0,
          uplo!: Triangle = Upper): Matrix                               // α op(a) op(a)ᵀ
func gemv(a: Matrix, x: Vector, transA!: Transpose = NoTrans,
          alpha!: Float64 = 1.0): Vector                                 // α op(a) x
func ger(x: Vector, y: Vector, alpha!: Float64 = 1.0): Matrix            // α x yᵀ
func axpy(alpha: Float64, x: Vector, y: Vector): Vector                  // α x + y
func scaleInPlace(x: Vector, alpha: Float64): Vector                     // x *= α (mutates)
```

---

## matcang.linalg

High-level linear algebra; all row-major, dispatching to LAPACKE.

```cangjie
func solve(a: Matrix, b: Vector): Vector                 // a x = b        (dgesv)
func solveMatrix(a: Matrix, b: Matrix): Matrix           // a X = B        (dgesv)
func inverse(a: Matrix): Matrix                          // (dgetrf+dgetri)
func determinant(a: Matrix): Float64                     // (dgetrf)

func cholesky(a: Matrix, lower!: Bool = true): Matrix    // a = l lᵀ       (dpotrf)
func qr(a: Matrix): QR                                   // a = q r        (dgeqrf+dorgqr)
func svd(a: Matrix): SVD                                 // a = u Σ vᵀ     (dgesdd)

func eigSymmetric(a: Matrix): EigenSym                   // sym: λ + vecs  (dsyev)
func eigenvaluesSymmetric(a: Matrix): Vector             // sym: λ only    (dsyev)
func eigenvalues(a: Matrix): Array<Complex>              // general        (dgeev)

func lstsq(a: Matrix, b: Vector): Vector                 // min ‖a x − b‖  (dgelsd)
func pinv(a: Matrix): Matrix                             // Moore–Penrose  (svd)
func matrixRank(a: Matrix, tol!: Float64 = -1.0): Int64
func cond(a: Matrix): Float64                            // 2-norm condition number

func lu(a: Matrix): LU                                   // a = p l u      (dgetrf)
func solveSPD(a: Matrix, b: Vector): Vector              // SPD a          (dposv)
func solveSPDMatrix(a: Matrix, b: Matrix): Matrix        // SPD, many rhs  (dposv)
func solveTriangular(a: Matrix, b: Vector, uplo!: Triangle = Lower,
        trans!: Transpose = NoTrans, diag!: Diagonal = NonUnit): Vector  // (dtrtrs)
func matrixPower(a: Matrix, k: Int64): Matrix            // a^k, k may be negative
```

### Result types

Each factorisation returns an immutable struct whose fields are ordinary
`Matrix`/`Vector` values.

**`struct QR`** — reduced QR factorisation of an m×n input (`k = min(m, n)`),
satisfying `a == q * r`:

| Field | Type | Shape / meaning |
|-------|------|-----------------|
| `q` | `Matrix` | m×k, orthonormal columns (`q.t * q == I`) |
| `r` | `Matrix` | k×n, upper-triangular |

**`struct SVD`** — reduced singular value decomposition,
`a == u * diag(s) * vt`:

| Field | Type | Shape / meaning |
|-------|------|-----------------|
| `u`  | `Matrix` | m×k, left singular vectors (orthonormal columns) |
| `s`  | `Vector` | length k, singular values, **descending**, non-negative |
| `vt` | `Matrix` | k×n, right singular vectors, **already transposed** (row i of `vt` pairs with `s[i]`) |

**`struct EigenSym`** — symmetric eigendecomposition, `a * vectors == vectors *
diag(values)`:

| Field | Type | Shape / meaning |
|-------|------|-----------------|
| `values`  | `Vector` | length n, real eigenvalues in **ascending** order |
| `vectors` | `Matrix` | n×n, orthonormal; **column j** is the eigenvector for `values[j]`, so the largest-eigenvalue direction is `vectors.col(n - 1)` |

**`struct LU`** — pivoted LU factorisation (`k = min(m, n)`), satisfying
`a == p * l * u`; singular inputs are permitted (zeros appear on `u`'s
diagonal):

| Field | Type | Shape / meaning |
|-------|------|-----------------|
| `p` | `Matrix` | m×m row-permutation; orthogonal, so `p.t` is its inverse |
| `l` | `Matrix` | m×k, unit-lower-triangular (`l[i,i] == 1`) |
| `u` | `Matrix` | k×n, upper-triangular |

### try* variants (non-throwing)

Every routine whose failure is **data-dependent** has a `try` twin that returns
`?T` (`None` on failure) instead of throwing, for branch-style call sites.
Contract violations (shape mismatch, non-square input) still throw from the
`try` versions — those are caller bugs, not data outcomes.

```cangjie
// None when the matrix is singular / not positive definite:
func trySolve(a, b): ?Vector          func trySolveMatrix(a, b): ?Matrix
func tryInverse(a): ?Matrix           func tryCholesky(a, lower!): ?Matrix
func trySolveSPD(a, b): ?Vector       func trySolveSPDMatrix(a, b): ?Matrix
func trySolveTriangular(a, b, ...): ?Vector
func tryMatrixPower(a, k): ?Matrix    // negative k on a singular matrix

// None if the underlying iteration fails to converge (rare):
func trySvd(a): ?SVD                  func tryEigSymmetric(a): ?EigenSym
func tryEigenvalues(a): ?Array<Complex>
func tryEigenvaluesSymmetric(a): ?Vector
func tryLstsq(a, b): ?Vector          func tryPinv(a): ?Matrix
func tryMatrixRank(a, tol!): ?Int64   func tryCond(a): ?Float64
```

```cangjie
if (let Some(x) <- trySolve(a, b)) { use(x) }   // branch on solvability
let inv = tryInverse(a) ?? pinv(a)              // fall back to the pseudo-inverse
```

---

## matcang (root)

**Runtime control**

```cangjie
func setNumThreads(n: Int32): Unit
func getNumThreads(): Int32
func getNumProcs(): Int32
func getConfig(): String        // OpenBLAS build/target string
func getCoreName(): String      // selected micro-arch kernel
func getParallel(): Int32       // 0 sequential, 1 pthreads, 2 OpenMP
```

**Raw bindings.** Every OpenBLAS routine is also available directly under its
canonical name as a `public unsafe` wrapper — `dgemm`, `dgesv`, `zheev`,
`somatcopy`, … — taking `CPointer<…>` arguments. These are for advanced use;
prefer the typed API above. Layout/flag constants live in the `Cblas` and
`Lapack` structs (`Cblas.ROW_MAJOR`, `Cblas.NO_TRANS`, …).
