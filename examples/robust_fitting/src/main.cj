/*
 * Robust fitting — RANSAC line estimation, the natural home of the try* API.
 *
 * A dataset of points on the line y = 2x + 1 is contaminated with gross
 * outliers. Ordinary least squares is dragged far off; RANSAC repeatedly fits
 * a candidate line to a random minimal sample (two points), scores it by its
 * inlier count, and keeps the best consensus — then refines with least squares
 * on the inliers only.
 *
 * Degenerate minimal samples (the same point drawn twice, or two points with
 * equal x) make the 2x2 system singular. That is exactly what `trySolve` is
 * for: `None` means "skip this sample", no exception plumbing in the loop.
 *
 * End-to-end test: fails unless RANSAC recovers the true line to tight
 * tolerance while plain least squares (on the contaminated data) is visibly
 * wrong, and degenerate samples were actually encountered and skipped.
 */
package robust_fitting

import std.math.*
import std.random.Random
import matcang.core.{Matrix, Vector}
import matcang.linalg.{trySolve, lstsq}

let TRUE_SLOPE = 2.0
let TRUE_INTERCEPT = 1.0
let INLIERS = 40
let OUTLIERS = 15
let ITERATIONS = 300
let TOLERANCE = 0.15 // residual threshold for counting a point as an inlier

/** Inliers on the true line (small noise) plus scattered gross outliers. */
func makeData(rng: Random): (Vector, Vector) {
    let n = INLIERS + OUTLIERS
    let xs = Vector(n)
    let ys = Vector(n)
    for (i in 0..INLIERS) {
        let x = rng.nextFloat64() * 4.0 - 2.0
        xs[i] = x
        ys[i] = TRUE_SLOPE * x + TRUE_INTERCEPT + rng.nextGaussianFloat64(mean: 0.0, sigma: 0.03)
    }
    for (i in INLIERS..n) {
        xs[i] = rng.nextFloat64() * 4.0 - 2.0
        ys[i] = rng.nextFloat64() * 24.0 - 12.0 // junk
    }
    (xs, ys)
}

/** Count points whose vertical residual against (slope, intercept) is small. */
func countInliers(xs: Vector, ys: Vector, slope: Float64, intercept: Float64): Int64 {
    var count = 0
    for (i in 0..xs.size) {
        if (abs(ys[i] - (slope * xs[i] + intercept)) < TOLERANCE) {
            count += 1
        }
    }
    count
}

/** Least-squares line fit y = a + b x over the flagged points. */
func refit(xs: Vector, ys: Vector, keep: Array<Bool>): (Float64, Float64) {
    var m = 0
    for (flag in keep) {
        if (flag) {
            m += 1
        }
    }
    let design = Matrix(m, 2)
    let target = Vector(m)
    var k = 0
    for (i in 0..xs.size) {
        if (keep[i]) {
            design[k, 0] = 1.0
            design[k, 1] = xs[i]
            target[k] = ys[i]
            k += 1
        }
    }
    let coef = lstsq(design, target)
    (coef[1], coef[0]) // (slope, intercept)
}

main(): Int64 {
    let rng = Random(13)
    let (xs, ys) = makeData(rng)
    let n = xs.size

    // plain least squares on everything — corrupted by the outliers
    let all = Array<Bool>(n, repeat: true)
    let (naiveSlope, naiveIntercept) = refit(xs, ys, all)

    // RANSAC: minimal two-point samples via trySolve
    var bestSlope = 0.0
    var bestIntercept = 0.0
    var bestCount = -1
    var degenerateSkips = 0
    for (_ in 0..ITERATIONS) {
        let i = rng.nextInt64(n)
        let j = rng.nextInt64(n)
        // line through points i and j:  [1 x_i; 1 x_j] [c; s] = [y_i; y_j]
        let system = Matrix([[1.0, xs[i]], [1.0, xs[j]]])
        let rhs = Vector([ys[i], ys[j]])
        let candidate = trySolve(system, rhs)
        if (candidate.isNone()) {
            degenerateSkips += 1 // i == j or equal x: singular, just skip
            continue
        }
        let coef = candidate.getOrThrow()
        let count = countInliers(xs, ys, coef[1], coef[0])
        if (count > bestCount) {
            bestCount = count
            bestSlope = coef[1]
            bestIntercept = coef[0]
        }
    }

    // final refinement on the consensus set (immutable copies: closures may
    // only capture read-only bindings)
    let winSlope = bestSlope
    let winIntercept = bestIntercept
    let consensus = Array<Bool>(n, {
        i => abs(ys[i] - (winSlope * xs[i] + winIntercept)) < TOLERANCE
    })
    let (slope, intercept) = refit(xs, ys, consensus)

    let ransacError = abs(slope - TRUE_SLOPE) + abs(intercept - TRUE_INTERCEPT)
    let naiveError = abs(naiveSlope - TRUE_SLOPE) + abs(naiveIntercept - TRUE_INTERCEPT)

    println("Robust fitting — RANSAC vs plain least squares (${OUTLIERS} gross outliers)")
    println("  true line        : y = ${TRUE_SLOPE} x + ${TRUE_INTERCEPT}")
    println("  plain lstsq      : y = ${naiveSlope} x + ${naiveIntercept}  (err ${naiveError})")
    println("  RANSAC + refit   : y = ${slope} x + ${intercept}  (err ${ransacError})")
    println("  consensus size   : ${bestCount} / ${n}")
    println("  degenerate skips : ${degenerateSkips} (trySolve -> None)")

    if (ransacError > 0.05) {
        println("FAIL: RANSAC did not recover the true line")
        return 1
    }
    if (naiveError < ransacError * 5.0) {
        println("FAIL: expected plain least squares to be visibly corrupted")
        return 1
    }
    if (degenerateSkips == 0) {
        println("FAIL: expected some degenerate samples to exercise trySolve")
        return 1
    }
    if (bestCount < INLIERS - 5) {
        println("FAIL: consensus set too small")
        return 1
    }
    println("OK")
    return 0
}
