/*
 * Tests for the try* API: None on data-dependent failure, Some(correct value)
 * on success, and contract violations still throwing.
 */
package matcang.linalg

import std.math.*
import matcang.core.{Matrix, Vector, Complex, ComplexMatrix, ComplexVector, Triangle, DimensionMismatchException}

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

@Test
class ComplexAndSpecialTryTests {
    func cxSingular(): ComplexMatrix {
        // rank-1: second row is 2x the first
        ComplexMatrix([[Complex(1.0, 1.0), Complex(2.0, 0.0)], [Complex(2.0, 2.0), Complex(4.0, 0.0)]])
    }
    func cxRegular(): ComplexMatrix {
        ComplexMatrix([[Complex(1.0, 1.0), Complex(2.0, 0.0)], [Complex(3.0, 0.0), Complex(4.0, -1.0)]])
    }

    @TestCase
    func complexTrySolveAndInverse() {
        let b = ComplexVector.of([Complex(1.0, 0.0), Complex(0.0, 1.0)])
        @Expect(trySolve(cxSingular(), b).isNone())
        @Expect(tryInverse(cxSingular()).isNone())
        @Expect(trySolveMatrix(cxSingular(), ComplexMatrix.identity(2)).isNone())
        if (let Some(x) <- trySolve(cxRegular(), b)) {
            @Expect((cxRegular() * x).approxEquals(b, tol: 1e-9))
        } else {
            @Fail("complex trySolve returned None on a regular system")
        }
        @Expect(tryInverse(cxRegular()).isSome())
    }

    @TestCase
    func complexTryCholesky() {
        // Hermitian but indefinite (eigenvalues of sigma_x are +/-1)
        let indefinite = ComplexMatrix([[Complex(0.0, 0.0), Complex(1.0, 0.0)], [Complex(1.0, 0.0), Complex(0.0, 0.0)]])
        @Expect(tryCholesky(indefinite).isNone())
        // Hermitian positive definite
        let hpd = ComplexMatrix([[Complex(2.0, 0.0), Complex(1.0, -1.0)], [Complex(1.0, 1.0), Complex(3.0, 0.0)]])
        @Expect(tryCholesky(hpd).isSome())
    }

    @TestCase
    func complexTrySpectral() {
        @Expect(tryEigen(cxRegular()).isSome())
        @Expect(trySvd(cxRegular()).isSome())
        let herm = cxRegular() * cxRegular().h
        @Expect(tryEigHermitian(herm).isSome())
        @Expect(tryEigenvaluesHermitian(herm).isSome())
        // real-matrix overload of tryEigen
        @Expect(tryEigen(Matrix([[0.0, -1.0], [1.0, 0.0]])).isSome())
    }

    @TestCase
    func specialSolverTwins() {
        // singular tridiagonal (all zeros)
        @Expect(trySolveTridiagonal(Vector([0.0]), Vector([0.0, 0.0]), Vector([0.0]),
            Vector([1.0, 1.0])).isNone())
        // regular tridiagonal
        @Expect(trySolveTridiagonal(Vector([-1.0]), Vector([2.0, 2.0]), Vector([-1.0]),
            Vector([1.0, 1.0])).isSome())
        // generalized eig: B not positive definite -> None
        let sym = Matrix([[2.0, 1.0], [1.0, 2.0]])
        let notPd = Matrix([[1.0, 2.0], [2.0, 1.0]])
        @Expect(tryEigSymmetricGeneralized(sym, notPd).isNone())
        @Expect(tryEigSymmetricGeneralized(sym, Matrix.identity(2)).isSome())
        // tridiagonal eig + schur succeed on well-posed inputs
        @Expect(tryEigSymmetricTridiagonal(Vector([2.0, 2.0]), Vector([-1.0])).isSome())
        @Expect(trySchur(Matrix([[1.0, 2.0], [3.0, 4.0]])).isSome())
    }
}
