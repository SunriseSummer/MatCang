/*
 * API tour — every corner of matcang in one runnable program.
 *
 * Executable documentation: each section demonstrates one API area with a tiny,
 * self-checking snippet. Read it top to bottom as a tutorial; run it as an
 * end-to-end test (any failed check exits non-zero).
 */
package api_tour

import std.math.*
import matcang.core.{Matrix, Vector, Complex, ComplexMatrix, ComplexVector, Transpose, Triangle, ScalarOps, 
    DimensionMismatchException, SingularMatrixException}
import matcang.blas.{gemm, gemmInto, gemv, ger, syrk, axpy, scaleInPlace}
import matcang.linalg.{solve, solveMatrix, inverse, determinant, cholesky, qr, svd, eigSymmetric, eigenvalues, eigen, 
    lstsq, pinv, matrixRank, cond, lu, solveSPD, solveTriangular, matrixPower, trySolve, tryInverse, tryCholesky, 
    eigHermitian, eigSymmetricGeneralized, solveTridiagonal, expm}
import matcang.{setNumThreads, getNumThreads, getConfig}

var failures = 0

func check(name: String, ok: Bool): Unit {
    if (ok) {
        println("  ok   ${name}")
    } else {
        println("  FAIL ${name}")
        failures += 1
    }
}

func section(title: String): Unit {
    println("")
    println("-- ${title} --")
}

func near(x: Float64, y: Float64): Bool {
    abs(x - y) < 1e-9
}

main(): Int64 {
    println("matcang API tour  (backend: ${getConfig()})")

    section("construction")
    let a = Matrix([[1, 2], [3, 4]]) // integer literals welcome
    let b = Matrix([[0.5, 1.0], [1.5, 2.0]]) // ... and of course floats
    check("Matrix([[...]]) row-wise literal", near(a[1, 0], 3.0))
    check("Vector([1, 2, 3]) literal", near(Vector([1, 2, 3])[2], 3.0))
    check("identity/fromDiagonal",
        near(Matrix.identity(3).trace(), 3.0) && near(Matrix.fromDiagonal([2.0, 3.0]).determinantLike(), 6.0))
    check("build from rule", near(Matrix.build(3, 3) {i, j => Float64(i + j)}[2, 2], 4.0))
    check("linspace", near(Vector.linspace(0.0, 1.0, 5)[3], 0.75))
    check("random reproducible", Matrix.random(2, 2, seed: 9).approxEquals(Matrix.random(2, 2, seed: 9)))

    section("indexing, slicing, stacking")
    let m = Matrix.build(4, 5) {i, j => Float64(i * 10 + j)}
    check("m[i, j] read/write", near(m[1, 2], 12.0))
    check("rectangular slice", near(m[1..3, 2..5][1, 2], 24.0))
    check("stepped slice", near(m[0..=2 : 2, 0..=4 : 2][1, 1], 22.0))
    check("row/column slice", m[1, 0..3].approxEquals(Vector([10.0, 11.0, 12.0])))
    check("vstack/hstack", Matrix.vstack([a, b]).rows == 4 && Matrix.hstack([a, b]).cols == 4)

    section("axis reductions & broadcasting")
    check("rowSums/colMeans", m.rowSums()[0] == 10.0 && near(m.colMeans()[0], 15.0))
    check("addRowVector broadcast", near(Matrix.zeros(2, 2).addRowVector(Vector([1.0, 2.0]))[1, 1], 2.0))
    check("flatten/toColumnMatrix", near(a.flatten()[3], 4.0) && Vector([1.0]).toColumnMatrix().rows == 1)

    section("arithmetic operators (BLAS-backed)")
    check("a + b / a - b", (a + b - b).approxEquals(a, tol: 1e-12))
    check("scalar both sides", (2.0 * a).approxEquals(a * 2.0))
    check("hadamard", near(a.hadamard(a)[1, 1], 16.0))
    check("matmul a * b", near((a * Matrix.identity(2)).frobeniusNorm(), a.frobeniusNorm()))
    check("matvec a * x", (a * Vector([1.0, 0.0])).approxEquals(Vector([1.0, 3.0])))
    check("transpose involution", a.t.t.approxEquals(a))

    section("vector ops")
    let v = Vector([3.0, 4.0])
    check("dot/norm/norm1/normInf",
        near(v.dot(v), 25.0) && near(v.norm(), 5.0) && near(v.norm1(), 7.0) && near(v.normInf(), 4.0))
    check("map/zipWith", near(v.map {x => x * x}.sum(), 25.0))
    check("argAbsMax", v.argAbsMax() == 1)

    section("explicit BLAS layer")
    check("gemm with transpose", near(gemm(a, a, transB: Transpose.Trans)[0, 0], 5.0))
    let c = Matrix.ones(2, 2)
    gemmInto(a, Matrix.identity(2), c, beta: 1.0)
    check("gemmInto accumulate", near(c[0, 0], 2.0))
    check("gemv transposed", near(gemv(a, Vector([1.0, 0.0]), transA: Transpose.Trans)[1], 2.0))
    check("ger outer product", near(ger(v, v)[0, 1], 12.0))
    check("syrk symmetric", near(syrk(a)[0, 1], syrk(a)[1, 0]))
    check("axpy fused", axpy(2.0, Vector([1.0, 1.0]), Vector([0.0, 1.0])).approxEquals(Vector([2.0, 3.0])))
    check("scaleInPlace", near(scaleInPlace(Vector([1.0, 2.0]), 3.0)[1], 6.0))

    section("linear systems & factorisations")
    let spd = Matrix([[4.0, 2.0], [2.0, 3.0]])
    let rhs = Vector([1.0, 1.0])
    check("solve residual", (spd * solve(spd, rhs) - rhs).norm() < 1e-12)
    check("solveMatrix", solveMatrix(spd, Matrix.identity(2)).approxEquals(inverse(spd), tol: 1e-12))
    check("determinant", near(determinant(spd), 8.0))
    check("inverse identity", (spd * inverse(spd)).approxEquals(Matrix.identity(2), tol: 1e-12))
    let l = cholesky(spd)
    check("cholesky l l^T", (l * l.t).approxEquals(spd, tol: 1e-12))
    let f = qr(Matrix([[1.0, 2.0], [3.0, 4.0], [5.0, 6.0]]))
    check("qr orthonormal", (f.q.t * f.q).approxEquals(Matrix.identity(2), tol: 1e-9))
    let d = svd(a)
    check("svd descending", d.s[0] >= d.s[1])
    let plu = lu(Matrix([[0.0, 1.0], [2.0, 3.0]]))
    check("lu p l u == a", (plu.p * plu.l * plu.u).approxEquals(Matrix([[0.0, 1.0], [2.0, 3.0]]), tol: 1e-12))
    check("solveSPD == solve", solveSPD(spd, rhs).approxEquals(solve(spd, rhs), tol: 1e-12))
    check("solveTriangular", (l * solveTriangular(l, rhs, uplo: Triangle.Lower) - rhs).norm() < 1e-12)
    check("matrixPower shear", near(matrixPower(Matrix([[1.0, 1.0], [0.0, 1.0]]), 7)[0, 1], 7.0))

    section("spectra, least squares, conditioning")
    let sym = Matrix([[2.0, 1.0], [1.0, 2.0]])
    let e = eigSymmetric(sym)
    check("eigSymmetric values", near(e.values[0], 1.0) && near(e.values[1], 3.0))
    let rot = eigenvalues(Matrix([[0.0, -1.0], [1.0, 0.0]]))
    check("complex eigenvalues +-i", near(abs(rot[0].im), 1.0) && near(rot[0].re, 0.0))
    let design = Matrix([[1.0, 0.0], [1.0, 1.0], [1.0, 2.0]])
    check("lstsq exact line", lstsq(design, Vector([1.0, 3.0, 5.0])).approxEquals(Vector([1.0, 2.0]), tol: 1e-10))
    let sing = Matrix([[1.0, 2.0], [2.0, 4.0]])
    check("pinv on singular", (sing * pinv(sing) * sing).approxEquals(sing, tol: 1e-9))
    check("matrixRank", matrixRank(sing) == 1 && matrixRank(spd) == 2)
    check("cond of identity", near(cond(Matrix.identity(4)), 1.0))

    section("try* API: branch on failure instead of catching")
    check("trySolve singular -> None", trySolve(sing, rhs).isNone())
    check("trySolve regular -> Some", trySolve(spd, rhs).isSome())
    check("tryInverse ?? pinv fallback", (sing * (tryInverse(sing) ?? pinv(sing)) * sing).approxEquals(sing, tol: 1e-9))
    check("tryCholesky indefinite -> None", tryCholesky(Matrix([[1.0, 2.0], [2.0, 1.0]])).isNone())

    section("errors & complex numbers")
    var threw = false
    try {
        let _ = a * Matrix.identity(3)
    } catch (_: DimensionMismatchException) {
        threw = true
    }
    check("shape mismatch throws", threw)
    var singThrew = false
    try {
        let _ = inverse(sing)
    } catch (_: SingularMatrixException) {
        singThrew = true
    }
    check("singular inverse throws", singThrew)
    let z = Complex(3.0, 4.0)
    check("complex abs/conj", near(z.abs(), 5.0) && near((z * z.conjugate()).re, 25.0))

    section("complex numbers")
    let cv = ComplexVector.of([Complex(1.0, 2.0), Complex(3.0, 4.0)])
    check("ComplexVector.dotc self = ||^2", abs(cv.dotc(cv).re - 30.0) < 1e-12)
    let cm = ComplexMatrix([[Complex(0.0, 1.0), Complex(1.0, 0.0)], [Complex(1.0, 0.0), Complex(0.0, 1.0)]])
    check("ComplexMatrix A*I == A", (cm * ComplexMatrix.identity(2)).approxEquals(cm))
    check("conjugate transpose (A^H)^H == A", cm.h.h.approxEquals(cm))
    // Hermitian A A^H has a real, non-negative spectrum
    let herm = cm * cm.h
    let he = eigHermitian(herm)
    check("eigHermitian real spectrum", he.values.size == 2 && he.values[0] >= -1e-9)
    // complex solve round-trips
    let cb = ComplexVector.of([Complex(1.0, 0.0), Complex(0.0, 1.0)])
    check("complex solve A x = b", (cm * solve(cm, cb)).approxEquals(cb, tol: 1e-9))
    // general real matrix -> complex eigenpairs (rotation has eigenvalues +/- i)
    let rotEig = eigen(Matrix([[0.0, -1.0], [1.0, 0.0]]))
    check("eigen(real) gives complex eigenvalues", abs(rotEig.values[0].abs() - 1.0) < 1e-9)
    // complex determinant, trace, cholesky and QR
    check("complex determinant/trace",
        determinant(ComplexMatrix.identity(2)) == Complex(1.0, 0.0) && cm.trace() == Complex(0.0, 2.0))
    let hpd = cm * cm.h + ComplexMatrix.identity(2) * 2.0
    let lFac = cholesky(hpd)
    check("complex cholesky L*L^H", (lFac * lFac.h).approxEquals(hpd, tol: 1e-9))
    let qrf = qr(cm)
    check("complex qr Q^H Q = I",
        (qrf.q.h * qrf.q).approxEquals(ComplexMatrix.identity(2), tol: 1e-9) && (qrf
            .q * qrf
            .r)
            .approxEquals(cm, tol: 1e-9))
    // complex gemmInto (allocation-free path) matches the operator
    let cInto = ComplexMatrix(2, 2)
    gemmInto(cm, hpd, cInto)
    check("complex gemmInto", cInto.approxEquals(cm * hpd, tol: 1e-9))
    // complex try*: singular solve branches to None
    let cxSing = ComplexMatrix([[Complex(1.0, 1.0), Complex(2.0, 2.0)], [Complex(2.0, 2.0), Complex(4.0, 4.0)]])
    check("complex trySolve None on singular", trySolve(cxSing, cb).isNone())

    section("specialised solvers")
    // generalised symmetric eig  A v = lambda B v
    let ga = Matrix([[2.0, 1.0], [1.0, 2.0]])
    let gb = Matrix([[2.0, 0.0], [0.0, 1.0]])
    let ge = eigSymmetricGeneralized(ga, gb)
    check("eigSymmetricGeneralized",
        (ga * ge.vectors.col(0)).approxEquals((gb * ge.vectors.col(0)) * ge.values[0], tol: 1e-9))
    // tridiagonal solve
    let tx = solveTridiagonal(Vector([-1.0, -1.0]), Vector([2.0, 2.0, 2.0]), Vector([-1.0, -1.0]), Vector([1.0, 0.0, 1.0]))
    check("solveTridiagonal", tx.size == 3)
    // matrix exponential of the zero matrix is the identity
    check("expm(0) == I", expm(Matrix.zeros(3, 3)).approxEquals(Matrix.identity(3), tol: 1e-12))

    section("runtime control")
    let before = getNumThreads()
    setNumThreads(1)
    check("setNumThreads", getNumThreads() == 1)
    setNumThreads(before)

    println("")
    if (failures > 0) {
        println("FAIL: ${failures} check(s) failed")
        return 1
    }
    println("OK — every API area verified")
    return 0
}

extend Matrix {
    /** Product of diagonal entries — tour-local helper for the diag demo. */
    func determinantLike(): Float64 {
        var p = 1.0
        for (i in 0..rows) {
            p *= data[i * cols + i]
        }
        p
    }
}
