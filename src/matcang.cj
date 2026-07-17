/*
 * matcang - a modern, elegant matrix computation library for Cangjie.
 *
 * This root package hosts the generated OpenBLAS bindings (ffi_*.cj), their
 * public canonical-name wrappers (*_binding.cj), the C-interop value types
 * (interop_types.cj) and the runtime control API (control.cj). The ergonomic
 * surface lives in the matcang.core / matcang.blas / matcang.linalg
 * subpackages; import matcang.prelude.* to get all of it at once.
 */
package matcang

/** Library version (kept in step with cjpm.toml). */
public const VERSION: String = "1.1.0"
