/*
 * Tests for ComplexMatrix: zgemm/zgemv products, transpose vs conjugate
 * transpose, and the Hermitian identity A A^H = (A A^H)^H.
 */
package matcang.core

import std.math.*

@Test
class ComplexMatrixTests {
    // A = [[i, 1], [1, i]]
    func ca(): ComplexMatrix {
        ComplexMatrix([[Complex(0.0, 1.0), Complex(1.0, 0.0)], [Complex(1.0, 0.0), Complex(0.0, 1.0)]])
    }

    @TestCase
    func constructionAndParts() {
        let a = ca()
        @Expect(a.rows == 2 && a.cols == 2 && a.isSquare)
        @Expect(a[0, 0] == Complex(0.0, 1.0) && a[0, 1] == Complex(1.0, 0.0))
        @Expect(a.real().approxEquals(Matrix([[0.0, 1.0], [1.0, 0.0]])))
        @Expect(a.imag().approxEquals(Matrix([[1.0, 0.0], [0.0, 1.0]])))
        @AssertThrows[MatCangException](a[2, 0])
    }

    @TestCase
    func identityAndMultiply() {
        let a = ca()
        // A * I == A
        @Expect((a * ComplexMatrix.identity(2)).approxEquals(a))
        // A * B with B = [[1, i], [i, 1]] gives 2i * I
        let b = ComplexMatrix([[Complex(1.0, 0.0), Complex(0.0, 1.0)], [Complex(0.0, 1.0), Complex(1.0, 0.0)]])
        let c = a * b
        @Expect(c.approxEquals(ComplexMatrix.fromDiagonal([Complex(0.0, 2.0), Complex(0.0, 2.0)])))
    }

    @TestCase
    func matVec() {
        // A * [1, 1] = [i+1, 1+i]
        let y = ca() * ComplexVector.of([Complex(1.0, 0.0), Complex(1.0, 0.0)])
        @Expect(y.approxEquals(ComplexVector.of([Complex(1.0, 1.0), Complex(1.0, 1.0)])))
    }

    @TestCase
    func transposeVsAdjoint() {
        // M = [[1+i, 2-i], [3, 4i]]
        let m = ComplexMatrix([[Complex(1.0, 1.0), Complex(2.0, -1.0)], [Complex(3.0, 0.0), Complex(0.0, 4.0)]])
        // plain transpose swaps indices, keeps values
        @Expect(m.t[1, 0] == Complex(2.0, -1.0) && m.t[0, 1] == Complex(3.0, 0.0))
        // conjugate transpose also conjugates
        @Expect(m.h[1, 0] == Complex(2.0, 1.0) && m.h[0, 1] == Complex(3.0, 0.0))
        @Expect(m.h[0, 0] == Complex(1.0, -1.0) && m.h[1, 1] == Complex(0.0, -4.0))
        // (A^H)^H == A
        @Expect(m.h.h.approxEquals(m))
    }

    @TestCase
    func aTimesAdjointIsHermitian() {
        let m = ComplexMatrix([[Complex(1.0, 1.0), Complex(2.0, -1.0)], [Complex(3.0, 0.0), Complex(0.0, 4.0)]])
        let g = m * m.h // Gram matrix: Hermitian and positive semidefinite

        // Hermitian: g[i,j] == conj(g[j,i]); diagonal is real
        for (i in 0..2) {
            @Expect(abs(g[i, i].im) < 1e-12)
            for (j in 0..2) {
                let a = g[i, j]
                let b = g[j, i]
                @Expect(abs(a.re - b.re) < 1e-12 && abs(a.im + b.im) < 1e-12)
            }
        }
    }

    @TestCase
    func arithmeticAndScale() {
        let a = ca()
        @Expect((a + a).approxEquals(a * Complex(2.0, 0.0)))
        @Expect((a - a).frobeniusNorm() < 1e-15)
        // scale by i then by -i recovers the original
        @Expect((a * Complex(0.0, 1.0) * Complex(0.0, -1.0)).approxEquals(a))
        @Expect(ComplexMatrix.fromReal(Matrix.identity(3)).approxEquals(ComplexMatrix.identity(3)))
        // real-scalar multiply and divide (zdscal paths)
        @Expect((a * 2.0).approxEquals(a + a))
        @Expect((a / 2.0 + a / 2.0).approxEquals(a))
    }

    @TestCase
    func traceOfDiagonal() {
        // trace of [[i,1],[1,i]] = 2i
        @Expect(ca().trace() == Complex(0.0, 2.0))
        let d = ComplexMatrix.fromDiagonal([Complex(1.0, 2.0), Complex(3.0, -4.0)])
        @Expect(d.trace() == Complex(4.0, -2.0))
        // trace requires a square matrix
        @AssertThrows[NonSquareMatrixException](ComplexMatrix(2, 3).trace())
    }

    @TestCase
    func dimensionErrors() {
        @AssertThrows[DimensionMismatchException](ca() * ComplexMatrix(3, 3))
        @AssertThrows[DimensionMismatchException](ca() + ComplexMatrix(3, 3))
    }
}
