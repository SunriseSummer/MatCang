/*
 * GPS trilateration — where am I? Nonlinear least squares tells you.
 *
 * Four "satellites" at known positions measure their distance to an unknown
 * receiver (with noise). Each measurement gives one nonlinear equation
 * ||s_i - x|| = d_i; finding x is a nonlinear least-squares problem solved by
 * Gauss-Newton: linearise around the current guess, solve the small linear
 * least-squares system for the correction, repeat.
 *
 *     residual r_i = ||s_i - x|| - d_i
 *     Jacobian J_i = (x - s_i)^T / ||s_i - x||     (a row per satellite)
 *     step:      solve  min || J dx + r ||   ->  x <- x + dx
 *
 * This is exactly how GPS receivers, surveying and sensor networks localise —
 * and a compact showcase of lstsq inside an iterative nonlinear solver.
 *
 * End-to-end test: fails unless Gauss-Newton converges quadratically-fast from
 * a far-off guess to the true position within measurement-noise accuracy.
 */
package gps_locate

import std.math.*
import std.random.Random
import matcang.core.{Matrix, Vector}
import matcang.linalg.lstsq

let SATELLITES: Array<Array<Float64>> = [
    [0.0, 0.0, 20.0],
    [15.0, 0.0, 18.0],
    [0.0, 15.0, 17.0],
    [12.0, 12.0, 22.0]
]
let TRUE_POSITION: Array<Float64> = [3.5, 7.2, 0.8]
let NOISE = 0.001 // one metre-ish on a kilometre-ish scale

func distance(a: Array<Float64>, b: Vector): Float64 {
    var s = 0.0
    for (k in 0..3) {
        let d = a[k] - b[k]
        s += d * d
    }
    sqrt(s)
}

/** One Gauss-Newton step: returns (new position, residual norm before step). */
func gaussNewtonStep(x: Vector, measured: Vector): (Vector, Float64) {
    let m = SATELLITES.size
    let jacobian = Matrix(m, 3)
    let residual = Vector(m)
    for (i in 0..m) {
        let range = distance(SATELLITES[i], x)
        residual[i] = range - measured[i]
        for (k in 0..3) {
            jacobian[i, k] = (x[k] - SATELLITES[i][k]) / range
        }
    }
    // correction dx minimises || J dx + r ||  ->  lstsq(J, -r)
    let dx = lstsq(jacobian, -residual)
    (x + dx, residual.norm())
}

main(): Int64 {
    // simulate noisy range measurements from the true position
    let rng = Random(5)
    let truth = Vector(TRUE_POSITION)
    let measured = Vector.build(SATELLITES.size) {
        i => distance(SATELLITES[i], truth) + rng.nextGaussianFloat64(mean: 0.0, sigma: NOISE)
    }

    var x = Vector([10.0, -5.0, 10.0]) // deliberately far-off initial guess
    println("GPS trilateration — Gauss-Newton on 4 pseudo-ranges")
    println("  iter   ||residual||        position")
    var residuals = Array<Float64>(6, repeat: 0.0)
    for (iter in 0..6) {
        let (next, rnorm) = gaussNewtonStep(x, measured)
        residuals[iter] = rnorm
        x = next
        println("  ${iter}\t${rnorm}\t${x}")
    }

    let positionError = (x - truth).norm()
    println("  true position : ${truth}")
    println("  estimate      : ${x}")
    println("  position error: ${positionError}")

    // fast (superlinear) convergence: residual collapses within a few steps
    if (residuals[3] > 1e-2 * residuals[0]) {
        println("FAIL: Gauss-Newton converged too slowly")
        return 1
    }
    if (positionError > 0.01) {
        println("FAIL: estimate not within measurement-noise accuracy")
        return 1
    }
    println("OK")
    return 0
}
