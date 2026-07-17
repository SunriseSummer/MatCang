/*
 * Smoke tests for the core Matrix/Vector types and their BLAS-backed ops.
 */
package matcang.core

import std.math.*

@Test
class CoreSmokeTests {
    @TestCase
    func matmul() {
        // [[1,2],[3,4]] * [[5,6],[7,8]] = [[19,22],[43,50]]
        let a = Matrix.fromRows([[1.0, 2.0], [3.0, 4.0]])
        let b = Matrix.fromRows([[5.0, 6.0], [7.0, 8.0]])
        let c = a * b
        @Expect(c[0, 0], 19.0)
        @Expect(c[0, 1], 22.0)
        @Expect(c[1, 0], 43.0)
        @Expect(c[1, 1], 50.0)
    }

    @TestCase
    func matvec() {
        // [[1,2,3],[4,5,6]] * [1,1,1] = [6, 15]
        let a = Matrix.fromRows([[1.0, 2.0, 3.0], [4.0, 5.0, 6.0]])
        let x = Vector.of([1.0, 1.0, 1.0])
        let y = a * x
        @Expect(y[0], 6.0)
        @Expect(y[1], 15.0)
    }

    @TestCase
    func dotAndNorm() {
        let x = Vector.of([1.0, 2.0, 3.0])
        let y = Vector.of([4.0, 5.0, 6.0])
        @Expect(x.dot(y), 32.0)
        @Expect(abs(x.norm() - sqrt(14.0)) < 1e-12)
        @Expect(x.norm1(), 6.0)
    }

    @TestCase
    func transposeAndTrace() {
        let a = Matrix.fromRows([[1.0, 2.0, 3.0], [4.0, 5.0, 6.0]])
        let at = a.t
        @Expect(at.rows, 3)
        @Expect(at.cols, 2)
        @Expect(at[2, 1], 6.0)
        let s = Matrix.fromRows([[1.0, 0.0], [0.0, 4.0]])
        @Expect(s.trace(), 5.0)
    }

    @TestCase
    func arithmetic() {
        let a = Matrix.fromRows([[1.0, 2.0], [3.0, 4.0]])
        let b = Matrix.ones(2, 2)
        let sum = a + b
        @Expect(sum[0, 0], 2.0)
        @Expect(sum[1, 1], 5.0)
        let scaled = a * 2.0
        @Expect(scaled[1, 0], 6.0)
        @Expect((a - a).frobeniusNorm() < 1e-15)
    }

    @TestCase
    func factoriesAndIndexing() {
        let id = Matrix.identity(3)
        @Expect(id[0, 0], 1.0)
        @Expect(id[0, 1], 0.0)
        @Expect(id.trace(), 3.0)
        let m = Matrix.build(2, 3) {i, j => Float64(i * 3 + j)}
        @Expect(m[1, 2], 5.0)
    }

    @TestCase
    func dimensionMismatchThrows() {
        let a = Matrix.fromRows([[1.0, 2.0]])
        let b = Matrix.fromRows([[1.0, 2.0]])
        @AssertThrows[DimensionMismatchException](a * b)
    }
}
