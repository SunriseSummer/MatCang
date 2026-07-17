/*
 * matcang.linalg - eigenvalue problems.
 *
 * `eigSymmetric` covers the symmetric/Hermitian case (real spectrum, orthonormal
 * eigenvectors) and is the workhorse for PCA, spectral clustering and physics.
 * `eigenvalues` handles the general non-symmetric case (complex spectrum).
 */
package matcang.linalg

import matcang.{dsyev, dgeev, CxF64, Lapack}
import matcang.core.{Matrix, Vector, Complex, ComplexVector, ComplexMatrix, NonSquareMatrixException, 
    ConvergenceException, BlasArgumentException}

/** Eigenvalues (ascending) and eigenvectors of a symmetric matrix. */
public struct EigenSym {
    public let values: Vector
    public let vectors: Matrix

    public init(values: Vector, vectors: Matrix) {
        this.values = values
        this.vectors = vectors
    }
}

/**
 * Eigen-decomposition of a symmetric matrix: real eigenvalues in ascending
 * order and the corresponding orthonormal eigenvectors as the columns of
 * `vectors`. Only the upper triangle of `a` is read. Dispatches to LAPACK dsyev.
 */
public func eigSymmetric(a: Matrix): EigenSym {
    if (a.rows != a.cols) {
        throw NonSquareMatrixException("eigSymmetric requires a square matrix, got ${a.rows}x${a.cols}")
    }
    let n = a.rows
    let vecs = a.copy()
    let w = Array<Float64>(n, repeat: 0.0)
    if (n == 0) {
        return EigenSym(Vector(0), vecs)
    }
    var info: Int32 = 0
    unsafe {
        let hv = acquireArrayRawData(vecs.data)
        let hw = acquireArrayRawData(w)
        info = dsyev(Lapack.ROW_MAJOR, 86, 85, Int32(n), hv.pointer, Int32(n), hw.pointer)
        releaseArrayRawData(hw)
        releaseArrayRawData(hv)
    }
    if (info > 0) {
        throw ConvergenceException("eigSymmetric (dsyev) failed to converge")
    }
    if (info < 0) {
        throw BlasArgumentException("dsyev: argument ${-info} had an illegal value")
    }
    EigenSym(Vector(w), vecs)
}

/** Eigenvalues of a symmetric matrix (ascending), without eigenvectors. */
public func eigenvaluesSymmetric(a: Matrix): Vector {
    if (a.rows != a.cols) {
        throw NonSquareMatrixException("eigenvaluesSymmetric requires a square matrix")
    }
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
        info = dsyev(Lapack.ROW_MAJOR, 78, 85, Int32(n), hv.pointer, Int32(n), hw.pointer)
        releaseArrayRawData(hw)
        releaseArrayRawData(hv)
    }
    if (info != 0) {
        throw ConvergenceException("eigenvaluesSymmetric (dsyev) failed, info=${info}")
    }
    Vector(w)
}

/**
 * Eigenvalues of a general (non-symmetric) real matrix, returned as complex
 * numbers. Dispatches to LAPACK dgeev (eigenvectors are not computed).
 */
public func eigenvalues(a: Matrix): Array<Complex> {
    if (a.rows != a.cols) {
        throw NonSquareMatrixException("eigenvalues requires a square matrix, got ${a.rows}x${a.cols}")
    }
    let n = a.rows
    if (n == 0) {
        return Array<Complex>()
    }
    let work = a.copy()
    let wr = Array<Float64>(n, repeat: 0.0)
    let wi = Array<Float64>(n, repeat: 0.0)
    let dummy = Array<Float64>(1, repeat: 0.0)
    var info: Int32 = 0
    unsafe {
        let hw = acquireArrayRawData(work.data)
        let hwr = acquireArrayRawData(wr)
        let hwi = acquireArrayRawData(wi)
        let hd = acquireArrayRawData(dummy)
        info = dgeev(Lapack.ROW_MAJOR, 78, 78, Int32(n), hw.pointer, Int32(n), hwr.pointer, hwi.pointer, hd.pointer, 1,
            hd.pointer, 1)
        releaseArrayRawData(hd)
        releaseArrayRawData(hwi)
        releaseArrayRawData(hwr)
        releaseArrayRawData(hw)
    }
    if (info > 0) {
        throw ConvergenceException("eigenvalues (dgeev) failed to converge")
    }
    if (info < 0) {
        throw BlasArgumentException("dgeev: argument ${-info} had an illegal value")
    }
    let result = Array<Complex>(n, {i => Complex(wr[i], wi[i])})
    result
}

/**
 * Full eigen-decomposition of a general (non-symmetric) real matrix (LAPACK
 * dgeev): the complex eigenvalues and their right eigenvectors as the columns
 * of a `ComplexMatrix`, satisfying `A v_k = lambda_k v_k`. Real matrices can
 * have genuinely complex eigenpairs, so both are returned in complex form -
 * this is what `eigenvalues` (values only) could not express. For symmetric
 * inputs prefer `eigSymmetric` (real spectrum, orthonormal vectors).
 */
public func eigen(a: Matrix): ComplexEigen {
    if (a.rows != a.cols) {
        throw NonSquareMatrixException("eigen requires a square matrix, got ${a.rows}x${a.cols}")
    }
    let n = a.rows
    if (n == 0) {
        return ComplexEigen(ComplexVector(0), ComplexMatrix(0, 0))
    }
    let work = a.copy()
    let wr = Array<Float64>(n, repeat: 0.0)
    let wi = Array<Float64>(n, repeat: 0.0)
    let vr = Array<Float64>(n * n, repeat: 0.0)
    let dummy = Array<Float64>(1, repeat: 0.0)
    var info: Int32 = 0
    unsafe {
        let hw = acquireArrayRawData(work.data)
        let hwr = acquireArrayRawData(wr)
        let hwi = acquireArrayRawData(wi)
        let hvr = acquireArrayRawData(vr)
        let hd = acquireArrayRawData(dummy)
        info = dgeev(Lapack.ROW_MAJOR, 78, 86, Int32(n), hw.pointer, Int32(n), hwr.pointer, hwi.pointer, hd.pointer, 1,
            hvr.pointer, Int32(n))
        releaseArrayRawData(hd)
        releaseArrayRawData(hvr)
        releaseArrayRawData(hwi)
        releaseArrayRawData(hwr)
        releaseArrayRawData(hw)
    }
    if (info > 0) {
        throw ConvergenceException("eigen (dgeev) failed to converge")
    }
    if (info < 0) {
        throw BlasArgumentException("dgeev: argument ${-info} had an illegal value")
    }
    // Unpack dgeev's packed real eigenvectors into complex columns. Real
    // eigenvalues (wi = 0) give a real column; a complex-conjugate pair (k, k+1)
    // is stored as v_k = VR[:,k] + i VR[:,k+1], v_{k+1} = conj(v_k).
    let valData = Array<CxF64>(n, {i => CxF64(wr[i], wi[i])})
    let vecData = Array<CxF64>(n * n, repeat: CxF64(0.0, 0.0))
    var k = 0
    while (k < n) {
        // dgeev stores conjugate pairs in adjacent columns; a lone complex
        // eigenvalue in the last column cannot occur, but guard anyway.
        if (wi[k] == 0.0 || k + 1 >= n) {
            for (i in 0..n) {
                vecData[i * n + k] = CxF64(vr[i * n + k], 0.0)
            }
            k += 1
        } else {
            for (i in 0..n) {
                let re = vr[i * n + k]
                let im = vr[i * n + k + 1]
                vecData[i * n + k] = CxF64(re, im)
                vecData[i * n + k + 1] = CxF64(re, -im)
            }
            k += 2
        }
    }
    ComplexEigen(ComplexVector(valData), ComplexMatrix(n, n, vecData))
}
