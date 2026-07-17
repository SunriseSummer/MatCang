/*
 * Kalman filter — tracking a constant-velocity object from noisy position
 * measurements.
 *
 * This is a compact, self-contained demonstration of matcang's matrix algebra:
 * the classic predict/update recursion is expressed directly with matrix
 * multiply, transpose, addition and inversion. The example doubles as an
 * end-to-end test: it fails (non-zero exit) unless the filtered track is
 * markedly closer to the ground truth than the raw measurements.
 *
 * State x = [position, velocity]^T, evolving as p_{k+1} = p_k + v_k dt.
 */
package kalman_filter

import std.math.*
import std.random.Random
import matcang.core.Matrix
import matcang.linalg.inverse

/** One predict + update step of the Kalman recursion. */
func kalmanStep(
    x: Matrix,
    p: Matrix,
    z: Matrix,
    f: Matrix,
    h: Matrix,
    q: Matrix,
    r: Matrix
): (Matrix, Matrix) {
    // ---- predict ----
    let xPred = f * x
    let pPred = f * p * f.t + q
    // ---- update ----
    let innovation = z - h * xPred
    let s = h * pPred * h.t + r
    let gain = pPred * h.t * inverse(s)
    let xNext = xPred + gain * innovation
    let identity = Matrix.identity(x.rows)
    let pNext = (identity - gain * h) * pPred
    (xNext, pNext)
}

func rmse(estimate: Array<Float64>, truth: Array<Float64>): Float64 {
    var acc = 0.0
    for (i in 0..estimate.size) {
        let d = estimate[i] - truth[i]
        acc += d * d
    }
    sqrt(acc / Float64(estimate.size))
}

main(): Int64 {
    let steps = 100
    let dt = 1.0
    let trueVelocity = 1.0
    let measurementNoise = 8.0 // standard deviation of position measurements

    // model matrices
    let f = Matrix.fromRows([[1.0, dt], [0.0, 1.0]])
    let h = Matrix.fromRows([[1.0, 0.0]])
    let q = Matrix.fromRows([[0.001, 0.0], [0.0, 0.001]])
    let r = Matrix.fromRows([[measurementNoise * measurementNoise]])

    // initial estimate: unknown, large uncertainty
    var x = Matrix.fromRows([[0.0], [0.0]])
    var p = Matrix.fromRows([[500.0, 0.0], [0.0, 500.0]])

    let rng = Random(7)
    let truth = Array<Float64>(steps, repeat: 0.0)
    let measured = Array<Float64>(steps, repeat: 0.0)
    let filtered = Array<Float64>(steps, repeat: 0.0)

    for (k in 0..steps) {
        let truePos = trueVelocity * Float64(k)
        let noisy = truePos + rng.nextGaussianFloat64(mean: 0.0, sigma: measurementNoise)
        let z = Matrix.fromRows([[noisy]])
        let (xNext, pNext) = kalmanStep(x, p, z, f, h, q, r)
        x = xNext
        p = pNext
        truth[k] = truePos
        measured[k] = noisy
        filtered[k] = x[0, 0]
    }

    let measuredError = rmse(measured, truth)
    let filteredError = rmse(filtered, truth)

    println("Kalman filter — constant-velocity tracking")
    println("  steps                : ${steps}")
    println("  measurement RMSE     : ${measuredError}")
    println("  filtered   RMSE      : ${filteredError}")
    println("  final velocity est.  : ${x[1, 0]} (true ${trueVelocity})")
    println("  error reduction      : ${(1.0 - filteredError / measuredError) * 100.0}%")

    // end-to-end assertions
    if (filteredError >= measuredError) {
        println("FAIL: filtering did not reduce the error")
        return 1
    }
    if (abs(x[1, 0] - trueVelocity) > 0.2) {
        println("FAIL: velocity estimate did not converge")
        return 1
    }
    println("OK")
    return 0
}
