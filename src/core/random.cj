/*
 * matcang.core - random matrix / vector factories.
 *
 * A fixed default seed keeps results reproducible (important for tests and
 * documentation); pass an explicit `seed` for a different stream.
 */
package matcang.core

import std.random.Random

extend Matrix {
    /** Matrix with entries drawn uniformly from [0, 1). */
    public static func random(rows: Int64, cols: Int64, seed!: UInt64 = 42): Matrix {
        let rng = Random(seed)
        let d = Array<Float64>(rows * cols, repeat: 0.0)
        for (i in 0..d.size) {
            d[i] = rng.nextFloat64()
        }
        Matrix(rows, cols, d)
    }

    /** Matrix with entries drawn from a normal (Gaussian) distribution. */
    public static func randomNormal(
        rows: Int64,
        cols: Int64,
        mean!: Float64 = 0.0,
        std!: Float64 = 1.0,
        seed!: UInt64 = 42
    ): Matrix {
        let rng = Random(seed)
        let d = Array<Float64>(rows * cols, repeat: 0.0)
        for (i in 0..d.size) {
            d[i] = rng.nextGaussianFloat64(mean: mean, sigma: std)
        }
        Matrix(rows, cols, d)
    }
}

extend Vector {
    /** Vector with entries drawn uniformly from [0, 1). */
    public static func random(size: Int64, seed!: UInt64 = 42): Vector {
        let rng = Random(seed)
        let d = Array<Float64>(size, repeat: 0.0)
        for (i in 0..size) {
            d[i] = rng.nextFloat64()
        }
        Vector(d)
    }
}
