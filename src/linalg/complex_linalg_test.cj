/*
 * Tests for complex linear algebra, each checked against a defining identity:
 *   solve         A x = b
 *   inverse       A A^-1 = I
 *   eig           A v_k = lambda_k v_k
 *   eigHermitian  real spectrum, A = V diag(lambda) V^H
 *   svd           A = U diag(s) V^H, s >= 0 descending
 */
package matcang.linalg

import matcang.core.{Complex, Vector, Matrix, ComplexMatrix, ComplexVector, SingularMatrixException}
import std.math.*

@Test
class ComplexLinalgTests {
    // general (non-Hermitian) matrix
    func cg(): ComplexMatrix {
        ComplexMatrix([[Complex(1.0, 1.0), Complex(2.0, 0.0)], [Complex(3.0, 0.0), Complex(4.0, -1.0)]])
    }
    // Hermitian matrix: A[1,0] = conj(A[0,1])
    func herm(): ComplexMatrix {
        ComplexMatrix([[Complex(2.0, 0.0), Complex(1.0, -1.0)], [Complex(1.0, 1.0), Complex(3.0, 0.0)]])
    }

    @TestCase
    func solveRoundTrip() {
        let a = cg()
        let b = ComplexVector.of([Complex(1.0, 0.0), Complex(0.0, 1.0)])
        let x = solve(a, b)
        @Expect((a * x).approxEquals(b, tol: 1e-9))
    }

    @TestCase
    func inverseRoundTrip() {
        let a = cg()
        let inv = inverse(a)
        @Expect((a * inv).approxEquals(ComplexMatrix.identity(2), tol: 1e-9))
        @Expect((inv * a).approxEquals(ComplexMatrix.identity(2), tol: 1e-9))
    }

    @TestCase
    func eigPairs() {
        // upper-triangular => eigenvalues are the diagonal {1+i, 3-i}
        let a = ComplexMatrix([[Complex(1.0, 1.0), Complex(2.0, 0.0)], [Complex(0.0, 0.0), Complex(3.0, -1.0)]])
        let e = eigen(a)
        @Expect(e.values.size == 2)
        // each (lambda_k, v_k) satisfies A v_k = lambda_k v_k
        for (k in 0..2) {
            let vk = e.vectors.col(k)
            let lhs = a * vk
            let rhs = vk * e.values[k]
            @Expect(lhs.approxEquals(rhs, tol: 1e-9))
        }
        // spectrum matches the diagonal (order-independent)
        let vals = e.values
        let got0 = vals[0]
        let got1 = vals[1]
        let hit = (approxC(got0, Complex(1.0, 1.0)) && approxC(got1, Complex(3.0, -1.0))) || (approxC(got1,
            Complex(1.0, 1.0)) && approxC(got0, Complex(3.0, -1.0)))
        @Expect(hit)
    }

    @TestCase
    func hermitianSpectrumIsReal() {
        let a = herm()
        let e = eigHermitian(a)
        @Expect(e.values.size == 2)
        // ascending real eigenvalues; trace = sum = 5, det = 2*3-|1-i|^2 = 6-2 = 4
        @Expect(abs(e.values[0] + e.values[1] - 5.0) < 1e-9)
        @Expect(abs(e.values[0] * e.values[1] - 4.0) < 1e-9)
        @Expect(e.values[0] <= e.values[1])
        // eigenpairs
        for (k in 0..2) {
            let vk = e.vectors.col(k)
            let lhs = a * vk
            let rhs = vk * Complex(e.values[k], 0.0)
            @Expect(lhs.approxEquals(rhs, tol: 1e-9))
        }
        // reconstruct A = V diag(lambda) V^H
        let v = e.vectors
        let d = ComplexMatrix.fromDiagonal([Complex(e.values[0], 0.0), Complex(e.values[1], 0.0)])
        @Expect((v * d * v.h).approxEquals(a, tol: 1e-9))
    }

    @TestCase
    func eigenvaluesHermitianOnly() {
        let full = eigHermitian(herm())
        let vals = eigenvaluesHermitian(herm())
        @Expect(vals.approxEquals(full.values, tol: 1e-9))
    }

    @TestCase
    func svdReconstruction() {
        // rectangular complex matrix
        let a = ComplexMatrix(
            [
                [Complex(1.0, 1.0), Complex(2.0, 0.0), Complex(0.0, -1.0)],
                [Complex(3.0, 0.0), Complex(0.0, 1.0), Complex(1.0, 1.0)]
            ]
        )
        let d = svd(a)
        let k = d.s.size
        @Expect(k == 2)
        // singular values are real, non-negative, descending
        for (i in 0..k) {
            @Expect(d.s[i] >= -1e-12)
        }
        @Expect(d.s[0] >= d.s[1] - 1e-12)
        // reconstruct A = U diag(s) V^H
        let sc = Array<Complex>(k, {i => Complex(d.s[i], 0.0)})
        let sigma = ComplexMatrix.fromDiagonal(sc)
        @Expect((d.u * sigma * d.vh).approxEquals(a, tol: 1e-9))
    }

    @TestCase
    func singularSolveThrows() {
        let sing = ComplexMatrix([[Complex(1.0, 0.0), Complex(2.0, 0.0)], [Complex(2.0, 0.0), Complex(4.0, 0.0)]])
        @AssertThrows[SingularMatrixException](solve(sing, ComplexVector.of([Complex(1.0, 0.0), Complex(1.0, 0.0)])))
    }

    @TestCase
    func realMatrixComplexEigen() {
        // rotation matrix [[0,-1],[1,0]] has eigenvalues +/- i (genuinely complex)
        let a = Matrix([[0.0, -1.0], [1.0, 0.0]])
        let e = eigen(a)
        @Expect(e.values.size == 2)
        // eigenvalues are +/- i
        let ok = (approxC(e.values[0], Complex(0.0, 1.0)) && approxC(e.values[1], Complex(0.0, -1.0))) || (approxC(
            e.values[0], Complex(0.0, -1.0)) && approxC(e.values[1], Complex(0.0, 1.0)))
        @Expect(ok)
        // eigenpairs: A v_k = lambda_k v_k (promote real A to complex to multiply)
        let ac = ComplexMatrix.fromReal(a)
        for (k in 0..2) {
            let vk = e.vectors.col(k)
            @Expect((ac * vk).approxEquals(vk * e.values[k], tol: 1e-9))
        }
        // a symmetric real matrix comes back with a real spectrum
        let s = eigen(Matrix([[2.0, 0.0], [0.0, 3.0]]))
        @Expect(abs(s.values[0].im) < 1e-12 && abs(s.values[1].im) < 1e-12)
    }

    @TestCase
    func complexDeterminant() {
        // det([[1+i, 2], [3, 4-i]]) = (1+i)(4-i) - 6 = (5+3i) - 6 = -1+3i
        let d = determinant(cg())
        @Expect(approxC(d, Complex(-1.0, 3.0)))
        @Expect(approxC(determinant(ComplexMatrix.identity(3)), Complex(1.0, 0.0)))
        // singular (rank-1) matrix -> 0
        let sing = ComplexMatrix([[Complex(1.0, 1.0), Complex(2.0, 2.0)], [Complex(2.0, 2.0), Complex(4.0, 4.0)]])
        @Expect(determinant(sing).abs() < 1e-12)
        // det(A B) = det(A) det(B)
        let a = cg()
        let b = herm()
        @Expect(approxC(determinant(a * b), determinant(a) * determinant(b)))
    }

    @TestCase
    func complexCholesky() {
        // Hermitian positive definite
        let a = herm()
        let l = cholesky(a) // lower: a = l l^H
        @Expect((l * l.h).approxEquals(a, tol: 1e-9))
        // strictly upper part of l is zero, diagonal is real positive
        @Expect(l[0, 1].abs() < 1e-15)
        @Expect(l[0, 0].im == 0.0 && l[0, 0].re > 0.0)
        // upper variant: a = u^H u
        let u = cholesky(a, lower: false)
        @Expect((u.h * u).approxEquals(a, tol: 1e-9))
        // not positive definite -> throws
        let indefinite = ComplexMatrix([[Complex(0.0, 0.0), Complex(1.0, 0.0)], [Complex(1.0, 0.0), Complex(0.0, 0.0)]])
        @AssertThrows[SingularMatrixException](cholesky(indefinite))
    }

    @TestCase
    func complexQR() {
        // tall 3x2 complex matrix
        let a = ComplexMatrix(
            [
                [Complex(1.0, 1.0), Complex(2.0, 0.0)],
                [Complex(0.0, 1.0), Complex(1.0, -1.0)],
                [Complex(3.0, 0.0), Complex(0.0, 2.0)]
            ]
        )
        let f = qr(a)
        @Expect(f.q.rows == 3 && f.q.cols == 2 && f.r.rows == 2 && f.r.cols == 2)
        // Q^H Q = I (orthonormal columns under the Hermitian inner product)
        @Expect((f.q.h * f.q).approxEquals(ComplexMatrix.identity(2), tol: 1e-9))
        // A = Q R
        @Expect((f.q * f.r).approxEquals(a, tol: 1e-9))
        // R upper-triangular
        @Expect(f.r[1, 0].abs() < 1e-12)
    }

    func approxC(a: Complex, b: Complex): Bool {
        abs(a.re - b.re) < 1e-9 && abs(a.im - b.im) < 1e-9
    }
}
