/*
 * PageRank — the eigenvector that ranked the web.
 *
 * A tiny 8-page web is encoded as a link matrix; the Google matrix
 * G = d M + (1-d)/n E (damping d = 0.85) is its random-surfer transition
 * matrix. The PageRank vector is the stationary distribution: the dominant
 * eigenvector of G with eigenvalue 1. We find it by power iteration — repeated
 * matrix-vector products — and cross-check it against a direct linear solve of
 * (I - d M) r = (1-d)/n * 1.
 *
 * End-to-end test: fails unless the iteration converges to a true fixed point,
 * agrees with the direct solve, and ranks the intuitively-central hub first.
 */
package pagerank

import std.math.*
import matcang.core.{Matrix, Vector}
import matcang.linalg.solve

let DAMPING = 0.85

/**
 * Column-stochastic link matrix of the demo web. links[j] lists the pages that
 * page j links to; column j of M spreads j's vote equally among them.
 * Page 2 is the hub: almost everyone links to it.
 */
func buildLinkMatrix(): Matrix {
    let n = 8
    let links: Array<Array<Int64>> = [
        [1, 2], // 0 -> 1, 2
        [2], // 1 -> 2
        [0, 3], // 2 -> 0, 3   (the hub passes rank on)
        [2, 4], // 3 -> 2, 4
        [2, 5, 6], // 4 -> 2, 5, 6
        [2], // 5 -> 2
        [2, 7], // 6 -> 2, 7
        [2, 6] // 7 -> 2, 6
    ]
    let m = Matrix(n, n)
    for (j in 0..n) {
        let outDegree = Float64(links[j].size)
        for (target in links[j]) {
            m[target, j] = 1.0 / outDegree
        }
    }
    m
}

/** Power iteration on the Google matrix until the rank vector stabilises. */
func powerIterate(m: Matrix, maxIter: Int64, tol: Float64): (Vector, Int64) {
    let n = m.rows
    let teleport = (1.0 - DAMPING) / Float64(n)
    var r = Vector.filled(n, 1.0 / Float64(n))
    var iterations = 0
    while (iterations < maxIter) {
        // G r = d (M r) + (1-d)/n * sum(r)   (sum(r) stays 1)
        let next = m * r * DAMPING + teleport
        let delta = (next - r).norm1()
        r = next
        iterations += 1
        if (delta < tol) {
            break
        }
    }
    (r, iterations)
}

main(): Int64 {
    let m = buildLinkMatrix()
    let n = m.rows
    let (rank, iterations) = powerIterate(m, 200, 1e-12)

    // direct solution: (I - d M) r = (1-d)/n * ones
    let system = Matrix.identity(n) - m * DAMPING
    let rhs = Vector.filled(n, (1.0 - DAMPING) / Float64(n))
    let direct = solve(system, rhs)

    // fixed-point residual under the full Google matrix
    let teleport = (1.0 - DAMPING) / Float64(n)
    let residual = (m * rank * DAMPING + teleport - rank).norm()

    println("PageRank — random surfer on an 8-page web  (damping ${DAMPING})")
    println("  power iterations     : ${iterations}")
    println("  fixed-point residual : ${residual}")
    println("  sum of ranks         : ${rank.sum()}")
    println("  agrees with solve    : ${rank.approxEquals(direct, tol: 1e-9)}")
    for (i in 0..n) {
        println("    page ${i}: ${rank[i]}")
    }
    let top = rank.argAbsMax()
    println("  top page             : ${top}")

    if (residual > 1e-9) {
        println("FAIL: iteration did not reach a fixed point")
        return 1
    }
    if (!rank.approxEquals(direct, tol: 1e-9)) {
        println("FAIL: power iteration and direct solve disagree")
        return 1
    }
    if (abs(rank.sum() - 1.0) > 1e-9) {
        println("FAIL: ranks do not form a probability distribution")
        return 1
    }
    if (top != 2) {
        println("FAIL: expected the hub (page 2) to rank first")
        return 1
    }
    println("OK")
    return 0
}
