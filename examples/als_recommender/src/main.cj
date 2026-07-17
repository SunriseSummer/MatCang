/*
 * Recommender system — matrix factorisation by Alternating Least Squares (ALS).
 *
 * The Netflix-Prize workhorse, end to end: a synthetic population of users
 * rates a catalogue of items; most ratings are unobserved. We recover the
 * hidden structure by factorising the rating matrix R ~= U V^T with latent
 * factors, alternately re-solving every user row and item row as a small ridge
 * system, then predict the held-out test ratings.
 *
 * This is the "larger application" example: data synthesis, train/test
 * masking, an iterative optimiser built from many small SPD solves, RMSE
 * tracking and a baseline comparison — all on the matcang API.
 *
 * End-to-end test: fails unless training RMSE decreases monotonically, the
 * test RMSE beats the global-mean baseline by a wide margin, and prediction
 * recovers the planted structure.
 */
package als_recommender

import std.math.*
import std.random.Random
import matcang.core.Matrix
import matcang.linalg.solveSPDMatrix

let USERS = 60
let ITEMS = 45
let RANK = 4 // planted latent dimension
let FACTORS = 4 // model latent dimension
let LAMBDA = 0.1 // ridge regularisation
let SWEEPS = 12
let TRAIN_FRACTION = 0.8

/** Synthetic ground truth: low-rank preferences plus light noise. */
func makeRatings(rng: Random): Matrix {
    let uTrue = Matrix.randomNormal(USERS, RANK, std: 1.0, seed: 101)
    let vTrue = Matrix.randomNormal(ITEMS, RANK, std: 1.0, seed: 102)
    let clean = uTrue * vTrue.t
    clean.map {x => x + rng.nextGaussianFloat64(mean: 0.0, sigma: 0.05)}
}

/** Random observation mask: 1 = train, 0 = held-out test. */
func makeMask(rng: Random): Matrix {
    Matrix.build(USERS, ITEMS) {
        _, _ => if (rng.nextFloat64() < TRAIN_FRACTION) {
            1.0
        } else {
            0.0
        }
    }
}

/**
 * Re-solve every row of `target` given the other side `fixed`:
 * for user u,  (F_u^T F_u + lambda I) x = F_u^T r_u  over observed entries.
 * Each system is FACTORS x FACTORS and SPD, solved with dposv.
 */
func solveSide(ratings: Matrix, mask: Matrix, fixed: Matrix, rows: Int64): Matrix {
    let out = Matrix(rows, FACTORS)
    let ridge = Matrix.identity(FACTORS) * LAMBDA
    for (r in 0..rows) {
        // gather the observed entries of this row
        var observed = 0
        for (j in 0..fixed.rows) {
            if (mask[r, j] > 0.5) {
                observed += 1
            }
        }
        if (observed == 0) {
            continue // cold row: keep zeros
        }
        let f = Matrix(observed, FACTORS) // factor rows of the observed items
        let y = Matrix(observed, 1) // the observed ratings
        var k = 0
        for (j in 0..fixed.rows) {
            if (mask[r, j] > 0.5) {
                for (c in 0..FACTORS) {
                    f[k, c] = fixed[j, c]
                }
                y[k, 0] = ratings[r, j]
                k += 1
            }
        }
        // normal equations with ridge: SPD by construction
        let gram = f.t * f + ridge
        let rhs = f.t * y
        let x = solveSPDMatrix(gram, rhs)
        for (c in 0..FACTORS) {
            out[r, c] = x[c, 0]
        }
    }
    out
}

/** RMSE of `prediction` against `truth` over the entries where mask==value. */
func maskedRmse(prediction: Matrix, truth: Matrix, mask: Matrix, value: Float64): Float64 {
    var acc = 0.0
    var count = 0
    for (i in 0..truth.rows) {
        for (j in 0..truth.cols) {
            if (abs(mask[i, j] - value) < 0.5) {
                let d = prediction[i, j] - truth[i, j]
                acc += d * d
                count += 1
            }
        }
    }
    sqrt(acc / Float64(count))
}

/** Mean of the training entries — the "predict the average" baseline. */
func trainMean(ratings: Matrix, mask: Matrix): Float64 {
    var acc = 0.0
    var count = 0
    for (i in 0..ratings.rows) {
        for (j in 0..ratings.cols) {
            if (mask[i, j] > 0.5) {
                acc += ratings[i, j]
                count += 1
            }
        }
    }
    acc / Float64(count)
}

main(): Int64 {
    let rng = Random(7)
    let ratings = makeRatings(rng)
    let mask = makeMask(rng)

    var userF = Matrix.randomNormal(USERS, FACTORS, std: 0.3, seed: 201)
    var itemF = Matrix.randomNormal(ITEMS, FACTORS, std: 0.3, seed: 202)

    println("ALS recommender — ${USERS} users x ${ITEMS} items, rank-${FACTORS} model")
    println("  observed ratings : ~${Int64(TRAIN_FRACTION * 100.0)}% train, rest held out")
    println("  sweep   train-RMSE")

    var previous = 1.0e18
    var monotone = true
    for (sweep in 0..SWEEPS) {
        // alternate the two ridge sub-problems (each convex given the other side)
        userF = solveSide(ratings, mask, itemF, USERS)
        itemF = solveSide(ratings.t, mask.t, userF, ITEMS)
        let rmse = maskedRmse(userF * itemF.t, ratings, mask, 1.0)
        if (rmse > previous + 1e-12) {
            monotone = false
        }
        previous = rmse
        if (sweep % 3 == 0 || sweep == SWEEPS - 1) {
            println("  ${sweep}\t${rmse}")
        }
    }

    let prediction = userF * itemF.t
    let testRmse = maskedRmse(prediction, ratings, mask, 0.0)
    let mean = trainMean(ratings, mask)
    let baseline = maskedRmse(Matrix.filled(USERS, ITEMS, mean), ratings, mask, 0.0)

    println("  test RMSE        : ${testRmse}")
    println("  baseline (mean)  : ${baseline}")
    println("  improvement      : ${baseline / testRmse}x over baseline")

    if (!monotone) {
        println("FAIL: training RMSE did not decrease monotonically")
        return 1
    }
    if (testRmse > 0.15) {
        println("FAIL: held-out predictions too poor (structure not recovered)")
        return 1
    }
    if (baseline / testRmse < 5.0) {
        println("FAIL: expected a large win over the global-mean baseline")
        return 1
    }
    println("OK")
    return 0
}
