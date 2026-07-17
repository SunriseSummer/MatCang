/*
 * Public, safe-to-link wrappers over the raw OpenBLAS foreign decls.
 * AUTO-GENERATED; do not edit by hand (see .devtools/gen_bindings.py).
 *
 * Cangjie `foreign` functions only resolve to their C symbol when called
 * from inside their declaring package, so these thin `unsafe` forwarders
 * (regular public functions, hence linkable across the whole module) give
 * every subpackage - and external users - access to the full BLAS/LAPACK
 * surface under its canonical routine name (e.g. `dgemm`, `dgesv`).
 */
package matcang

// LAPACK aux bindings : 2 wrappers

public unsafe func ilaver(p0: CPointer<Int32>, p1: CPointer<Int32>, p2: CPointer<Int32>): Unit { LAPACKE_ilaver(p0, p1, p2) }
public unsafe func get_nancheck(): Int32 { LAPACKE_get_nancheck() }
