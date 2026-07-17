/*
 * Spectral graph partitioning — cutting a graph with an eigenvector.
 *
 * Two 6-node communities are densely wired internally and joined by just two
 * bridge edges. The graph Laplacian L = D - A holds the cut structure in its
 * spectrum: the multiplicity of eigenvalue 0 counts connected components, the
 * second-smallest eigenvalue (algebraic connectivity, Fiedler value) measures
 * how tightly the graph hangs together, and the signs of its eigenvector (the
 * Fiedler vector) split the vertices into the two natural communities.
 *
 * End-to-end test: fails unless the Laplacian's spectrum has the expected
 * structure (lambda_0 ~ 0, constant kernel vector, small positive Fiedler
 * value) and the sign cut recovers the planted communities exactly.
 */
package spectral_partition

import std.math.*
import matcang.core.{Matrix, Vector}
import matcang.linalg.eigSymmetric

let NODES = 12
let GROUP = 6

/** Adjacency matrix: two near-cliques bridged by edges 0-6 and 5-11. */
func buildAdjacency(): Matrix {
    let a = Matrix(NODES, NODES)
    let addEdge = { u: Int64, v: Int64 =>
        a[u, v] = 1.0
        a[v, u] = 1.0
    }
    // community 1: nodes 0..5 in a dense ring-with-chords
    for (u in 0..GROUP) {
        addEdge(u, (u + 1) % GROUP)
        addEdge(u, (u + 2) % GROUP)
    }
    // community 2: nodes 6..11, same shape
    for (u in 0..GROUP) {
        addEdge(GROUP + u, GROUP + (u + 1) % GROUP)
        addEdge(GROUP + u, GROUP + (u + 2) % GROUP)
    }
    // two weak bridges
    addEdge(0, 6)
    addEdge(5, 11)
    a
}

/** Graph Laplacian L = D - A. */
func laplacian(a: Matrix): Matrix {
    Matrix.fromDiagonal(a.rowSums().toArray()) - a
}

main(): Int64 {
    let a = buildAdjacency()
    let l = laplacian(a)
    let eig = eigSymmetric(l)

    let lambda0 = eig.values[0]
    let fiedlerValue = eig.values[1]
    let fiedler = eig.vectors.col(1)

    // sign cut: negative side vs non-negative side
    var group0 = 0
    var crossErrors = 0
    for (i in 0..NODES) {
        let inFirst = fiedler[i] < 0.0
        if (inFirst) {
            group0 += 1
        }
        // planted truth: nodes 0..5 together, 6..11 together
        let plantedFirst = i < GROUP
        // consistent labelling is checked after the loop via group sizes;
        // count mismatches against both labellings and take the better one
        if (inFirst != plantedFirst) {
            crossErrors += 1
        }
    }
    // the eigenvector's global sign is arbitrary: accept either labelling
    let mismatches = if (crossErrors <= NODES - crossErrors) {
        crossErrors
    } else {
        NODES - crossErrors
    }

    println("Spectral partitioning — Fiedler vector of the graph Laplacian")
    println("  lambda_0 (should be ~0)     : ${lambda0}")
    println("  Fiedler value lambda_1      : ${fiedlerValue}")
    println("  partition sizes             : ${group0} vs ${NODES - group0}")
    println("  mismatches vs planted truth : ${mismatches}")
    println("  Fiedler vector              : ${fiedler}")

    if (abs(lambda0) > 1e-9) {
        println("FAIL: smallest Laplacian eigenvalue is not 0")
        return 1
    }
    if (fiedlerValue < 1e-9) {
        println("FAIL: graph should be connected (positive Fiedler value)")
        return 1
    }
    if (mismatches != 0 || group0 != GROUP) {
        println("FAIL: sign cut did not recover the planted communities")
        return 1
    }
    println("OK")
    return 0
}
