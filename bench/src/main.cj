/*
 * matcang benchmark suites.
 *
 * Run with `cjpm run` from bench/. Prints median timings and throughput for the
 * library's hot paths, and enforces one regression gate: the in-place wrapper
 * (gemmInto) must stay within 1.25x of a direct cblas_dgemm call — the
 * "no meaningful overhead over C" guarantee. Exits non-zero if that fails, so
 * the suite doubles as a performance test in CI.
 *
 * Suites:
 *   parity      raw dgemm vs gemmInto vs allocating a*b (768^2)
 *   gemm        dgemm scaling across sizes
 *   gemv        matrix-vector throughput
 *   elementwise BLAS-backed add/scale vs per-element closure baseline
 *   transpose   domatcopy-backed transpose vs naive loop baseline
 *   factor      solve / cholesky / svd / eigSymmetric wall times
 */
package bench

import std.math.abs
import matcang.core.Matrix
import matcang.blas.{gemmInto, gemm}
import matcang.linalg.{solve, cholesky, svd, eigSymmetric, eigHermitian, eigen, expm, eigSymmetricGeneralized, qr, schur
    }
import matcang.{dgemm, zgemm, CxF64, Cblas, getConfig, getNumThreads}
import matcang.core.{Vector, Complex, ComplexMatrix, ComplexVector}

/** Direct BLAS dgemm into `out` — the C baseline every wrapper is held to. */
func rawGemm(a: Matrix, b: Matrix, out: Matrix): Unit {
    let n = a.rows
    unsafe {
        let ha = acquireArrayRawData(a.data)
        let hb = acquireArrayRawData(b.data)
        let hc = acquireArrayRawData(out.data)
        dgemm(Cblas.ROW_MAJOR, Cblas.NO_TRANS, Cblas.NO_TRANS, Int32(n), Int32(n), Int32(n), 1.0, ha.pointer, Int32(n),
            hb.pointer, Int32(n), 0.0, hc.pointer, Int32(n))
        releaseArrayRawData(hc)
        releaseArrayRawData(hb)
        releaseArrayRawData(ha)
    }
}

/** Regression gate: wrapper parity with raw BLAS. Returns true when it holds. */
func paritySuite(): Bool {
    let n = 768
    let a = Matrix.randomNormal(n, n, seed: 1)
    let b = Matrix.randomNormal(n, n, seed: 2)
    let out = Matrix(n, n)

    let raw = measure {=> rawGemm(a, b, out)}
    let inplace = measure {=> gemmInto(a, b, out)}
    let alloc = measure {
        =>
            let _ = a * b
            ()
    }

    printHeader("parity — dgemm ${n}x${n} (gate: gemmInto <= 1.25x raw)")
    printRow("raw cblas_dgemm", raw, gflops: gemmFlops(n) / raw / 1.0e9)
    printRow("matcang gemmInto (in-place)", inplace, gflops: gemmFlops(n) / inplace / 1.0e9)
    printRow("matcang a * b (allocating)", alloc, gflops: gemmFlops(n) / alloc / 1.0e9)
    println("  wrapper overhead: ${trim((inplace / raw - 1.0) * 100.0)}%")

    // correctness alongside speed: the two paths must agree
    let c = a * b
    var maxErr = 0.0
    for (i in 0..c.data.size) {
        let d = abs(c.data[i] - out.data[i])
        if (d > maxErr) {
            maxErr = d
        }
    }
    if (maxErr > 1e-9) {
        println("  PARITY FAIL: results disagree (max diff ${maxErr})")
        return false
    }
    if (inplace > raw * 1.25) {
        println("  PARITY FAIL: gemmInto exceeded 1.25x of raw BLAS")
        return false
    }
    println("  parity: OK")
    true
}

func gemmSuite(): Unit {
    printHeader("gemm scaling (a * b)")
    for (n in [128, 256, 512]) {
        let a = Matrix.randomNormal(n, n, seed: 3)
        let b = Matrix.randomNormal(n, n, seed: 4)
        let t = measure {
            =>
                let _ = a * b
                ()
        }
        printRow("dgemm ${n}x${n}", t, gflops: gemmFlops(n) / t / 1.0e9)
    }
}

func gemvSuite(): Unit {
    printHeader("gemv (a * x)")
    let n = 2048
    let a = Matrix.randomNormal(n, n, seed: 5)
    let x = Vector.random(n, seed: 6)
    let t = measure {
        =>
            let _ = a * x
            ()
    }
    printRow("dgemv ${n}x${n}", t, gflops: gemvFlops(n, n) / t / 1.0e9)
}

func elementwiseSuite(): Unit {
    printHeader("element-wise ops, 4M elements (BLAS kernels vs closure loop)")
    let a = Matrix.randomNormal(2000, 2000, seed: 7)
    let b = Matrix.randomNormal(2000, 2000, seed: 8)

    let blasAdd = measure {
        =>
            let _ = a + b
            ()
    }
    let loopAdd = measure {
        =>
            let _ = a.zipWith(b) {x, y => x + y}
            ()
    }
    printRow("a + b (daxpy path)", blasAdd)
    printRow("zipWith closure baseline", loopAdd)
    println("  speedup: ${trim(loopAdd / blasAdd)}x")

    let blasScale = measure {
        =>
            let _ = a * 2.0
            ()
    }
    let loopScale = measure {
        =>
            let _ = a.map {x => x * 2.0}
            ()
    }
    printRow("a * 2.0 (dscal path)", blasScale)
    printRow("map closure baseline", loopScale)
    println("  speedup: ${trim(loopScale / blasScale)}x")
}

func transposeSuite(): Unit {
    printHeader("transpose 2048x2048 (domatcopy vs naive loop)")
    let n = 2048
    let a = Matrix.randomNormal(n, n, seed: 9)

    let fast = measure {
        =>
            let _ = a.t
            ()
    }
    let naive = measure {
        =>
            let out = Matrix(n, n)
            for (i in 0..n) {
                for (j in 0..n) {
                    out.data[j * n + i] = a.data[i * n + j]
                }
            }
            ()
    }
    printRow("a.t (domatcopy)", fast)
    printRow("naive double loop", naive)
    println("  speedup: ${trim(naive / fast)}x")
}

func factorSuite(): Unit {
    printHeader("factorisations / solvers")
    let n = 512
    let g = Matrix.randomNormal(n, n, seed: 10)
    let spd = g.t * g + Matrix.identity(n) * Float64(n)
    let b = Vector.random(n, seed: 11)

    let tSolve = measure(reps: 5) {
        =>
            let _ = solve(g, b)
            ()
    }
    printRow("solve ${n}x${n} (dgesv)", tSolve)

    let tChol = measure(reps: 5) {
        =>
            let _ = cholesky(spd)
            ()
    }
    printRow("cholesky ${n}x${n} (dpotrf)", tChol)

    let m = Matrix.randomNormal(256, 256, seed: 12)
    let tSvd = measure(reps: 5) {
        =>
            let _ = svd(m)
            ()
    }
    printRow("svd 256x256 (dgesdd)", tSvd)

    let sym = (m + m.t) * 0.5
    let tEig = measure(reps: 5) {
        =>
            let _ = eigSymmetric(sym)
            ()
    }
    printRow("eigSymmetric 256x256 (dsyev)", tEig)
}

/** Random complex matrix built from two real random matrices. */
func randomComplex(rows: Int64, cols: Int64, s1: UInt64, s2: UInt64): ComplexMatrix {
    ComplexMatrix.fromParts(Matrix.randomNormal(rows, cols, seed: s1), Matrix.randomNormal(rows, cols, seed: s2))
}

/** Flop count of an n x n x n complex dense multiply (8 real flops per madd). */
func gemmFlopsComplex(n: Int64): Float64 {
    8.0 * Float64(n) * Float64(n) * Float64(n)
}

/** Direct BLAS zgemm into `out` — the C baseline for the complex wrappers. */
func rawZgemm(a: ComplexMatrix, b: ComplexMatrix, out: ComplexMatrix): Unit {
    let n = a.rows
    let alpha = Array<CxF64>(1, repeat: CxF64(1.0, 0.0))
    let beta = Array<CxF64>(1, repeat: CxF64(0.0, 0.0))
    unsafe {
        let ha = acquireArrayRawData(a.data)
        let hb = acquireArrayRawData(b.data)
        let hc = acquireArrayRawData(out.data)
        let hal = acquireArrayRawData(alpha)
        let hbe = acquireArrayRawData(beta)
        zgemm(Cblas.ROW_MAJOR, Cblas.NO_TRANS, Cblas.NO_TRANS, Int32(n), Int32(n), Int32(n), hal.pointer, ha.pointer,
            Int32(n), hb.pointer, Int32(n), hbe.pointer, hc.pointer, Int32(n))
        releaseArrayRawData(hbe)
        releaseArrayRawData(hal)
        releaseArrayRawData(hc)
        releaseArrayRawData(hb)
        releaseArrayRawData(ha)
    }
}

func complexSuite(): Bool {
    printHeader("complex linear algebra (z-precision, gate: gemmInto <= 1.25x raw)")
    let n = 512
    let a = randomComplex(n, n, 21, 22)
    let b = randomComplex(n, n, 23, 24)
    let out = ComplexMatrix(n, n)

    // complex wrapper parity: raw zgemm vs allocation-free gemmInto vs a * b
    let raw = measure {=> rawZgemm(a, b, out)}
    let inplace = measure {=> gemmInto(a, b, out)}
    let tMul = measure {
        =>
            let _ = a * b
            ()
    }
    printRow("raw cblas_zgemm ${n}x${n}", raw, gflops: gemmFlopsComplex(n) / raw / 1.0e9)
    printRow("matcang gemmInto (in-place)", inplace, gflops: gemmFlopsComplex(n) / inplace / 1.0e9)
    printRow("matcang a * b (allocating)", tMul, gflops: gemmFlopsComplex(n) / tMul / 1.0e9)
    println("  wrapper overhead: ${trim((inplace / raw - 1.0) * 100.0)}%")
    if (inplace > raw * 1.25) {
        println("  COMPLEX PARITY FAIL: gemmInto exceeded 1.25x of raw zgemm")
        return false
    }

    // correctness alongside speed: gemmInto agrees with the operator...
    let viaOp = a * b
    if (!viaOp.approxEquals(out, tol: 1e-6)) {
        println("  COMPLEX FAIL: gemmInto and a * b disagree")
        return false
    }
    // ...and (A B)^H = B^H A^H
    let lhs = viaOp.h
    let rhs = b.h * a.h
    if (!lhs.approxEquals(rhs, tol: 1e-6)) {
        println("  COMPLEX FAIL: (AB)^H != B^H A^H")
        return false
    }

    let rhsVec = ComplexVector.fromReal(Vector.random(n, seed: 25))
    let tSolve = measure(reps: 5) {
        =>
            let _ = solve(a, rhsVec)
            ()
    }
    printRow("zgesv solve ${n}x${n}", tSolve)

    // Hermitian eig and complex svd on a moderate size
    let herm = a * a.h // Hermitian, positive semidefinite
    let m = 256
    let hm = randomComplex(m, m, 26, 27)
    let hHerm = hm * hm.h
    let tEig = measure(reps: 3) {
        =>
            let _ = eigHermitian(hHerm)
            ()
    }
    printRow("zheev eigHermitian ${m}x${m}", tEig)

    let tSvd = measure(reps: 3) {
        =>
            let _ = svd(hm)
            ()
    }
    printRow("zgesdd svd ${m}x${m}", tSvd)

    let hpd = hHerm + ComplexMatrix.identity(m) * Float64(m) // Hermitian PD
    let tChol = measure(reps: 3) {
        =>
            let _ = cholesky(hpd)
            ()
    }
    printRow("zpotrf cholesky ${m}x${m}", tChol)

    let tQr = measure(reps: 3) {
        =>
            let _ = qr(hm)
            ()
    }
    printRow("zgeqrf+zungqr qr ${m}x${m}", tQr)
    println("  complex: OK")
    true
}

func advancedSuite(): Unit {
    printHeader("advanced double solvers")
    let n = 256
    let g = Matrix.randomNormal(n, n, seed: 31)
    let sym = (g + g.t) * 0.5
    let spd = g.t * g + Matrix.identity(n) * Float64(n)

    let tGen = measure(reps: 3) {
        =>
            let _ = eigSymmetricGeneralized(sym, spd)
            ()
    }
    printRow("dsygvd generalized eig ${n}x${n}", tGen)

    let small = Matrix.randomNormal(64, 64, seed: 32)
    let tExp = measure(reps: 3) {
        =>
            let _ = expm(small)
            ()
    }
    printRow("expm 64x64 (Pade + squaring)", tExp)

    let tEigen = measure(reps: 3) {
        =>
            let _ = eigen(small)
            ()
    }
    printRow("dgeev eigen+vectors 64x64", tEigen)

    let tSchur = measure(reps: 3) {
        =>
            let _ = schur(g)
            ()
    }
    printRow("dgees schur ${n}x${n}", tSchur)
}

main(): Int64 {
    println("matcang benchmarks")
    println("  backend : ${getConfig()}")
    println("  threads : ${getNumThreads()}")

    let parityOk = paritySuite()
    gemmSuite()
    gemvSuite()
    elementwiseSuite()
    transposeSuite()
    factorSuite()
    let complexOk = complexSuite()
    advancedSuite()

    println("")
    if (!parityOk) {
        println("RESULT: FAIL (parity regression)")
        return 1
    }
    if (!complexOk) {
        println("RESULT: FAIL (complex correctness)")
        return 1
    }
    println("RESULT: OK")
    return 0
}
