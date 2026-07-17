/*
 * matcang.prelude - the one-stop import surface.
 *
 * `import matcang.prelude.*` brings the whole ergonomic API (core types, BLAS
 * helpers and the linear-algebra routines) into scope. This is the single
 * deliberate wildcard re-export in the library; individual layers can still be
 * imported directly (matcang.core, matcang.blas, matcang.linalg) when narrower
 * dependencies are preferred.
 */
package matcang.prelude

public import matcang.core.*
public import matcang.blas.*
public import matcang.linalg.*
