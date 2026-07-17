/*
 * A spin-1/2 in a magnetic field — the smallest quantum system, solved with
 * Hermitian eigen-decomposition.
 *
 * The Hamiltonian is  H = (E/2) (n_x sigma_x + n_y sigma_y + n_z sigma_z),
 * where the sigmas are the Pauli matrices and n is a unit vector along the
 * field. H is Hermitian, so `eigHermitian` returns REAL energies and complex
 * eigenstates. Physics says the energies must be exactly +/- E/2 and the two
 * eigenstates are spin aligned / anti-aligned with the field.
 *
 * Self-checks (non-zero exit on failure):
 *   1. energies are -E/2 and +E/2;
 *   2. eigenstates are orthonormal under the Hermitian inner product;
 *   3. H |psi> = energy |psi>;
 *   4. <psi| (n . sigma) |psi> = -1 (ground) / +1 (excited): the spin is
 *      perfectly (anti)aligned with the field.
 */
package quantum_spin

import std.math.*
import matcang.core.{Complex, ComplexMatrix, ComplexVector}
import matcang.linalg.eigHermitian

// Pauli matrices
func sigmaX(): ComplexMatrix {
    ComplexMatrix([[Complex(0.0, 0.0), Complex(1.0, 0.0)], [Complex(1.0, 0.0), Complex(0.0, 0.0)]])
}

func sigmaY(): ComplexMatrix {
    ComplexMatrix([[Complex(0.0, 0.0), Complex(0.0, -1.0)], [Complex(0.0, 1.0), Complex(0.0, 0.0)]])
}

func sigmaZ(): ComplexMatrix {
    ComplexMatrix([[Complex(1.0, 0.0), Complex(0.0, 0.0)], [Complex(0.0, 0.0), Complex(-1.0, 0.0)]])
}

main(): Int64 {
    let energy = 3.0
    // field direction (normalised)
    var nx = 1.0
    var ny = 2.0
    var nz = 2.0
    let len = sqrt(nx * nx + ny * ny + nz * nz)
    nx /= len
    ny /= len
    nz /= len

    // n . sigma
    let nDotSigma = sigmaX() * Complex(nx, 0.0) + sigmaY() * Complex(ny, 0.0) + sigmaZ() * Complex(nz, 0.0)
    let h = nDotSigma * Complex(energy / 2.0, 0.0)

    let e = eigHermitian(h)
    let energies = e.values
    let states = e.vectors

    // expectation of (n . sigma) in each eigenstate
    let ground = states.col(0)
    let excited = states.col(1)
    let expGround = ground.dotc(nDotSigma * ground)
    let expExcited = excited.dotc(nDotSigma * excited)

    println("Spin-1/2 in a field (E = ${energy})")
    println("  field direction      : (${nx}, ${ny}, ${nz})")
    println("  energies             : ${energies[0]}, ${energies[1]}")
    println("  <n.sigma> ground     : ${expGround}")
    println("  <n.sigma> excited    : ${expExcited}")

    // (1) energies are -E/2, +E/2
    if (abs(energies[0] + energy / 2.0) > 1e-9 || abs(energies[1] - energy / 2.0) > 1e-9) {
        println("FAIL: energies are not +/- E/2")
        return 1
    }
    // (2) orthonormal eigenstates (Hermitian inner product)
    let norm0 = ground.dotc(ground)
    let cross = ground.dotc(excited)
    if (abs(norm0.re - 1.0) > 1e-9 || abs(norm0.im) > 1e-9) {
        println("FAIL: ground state not normalised")
        return 1
    }
    if (cross.abs() > 1e-9) {
        println("FAIL: eigenstates not orthogonal")
        return 1
    }
    // (3) H |psi> = E |psi>
    let resid = (h * ground) - (ground * Complex(energies[0], 0.0))
    if (resid.norm() > 1e-9) {
        println("FAIL: eigenvalue equation not satisfied")
        return 1
    }
    // (4) spin (anti)aligned with the field: <n.sigma> = -1 / +1
    if (abs(expGround.re + 1.0) > 1e-9 || abs(expExcited.re - 1.0) > 1e-9) {
        println("FAIL: spin not aligned with field")
        return 1
    }
    println("OK")
    return 0
}
