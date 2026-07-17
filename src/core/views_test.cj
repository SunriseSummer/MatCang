/*
 * Tests for slicing, stacking, axis reductions, broadcasting and conversions,
 * plus regression checks for the BLAS-accelerated operators and the formatter.
 */
package matcang.core

import std.math.*

@Test
class ViewsTests {
    @TestCase
    func rectangularSlice() {
        let m = Matrix.build(4, 5) {i, j => Float64(i * 10 + j)}
        let s = m[1..3, 2..5] // rows 1,2  cols 2,3,4
        @Expect(s.rows == 2 && s.cols == 3)
        @Expect(abs(s[0, 0] - 12.0) < 1e-12)
        @Expect(abs(s[1, 2] - 24.0) < 1e-12)
        // closed ranges and steps
        let t = m[0..=2 : 2, 0..=4 : 2] // rows 0,2  cols 0,2,4
        @Expect(t.rows == 2 && t.cols == 3)
        @Expect(abs(t[1, 1] - 22.0) < 1e-12)
    }

    @TestCase
    func rowAndColumnSlices() {
        let m = Matrix.build(3, 4) {i, j => Float64(i * 4 + j)}
        let r = m[1, 1..4]
        @Expect(r.approxEquals(Vector.of([5.0, 6.0, 7.0])))
        let c = m[0..3, 2]
        @Expect(c.approxEquals(Vector.of([2.0, 6.0, 10.0])))
        @AssertThrows[MatCangException](m[0..9, 0])
    }

    @TestCase
    func stacking() {
        let a = Matrix.fromRows([[1.0, 2.0]])
        let b = Matrix.fromRows([[3.0, 4.0], [5.0, 6.0]])
        let v = Matrix.vstack([a, b])
        @Expect(v.rows == 3 && abs(v[2, 1] - 6.0) < 1e-12)
        let h = Matrix.hstack([b, b])
        @Expect(h.cols == 4 && abs(h[1, 3] - 6.0) < 1e-12)
        @AssertThrows[DimensionMismatchException](Matrix.vstack([a, Matrix.zeros(1, 3)]))
    }

    @TestCase
    func axisReductions() {
        let m = Matrix.fromRows([[1.0, 2.0, 3.0], [4.0, 5.0, 6.0]])
        @Expect(m.rowSums().approxEquals(Vector.of([6.0, 15.0])))
        @Expect(m.colSums().approxEquals(Vector.of([5.0, 7.0, 9.0])))
        @Expect(m.rowMeans().approxEquals(Vector.of([2.0, 5.0])))
        @Expect(m.colMeans().approxEquals(Vector.of([2.5, 3.5, 4.5])))
    }

    @TestCase
    func broadcasting() {
        let m = Matrix.zeros(2, 3)
        let r = m.addRowVector(Vector.of([1.0, 2.0, 3.0]))
        @Expect(abs(r[1, 2] - 3.0) < 1e-12)
        let c = m.addColVector(Vector.of([10.0, 20.0]))
        @Expect(abs(c[1, 0] - 20.0) < 1e-12)
        @AssertThrows[DimensionMismatchException](m.addRowVector(Vector.of([1.0])))
    }

    @TestCase
    func conversionsAndConcat() {
        let v = Vector.of([1.0, 2.0, 3.0])
        let col = v.toColumnMatrix()
        @Expect(col.rows == 3 && col.cols == 1 && abs(col[2, 0] - 3.0) < 1e-12)
        let rowM = v.toRowMatrix()
        @Expect(rowM.rows == 1 && rowM.cols == 3)
        let m = Matrix.fromRows([[1.0, 2.0], [3.0, 4.0]])
        @Expect(m.flatten().approxEquals(Vector.of([1.0, 2.0, 3.0, 4.0])))
        let joined = Vector.concat([v, Vector.of([9.0])])
        @Expect(joined.size == 4 && abs(joined[3] - 9.0) < 1e-12)
        let sliced = v[1..3]
        @Expect(sliced.approxEquals(Vector.of([2.0, 3.0])))
    }

    @TestCase
    func blasOperatorEquivalence() {
        // the daxpy/dscal-backed operators must match the element-wise defs
        let a = Matrix.randomNormal(7, 5, seed: 21)
        let b = Matrix.randomNormal(7, 5, seed: 22)
        @Expect((a + b).approxEquals(a.zipWith(b) {x, y => x + y}, tol: 1e-15))
        @Expect((a - b).approxEquals(a.zipWith(b) {x, y => x - y}, tol: 1e-15))
        @Expect((a * 3.5).approxEquals(a.map {x => x * 3.5}, tol: 1e-15))
        @Expect((-a).approxEquals(a.map {x => -x}, tol: 1e-15))
        @Expect(a.t.t.approxEquals(a)) // domatcopy round trip
        let u = Vector.random(9, seed: 23)
        let w = Vector.random(9, seed: 24)
        @Expect((u + w).approxEquals(u.zipWith(w) {x, y => x + y}, tol: 1e-15))
        @Expect((u * 2.0).approxEquals(u.map {x => x * 2.0}, tol: 1e-15))
    }

    @TestCase
    func formatterHandlesExtremes() {
        // regression: printing huge/non-finite values must not overflow Int64
        let m = Matrix.fromRows([[1.0e300, -2.5], [0.0, 1.0 / 0.0]])
        let s = m.toString()
        @Expect(s.size > 0)
        @Expect(Vector.of([-1.0e300]).toString().size > 0)
    }
}
