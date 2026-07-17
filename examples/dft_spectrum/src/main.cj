/*
 * Discrete Fourier Transform as one complex matrix-vector product.
 *
 * The DFT is *literally* multiplication by the Fourier matrix F, where
 * F[j,k] = exp(-2 pi i j k / N). matcang's ComplexMatrix makes that the whole
 * algorithm: build F, multiply, read the spectrum. This example synthesises a
 * signal from two pure tones, recovers those frequencies from the magnitude
 * spectrum, and reconstructs the signal with the inverse DFT
 *   x = (1/N) F^H X
 * (F is symmetric, so F^H = conj(F) and F^H F = N I).
 *
 * It doubles as an end-to-end test: it exits non-zero unless the two dominant
 * spectral peaks land exactly on the injected frequencies AND the inverse DFT
 * reproduces the original samples to 1e-9.
 */
package dft_spectrum

import std.math.*
import matcang.core.{Complex, ComplexMatrix, ComplexVector, Vector}

/** N x N Fourier matrix F[j,k] = exp(-2 pi i j k / N). */
func fourierMatrix(n: Int64): ComplexMatrix {
    let f = ComplexMatrix(n, n)
    let twoPi = 2.0 * 3.141592653589793
    for (j in 0..n) {
        for (k in 0..n) {
            let angle = -twoPi * Float64(j) * Float64(k) / Float64(n)
            f[j, k] = Complex(cos(angle), sin(angle))
        }
    }
    f
}

main(): Int64 {
    let n = 64
    let f1 = 5 // first tone (cycles over the window)
    let f2 = 12 // second tone
    let twoPi = 2.0 * 3.141592653589793

    // real signal: cos at f1 plus half-amplitude cos at f2
    let sample = Array<Complex>(n, { k =>
        let t = Float64(k)
        Complex(cos(twoPi * Float64(f1) * t / Float64(n)) +
            0.5 * cos(twoPi * Float64(f2) * t / Float64(n)), 0.0)
    })
    let x = ComplexVector.of(sample)

    let f = fourierMatrix(n)
    let spectrum = f * x // the DFT

    // magnitude spectrum over the first half (real signal => symmetric)
    let mag = Vector(n)
    for (j in 0..n) {
        mag.data[j] = spectrum[j].abs()
    }

    // find the two dominant bins in [1, n/2)
    var top1 = 1
    var top2 = 2
    for (j in 1..(n / 2)) {
        if (mag.data[j] > mag.data[top1]) {
            top2 = top1
            top1 = j
        } else if (mag.data[j] > mag.data[top2] && j != top1) {
            top2 = j
        }
    }
    let peakLo = if (top1 < top2) {
        top1
    } else {
        top2
    }
    let peakHi = if (top1 < top2) {
        top2
    } else {
        top1
    }

    // inverse DFT: x_rec = (1/N) F^H X
    let recovered = (f.h * spectrum) * (1.0 / Float64(n))
    var reconErr = 0.0
    for (k in 0..n) {
        let d = recovered[k] - sample[k]
        let e = sqrt(d.re * d.re + d.im * d.im)
        if (e > reconErr) {
            reconErr = e
        }
    }

    println("DFT spectral analysis (N = ${n})")
    println("  injected tones       : ${f1}, ${f2}")
    println("  recovered peaks      : ${peakLo}, ${peakHi}")
    println("  peak magnitude @${f1}  : ${mag.data[f1]}")
    println("  peak magnitude @${f2}  : ${mag.data[f2]}")
    println("  inverse-DFT max error: ${reconErr}")

    if (peakLo != f1 || peakHi != f2) {
        println("FAIL: dominant frequencies not recovered")
        return 1
    }
    if (reconErr > 1e-9) {
        println("FAIL: inverse DFT did not reconstruct the signal")
        return 1
    }
    // the f1 tone (amplitude 1) must dominate the f2 tone (amplitude 0.5)
    if (mag.data[f1] <= mag.data[f2]) {
        println("FAIL: amplitude ordering wrong")
        return 1
    }
    println("OK")
    return 0
}
