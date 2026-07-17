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
import matcang.blas.gemmInto
import matcang.linalg.{solve, cholesky, svd, eigSymmetric}
import matcang.{dgemm, Cblas, getConfig, getNumThreads}
import matcang.core.Vector

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

    println("")
    if (!parityOk) {
        println("RESULT: FAIL (parity regression)")
        return 1
    }
    println("RESULT: OK")
    return 0
}
