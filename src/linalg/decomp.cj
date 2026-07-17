/*
 * matcang.linalg - matrix factorisations: Cholesky, QR, SVD.
 */
package matcang.linalg

import matcang.{dpotrf, dgeqrf, dorgqr, dgesdd, Lapack}
import matcang.core.{Matrix, Vector, NonSquareMatrixException, SingularMatrixException, ConvergenceException, 
    BlasArgumentException}

/**
 * Cholesky factorisation of a symmetric positive-definite matrix.
 * Returns the lower-triangular `l` with `a = l * l^T` (or upper `u` with
 * `a = u^T * u` when `lower = false`). Dispatches to LAPACK dpotrf.
 */
public func cholesky(a: Matrix, lower!: Bool = true): Matrix {
    if (a.rows != a.cols) {
        throw NonSquareMatrixException("cholesky requires a square matrix, got ${a.rows}x${a.cols}")
    }
    let n = a.rows
    let c = a.copy()
    if (n == 0) {
        return c
    }
    let uplo: Int8 = if (lower) {
        76 // 'L'
    } else {
        85 // 'U'
    }
    var info: Int32 = 0
    unsafe {
        let hc = acquireArrayRawData(c.data)
        info = dpotrf(Lapack.ROW_MAJOR, uplo, Int32(n), hc.pointer, Int32(n))
        releaseArrayRawData(hc)
    }
    if (info > 0) {
        throw SingularMatrixException("cholesky: matrix is not positive definite (leading minor ${info})")
    }
    if (info < 0) {
        throw BlasArgumentException("dpotrf: argument ${-info} had an illegal value")
    }
    // zero the unused triangle for a clean result
    for (i in 0..n) {
        for (j in 0..n) {
            let keep = if (lower) {
                j <= i
            } else {
                j >= i
            }
            if (!keep) {
                c.data[i * n + j] = 0.0
            }
        }
    }
    c
}

/** Result of a (reduced) QR factorisation: `a = q * r`. */
public struct QR {
    public let q: Matrix
    public let r: Matrix

    public init(q: Matrix, r: Matrix) {
        this.q = q
        this.r = r
    }
}

/**
 * Reduced (economy) QR factorisation of an m-by-n matrix (m >= n): an
 * m-by-k `q` with orthonormal columns and a k-by-n upper-triangular `r`, where
 * `k = min(m, n)` and `a = q * r`. Dispatches to LAPACK dgeqrf + dorgqr.
 */
public func qr(a: Matrix): QR {
    let m = a.rows
    let ncol = a.cols
    let k = if (m < ncol) {
        m
    } else {
        ncol
    }
    let work = a.copy()
    if (m == 0 || ncol == 0) {
        return QR(Matrix(m, k), Matrix(k, ncol))
    }
    let tau = Array<Float64>(k, repeat: 0.0)
    var info: Int32 = 0
    unsafe {
        let hw = acquireArrayRawData(work.data)
        let ht = acquireArrayRawData(tau)
        info = dgeqrf(Lapack.ROW_MAJOR, Int32(m), Int32(ncol), hw.pointer, Int32(ncol), ht.pointer)
        releaseArrayRawData(ht)
        releaseArrayRawData(hw)
    }
    checkArg(info, "dgeqrf")
    // R = upper triangle (k x ncol)
    let r = Matrix(k, ncol)
    for (i in 0..k) {
        for (j in i..ncol) {
            r.data[i * ncol + j] = work.data[i * ncol + j]
        }
    }
    // form Q (m x k) in place, then extract respecting the physical stride ncol
    unsafe {
        let hw = acquireArrayRawData(work.data)
        let ht = acquireArrayRawData(tau)
        info = dorgqr(Lapack.ROW_MAJOR, Int32(m), Int32(k), Int32(k), hw.pointer, Int32(ncol), ht.pointer)
        releaseArrayRawData(ht)
        releaseArrayRawData(hw)
    }
    checkArg(info, "dorgqr")
    let q = Matrix(m, k)
    for (i in 0..m) {
        for (j in 0..k) {
            q.data[i * k + j] = work.data[i * ncol + j]
        }
    }
    QR(q, r)
}

/** Result of a singular value decomposition: `a = u * diag(s) * vt`. */
public struct SVD {
    public let u: Matrix
    public let s: Vector
    public let vt: Matrix

    public init(u: Matrix, s: Vector, vt: Matrix) {
        this.u = u
        this.s = s
        this.vt = vt
    }
}

/**
 * Reduced singular value decomposition of an m-by-n matrix: `u` (m-by-k),
 * singular values `s` (length k, descending) and `vt` (k-by-n), with
 * `k = min(m, n)` and `a = u * diag(s) * vt`. Dispatches to LAPACK dgesdd.
 */
public func svd(a: Matrix): SVD {
    let m = a.rows
    let n = a.cols
    let k = if (m < n) {
        m
    } else {
        n
    }
    if (m == 0 || n == 0) {
        return SVD(Matrix(m, k), Vector(k), Matrix(k, n))
    }
    let work = a.copy()
    let s = Array<Float64>(k, repeat: 0.0)
    let u = Matrix(m, k)
    let vt = Matrix(k, n)
    var info: Int32 = 0
    unsafe {
        let hw = acquireArrayRawData(work.data)
        let hs = acquireArrayRawData(s)
        let hu = acquireArrayRawData(u.data)
        let hvt = acquireArrayRawData(vt.data)
        info = dgesdd(Lapack.ROW_MAJOR, 83, Int32(m), Int32(n), hw.pointer, Int32(n), hs.pointer, hu.pointer, Int32(k),
            hvt.pointer, Int32(n))
        releaseArrayRawData(hvt)
        releaseArrayRawData(hu)
        releaseArrayRawData(hs)
        releaseArrayRawData(hw)
    }
    if (info > 0) {
        throw ConvergenceException("svd (dgesdd) did not converge")
    }
    checkArg(info, "dgesdd")
    SVD(u, Vector(s), vt)
}

func checkArg(info: Int32, routine: String): Unit {
    if (info < 0) {
        throw BlasArgumentException("${routine}: argument ${-info} had an illegal value")
    }
}
