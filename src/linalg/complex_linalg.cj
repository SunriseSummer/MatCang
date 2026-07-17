/*
 * matcang.linalg - complex linear algebra over LAPACK's z-precision drivers.
 *
 * These overloads mirror the real API for ComplexMatrix / ComplexVector inputs:
 *   solve / solveMatrix (zgesv), inverse (zgetrf+zgetri), svd (zgesdd),
 * plus two eigen-solvers that the real surface cannot express:
 *   eig            general complex spectrum WITH right eigenvectors (zgeev),
 *   eigHermitian   real spectrum + orthonormal eigenvectors of a Hermitian
 *                  matrix (zheev).
 *
 * All matrices are row-major; the LAPACK_ROW_MAJOR layout flag lets LAPACKE do
 * any internal transposition. Inputs are never mutated - every driver works on
 * a copy. Buffers are the interleaved CxF64 arrays ComplexMatrix already holds,
 * so they cross the FFI boundary zero-copy.
 */
package matcang.linalg

import matcang.{zgesv, zgetrf, zgetri, zgeev, zheev, zgesdd, zpotrf, zgeqrf, zungqr, CxF64, Lapack}
import matcang.core.{Vector, Complex, ComplexMatrix, ComplexVector, NonSquareMatrixException, 
    SingularMatrixException, ConvergenceException, BlasArgumentException, DimensionMismatchException}

/** Eigenvalues and right eigenvectors of a general complex matrix. */
public struct ComplexEigen {
    /** Eigenvalues (in LAPACK's returned order). */
    public let values: ComplexVector
    /** Right eigenvectors as columns: `A * vectors[:,k] = values[k] * vectors[:,k]`. */
    public let vectors: ComplexMatrix

    public init(values: ComplexVector, vectors: ComplexMatrix) {
        this.values = values
        this.vectors = vectors
    }
}

/** Real eigenvalues (ascending) and orthonormal eigenvectors of a Hermitian matrix. */
public struct HermitianEigen {
    public let values: Vector
    public let vectors: ComplexMatrix

    public init(values: Vector, vectors: ComplexMatrix) {
        this.values = values
        this.vectors = vectors
    }
}

/** Complex singular value decomposition: `a = u * diag(s) * vh`. */
public struct ComplexSVD {
    public let u: ComplexMatrix
    public let s: Vector // real, descending
    public let vh: ComplexMatrix

    public init(u: ComplexMatrix, s: Vector, vh: ComplexMatrix) {
        this.u = u
        this.s = s
        this.vh = vh
    }
}

func requireSquareCx(a: ComplexMatrix): Unit {
    if (a.rows != a.cols) {
        throw NonSquareMatrixException("expected a square matrix, got ${a.rows}x${a.cols}")
    }
}

/** Solve `a x = b` for a single complex right-hand side (LAPACK zgesv). */
public func solve(a: ComplexMatrix, b: ComplexVector): ComplexVector {
    requireSquareCx(a)
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
        info = zgesv(Lapack.ROW_MAJOR, Int32(n), 1, ha.pointer, Int32(n), hp.pointer, hb.pointer, 1)
        releaseArrayRawData(hp)
        releaseArrayRawData(hb)
        releaseArrayRawData(ha)
    }
    checkInfo(info, "zgesv")
    x
}

/** Solve `a X = B` for a matrix of complex right-hand sides (LAPACK zgesv). */
public func solveMatrix(a: ComplexMatrix, b: ComplexMatrix): ComplexMatrix {
    requireSquareCx(a)
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
        info = zgesv(Lapack.ROW_MAJOR, Int32(n), Int32(nrhs), ha.pointer, Int32(n), hp.pointer, hb.pointer, Int32(nrhs))
        releaseArrayRawData(hp)
        releaseArrayRawData(hb)
        releaseArrayRawData(ha)
    }
    checkInfo(info, "zgesv")
    x
}

/** Complex matrix inverse via LU (LAPACK zgetrf + zgetri). */
public func inverse(a: ComplexMatrix): ComplexMatrix {
    requireSquareCx(a)
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
        info = zgetrf(Lapack.ROW_MAJOR, Int32(n), Int32(n), hi.pointer, Int32(n), hp.pointer)
        releaseArrayRawData(hp)
        releaseArrayRawData(hi)
    }
    checkInfo(info, "zgetrf")
    unsafe {
        let hi = acquireArrayRawData(inv.data)
        let hp = acquireArrayRawData(ipiv)
        info = zgetri(Lapack.ROW_MAJOR, Int32(n), hi.pointer, Int32(n), hp.pointer)
        releaseArrayRawData(hp)
        releaseArrayRawData(hi)
    }
    checkInfo(info, "zgetri")
    inv
}

/**
 * Eigen-decomposition of a general complex matrix (LAPACK zgeev): the complex
 * eigenvalues and the right eigenvectors as columns of `vectors`.
 */
public func eigen(a: ComplexMatrix): ComplexEigen {
    requireSquareCx(a)
    let n = a.rows
    if (n == 0) {
        return ComplexEigen(ComplexVector(0), ComplexMatrix(0, 0))
    }
    let work = a.copy()
    let w = Array<CxF64>(n, repeat: CxF64(0.0, 0.0))
    let vr = Array<CxF64>(n * n, repeat: CxF64(0.0, 0.0))
    let vl = Array<CxF64>(1, repeat: CxF64(0.0, 0.0)) // jobvl='N': unused, needs a valid ptr
    var info: Int32 = 0
    unsafe {
        let hw = acquireArrayRawData(work.data)
        let hval = acquireArrayRawData(w)
        let hvr = acquireArrayRawData(vr)
        let hvl = acquireArrayRawData(vl)
        info = zgeev(Lapack.ROW_MAJOR, 78, 86, Int32(n), hw.pointer, Int32(n), hval.pointer, hvl.pointer, 1, hvr.pointer,
            Int32(n))
        releaseArrayRawData(hvl)
        releaseArrayRawData(hvr)
        releaseArrayRawData(hval)
        releaseArrayRawData(hw)
    }
    if (info > 0) {
        throw ConvergenceException("eigen (zgeev) failed to converge")
    }
    if (info < 0) {
        throw BlasArgumentException("zgeev: argument ${-info} had an illegal value")
    }
    ComplexEigen(ComplexVector(w), ComplexMatrix(n, n, vr))
}

/**
 * Eigen-decomposition of a Hermitian matrix (LAPACK zheev): real eigenvalues in
 * ascending order and the orthonormal eigenvectors as columns of `vectors`.
 * Only the upper triangle of `a` is read.
 */
public func eigHermitian(a: ComplexMatrix): HermitianEigen {
    requireSquareCx(a)
    let n = a.rows
    let vecs = a.copy()
    let w = Array<Float64>(n, repeat: 0.0)
    if (n == 0) {
        return HermitianEigen(Vector(0), vecs)
    }
    var info: Int32 = 0
    unsafe {
        let hv = acquireArrayRawData(vecs.data)
        let hw = acquireArrayRawData(w)
        info = zheev(Lapack.ROW_MAJOR, 86, 85, Int32(n), hv.pointer, Int32(n), hw.pointer)
        releaseArrayRawData(hw)
        releaseArrayRawData(hv)
    }
    if (info > 0) {
        throw ConvergenceException("eigHermitian (zheev) failed to converge")
    }
    if (info < 0) {
        throw BlasArgumentException("zheev: argument ${-info} had an illegal value")
    }
    HermitianEigen(Vector(w), vecs)
}

/** Real eigenvalues of a Hermitian matrix (ascending), without eigenvectors. */
public func eigenvaluesHermitian(a: ComplexMatrix): Vector {
    requireSquareCx(a)
    let n = a.rows
    let work = a.copy()
    let w = Array<Float64>(n, repeat: 0.0)
    if (n == 0) {
        return Vector(0)
    }
    var info: Int32 = 0
    unsafe {
        let hv = acquireArrayRawData(work.data)
        let hw = acquireArrayRawData(w)
        info = zheev(Lapack.ROW_MAJOR, 78, 85, Int32(n), hv.pointer, Int32(n), hw.pointer)
        releaseArrayRawData(hw)
        releaseArrayRawData(hv)
    }
    if (info != 0) {
        throw ConvergenceException("eigenvaluesHermitian (zheev) failed, info=${info}")
    }
    Vector(w)
}

/**
 * Reduced singular value decomposition of a complex m-by-n matrix (LAPACK
 * zgesdd): `u` (m-by-k), real singular values `s` (length k, descending) and
 * `vh` (k-by-n) with `k = min(m, n)` and `a = u * diag(s) * vh`.
 */
public func svd(a: ComplexMatrix): ComplexSVD {
    let m = a.rows
    let n = a.cols
    let k = if (m < n) {
        m
    } else {
        n
    }
    if (m == 0 || n == 0) {
        return ComplexSVD(ComplexMatrix(m, k), Vector(k), ComplexMatrix(k, n))
    }
    let work = a.copy()
    let s = Array<Float64>(k, repeat: 0.0)
    let u = ComplexMatrix(m, k)
    let vh = ComplexMatrix(k, n)
    var info: Int32 = 0
    unsafe {
        let hw = acquireArrayRawData(work.data)
        let hs = acquireArrayRawData(s)
        let hu = acquireArrayRawData(u.data)
        let hvh = acquireArrayRawData(vh.data)
        info = zgesdd(Lapack.ROW_MAJOR, 83, Int32(m), Int32(n), hw.pointer, Int32(n), hs.pointer, hu.pointer, Int32(k),
            hvh.pointer, Int32(n))
        releaseArrayRawData(hvh)
        releaseArrayRawData(hu)
        releaseArrayRawData(hs)
        releaseArrayRawData(hw)
    }
    if (info > 0) {
        throw ConvergenceException("svd (zgesdd) did not converge")
    }
    if (info < 0) {
        throw BlasArgumentException("zgesdd: argument ${-info} had an illegal value")
    }
    ComplexSVD(u, Vector(s), vh)
}

/** Result of a reduced complex QR factorisation: `a = q * r`. */
public struct ComplexQR {
    /** m x k matrix with orthonormal columns under the Hermitian inner product. */
    public let q: ComplexMatrix
    /** k x n upper-triangular factor. */
    public let r: ComplexMatrix

    public init(q: ComplexMatrix, r: ComplexMatrix) {
        this.q = q
        this.r = r
    }
}

/** Complex determinant via LU factorisation (LAPACK zgetrf), pivot-signed. */
public func determinant(a: ComplexMatrix): Complex {
    requireSquareCx(a)
    let n = a.rows
    if (n == 0) {
        return Complex(1.0, 0.0)
    }
    let lu = a.copy()
    let ipiv = Array<Int32>(n, repeat: 0)
    var info: Int32 = 0
    unsafe {
        let hl = acquireArrayRawData(lu.data)
        let hp = acquireArrayRawData(ipiv)
        info = zgetrf(Lapack.ROW_MAJOR, Int32(n), Int32(n), hl.pointer, Int32(n), hp.pointer)
        releaseArrayRawData(hp)
        releaseArrayRawData(hl)
    }
    if (info > 0) {
        return Complex(0.0, 0.0) // singular: U has a zero on the diagonal
    }
    if (info < 0) {
        throw BlasArgumentException("zgetrf: argument ${-info} had an illegal value")
    }
    var det = Complex(1.0, 0.0)
    for (i in 0..n) {
        let c = lu.data[i * n + i]
        det = det * Complex(c.re, c.im)
    }
    // account for row interchanges (ipiv is 1-based)
    for (i in 0..n) {
        if (Int64(ipiv[i]) != i + 1) {
            det = -det
        }
    }
    det
}

/**
 * Cholesky factorisation of a Hermitian positive-definite matrix (LAPACK
 * zpotrf). Returns the lower-triangular `l` with `a = l * l^H` (or upper `u`
 * with `a = u^H * u` when `lower = false`). The diagonal of the factor is real.
 */
public func cholesky(a: ComplexMatrix, lower!: Bool = true): ComplexMatrix {
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
        info = zpotrf(Lapack.ROW_MAJOR, uplo, Int32(n), hc.pointer, Int32(n))
        releaseArrayRawData(hc)
    }
    if (info > 0) {
        throw SingularMatrixException("cholesky: matrix is not positive definite (leading minor ${info})")
    }
    if (info < 0) {
        throw BlasArgumentException("zpotrf: argument ${-info} had an illegal value")
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
                c.data[i * n + j] = CxF64(0.0, 0.0)
            }
        }
    }
    c
}

/**
 * Reduced (economy) complex QR factorisation of an m-by-n matrix: an m-by-k
 * `q` with orthonormal columns (`q^H q = I`) and a k-by-n upper-triangular `r`,
 * where `k = min(m, n)` and `a = q * r`. Dispatches to LAPACK zgeqrf + zungqr.
 */
public func qr(a: ComplexMatrix): ComplexQR {
    let m = a.rows
    let ncol = a.cols
    let k = if (m < ncol) {
        m
    } else {
        ncol
    }
    let work = a.copy()
    if (m == 0 || ncol == 0) {
        return ComplexQR(ComplexMatrix(m, k), ComplexMatrix(k, ncol))
    }
    let tau = Array<CxF64>(k, repeat: CxF64(0.0, 0.0))
    var info: Int32 = 0
    unsafe {
        let hw = acquireArrayRawData(work.data)
        let ht = acquireArrayRawData(tau)
        info = zgeqrf(Lapack.ROW_MAJOR, Int32(m), Int32(ncol), hw.pointer, Int32(ncol), ht.pointer)
        releaseArrayRawData(ht)
        releaseArrayRawData(hw)
    }
    checkArg(info, "zgeqrf")
    // R = upper triangle (k x ncol)
    let r = ComplexMatrix(k, ncol)
    for (i in 0..k) {
        for (j in i..ncol) {
            r.data[i * ncol + j] = work.data[i * ncol + j]
        }
    }
    // form Q (m x k) in place, then extract respecting the physical stride ncol
    unsafe {
        let hw = acquireArrayRawData(work.data)
        let ht = acquireArrayRawData(tau)
        info = zungqr(Lapack.ROW_MAJOR, Int32(m), Int32(k), Int32(k), hw.pointer, Int32(ncol), ht.pointer)
        releaseArrayRawData(ht)
        releaseArrayRawData(hw)
    }
    checkArg(info, "zungqr")
    let q = ComplexMatrix(m, k)
    for (i in 0..m) {
        for (j in 0..k) {
            q.data[i * k + j] = work.data[i * ncol + j]
        }
    }
    ComplexQR(q, r)
}
