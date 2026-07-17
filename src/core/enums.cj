/*
 * matcang.core - typed enums for BLAS/LAPACK options.
 *
 * These replace the opaque magic integers / single characters of the C API
 * with self-documenting values. Each knows how to lower itself to the CBLAS
 * enum constant or the LAPACK option character.
 */
package matcang.core

import matcang.Cblas

/** Whether (and how) a matrix operand is transposed. */
public enum Transpose {
    | NoTrans
    | Trans
    | ConjTrans

    public func toCblas(): Int32 {
        match (this) {
            case NoTrans => Cblas.NO_TRANS
            case Trans => Cblas.TRANS
            case ConjTrans => Cblas.CONJ_TRANS
        }
    }

    /** LAPACK single-character option ('N' / 'T' / 'C') as an Int8 code. */
    public func toChar(): Int8 {
        match (this) {
            case NoTrans => 78 // 'N'
            case Trans => 84 // 'T'
            case ConjTrans => 67 // 'C'
        }
    }
}

/** Which triangle (upper/lower) of a symmetric/triangular matrix is used. */
public enum Triangle {
    | Upper
    | Lower

    public func toCblas(): Int32 {
        match (this) {
            case Upper => Cblas.UPPER
            case Lower => Cblas.LOWER
        }
    }

    public func toChar(): Int8 {
        match (this) {
            case Upper => 85 // 'U'
            case Lower => 76 // 'L'
        }
    }
}

/** Side from which a matrix operand is applied. */
public enum Side {
    | Left
    | Right

    public func toCblas(): Int32 {
        match (this) {
            case Left => Cblas.LEFT
            case Right => Cblas.RIGHT
        }
    }

    public func toChar(): Int8 {
        match (this) {
            case Left => 76 // 'L'
            case Right => 82 // 'R'
        }
    }
}

/** Whether a triangular matrix has a unit (1) diagonal. */
public enum Diagonal {
    | NonUnit
    | UnitDiag

    public func toCblas(): Int32 {
        match (this) {
            case NonUnit => Cblas.NON_UNIT
            case UnitDiag => Cblas.UNIT
        }
    }

    public func toChar(): Int8 {
        match (this) {
            case NonUnit => 78 // 'N'
            case UnitDiag => 85 // 'U'
        }
    }
}
