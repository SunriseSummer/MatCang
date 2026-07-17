/*
 * Error-path and additional-coverage tests for the linear algebra layer.
 */
package matcang.linalg

import std.math.*
import matcang.core.{Matrix, Vector, SingularMatrixException, NonSquareMatrixException, DimensionMismatchException}

@Test
class LinalgErrorTests {
    @TestCase
    func singularSolveThrows() {
        let singular = Matrix.fromRows([[1.0, 2.0], [2.0, 4.0]]) // rank 1
        @AssertThrows[SingularMatrixException](solve(singular, Vector.of([1.0, 2.0])))
        @Expect(abs(determinant(singular)) < 1e-12)
    }

    @TestCase
    func nonSquareThrows() {
        let rect = Matrix.zeros(2, 3)
        @AssertThrows[NonSquareMatrixException](inverse(rect))
        @AssertThrows[NonSquareMatrixException](determinant(rect))
    }

    @TestCase
    func dimensionMismatchThrows() {
        let a = Matrix.identity(3)
        @AssertThrows[DimensionMismatchException](solve(a, Vector.of([1.0, 2.0])))
    }

    @TestCase
    func choleskyNonPositiveDefiniteThrows() {
        // symmetric but indefinite
        let indefinite = Matrix.fromRows([[1.0, 2.0], [2.0, 1.0]])
        @AssertThrows[SingularMatrixException](cholesky(indefinite))
    }

    @TestCase
    func solveMatrixMultipleRhs() {
        let a = Matrix.fromRows([[2.0, 0.0], [0.0, 4.0]])
        let b = Matrix.fromRows([[2.0, 4.0], [8.0, 4.0]])
        let x = solveMatrix(a, b)
        @Expect(abs(x[0, 0] - 1.0) < 1e-12 && abs(x[0, 1] - 2.0) < 1e-12)
        @Expect(abs(x[1, 0] - 2.0) < 1e-12 && abs(x[1, 1] - 1.0) < 1e-12)
    }

    @TestCase
    func conditionNumberOfIdentity() {
        @Expect(abs(cond(Matrix.identity(4)) - 1.0) < 1e-9)
    }

    @TestCase
    func qrOnTallMatrix() {
        let a = Matrix.randomNormal(6, 3, seed: 9)
        let f = qr(a)
        @Expect(f.q.rows == 6 && f.q.cols == 3 && f.r.rows == 3 && f.r.cols == 3)
        // reconstruct
        var maxErr = 0.0
        let recon = f.q * f.r
        for (i in 0..a.data.size) {
            let d = abs(recon.data[i] - a.data[i])
            if (d > maxErr) {
                maxErr = d
            }
        }
        @Expect(maxErr < 1e-9)
    }

    @TestCase
    func inverseTimesOriginalIsIdentity() {
        let a = Matrix.randomNormal(5, 5, seed: 12)
        let prod = inverse(a) * a
        let id = Matrix.identity(5)
        @Expect(prod.approxEquals(id, tol: 1e-8))
    }
}
