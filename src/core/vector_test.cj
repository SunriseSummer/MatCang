/*
 * Tests for Vector operations, the Complex value type and factory helpers.
 */
package matcang.core

import std.math.*

@Test
class VectorTests {
    @TestCase
    func arithmeticAndReductions() {
        let a = Vector.of([1.0, 2.0, 3.0, 4.0])
        @Expect(abs(a.sum() - 10.0) < 1e-12)
        @Expect(abs(a.mean() - 2.5) < 1e-12)
        @Expect(abs(a.max() - 4.0) < 1e-12)
        @Expect(abs(a.min() - 1.0) < 1e-12)
        let b = a * 2.0
        @Expect(abs(b[3] - 8.0) < 1e-12)
        @Expect((a + a).approxEquals(b))
    }

    @TestCase
    func dotAndNorms() {
        let a = Vector.of([3.0, 4.0])
        @Expect(abs(a.norm() - 5.0) < 1e-12)
        @Expect(abs(a.norm1() - 7.0) < 1e-12)
        @Expect(abs(a.normInf() - 4.0) < 1e-12)
        @Expect(abs(a.dot(Vector.of([1.0, 1.0])) - 7.0) < 1e-12)
    }

    @TestCase
    func linspaceAndBuild() {
        let v = Vector.linspace(0.0, 1.0, 5)
        @Expect(v.size == 5)
        @Expect(abs(v[0]) < 1e-15)
        @Expect(abs(v[4] - 1.0) < 1e-12)
        @Expect(abs(v[2] - 0.5) < 1e-12)
        let squares = Vector.build(4) {i => Float64(i * i)}
        @Expect(abs(squares[3] - 9.0) < 1e-12)
    }

    @TestCase
    func leftScalarMultiply() {
        let v = Vector.of([1.0, 2.0])
        let w = 3.0 * v
        @Expect(abs(w[0] - 3.0) < 1e-12)
        @Expect(abs(w[1] - 6.0) < 1e-12)
    }

    @TestCase
    func mismatchThrows() {
        let a = Vector.of([1.0, 2.0])
        let b = Vector.of([1.0, 2.0, 3.0])
        @AssertThrows[DimensionMismatchException](a + b)
    }
}

@Test
class ComplexTests {
    @TestCase
    func fieldOperations() {
        let a = Complex(1.0, 2.0)
        let b = Complex(3.0, -1.0)
        @Expect((a + b) == Complex(4.0, 1.0))
        @Expect((a * b) == Complex(5.0, 5.0))
        @Expect(abs(a.abs() - sqrt(5.0)) < 1e-12)
        @Expect(a.conjugate() == Complex(1.0, -2.0))
    }

    @TestCase
    func divisionRoundTrip() {
        let a = Complex(2.0, 3.0)
        let b = Complex(1.0, -1.0)
        let q = a / b
        let back = q * b
        @Expect(abs(back.re - a.re) < 1e-12)
        @Expect(abs(back.im - a.im) < 1e-12)
    }
}
