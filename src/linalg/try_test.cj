/*
 * Tests for the try* API: None on data-dependent failure, Some(correct value)
 * on success, and contract violations still throwing.
 */
package matcang.linalg

import std.math.*
import matcang.core.{Matrix, Vector, Triangle, DimensionMismatchException}

@Test
class TryApiTests {
    @TestCase
    func trySolvePaths() {
        let singular = Matrix([[1.0, 2.0], [2.0, 4.0]])
        @Expect(trySolve(singular, Vector([1, 2])).isNone())
        let a = Matrix([[2.0, 1.0], [1.0, 3.0]])
        let b = Vector([3.0, 5.0])
        if (let Some(x) <- trySolve(a, b)) {
            @Expect(x.approxEquals(solve(a, b)))
        } else {
            @Fail("trySolve returned None on a regular system")
        }
        // contract violations still throw from try* versions
        @AssertThrows[DimensionMismatchException](trySolve(a, Vector([1.0])))
    }

    @TestCase
    func tryInverseWithFallback() {
        let singular = Matrix([[1.0, 2.0], [2.0, 4.0]])
        @Expect(tryInverse(singular).isNone())
        // the canonical usage: fall back to the pseudo-inverse
        let generalised = tryInverse(singular) ?? pinv(singular)
        @Expect((singular * generalised * singular).approxEquals(singular, tol: 1e-9))
        let id = Matrix.identity(3)
        @Expect(tryInverse(id).getOrThrow().approxEquals(id))
    }

    @TestCase
    func tryCholeskyAndSpd() {
        let indefinite = Matrix([[1.0, 2.0], [2.0, 1.0]])
        @Expect(tryCholesky(indefinite).isNone())
        @Expect(trySolveSPD(indefinite, Vector([1, 1])).isNone())
        let spd = Matrix([[4.0, 2.0], [2.0, 3.0]])
        @Expect(tryCholesky(spd).isSome())
        if (let Some(x) <- trySolveSPD(spd, Vector([1.0, 1.0]))) {
            @Expect((spd * x - Vector([1.0, 1.0])).norm() < 1e-12)
        } else {
            @Fail("trySolveSPD returned None on an SPD system")
        }
    }

    @TestCase
    func trySolveTriangularZeroDiag() {
        let broken = Matrix([[1.0, 0.0], [3.0, 0.0]]) // zero on the diagonal
        @Expect(trySolveTriangular(broken, Vector([1, 1]), uplo: Triangle.Lower).isNone())
        let l = Matrix([[2.0, 0.0], [1.0, 3.0]])
        @Expect(trySolveTriangular(l, Vector([2.0, 5.0]), uplo: Triangle.Lower).isSome())
    }

    @TestCase
    func tryMatrixPowerNegativeSingular() {
        let singular = Matrix([[1.0, 2.0], [2.0, 4.0]])
        @Expect(tryMatrixPower(singular, -1).isNone())
        @Expect(tryMatrixPower(singular, 2).isSome()) // non-negative powers always exist
    }

    @TestCase
    func trySpectralRoutinesSucceed() {
        let a = Matrix([[2.0, 1.0], [1.0, 2.0]])
        @Expect(trySvd(a).isSome())
        @Expect(tryEigSymmetric(a).isSome())
        @Expect(tryEigenvalues(a).isSome())
        @Expect(tryLstsq(a, Vector([1.0, 1.0])).isSome())
        @Expect(tryPinv(a).isSome())
        @Expect(tryMatrixRank(a).getOrThrow() == 2)
        @Expect(tryCond(a).getOrThrow() > 1.0 - 1e-12)
        @Expect(tryEigenvaluesSymmetric(a).isSome())
        @Expect(trySolveMatrix(a, Matrix.identity(2)).isSome())
    }
}
