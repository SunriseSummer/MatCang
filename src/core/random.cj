/*
 * matcang.core - random matrix / vector factories.
 *
 * Seeding policy (important):
 *   - pass an explicit `seed` for a reproducible stream — the same seed always
 *     yields the same data, which is what tests and documentation rely on;
 *   - omit `seed` (the default) to draw from a process-wide shared generator
 *     that advances on every call, so two unseeded `random(...)` calls return
 *     *different* data (initialising two weight matrices, say, no longer
 *     produces accidentally identical values).
 *
 * The shared generator is entropy-seeded once per process. `std.random.Random`
 * is not thread-safe, so concurrent unseeded draws from multiple threads should
 * each pass their own `seed` (a per-thread reproducible stream) instead.
 */
package matcang.core

import std.random.Random

/** Process-wide generator backing unseeded `random(...)` draws. */
let sharedRandom = Random()

/** Pick the generator for a request: reproducible if seeded, shared if not. */
func rngFor(seed: ?UInt64): Random {
    match (seed) {
        case Some(s) => Random(s)
        case None => sharedRandom
    }
}

extend Matrix {
    /** Matrix with entries drawn uniformly from [0, 1). */
    public static func random(rows: Int64, cols: Int64, seed!: ?UInt64 = None): Matrix {
        let rng = rngFor(seed)
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
        seed!: ?UInt64 = None
    ): Matrix {
        let rng = rngFor(seed)
        let d = Array<Float64>(rows * cols, repeat: 0.0)
        for (i in 0..d.size) {
            d[i] = rng.nextGaussianFloat64(mean: mean, sigma: std)
        }
        Matrix(rows, cols, d)
    }
}

extend Vector {
    /** Vector with entries drawn uniformly from [0, 1). */
    public static func random(size: Int64, seed!: ?UInt64 = None): Vector {
        let rng = rngFor(seed)
        let d = Array<Float64>(size, repeat: 0.0)
        for (i in 0..size) {
            d[i] = rng.nextFloat64()
        }
        Vector(d)
    }

    /** Vector with entries drawn from a normal (Gaussian) distribution. */
    public static func randomNormal(
        size: Int64,
        mean!: Float64 = 0.0,
        std!: Float64 = 1.0,
        seed!: ?UInt64 = None
    ): Vector {
        let rng = rngFor(seed)
        let d = Array<Float64>(size, repeat: 0.0)
        for (i in 0..size) {
            d[i] = rng.nextGaussianFloat64(mean: mean, sigma: std)
        }
        Vector(d)
    }
}
