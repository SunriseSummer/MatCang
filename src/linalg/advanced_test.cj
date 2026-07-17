/*
 * Tests for the advanced solvers: LU exposure, SPD solve, triangular solve and
 * matrix powers — each checked against a defining identity.
 */
package matcang.linalg

import std.math.*
import matcang.core.{Matrix, Vector, Triangle, Transpose, SingularMatrixException}

@Test
class AdvancedLinalgTests {
    @TestCase
    func luReconstructs() {
        let a = Matrix.fromRows([[2.0, 1.0, 1.0], [4.0, -6.0, 0.0], [-2.0, 7.0, 2.0]])
        let f = lu(a)
        // p l u == a
        @Expect((f.p * f.l * f.u).approxEquals(a, tol: 1e-12))
        // l unit lower, u upper
        @Expect(abs(f.l[0, 0] - 1.0) < 1e-15 && abs(f.l[0, 1]) < 1e-15)
        @Expect(abs(f.u[1, 0]) < 1e-15)
        // p orthogonal
        @Expect((f.p * f.p.t).approxEquals(Matrix.identity(3), tol: 1e-15))
    }

    @TestCase
    func luRectangular() {
        let a = Matrix.randomNormal(5, 3, seed: 31)
        let f = lu(a)
        @Expect(f.l.rows == 5 && f.l.cols == 3 && f.u.rows == 3 && f.u.cols == 3)
        @Expect((f.p * f.l * f.u).approxEquals(a, tol: 1e-12))
        let wide = Matrix.randomNormal(3, 5, seed: 32)
        let g = lu(wide)
        @Expect((g.p * g.l * g.u).approxEquals(wide, tol: 1e-12))
    }

    @TestCase
    func spdSolve() {
        // SPD system: A = M^T M + I is positive definite
        let m = Matrix.randomNormal(4, 4, seed: 33)
        let a = m.t * m + Matrix.identity(4)
        let b = Vector.of([1.0, 2.0, 3.0, 4.0])
        let x = solveSPD(a, b)
        @Expect((a * x - b).norm() < 1e-10)
        // agrees with the general solver
        @Expect(x.approxEquals(solve(a, b), tol: 1e-10))
        // non-SPD input is rejected
        let indefinite = Matrix.fromRows([[1.0, 2.0], [2.0, 1.0]])
        @AssertThrows[SingularMatrixException](solveSPD(indefinite, Vector.of([1.0, 1.0])))
    }

    @TestCase
    func triangularSolve() {
        let l = Matrix.fromRows([[2.0, 0.0, 0.0], [1.0, 3.0, 0.0], [4.0, -1.0, 5.0]])
        let b = Vector.of([2.0, 5.0, 8.0])
        let x = solveTriangular(l, b, uplo: Triangle.Lower)
        @Expect((l * x - b).norm() < 1e-12)
        // upper via the transpose flag
        let y = solveTriangular(l, b, uplo: Triangle.Lower, trans: Transpose.Trans)
        @Expect((l.t * y - b).norm() < 1e-12)
    }

    @TestCase
    func choleskyThenTriangularReuse() {
        // factor once, back-substitute twice: l (l^T x) = b
        let m = Matrix.randomNormal(4, 4, seed: 34)
        let a = m.t * m + Matrix.identity(4) * 2.0
        let b = Vector.of([1.0, 0.0, -1.0, 2.0])
        let l = cholesky(a)
        let z = solveTriangular(l, b, uplo: Triangle.Lower)
        let x = solveTriangular(l, z, uplo: Triangle.Lower, trans: Transpose.Trans)
        @Expect((a * x - b).norm() < 1e-9)
    }

    @TestCase
    func matrixPowers() {
        let a = Matrix.fromRows([[1.0, 1.0], [0.0, 1.0]])
        // a^k = [[1, k], [0, 1]] for this shear matrix
        let a5 = matrixPower(a, 5)
        @Expect(abs(a5[0, 1] - 5.0) < 1e-12)
        @Expect(matrixPower(a, 0).approxEquals(Matrix.identity(2)))
        // negative power: a^-1 * a == I
        let inv = matrixPower(a, -1)
        @Expect((inv * a).approxEquals(Matrix.identity(2), tol: 1e-12))
        // Fibonacci via matrix power: [[1,1],[1,0]]^10 -> F(10)=55 at (0,1)
        let fib = matrixPower(Matrix.fromRows([[1.0, 1.0], [1.0, 0.0]]), 10)
        @Expect(abs(fib[0, 1] - 55.0) < 1e-9)
    }
}
