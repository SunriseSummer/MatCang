/*
 * matcang.linalg - additional direct solvers and factorisations:
 * pivoted LU exposure, SPD (Cholesky-based) solve, triangular solve, and
 * integer matrix powers.
 */
package matcang.linalg

import matcang.{dgetrf, dposv, dtrtrs, Lapack}
import matcang.core.{Matrix, Vector, Transpose, Triangle, Diagonal, NonSquareMatrixException, SingularMatrixException, 
    BlasArgumentException, DimensionMismatchException}

/** Result of a pivoted LU factorisation: `a = p * l * u`. */
public struct LU {
    /** Row-permutation matrix (orthogonal: `p.t` is its inverse). */
    public let p: Matrix
    /** Unit-lower-triangular (trapezoidal for rectangular input). */
    public let l: Matrix
    /** Upper-triangular (trapezoidal for rectangular input). */
    public let u: Matrix

    public init(p: Matrix, l: Matrix, u: Matrix) {
        this.p = p
        this.l = l
        this.u = u
    }
}

/**
 * Pivoted LU factorisation of an m-by-n matrix: `a = p * l * u` with `p` an
 * m-by-m permutation, `l` m-by-k unit-lower and `u` k-by-n upper (k = min(m,n)).
 * Dispatches to LAPACK dgetrf. Unlike `solve`/`determinant`, this exposes the
 * factors themselves. Singular inputs are allowed (u simply has zeros on its
 * diagonal).
 */
public func lu(a: Matrix): LU {
    let m = a.rows
    let n = a.cols
    let k = if (m < n) {
        m
    } else {
        n
    }
    let work = a.copy()
    let ipiv = Array<Int32>(k, repeat: 0)
    if (m > 0 && n > 0) {
        var info: Int32 = 0
        unsafe {
            let hw = acquireArrayRawData(work.data)
            let hp = acquireArrayRawData(ipiv)
            info = dgetrf(Lapack.ROW_MAJOR, Int32(m), Int32(n), hw.pointer, Int32(n), hp.pointer)
            releaseArrayRawData(hp)
            releaseArrayRawData(hw)
        }
        if (info < 0) {
            throw BlasArgumentException("dgetrf: argument ${-info} had an illegal value")
        }
        // info > 0 (exact singularity) is fine for a factorisation
    }
    // unpack L (m x k, unit diagonal) and U (k x n) from the packed factor
    let l = Matrix(m, k)
    let u = Matrix(k, n)
    for (i in 0..m) {
        for (j in 0..k) {
            if (j < i) {
                l.data[i * k + j] = work.data[i * n + j]
            } else if (j == i) {
                l.data[i * k + j] = 1.0
            }
        }
    }
    for (i in 0..k) {
        for (j in i..n) {
            u.data[i * n + j] = work.data[i * n + j]
        }
    }
    // rebuild the permutation: applying dgetrf's row swaps (ipiv is 1-based) to
    // the identity gives S with S a = l u, so a = S^T l u and p = S^T.
    let perm = Array<Int64>(m, {i => i})
    for (i in 0..k) {
        let other = Int64(ipiv[i]) - 1
        let tmp = perm[i]
        perm[i] = perm[other]
        perm[other] = tmp
    }
    let p = Matrix(m, m)
    for (i in 0..m) {
        // row i of S is e_{perm[i]}; p = S^T puts that 1 at (perm[i], i)
        p.data[perm[i] * m + i] = 1.0
    }
    LU(p, l, u)
}

/**
 * Solve `a x = b` for a symmetric positive-definite `a` via Cholesky (LAPACK
 * dposv) - roughly twice as fast as the general LU path and numerically ideal
 * for normal equations, covariance systems and FEM stiffness matrices. Only the
 * lower triangle of `a` is read.
 */
public func solveSPD(a: Matrix, b: Vector): Vector {
    let x = solveSPDMatrix(a, b.toColumnMatrix())
    x.col(0)
}

/** Multi-right-hand-side variant of `solveSPD` (columns of `b`). */
public func solveSPDMatrix(a: Matrix, b: Matrix): Matrix {
    if (a.rows != a.cols) {
        throw NonSquareMatrixException("solveSPD requires a square matrix, got ${a.rows}x${a.cols}")
    }
    if (a.rows != b.rows) {
        throw DimensionMismatchException("solveSPD: ${a.rows}x${a.cols} vs rhs ${b.rows}x${b.cols}")
    }
    let n = a.rows
    let nrhs = b.cols
    let factor = a.copy()
    let x = b.copy()
    if (n == 0 || nrhs == 0) {
        return x
    }
    var info: Int32 = 0
    unsafe {
        let hf = acquireArrayRawData(factor.data)
        let hx = acquireArrayRawData(x.data)
        info = dposv(Lapack.ROW_MAJOR, 76, Int32(n), Int32(nrhs), hf.pointer, Int32(n), hx.pointer, Int32(nrhs))
        releaseArrayRawData(hx)
        releaseArrayRawData(hf)
    }
    if (info > 0) {
        throw SingularMatrixException("solveSPD: matrix is not positive definite (leading minor ${info})")
    }
    if (info < 0) {
        throw BlasArgumentException("dposv: argument ${-info} had an illegal value")
    }
    x
}

/**
 * Solve the triangular system `op(a) x = b` (LAPACK dtrtrs), where `a` is
 * upper- or lower-triangular per `uplo` and `op` follows `trans`. The
 * back-substitution workhorse for reusing qr/cholesky/lu factors.
 */
public func solveTriangular(
    a: Matrix,
    b: Vector,
    uplo!: Triangle = Triangle.Lower,
    trans!: Transpose = Transpose.NoTrans,
    diag!: Diagonal = Diagonal.NonUnit
): Vector {
    if (a.rows != a.cols) {
        throw NonSquareMatrixException("solveTriangular requires a square matrix, got ${a.rows}x${a.cols}")
    }
    if (a.rows != b.size) {
        throw DimensionMismatchException("solveTriangular: matrix is ${a.rows}x${a.cols}, rhs length ${b.size}")
    }
    let n = a.rows
    let x = b.copy()
    if (n == 0) {
        return x
    }
    var info: Int32 = 0
    unsafe {
        let ha = acquireArrayRawData(a.data)
        let hx = acquireArrayRawData(x.data)
        info = dtrtrs(Lapack.ROW_MAJOR, uplo.toChar(), trans.toChar(), diag.toChar(), Int32(n), 1, ha.pointer, Int32(n),
            hx.pointer, 1)
        releaseArrayRawData(hx)
        releaseArrayRawData(ha)
    }
    if (info > 0) {
        throw SingularMatrixException("solveTriangular: diagonal element ${info} is zero")
    }
    if (info < 0) {
        throw BlasArgumentException("dtrtrs: argument ${-info} had an illegal value")
    }
    x
}

/**
 * Integer matrix power `a^k` by repeated squaring (dgemm-backed products).
 * `k = 0` yields the identity; negative `k` raises the inverse.
 */
public func matrixPower(a: Matrix, k: Int64): Matrix {
    if (a.rows != a.cols) {
        throw NonSquareMatrixException("matrixPower requires a square matrix, got ${a.rows}x${a.cols}")
    }
    if (k < 0) {
        return matrixPower(inverse(a), -k)
    }
    var result = Matrix.identity(a.rows)
    var base = a.copy()
    var e = k
    while (e > 0) {
        if (e % 2 == 1) {
            result = result * base
        }
        base = base * base
        e /= 2
    }
    result
}
