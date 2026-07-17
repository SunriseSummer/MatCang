/*
 * matcang.blas - level-2 BLAS (matrix-vector).
 */
package matcang.blas

import matcang.{dgemv, dger, Cblas}
import matcang.core.{Matrix, Vector, Transpose, DimensionMismatchException}

/**
 * General matrix-vector product `alpha * op(a) * x`, where `op(a)` is `a` or
 * `a^T`. Dispatches to BLAS dgemv.
 */
public func gemv(
    a: Matrix,
    x: Vector,
    transA!: Transpose = Transpose.NoTrans,
    alpha!: Float64 = 1.0
): Vector {
    let noTrans = match (transA) {
        case NoTrans => true
        case _ => false
    }
    let inLen = if (noTrans) {
        a.cols
    } else {
        a.rows
    }
    let outLen = if (noTrans) {
        a.rows
    } else {
        a.cols
    }
    if (x.size != inLen) {
        throw DimensionMismatchException("gemv: operand length ${x.size} incompatible with ${a.rows}x${a.cols}")
    }
    let y = Vector(outLen)
    if (a.rows == 0 || a.cols == 0) {
        return y
    }
    unsafe {
        let ha = acquireArrayRawData(a.data)
        let hx = acquireArrayRawData(x.data)
        let hy = acquireArrayRawData(y.data)
        dgemv(Cblas.ROW_MAJOR, transA.toCblas(), Int32(a.rows), Int32(a.cols), alpha, ha.pointer, Int32(a.cols),
            hx.pointer, 1, 0.0, hy.pointer, 1)
        releaseArrayRawData(hy)
        releaseArrayRawData(hx)
        releaseArrayRawData(ha)
    }
    y
}

/**
 * Rank-1 update as a fresh matrix: `alpha * x * y^T` (outer product), an
 * `x.size` by `y.size` matrix. Dispatches to BLAS dger.
 */
public func ger(x: Vector, y: Vector, alpha!: Float64 = 1.0): Matrix {
    let m = x.size
    let n = y.size
    let a = Matrix(m, n)
    if (m == 0 || n == 0) {
        return a
    }
    unsafe {
        let hx = acquireArrayRawData(x.data)
        let hy = acquireArrayRawData(y.data)
        let ha = acquireArrayRawData(a.data)
        dger(Cblas.ROW_MAJOR, Int32(m), Int32(n), alpha, hx.pointer, 1, hy.pointer, 1, ha.pointer, Int32(n))
        releaseArrayRawData(ha)
        releaseArrayRawData(hy)
        releaseArrayRawData(hx)
    }
    a
}
