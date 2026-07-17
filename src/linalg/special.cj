/*
 * matcang.linalg - specialised real solvers and functions that round out the
 * double-precision surface:
 *   eigSymmetricGeneralized   A v = lambda B v, B SPD          (dsygvd)
 *   solveTridiagonal          tridiagonal system               (dgtsv)
 *   eigSymmetricTridiagonal   symmetric tridiagonal spectrum   (dstev)
 *   schur                     real Schur decomposition         (dgees)
 *   expm                      matrix exponential (scaling & squaring + Pade)
 *
 * All are row-major and never mutate their inputs (they work on copies).
 */
package matcang.linalg

import matcang.{dsygvd, dgtsv, dstev, dgees, Lapack}
import matcang.core.{Matrix, Vector, NonSquareMatrixException, SingularMatrixException, ConvergenceException, 
    BlasArgumentException, DimensionMismatchException}
import std.math.*

/**
 * Generalised symmetric-definite eigenproblem `A v = lambda B v` with `A`
 * symmetric and `B` symmetric positive-definite (LAPACK dsygvd). Returns real
 * eigenvalues (ascending) and B-orthonormal eigenvectors as columns. This is
 * the vibration / structural-modes problem `K v = lambda M v`.
 */
public func eigSymmetricGeneralized(a: Matrix, b: Matrix): EigenSym {
    if (a.rows != a.cols) {
        throw NonSquareMatrixException("eigSymmetricGeneralized requires square A, got ${a.rows}x${a.cols}")
    }
    if (b.rows != b.cols || b.rows != a.rows) {
        throw DimensionMismatchException("eigSymmetricGeneralized: A is ${a.rows}x${a.cols}, B is ${b.rows}x${b.cols}")
    }
    let n = a.rows
    let av = a.copy()
    let bv = b.copy()
    let w = Array<Float64>(n, repeat: 0.0)
    if (n == 0) {
        return EigenSym(Vector(0), av)
    }
    var info: Int32 = 0
    unsafe {
        let ha = acquireArrayRawData(av.data)
        let hb = acquireArrayRawData(bv.data)
        let hw = acquireArrayRawData(w)
        // itype=1: A x = lambda B x; jobz='V'; uplo='U'
        info = dsygvd(Lapack.ROW_MAJOR, 1, 86, 85, Int32(n), ha.pointer, Int32(n), hb.pointer, Int32(n), hw.pointer)
        releaseArrayRawData(hw)
        releaseArrayRawData(hb)
        releaseArrayRawData(ha)
    }
    if (info < 0) {
        throw BlasArgumentException("dsygvd: argument ${-info} had an illegal value")
    }
    if (info > 0) {
        if (Int64(info) <= n) {
            throw ConvergenceException("eigSymmetricGeneralized (dsygvd) failed to converge")
        }
        throw SingularMatrixException("eigSymmetricGeneralized: B is not positive definite")
    }
    EigenSym(Vector(w), av)
}

/**
 * Solve a tridiagonal system `A x = b` given the sub-, main and super-diagonals
 * (`dl` length n-1, `d` length n, `du` length n-1) via LAPACK dgtsv. O(n) work -
 * the right tool for 1-D PDE and spline systems instead of a dense solve.
 */
public func solveTridiagonal(dl: Vector, d: Vector, du: Vector, b: Vector): Vector {
    let n = d.size
    if (n == 0) {
        return Vector(0)
    }
    if (dl.size != n - 1 || du.size != n - 1) {
        throw DimensionMismatchException(
            "solveTridiagonal: diagonals must be (${n - 1}, ${n}, ${n - 1}), got (${dl.size}, ${n}, ${du.size})")
    }
    if (b.size != n) {
        throw DimensionMismatchException("solveTridiagonal: rhs length ${b.size} != ${n}")
    }
    let dlc = dl.copy()
    let dc = d.copy()
    let duc = du.copy()
    let x = b.copy()
    var info: Int32 = 0
    unsafe {
        let hdl = acquireArrayRawData(dlc.data)
        let hd = acquireArrayRawData(dc.data)
        let hdu = acquireArrayRawData(duc.data)
        let hx = acquireArrayRawData(x.data)
        info = dgtsv(Lapack.ROW_MAJOR, Int32(n), 1, hdl.pointer, hd.pointer, hdu.pointer, hx.pointer, 1)
        releaseArrayRawData(hx)
        releaseArrayRawData(hdu)
        releaseArrayRawData(hd)
        releaseArrayRawData(hdl)
    }
    if (info > 0) {
        throw SingularMatrixException("solveTridiagonal: matrix is singular (zero pivot at ${info})")
    }
    if (info < 0) {
        throw BlasArgumentException("dgtsv: argument ${-info} had an illegal value")
    }
    x
}

/**
 * Eigenvalues (ascending) and eigenvectors of a symmetric tridiagonal matrix
 * given its main diagonal `d` (length n) and off-diagonal `e` (length n-1) via
 * LAPACK dstev.
 */
public func eigSymmetricTridiagonal(d: Vector, e: Vector): EigenSym {
    let n = d.size
    if (n == 0) {
        return EigenSym(Vector(0), Matrix(0, 0))
    }
    if (e.size != n - 1) {
        throw DimensionMismatchException("eigSymmetricTridiagonal: off-diagonal must be length ${n - 1}, got ${e.size}")
    }
    let dc = d.copy()
    let ec = Vector(n) // dstev reads n-1 but wants a length-n scratch tail
    for (i in 0..(n - 1)) {
        ec.data[i] = e.data[i]
    }
    let z = Matrix(n, n)
    var info: Int32 = 0
    unsafe {
        let hd = acquireArrayRawData(dc.data)
        let he = acquireArrayRawData(ec.data)
        let hz = acquireArrayRawData(z.data)
        info = dstev(Lapack.ROW_MAJOR, 86, Int32(n), hd.pointer, he.pointer, hz.pointer, Int32(n))
        releaseArrayRawData(hz)
        releaseArrayRawData(he)
        releaseArrayRawData(hd)
    }
    if (info > 0) {
        throw ConvergenceException("eigSymmetricTridiagonal (dstev) failed to converge")
    }
    if (info < 0) {
        throw BlasArgumentException("dstev: argument ${-info} had an illegal value")
    }
    EigenSym(dc, z)
}

/** Real Schur decomposition `a = z * t * z^T`: `z` orthogonal, `t` quasi-triangular. */
public struct Schur {
    /** Orthogonal Schur-vector matrix. */
    public let z: Matrix
    /** Quasi-upper-triangular Schur form (1x1 and 2x2 blocks on the diagonal). */
    public let t: Matrix

    public init(z: Matrix, t: Matrix) {
        this.z = z
        this.t = t
    }
}

/**
 * Real Schur decomposition of a general square matrix (LAPACK dgees):
 * `a = z * t * z^T` with `z` orthogonal and `t` block-upper-triangular. The
 * eigenvalues sit on `t`'s (quasi-)diagonal. Eigenvalues are not reordered.
 */
public func schur(a: Matrix): Schur {
    if (a.rows != a.cols) {
        throw NonSquareMatrixException("schur requires a square matrix, got ${a.rows}x${a.cols}")
    }
    let n = a.rows
    if (n == 0) {
        return Schur(Matrix(0, 0), Matrix(0, 0))
    }
    let t = a.copy()
    let z = Matrix(n, n)
    let wr = Array<Float64>(n, repeat: 0.0)
    let wi = Array<Float64>(n, repeat: 0.0)
    let sdim = Array<Int32>(1, repeat: 0)
    var info: Int32 = 0
    unsafe {
        let ht = acquireArrayRawData(t.data)
        let hz = acquireArrayRawData(z.data)
        let hwr = acquireArrayRawData(wr)
        let hwi = acquireArrayRawData(wi)
        let hs = acquireArrayRawData(sdim)
        // jobvs='V' (compute Schur vectors), sort='N' (no ordering), select=null
        let nullSelect = CPointer<Unit>()
        info = dgees(Lapack.ROW_MAJOR, 86, 78, nullSelect, Int32(n), ht.pointer, Int32(n), hs.pointer, hwr.pointer,
            hwi.pointer, hz.pointer, Int32(n))
        releaseArrayRawData(hs)
        releaseArrayRawData(hwi)
        releaseArrayRawData(hwr)
        releaseArrayRawData(hz)
        releaseArrayRawData(ht)
    }
    if (info > 0) {
        throw ConvergenceException("schur (dgees) failed to converge")
    }
    if (info < 0) {
        throw BlasArgumentException("dgees: argument ${-info} had an illegal value")
    }
    Schur(z, t)
}

/**
 * Matrix exponential `e^A` via scaling-and-squaring with a diagonal (6,6) Pade
 * approximant - the standard dense algorithm (no new LAPACK kernel; built on
 * the matrix product and `solve`). Exact for `A = 0` (returns I) and reproduces
 * `diag(e^a_i)` for diagonal inputs.
 */
public func expm(a: Matrix): Matrix {
    if (a.rows != a.cols) {
        throw NonSquareMatrixException("expm requires a square matrix, got ${a.rows}x${a.cols}")
    }
    let n = a.rows
    if (n == 0) {
        return Matrix(0, 0)
    }
    // scale so that ||A/2^s||_inf <= 1/2. s is capped at 64: beyond that the
    // entries of e^A overflow Float64 anyway, and the cap keeps the squaring
    // count bounded (and avoids any 1<<s style integer overflow).
    let nrm = infNorm(a)
    var s = 0
    if (nrm > 0.5) {
        s = Int64(ceil(log2(nrm))) + 1
        if (s < 0) {
            s = 0
        }
        if (s > 64) {
            s = 64
        }
    }
    let scaled = a * pow(0.5, Float64(s))

    // (6,6) Pade: N = sum c_k A^k, D = sum (-1)^k c_k A^k, expm ~ D^{-1} N
    let c = padeCoeffs6()
    var n_mat = Matrix.identity(n) * c[0]
    var d_mat = Matrix.identity(n) * c[0]
    var apow = Matrix.identity(n)
    for (k in 1..7) {
        apow = apow * scaled
        n_mat = n_mat + apow * c[k]
        let sign = if (k % 2 == 0) {
            1.0
        } else {
            -1.0
        }
        d_mat = d_mat + apow * (sign * c[k])
    }
    var r = solveMatrix(d_mat, n_mat)

    // square s times
    for (_ in 0..s) {
        r = r * r
    }
    r
}

func padeCoeffs6(): Array<Float64> {
    // c_k = c_{k-1} * (q-k+1) / (k*(2q-k+1)) with q=6, c_0 = 1
    let c = Array<Float64>(7, repeat: 0.0)
    c[0] = 1.0
    let q = 6.0
    for (k in 1..7) {
        c[k] = c[k - 1] * (q - Float64(k) + 1.0) / (Float64(k) * (2.0 * q - Float64(k) + 1.0))
    }
    c
}

/** Infinity norm (max absolute row sum) of a matrix. */
func infNorm(a: Matrix): Float64 {
    var mx = 0.0
    for (i in 0..a.rows) {
        var s = 0.0
        for (j in 0..a.cols) {
            s += abs(a.data[i * a.cols + j])
        }
        if (s > mx) {
            mx = s
        }
    }
    mx
}
