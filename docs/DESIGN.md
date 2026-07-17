# Design notes

This document records the architecture of matcang and the reasoning behind its
less-obvious choices — most importantly how the Cangjie-C interop layer is
structured so that thousands of BLAS/LAPACK functions are both *mapped* and
*callable* from a clean, layered package hierarchy.

## Goals

1. **Map the entire OpenBLAS C interface.** Every function exported through
   CBLAS and LAPACKE should have a corresponding Cangjie binding.
2. **Offer a modern, elegant high-level API.** Users should think in matrices
   and mathematics, not pointers and column-major leading dimensions.
3. **Pay no meaningful performance tax.** Compute must run at native OpenBLAS
   speed; the Cangjie layer must not copy buffers or interpret element-wise.

## Layering

```
matcang            root package: raw `foreign` decls + public wrappers + control
matcang.core       Matrix, Vector, Complex, enums, errors, formatting
matcang.blas       explicit-control BLAS free functions
matcang.linalg     LAPACK-backed linear algebra
matcang.prelude    re-export of core + blas + linalg
```

Dependencies point strictly downward (`prelude → {core, blas, linalg} → root`),
forming the acyclic graph cjpm requires.

## The FFI linking constraint

Two properties of Cangjie's C interop shaped the whole layout:

1. **`foreign` functions carry no access modifier.** They are always
   package-*internal* — visible in their declaring package and its subpackages,
   never to a sibling package or an external module.
2. **A `foreign` call only resolves to its C symbol inside its declaring
   package.** Called from another package, the reference is name-mangled with
   the caller's package and fails to link.

The consequence is strict: *all code that calls a `foreign` function must live
in that function's own package.* A naïve `matcang.ffi` subpackage holding the
declarations therefore cannot be used by `matcang.core` (a sibling) — it
compiles but does not link.

### The solution: root declarations + canonical wrappers

matcang resolves this in two steps:

- **Raw `foreign` declarations live in the root `matcang` package.** Because the
  ergonomic packages (`core`, `blas`, `linalg`) are *subpackages* of `matcang`,
  the internal declarations are visible to them.
- **Generated public wrappers make them linkable.** For each C routine the
  generator also emits a regular (non-`foreign`) `public unsafe` function *in the
  same root package* that forwards to the `foreign` call. Being an ordinary
  Cangjie function, it links across the whole module and to external users; being
  in the same package as the `foreign` declaration, its internal call resolves to
  the C symbol. The wrappers are named for the canonical BLAS/LAPACK routine —
  `dgemm`, `dgesv`, `dgesdd` — dropping the `cblas_` / `LAPACKE_` C-interface
  prefix.

```
   cblas_dgemm   (foreign, internal, root)      <-- the C symbol
        ▲
        │ same-package call resolves to C
        │
   public unsafe func dgemm(...)  (root)         <-- linkable everywhere
        ▲
        │ ordinary cross-package call
        │
   matcang.core / blas / linalg                  <-- use dgemm(...)
```

The root package's re-export of the ergonomic API is deliberately omitted (it
would create a cycle: `root → core → root`); the one-import convenience lives in
the leaf `matcang.prelude` instead.

## Binding generation

`tools/gen_bindings.py` parses the OpenBLAS headers (`cblas.h`, `lapacke.h`) and
emits:

- the `foreign` declaration blocks (`ffi_*.cj`), and
- the public wrapper functions (`blas_binding.cj`, `lapack_binding_*.cj`).

Type mapping is mechanical: `blasint`/`lapack_int` → `Int32`, `double*` →
`CPointer<Float64>`, `char` → `Int8`, C99 `float _Complex` → the ABI-compatible
`@C struct CxF32`, enum flags → `Int32`, and so on. Declarations are filtered
against the symbols the built `libopenblas.so` actually exports, so bindings for
routines this build omits (extended-precision `*svxx`, bfloat16, half-precision)
are simply not generated and everything links.

Regenerate after changing the OpenBLAS build with `tools/build_openblas.sh`.

## Storage and interop

- `Matrix` stores its data **row-major** in a flat `Array<Float64>`; element
  `(i, j)` is at `data[i * cols + j]`. All BLAS/LAPACK calls pass the row-major
  layout flag (`Cblas.ROW_MAJOR` / `Lapack.ROW_MAJOR`), so LAPACKE performs any
  storage conversion internally and users never think column-major.
- Matrix and vector buffers are handed to C **zero-copy** with
  `acquireArrayRawData` / `releaseArrayRawData`; nothing is allocated or copied
  to cross the boundary. The acquire/release pair brackets exactly one C call,
  as the interop contract requires.
- Arithmetic operators return fresh values (immutable-by-default), while the
  `matcang.blas` layer and in-place helpers are available when avoiding
  allocation matters.

## Error handling

LAPACK's `info` return code is translated into a typed exception:
`info < 0` (bad argument) → `BlasArgumentException`; `info > 0` → a
context-specific `SingularMatrixException` or `ConvergenceException`. Shape
checks throw `DimensionMismatchException` / `NonSquareMatrixException` before any
native call, so misuse fails fast with a clear message rather than a crash.
