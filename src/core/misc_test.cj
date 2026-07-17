/*
 * Coverage tests for the smaller core APIs: enums, Complex extras, conversions,
 * reshape sharing semantics, mutation helpers and equality edge cases.
 */
package matcang.core

import std.math.*

@Test
class EnumTests {
    @TestCase
    func cblasCodes() {
        @Expect(Transpose.NoTrans.toCblas() == 111)
        @Expect(Transpose.Trans.toCblas() == 112)
        @Expect(Transpose.ConjTrans.toCblas() == 113)
        @Expect(Triangle.Upper.toCblas() == 121)
        @Expect(Triangle.Lower.toCblas() == 122)
        @Expect(Side.Left.toCblas() == 141)
        @Expect(Diagonal.NonUnit.toCblas() == 131)
        @Expect(Diagonal.UnitDiag.toCblas() == 132)
    }

    @TestCase
    func lapackChars() {
        // 'N' 'T' 'C' / 'U' 'L' / 'L' 'R' / 'N' 'U'
        @Expect(Transpose.NoTrans.toChar() == 78 && Transpose.Trans.toChar() == 84)
        @Expect(Triangle.Upper.toChar() == 85 && Triangle.Lower.toChar() == 76)
        @Expect(Side.Left.toChar() == 76 && Side.Right.toChar() == 82)
        @Expect(Diagonal.NonUnit.toChar() == 78 && Diagonal.UnitDiag.toChar() == 85)
    }
}

@Test
class ComplexExtraTests {
    @TestCase
    func constantsAndArg() {
        @Expect(Complex.zero() == Complex(0.0, 0.0))
        @Expect(Complex.one() == Complex(1.0, 0.0))
        @Expect(Complex.i() * Complex.i() == Complex(-1.0, 0.0))
        @Expect(abs(Complex(0.0, 2.0).arg() - 3.14159265358979 / 2.0) < 1e-9)
        @Expect(abs(Complex(-1.0, 0.0).arg() - 3.14159265358979) < 1e-9)
    }

    @TestCase
    func absIsOverflowSafe() {
        // components near Float64's range must not overflow in the squares
        let big = Complex(1.0e200, 1.0e200)
        let expected = 1.0e200 * sqrt(2.0)
        @Expect(abs(big.abs() - expected) / expected < 1e-15)
        @Expect(Complex(3.0, 4.0).abs() == 5.0)
        @Expect(Complex(0.0, 0.0).abs() == 0.0)
        @Expect(Complex(0.0, -7.0).abs() == 7.0)
    }

    @TestCase
    func rendering() {
        // Fixed 4-decimal rendering, consistent with Matrix/Vector formatting.
        @Expect(Complex(1.5, 2.0).toString() == "1.5000+2.0000i")
        @Expect(Complex(1.5, -2.0).toString() == "1.5000-2.0000i")
    }

    @TestCase
    func realConstructorAndNegate() {
        let z = Complex(3.0)
        @Expect(z.im == 0.0 && (-z) == Complex(-3.0, 0.0))
    }
}

@Test
class ConversionTests {
    @TestCase
    func to2dAndToArray() {
        let m = Matrix([[1, 2, 3], [4, 5, 6]])
        let grid = m.to2D()
        @Expect(grid.size == 2 && grid[1][2] == 6.0)
        let flat = m.toArray()
        @Expect(flat.size == 6 && flat[3] == 4.0)
        // toArray copies: mutating the copy must not touch the matrix
        flat[0] = 99.0
        @Expect(m[0, 0] == 1.0)
    }

    @TestCase
    func reshapeSharesStorage() {
        let m = Matrix([[1.0, 2.0], [3.0, 4.0]])
        let r = m.reshape(4, 1)
        r[2, 0] = 30.0 // documented aliasing: reshape shares the buffer
        @Expect(m[1, 0] == 30.0)
    }

    @TestCase
    func matmulAliasAndShape() {
        let a = Matrix([[1, 2], [3, 4]])
        @Expect(a.matmul(Matrix.identity(2)).approxEquals(a))
        @Expect(a.shape[0] == 2 && a.shape[1] == 2)
        @Expect(a.size == 4)
    }
}

@Test
class MutationAndEqualityTests {
    @TestCase
    func setRowSetColumn() {
        let m = Matrix.zeros(2, 3)
        m.setRow(1, Vector([7.0, 8.0, 9.0]))
        m.setColumn(0, Vector([1.0, 2.0]))
        @Expect(m[1, 0] == 2.0 && m[1, 2] == 9.0 && m[0, 0] == 1.0)
        @AssertThrows[DimensionMismatchException](m.setRow(0, Vector([1.0])))
        @AssertThrows[DimensionMismatchException](m.setColumn(0, Vector([1.0, 2.0, 3.0])))
    }

    @TestCase
    func equalityAndShapeMismatch() {
        let a = Matrix([[1.0, 2.0]])
        @Expect(a == a.copy())
        @Expect(a != Matrix([[1.0, 3.0]]))
        @Expect(!(a == Matrix.zeros(2, 1))) // different shapes are never equal
        @Expect(!a.approxEquals(Matrix.zeros(2, 1)))
    }

    @TestCase
    func emptyMatrixOps() {
        let e = Matrix(0, 3)
        let f = Matrix(3, 0)
        let p = e * f // 0x0 product is legal
        @Expect(p.rows == 0 && p.cols == 0)
        @Expect((e + e).isEmpty)
        @Expect(e.t.rows == 3 && e.t.cols == 0)
        @AssertThrows[DimensionMismatchException](Matrix.fromColumns([[1.0], [1.0, 2.0]]))
    }

    @TestCase
    func vectorEdgeApis() {
        @Expect(Vector.basis(4, 2)[2] == 1.0 && Vector.basis(4, 2).sum() == 1.0)
        @Expect(Vector.filled(3, 2.5).norm1() == 7.5)
        @Expect(Vector(0).isEmpty)
        let v = Vector([5.0, -6.0, 2.0])
        @AssertThrows[MatCangException](v[3])
        @Expect(v[0..3 : 2].approxEquals(Vector([5.0, 2.0])))
        @AssertThrows[DimensionMismatchException](v.hadamard(Vector([1.0])))
        // basis validates its index (a clean library error, not a raw array trap)
        @AssertThrows[MatCangException](Vector.basis(4, 4))
        @AssertThrows[MatCangException](Vector.basis(4, -1))
    }
}

@Test
class RandomSeedingTests {
    @TestCase
    func seededIsReproducible() {
        // Same explicit seed -> identical data (the property tests rely on).
        @Expect(Matrix.random(3, 3, seed: 7).approxEquals(Matrix.random(3, 3, seed: 7)))
        @Expect(Vector.random(5, seed: 7).approxEquals(Vector.random(5, seed: 7)))
        @Expect(Matrix.randomNormal(3, 3, seed: 8).approxEquals(Matrix.randomNormal(3, 3, seed: 8)))
    }

    @TestCase
    func unseededDrawsDiffer() {
        // Two unseeded draws must NOT be identical (the fixed footgun): they
        // advance a shared generator. A 9-element collision by chance is ~0.
        let a = Matrix.random(3, 3)
        let b = Matrix.random(3, 3)
        @Expect(!a.approxEquals(b))
        let u = Vector.randomNormal(8)
        let w = Vector.randomNormal(8)
        @Expect(!u.approxEquals(w))
    }

    @TestCase
    func differentSeedsDiffer() {
        @Expect(!Matrix.random(4, 4, seed: 1).approxEquals(Matrix.random(4, 4, seed: 2)))
    }
}
