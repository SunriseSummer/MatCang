/*
 * Tests for the specialised double-precision solvers and matrix exponential.
 */
package matcang.linalg

import matcang.core.{Matrix, Vector}
import std.math.*

@Test
class SpecialSolversTests {
    @TestCase
    func generalizedSymmetricEig() {
        // A x = lambda B x, A symmetric, B SPD
        let a = Matrix([[2.0, 1.0], [1.0, 2.0]])
        let b = Matrix([[2.0, 0.0], [0.0, 1.0]])
        let e = eigSymmetricGeneralized(a, b)
        @Expect(e.values.size == 2)
        @Expect(e.values[0] <= e.values[1])
        // each pair satisfies A v = lambda B v
        for (k in 0..2) {
            let v = e.vectors.col(k)
            let lhs = a * v
            let rhs = (b * v) * e.values[k]
            @Expect(lhs.approxEquals(rhs, tol: 1e-9))
        }
    }

    @TestCase
    func tridiagonalSolve() {
        // 4x4 tridiagonal with diagonal 4, off-diagonals -1
        let dl = Vector([-1.0, -1.0, -1.0])
        let d = Vector([4.0, 4.0, 4.0, 4.0])
        let du = Vector([-1.0, -1.0, -1.0])
        let b = Vector([1.0, 2.0, 3.0, 4.0])
        let x = solveTridiagonal(dl, d, du, b)
        // reconstruct the dense matrix and check A x = b
        let dense = Matrix.build(4, 4) {
            i, j => if (i == j) {
                4.0
            } else if (abs(i - j) == 1) {
                -1.0
            } else {
                0.0
            }
        }
        @Expect((dense * x).approxEquals(b, tol: 1e-9))
    }

    @TestCase
    func symmetricTridiagonalEig() {
        let d = Vector([2.0, 2.0, 2.0])
        let e = Vector([-1.0, -1.0])
        let res = eigSymmetricTridiagonal(d, e)
        // compare spectrum against the equivalent dense symmetric eig
        let dense = Matrix([[2.0, -1.0, 0.0], [-1.0, 2.0, -1.0], [0.0, -1.0, 2.0]])
        let ref = eigSymmetric(dense)
        @Expect(res.values.approxEquals(ref.values, tol: 1e-9))
        // eigenvectors satisfy T v = lambda v
        for (k in 0..3) {
            let v = res.vectors.col(k)
            @Expect((dense * v).approxEquals(v * res.values[k], tol: 1e-9))
        }
    }

    @TestCase
    func schurDecomposition() {
        let a = Matrix([[4.0, 1.0, 2.0], [0.0, 3.0, -1.0], [1.0, 0.0, 2.0]])
        let s = schur(a)
        // A = Z T Z^T
        @Expect((s.z * s.t * s.z.t).approxEquals(a, tol: 1e-9))
        // Z orthogonal: Z Z^T = I
        @Expect((s.z * s.z.t).approxEquals(Matrix.identity(3), tol: 1e-9))
    }

    @TestCase
    func matrixExponential() {
        // expm(0) = I
        @Expect(expm(Matrix.zeros(3, 3)).approxEquals(Matrix.identity(3), tol: 1e-12))
        // expm(diag(a,b)) = diag(e^a, e^b)
        let d = expm(Matrix([[0.5, 0.0], [0.0, -1.0]]))
        @Expect(abs(d[0, 0] - exp(0.5)) < 1e-9 && abs(d[1, 1] - exp(-1.0)) < 1e-9)
        @Expect(abs(d[0, 1]) < 1e-12 && abs(d[1, 0]) < 1e-12)
        // expm([[0,-t],[t,0]]) = rotation by t
        let t = 0.7
        let r = expm(Matrix([[0.0, -t], [t, 0.0]]))
        @Expect(abs(r[0, 0] - cos(t)) < 1e-9 && abs(r[0, 1] + sin(t)) < 1e-9)
        @Expect(abs(r[1, 0] - sin(t)) < 1e-9 && abs(r[1, 1] - cos(t)) < 1e-9)
        // larger norm exercises several scaling/squaring rounds accurately
        let big = expm(Matrix([[30.0, 0.0], [0.0, -30.0]]))
        @Expect(abs(big[0, 0] - exp(30.0)) / exp(30.0) < 1e-9)
        @Expect(abs(big[1, 1] - exp(-30.0)) / exp(-30.0) < 1e-9)
        // extreme norm must not crash (the scale count is capped; entries may
        // legitimately overflow to Inf, but the call itself succeeds)
        let huge = expm(Matrix([[1.0e19, 0.0], [0.0, 1.0e19]]))
        @Expect(huge.rows == 2 && huge[0, 0] != 0.0)
    }
}
