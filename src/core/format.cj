/*
 * matcang.core - number and grid formatting helpers used by the pretty
 * printers of Matrix and Vector.
 */
package matcang.core

import std.math.*

/**
 * Format a Float64 with a fixed number of decimals, without relying on the
 * platform default (which always prints 6 decimals). Small, dependency-free
 * and good enough for human-readable matrix output.
 */
func formatFixed(x: Float64, decimals: Int64): String {
    if (x != x) {
        return "nan"
    }
    var v = x
    var sign = ""
    if (v < 0.0) {
        sign = "-"
        v = -v
    }
    let p = pow(10.0, Float64(decimals))
    // Values whose scaled form does not fit an Int64 (huge finite values or
    // infinities) fall back to the default float representation instead of
    // overflowing the conversion below.
    if (v * p >= 9.0e18) {
        return "${x}"
    }
    let scaled = Int64(round(v * p))
    let ip = Int64(p)
    let intPart = scaled / ip
    if (decimals == 0) {
        return sign + "${intPart}"
    }
    let frac = scaled % ip
    var fracStr = "${frac}"
    while (fracStr.size < decimals) {
        fracStr = "0" + fracStr
    }
    return sign + "${intPart}." + fracStr
}

/** Left-pad `s` with spaces to `width`. */
func padLeft(s: String, width: Int64): String {
    var out = s
    while (out.size < width) {
        out = " " + out
    }
    return out
}

/**
 * Render a row-major numeric buffer as an aligned grid, e.g.
 *   [  1.0000   2.0000 ]
 *   [  3.0000   4.0000 ]
 */
func formatGrid(data: Array<Float64>, rows: Int64, cols: Int64, decimals: Int64): String {
    if (rows == 0 || cols == 0) {
        return "[ ] (${rows}x${cols})"
    }
    let cells = Array<String>(data.size, repeat: "")
    var width = 0
    for (idx in 0..data.size) {
        let s = formatFixed(data[idx], decimals)
        cells[idx] = s
        if (s.size > width) {
            width = s.size
        }
    }
    let sb = StringBuilder()
    for (i in 0..rows) {
        sb.append("[ ")
        for (j in 0..cols) {
            sb.append(padLeft(cells[i * cols + j], width))
            if (j < cols - 1) {
                sb.append("  ")
            }
        }
        sb.append(" ]")
        if (i < rows - 1) {
            sb.append("\n")
        }
    }
    return sb.toString()
}
