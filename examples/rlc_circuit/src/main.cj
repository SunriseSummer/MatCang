/*
 * AC steady-state circuit analysis with complex phasors.
 *
 * In the phasor domain every element is a complex impedance
 *   Z_R = R,   Z_L = j w L,   Z_C = 1 / (j w C)
 * and mesh analysis becomes one complex linear system  Z I = V  for the mesh
 * currents. matcang solves it directly with the complex `solve`.
 *
 * Two-mesh circuit: a source Vs drives R1 into a shared coupling resistor Rc
 * (mesh 1); mesh 2 is a series R2-L-C loop closed through Rc. Because the
 * meshes couple through a (frequency-flat) resistor, mesh 2 keeps its clean
 * series resonance at w0 = 1/sqrt(L C).
 *
 * Self-checks (exits non-zero on any failure):
 *   1. Conservation of real power: Re(Vs * conj(I1)) = R1|I1|^2 + (Rc)... etc,
 *      checked as source real power = total resistive dissipation.
 *   2. matcang's complex `solve` agrees with an independent Cramer's-rule
 *      solution of the 2x2 system (a direct correctness check of the solver).
 *   3. A frequency sweep peaks in |I2| exactly at w0 = 1/sqrt(L C).
 */
package rlc_circuit

import std.math.*
import matcang.core.{Complex, ComplexMatrix, ComplexVector}
import matcang.linalg.solve

let R1 = 10.0
let RC = 20.0 // shared coupling resistor
let R2 = 2.0 // series loss in mesh 2 (small => sharp resonance)
let L = 1.0e-3 // 1 mH
let C = 1.0e-6 // 1 uF
let VS = 5.0 // source amplitude (real reference phasor)

/** Mesh-impedance matrix at angular frequency w. */
func meshZ(w: Float64): ComplexMatrix {
    let zL = Complex(0.0, w * L) // j w L
    let zC = Complex(0.0, -1.0 / (w * C)) // 1/(j w C) = -j/(w C)
    let z11 = Complex(R1 + RC, 0.0)
    let z12 = Complex(-RC, 0.0)
    let z22 = Complex(RC + R2, 0.0) + zL + zC
    ComplexMatrix([[z11, z12], [z12, z22]])
}

/** Solve for mesh currents at frequency w. */
func meshCurrents(w: Float64): ComplexVector {
    let v = ComplexVector.of([Complex(VS, 0.0), Complex(0.0, 0.0)])
    solve(meshZ(w), v)
}

/** Independent 2x2 solve by Cramer's rule, in scalar complex arithmetic. */
func cramerCurrents(w: Float64): (Complex, Complex) {
    let z = meshZ(w)
    let z11 = z[0, 0]
    let z12 = z[0, 1]
    let z21 = z[1, 0]
    let z22 = z[1, 1]
    let vs = Complex(VS, 0.0)
    let det = z11 * z22 - z12 * z21
    let i1 = (vs * z22) / det // V2 = 0
    let i2 = (-(z21 * vs)) / det
    (i1, i2)
}

main(): Int64 {
    let w0 = 1.0 / sqrt(L * C) // series resonance of mesh 2

    // ---- (1) real-power balance at an off-resonance drive frequency ----
    let w = 0.5 * w0
    let i = meshCurrents(w)
    let i1 = i[0]
    let i2 = i[1]
    let pSource = (Complex(VS, 0.0) * i1.conjugate()).re
    // resistive dissipation: R1 carries I1, shared Rc carries I1-I2, R2 carries I2
    let diff = i1 - i2
    let pDiss = R1 * (i1.abs() * i1.abs()) + RC * (diff.abs() * diff.abs()) + R2 * (i2.abs() * i2.abs())

    // ---- (2) independent Cramer's-rule cross-check of the solver ----
    let (ci1, ci2) = cramerCurrents(w)
    let solveErr = (i1 - ci1).abs() + (i2 - ci2).abs()

    // ---- (3) frequency sweep: |I2| peaks at the series resonance w0 ----
    var bestW = 0.0
    var bestMag = -1.0
    let steps = 6000
    let wLo = 0.3 * w0
    let wHi = 3.0 * w0
    for (kk in 0..(steps + 1)) {
        let wk = wLo + (wHi - wLo) * Float64(kk) / Float64(steps)
        let m = meshCurrents(wk)[1].abs()
        if (m > bestMag) {
            bestMag = m
            bestW = wk
        }
    }

    println("RLC AC analysis (R1=${R1}, Rc=${RC}, R2=${R2}, L=${L}, C=${C})")
    println("  drive w              : ${w} rad/s")
    println("  mesh currents        : I1=${i1}, I2=${i2}")
    println("  source real power    : ${pSource} W")
    println("  dissipated power     : ${pDiss} W")
    println("  solve vs Cramer error: ${solveErr}")
    println("  analytic resonance w0: ${w0} rad/s")
    println("  swept peak |I2| at w : ${bestW} rad/s  (|I2|=${bestMag})")

    if (abs(pSource - pDiss) > 1e-9 * (abs(pSource) + 1.0)) {
        println("FAIL: real power not conserved")
        return 1
    }
    if (solveErr > 1e-9) {
        println("FAIL: complex solve disagrees with Cramer's rule")
        return 1
    }
    if (abs(bestW - w0) / w0 > 0.01) {
        println("FAIL: resonance peak misplaced")
        return 1
    }
    println("OK")
    return 0
}
