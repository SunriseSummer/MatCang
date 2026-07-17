/*
 * matcang.core - dense 1-D vector of Float64.
 *
 * Vector is a thin, ergonomic wrapper over a contiguous Float64 buffer. Level-1
 * BLAS (dot / nrm2 / asum) is used where it pays off; everything else is a
 * clear loop. Arithmetic operators return new vectors (value-like semantics)
 * even though Vector itself is a reference type.
 */
package matcang.core

import matcang.{ddot, dnrm2, dasum, idamax, daxpy, dscal, dcopy}
import std.math.*

public class Vector <: ToString {
    public let data: Array<Float64>

    public init(data: Array<Float64>) {
        this.data = data
    }

    /** A zero vector of the given length. */
    public init(size: Int64) {
        if (size < 0) {
            throw MatCangException("vector size must be non-negative, got ${size}")
        }
        this.data = Array<Float64>(size, repeat: 0.0)
    }

    /**
     * Integer-literal convenience: `Vector([1, 2, 3])`. Entries are converted
     * to Float64 and copied.
     */
    public init(values: Array<Int64>) {
        this.data = Array<Float64>(values.size, {i => Float64(values[i])})
    }

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
    public operator func [](i: Int64): Float64 {
        checkIndex(i)
        data[i]
    }

    public operator func [](i: Int64, value!: Float64): Unit {
        checkIndex(i)
        data[i] = value
    }

    func checkIndex(i: Int64): Unit {
        if (i < 0 || i >= data.size) {
            throw MatCangException("vector index ${i} out of bounds [0, ${data.size})")
        }
    }

    // ---- factories --------------------------------------------------------
    public static func zeros(size: Int64): Vector {
        Vector(size)
    }

    public static func ones(size: Int64): Vector {
        Vector.filled(size, 1.0)
    }

    public static func filled(size: Int64, value: Float64): Vector {
        Vector(Array<Float64>(size, repeat: value))
    }

    public static func of(values: Array<Float64>): Vector {
        Vector(copyOf(values))
    }

    /** Build a vector element-wise from its index. */
    public static func build(size: Int64, f: (Int64) -> Float64): Vector {
        let d = Array<Float64>(size, repeat: 0.0)
        for (i in 0..size) {
            d[i] = f(i)
        }
        Vector(d)
    }

    /** `count` evenly spaced values from `start` to `stop` inclusive. */
    public static func linspace(start: Float64, stop: Float64, count: Int64): Vector {
        if (count <= 0) {
            return Vector(0)
        }
        if (count == 1) {
            return Vector([start])
        }
        let d = Array<Float64>(count, repeat: 0.0)
        let step = (stop - start) / Float64(count - 1)
        for (i in 0..count) {
            d[i] = start + Float64(i) * step
        }
        Vector(d)
    }

    /** i-th standard basis vector e_i in R^size. */
    public static func basis(size: Int64, i: Int64): Vector {
        let v = Vector(size)
        v.data[i] = 1.0
        v
    }

    // ---- transforms -------------------------------------------------------
    public func copy(): Vector {
        Vector(copyOf(data))
    }

    public func map(f: (Float64) -> Float64): Vector {
        let d = Array<Float64>(data.size, repeat: 0.0)
        for (i in 0..data.size) {
            d[i] = f(data[i])
        }
        Vector(d)
    }

    public func mapIndexed(f: (Int64, Float64) -> Float64): Vector {
        let d = Array<Float64>(data.size, repeat: 0.0)
        for (i in 0..data.size) {
            d[i] = f(i, data[i])
        }
        Vector(d)
    }

    public func zipWith(other: Vector, f: (Float64, Float64) -> Float64): Vector {
        checkSameSize(other)
        let d = Array<Float64>(data.size, repeat: 0.0)
        for (i in 0..data.size) {
            d[i] = f(data[i], other.data[i])
        }
        Vector(d)
    }

    public func forEach(f: (Float64) -> Unit): Unit {
        for (i in 0..data.size) {
            f(data[i])
        }
    }

    // ---- reductions -------------------------------------------------------
    /** Inner product via BLAS ddot. */
    public func dot(other: Vector): Float64 {
        checkSameSize(other)
        if (data.size == 0) {
            return 0.0
        }
        var r = 0.0
        unsafe {
            let hx = acquireArrayRawData(data)
            let hy = acquireArrayRawData(other.data)
            r = ddot(Int32(data.size), hx.pointer, 1, hy.pointer, 1)
            releaseArrayRawData(hy)
            releaseArrayRawData(hx)
        }
        r
    }

    /** Euclidean (2-)norm via BLAS dnrm2. */
    public func norm(): Float64 {
        if (data.size == 0) {
            return 0.0
        }
        var r = 0.0
        unsafe {
            let h = acquireArrayRawData(data)
            r = dnrm2(Int32(data.size), h.pointer, 1)
            releaseArrayRawData(h)
        }
        r
    }

    /** 1-norm (sum of absolute values) via BLAS dasum. */
    public func norm1(): Float64 {
        if (data.size == 0) {
            return 0.0
        }
        var r = 0.0
        unsafe {
            let h = acquireArrayRawData(data)
            r = dasum(Int32(data.size), h.pointer, 1)
            releaseArrayRawData(h)
        }
        r
    }

    /** Infinity-norm (max absolute value). */
    public func normInf(): Float64 {
        var m = 0.0
        for (v in data) {
            let a = abs(v)
            if (a > m) {
                m = a
            }
        }
        m
    }

    public func sum(): Float64 {
        var s = 0.0
        for (v in data) {
            s += v
        }
        s
    }

    public func mean(): Float64 {
        if (data.size == 0) {
            return 0.0
        }
        sum() / Float64(data.size)
    }

    public func min(): Float64 {
        if (data.size == 0) {
            throw MatCangException("min of empty vector")
        }
        var m = data[0]
        for (v in data) {
            if (v < m) {
                m = v
            }
        }
        m
    }

    public func max(): Float64 {
        if (data.size == 0) {
            throw MatCangException("max of empty vector")
        }
        var m = data[0]
        for (v in data) {
            if (v > m) {
                m = v
            }
        }
        m
    }

    /** Index of the maximum absolute value (BLAS idamax, 0-based). */
    public func argAbsMax(): Int64 {
        if (data.size == 0) {
            throw MatCangException("argAbsMax of empty vector")
        }
        var idx: UIntNative = 0
        unsafe {
            let h = acquireArrayRawData(data)
            idx = idamax(Int32(data.size), h.pointer, 1)
            releaseArrayRawData(h)
        }
        Int64(idx)
    }

    // ---- arithmetic -------------------------------------------------------
    // +, -, scalar * and unary - run on BLAS level-1 kernels (daxpy/dscal).
    public operator func +(rhs: Vector): Vector {
        checkSameSize(rhs)
        let out = copy()
        axpyInto(1.0, rhs.data, out.data)
        out
    }

    public operator func -(rhs: Vector): Vector {
        checkSameSize(rhs)
        let out = copy()
        axpyInto(-1.0, rhs.data, out.data)
        out
    }

    /** Element-wise (Hadamard) product. */
    public func hadamard(rhs: Vector): Vector {
        checkSameSize(rhs)
        zipWith(rhs) {a, b => a * b}
    }

    public operator func *(s: Float64): Vector {
        let out = copy()
        scaleBuffer(out.data, s)
        out
    }

    public operator func /(s: Float64): Vector {
        map {v => v / s}
    }

    public operator func +(s: Float64): Vector {
        map {v => v + s}
    }

    public operator func -(s: Float64): Vector {
        map {v => v - s}
    }

    public operator func -(): Vector {
        let out = copy()
        scaleBuffer(out.data, -1.0)
        out
    }

    public operator func ==(rhs: Vector): Bool {
        if (data.size != rhs.data.size) {
            return false
        }
        for (i in 0..data.size) {
            if (data[i] != rhs.data[i]) {
                return false
            }
        }
        true
    }

    public operator func !=(rhs: Vector): Bool {
        !(this == rhs)
    }

    public func approxEquals(rhs: Vector, tol!: Float64 = 1e-9): Bool {
        if (data.size != rhs.data.size) {
            return false
        }
        for (i in 0..data.size) {
            if (abs(data[i] - rhs.data[i]) > tol) {
                return false
            }
        }
        true
    }

    // ---- conversions ------------------------------------------------------
    public func toArray(): Array<Float64> {
        copyOf(data)
    }

    func checkSameSize(other: Vector): Unit {
        if (data.size != other.data.size) {
            throw DimensionMismatchException("vector sizes differ: ${data.size} vs ${other.data.size}")
        }
    }

    public func toString(): String {
        let sb = StringBuilder()
        sb.append("[")
        for (i in 0..data.size) {
            sb.append(formatFixed(data[i], 4))
            if (i < data.size - 1) {
                sb.append(", ")
            }
        }
        sb.append("]")
        sb.toString()
    }
}

/** Copy a Float64 array via BLAS dcopy (helper shared inside the package). */
func copyOf(a: Array<Float64>): Array<Float64> {
    let d = Array<Float64>(a.size, repeat: 0.0)
    if (a.size == 0) {
        return d
    }
    unsafe {
        let hs = acquireArrayRawData(a)
        let hd = acquireArrayRawData(d)
        dcopy(Int32(a.size), hs.pointer, 1, hd.pointer, 1)
        releaseArrayRawData(hd)
        releaseArrayRawData(hs)
    }
    d
}

/** In-place `y += alpha * x` over flat buffers via BLAS daxpy (package helper). */
func axpyInto(alpha: Float64, x: Array<Float64>, y: Array<Float64>): Unit {
    if (x.size == 0) {
        return
    }
    unsafe {
        let hx = acquireArrayRawData(x)
        let hy = acquireArrayRawData(y)
        daxpy(Int32(x.size), alpha, hx.pointer, 1, hy.pointer, 1)
        releaseArrayRawData(hy)
        releaseArrayRawData(hx)
    }
}

/** In-place `buf *= alpha` via BLAS dscal (package helper). */
func scaleBuffer(buf: Array<Float64>, alpha: Float64): Unit {
    if (buf.size == 0) {
        return
    }
    unsafe {
        let h = acquireArrayRawData(buf)
        dscal(Int32(buf.size), alpha, h.pointer, 1)
        releaseArrayRawData(h)
    }
}
