/*
 * Pattern recognition — PCA followed by k-means clustering.
 *
 * Three Gaussian blobs live in 4-D space. We (1) reduce to their two dominant
 * directions with Principal Component Analysis — centre the data, form the
 * covariance matrix, and take its leading eigenvectors via matcang's symmetric
 * eigensolver — and (2) cluster the projection with k-means. Because the blobs
 * are well separated, the recovered clusters should match the true classes.
 *
 * End-to-end test: fails unless PCA concentrates the variance in two components
 * and the clustering purity exceeds 90%.
 */
package pattern_recognition

import std.random.Random
import matcang.core.{Matrix, Vector}
import matcang.linalg.eigSymmetric

let CLASSES = 3
let PER_CLASS = 40

/** Build a labelled 4-D dataset of three Gaussian blobs. */
func makeData(): (Matrix, Array<Int64>) {
    let centers = Matrix([
            [3.0, 3.0, 0.0, 0.0],
            [-3.0, 3.0, 0.0, 0.0],
            [0.0, -3.0, 3.0, 0.0]
    ])
    let n = CLASSES * PER_CLASS
    let data = Matrix(n, 4)
    let labels = Array<Int64>(n, repeat: 0)
    let rng = Random(11)
    var row = 0
    for (c in 0..CLASSES) {
        for (_ in 0..PER_CLASS) {
            for (d in 0..4) {
                data[row, d] = centers[c, d] + rng.nextGaussianFloat64(mean: 0.0, sigma: 0.6)
            }
            labels[row] = c
            row += 1
        }
    }
    (data, labels)
}

/** Subtract the column means; returns the centred copy. */
func centerColumns(x: Matrix): Matrix {
    x.addRowVector(-x.colMeans())
}

/** Project onto the two leading principal components; returns (scores, ev). */
func pca2(x: Matrix): (Matrix, Vector) {
    let centered = centerColumns(x)
    let n = Float64(x.rows)
    // covariance = Xc^T Xc / (n-1)
    let cov = (centered.t * centered) * (1.0 / (n - 1.0))
    let eig = eigSymmetric(cov)
    // eigenvalues ascending, so the top-2 directions are the last two columns
    let dim = cov.rows
    let components = Matrix(dim, 2)
    for (i in 0..dim) {
        components[i, 0] = eig.vectors[i, dim - 1]
        components[i, 1] = eig.vectors[i, dim - 2]
    }
    (centered * components, eig.values)
}

func distanceSquared(a: Vector, b: Vector): Float64 {
    var s = 0.0
    for (i in 0..a.size) {
        let d = a[i] - b[i]
        s += d * d
    }
    s
}

/** Lloyd's k-means; returns the cluster assignment for every point. */
func kmeans(points: Matrix, k: Int64, iterations: Int64): Array<Int64> {
    let n = points.rows
    let dim = points.cols
    var centroids = Array<Vector>(k, {i => points.row(i * (n / k))})
    let assignment = Array<Int64>(n, repeat: 0)

    for (_ in 0..iterations) {
        // assign
        for (i in 0..n) {
            let p = points.row(i)
            var best = 0
            var bestDist = distanceSquared(p, centroids[0])
            for (c in 1..k) {
                let d = distanceSquared(p, centroids[c])
                if (d < bestDist) {
                    bestDist = d
                    best = c
                }
            }
            assignment[i] = best
        }
        // update
        let sums = Array<Vector>(k, {_ => Vector(dim)})
        let counts = Array<Int64>(k, repeat: 0)
        for (i in 0..n) {
            let c = assignment[i]
            sums[c] = sums[c] + points.row(i)
            counts[c] += 1
        }
        for (c in 0..k) {
            if (counts[c] > 0) {
                centroids[c] = sums[c] * (1.0 / Float64(counts[c]))
            }
        }
    }
    assignment
}

/** Clustering purity: fraction of points whose cluster's majority label they share. */
func purity(assignment: Array<Int64>, labels: Array<Int64>, k: Int64): Float64 {
    var correct = 0
    for (c in 0..k) {
        let counts = Array<Int64>(CLASSES, repeat: 0)
        for (i in 0..assignment.size) {
            if (assignment[i] == c) {
                counts[labels[i]] += 1
            }
        }
        var majority = 0
        for (t in 0..CLASSES) {
            if (counts[t] > majority) {
                majority = counts[t]
            }
        }
        correct += majority
    }
    Float64(correct) / Float64(assignment.size)
}

main(): Int64 {
    let (data, labels) = makeData()
    let (scores, eigenvalues) = pca2(data)

    // variance explained by the top two components
    var total = 0.0
    for (v in eigenvalues.data) {
        total += v
    }
    let dim = eigenvalues.size
    let top2 = eigenvalues[dim - 1] + eigenvalues[dim - 2]
    let explained = top2 / total

    let assignment = kmeans(scores, CLASSES, 25)
    let score = purity(assignment, labels, CLASSES)

    println("Pattern recognition — PCA + k-means")
    println("  samples             : ${data.rows} in ${data.cols}-D")
    println("  eigenvalues (asc)   : ${eigenvalues}")
    println("  variance explained  : ${explained * 100.0}% by 2 components")
    println("  clustering purity   : ${score * 100.0}%")

    if (explained < 0.8) {
        println("FAIL: PCA did not concentrate the variance")
        return 1
    }
    if (score < 0.9) {
        println("FAIL: clustering purity too low")
        return 1
    }
    println("OK")
    return 0
}
