/*
 * Correctness tests for the LAPACK-backed linear algebra layer. Each result is
 * checked against a known answer or a defining identity (e.g. Q Q^T = I).
 */
package matcang.linalg

import std.math.*
import matcang.core.{Matrix, Vector}

func maxAbsDiff(a: Matrix, b: Matrix): Float64 {
    var m = 0.0
    for (i in 0..a.data.size) {
        let d = abs(a.data[i] - b.data[i])
        if (d > m) {
            m = d
        }
    }
    m
}

@Test
class LinalgTests {
    @TestCase
    func solveSystem() {
        let a = Matrix.fromRows([[2.0, 1.0], [1.0, 3.0]])
        let b = Vector.of([3.0, 5.0])
        let x = solve(a, b)
        @Expect(abs(x[0] - 0.8) < 1e-12)
        @Expect(abs(x[1] - 1.4) < 1e-12)
        // residual A x - b ~ 0
        let r = a * x - b
        @Expect(r.norm() < 1e-12)
    }

    @TestCase
    func inverseAndDet() {
        let a = Matrix.fromRows([[4.0, 7.0], [2.0, 6.0]])
        let inv = inverse(a)
        let expected = Matrix.fromRows([[0.6, -0.7], [-0.2, 0.4]])
        @Expect(maxAbsDiff(inv, expected) < 1e-12)
        @Expect(abs(determinant(a) - 10.0) < 1e-10)
        // A * inv(A) == I
        let prod = a * inv
        @Expect(maxAbsDiff(prod, Matrix.identity(2)) < 1e-12)
    }

    @TestCase
    func determinantKnown() {
        let a = Matrix.fromRows([[1.0, 2.0], [3.0, 4.0]])
        @Expect(abs(determinant(a) - (-2.0)) < 1e-12)
        let id = Matrix.identity(5)
        @Expect(abs(determinant(id) - 1.0) < 1e-12)
    }

    @TestCase
    func choleskyFactor() {
        let a = Matrix.fromRows([[4.0, 2.0], [2.0, 3.0]])
        let l = cholesky(a, lower: true)
        // L * L^T == A
        let recon = l * l.t
        @Expect(maxAbsDiff(recon, a) < 1e-12)
        // L is lower triangular
        @Expect(abs(l[0, 1]) < 1e-15)
    }

    @TestCase
    func qrFactor() {
        let a = Matrix.fromRows([[12.0, -51.0], [6.0, 167.0], [-4.0, 24.0]])
        let f = qr(a)
        // Q R == A
        @Expect(maxAbsDiff(f.q * f.r, a) < 1e-9)
        // Q^T Q == I (orthonormal columns)
        let qtq = f.q.t * f.q
        @Expect(maxAbsDiff(qtq, Matrix.identity(2)) < 1e-9)
        // R upper triangular
        @Expect(abs(f.r[1, 0]) < 1e-9)
    }

    @TestCase
    func svdReconstruct() {
        let a = Matrix.fromRows([[3.0, 0.0, 0.0], [0.0, -2.0, 0.0]])
        let d = svd(a)
        // singular values descending and non-negative
        @Expect(d.s[0] >= d.s[1])
        @Expect(abs(d.s[0] - 3.0) < 1e-12)
        @Expect(abs(d.s[1] - 2.0) < 1e-12)
        // U diag(S) VT == A
        let sMat = Matrix.build(d.s.size, d.s.size) {
            i, j => if (i == j) {
                d.s[i]
            } else {
                0.0
            }
        }
        let recon = d.u * sMat * d.vt
        @Expect(maxAbsDiff(recon, a) < 1e-10)
    }

    @TestCase
    func symmetricEigen() {
        let a = Matrix.fromRows([[2.0, 1.0], [1.0, 2.0]])
        let e = eigSymmetric(a)
        // eigenvalues ascending: 1, 3
        @Expect(abs(e.values[0] - 1.0) < 1e-12)
        @Expect(abs(e.values[1] - 3.0) < 1e-12)
        // A V == V diag(values): check column by column
        let av = a * e.vectors
        let scaled = e.vectors.mapIndexed {_, j, v => v * e.values[j]}
        @Expect(maxAbsDiff(av, scaled) < 1e-10)
    }

    @TestCase
    func generalEigenvalues() {
        // rotation-like matrix has complex eigenvalues +-i
        let a = Matrix.fromRows([[0.0, -1.0], [1.0, 0.0]])
        let vals = eigenvalues(a)
        @Expect(vals.size == 2)
        @Expect(abs(vals[0].re) < 1e-12)
        @Expect(abs(abs(vals[0].im) - 1.0) < 1e-12)
    }

    @TestCase
    func leastSquaresLineFit() {
        // fit y = a + b x to points (0,1),(1,3),(2,5),(3,7): exact line y=1+2x
        let design = Matrix.fromRows([[1.0, 0.0], [1.0, 1.0], [1.0, 2.0], [1.0, 3.0]])
        let y = Vector.of([1.0, 3.0, 5.0, 7.0])
        let coef = lstsq(design, y)
        @Expect(abs(coef[0] - 1.0) < 1e-10)
        @Expect(abs(coef[1] - 2.0) < 1e-10)
    }

    @TestCase
    func pseudoInverseIdentity() {
        let a = Matrix.fromRows([[1.0, 2.0], [3.0, 4.0], [5.0, 6.0]])
        let ap = pinv(a)
        // A A+ A == A
        let recon = a * ap * a
        @Expect(maxAbsDiff(recon, a) < 1e-9)
        @Expect(matrixRank(a) == 2)
    }
}
