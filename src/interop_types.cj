/*
 * Shared C-interop types and constants for the OpenBLAS API.
 *
 *   - CxF32 / CxF64 model C99 `float _Complex` / `double _Complex` by value
 *     (two contiguous components, real then imaginary). On the x86-64 SysV
 *     ABI a `struct { float re, im; }` is passed/returned identically to the
 *     native complex type, so these are safe drop-in mappings.
 *   - The Cblas* / Lapack* constants mirror the C enum values in cblas.h.
 *
 * Part of the root `matcang` package (hand-written; the ffi_*.cj / *_binding.cj
 * files are generated).
 */
package matcang

@C
public struct CxF32 {
    public var re: Float32 = 0.0
    public var im: Float32 = 0.0
    public init() {}
    public init(re: Float32, im: Float32) {
        this.re = re
        this.im = im
    }
}

@C
public struct CxF64 {
    public var re: Float64 = 0.0
    public var im: Float64 = 0.0
    public init() {}
    public init(re: Float64, im: Float64) {
        this.re = re
        this.im = im
    }
}

/**
 * CBLAS enum values (see cblas.h), grouped under one type so call sites read
 * as `Cblas.ROW_MAJOR`, `Cblas.NO_TRANS`, ...
 */
public struct Cblas {
    public static const ROW_MAJOR: Int32 = 101
    public static const COL_MAJOR: Int32 = 102

    public static const NO_TRANS: Int32 = 111
    public static const TRANS: Int32 = 112
    public static const CONJ_TRANS: Int32 = 113
    public static const CONJ_NO_TRANS: Int32 = 114

    public static const UPPER: Int32 = 121
    public static const LOWER: Int32 = 122

    public static const NON_UNIT: Int32 = 131
    public static const UNIT: Int32 = 132

    public static const LEFT: Int32 = 141
    public static const RIGHT: Int32 = 142
}

/** LAPACKE matrix_layout values (see lapacke.h). */
public struct Lapack {
    public static const ROW_MAJOR: Int32 = 101
    public static const COL_MAJOR: Int32 = 102
}
