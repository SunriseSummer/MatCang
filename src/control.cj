/*
 * Runtime control over the OpenBLAS backend: thread counts and build info.
 * Thin safe wrappers over the openblas_* control functions (root package).
 */
package matcang

/** Set the number of threads OpenBLAS may use for subsequent operations. */
public func setNumThreads(n: Int32): Unit {
    unsafe { openblas_set_num_threads(n) }
}

/** The number of threads OpenBLAS is currently configured to use. */
public func getNumThreads(): Int32 {
    unsafe { openblas_get_num_threads() }
}

/** The number of physical cores OpenBLAS detected. */
public func getNumProcs(): Int32 {
    unsafe { openblas_get_num_procs() }
}

/** OpenBLAS build/configuration string (target CPU, threading model, ...). */
public func getConfig(): String {
    unsafe { openblas_get_config().toString() }
}

/** The CPU micro-architecture kernel OpenBLAS selected at runtime. */
public func getCoreName(): String {
    unsafe { openblas_get_corename().toString() }
}

/** Parallelisation model: 0 = sequential, 1 = pthreads, 2 = OpenMP. */
public func getParallel(): Int32 {
    unsafe { openblas_get_parallel() }
}
