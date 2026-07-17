# Platform support

matcang ships a prebuilt OpenBLAS 0.3.33 runtime for three targets, so the
library builds and runs out of the box with no need to compile OpenBLAS from C
source:

| Platform     | Cangjie target        | Runtime shipped | Verified |
|--------------|-----------------------|-----------------|----------|
| Linux x64    | `x86_64-unknown-linux-gnu` | `libopenblas.so` (DYNAMIC_ARCH, built from source) | ✅ native run — 82 unit tests + 14 examples + bench |
| Windows x64  | `x86_64-w64-mingw32`       | `libopenblas.dll` + import lib + mingw runtime | ✅ cross-compiled + run under Wine — all examples |
| macOS arm64  | `aarch64-apple-darwin`     | `libopenblas.dylib` (self-contained bundle) | ⚙️ built & symbol-verified (see note) |

Everything lives under `third_party/openblas/lib/<platform>/`, and each
`cjpm.toml` selects the right one through a per-target `link-option` block — no
manual switching.

## How each runtime is produced

- **Linux x64** — built from the OpenBLAS v0.3.33 source with
  `DYNAMIC_ARCH=1` (runtime CPU dispatch), so one binary runs on any x86-64 CPU.
  Reproduce with `tools/build_openblas.sh`.
- **Windows x64** — cross-compiled from the same v0.3.33 source with the
  mingw-w64 toolchain (`DYNAMIC_ARCH=1`). The DLL's mingw runtime dependencies
  (`libgcc_s_seh-1`, `libgfortran-5`, `libquadmath-0`, `libwinpthread-1`) are
  bundled alongside it. Reproduce with `tools/build_openblas_windows.sh`.
- **macOS arm64** — the official conda-forge OpenBLAS 0.3.33 dylib (arm64,
  pthreads). Its Fortran runtime (`libgfortran.5`, `libquadmath.0`,
  `libgcc_s.1.1`) is bundled and every inter-library reference is rewritten to
  `@loader_path`, so the bundle is self-contained (only the always-present
  `/usr/lib/libSystem` remains external). Reproduce with
  `tools/fetch_openblas_macos.sh`.

## Binding portability

The Cangjie bindings are generated once against the **intersection** of the
symbols exported by all three runtimes (`third_party/openblas/openblas_symbols_common.txt`),
so every wrapped routine is guaranteed present on every platform. Only a handful
of x86-only kernels (`cblas_?gemm3m`, `cblas_?gemm_batch_strided`) are excluded;
none are used by the high-level API.

## Verification

- **Linux** is exercised natively: `cd matcang && cjpm test` (82 tests),
  `tools/run_examples.sh` (14 examples) and `cd bench && cjpm run`.
- **Windows** was verified by cross-compiling each example
  (`cjpm build --target x86_64-w64-mingw32`) and running the resulting `.exe`
  under Wine with the shipped DLL bundle. BLAS (`gemm`) and LAPACK (`dgesv`,
  `dgesdd`, `dsyev`) paths all produce results identical to Linux.
- **macOS arm64** binaries cannot be executed in the Linux build environment,
  so the dylib bundle is validated structurally: it is the official
  conda-forge 0.3.33 build, its exported symbols cover the full binding set, and
  its load commands were confirmed self-contained with `llvm-otool`. Because the
  bindings are the identical 0.3.33 C API proven correct on the other two
  platforms, the same calls apply unchanged.

## Runtime notes

- **Linux / macOS** resolve co-located libraries automatically (soname / rpath /
  `@loader_path`); `cjpm run` puts the library directory on the loader path.
- **Windows** searches the executable's own directory and `PATH` for DLLs (there
  is no rpath). Ensure the DLLs in `third_party/openblas/lib/windows_x86_64/`
  are alongside the built `.exe` or on `PATH` when running — for example copy
  them next to `target/.../bin/` or prepend that directory to `PATH`.
