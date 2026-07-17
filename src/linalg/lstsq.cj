/*
 * matcang.linalg - least squares, pseudo-inverse and SVD-derived quantities.
 */
package matcang.linalg

import matcang.{dgelsd, Lapack}
import matcang.core.{Matrix, Vector, BlasArgumentException, ConvergenceException, DimensionMismatchException}

let EPS: Float64 = 2.2204460492503131e-16

/**
 * Minimum-norm least-squares solution of `a x ~= b` (minimising the residual
 * 2-norm), valid for over-, under- and rank-deficient systems. Dispatches to
 * the SVD-based LAPACK dgelsd.
 */
public func lstsq(a: Matrix, b: Vector): Vector {
    if (a.rows != b.size) {
        throw DimensionMismatchException("lstsq: matrix is ${a.rows}x${a.cols}, rhs length ${b.size}")
    }
    let n = a.cols
    let sol = lstsqCore(a, b.data, 1)
    // solution is the first n entries
    let out = Array<Float64>(n, repeat: 0.0)
    for (i in 0..n) {
        out[i] = sol[i]
    }
    Vector(out)
}

/** Shared dgelsd driver; returns the (max(m,n) x nrhs) work buffer. */
func lstsqCore(a: Matrix, rhs: Array<Float64>, nrhs: Int64): Array<Float64> {
    let m = a.rows
    let n = a.cols
    let maxmn = if (m > n) {
        m
    } else {
        n
    }
    let minmn = if (m < n) {
        m
    } else {
        n
    }
    let work = a.copy()
    let bwork = Array<Float64>(maxmn * nrhs, repeat: 0.0)
    // load rhs (m x nrhs, row-major) into the top of bwork (maxmn x nrhs)
    for (i in 0..m) {
        for (j in 0..nrhs) {
            bwork[i * nrhs + j] = rhs[i * nrhs + j]
        }
    }
    let s = Array<Float64>(minmn, repeat: 0.0)
    let rank = Array<Int32>(1, repeat: 0)
    var info: Int32 = 0
    unsafe {
        let hw = acquireArrayRawData(work.data)
        let hb = acquireArrayRawData(bwork)
        let hs = acquireArrayRawData(s)
        let hr = acquireArrayRawData(rank)
        info = dgelsd(Lapack.ROW_MAJOR, Int32(m), Int32(n), Int32(nrhs), hw.pointer, Int32(n), hb.pointer, Int32(nrhs),
            hs.pointer, -1.0, hr.pointer)
        releaseArrayRawData(hr)
        releaseArrayRawData(hs)
        releaseArrayRawData(hb)
        releaseArrayRawData(hw)
    }
    if (info > 0) {
        throw ConvergenceException("lstsq (dgelsd) failed to converge")
    }
    if (info < 0) {
        throw BlasArgumentException("dgelsd: argument ${-info} had an illegal value")
    }
    bwork
}

/** Moore-Penrose pseudo-inverse via SVD (n-by-m for an m-by-n input). */
public func pinv(a: Matrix): Matrix {
    let m = a.rows
    let n = a.cols
    let decomp = svd(a)
    let k = decomp.s.size
    let smax = if (k == 0) {
        0.0
    } else {
        decomp.s[0]
    }
    let tol = Float64(if (m > n) {
        m
    } else {
        n
    }) * EPS * smax
    let sinv = Array<Float64>(k, repeat: 0.0)
    for (i in 0..k) {
        if (decomp.s[i] > tol) {
            sinv[i] = 1.0 / decomp.s[i]
        }
    }
    // pinv[a][b] = sum_i sinv[i] * V[a][i] * U[b][i], with V = vt^T
    let result = Matrix(n, m)
    for (ra in 0..n) {
        for (cb in 0..m) {
            var acc = 0.0
            for (i in 0..k) {
                acc += sinv[i] * decomp.vt.data[i * n + ra] * decomp.u.data[cb * k + i]
            }
            result.data[ra * m + cb] = acc
        }
    }
    result
}

/** Numerical rank: number of singular values above a relative tolerance. */
public func matrixRank(a: Matrix, tol!: Float64 = -1.0): Int64 {
    let decomp = svd(a)
    let k = decomp.s.size
    if (k == 0) {
        return 0
    }
    let smax = decomp.s[0]
    let threshold = if (tol >= 0.0) {
        tol
    } else {
        Float64(if (a.rows > a.cols) {
            a.rows
        } else {
            a.cols
        }) * EPS * smax
    }
    var count = 0
    for (i in 0..k) {
        if (decomp.s[i] > threshold) {
            count += 1
        }
    }
    count
}

/** 2-norm condition number `s_max / s_min` (infinity if singular). */
public func cond(a: Matrix): Float64 {
    let decomp = svd(a)
    let k = decomp.s.size
    if (k == 0) {
        return 0.0
    }
    let smin = decomp.s[k - 1]
    if (smin <= 0.0) {
        return Float64.Inf
    }
    decomp.s[0] / smin
}
