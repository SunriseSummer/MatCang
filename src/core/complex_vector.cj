/*
 * matcang.core - dense 1-D vector of complex numbers.
 *
 * ComplexVector stores its entries as a contiguous Array<CxF64> - the same
 * interleaved (real, imag) layout LAPACK/CBLAS expect - so buffers cross the
 * FFI boundary zero-copy via acquireArrayRawData, exactly like the real Vector.
 * The element API speaks in the ergonomic `Complex` value type; conversion at
 * the boundary is a trivial field copy.
 *
 * Level-1 complex BLAS backs the hot paths: zaxpy (+/-), zscal/zdscal (scaling),
 * zdotu_sub/zdotc_sub (the two inner products) and dznrm2/dzasum (norms). The
 * *_sub dot variants are used deliberately - they return through an output
 * pointer, sidestepping the by-value complex-return ABI mismatch that plagues
 * cblas_zdotu across platforms.
 */
package matcang.core

import matcang.{zaxpy, zscal, zdscal, zcopy, zdotu_sub, zdotc_sub, dznrm2, dzasum, CxF64}
import std.math.*

public class ComplexVector <: ToString {
    public let data: Array<CxF64> // interleaved re/im, length = size

    public init(data: Array<CxF64>) {
        this.data = data
    }

    /** A zero vector of the given length. */
    public init(size: Int64) {
        if (size < 0) {
            throw MatCangException("complex vector size must be non-negative, got ${size}")
        }
        this.data = Array<CxF64>(size, repeat: CxF64(0.0, 0.0))
    }

    /** Build from an array of `Complex` values (copied). */
    public init(values: Array<Complex>) {
        this.data = Array<CxF64>(values.size, {i => CxF64(values[i].re, values[i].im)})
    }

    // ---- factories --------------------------------------------------------
    public static func zeros(size: Int64): ComplexVector {
        ComplexVector(size)
    }

    public static func of(values: Array<Complex>): ComplexVector {
        ComplexVector(values)
    }

    /** Promote a real vector to complex (zero imaginary part). */
    public static func fromReal(re: Vector): ComplexVector {
        ComplexVector(Array<CxF64>(re.size, {i => CxF64(re.data[i], 0.0)}))
    }

    /** Assemble from separate real and imaginary parts (equal length). */
    public static func fromParts(re: Array<Float64>, im: Array<Float64>): ComplexVector {
        if (re.size != im.size) {
            throw DimensionMismatchException("fromParts: re length ${re.size} != im length ${im.size}")
        }
        ComplexVector(Array<CxF64>(re.size, {i => CxF64(re[i], im[i])}))
    }

    // ---- shape ------------------------------------------------------------
    public prop size: Int64 {
        get() {
            data.size
        }
    }

    public prop isEmpty: Bool {
        get() {
            data.size == 0
        }
    }

    // ---- element access ---------------------------------------------------
    public operator func [](i: Int64): Complex {
        checkIndex(i)
        let c = data[i]
        Complex(c.re, c.im)
    }

    public operator func [](i: Int64, value!: Complex): Unit {
        checkIndex(i)
        data[i] = CxF64(value.re, value.im)
    }

    func checkIndex(i: Int64): Unit {
        if (i < 0 || i >= data.size) {
            throw MatCangException("complex vector index ${i} out of bounds [0, ${data.size})")
        }
    }

    // ---- parts / conjugate ------------------------------------------------
    /** Real parts as a real Vector. */
    public func real(): Vector {
        Vector(Array<Float64>(data.size, {i => data[i].re}))
    }

    /** Imaginary parts as a real Vector. */
    public func imag(): Vector {
        Vector(Array<Float64>(data.size, {i => data[i].im}))
    }

    /** Element-wise complex conjugate. */
    public func conjugate(): ComplexVector {
        ComplexVector(Array<CxF64>(data.size, {i => CxF64(data[i].re, -data[i].im)}))
    }

    // ---- transforms -------------------------------------------------------
    public func copy(): ComplexVector {
        ComplexVector(cxCopyOf(data))
    }

    public func map(f: (Complex) -> Complex): ComplexVector {
        let d = Array<CxF64>(data.size, repeat: CxF64(0.0, 0.0))
        for (i in 0..data.size) {
            let r = f(Complex(data[i].re, data[i].im))
            d[i] = CxF64(r.re, r.im)
        }
        ComplexVector(d)
    }

    public func toArray(): Array<Complex> {
        Array<Complex>(data.size, {i => Complex(data[i].re, data[i].im)})
    }

    // ---- reductions -------------------------------------------------------
    /** Unconjugated inner product sum_i x_i * y_i (BLAS zdotu). */
    public func dot(other: ComplexVector): Complex {
        checkSameSize(other)
        if (data.size == 0) {
            return Complex(0.0, 0.0)
        }
        let r = Array<CxF64>(1, repeat: CxF64(0.0, 0.0))
        unsafe {
            let hx = acquireArrayRawData(data)
            let hy = acquireArrayRawData(other.data)
            let hr = acquireArrayRawData(r)
            zdotu_sub(Int32(data.size), hx.pointer, 1, hy.pointer, 1, hr.pointer)
            releaseArrayRawData(hr)
            releaseArrayRawData(hy)
            releaseArrayRawData(hx)
        }
        Complex(r[0].re, r[0].im)
    }

    /** Hermitian inner product sum_i conj(x_i) * y_i (BLAS zdotc). */
    public func dotc(other: ComplexVector): Complex {
        checkSameSize(other)
        if (data.size == 0) {
            return Complex(0.0, 0.0)
        }
        let r = Array<CxF64>(1, repeat: CxF64(0.0, 0.0))
        unsafe {
            let hx = acquireArrayRawData(data)
            let hy = acquireArrayRawData(other.data)
            let hr = acquireArrayRawData(r)
            zdotc_sub(Int32(data.size), hx.pointer, 1, hy.pointer, 1, hr.pointer)
            releaseArrayRawData(hr)
            releaseArrayRawData(hy)
            releaseArrayRawData(hx)
        }
        Complex(r[0].re, r[0].im)
    }

    /** Euclidean (2-)norm via BLAS dznrm2. */
    public func norm(): Float64 {
        if (data.size == 0) {
            return 0.0
        }
        var r = 0.0
        unsafe {
            let h = acquireArrayRawData(data)
            r = dznrm2(Int32(data.size), h.pointer, 1)
            releaseArrayRawData(h)
        }
        r
    }

    /** 1-norm sum |re|+|im| via BLAS dzasum (matching BLAS's definition). */
    public func norm1(): Float64 {
        if (data.size == 0) {
            return 0.0
        }
        var r = 0.0
        unsafe {
            let h = acquireArrayRawData(data)
            r = dzasum(Int32(data.size), h.pointer, 1)
            releaseArrayRawData(h)
        }
        r
    }

    public func sum(): Complex {
        var re = 0.0
        var im = 0.0
        for (c in data) {
            re += c.re
            im += c.im
        }
        Complex(re, im)
    }

    // ---- arithmetic -------------------------------------------------------
    public operator func +(rhs: ComplexVector): ComplexVector {
        checkSameSize(rhs)
        let out = copy()
        zaxpyInto(CxF64(1.0, 0.0), rhs.data, out.data)
        out
    }

    public operator func -(rhs: ComplexVector): ComplexVector {
        checkSameSize(rhs)
        let out = copy()
        zaxpyInto(CxF64(-1.0, 0.0), rhs.data, out.data)
        out
    }

    /** Element-wise (Hadamard) product. */
    public func hadamard(rhs: ComplexVector): ComplexVector {
        checkSameSize(rhs)
        let d = Array<CxF64>(data.size, repeat: CxF64(0.0, 0.0))
        for (i in 0..data.size) {
            let a = data[i]
            let b = rhs.data[i]
            d[i] = CxF64(a.re * b.re - a.im * b.im, a.re * b.im + a.im * b.re)
        }
        ComplexVector(d)
    }

    /** Scale by a complex scalar (BLAS zscal). */
    public operator func *(s: Complex): ComplexVector {
        let out = copy()
        zscalInPlace(CxF64(s.re, s.im), out.data)
        out
    }

    /** Scale by a real scalar (BLAS zdscal). */
    public operator func *(s: Float64): ComplexVector {
        let out = copy()
        zdscalInPlace(s, out.data)
        out
    }

    /** Divide by a real scalar (BLAS zdscal with 1/s). */
    public operator func /(s: Float64): ComplexVector {
        let out = copy()
        zdscalInPlace(1.0 / s, out.data)
        out
    }

    public operator func -(): ComplexVector {
        this * (-1.0)
    }

    // ---- equality ---------------------------------------------------------
    public operator func ==(rhs: ComplexVector): Bool {
        if (data.size != rhs.data.size) {
            return false
        }
        for (i in 0..data.size) {
            if (data[i].re != rhs.data[i].re || data[i].im != rhs.data[i].im) {
                return false
            }
        }
        true
    }

    public operator func !=(rhs: ComplexVector): Bool {
        !(this == rhs)
    }

    public func approxEquals(rhs: ComplexVector, tol!: Float64 = 1e-9): Bool {
        if (data.size != rhs.data.size) {
            return false
        }
        for (i in 0..data.size) {
            let dr = data[i].re - rhs.data[i].re
            let di = data[i].im - rhs.data[i].im
            if (sqrt(dr * dr + di * di) > tol) {
                return false
            }
        }
        true
    }

    func checkSameSize(other: ComplexVector): Unit {
        if (data.size != other.data.size) {
            throw DimensionMismatchException("complex vector sizes differ: ${data.size} vs ${other.data.size}")
        }
    }

    public func toString(): String {
        let sb = StringBuilder()
        sb.append("[")
        for (i in 0..data.size) {
            sb.append(Complex(data[i].re, data[i].im).toString())
            if (i < data.size - 1) {
                sb.append(", ")
            }
        }
        sb.append("]")
        sb.toString()
    }
}

// ---- package-internal complex level-1 helpers ----------------------------

/** Copy a CxF64 array via BLAS zcopy. */
func cxCopyOf(a: Array<CxF64>): Array<CxF64> {
    let d = Array<CxF64>(a.size, repeat: CxF64(0.0, 0.0))
    if (a.size == 0) {
        return d
    }
    unsafe {
        let hs = acquireArrayRawData(a)
        let hd = acquireArrayRawData(d)
        zcopy(Int32(a.size), hs.pointer, 1, hd.pointer, 1)
        releaseArrayRawData(hd)
        releaseArrayRawData(hs)
    }
    d
}

/** In-place `y += alpha * x` over complex buffers via BLAS zaxpy. */
func zaxpyInto(alpha: CxF64, x: Array<CxF64>, y: Array<CxF64>): Unit {
    if (x.size == 0) {
        return
    }
    let a = Array<CxF64>(1, repeat: alpha)
    unsafe {
        let ha = acquireArrayRawData(a)
        let hx = acquireArrayRawData(x)
        let hy = acquireArrayRawData(y)
        zaxpy(Int32(x.size), ha.pointer, hx.pointer, 1, hy.pointer, 1)
        releaseArrayRawData(hy)
        releaseArrayRawData(hx)
        releaseArrayRawData(ha)
    }
}

/** In-place `buf *= alpha` (complex scalar) via BLAS zscal. */
func zscalInPlace(alpha: CxF64, buf: Array<CxF64>): Unit {
    if (buf.size == 0) {
        return
    }
    let a = Array<CxF64>(1, repeat: alpha)
    unsafe {
        let ha = acquireArrayRawData(a)
        let hb = acquireArrayRawData(buf)
        zscal(Int32(buf.size), ha.pointer, hb.pointer, 1)
        releaseArrayRawData(hb)
        releaseArrayRawData(ha)
    }
}

/** In-place `buf *= alpha` (real scalar) via BLAS zdscal. */
func zdscalInPlace(alpha: Float64, buf: Array<CxF64>): Unit {
    if (buf.size == 0) {
        return
    }
    unsafe {
        let hb = acquireArrayRawData(buf)
        zdscal(Int32(buf.size), alpha, hb.pointer, 1)
        releaseArrayRawData(hb)
    }
}
