/*
 * matcang.blas - complex level-3 BLAS (matrix-matrix) with explicit control.
 *
 * Complex counterparts of `gemm` / `gemmInto`: full transpose control
 * (including ConjTrans - meaningful only for complex operands) and complex
 * alpha/beta scalars. `gemmInto` is the allocation-free hot path, held to the
 * same wrapper-parity standard as the real one (see bench/).
 */
package matcang.blas

import matcang.{zgemm, CxF64, Cblas}
import matcang.core.{Complex, ComplexMatrix, Transpose, DimensionMismatchException}

/**
 * General complex matrix-matrix product `alpha * op(a) * op(b)`, where `op(x)`
 * is `x`, `x^T` or `x^H` per the transpose flags. Dispatches to BLAS zgemm.
 */
public func gemm(
    a: ComplexMatrix,
    b: ComplexMatrix,
    transA!: Transpose = Transpose.NoTrans,
    transB!: Transpose = Transpose.NoTrans,
    alpha!: Complex = Complex(1.0, 0.0)
): ComplexMatrix {
    let (m, k) = opDimsCx(a, transA)
    let (k2, n) = opDimsCx(b, transB)
    if (k != k2) {
        throw DimensionMismatchException("gemm inner dimensions disagree: ${m}x${k} times ${k2}x${n}")
    }
    let c = ComplexMatrix(m, n)
    if (m == 0 || n == 0 || k == 0) {
        return c
    }
    zgemmCall(a, b, c, transA, transB, CxF64(alpha.re, alpha.im), CxF64(0.0, 0.0), m, n, k)
    c
}

/**
 * In-place complex update `c = alpha * op(a) * op(b) + beta * c`, writing into
 * the caller-provided `c` - the allocation-free path for tight loops. `c` must
 * already have the result shape. Dispatches to BLAS zgemm.
 */
public func gemmInto(
    a: ComplexMatrix,
    b: ComplexMatrix,
    c: ComplexMatrix,
    transA!: Transpose = Transpose.NoTrans,
    transB!: Transpose = Transpose.NoTrans,
    alpha!: Complex = Complex(1.0, 0.0),
    beta!: Complex = Complex(0.0, 0.0)
): Unit {
    let (m, k) = opDimsCx(a, transA)
    let (k2, n) = opDimsCx(b, transB)
    if (k != k2) {
        throw DimensionMismatchException("gemmInto inner dimensions disagree: ${m}x${k} times ${k2}x${n}")
    }
    if (c.rows != m || c.cols != n) {
        throw DimensionMismatchException("gemmInto output is ${c.rows}x${c.cols}, expected ${m}x${n}")
    }
    if (m == 0 || n == 0 || k == 0) {
        return
    }
    zgemmCall(a, b, c, transA, transB, CxF64(alpha.re, alpha.im), CxF64(beta.re, beta.im), m, n, k)
}

/** Shared zgemm dispatch (alpha/beta passed by pointer, as CBLAS requires). */
func zgemmCall(
    a: ComplexMatrix,
    b: ComplexMatrix,
    c: ComplexMatrix,
    transA: Transpose,
    transB: Transpose,
    alpha: CxF64,
    beta: CxF64,
    m: Int64,
    n: Int64,
    k: Int64
): Unit {
    let al = Array<CxF64>(1, repeat: alpha)
    let be = Array<CxF64>(1, repeat: beta)
    unsafe {
        let ha = acquireArrayRawData(a.data)
        let hb = acquireArrayRawData(b.data)
        let hc = acquireArrayRawData(c.data)
        let hal = acquireArrayRawData(al)
        let hbe = acquireArrayRawData(be)
        zgemm(Cblas.ROW_MAJOR, transA.toCblas(), transB.toCblas(), Int32(m), Int32(n), Int32(k), hal.pointer, ha.pointer,
            Int32(a.cols), hb.pointer, Int32(b.cols), hbe.pointer, hc.pointer, Int32(n))
        releaseArrayRawData(hbe)
        releaseArrayRawData(hal)
        releaseArrayRawData(hc)
        releaseArrayRawData(hb)
        releaseArrayRawData(ha)
    }
}

/** Dimensions (rows, cols) of `op(x)` given the transpose flag. */
func opDimsCx(x: ComplexMatrix, trans: Transpose): (Int64, Int64) {
    match (trans) {
        case NoTrans => (x.rows, x.cols)
        case _ => (x.cols, x.rows)
    }
}
