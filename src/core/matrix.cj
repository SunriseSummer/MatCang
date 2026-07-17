/*
 * matcang.core - dense 2-D matrix of Float64 (row-major storage).
 *
 * Matrix is the centrepiece of the library. It presents a clean, immutable-by-
 * default surface (arithmetic returns fresh matrices) while delegating the
 * heavy lifting - matrix multiply, norms - to OpenBLAS through the FFI layer.
 *
 * Storage is row-major: element (i, j) lives at data[i * cols + j]. BLAS/LAPACK
 * calls therefore pass the Cblas.ROW_MAJOR / Lapack.ROW_MAJOR layout flag.
 */
package matcang.core

import std.math.*
import matcang.{dgemm, dgemv, dnrm2, domatcopy, Cblas}

public class Matrix <: ToString {
    public let rows: Int64
    public let cols: Int64
    public let data: Array<Float64> // row-major, length rows*cols

    /** Wrap an existing row-major buffer (validated). */
    public init(rows: Int64, cols: Int64, data: Array<Float64>) {
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
        this.data = Array<Float64>(rows * cols, repeat: 0.0)
    }

    /**
     * Literal construction, row by row: `Matrix([[1.0, 2.0], [3.0, 4.0]])`.
     * Rows must all have the same length; the data is copied.
     */
    public init(rowsData: Array<Array<Float64>>) {
        let r = rowsData.size
        let c = if (r == 0) {
            0
        } else {
            rowsData[0].size
        }
        let d = Array<Float64>(r * c, repeat: 0.0)
        for (i in 0..r) {
            if (rowsData[i].size != c) {
                throw DimensionMismatchException("row ${i} has length ${rowsData[i].size}, expected ${c}")
            }
            for (j in 0..c) {
                d[i * c + j] = rowsData[i][j]
            }
        }
        this.rows = r
        this.cols = c
        this.data = d
    }

    /**
     * Integer-literal convenience: `Matrix([[1, 2, 3], [4, 5, 6]])`. Entries are
     * converted to Float64 (Cangjie integer literals do not coerce implicitly).
     */
    public init(rowsData: Array<Array<Int64>>) {
        let r = rowsData.size
        let c = if (r == 0) {
            0
        } else {
            rowsData[0].size
        }
        let d = Array<Float64>(r * c, repeat: 0.0)
        for (i in 0..r) {
            if (rowsData[i].size != c) {
                throw DimensionMismatchException("row ${i} has length ${rowsData[i].size}, expected ${c}")
            }
            for (j in 0..c) {
                d[i * c + j] = Float64(rowsData[i][j])
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

    /** Transpose accessor: `a.t` reads naturally in expressions. */
    public prop t: Matrix {
        get() {
            transpose()
        }
    }

    // ---- element access ---------------------------------------------------
    public operator func [](i: Int64, j: Int64): Float64 {
        checkIndex(i, j)
        data[i * cols + j]
    }

    public operator func [](i: Int64, j: Int64, value!: Float64): Unit {
        checkIndex(i, j)
        data[i * cols + j] = value
    }

    func checkIndex(i: Int64, j: Int64): Unit {
        if (i < 0 || i >= rows || j < 0 || j >= cols) {
            throw MatCangException("index (${i}, ${j}) out of bounds for ${rows}x${cols} matrix")
        }
    }

    // ---- factories --------------------------------------------------------
    public static func zeros(rows: Int64, cols: Int64): Matrix {
        Matrix(rows, cols)
    }

    public static func ones(rows: Int64, cols: Int64): Matrix {
        Matrix.filled(rows, cols, 1.0)
    }

    public static func filled(rows: Int64, cols: Int64, value: Float64): Matrix {
        Matrix(rows, cols, Array<Float64>(rows * cols, repeat: value))
    }

    /** n x n identity matrix. */
    public static func identity(n: Int64): Matrix {
        let m = Matrix(n, n)
        for (i in 0..n) {
            m.data[i * n + i] = 1.0
        }
        m
    }

    /** Square diagonal matrix from the given diagonal entries. */
    public static func fromDiagonal(values: Array<Float64>): Matrix {
        let n = values.size
        let m = Matrix(n, n)
        for (i in 0..n) {
            m.data[i * n + i] = values[i]
        }
        m
    }

    /** Build a matrix element-wise from a function of its indices. */
    public static func build(rows: Int64, cols: Int64, f: (Int64, Int64) -> Float64): Matrix {
        let d = Array<Float64>(rows * cols, repeat: 0.0)
        for (i in 0..rows) {
            for (j in 0..cols) {
                d[i * cols + j] = f(i, j)
            }
        }
        Matrix(rows, cols, d)
    }

    /** Assemble a matrix from a list of row arrays. */
    public static func fromRows(rowsData: Array<Array<Float64>>): Matrix {
        let r = rowsData.size
        if (r == 0) {
            return Matrix(0, 0)
        }
        let c = rowsData[0].size
        let d = Array<Float64>(r * c, repeat: 0.0)
        for (i in 0..r) {
            if (rowsData[i].size != c) {
                throw DimensionMismatchException("row ${i} has length ${rowsData[i].size}, expected ${c}")
            }
            for (j in 0..c) {
                d[i * c + j] = rowsData[i][j]
            }
        }
        Matrix(r, c, d)
    }

    /** Assemble a matrix from a list of column vectors. */
    public static func fromColumns(colsData: Array<Array<Float64>>): Matrix {
        let c = colsData.size
        if (c == 0) {
            return Matrix(0, 0)
        }
        let r = colsData[0].size
        let d = Array<Float64>(r * c, repeat: 0.0)
        for (j in 0..c) {
            if (colsData[j].size != r) {
                throw DimensionMismatchException("column ${j} has length ${colsData[j].size}, expected ${r}")
            }
            for (i in 0..r) {
                d[i * c + j] = colsData[j][i]
            }
        }
        Matrix(r, c, d)
    }

    // ---- rows / columns / diagonal ---------------------------------------
    public func row(i: Int64): Vector {
        if (i < 0 || i >= rows) {
            throw MatCangException("row ${i} out of bounds for ${rows}x${cols} matrix")
        }
        let d = Array<Float64>(cols, repeat: 0.0)
        for (j in 0..cols) {
            d[j] = data[i * cols + j]
        }
        Vector(d)
    }

    public func col(j: Int64): Vector {
        if (j < 0 || j >= cols) {
            throw MatCangException("column ${j} out of bounds for ${rows}x${cols} matrix")
        }
        let d = Array<Float64>(rows, repeat: 0.0)
        for (i in 0..rows) {
            d[i] = data[i * cols + j]
        }
        Vector(d)
    }

    public func setRow(i: Int64, v: Vector): Unit {
        if (v.size != cols) {
            throw DimensionMismatchException("row length ${v.size} != cols ${cols}")
        }
        for (j in 0..cols) {
            data[i * cols + j] = v.data[j]
        }
    }

    public func setColumn(j: Int64, v: Vector): Unit {
        if (v.size != rows) {
            throw DimensionMismatchException("column length ${v.size} != rows ${rows}")
        }
        for (i in 0..rows) {
            data[i * cols + j] = v.data[i]
        }
    }

    public func diagonal(): Vector {
        let n = if (rows < cols) {
            rows
        } else {
            cols
        }
        let d = Array<Float64>(n, repeat: 0.0)
        for (i in 0..n) {
            d[i] = data[i * cols + i]
        }
        Vector(d)
    }

    public func trace(): Float64 {
        requireSquare()
        var s = 0.0
        for (i in 0..rows) {
            s += data[i * cols + i]
        }
        s
    }

    // ---- transforms -------------------------------------------------------
    public func copy(): Matrix {
        Matrix(rows, cols, copyOf(data))
    }

    /** Transpose (returns a new matrix; OpenBLAS domatcopy, cache-blocked). */
    public func transpose(): Matrix {
        let out = Matrix(cols, rows)
        if (data.size == 0) {
            return out
        }
        unsafe {
            let ha = acquireArrayRawData(data)
            let hb = acquireArrayRawData(out.data)
            domatcopy(Cblas.ROW_MAJOR, Cblas.TRANS, Int32(rows), Int32(cols), 1.0, ha.pointer, Int32(cols), hb.pointer,
                Int32(rows))
            releaseArrayRawData(hb)
            releaseArrayRawData(ha)
        }
        out
    }

    /** Reinterpret the same data under a new shape (O(1), shares storage). */
    public func reshape(newRows: Int64, newCols: Int64): Matrix {
        if (newRows * newCols != rows * cols) {
            throw DimensionMismatchException("cannot reshape ${rows}x${cols} into ${newRows}x${newCols}")
        }
        Matrix(newRows, newCols, data)
    }

    public func map(f: (Float64) -> Float64): Matrix {
        let d = Array<Float64>(data.size, repeat: 0.0)
        for (i in 0..data.size) {
            d[i] = f(data[i])
        }
        Matrix(rows, cols, d)
    }

    public func mapIndexed(f: (Int64, Int64, Float64) -> Float64): Matrix {
        let d = Array<Float64>(data.size, repeat: 0.0)
        for (i in 0..rows) {
            for (j in 0..cols) {
                let idx = i * cols + j
                d[idx] = f(i, j, data[idx])
            }
        }
        Matrix(rows, cols, d)
    }

    public func zipWith(other: Matrix, f: (Float64, Float64) -> Float64): Matrix {
        checkSameShape(other)
        let d = Array<Float64>(data.size, repeat: 0.0)
        for (i in 0..data.size) {
            d[i] = f(data[i], other.data[i])
        }
        Matrix(rows, cols, d)
    }

    public func forEach(f: (Float64) -> Unit): Unit {
        for (i in 0..data.size) {
            f(data[i])
        }
    }

    // ---- reductions -------------------------------------------------------
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
            throw MatCangException("min of empty matrix")
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
            throw MatCangException("max of empty matrix")
        }
        var m = data[0]
        for (v in data) {
            if (v > m) {
                m = v
            }
        }
        m
    }

    /** Frobenius norm via BLAS dnrm2 over the flat buffer. */
    public func frobeniusNorm(): Float64 {
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

    // ---- arithmetic (element-wise & scalar) ------------------------------
    // The +, -, scalar *, / and unary - paths run on BLAS level-1 kernels
    // (daxpy/dscal) over the flat buffers rather than per-element closures.
    // Scalar + / - broadcast a constant to every entry, which has no level-1
    // kernel, so those stay element-wise loops.
    public operator func +(rhs: Matrix): Matrix {
        checkSameShape(rhs)
        let out = copy()
        axpyInto(1.0, rhs.data, out.data)
        out
    }

    public operator func -(rhs: Matrix): Matrix {
        checkSameShape(rhs)
        let out = copy()
        axpyInto(-1.0, rhs.data, out.data)
        out
    }

    /** Element-wise (Hadamard) product. */
    public func hadamard(rhs: Matrix): Matrix {
        checkSameShape(rhs)
        zipWith(rhs) {a, b => a * b}
    }

    public operator func *(s: Float64): Matrix {
        let out = copy()
        scaleBuffer(out.data, s)
        out
    }

    public operator func /(s: Float64): Matrix {
        let out = copy()
        scaleBuffer(out.data, 1.0 / s)
        out
    }

    public operator func +(s: Float64): Matrix {
        map {v => v + s}
    }

    public operator func -(s: Float64): Matrix {
        map {v => v - s}
    }

    public operator func -(): Matrix {
        let out = copy()
        scaleBuffer(out.data, -1.0)
        out
    }

    // ---- matrix / vector products (BLAS) ---------------------------------
    /** Matrix product `this * rhs` via BLAS dgemm. */
    public operator func *(rhs: Matrix): Matrix {
        if (cols != rhs.rows) {
            throw DimensionMismatchException("cannot multiply ${rows}x${cols} by ${rhs.rows}x${rhs.cols}")
        }
        let m = rows
        let k = cols
        let n = rhs.cols
        let c = Matrix(m, n)
        if (m == 0 || n == 0 || k == 0) {
            return c
        }
        unsafe {
            let ha = acquireArrayRawData(data)
            let hb = acquireArrayRawData(rhs.data)
            let hc = acquireArrayRawData(c.data)
            dgemm(Cblas.ROW_MAJOR, Cblas.NO_TRANS, Cblas.NO_TRANS, Int32(m), Int32(n), Int32(k), 1.0, ha.pointer,
                Int32(k), hb.pointer, Int32(n), 0.0, hc.pointer, Int32(n))
            releaseArrayRawData(hc)
            releaseArrayRawData(hb)
            releaseArrayRawData(ha)
        }
        c
    }

    /** Matrix-vector product `this * x` via BLAS dgemv. */
    public operator func *(x: Vector): Vector {
        if (cols != x.size) {
            throw DimensionMismatchException("cannot multiply ${rows}x${cols} matrix by vector of length ${x.size}")
        }
        let y = Vector(rows)
        if (rows == 0 || cols == 0) {
            return y
        }
        unsafe {
            let ha = acquireArrayRawData(data)
            let hx = acquireArrayRawData(x.data)
            let hy = acquireArrayRawData(y.data)
            dgemv(Cblas.ROW_MAJOR, Cblas.NO_TRANS, Int32(rows), Int32(cols), 1.0, ha.pointer, Int32(cols), hx.pointer, 1,
                0.0, hy.pointer, 1)
            releaseArrayRawData(hy)
            releaseArrayRawData(hx)
            releaseArrayRawData(ha)
        }
        y
    }

    /** Explicit alias for the matrix product, for readable pipelines. */
    public func matmul(rhs: Matrix): Matrix {
        this * rhs
    }

    // ---- equality ---------------------------------------------------------
    public operator func ==(rhs: Matrix): Bool {
        if (rows != rhs.rows || cols != rhs.cols) {
            return false
        }
        for (i in 0..data.size) {
            if (data[i] != rhs.data[i]) {
                return false
            }
        }
        true
    }

    public operator func !=(rhs: Matrix): Bool {
        !(this == rhs)
    }

    public func approxEquals(rhs: Matrix, tol!: Float64 = 1e-9): Bool {
        if (rows != rhs.rows || cols != rhs.cols) {
            return false
        }
        for (i in 0..data.size) {
            if (abs(data[i] - rhs.data[i]) > tol) {
                return false
            }
        }
        true
    }

    // ---- conversions & helpers -------------------------------------------
    public func toArray(): Array<Float64> {
        copyOf(data)
    }

    public func to2D(): Array<Array<Float64>> {
        let out = Array<Array<Float64>>(rows, {_ => Array<Float64>(cols, repeat: 0.0)})
        for (i in 0..rows) {
            for (j in 0..cols) {
                out[i][j] = data[i * cols + j]
            }
        }
        out
    }

    func requireSquare(): Unit {
        if (rows != cols) {
            throw NonSquareMatrixException("operation requires a square matrix, got ${rows}x${cols}")
        }
    }

    func checkSameShape(other: Matrix): Unit {
        if (rows != other.rows || cols != other.cols) {
            throw DimensionMismatchException("shape mismatch: ${rows}x${cols} vs ${other.rows}x${other.cols}")
        }
    }

    public func toString(): String {
        formatGrid(data, rows, cols, 4)
    }
}
