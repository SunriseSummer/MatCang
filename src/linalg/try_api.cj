/*
 * matcang.linalg - non-throwing `try*` variants.
 *
 * Every routine whose failure is *data-dependent* — a singular matrix, a
 * non-positive-definite matrix, an iteration that fails to converge — has a
 * `try` twin here that returns `None` instead of throwing, for branch-style
 * call sites ("if invertible do X, otherwise fall back to Y"):
 *
 *     if (let Some(x) <- trySolve(a, b)) { ... } else { ... }
 *     let inv = tryInverse(a) ?? pinv(a)
 *
 * Deliberate split of the two failure classes:
 *   - data-dependent outcomes  -> `None`      (these wrappers)
 *   - contract violations       -> exception   (shape mismatch, non-square:
 *     those are caller bugs and still throw from the try* versions too)
 *
 * The throwing originals remain the primary API: they compose in expression
 * chains and carry precise diagnostics (which pivot, which leading minor).
 */
package matcang.linalg

import matcang.core.{Matrix, Vector, Complex, ComplexMatrix, ComplexVector, Transpose, Triangle, Diagonal, 
    SingularMatrixException, ConvergenceException}

/** `solve` returning `None` when the matrix is singular. */
public func trySolve(a: Matrix, b: Vector): ?Vector {
    try {
        return solve(a, b)
    } catch (_: SingularMatrixException) {
        return None
    }
}

/** `solveMatrix` returning `None` when the matrix is singular. */
public func trySolveMatrix(a: Matrix, b: Matrix): ?Matrix {
    try {
        return solveMatrix(a, b)
    } catch (_: SingularMatrixException) {
        return None
    }
}

/** `inverse` returning `None` when the matrix is singular. */
public func tryInverse(a: Matrix): ?Matrix {
    try {
        return inverse(a)
    } catch (_: SingularMatrixException) {
        return None
    }
}

/** `cholesky` returning `None` when the matrix is not positive definite. */
public func tryCholesky(a: Matrix, lower!: Bool = true): ?Matrix {
    try {
        return cholesky(a, lower: lower)
    } catch (_: SingularMatrixException) {
        return None
    }
}

/** `svd` returning `None` if the iteration fails to converge (rare). */
public func trySvd(a: Matrix): ?SVD {
    try {
        return svd(a)
    } catch (_: ConvergenceException) {
        return None
    }
}

/** `eigSymmetric` returning `None` if the iteration fails to converge. */
public func tryEigSymmetric(a: Matrix): ?EigenSym {
    try {
        return eigSymmetric(a)
    } catch (_: ConvergenceException) {
        return None
    }
}

/** `eigenvaluesSymmetric` returning `None` if the iteration fails to converge. */
public func tryEigenvaluesSymmetric(a: Matrix): ?Vector {
    try {
        return eigenvaluesSymmetric(a)
    } catch (_: ConvergenceException) {
        return None
    }
}

/** `eigenvalues` returning `None` if the QR iteration fails to converge. */
public func tryEigenvalues(a: Matrix): ?Array<Complex> {
    try {
        return eigenvalues(a)
    } catch (_: ConvergenceException) {
        return None
    }
}

/** `lstsq` returning `None` if the SVD iteration fails to converge. */
public func tryLstsq(a: Matrix, b: Vector): ?Vector {
    try {
        return lstsq(a, b)
    } catch (_: ConvergenceException) {
        return None
    }
}

/** `pinv` returning `None` if the underlying SVD fails to converge. */
public func tryPinv(a: Matrix): ?Matrix {
    try {
        return pinv(a)
    } catch (_: ConvergenceException) {
        return None
    }
}

/** `matrixRank` returning `None` if the underlying SVD fails to converge. */
public func tryMatrixRank(a: Matrix, tol!: Float64 = -1.0): ?Int64 {
    try {
        return matrixRank(a, tol: tol)
    } catch (_: ConvergenceException) {
        return None
    }
}

/** `cond` returning `None` if the underlying SVD fails to converge. */
public func tryCond(a: Matrix): ?Float64 {
    try {
        return cond(a)
    } catch (_: ConvergenceException) {
        return None
    }
}

/** `solveSPD` returning `None` when the matrix is not positive definite. */
public func trySolveSPD(a: Matrix, b: Vector): ?Vector {
    try {
        return solveSPD(a, b)
    } catch (_: SingularMatrixException) {
        return None
    }
}

/** `solveSPDMatrix` returning `None` when the matrix is not positive definite. */
public func trySolveSPDMatrix(a: Matrix, b: Matrix): ?Matrix {
    try {
        return solveSPDMatrix(a, b)
    } catch (_: SingularMatrixException) {
        return None
    }
}

/** `solveTriangular` returning `None` when a diagonal element is zero. */
public func trySolveTriangular(
    a: Matrix,
    b: Vector,
    uplo!: Triangle = Triangle.Lower,
    trans!: Transpose = Transpose.NoTrans,
    diag!: Diagonal = Diagonal.NonUnit
): ?Vector {
    try {
        return solveTriangular(a, b, uplo: uplo, trans: trans, diag: diag)
    } catch (_: SingularMatrixException) {
        return None
    }
}

/** `matrixPower` returning `None` when a negative power meets a singular matrix. */
public func tryMatrixPower(a: Matrix, k: Int64): ?Matrix {
    try {
        return matrixPower(a, k)
    } catch (_: SingularMatrixException) {
        return None
    }
}

// ---- complex twins ---------------------------------------------------------

/** Complex `solve` returning `None` when the matrix is singular. */
public func trySolve(a: ComplexMatrix, b: ComplexVector): ?ComplexVector {
    try {
        return solve(a, b)
    } catch (_: SingularMatrixException) {
        return None
    }
}

/** Complex `solveMatrix` returning `None` when the matrix is singular. */
public func trySolveMatrix(a: ComplexMatrix, b: ComplexMatrix): ?ComplexMatrix {
    try {
        return solveMatrix(a, b)
    } catch (_: SingularMatrixException) {
        return None
    }
}

/** Complex `inverse` returning `None` when the matrix is singular. */
public func tryInverse(a: ComplexMatrix): ?ComplexMatrix {
    try {
        return inverse(a)
    } catch (_: SingularMatrixException) {
        return None
    }
}

/** Complex `cholesky` returning `None` when not Hermitian positive definite. */
public func tryCholesky(a: ComplexMatrix, lower!: Bool = true): ?ComplexMatrix {
    try {
        return cholesky(a, lower: lower)
    } catch (_: SingularMatrixException) {
        return None
    }
}

/** Real `eigen` returning `None` if the QR iteration fails to converge. */
public func tryEigen(a: Matrix): ?ComplexEigen {
    try {
        return eigen(a)
    } catch (_: ConvergenceException) {
        return None
    }
}

/** Complex `eigen` returning `None` if the iteration fails to converge. */
public func tryEigen(a: ComplexMatrix): ?ComplexEigen {
    try {
        return eigen(a)
    } catch (_: ConvergenceException) {
        return None
    }
}

/** `eigHermitian` returning `None` if the iteration fails to converge. */
public func tryEigHermitian(a: ComplexMatrix): ?HermitianEigen {
    try {
        return eigHermitian(a)
    } catch (_: ConvergenceException) {
        return None
    }
}

/** `eigenvaluesHermitian` returning `None` if the iteration fails to converge. */
public func tryEigenvaluesHermitian(a: ComplexMatrix): ?Vector {
    try {
        return eigenvaluesHermitian(a)
    } catch (_: ConvergenceException) {
        return None
    }
}

/** Complex `svd` returning `None` if the iteration fails to converge (rare). */
public func trySvd(a: ComplexMatrix): ?ComplexSVD {
    try {
        return svd(a)
    } catch (_: ConvergenceException) {
        return None
    }
}

// ---- specialised-solver twins ----------------------------------------------

/** `solveTridiagonal` returning `None` when the system is singular. */
public func trySolveTridiagonal(dl: Vector, d: Vector, du: Vector, b: Vector): ?Vector {
    try {
        return solveTridiagonal(dl, d, du, b)
    } catch (_: SingularMatrixException) {
        return None
    }
}

/**
 * `eigSymmetricGeneralized` returning `None` when B is not positive definite
 * or the iteration fails to converge (both are data outcomes).
 */
public func tryEigSymmetricGeneralized(a: Matrix, b: Matrix): ?EigenSym {
    try {
        return eigSymmetricGeneralized(a, b)
    } catch (_: SingularMatrixException) {
        return None
    } catch (_: ConvergenceException) {
        return None
    }
}

/** `eigSymmetricTridiagonal` returning `None` if the iteration fails to converge. */
public func tryEigSymmetricTridiagonal(d: Vector, e: Vector): ?EigenSym {
    try {
        return eigSymmetricTridiagonal(d, e)
    } catch (_: ConvergenceException) {
        return None
    }
}

/** `schur` returning `None` if the QR iteration fails to converge. */
public func trySchur(a: Matrix): ?Schur {
    try {
        return schur(a)
    } catch (_: ConvergenceException) {
        return None
    }
}
