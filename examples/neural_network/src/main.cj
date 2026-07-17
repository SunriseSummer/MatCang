/*
 * A two-layer perceptron trained by back-propagation to learn XOR — the
 * textbook problem a single linear layer cannot solve.
 *
 * Every layer is a matrix multiply, and every gradient is a matrix multiply
 * with a transposed operand, so the whole training loop is a showcase of
 * matcang's BLAS-backed algebra. Samples are batched as columns, so one gemm
 * processes the entire dataset per layer.
 *
 * End-to-end test: fails unless the trained network classifies all four XOR
 * inputs correctly with low loss.
 */
package neural_network

import std.math.*
import matcang.core.Matrix

func sigmoid(m: Matrix): Matrix {
    m.map {x => 1.0 / (1.0 + exp(-x))}
}

/** Elementwise sigmoid'(z) given a = sigmoid(z): a * (1 - a). */
func sigmoidPrimeFromActivation(a: Matrix): Matrix {
    a.map {v => v * (1.0 - v)}
}

/** Add a column-vector bias to every column of z (broadcast over samples). */
func addBias(z: Matrix, b: Matrix): Matrix {
    z.addColVector(b.col(0))
}

/** Row-wise sums as a column vector (gradient of a broadcast bias). */
func rowSums(m: Matrix): Matrix {
    m.rowSums().toColumnMatrix()
}

main(): Int64 {
    // XOR dataset: four samples as columns of a 2 x 4 input matrix.
    let x = Matrix.fromRows([[0.0, 0.0, 1.0, 1.0], [0.0, 1.0, 0.0, 1.0]])
    let y = Matrix.fromRows([[0.0, 1.0, 1.0, 0.0]])

    let hidden = 8
    var w1 = Matrix.randomNormal(hidden, 2, std: 1.0, seed: 1)
    var b1 = Matrix(hidden, 1)
    var w2 = Matrix.randomNormal(1, hidden, std: 1.0, seed: 2)
    var b2 = Matrix(1, 1)

    let lr = 0.5
    let epochs = 5000
    let samples = Float64(x.cols)
    var loss = 0.0

    for (epoch in 0..epochs) {
        // ---- forward ----
        let a1 = sigmoid(addBias(w1 * x, b1))
        let a2 = sigmoid(addBias(w2 * a1, b2))

        // ---- loss (mean squared error) ----
        let diff = a2 - y
        loss = diff.map {v => v * v}.sum() / samples

        // ---- backward ----
        let dz2 = diff.hadamard(sigmoidPrimeFromActivation(a2))
        let dw2 = dz2 * a1.t
        let db2 = rowSums(dz2)
        let dz1 = (w2.t * dz2).hadamard(sigmoidPrimeFromActivation(a1))
        let dw1 = dz1 * x.t
        let db1 = rowSums(dz1)

        // ---- gradient descent update ----
        w2 = w2 - dw2 * lr
        b2 = b2 - db2 * lr
        w1 = w1 - dw1 * lr
        b1 = b1 - db1 * lr

        if (epoch % 1000 == 0) {
            println("epoch ${epoch}: loss = ${loss}")
        }
    }

    // ---- evaluate ----
    let a1 = sigmoid(addBias(w1 * x, b1))
    let prediction = sigmoid(addBias(w2 * a1, b2))
    println("final loss     : ${loss}")
    println("predictions    : ${prediction}")
    println("targets        : ${y}")

    var correct = 0
    for (j in 0..x.cols) {
        let rounded = if (prediction[0, j] >= 0.5) {
            1.0
        } else {
            0.0
        }
        if (abs(rounded - y[0, j]) < 0.5) {
            correct += 1
        }
    }
    println("correct        : ${correct} / ${x.cols}")

    if (correct != 4 || loss > 0.01) {
        println("FAIL: network did not learn XOR")
        return 1
    }
    println("OK")
    return 0
}
