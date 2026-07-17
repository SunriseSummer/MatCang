/*
 * matcang.core - dense 2-D matrix of complex numbers (row-major).
 *
 * ComplexMatrix mirrors Matrix: entries live in a flat Array<CxF64>, element
 * (i, j) at data[i * cols + j], handed to CBLAS/LAPACK zero-copy. The matrix
 * product runs on BLAS zgemm; everything speaks the ergonomic `Complex` type at
 * its edges. Both a plain transpose (`.t`) and a conjugate transpose (`.h`,
 * the Hermitian adjoint) are provided - the distinction only exists for complex
 * matrices and matters throughout complex linear algebra.
 */
package matcang.core

import matcang.{zgemm, zgemv, dznrm2, CxF64, Cblas}
import std.math.*

public class ComplexMatrix <: ToString {
    public let rows: Int64
    public let cols: Int64
    public let data: Array<CxF64> // row-major, length rows*cols

    public init(rows: Int64, cols: Int64, data: Array<CxF64>) {
        if (rows < 0 || cols < 0) {
            throw MatCangException("matrix dimensions must be non-negative: ${rows}x${cols}")
        }
        if (data.size != rows * cols) {
            throw DimensionMismatchException(
                "buffer length ${data.size} does not match ${rows}x${cols} = ${rows * cols}")
        }
        this.rows = rows
        this.cols = cols
        this.data = data
    }

    /** A zero matrix of the given shape. */
    public init(rows: Int64, cols: Int64) {
        if (rows < 0 || cols < 0) {
            throw MatCangException("matrix dimensions must be non-negative: ${rows}x${cols}")
        }
        this.rows = rows
        this.cols = cols
        this.data = Array<CxF64>(rows * cols, repeat: CxF64(0.0, 0.0))
    }

    /** Literal construction, row by row (all rows equal length; data copied). */
    public init(rowsData: Array<Array<Complex>>) {
        let r = rowsData.size
        let c = if (r == 0) {
            0
        } else {
            rowsData[0].size
        }
        let d = Array<CxF64>(r * c, repeat: CxF64(0.0, 0.0))
        for (i in 0..r) {
            if (rowsData[i].size != c) {
                throw DimensionMismatchException("row ${i} has length ${rowsData[i].size}, expected ${c}")
            }
            for (j in 0..c) {
                d[i * c + j] = CxF64(rowsData[i][j].re, rowsData[i][j].im)
            }
        }
        this.rows = r
        this.cols = c
        this.data = d
    }

    // ---- shape ------------------------------------------------------------
    public prop size: Int64 {
        get() {
            rows * cols
        }
    }

    public prop shape: (Int64, Int64) {
        get() {
            (rows, cols)
        }
    }

    public prop isSquare: Bool {
        get() {
            rows == cols
        }
    }

    public prop isEmpty: Bool {
        get() {
            rows == 0 || cols == 0
        }
    }

    /** Plain (non-conjugated) transpose. */
    public prop t: ComplexMatrix {
        get() {
            transpose()
        }
    }

    /** Conjugate transpose (Hermitian adjoint) A^H. */
    public prop h: ComplexMatrix {
        get() {
            conjugateTranspose()
        }
    }

    // ---- element access ---------------------------------------------------
    public operator func [](i: Int64, j: Int64): Complex {
        checkIndex(i, j)
        let c = data[i * cols + j]
        Complex(c.re, c.im)
    }

    public operator func [](i: Int64, j: Int64, value!: Complex): Unit {
        checkIndex(i, j)
        data[i * cols + j] = CxF64(value.re, value.im)
    }

    func checkIndex(i: Int64, j: Int64): Unit {
        if (i < 0 || i >= rows || j < 0 || j >= cols) {
            throw MatCangException("index (${i}, ${j}) out of bounds for ${rows}x${cols} matrix")
        }
    }

    // ---- factories --------------------------------------------------------
    public static func zeros(rows: Int64, cols: Int64): ComplexMatrix {
        ComplexMatrix(rows, cols)
    }

    /** n x n identity matrix. */
    public static func identity(n: Int64): ComplexMatrix {
        let m = ComplexMatrix(n, n)
        for (i in 0..n) {
            m.data[i * n + i] = CxF64(1.0, 0.0)
        }
        m
    }

    /** Promote a real matrix to complex (zero imaginary part). */
    public static func fromReal(a: Matrix): ComplexMatrix {
        let d = Array<CxF64>(a.data.size, {i => CxF64(a.data[i], 0.0)})
        ComplexMatrix(a.rows, a.cols, d)
    }

    /** Combine real and imaginary real-matrices of equal shape. */
    public static func fromParts(re: Matrix, im: Matrix): ComplexMatrix {
        if (re.rows != im.rows || re.cols != im.cols) {
            throw DimensionMismatchException("fromParts shape mismatch: ${re.rows}x${re.cols} vs ${im.rows}x${im.cols}")
        }
        let d = Array<CxF64>(re.data.size, {i => CxF64(re.data[i], im.data[i])})
        ComplexMatrix(re.rows, re.cols, d)
    }

    /** Square diagonal matrix from complex diagonal entries. */
    public static func fromDiagonal(values: Array<Complex>): ComplexMatrix {
        let n = values.size
        let m = ComplexMatrix(n, n)
        for (i in 0..n) {
            m.data[i * n + i] = CxF64(values[i].re, values[i].im)
        }
        m
    }

    // ---- rows / columns / parts ------------------------------------------
    public func row(i: Int64): ComplexVector {
        if (i < 0 || i >= rows) {
            throw MatCangException("row ${i} out of bounds for ${rows}x${cols} matrix")
        }
        let d = Array<CxF64>(cols, repeat: CxF64(0.0, 0.0))
        for (j in 0..cols) {
            d[j] = data[i * cols + j]
        }
        ComplexVector(d)
    }

    public func col(j: Int64): ComplexVector {
        if (j < 0 || j >= cols) {
            throw MatCangException("column ${j} out of bounds for ${rows}x${cols} matrix")
        }
        let d = Array<CxF64>(rows, repeat: CxF64(0.0, 0.0))
        for (i in 0..rows) {
            d[i] = data[i * cols + j]
        }
        ComplexVector(d)
    }

    public func diagonal(): ComplexVector {
        let n = if (rows < cols) {
            rows
        } else {
            cols
        }
        let d = Array<CxF64>(n, repeat: CxF64(0.0, 0.0))
        for (i in 0..n) {
            d[i] = data[i * cols + i]
        }
        ComplexVector(d)
    }

    /** Sum of the diagonal entries (square matrices only). */
    public func trace(): Complex {
        if (rows != cols) {
            throw NonSquareMatrixException("operation requires a square matrix, got ${rows}x${cols}")
        }
        var sr = 0.0
        var si = 0.0
        for (i in 0..rows) {
            let c = data[i * cols + i]
            sr += c.re
            si += c.im
        }
        Complex(sr, si)
    }

    /** Real parts as a real Matrix. */
    public func real(): Matrix {
        Matrix(rows, cols, Array<Float64>(data.size, {i => data[i].re}))
    }

    /** Imaginary parts as a real Matrix. */
    public func imag(): Matrix {
        Matrix(rows, cols, Array<Float64>(data.size, {i => data[i].im}))
    }

    // ---- transforms -------------------------------------------------------
    public func copy(): ComplexMatrix {
        ComplexMatrix(rows, cols, cxCopyOf(data))
    }

    /** Element-wise complex conjugate (same shape). */
    public func conjugate(): ComplexMatrix {
        ComplexMatrix(rows, cols, Array<CxF64>(data.size, {i => CxF64(data[i].re, -data[i].im)}))
    }

    /** Plain transpose (no conjugation). */
    public func transpose(): ComplexMatrix {
        let out = ComplexMatrix(cols, rows)
        for (i in 0..rows) {
            for (j in 0..cols) {
                out.data[j * rows + i] = data[i * cols + j]
            }
        }
        out
    }

    /** Conjugate transpose (Hermitian adjoint) A^H. */
    public func conjugateTranspose(): ComplexMatrix {
        let out = ComplexMatrix(cols, rows)
        for (i in 0..rows) {
            for (j in 0..cols) {
                let c = data[i * cols + j]
                out.data[j * rows + i] = CxF64(c.re, -c.im)
            }
        }
        out
    }

    public func map(f: (Complex) -> Complex): ComplexMatrix {
        let d = Array<CxF64>(data.size, repeat: CxF64(0.0, 0.0))
        for (i in 0..data.size) {
            let r = f(Complex(data[i].re, data[i].im))
            d[i] = CxF64(r.re, r.im)
        }
        ComplexMatrix(rows, cols, d)
    }

    /** Frobenius norm via BLAS dznrm2 over the flat buffer. */
    public func frobeniusNorm(): Float64 {
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

    // ---- arithmetic -------------------------------------------------------
    public operator func +(rhs: ComplexMatrix): ComplexMatrix {
        checkSameShape(rhs)
        let out = copy()
        zaxpyInto(CxF64(1.0, 0.0), rhs.data, out.data)
        out
    }

    public operator func -(rhs: ComplexMatrix): ComplexMatrix {
        checkSameShape(rhs)
        let out = copy()
        zaxpyInto(CxF64(-1.0, 0.0), rhs.data, out.data)
        out
    }

    /** Element-wise (Hadamard) product. */
    public func hadamard(rhs: ComplexMatrix): ComplexMatrix {
        checkSameShape(rhs)
        let d = Array<CxF64>(data.size, repeat: CxF64(0.0, 0.0))
        for (i in 0..data.size) {
            let a = data[i]
            let b = rhs.data[i]
            d[i] = CxF64(a.re * b.re - a.im * b.im, a.re * b.im + a.im * b.re)
        }
        ComplexMatrix(rows, cols, d)
    }

    public operator func *(s: Complex): ComplexMatrix {
        let out = copy()
        zscalInPlace(CxF64(s.re, s.im), out.data)
        out
    }

    /** Scale by a real scalar (BLAS zdscal). */
    public operator func *(s: Float64): ComplexMatrix {
        let out = copy()
        zdscalInPlace(s, out.data)
        out
    }

    /** Divide by a real scalar (BLAS zdscal with 1/s). */
    public operator func /(s: Float64): ComplexMatrix {
        let out = copy()
        zdscalInPlace(1.0 / s, out.data)
        out
    }

    public operator func -(): ComplexMatrix {
        this * Complex(-1.0, 0.0)
    }

    // ---- matrix / vector products (BLAS zgemm / zgemv) -------------------
    /** Matrix product `this * rhs` via BLAS zgemm. */
    public operator func *(rhs: ComplexMatrix): ComplexMatrix {
        if (cols != rhs.rows) {
            throw DimensionMismatchException("cannot multiply ${rows}x${cols} by ${rhs.rows}x${rhs.cols}")
        }
        let m = rows
        let k = cols
        let n = rhs.cols
        let c = ComplexMatrix(m, n)
        if (m == 0 || n == 0 || k == 0) {
            return c
        }
        let alpha = Array<CxF64>(1, repeat: CxF64(1.0, 0.0))
        let beta = Array<CxF64>(1, repeat: CxF64(0.0, 0.0))
        unsafe {
            let ha = acquireArrayRawData(data)
            let hb = acquireArrayRawData(rhs.data)
            let hc = acquireArrayRawData(c.data)
            let hal = acquireArrayRawData(alpha)
            let hbe = acquireArrayRawData(beta)
            zgemm(Cblas.ROW_MAJOR, Cblas.NO_TRANS, Cblas.NO_TRANS, Int32(m), Int32(n), Int32(k), hal.pointer, ha.pointer,
                Int32(k), hb.pointer, Int32(n), hbe.pointer, hc.pointer, Int32(n))
            releaseArrayRawData(hbe)
            releaseArrayRawData(hal)
            releaseArrayRawData(hc)
            releaseArrayRawData(hb)
            releaseArrayRawData(ha)
        }
        c
    }

    /** Matrix-vector product `this * x` via BLAS zgemv. */
    public operator func *(x: ComplexVector): ComplexVector {
        if (cols != x.size) {
            throw DimensionMismatchException("cannot multiply ${rows}x${cols} matrix by vector of length ${x.size}")
        }
        let y = ComplexVector(rows)
        if (rows == 0 || cols == 0) {
            return y
        }
        let alpha = Array<CxF64>(1, repeat: CxF64(1.0, 0.0))
        let beta = Array<CxF64>(1, repeat: CxF64(0.0, 0.0))
        unsafe {
            let ha = acquireArrayRawData(data)
            let hx = acquireArrayRawData(x.data)
            let hy = acquireArrayRawData(y.data)
            let hal = acquireArrayRawData(alpha)
            let hbe = acquireArrayRawData(beta)
            zgemv(Cblas.ROW_MAJOR, Cblas.NO_TRANS, Int32(rows), Int32(cols), hal.pointer, ha.pointer, Int32(cols),
                hx.pointer, 1, hbe.pointer, hy.pointer, 1)
            releaseArrayRawData(hbe)
            releaseArrayRawData(hal)
            releaseArrayRawData(hy)
            releaseArrayRawData(hx)
            releaseArrayRawData(ha)
        }
        y
    }

    public func matmul(rhs: ComplexMatrix): ComplexMatrix {
        this * rhs
    }

    // ---- equality ---------------------------------------------------------
    public operator func ==(rhs: ComplexMatrix): Bool {
        if (rows != rhs.rows || cols != rhs.cols) {
            return false
        }
        for (i in 0..data.size) {
            if (data[i].re != rhs.data[i].re || data[i].im != rhs.data[i].im) {
                return false
            }
        }
        true
    }

    public operator func !=(rhs: ComplexMatrix): Bool {
        !(this == rhs)
    }

    public func approxEquals(rhs: ComplexMatrix, tol!: Float64 = 1e-9): Bool {
        if (rows != rhs.rows || cols != rhs.cols) {
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

    func checkSameShape(other: ComplexMatrix): Unit {
        if (rows != other.rows || cols != other.cols) {
            throw DimensionMismatchException("shape mismatch: ${rows}x${cols} vs ${other.rows}x${other.cols}")
        }
    }

    public func toString(): String {
        if (rows == 0 || cols == 0) {
            return "[ ] (${rows}x${cols})"
        }
        let sb = StringBuilder()
        for (i in 0..rows) {
            sb.append("[ ")
            for (j in 0..cols) {
                sb.append(Complex(data[i * cols + j].re, data[i * cols + j].im).toString())
                if (j < cols - 1) {
                    sb.append("  ")
                }
            }
            sb.append(" ]")
            if (i < rows - 1) {
                sb.append("\n")
            }
        }
        sb.toString()
    }
}
