/*
 * Markov chains — tomorrow's weather, the long run, and how fast we get there.
 *
 * A three-state weather model (sunny / cloudy / rainy) evolves by a column-
 * stochastic transition matrix P: tomorrow = P * today. Three classic
 * questions, three matcang one-liners:
 *
 *   1. The 7-day forecast?          matrixPower(p, 7) * today
 *   2. The climate (long run)?      the stationary distribution: solve
 *                                   (P - I) pi = 0 with a normalisation row —
 *                                   equivalently matrixPower(p, BIG) columns.
 *   3. How fast is it forgotten?    the spectral gap: |lambda_2| of P sets the
 *                                   geometric rate at which initial conditions
 *                                   fade — forecast error ~ |lambda_2|^t.
 *
 * End-to-end test: fails unless the power-iterated forecast converges to the
 * stationary distribution computed by direct solve, every P^k stays a valid
 * distribution, and the measured convergence rate matches |lambda_2| from the
 * eigenvalue spectrum.
 */
package markov_chain

import std.math.*
import matcang.core.{Matrix, Vector}
import matcang.linalg.{solve, eigenvalues, matrixPower}

/** Column-stochastic weather transitions: column j = "given state j today". */
func buildTransitions(): Matrix {
    Matrix([
        [0.70, 0.30, 0.20], // sunny  tomorrow, given sunny/cloudy/rainy today
        [0.20, 0.40, 0.30], // cloudy tomorrow
        [0.10, 0.30, 0.50] // rainy  tomorrow
    ])
}

/**
 * Stationary distribution via direct solve: replace the last balance equation
 * (they are linearly dependent) with the normalisation sum(pi) = 1.
 */
func stationary(p: Matrix): Vector {
    let n = p.rows
    let system = p - Matrix.identity(n)
    for (j in 0..n) {
        system[n - 1, j] = 1.0
    }
    let rhs = Vector(n)
    rhs[n - 1] = 1.0
    solve(system, rhs)
}

/** Largest sub-dominant eigenvalue modulus |lambda_2| (lambda_1 = 1). */
func spectralGapRate(p: Matrix): Float64 {
    var second = 0.0
    for (lambda in eigenvalues(p)) {
        let modulus = lambda.abs()
        if (modulus < 0.999999 && modulus > second) {
            second = modulus
        }
    }
    second
}

main(): Int64 {
    let p = buildTransitions()
    let today = Vector([1.0, 0.0, 0.0]) // certainly sunny today

    println("Markov weather — sunny / cloudy / rainy")
    println("  day    sunny    cloudy   rainy")
    var allValid = true
    for (day in [1, 3, 7, 30]) {
        let dist = matrixPower(p, day) * today
        if (abs(dist.sum() - 1.0) > 1e-12 || dist.min() < -1e-15) {
            allValid = false
        }
        println("  ${day}\t${dist[0]}\t${dist[1]}\t${dist[2]}")
    }

    let pi = stationary(p)
    let forecast30 = matrixPower(p, 30) * today
    println("  stationary (solve)   : ${pi}")
    println("  P^30 * today         : ${forecast30}")

    // measured forgetting rate vs the spectral prediction
    let rate = spectralGapRate(p)
    let err5 = (matrixPower(p, 5) * today - pi).norm1()
    let err10 = (matrixPower(p, 10) * today - pi).norm1()
    let measured = pow(err10 / err5, 1.0 / 5.0) // per-step decay over 5 steps
    println("  |lambda_2| (theory)  : ${rate}")
    println("  measured decay/step  : ${measured}")

    if (!allValid) {
        println("FAIL: some P^k * today was not a probability distribution")
        return 1
    }
    if (!forecast30.approxEquals(pi, tol: 1e-9)) {
        println("FAIL: power iteration did not reach the stationary distribution")
        return 1
    }
    if (abs(measured - rate) > 0.02) {
        println("FAIL: convergence rate does not match the spectral gap")
        return 1
    }
    println("OK")
    return 0
}
