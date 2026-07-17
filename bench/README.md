# bench — performance suites

Micro- and macro-benchmarks for matcang's hot paths, plus **two wrapper-parity
regression gates**: the in-place `gemmInto` must stay within 1.25× of a direct
`cblas_dgemm` call on the same buffers, and the complex `gemmInto` within 1.25×
of raw `cblas_zgemm` — or the run exits non-zero. That is the enforceable form
of the library's core performance promise — *no meaningful overhead over
calling OpenBLAS from C*, in both real and complex precision.

## Running

```bash
cd bench && cjpm run
```

## Suites

| Suite | What it measures |
|-------|------------------|
| `parity` | raw `cblas_dgemm` vs `gemmInto` (in-place) vs `a * b` (allocating), 768², with the 1.25× gate and a bitwise result comparison |
| `gemm` | `a * b` GFLOP/s across 128/256/512 |
| `gemv` | matrix-vector throughput at 2048² |
| `elementwise` | BLAS-backed `a + b` / `a * 2.0` (daxpy/dscal paths) vs per-element closure baselines |
| `transpose` | `a.t` (OpenBLAS `domatcopy`) vs a naive double loop, 2048² |
| `factor` | wall times for `solve`, `cholesky`, `svd`, `eigSymmetric` |
| `complex` | **complex parity gate** (raw `zgemm` vs complex `gemmInto` vs `a * b`) plus `zgesv`, `zheev`, `zgesdd`, `zpotrf`, `zgeqrf+zungqr`, with an `(AB)ᴴ = BᴴAᴴ` correctness gate |
| `advanced` | `dsygvd` generalized eig, `expm`, `dgeev` eigen+vectors, `dgees` Schur |

## Representative results (containerised x86-64, OpenBLAS 0.3.33)

```
real   raw cblas_dgemm 768²   :  ~4.5–6.8 ms   ≈200 GFLOP/s
       matcang gemmInto       :   within the 1.25x gate (usually ≈ raw)
       matcang a * b          :   slower — pays result allocation each call
complex raw cblas_zgemm 512²  :   5.26 ms      204.1 GFLOP/s
       matcang gemmInto       :   5.64 ms      190.3 GFLOP/s   <- 7.2% over raw C
       matcang a * b          :  10.15 ms      105.8 GFLOP/s   <- allocation-bound
a + b vs closure loop  :  5.1x faster (daxpy)
a * 2.0 vs closure     :  3.2x faster (dscal)
transpose vs naive     :  1.2x faster (domatcopy)
```

Numbers vary with hardware and thread count; the *ratios* are the point. The
harness (`src/harness.cj`) is reusable: median-of-N timing with warmup,
GFLOP/s helpers and aligned table output.

## Interpreting

- **gemmInto ≈ raw** proves the Cangjie wrapper layer costs nothing measurable:
  buffers cross the FFI zero-copy and the call is a single forward.
- **`a * b` slower than `gemmInto`** is the price of immutability (a fresh
  result matrix per call), an `O(n²)` cost against `O(n³)` work — amortised
  away as `n` grows; use `gemmInto` in tight loops.
- The element-wise and transpose suites document why those paths were moved
  onto BLAS kernels rather than per-element closures.
