# matcang examples — a guided tour

Eighteen self-contained programs, each a real piece of mathematics **and** an
end-to-end test (prints `OK` and exits 0 only when its numerical claims hold).
Run any of them with:

```bash
cd <example> && cjpm run
```

## Where to start

**New to matcang?** Read and run in this order — each step introduces one new
layer of the library:

1. [`api_tour`](api_tour) — every API area in small self-checking snippets;
   your interactive reference.
2. [`kalman_filter`](kalman_filter) — first real algorithm: operators that
   read like the textbook equations.
3. [`pagerank`](pagerank) — matrix–vector iteration meets a famous idea.
4. Pick any track below.

## The full menu

| Example | 难度 | The hook | Library focus |
|---------|------|----------|---------------|
| [`api_tour`](api_tour) | ★ | the whole API, one file, 70+ checks | everything |
| [`kalman_filter`](kalman_filter) | ★ | filter a noisy track like a navigation system | operators, `.t`, `inverse` |
| [`markov_chain`](markov_chain) | ★ | tomorrow's weather, the climate, and the speed of forgetting | `matrixPower`, `solve`, `eigenvalues` |
| [`pagerank`](pagerank) | ★ | the eigenvector that ranked the web | matvec iteration, `solve`, `norm1` |
| [`svd_compression`](svd_compression) | ★★ | compress an image; watch Eckart–Young hold *exactly* | `svd`, `frobeniusNorm` |
| [`polynomial_regression`](polynomial_regression) | ★★ | Runge's revenge: why degree-10 fits misbehave | `lstsq`, `cond`, Vandermonde |
| [`gps_locate`](gps_locate) | ★★ | "where am I?" — how GPS actually solves it | `lstsq` inside Gauss–Newton |
| [`pattern_recognition`](pattern_recognition) | ★★ | PCA + k-means find structure without labels | covariance, `eigSymmetric` |
| [`spectral_partition`](spectral_partition) | ★★ | cut a graph with the *sign pattern* of one eigenvector | Laplacian, `eigSymmetric` |
| [`robust_fitting`](robust_fitting) | ★★ | RANSAC shrugs off outliers; `trySolve` skips degenerate draws | `try*` API, `lstsq` |
| [`neural_network`](neural_network) | ★★ | an MLP learns XOR by hand-written backprop | `gemm` w/ transposes, `hadamard` |
| [`finite_element`](finite_element) | ★★★ | a PDE solver in 100 lines, with provable O(h²) convergence | assembly, `solve` |
| [`heat_equation`](heat_equation) | ★★★ | factor once, march 200 timesteps by back-substitution | `lu`, `solveTriangular` |
| [`als_recommender`](als_recommender) | ★★★ | a working recommender system (the Netflix-Prize workhorse) | `solveSPDMatrix` at scale |

### Complex numbers & advanced solvers

| Example | 难度 | The hook | Library focus |
|---------|------|----------|---------------|
| [`dft_spectrum`](dft_spectrum) | ★★ | the Fourier transform *is* a matrix; read a signal's frequencies | `ComplexMatrix`, `zgemv`, `.h` |
| [`rlc_circuit`](rlc_circuit) | ★★ | AC circuits are complex linear systems; watch resonance appear | complex `solve` (`zgesv`) |
| [`quantum_spin`](quantum_spin) | ★★★ | a qubit in a field: real energies, complex states | `eigHermitian` (`zheev`), `dotc` |
| [`vibration_modes`](vibration_modes) | ★★★ | a structure's natural frequencies, checked against closed form | `eigSymmetricGeneralized` (`dsygvd`) |

## Three ideas worth stealing

- **Every example is an assertion.** The printed numbers are checked against
  theory (Eckart–Young, O(h²), spectral gaps, exact solutions) — if the library
  regresses, an example fails loudly. Steal this for your own numeric code.
- **Factor once, solve many** (`heat_equation`): when the matrix doesn't
  change, `lu` + two `solveTriangular` calls per step replace an O(n³) solve
  with O(n²) back-substitution.
- **`try*` in sampling loops** (`robust_fitting`): degenerate random draws are
  data, not exceptions — branch on `None` and resample.

Performance measurements live in [`../bench`](../bench), not here: examples
demonstrate *what* the library does; bench proves *how fast*.
