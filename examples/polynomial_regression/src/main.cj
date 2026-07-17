/*
 * Polynomial regression and the price of ill-conditioning.
 *
 * We fit polynomials of rising degree to noisy samples of Runge's function
 * 1 / (1 + 25 x^2) on [-1, 1] via the Vandermonde design matrix and SVD-based
 * least squares. Two classic lessons appear in the numbers:
 *
 *   1. The fit improves with degree — the residual falls monotonically.
 *   2. The Vandermonde matrix's condition number explodes exponentially with
 *      degree, which is why serious fitting uses orthogonal bases or QR/SVD
 *      solvers (as matcang's lstsq does) rather than the normal equations.
 *
 * End-to-end test: fails unless the residual decreases with degree, the
 * degree-10 fit is close, and the condition number grows by orders of
 * magnitude.
 */
package polynomial_regression

import std.math.*
import matcang.core.{Matrix, Vector}
import matcang.linalg.{lstsq, cond}

func runge(x: Float64): Float64 {
    1.0 / (1.0 + 25.0 * x * x)
}

/** Vandermonde design matrix: row i is [1, x_i, x_i^2, ..., x_i^degree]. */
func vandermonde(xs: Vector, degree: Int64): Matrix {
    Matrix.build(xs.size, degree + 1) {
        i, j => pow(xs[i], Float64(j))
    }
}

/** Root-mean-square residual of the fitted polynomial on the samples. */
func fitAndMeasure(xs: Vector, ys: Vector, degree: Int64): (Float64, Float64) {
    let v = vandermonde(xs, degree)
    let coefficients = lstsq(v, ys)
    let residual = (v * coefficients - ys).norm() / sqrt(Float64(xs.size))
    (residual, cond(v))
}

main(): Int64 {
    let samples = 41
    let xs = Vector.linspace(-1.0, 1.0, samples)
    let ys = xs.map(runge)

    println("Polynomial regression — Runge's function, Vandermonde + SVD lstsq")
    println("  degree   RMS residual      cond(V)")

    let degrees: Array<Int64> = [2, 4, 6, 8, 10]
    let residuals = Array<Float64>(degrees.size, repeat: 0.0)
    let conditions = Array<Float64>(degrees.size, repeat: 0.0)
    for (k in 0..degrees.size) {
        let (r, c) = fitAndMeasure(xs, ys, degrees[k])
        residuals[k] = r
        conditions[k] = c
        println("    ${degrees[k]}\t ${r}\t ${c}")
    }

    // 1) residual falls monotonically with degree
    var monotone = true
    for (k in 1..degrees.size) {
        if (residuals[k] > residuals[k - 1] + 1e-12) {
            monotone = false
        }
    }
    // 2) conditioning deteriorates by orders of magnitude
    let condGrowth = conditions[degrees.size - 1] / conditions[0]

    println("  residual monotone decreasing : ${monotone}")
    println("  cond growth (deg 2 -> 10)    : ${condGrowth}x")

    if (!monotone) {
        println("FAIL: residual did not decrease with degree")
        return 1
    }
    // Runge's function resists global polynomials (that is the lesson); the
    // degree-10 fit should still cut the degree-2 residual several-fold.
    if (residuals[degrees.size - 1] > 0.05 || residuals[degrees.size - 1] > residuals[0] / 3.0) {
        println("FAIL: degree-10 fit did not improve enough")
        return 1
    }
    if (condGrowth < 100.0) {
        println("FAIL: expected the Vandermonde conditioning to blow up")
        return 1
    }
    println("OK")
    return 0
}
