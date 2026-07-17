/*
 * matcang.linalg - eigenvalue problems.
 *
 * `eigSymmetric` covers the symmetric/Hermitian case (real spectrum, orthonormal
 * eigenvectors) and is the workhorse for PCA, spectral clustering and physics.
 * `eigenvalues` handles the general non-symmetric case (complex spectrum).
 */
package matcang.linalg

import matcang.{dsyev, dgeev, Lapack}
import matcang.core.{Matrix, Vector, Complex, NonSquareMatrixException, ConvergenceException, BlasArgumentException}

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
