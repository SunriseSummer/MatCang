/*
 * matcang.core - exception hierarchy.
 *
 * All library-specific failures derive from MatCangException so callers can
 * catch the whole family with a single handler, or narrow to a specific case.
 */
package matcang.core

public open class MatCangException <: Exception {
    public init() {
        super()
    }
    public init(message: String) {
        super(message)
    }
}

/** Raised when operand shapes are incompatible for an operation. */
public class DimensionMismatchException <: MatCangException {
    public init(message: String) {
        super(message)
    }
}

/** Raised when a square matrix is required but a non-square one was given. */
public class NonSquareMatrixException <: MatCangException {
    public init(message: String) {
        super(message)
    }
}

/** Raised when a matrix is singular (or numerically so) for the requested op. */
public class SingularMatrixException <: MatCangException {
    public init(message: String) {
        super(message)
    }
}

/** Raised when an iterative/decomposition routine fails to converge. */
public class ConvergenceException <: MatCangException {
    public init(message: String) {
        super(message)
    }
}

/** Raised when a LAPACK/BLAS routine reports an invalid argument (info < 0). */
public class BlasArgumentException <: MatCangException {
    public init(message: String) {
        super(message)
    }
}
