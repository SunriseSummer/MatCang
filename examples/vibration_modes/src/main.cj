/*
 * Natural frequencies of a mass-spring chain — a generalised eigenproblem.
 *
 * N masses in a line, each tied to its neighbours (and the two end walls) by
 * identical springs, obey  M x'' = -K x.  Normal modes x = v e^{i w t} turn
 * that into the generalised symmetric-definite eigenproblem
 *     K v = w^2 M v
 * with K the (tridiagonal) stiffness matrix and M the (diagonal) mass matrix.
 * matcang solves it directly with `eigSymmetricGeneralized`.
 *
 * For equal masses m and equal springs k the frequencies are known in closed
 * form:  w_j^2 = (4k/m) sin^2( j pi / (2(N+1)) ),  j = 1..N.  The example uses
 * that to check the computed spectrum, and verifies K v = w^2 M v for every
 * mode plus M-orthogonality of the mode shapes.
 */
package vibration_modes

import std.math.*
import matcang.core.{Matrix, Vector}
import matcang.linalg.eigSymmetricGeneralized

main(): Int64 {
    let n = 6
    let k = 4.0 // spring constant
    let m = 2.0 // mass

    // stiffness matrix (fixed-fixed chain): tridiagonal [-k, 2k, -k]
    let stiffness = Matrix.build(n, n) {
        i, j => if (i == j) {
            2.0 * k
        } else if (abs(i - j) == 1) {
            -k
        } else {
            0.0
        }
    }
    // mass matrix: diagonal
    let mass = Matrix.build(n, n) {
        i, j => if (i == j) {
            m
        } else {
            0.0
        }
    }

    let modes = eigSymmetricGeneralized(stiffness, mass)
    let omegaSq = modes.values

    // analytic frequencies
    let pi = 3.141592653589793
    let analytic = Vector.build(n) {
        j =>
            let s = sin(Float64(j + 1) * pi / (2.0 * Float64(n + 1)))
            (4.0 * k / m) * s * s
    }

    println("Mass-spring chain normal modes (N = ${n}, k = ${k}, m = ${m})")
    for (j in 0..n) {
        println("  mode ${j}: w^2 = ${omegaSq[j]}   (analytic ${analytic.data[j]})")
    }

    // (1) computed spectrum matches the closed form
    if (!omegaSq.approxEquals(analytic, tol: 1e-9)) {
        println("FAIL: frequencies disagree with the analytic formula")
        return 1
    }
    // (2) every mode satisfies K v = w^2 M v
    for (j in 0..n) {
        let v = modes.vectors.col(j)
        let lhs = stiffness * v
        let rhs = (mass * v) * omegaSq[j]
        if (!lhs.approxEquals(rhs, tol: 1e-8)) {
            println("FAIL: mode ${j} does not satisfy the eigen-equation")
            return 1
        }
    }
    // (3) distinct modes are M-orthogonal: v_i^T M v_j = 0 for i != j
    for (i in 0..n) {
        for (j in (i + 1)..n) {
            let vi = modes.vectors.col(i)
            let vj = modes.vectors.col(j)
            let mvj = mass * vj
            if (abs(vi.dot(mvj)) > 1e-8) {
                println("FAIL: modes ${i} and ${j} are not M-orthogonal")
                return 1
            }
        }
    }
    println("OK")
    return 0
}
