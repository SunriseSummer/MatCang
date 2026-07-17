/*
 * matcang.linalg - linear systems, inverse and determinant via LAPACK LU.
 *
 * All routines take row-major matrices and pass the LapackRowMajor layout, so
 * LAPACKE handles the storage conversion internally. Inputs are never mutated;
 * factorisations work on copies.
 */
package matcang.linalg

import matcang.{dgesv, dgetrf, dgetri, Lapack}
import matcang.core.{Matrix, Vector, NonSquareMatrixException, SingularMatrixException, BlasArgumentException, 
    DimensionMismatchException}

/**
 * Solve the linear system `a x = b` for a single right-hand side.
 * `a` must be square and non-singular. Dispatches to LAPACK dgesv.
 */
public func solve(a: Matrix, b: Vector): Vector {
    requireSquare(a)
    if (a.rows != b.size) {
        throw DimensionMismatchException("solve: matrix is ${a.rows}x${a.cols}, rhs length ${b.size}")
    }
    let n = a.rows
    let lu = a.copy()
    let x = b.copy()
    if (n == 0) {
        return x
    }
    let ipiv = Array<Int32>(n, repeat: 0)
    var info: Int32 = 0
    unsafe {
        let ha = acquireArrayRawData(lu.data)
        let hb = acquireArrayRawData(x.data)
        let hp = acquireArrayRawData(ipiv)
        info = dgesv(Lapack.ROW_MAJOR, Int32(n), 1, ha.pointer, Int32(n), hp.pointer, hb.pointer, 1)
        releaseArrayRawData(hp)
        releaseArrayRawData(hb)
        releaseArrayRawData(ha)
    }
    checkInfo(info, "dgesv")
    x
}

/**
 * Solve `a X = B` for a matrix of right-hand sides (columns of `b`).
 * Dispatches to LAPACK dgesv.
 */
public func solveMatrix(a: Matrix, b: Matrix): Matrix {
    requireSquare(a)
    if (a.rows != b.rows) {
        throw DimensionMismatchException("solveMatrix: ${a.rows}x${a.cols} vs rhs ${b.rows}x${b.cols}")
    }
    let n = a.rows
    let nrhs = b.cols
    let lu = a.copy()
    let x = b.copy()
    if (n == 0 || nrhs == 0) {
        return x
    }
    let ipiv = Array<Int32>(n, repeat: 0)
    var info: Int32 = 0
    unsafe {
        let ha = acquireArrayRawData(lu.data)
        let hb = acquireArrayRawData(x.data)
        let hp = acquireArrayRawData(ipiv)
        info = dgesv(Lapack.ROW_MAJOR, Int32(n), Int32(nrhs), ha.pointer, Int32(n), hp.pointer, hb.pointer, Int32(nrhs))
        releaseArrayRawData(hp)
        releaseArrayRawData(hb)
        releaseArrayRawData(ha)
    }
    checkInfo(info, "dgesv")
    x
}

/** Matrix inverse via LU factorisation (LAPACK dgetrf + dgetri). */
public func inverse(a: Matrix): Matrix {
    requireSquare(a)
    let n = a.rows
    let inv = a.copy()
    if (n == 0) {
        return inv
    }
    let ipiv = Array<Int32>(n, repeat: 0)
    var info: Int32 = 0
    unsafe {
        let hi = acquireArrayRawData(inv.data)
        let hp = acquireArrayRawData(ipiv)
        info = dgetrf(Lapack.ROW_MAJOR, Int32(n), Int32(n), hi.pointer, Int32(n), hp.pointer)
        releaseArrayRawData(hp)
        releaseArrayRawData(hi)
    }
    checkInfo(info, "dgetrf")
    unsafe {
        let hi = acquireArrayRawData(inv.data)
        let hp = acquireArrayRawData(ipiv)
        info = dgetri(Lapack.ROW_MAJOR, Int32(n), hi.pointer, Int32(n), hp.pointer)
        releaseArrayRawData(hp)
        releaseArrayRawData(hi)
    }
    checkInfo(info, "dgetri")
    inv
}

/** Determinant via LU factorisation (product of U's diagonal, pivot-signed). */
public func determinant(a: Matrix): Float64 {
    requireSquare(a)
    let n = a.rows
    if (n == 0) {
        return 1.0
    }
    let lu = a.copy()
    let ipiv = Array<Int32>(n, repeat: 0)
    var info: Int32 = 0
    unsafe {
        let hl = acquireArrayRawData(lu.data)
        let hp = acquireArrayRawData(ipiv)
        info = dgetrf(Lapack.ROW_MAJOR, Int32(n), Int32(n), hl.pointer, Int32(n), hp.pointer)
        releaseArrayRawData(hp)
        releaseArrayRawData(hl)
    }
    if (info > 0) {
        return 0.0 // singular: U has a zero on the diagonal
    }
    checkInfo(info, "dgetrf")
    var det = 1.0
    for (i in 0..n) {
        det *= lu.data[i * n + i]
    }
    // account for row interchanges (ipiv is 1-based)
    for (i in 0..n) {
        if (Int64(ipiv[i]) != i + 1) {
            det = -det
        }
    }
    det
}

func requireSquare(a: Matrix): Unit {
    if (a.rows != a.cols) {
        throw NonSquareMatrixException("expected a square matrix, got ${a.rows}x${a.cols}")
    }
}

/** Translate a LAPACK `info` return into an exception (0 means success). */
func checkInfo(info: Int32, routine: String): Unit {
    if (info < 0) {
        throw BlasArgumentException("${routine}: argument ${-info} had an illegal value")
    }
    if (info > 0) {
        throw SingularMatrixException("${routine}: matrix is singular (U[${info},${info}] = 0)")
    }
}
