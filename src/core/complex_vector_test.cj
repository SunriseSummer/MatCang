/*
 * Tests for ComplexVector: construction, the two inner products, norms and
 * BLAS-backed arithmetic, checked against hand-computed values.
 */
package matcang.core

import std.math.*

@Test
class ComplexVectorTests {
    func cv(): ComplexVector {
        ComplexVector.of([Complex(1.0, 2.0), Complex(3.0, 4.0)])
    }
    func cw(): ComplexVector {
        ComplexVector.of([Complex(5.0, 6.0), Complex(7.0, 8.0)])
    }

    @TestCase
    func constructionAndIndexing() {
        let x = cv()
        @Expect(x.size == 2)
        @Expect(x[0] == Complex(1.0, 2.0) && x[1] == Complex(3.0, 4.0))
        x[0] = Complex(9.0, -1.0)
        @Expect(x[0] == Complex(9.0, -1.0))
        @AssertThrows[MatCangException](x[2])
        // real promotion + parts
        let r = ComplexVector.fromReal(Vector([1.0, 2.0, 3.0]))
        @Expect(r[1] == Complex(2.0, 0.0))
        @Expect(r.imag().approxEquals(Vector([0.0, 0.0, 0.0])))
        @Expect(cv().real().approxEquals(Vector([1.0, 3.0])))
        @Expect(cv().imag().approxEquals(Vector([2.0, 4.0])))
    }

    @TestCase
    func unconjugatedDot() {
        // sum x_i y_i = (1+2i)(5+6i)+(3+4i)(7+8i) = -18+68i
        let d = cv().dot(cw())
        @Expect(abs(d.re - (-18.0)) < 1e-12 && abs(d.im - 68.0) < 1e-12)
    }

    @TestCase
    func hermitianDot() {
        // sum conj(x_i) y_i = (1-2i)(5+6i)+(3-4i)(7+8i) = 70-8i
        let d = cv().dotc(cw())
        @Expect(abs(d.re - 70.0) < 1e-12 && abs(d.im - (-8.0)) < 1e-12)
        // dotc with self is real and equals norm^2
        let s = cv().dotc(cv())
        @Expect(abs(s.im) < 1e-12)
        @Expect(abs(s.re - 30.0) < 1e-12) // 1+4+9+16
    }

    @TestCase
    func norms() {
        @Expect(abs(cv().norm() - sqrt(30.0)) < 1e-12)
        // dzasum sums |re|+|im| over entries: (1+2)+(3+4) = 10
        @Expect(abs(cv().norm1() - 10.0) < 1e-12)
    }

    @TestCase
    func arithmetic() {
        @Expect((cv() + cw()).approxEquals(ComplexVector.of([Complex(6.0, 8.0), Complex(10.0, 12.0)])))
        @Expect((cv() - cw()).approxEquals(ComplexVector.of([Complex(-4.0, -4.0), Complex(-4.0, -4.0)])))
        // scale by real and by complex
        @Expect((cv() * 2.0).approxEquals(ComplexVector.of([Complex(2.0, 4.0), Complex(6.0, 8.0)])))
        @Expect((cv() * Complex(2.0, 0.0)).approxEquals(cv() * 2.0))
        // multiply by i rotates by 90 degrees: (a+bi)i = -b+ai
        @Expect((cv() * Complex(0.0, 1.0)).approxEquals(
            ComplexVector.of([Complex(-2.0, 1.0), Complex(-4.0, 3.0)])))
        @Expect((-cv()).approxEquals(ComplexVector.of([Complex(-1.0, -2.0), Complex(-3.0, -4.0)])))
        // real-scalar division (zdscal path)
        @Expect((cv() / 2.0).approxEquals(ComplexVector.of([Complex(0.5, 1.0), Complex(1.5, 2.0)])))
    }

    @TestCase
    func conjugateAndHadamard() {
        @Expect(cv().conjugate().approxEquals(ComplexVector.of([Complex(1.0, -2.0), Complex(3.0, -4.0)])))
        @Expect(cv().hadamard(cw()).approxEquals(
            ComplexVector.of([Complex(-7.0, 16.0), Complex(-11.0, 52.0)])))
        @Expect(cv().sum() == Complex(4.0, 6.0))
    }

    @TestCase
    func dimensionErrors() {
        @AssertThrows[DimensionMismatchException](cv().dot(ComplexVector(3)))
        @AssertThrows[DimensionMismatchException](cv() + ComplexVector(3))
    }
}
