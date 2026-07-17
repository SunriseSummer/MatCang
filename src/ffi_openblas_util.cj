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

// OpenBLAS utility/control functions : 7 functions

foreign {
    func openblas_set_num_threads(p0: Int32): Unit
    func openblas_get_num_threads(): Int32
    func openblas_get_num_procs(): Int32
    func openblas_get_config(): CString
    func openblas_get_corename(): CString
    func openblas_set_threads_callback_function(p0: CPointer<Unit>): Unit
    func openblas_get_parallel(): Int32
}
