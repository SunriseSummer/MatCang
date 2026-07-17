# MatCang/麦仓：仓颉高性能矩阵计算库

**A modern, elegant matrix-computation library for the [Cangjie](https://cangjie-lang.cn) language, powered by [OpenBLAS](https://github.com/OpenMathLib/OpenBLAS).**

> MatCang 是一个基于仓颉语言、以 OpenBLAS 为计算内核的现代化矩阵计算库。它通过仓颉-C 互操作完整映射了 OpenBLAS 的 C 接口（CBLAS + LAPACKE，共 2600+ 个函数），并在其上用仓颉的现代语言特性构建了优雅、类型安全、易用的高层 API（矩阵/向量运算、线性方程组、特征值、SVD、QR、Cholesky、最小二乘等），配套充足的单元测试（82 个）、14 个自验证数学应用示例（卡尔曼滤波、神经网络、模式识别、有限元、SVD 压缩、PageRank、谱图分割、热传导方程、RANSAC 鲁棒拟合、ALS 推荐系统等）与独立的 bench 性能测试模块；并为 Linux x64 / Windows x64 / macOS arm64 预编译好 OpenBLAS 动态库，开箱即用。

---

## Why matcang

- **The speed of OpenBLAS, the ergonomics of Cangjie.** Heavy lifting (matrix
  multiply, factorisations, eigenproblems) runs on the same battle-tested,
  multi-threaded BLAS/LAPACK kernels that NumPy, Julia and MATLAB rely on. You
  write `a * b`, `solve(a, b)` or `svd(a)`.
- **Complete, faithful interface mapping.** Every function OpenBLAS v0.3.33
  exports through its C interface — the full CBLAS (all precisions, all levels,
  plus OpenBLAS extensions) and the full LAPACKE surface, `_work` variants
  included — is mapped as a Cangjie binding: **2660 foreign declarations and
  2648 public wrappers**, generated mechanically from the OpenBLAS headers.
- **Modern, layered, type-safe design.** Opaque C `int` flags become real enums
  (`Transpose`, `Triangle`, ...); failures become a typed exception hierarchy;
  buffers are shared with C zero-copy; arithmetic reads like mathematics.
- **Proven correct.** 82 unit tests plus 14 self-verifying application examples
  check results against known answers and defining identities
  (`Q Qᵀ = I`, `U Σ Vᵀ = A`, Eckart–Young, O(h²) FEM convergence, ...).

## Architecture

matcang is organised as thin, well-separated layers. Each builds only on the
ones below it.

```
        ┌─────────────────────────────────────────────┐
        │  examples/  (Kalman · MLP · PCA · FEM · SVD)  │   applications & e2e tests
        └─────────────────────────────────────────────┘
        ┌─────────────────────────────────────────────┐
        │  matcang.prelude   one-import convenience     │
        ├───────────────┬───────────────┬───────────────┤
        │ matcang.linalg │  matcang.blas │  matcang.core │   ergonomic, typed, safe
        │ solve/svd/eig  │  gemm/gemv/…  │ Matrix/Vector │
        └───────────────┴───────────────┴───────────────┘
        ┌─────────────────────────────────────────────┐
        │  matcang   (root)   raw `foreign` decls +     │   generated FFI layer
        │  canonical wrappers  (dgemm, dgesv, …)        │
        └─────────────────────────────────────────────┘
        ┌─────────────────────────────────────────────┐
        │  OpenBLAS v0.3.33   (CBLAS + LAPACK/LAPACKE)  │   native compute kernels
        └─────────────────────────────────────────────┘
```

See [`docs/DESIGN.md`](docs/DESIGN.md) for why the raw bindings live in the root
package and how the wrapper layer makes them linkable everywhere.

## Requirements

- Cangjie SDK **1.0.5** (`cjc`, `cjpm`).
- A prebuilt OpenBLAS 0.3.33 runtime is **vendored for three platforms** under
  [`.openblas/lib/<platform>/`](.openblas/lib/), so nothing
  needs building from C source:

  | Platform | Runtime | Status |
  |----------|---------|--------|
  | Linux x64 | `libopenblas.so` (DYNAMIC_ARCH) | verified natively |
  | Windows x64 | `libopenblas.dll` + mingw runtime | verified via cross-compile + Wine |
  | macOS arm64 | self-contained `libopenblas.dylib` bundle | built & symbol-verified |

  Each `cjpm.toml` selects the right one automatically via a per-target
  `link-option`. See [`docs/PLATFORMS.md`](docs/PLATFORMS.md) for how the runtimes
  are produced and verified; reproduce them with the `.devtools/*openblas*` scripts.

## Quick start

```cangjie
package demo

import matcang.core.{Matrix, Vector}
import matcang.linalg.{solve, svd}

main() {
    let a = Matrix([[2.0, 1.0], [1.0, 3.0]])   // literal rows, ints work too
    let b = Vector([3.0, 5.0])

    // Solve A x = b   (LAPACK dgesv under the hood)
    println(solve(a, b))                 // [0.8000, 1.4000]

    // Matrix product   (BLAS dgemm)
    println(a * a)                       // [ 5  5 ; 5 10 ]

    // Singular values
    println(svd(a).s)                    // [3.6180, 1.3820]
}
```

Setup dependency for `matcang`:

```toml
[dependencies]
  matcang = { path = "<matcang>/matcang" }
```

Prefer a single import? `import matcang.prelude.*` brings the whole API into
scope.

## The packages

| Package            | Contents |
|--------------------|----------|
| `matcang.core`     | `Matrix`, `Vector`, `Complex`, the `Transpose`/`Triangle`/`Side`/`Diagonal` enums, the exception hierarchy, factories, operators, pretty-printing. |
| `matcang.blas`     | Explicit-control BLAS: `gemm`, `gemv`, `ger`, `syrk`, `axpy`, `scaleInPlace` (transpose flags, α/β scalars). |
| `matcang.linalg`   | `solve`, `inverse`, `determinant`, `cholesky`, `qr`, `svd`, `lu`, `eigSymmetric`, `eigenvalues`, `lstsq`, `pinv`, `matrixRank`, `cond`, `solveSPD`, `solveTriangular`, `matrixPower` — plus non-throwing `try*` twins for every data-dependent failure. |
| `matcang` (root)   | The generated FFI: raw `foreign` decls + canonical BLAS/LAPACK wrappers (`dgemm`, `dgesv`, …) and the `setNumThreads`/`getConfig` control API. |
| `matcang.prelude`  | One wildcard re-export of the three ergonomic packages. |

Full reference in [`docs/API.md`](docs/API.md); a task-oriented walkthrough in
[`docs/GUIDE.md`](docs/GUIDE.md).

## Examples

Each example in [`examples/`](examples) is a standalone runnable program **and**
an end-to-end test — it exits non-zero unless its numerical result is correct.
**Start with [`examples/README.md`](examples/README.md)** for a guided learning
path with difficulty ratings.

| Example | Mathematics | matcang features exercised |
|---------|-------------|----------------------------|
| [`kalman_filter`](examples/kalman_filter)             | Kalman filtering of a noisy track | `*`, `.t`, `inverse` |
| [`neural_network`](examples/neural_network)           | MLP + back-propagation learning XOR | `gemm` with transposed operands, `map`/`hadamard` |
| [`pattern_recognition`](examples/pattern_recognition) | PCA + k-means clustering | covariance, `eigSymmetric`, projection |
| [`finite_element`](examples/finite_element)           | 1-D Poisson via linear FEM | matrix assembly, `solve` |
| [`svd_compression`](examples/svd_compression)         | Low-rank image compression | `svd`, Eckart–Young |
| [`pagerank`](examples/pagerank)                       | Random-surfer ranking (power iteration) | `dgemv` operators, `solve`, `norm1` |
| [`polynomial_regression`](examples/polynomial_regression) | Runge fits & ill-conditioning | `lstsq`, `cond`, Vandermonde `build` |
| [`spectral_partition`](examples/spectral_partition)   | Graph cut via the Fiedler vector | Laplacian assembly, `eigSymmetric` |
| [`heat_equation`](examples/heat_equation)             | Crank–Nicolson PDE marching | `lu` factor-once + `solveTriangular` reuse |
| [`robust_fitting`](examples/robust_fitting)           | RANSAC vs outlier-corrupted lstsq | `trySolve` (`try*` API), `lstsq` |
| [`als_recommender`](examples/als_recommender)         | **Larger app**: ALS matrix factorisation | many small `solveSPDMatrix`, masking, RMSE |
| [`markov_chain`](examples/markov_chain)               | Weather forecasts, climate, mixing speed | `matrixPower`, `solve`, `eigenvalues` |
| [`gps_locate`](examples/gps_locate)                   | GPS trilateration via Gauss–Newton | `lstsq` in a nonlinear solver |
| [`api_tour`](examples/api_tour)                       | Every API area, self-checking | the whole surface |

```bash
cd examples/kalman_filter && cjpm run
```

## Building and testing

```bash
# unit tests for the library (82 tests)
cjpm test

# performance suites + wrapper-parity regression gate
cd bench && cjpm run
```

## Performance

The high-level API is a thin, allocation-lean shell over OpenBLAS: matrix data
is handed to C **zero-copy** via `acquireArrayRawData`, and the wrapper layer is
a single forwarding call. Compute-bound work runs at native OpenBLAS speed on the
library's multi-threaded kernels — there is no per-element interpreter overhead.

The [`bench/`](bench) module (`cd bench && cjpm run`) measures the hot paths and
gates the wrapper-parity regression. Representative results (4 threads):

```
  raw cblas_dgemm 768²   :  4.15 ms  (218.4 GFLOP/s)
  matcang gemmInto       :  4.18 ms  (216.5 GFLOP/s)   <- 0.85% over raw C
  matcang a * b          : 12.32 ms  ( 73.6 GFLOP/s)   <- allocation-bound
  element-wise a + b     :  5.2x faster than a closure loop (daxpy path)
  transpose 2048²        :  1.2x faster than a naive loop (domatcopy)
```

The in-place path (`matcang.blas.gemmInto` and friends) is within one percent of
C. The convenient `a * b` allocates a fresh result each call — an `O(n²)` cost
negligible against the `O(n³)` multiply at scale, but for tight loops prefer the
in-place ops. Tune threads with `matcang.setNumThreads(n)` and inspect the
active kernel with `matcang.getConfig()`.

## Licensing & attribution

matcang links against **OpenBLAS**, distributed under the BSD 3-Clause license
(see `.openblas/` and the upstream project). The generated bindings
are derived from the OpenBLAS public headers. matcang's own source is provided
for use alongside the Cangjie toolchain.
