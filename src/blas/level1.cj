/*
 * matcang.blas - level-1 BLAS (vector-vector) with explicit control.
 *
 * The ergonomic operators on Vector cover the common cases; these expose the
 * fused `alpha * x + y` (axpy) and in-place scaling that performance-sensitive
 * code wants.
 */
package matcang.blas

import matcang.{daxpy, dscal}
import matcang.core.{Vector, DimensionMismatchException}

/**
 * Fused update `alpha * x + y` returned as a new vector (BLAS daxpy). Neither
 * input is modified.
 */
public func axpy(alpha: Float64, x: Vector, y: Vector): Vector {
    if (x.size != y.size) {
        throw DimensionMismatchException("axpy: vector sizes differ: ${x.size} vs ${y.size}")
    }
    let result = y.copy()
    if (x.size == 0) {
        return result
    }
    unsafe {
        let hx = acquireArrayRawData(x.data)
        let hr = acquireArrayRawData(result.data)
        daxpy(Int32(x.size), alpha, hx.pointer, 1, hr.pointer, 1)
        releaseArrayRawData(hr)
        releaseArrayRawData(hx)
    }
    result
}

/** Scale `x` in place by `alpha` (BLAS dscal); returns the same vector. */
public func scaleInPlace(x: Vector, alpha: Float64): Vector {
    if (x.size == 0) {
        return x
    }
    unsafe {
        let hx = acquireArrayRawData(x.data)
        dscal(Int32(x.size), alpha, hx.pointer, 1)
        releaseArrayRawData(hx)
    }
    x
}
