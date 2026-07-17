# Third-party notices

matcang redistributes the following third-party components in binary form in
its **release packages** (under `.openblas/lib/<platform>/`; the binaries are
not committed to the source repository). Their license texts accompany the
binaries or are referenced below; nothing in this project modifies their
upstream sources except as described.

## OpenBLAS 0.3.33 — BSD 3-Clause

- Files: `.openblas/lib/linux_x86_64/libopenblas*.so`,
  `.openblas/lib/windows_x86_64/libopenblas.dll` (+ `openblas.dll`
  copy and `libopenblas.dll.a` import library),
  `.openblas/lib/macos_arm64/libopenblas*.dylib`,
  and the headers under `.openblas/include/`.
- License: BSD 3-Clause — see [`.openblas/LICENSE`](.openblas/LICENSE).
- Provenance: Linux and Windows binaries are built unmodified from the
  [OpenBLAS v0.3.33 tag](https://github.com/OpenMathLib/OpenBLAS/tree/v0.3.33)
  (`.devtools/build_openblas.sh`, `.devtools/build_openblas_windows.sh`). The macOS
  arm64 binary is the conda-forge `libopenblas 0.3.33` build; its Mach-O load
  commands were rewritten to `@loader_path` for relocatability
  (`.devtools/fetch_openblas_macos.sh`) — no code changes.

## GCC runtime libraries — GPL-3.0 with GCC Runtime Library Exception

The Fortran/GCC support runtimes that OpenBLAS's LAPACK component links
against are redistributed alongside the binaries:

- Windows (mingw-w64 win32-thread runtimes): `libgfortran-5.dll`,
  `libgcc_s_seh-1.dll`, `libquadmath-0.dll`, `libwinpthread-1.dll`
  (libwinpthread carries the MIT/BSD-style mingw-w64 licence).
- macOS (conda-forge gfortran runtimes): `libgfortran.5.dylib`,
  `libgcc_s.1.1.dylib`, `libquadmath.0.dylib`.

These are unmodified runtime libraries distributed under the GCC Runtime
Library Exception, which permits redistribution with programs of any license:
<https://www.gnu.org/licenses/gcc-exception-3.1.html>.

## Interface derivation

The generated bindings under `matcang/src/ffi_*.cj` and
`matcang/src/*_binding.cj` are mechanically derived from the OpenBLAS public
C headers (`cblas.h`, `lapacke.h`; BSD 3-Clause) by `.devtools/gen_bindings.py`.
