/*
 * matcang.core - slicing, stacking, axis reductions and broadcasting.
 *
 * These extensions round out the Matrix/Vector API with the everyday
 * data-wrangling operations that applications otherwise hand-roll:
 *
 *   m[1..3, 0..2]      rectangular slice (any Range, including ..= and steps)
 *   m[2, 0..4]         one row's slice as a Vector; m[0..4, 2] one column's
 *   Matrix.vstack(...) / Matrix.hstack(...)
 *   m.rowSums() / colSums() / rowMeans() / colMeans()
 *   m.addRowVector(v) / addColVector(v)   broadcast add
 *   m.flatten(), v.toColumnMatrix(), v.toRowMatrix(), Vector.concat(...)
 *
 * All slices copy (matcang matrices are dense row-major buffers); they never
 * alias the source.
 */
package matcang.core

extend Matrix {
    /** Rectangular slice: the rows and columns selected by the two ranges. */
    public operator func [](rowRange: Range<Int64>, colRange: Range<Int64>): Matrix {
        let ri = collectIndices(rowRange, rows, "row")
        let ci = collectIndices(colRange, cols, "column")
        let out = Matrix(ri.size, ci.size)
        for (a in 0..ri.size) {
            let srcRow = ri[a] * cols
            for (b in 0..ci.size) {
                out.data[a * ci.size + b] = data[srcRow + ci[b]]
            }
        }
        out
    }

    /** Slice of row `i`: the entries at `i, colRange` as a Vector. */
    public operator func [](i: Int64, colRange: Range<Int64>): Vector {
        checkIndex(i, 0)
        let ci = collectIndices(colRange, cols, "column")
        Vector.build(ci.size) {b => data[i * cols + ci[b]]}
    }

    /** Slice of column `j`: the entries at `rowRange, j` as a Vector. */
    public operator func [](rowRange: Range<Int64>, j: Int64): Vector {
        checkIndex(0, j)
        let ri = collectIndices(rowRange, rows, "row")
        Vector.build(ri.size) {a => data[ri[a] * cols + j]}
    }

    /** Stack matrices top-to-bottom (all must share the column count). */
    public static func vstack(parts: Array<Matrix>): Matrix {
        if (parts.size == 0) {
            return Matrix(0, 0)
        }
        let c = parts[0].cols
        var totalRows = 0
        for (p in parts) {
            if (p.cols != c) {
                throw DimensionMismatchException("vstack: expected ${c} columns, got ${p.cols}")
            }
            totalRows += p.rows
        }
        let out = Matrix(totalRows, c)
        var offset = 0
        for (p in parts) {
            for (k in 0..p.data.size) {
                out.data[offset + k] = p.data[k]
            }
            offset += p.data.size
        }
        out
    }

    /** Stack matrices left-to-right (all must share the row count). */
    public static func hstack(parts: Array<Matrix>): Matrix {
        if (parts.size == 0) {
            return Matrix(0, 0)
        }
        let r = parts[0].rows
        var totalCols = 0
        for (p in parts) {
            if (p.rows != r) {
                throw DimensionMismatchException("hstack: expected ${r} rows, got ${p.rows}")
            }
            totalCols += p.cols
        }
        let out = Matrix(r, totalCols)
        var colOffset = 0
        for (p in parts) {
            for (i in 0..r) {
                for (j in 0..p.cols) {
                    out.data[i * totalCols + colOffset + j] = p.data[i * p.cols + j]
                }
            }
            colOffset += p.cols
        }
        out
    }

    /** Sum of each row (length-`rows` vector). */
    public func rowSums(): Vector {
        let out = Vector(rows)
        for (i in 0..rows) {
            var s = 0.0
            for (j in 0..cols) {
                s += data[i * cols + j]
            }
            out.data[i] = s
        }
        out
    }

    /** Sum of each column (length-`cols` vector). */
    public func colSums(): Vector {
        let out = Vector(cols)
        for (i in 0..rows) {
            let base = i * cols
            for (j in 0..cols) {
                out.data[j] += data[base + j]
            }
        }
        out
    }

    /** Mean of each row. */
    public func rowMeans(): Vector {
        if (cols == 0) {
            return Vector(rows)
        }
        rowSums() / Float64(cols)
    }

    /** Mean of each column. */
    public func colMeans(): Vector {
        if (rows == 0) {
            return Vector(cols)
        }
        colSums() / Float64(rows)
    }

    /** Broadcast add: `v` (length `cols`) is added to every row. */
    public func addRowVector(v: Vector): Matrix {
        if (v.size != cols) {
            throw DimensionMismatchException("addRowVector: length ${v.size} != cols ${cols}")
        }
        mapIndexed {_, j, x => x + v.data[j]}
    }

    /** Broadcast add: `v` (length `rows`) is added to every column. */
    public func addColVector(v: Vector): Matrix {
        if (v.size != rows) {
            throw DimensionMismatchException("addColVector: length ${v.size} != rows ${rows}")
        }
        mapIndexed {i, _, x => x + v.data[i]}
    }

    /** All entries as one row-major Vector (copies). */
    public func flatten(): Vector {
        Vector(copyOf(data))
    }
}

extend Vector {
    /** Slice: the entries selected by `range` (copies). */
    public operator func [](range: Range<Int64>): Vector {
        let idx = collectIndices(range, data.size, "index")
        Vector.build(idx.size) {k => data[idx[k]]}
    }

    /** Concatenate vectors end-to-end. */
    public static func concat(parts: Array<Vector>): Vector {
        var total = 0
        for (p in parts) {
            total += p.size
        }
        let out = Vector(total)
        var offset = 0
        for (p in parts) {
            for (k in 0..p.size) {
                out.data[offset + k] = p.data[k]
            }
            offset += p.size
        }
        out
    }

    /** This vector as an n-by-1 matrix (copies). */
    public func toColumnMatrix(): Matrix {
        Matrix(data.size, 1, copyOf(data))
    }

    /** This vector as a 1-by-n matrix (copies). */
    public func toRowMatrix(): Matrix {
        Matrix(1, data.size, copyOf(data))
    }
}

/** Validate a range against `limit` and expand it to explicit indices. */
func collectIndices(range: Range<Int64>, limit: Int64, what: String): Array<Int64> {
    var count = 0
    for (i in range) {
        if (i < 0 || i >= limit) {
            throw MatCangException("${what} ${i} out of bounds [0, ${limit})")
        }
        count += 1
    }
    let idx = Array<Int64>(count, repeat: 0)
    var k = 0
    for (i in range) {
        idx[k] = i
        k += 1
    }
    idx
}
