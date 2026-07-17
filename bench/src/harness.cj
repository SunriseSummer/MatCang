/*
 * bench - a small, reusable measurement harness.
 *
 * Median-of-N timing with warmup, aligned table output, and GFLOP/s helpers.
 * Kept deliberately dependency-free so suites read as plain declarations:
 *
 *     let t = measure(reps: 9) { ... }        // median seconds
 *     printRow("dgemm 512", t, gflops: gemmFlops(512) / t)
 */
package bench

import std.time.MonoTime

/** Median wall-clock seconds over `reps` runs (after `warmup` untimed runs). */
public func measure(reps!: Int64 = 9, warmup!: Int64 = 2, body!: () -> Unit): Float64 {
    for (_ in 0..warmup) {
        body()
    }
    let samples = Array<Int64>(reps, repeat: 0)
    for (r in 0..reps) {
        let t0 = MonoTime.now()
        body()
        samples[r] = (MonoTime.now() - t0).toNanoseconds()
    }
    Float64(median(samples)) / 1.0e9
}

/** Median of an Int64 sample (insertion sort; samples are tiny). */
func median(samples: Array<Int64>): Int64 {
    let sorted = samples.clone()
    for (i in 1..sorted.size) {
        let key = sorted[i]
        var j = i - 1
        while (j >= 0 && sorted[j] > key) {
            sorted[j + 1] = sorted[j]
            j -= 1
        }
        sorted[j + 1] = key
    }
    sorted[sorted.size / 2]
}

/** Flop count of an n x n x n dense multiply. */
public func gemmFlops(n: Int64): Float64 {
    2.0 * Float64(n) * Float64(n) * Float64(n)
}

/** Flop count of an m x n matrix-vector multiply. */
public func gemvFlops(m: Int64, n: Int64): Float64 {
    2.0 * Float64(m) * Float64(n)
}

// ---- table output ----------------------------------------------------------

public func printHeader(title: String): Unit {
    println("")
    println("== ${title} ==")
    println("  ${pad("case", 34)} ${pad("median", 12)} ${pad("throughput", 14)}")
}

/** One aligned result row; pass gflops < 0.0 to omit the throughput column. */
public func printRow(name: String, seconds: Float64, gflops!: Float64 = -1.0): Unit {
    let ms = formatMs(seconds)
    let thr = if (gflops >= 0.0) {
        "${trim(gflops)} GFLOP/s"
    } else {
        "-"
    }
    println("  ${pad(name, 34)} ${pad(ms, 12)} ${pad(thr, 14)}")
}

func formatMs(seconds: Float64): String {
    "${trim(seconds * 1000.0)} ms"
}

/** Fixed 3-decimal rendering, enough for a benchmark table. */
func trim(x: Float64): String {
    var v = x
    var sign = ""
    if (v < 0.0) {
        sign = "-"
        v = -v
    }
    let scaled = Int64(v * 1000.0 + 0.5)
    let whole = scaled / 1000
    var frac = "${scaled % 1000}"
    while (frac.size < 3) {
        frac = "0" + frac
    }
    "${sign}${whole}.${frac}"
}

func pad(s: String, width: Int64): String {
    var out = s
    while (out.size < width) {
        out = out + " "
    }
    out
}
