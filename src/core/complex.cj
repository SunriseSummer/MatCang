/*
 * matcang.core - a lightweight complex-number value type.
 *
 * `Complex` is an immutable struct (value semantics) with the usual field
 * operations. It mirrors the memory layout of the FFI CxF64 type, so complex
 * BLAS/LAPACK routines can be fed arrays of Complex directly.
 */
package matcang.core

import std.math.*

public struct Complex <: ToString & Equatable<Complex> {
    public let re: Float64
    public let im: Float64

    public init(re: Float64, im: Float64) {
        this.re = re
        this.im = im
    }

    /** Construct a purely real complex number. */
    public init(re: Float64) {
        this.re = re
        this.im = 0.0
    }

    public static func zero(): Complex {
        Complex(0.0, 0.0)
    }

    public static func one(): Complex {
        Complex(1.0, 0.0)
    }

    /** The imaginary unit i. */
    public static func i(): Complex {
        Complex(0.0, 1.0)
    }

    public operator func +(rhs: Complex): Complex {
        Complex(re + rhs.re, im + rhs.im)
    }

    public operator func -(rhs: Complex): Complex {
        Complex(re - rhs.re, im - rhs.im)
    }

    public operator func *(rhs: Complex): Complex {
        Complex(re * rhs.re - im * rhs.im, re * rhs.im + im * rhs.re)
    }

    /**
     * Complex division. Dividing by zero follows IEEE-754 semantics (the
     * NumPy convention): the result carries `Inf`/`NaN` components rather than
     * throwing, so it composes in numeric pipelines without special-casing.
     */
    public operator func /(rhs: Complex): Complex {
        let denom = rhs.re * rhs.re + rhs.im * rhs.im
        Complex((re * rhs.re + im * rhs.im) / denom, (im * rhs.re - re * rhs.im) / denom)
    }

    public operator func -(): Complex {
        Complex(-re, -im)
    }

    /** Complex conjugate. */
    public func conjugate(): Complex {
        Complex(re, -im)
    }

    /**
     * Modulus |z| = sqrt(re^2 + im^2), computed in scaled form so components
     * near Float64's range limits do not overflow/underflow in the squares
     * (the hypot algorithm).
     */
    public func abs(): Float64 {
        var ar = re
        if (ar < 0.0) {
            ar = -ar
        }
        var ai = im
        if (ai < 0.0) {
            ai = -ai
        }
        let hi = if (ar > ai) {
            ar
        } else {
            ai
        }
        if (hi == 0.0) {
            return 0.0
        }
        let lo = if (ar > ai) {
            ai
        } else {
            ar
        }
        let r = lo / hi
        hi * sqrt(1.0 + r * r)
    }

    /** Argument (phase angle) in radians. */
    public func arg(): Float64 {
        atan2(im, re)
    }

    public operator func ==(rhs: Complex): Bool {
        re == rhs.re && im == rhs.im
    }

    public operator func !=(rhs: Complex): Bool {
        !(this == rhs)
    }

    public func toString(): String {
        // Fixed 4-decimal rendering, matching Matrix/Vector pretty-printing.
        if (im >= 0.0) {
            "${formatFixed(re, 4)}+${formatFixed(im, 4)}i"
        } else {
            "${formatFixed(re, 4)}-${formatFixed(-im, 4)}i"
        }
    }
}
