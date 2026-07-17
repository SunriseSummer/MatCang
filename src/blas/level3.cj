/*
 * matcang.blas - level-3 BLAS (matrix-matrix) with explicit control.
 *
 * These free functions expose the full generality of the underlying BLAS
 * kernels (transposition flags, scalar multipliers) that the ergonomic Matrix
 * operators deliberately hide. They return freshly allocated results and never
 * mutate their inputs.
 */
package matcang.blas

import matcang.{dgemm, dsyrk, Cblas}
import matcang.core.{Matrix, Transpose, Triangle, DimensionMismatchException}

/**
 * General matrix-matrix product `alpha * op(a) * op(b)`, where `op(x)` is `x`
 * or `x^T` per the transpose flags. Dispatches to BLAS dgemm.
 */
public func gemm(
    a: Matrix,
    b: Matrix,
    transA!: Transpose = Transpose.NoTrans,
    transB!: Transpose = Transpose.NoTrans,
    alpha!: Float64 = 1.0
): Matrix {
    let (m, k) = opDims(a, transA)
    let (k2, n) = opDims(b, transB)
    if (k != k2) {
        throw DimensionMismatchException("gemm inner dimensions disagree: ${m}x${k} times ${k2}x${n}")
    }
    let c = Matrix(m, n)
    if (m == 0 || n == 0 || k == 0) {
        return c
    }
    unsafe {
        let ha = acquireArrayRawData(a.data)
        let hb = acquireArrayRawData(b.data)
        let hc = acquireArrayRawData(c.data)
        dgemm(Cblas.ROW_MAJOR, transA.toCblas(), transB.toCblas(), Int32(m), Int32(n), Int32(k), alpha, ha.pointer,
            Int32(a.cols), hb.pointer, Int32(b.cols), 0.0, hc.pointer, Int32(n))
        releaseArrayRawData(hc)
        releaseArrayRawData(hb)
        releaseArrayRawData(ha)
    }
    c
}

/**
 * In-place general matrix-matrix update `c = alpha * op(a) * op(b) + beta * c`,
 * writing into the caller-provided `c`. This is the allocation-free path for
 * performance-sensitive inner loops; `c` must already have the result shape.
 * Dispatches to BLAS dgemm.
 */
public func gemmInto(
    a: Matrix,
    b: Matrix,
    c: Matrix,
    transA!: Transpose = Transpose.NoTrans,
    transB!: Transpose = Transpose.NoTrans,
    alpha!: Float64 = 1.0,
    beta!: Float64 = 0.0
): Unit {
    let (m, k) = opDims(a, transA)
    let (k2, n) = opDims(b, transB)
    if (k != k2) {
        throw DimensionMismatchException("gemmInto inner dimensions disagree: ${m}x${k} times ${k2}x${n}")
    }
    if (c.rows != m || c.cols != n) {
        throw DimensionMismatchException("gemmInto output is ${c.rows}x${c.cols}, expected ${m}x${n}")
    }
    if (m == 0 || n == 0 || k == 0) {
        return
    }
    unsafe {
        let ha = acquireArrayRawData(a.data)
        let hb = acquireArrayRawData(b.data)
        let hc = acquireArrayRawData(c.data)
        dgemm(Cblas.ROW_MAJOR, transA.toCblas(), transB.toCblas(), Int32(m), Int32(n), Int32(k), alpha, ha.pointer,
            Int32(a.cols), hb.pointer, Int32(b.cols), beta, hc.pointer, Int32(n))
        releaseArrayRawData(hc)
        releaseArrayRawData(hb)
        releaseArrayRawData(ha)
    }
}

/**
 * Symmetric rank-k update: returns the symmetric matrix
 * `alpha * op(a) * op(a)^T` (with `op(a) = a` for NoTrans, `a^T` for Trans).
 * Only the requested triangle is computed by BLAS; the result is mirrored into
 * a full dense symmetric matrix. Dispatches to BLAS dsyrk.
 */
public func syrk(
    a: Matrix,
    trans!: Transpose = Transpose.NoTrans,
    alpha!: Float64 = 1.0,
    uplo!: Triangle = Triangle.Upper
): Matrix {
    let (n, k) = opDims(a, trans)
    let c = Matrix(n, n)
    if (n == 0) {
        return c
    }
    unsafe {
        let ha = acquireArrayRawData(a.data)
        let hc = acquireArrayRawData(c.data)
        dsyrk(Cblas.ROW_MAJOR, uplo.toCblas(), trans.toCblas(), Int32(n), Int32(k), alpha, ha.pointer, Int32(a.cols),
            0.0, hc.pointer, Int32(n))
        releaseArrayRawData(hc)
        releaseArrayRawData(ha)
    }
    mirrorTriangle(c, uplo)
    c
}

/** Dimensions (rows, cols) of `op(x)` given the transpose flag. */
func opDims(x: Matrix, trans: Transpose): (Int64, Int64) {
    match (trans) {
        case NoTrans => (x.rows, x.cols)
        case _ => (x.cols, x.rows)
    }
}

/** Fill the opposite triangle so a one-sided symmetric result is fully dense. */
func mirrorTriangle(c: Matrix, uplo: Triangle): Unit {
    let n = c.rows
    match (uplo) {
        case Upper => for (i in 0..n) {
            for (j in 0..i) {
                c.data[i * n + j] = c.data[j * n + i]
            }
        }
        case Lower => for (i in 0..n) {
            for (j in (i + 1)..n) {
                c.data[i * n + j] = c.data[j * n + i]
            }
        }
    }
}
