/*
 * Heat equation — Crank-Nicolson time stepping with a factor-once LU.
 *
 *     u_t = u_xx  on (0, 1),   u(0) = u(1) = 0,   u(x, 0) = sin(pi x)
 *
 * has the exact solution u(x, t) = exp(-pi^2 t) sin(pi x). Crank-Nicolson
 * discretises to (I + dt/2 K) u_{n+1} = (I - dt/2 K) u_n, a linear solve per
 * step with the SAME matrix every time — the textbook case for factorising
 * once and back-substituting many times:
 *
 *     factor once:  A = P L U                      (lu)
 *     each step:    w = P^T b;  L z = w;  U u' = z (two solveTriangular calls,
 *                                                   L has a unit diagonal)
 *
 * End-to-end test: fails unless the factor-reuse pipeline matches a direct
 * solve to machine precision, the marched solution matches the analytic one,
 * and the numerical decay rate reproduces exp(-pi^2 dt) per step.
 */
package heat_equation

import std.math.*
import matcang.core.{Matrix, Vector, Triangle, Diagonal}
import matcang.linalg.{lu, LU, solve, solveTriangular}

let PI: Float64 = 3.14159265358979323846
let INTERIOR = 63 // interior nodes (h = 1/64)
let DT = 0.0005
let STEPS = 200 // march to t = 0.1

/** Second-difference stiffness K (tridiagonal, scaled by 1/h^2). */
func buildStiffness(): Matrix {
    let h = 1.0 / Float64(INTERIOR + 1)
    let s = 1.0 / (h * h)
    Matrix.build(INTERIOR, INTERIOR) {
        i, j => if (i == j) {
            2.0 * s
        } else if (i == j + 1 || j == i + 1) {
            -s
        } else {
            0.0
        }
    }
}

/** One Crank-Nicolson step via the prefactored A = P L U. */
func stepWithFactors(f: LU, rhs: Vector): Vector {
    let w = f.p.t * rhs // permutation inverse = transpose
    let z = solveTriangular(f.l, w, uplo: Triangle.Lower, diag: Diagonal.UnitDiag)
    solveTriangular(f.u, z, uplo: Triangle.Upper)
}

main(): Int64 {
    let h = 1.0 / Float64(INTERIOR + 1)
    let k = buildStiffness()
    let a = Matrix.identity(INTERIOR) + k * (DT / 2.0) // implicit side
    let b = Matrix.identity(INTERIOR) - k * (DT / 2.0) // explicit side

    var u = Vector.build(INTERIOR) {i => sin(PI * Float64(i + 1) * h)}
    let factors = lu(a)

    // sanity: the triangular pipeline must equal a direct dense solve
    let probe = b * u
    let viaFactors = stepWithFactors(factors, probe)
    let viaSolve = solve(a, probe)
    let pipelineDiff = (viaFactors - viaSolve).norm()

    // march to t = STEPS * DT, tracking the amplitude decay per step
    var decayAccurate = true
    let expectedDecay = exp(-PI * PI * DT)
    for (_ in 0..STEPS) {
        let before = u.normInf()
        u = stepWithFactors(factors, b * u)
        let ratio = u.normInf() / before
        if (abs(ratio - expectedDecay) > 1e-5) {
            decayAccurate = false
        }
    }

    // compare with the analytic solution at t = STEPS * DT
    let t = Float64(STEPS) * DT
    let exact = Vector.build(INTERIOR) {i => exp(-PI * PI * t) * sin(PI * Float64(i + 1) * h)}
    let maxError = (u - exact).normInf()

    println("Heat equation — Crank-Nicolson, factor-once LU, ${STEPS} steps to t=${t}")
    println("  grid                 : ${INTERIOR} interior nodes (h = ${h})")
    println("  pipeline vs solve    : ${pipelineDiff}")
    println("  amplitude decay/step : ${expectedDecay} (theory), matched: ${decayAccurate}")
    println("  max |u - exact|      : ${maxError}")
    println("  final peak amplitude : ${u.normInf()} (exact ${exp(-PI * PI * t)})")

    if (pipelineDiff > 1e-10) {
        println("FAIL: LU triangular pipeline disagrees with direct solve")
        return 1
    }
    if (!decayAccurate) {
        println("FAIL: per-step decay rate off theory")
        return 1
    }
    if (maxError > 1e-4) {
        println("FAIL: solution drifted from the analytic answer")
        return 1
    }
    println("OK")
    return 0
}
