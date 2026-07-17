/*
 * Finite element method — the 1-D Poisson problem
 *
 *     -u''(x) = f(x)  on (0, 1),   u(0) = u(1) = 0.
 *
 * We discretise with piecewise-linear (P1) elements, assemble the global
 * stiffness matrix element by element and solve the resulting linear system
 * with matcang's LAPACK-backed `solve`. With f(x) = pi^2 sin(pi x) the exact
 * solution is u(x) = sin(pi x), so we can measure the true discretisation
 * error and confirm the expected O(h^2) convergence.
 *
 * End-to-end test: fails unless the FEM solution matches the analytic one to a
 * tight tolerance and the error shrinks by ~4x when the mesh is halved.
 */
package finite_element

import std.math.*
import matcang.core.{Matrix, Vector}
import matcang.linalg.solve

let PI: Float64 = 3.14159265358979323846

func source(x: Float64): Float64 {
    PI * PI * sin(PI * x)
}

func exact(x: Float64): Float64 {
    sin(PI * x)
}

/**
 * Solve the problem on a uniform mesh of `nElem` elements and return the
 * maximum nodal error against the analytic solution.
 */
func solvePoisson(nElem: Int64): Float64 {
    let h = 1.0 / Float64(nElem)
    let nInterior = nElem - 1 // interior nodes are the unknowns (Dirichlet BCs)

    // assemble global stiffness K and load b over interior nodes
    let k = Matrix(nInterior, nInterior)
    let b = Vector(nInterior)
    let localStiffness = 1.0 / h // each element contributes (1/h)[[1,-1],[-1,1]]

    for (e in 0..nElem) {
        // element e connects global nodes e and e+1; keep only interior dofs
        let left = e - 1 // interior index of node e   (-1 if on boundary)
        let right = e // interior index of node e+1 (== nInterior if boundary)
        if (left >= 0 && left < nInterior) {
            k[left, left] = k[left, left] + localStiffness
        }
        if (right >= 0 && right < nInterior) {
            k[right, right] = k[right, right] + localStiffness
        }
        if (left >= 0 && left < nInterior && right >= 0 && right < nInterior) {
            k[left, right] = k[left, right] - localStiffness
            k[right, left] = k[right, left] - localStiffness
        }
    }

    // lumped load vector: b_i = h * f(x_i)
    for (i in 0..nInterior) {
        let x = Float64(i + 1) * h
        b[i] = h * source(x)
    }

    let u = solve(k, b)

    var maxErr = 0.0
    for (i in 0..nInterior) {
        let x = Float64(i + 1) * h
        let err = abs(u[i] - exact(x))
        if (err > maxErr) {
            maxErr = err
        }
    }
    maxErr
}

main(): Int64 {
    let coarse = solvePoisson(20)
    let fine = solvePoisson(40)
    let finer = solvePoisson(80)

    println("Finite element method — 1D Poisson  -u'' = pi^2 sin(pi x)")
    println("  mesh  20 elements: max error = ${coarse}")
    println("  mesh  40 elements: max error = ${fine}")
    println("  mesh  80 elements: max error = ${finer}")
    println("  refinement ratio (coarse/fine)  : ${coarse / fine}")
    println("  refinement ratio (fine/finer)   : ${fine / finer}")

    // O(h^2): halving h should cut the error by roughly 4.
    if (finer > 1e-3) {
        println("FAIL: solution not accurate enough")
        return 1
    }
    if (coarse / fine < 3.0 || fine / finer < 3.0) {
        println("FAIL: convergence slower than expected")
        return 1
    }
    println("OK")
    return 0
}
