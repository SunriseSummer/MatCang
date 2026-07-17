# Calling the raw bindings

The high-level API (`Matrix`, `ComplexMatrix`, `solve`, `svd`, …) covers the
routines applications reach for. But the generated FFI layer maps the **whole**
OpenBLAS C interface — 2642 callable wrappers across all four precisions
(`s`/`d`/`c`/`z`), every BLAS level and the full LAPACKE surface. When you need
a routine the high-level API doesn't wrap — a banded solver, a specific driver,
a single-precision kernel — call its wrapper directly. This page shows how.

## The layer

For every C routine the generator emits a `public unsafe` wrapper in the root
`matcang` package, named for the canonical BLAS/LAPACK routine (the `cblas_` /
`LAPACKE_` prefix dropped):

```
cblas_dgemm   ->  matcang.dgemm
LAPACKE_zgesv ->  matcang.zgesv
LAPACKE_dgbsv ->  matcang.dgbsv   (banded solve; not in the high-level API)
```

They are `unsafe` and take raw `CPointer`s — you manage layout, leading
dimensions and the `info` return yourself. Import them from `matcang`.

## The three rules

1. **Hand buffers to C zero-copy** with `acquireArrayRawData` /
   `releaseArrayRawData`. Acquire inside an `unsafe` block, use `.pointer`, and
   release **after** the single call (release in reverse order of acquire):

   ```cangjie
   unsafe {
       let ha = acquireArrayRawData(a.data)
       let hb = acquireArrayRawData(b.data)
       // ... one C call using ha.pointer, hb.pointer ...
       releaseArrayRawData(hb)
       releaseArrayRawData(ha)
   }
   ```

2. **Pass the row-major layout flag.** matcang stores matrices row-major, so use
   `Lapack.ROW_MAJOR` (LAPACKE) or `Cblas.ROW_MAJOR` (CBLAS); LAPACKE then does
   any internal transposition. With row-major storage the leading dimension of
   an m×n matrix is its column count `n`.

3. **Check the `info` return.** LAPACKE wrappers return `Int32`: `0` success,
   `< 0` an illegal argument (position `-info`), `> 0` a data condition
   (singular pivot, no convergence, …).

## Example — a banded solve (`dgbsv`, not in the high-level API)

```cangjie
import matcang.{dgbsv, Lapack}

// Solve a banded system A x = b. A is stored in LAPACK band form (see the
// LAPACK docs for the layout); kl/ku are the sub/super-diagonal counts.
unsafe {
    let hab = acquireArrayRawData(ab.data)   // banded storage buffer
    let hip = acquireArrayRawData(ipiv)      // Array<Int32>, length n
    let hb  = acquireArrayRawData(x.data)    // rhs, overwritten with the solution
    let info = dgbsv(Lapack.ROW_MAJOR, Int32(n), Int32(kl), Int32(ku), Int32(nrhs),
                     hab.pointer, Int32(ldab), hip.pointer, hb.pointer, Int32(nrhs))
    releaseArrayRawData(hb); releaseArrayRawData(hip); releaseArrayRawData(hab)
    if (info != 0) { /* handle */ }
}
```

## Complex routines

Complex operands are typed `CPointer<CxF32>` / `CPointer<CxF64>` (the `@C`
interleaved `(re, im)` value types), so back them with `Array<CxF32>` /
`Array<CxF64>`. CBLAS complex scalars (α/β) are passed **by pointer** — a
length-1 array of `CxF64`.

One caveat: the four complex dot routines that return **by value**
(`cdotu`, `cdotc`, `zdotu`, `zdotc`) are ABI-fragile across platforms. Prefer
the `*_sub` variants (`zdotu_sub`, …), which write the result through an output
pointer and are safe everywhere — this is what `ComplexVector.dot`/`dotc` use.

## When to prefer the high-level API

The wrappers cost nothing at runtime, but they give up type safety and shape
checks. For anything the high-level API already covers, use it — the raw layer
is for reaching routines it doesn't. See [`API.md`](API.md) for the high-level
surface and [`DESIGN.md`](DESIGN.md) for why the wrappers exist and link.
