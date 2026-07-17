/*
 * Raw foreign declarations for the OpenBLAS C API.
 * AUTO-GENERATED from OpenBLAS v0.3.33 headers (cblas.h / lapacke.h).
 * Do not edit by hand; regenerate with tools/gen_bindings.py.
 *
 * These live in the root `matcang` package (not a subpackage) because
 * Cangjie `foreign` functions are package-internal and can carry no access
 * modifier; keeping them at the root lets every matcang.* subpackage call
 * them while remaining hidden from external importers.
 */
package matcang

// LAPACKE aux routines : 2 functions

foreign {
    func LAPACKE_ilaver(p0: CPointer<Int32>, p1: CPointer<Int32>, p2: CPointer<Int32>): Unit
    func LAPACKE_get_nancheck(): Int32
}
