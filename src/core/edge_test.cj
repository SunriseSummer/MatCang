/*
 * Edge-case and API-coverage tests for the core types: empty/degenerate shapes,
 * reshape/transpose invariants, factories, and error conditions.
 */
package matcang.core

import std.math.*

@Test
class MatrixEdgeTests {
    @TestCase
    func emptyAndSingleton() {
        let empty = Matrix(0, 0)
        @Expect(empty.isEmpty)
        @Expect(empty.frobeniusNorm() < 1e-18)
        let one = Matrix.fromRows([[42.0]])
        @Expect(one.isSquare)
        @Expect(abs(one.trace() - 42.0) < 1e-12)
        @Expect(abs((one * one)[0, 0] - 1764.0) < 1e-9)
    }

    @TestCase
    func reshapeSharesAndValidates() {
        let a = Matrix.build(2, 3) {i, j => Float64(i * 3 + j)}
        let r = a.reshape(3, 2)
        @Expect(r.rows == 3 && r.cols == 2)
        @Expect(abs(r[2, 1] - 5.0) < 1e-12)
        @AssertThrows[DimensionMismatchException](a.reshape(4, 2))
    }

    @TestCase
    func transposeInvolution() {
        let a = Matrix.randomNormal(4, 7, seed: 3)
        @Expect(a.t.t.approxEquals(a))
        // (AB)^T == B^T A^T
        let b = Matrix.randomNormal(7, 5, seed: 4)
        @Expect((a * b).t.approxEquals(b.t * a.t, tol: 1e-9))
    }

    @TestCase
    func indexingBounds() {
        let a = Matrix.identity(3)
        @AssertThrows[MatCangException](a[3, 0])
        @AssertThrows[MatCangException](a[0, 3])
    }

    @TestCase
    func rowsColumnsDiagonal() {
        let a = Matrix.fromRows([[1.0, 2.0, 3.0], [4.0, 5.0, 6.0]])
        @Expect(a.row(1).approxEquals(Vector.of([4.0, 5.0, 6.0])))
        @Expect(a.col(2).approxEquals(Vector.of([3.0, 6.0])))
        @Expect(a.diagonal().approxEquals(Vector.of([1.0, 5.0])))
        let m = Matrix.zeros(2, 2)
        m.setRow(0, Vector.of([7.0, 8.0]))
        m.setColumn(1, Vector.of([8.0, 9.0]))
        @Expect(abs(m[0, 0] - 7.0) < 1e-12 && abs(m[1, 1] - 9.0) < 1e-12)
    }

    @TestCase
    func hadamardAndReductions() {
        let a = Matrix.fromRows([[1.0, 2.0], [3.0, 4.0]])
        let b = Matrix.filled(2, 2, 2.0)
        @Expect(a.hadamard(b).approxEquals(a * 2.0))
        @Expect(abs(a.sum() - 10.0) < 1e-12)
        @Expect(abs(a.max() - 4.0) < 1e-12)
        @Expect(abs(a.min() - 1.0) < 1e-12)
        @Expect(abs(a.mean() - 2.5) < 1e-12)
    }

    @TestCase
    func factoriesFromColumnsAndDiag() {
        let c = Matrix.fromColumns([[1.0, 2.0], [3.0, 4.0]])
        @Expect(abs(c[0, 1] - 3.0) < 1e-12 && abs(c[1, 0] - 2.0) < 1e-12)
        let d = Matrix.fromDiagonal([2.0, 5.0, 7.0])
        @Expect(abs(d.trace() - 14.0) < 1e-12 && abs(d[0, 1]) < 1e-18)
        @AssertThrows[DimensionMismatchException](Matrix.fromRows([[1.0, 2.0], [3.0]]))
    }
}
