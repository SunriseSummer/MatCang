/*
 * matcang.core - left-hand scalar operators, so `2.0 * m` reads as naturally
 * as `m * 2.0`.
 *
 * Cangjie never exports a *direct* extension of a foreign type (Float64 lives
 * in std.core), so the operators are attached through a local public interface
 * instead: an interface extension is exported with the interface's visibility,
 * and callers activate it simply by importing `ScalarOps` (the prelude re-
 * exports it, so `import matcang.prelude.*` is enough).
 */
package matcang.core

/**
 * Left scalar multiplication for Float64: import this interface to write
 * `2.0 * m` and `2.0 * v` outside the matcang.core package.
 */
public interface ScalarOps {
    operator func *(m: Matrix): Matrix
    operator func *(v: Vector): Vector
}

extend Float64 <: ScalarOps {
    public operator func *(m: Matrix): Matrix {
        m * this
    }

    public operator func *(v: Vector): Vector {
        v * this
    }
}
