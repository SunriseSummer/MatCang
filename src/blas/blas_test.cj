/*
 * Tests for the explicit-control BLAS layer, focusing on the transpose paths
 * the ergonomic operators do not exercise.
 */
package matcang.blas

import std.math.*
import matcang.core.{Matrix, Vector, Complex, ComplexMatrix, Transpose, DimensionMismatchException}

@Test
class BlasTests {
    @TestCase
    func gemmNoTrans() {
        let a = Matrix.fromRows([[1.0, 2.0], [3.0, 4.0]])
        let b = Matrix.fromRows([[5.0, 6.0], [7.0, 8.0]])
        let c = gemm(a, b)
        @Expect(abs(c[0, 0] - 19.0) < 1e-12)
        @Expect(abs(c[1, 1] - 50.0) < 1e-12)
    }

    @TestCase
    func gemmTransB() {
        // A A^T for A = [[1,2,3],[4,5,6]] = [[14,32],[32,77]]
        let a = Matrix.fromRows([[1.0, 2.0, 3.0], [4.0, 5.0, 6.0]])
        let c = gemm(a, a, transB: Transpose.Trans)
        @Expect(abs(c[0, 0] - 14.0) < 1e-12)
        @Expect(abs(c[0, 1] - 32.0) < 1e-12)
        @Expect(abs(c[1, 1] - 77.0) < 1e-12)
    }

    @TestCase
    func gemmTransA() {
        // A^T A for A = [[1,2],[3,4]] = [[10,14],[14,20]]
        let a = Matrix.fromRows([[1.0, 2.0], [3.0, 4.0]])
        let c = gemm(a, a, transA: Transpose.Trans)
        @Expect(abs(c[0, 0] - 10.0) < 1e-12)
        @Expect(abs(c[1, 1] - 20.0) < 1e-12)
    }

    @TestCase
    func gemvTransposed() {
        let a = Matrix.fromRows([[1.0, 2.0, 3.0], [4.0, 5.0, 6.0]])
        let y = gemv(a, Vector.of([1.0, 1.0, 1.0]))
        @Expect(abs(y[0] - 6.0) < 1e-12)
        @Expect(abs(y[1] - 15.0) < 1e-12)
        let yt = gemv(a, Vector.of([1.0, 1.0]), transA: Transpose.Trans)
        @Expect(abs(yt[0] - 5.0) < 1e-12)
        @Expect(abs(yt[2] - 9.0) < 1e-12)
    }

    @TestCase
    func outerProduct() {
        let m = ger(Vector.of([1.0, 2.0]), Vector.of([3.0, 4.0]))
        @Expect(abs(m[0, 0] - 3.0) < 1e-12)
        @Expect(abs(m[1, 0] - 6.0) < 1e-12)
        @Expect(abs(m[1, 1] - 8.0) < 1e-12)
    }

    @TestCase
    func axpyFused() {
        let r = axpy(2.0, Vector.of([1.0, 1.0, 1.0]), Vector.of([1.0, 2.0, 3.0]))
        @Expect(abs(r[0] - 3.0) < 1e-12)
        @Expect(abs(r[2] - 5.0) < 1e-12)
    }

    @TestCase
    func gemmIntoInPlace() {
        let a = Matrix.fromRows([[1.0, 2.0], [3.0, 4.0]])
        let b = Matrix.fromRows([[5.0, 6.0], [7.0, 8.0]])
        let c = Matrix.ones(2, 2)
        // c = 1*a*b + 2*c  ->  [[19,22],[43,50]] + [[2,2],[2,2]]
        gemmInto(a, b, c, alpha: 1.0, beta: 2.0)
        @Expect(abs(c[0, 0] - 21.0) < 1e-12)
        @Expect(abs(c[1, 1] - 52.0) < 1e-12)
        @AssertThrows[DimensionMismatchException](gemmInto(a, b, Matrix(3, 3)))
    }

    @TestCase
    func symmetricRankK() {
        // A A^T is symmetric; check syrk fills both triangles consistently
        let a = Matrix.fromRows([[1.0, 2.0, 3.0], [4.0, 5.0, 6.0]])
        let c = syrk(a)
        @Expect(abs(c[0, 1] - c[1, 0]) < 1e-15)
        @Expect(abs(c[0, 1] - 32.0) < 1e-12)
    }
}

@Test
class ComplexBlasTests {
    func ma(): ComplexMatrix {
        ComplexMatrix([[Complex(1.0, 1.0), Complex(2.0, 0.0)], [Complex(0.0, 1.0), Complex(1.0, -1.0)]])
    }
    func mb(): ComplexMatrix {
        ComplexMatrix([[Complex(2.0, -1.0), Complex(0.0, 1.0)], [Complex(1.0, 0.0), Complex(3.0, 2.0)]])
    }

    @TestCase
    func complexGemmMatchesOperator() {
        @Expect(gemm(ma(), mb()).approxEquals(ma() * mb(), tol: 1e-12))
    }

    @TestCase
    func complexGemmTransposeFlags() {
        // Trans reproduces .t products; ConjTrans reproduces .h products
        @Expect(gemm(ma(), mb(), transA: Transpose.Trans).approxEquals(ma().t * mb(), tol: 1e-12))
        @Expect(gemm(ma(), mb(), transB: Transpose.ConjTrans).approxEquals(ma() * mb().h, tol: 1e-12))
        @Expect(gemm(ma(), mb(), transA: Transpose.ConjTrans, transB: Transpose.Trans)
            .approxEquals(ma().h * mb().t, tol: 1e-12))
    }

    @TestCase
    func complexGemmAlpha() {
        // alpha = i rotates the whole product by 90 degrees
        let byI = gemm(ma(), mb(), alpha: Complex(0.0, 1.0))
        @Expect(byI.approxEquals((ma() * mb()) * Complex(0.0, 1.0), tol: 1e-12))
    }

    @TestCase
    func complexGemmIntoAccumulates() {
        let c = ComplexMatrix.identity(2)
        // c = 1*A*B + 2*c
        gemmInto(ma(), mb(), c, beta: Complex(2.0, 0.0))
        let expected = ma() * mb() + ComplexMatrix.identity(2) * Complex(2.0, 0.0)
        @Expect(c.approxEquals(expected, tol: 1e-12))
        // shape mismatch is a contract violation
        @AssertThrows[DimensionMismatchException](gemmInto(ma(), mb(), ComplexMatrix(3, 3)))
    }
}
