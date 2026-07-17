/*
 * Image compression with the singular value decomposition.
 *
 * A smooth 64x64 grayscale "image" (a couple of Gaussian blobs over a gentle
 * gradient) has rapidly decaying singular values, so a handful of rank-1 layers
 * reconstruct it almost exactly. We compute the SVD once and rebuild the image
 * from its k largest components, illustrating the Eckart-Young theorem: the
 * relative error of the best rank-k approximation is sqrt(1 - captured energy).
 *
 * End-to-end test: fails unless a low-rank approximation captures nearly all the
 * energy and its measured error matches the Eckart-Young prediction (a strong
 * check that the SVD factors are correct).
 */
package svd_compression

import std.math.*
import matcang.core.Matrix
import matcang.linalg.{svd, SVD}

let SIZE = 64

/** Synthesise a smooth, near-low-rank grayscale image. */
func makeImage(): Matrix {
    Matrix.build(SIZE, SIZE) { i, j =>
        let x = Float64(i)
        let y = Float64(j)
        let blob1 = exp(-((x - 20.0) * (x - 20.0) + (y - 22.0) * (y - 22.0)) / 220.0)
        let blob2 = exp(-((x - 44.0) * (x - 44.0) + (y - 40.0) * (y - 40.0)) / 320.0)
        let gradient = (x + y) / Float64(2 * SIZE)
        blob1 + 0.7 * blob2 + 0.3 * gradient
    }
}

/** Rebuild the best rank-k approximation from a precomputed SVD. */
func lowRankApprox(decomp: SVD, k: Int64): Matrix {
    let m = decomp.u.rows
    let n = decomp.vt.cols
    let uk = Matrix.build(m, k) {i, j => decomp.u[i, j]}
    let sk = Matrix.build(k, k) { i, j =>
        if (i == j) {
            decomp.s[i]
        } else {
            0.0
        }
    }
    let vtk = Matrix.build(k, n) {i, j => decomp.vt[i, j]}
    uk * sk * vtk
}

func capturedEnergy(decomp: SVD, k: Int64): Float64 {
    var top = 0.0
    var total = 0.0
    for (i in 0..decomp.s.size) {
        let e = decomp.s[i] * decomp.s[i]
        total += e
        if (i < k) {
            top += e
        }
    }
    top / total
}

main(): Int64 {
    let image = makeImage()
    let decomp = svd(image)
    let originalNorm = image.frobeniusNorm()

    println("SVD image compression — ${SIZE}x${SIZE} smooth image")
    println("  first 6 singular values: ")
    for (i in 0..6) {
        println("    sigma[${i}] = ${decomp.s[i]}")
    }
    println("  ${"rank"}   ${"energy"}      ${"rel.error"}   ${"predicted"}   ${"compression"}")

    var okRank8Energy = false
    var eckartYoungHolds = true
    for (k in [1, 2, 4, 8, 16]) {
        let approx = lowRankApprox(decomp, k)
        let relError = (image - approx).frobeniusNorm() / originalNorm
        let energy = capturedEnergy(decomp, k)
        let predicted = sqrt(1.0 - energy) // Eckart-Young
        let ratio = Float64(SIZE * SIZE) / Float64(k * (2 * SIZE + 1))
        println("  ${k}\t${energy}\t${relError}\t${predicted}\t${ratio}x")
        if (k == 8 && energy > 0.99) {
            okRank8Energy = true
        }
        if (abs(relError - predicted) > 1e-9) {
            eckartYoungHolds = false
        }
    }

    if (!okRank8Energy) {
        println("FAIL: rank-8 approximation did not capture enough energy")
        return 1
    }
    if (!eckartYoungHolds) {
        println("FAIL: measured error does not match the Eckart-Young prediction")
        return 1
    }
    println("OK")
    return 0
}
