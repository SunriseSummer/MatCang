# RLC circuit — AC analysis with complex phasors

Alternating-current circuit analysis is complex linear algebra. In the phasor
domain each element is a complex **impedance**

```
Z_R = R,    Z_L = jωL,    Z_C = 1/(jωC),
```

and Kirchhoff's mesh equations become one complex linear system `Z I = V` for
the mesh currents. matcang solves it directly with the complex `solve`.

## The circuit

A source `Vs` drives `R1` into a shared coupling resistor `Rc` (mesh 1); mesh 2
is a series `R2–L–C` loop closed through `Rc`. Because the meshes couple through
a frequency-flat resistor, mesh 2 keeps a clean series resonance at
`ω₀ = 1/√(LC)`.

## How matcang is used

- `ComplexMatrix` holds the 2×2 mesh-impedance matrix `Z(ω)`;
- `matcang.linalg.solve(Z, V)` (LAPACK `zgesv`) returns the phasor currents;
- scalar `Complex` arithmetic computes powers and an independent cross-check.

See [`src/main.cj`](src/main.cj).

## Running

```bash
cjpm run
```

## What the end-to-end test checks

Exits non-zero unless all three hold:

1. **Real power is conserved** — the source's real power `Re(Vs · conj(I₁))`
   equals the total resistive dissipation `R1|I₁|² + Rc|I₁−I₂|² + R2|I₂|²`.
2. **The solver is correct** — matcang's complex `solve` matches an independent
   Cramer's-rule solution of the 2×2 system to `1e-9`.
3. **Resonance is physical** — a frequency sweep peaks in `|I₂|` at the analytic
   series resonance `ω₀ = 1/√(LC)`.
