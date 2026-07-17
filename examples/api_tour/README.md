# API tour — the whole surface, one runnable file

Executable documentation: every public API area of matcang demonstrated in a
small, self-checking snippet — construction (including the `Matrix([[1, 2],
[3, 4]])` literal form), indexing/slicing/stacking, axis reductions and
broadcasting, BLAS-backed operators, the explicit `matcang.blas` layer, every
solver and factorisation in `matcang.linalg`, the `try*` API, typed exceptions,
`Complex`, and the runtime-control functions.

Read `src/main.cj` top to bottom as a tutorial; run it as a test:

```bash
cjpm run
```

Every line of output is `ok <check>`; any failure flips the exit code, so this
example doubles as a whole-API regression test. See `docs/API.md` for the
reference these snippets illustrate.
