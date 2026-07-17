# Quantum spin — the smallest Hermitian eigenproblem

A spin-½ particle (a qubit) in a magnetic field is the simplest non-trivial
quantum system, and it is genuinely complex: its states live in `ℂ²` and its
Hamiltonian is a `2×2` **Hermitian** matrix. Diagonalising it is exactly what
`eigHermitian` is for — real energies, complex eigenstates.

## The physics

For a field along the unit vector `n`, the Hamiltonian is

```
H = (E/2) (n_x σ_x + n_y σ_y + n_z σ_z),
```

with the Pauli matrices

```
σ_x = [[0, 1],[1, 0]],   σ_y = [[0,-i],[i, 0]],   σ_z = [[1, 0],[0,-1]].
```

Quantum mechanics predicts the energies are exactly `±E/2`, and the two
eigenstates are spin **aligned** / **anti-aligned** with the field: the
expectation `⟨ψ| n·σ |ψ⟩` is `+1` for the excited state and `−1` for the ground
state.

## How matcang is used

- Pauli matrices and `H` are `ComplexMatrix` values (`+`, complex scaling);
- `matcang.linalg.eigHermitian` (LAPACK `zheev`) returns the real spectrum and
  orthonormal complex eigenvectors;
- `ComplexVector.dotc` (the Hermitian inner product) computes normalisation,
  orthogonality and the spin expectation values.

See [`src/main.cj`](src/main.cj).

## Running

```bash
cjpm run
```

## What the end-to-end test checks

Exits non-zero unless: the energies are `±E/2`; the eigenstates are orthonormal
under the Hermitian inner product; `H|ψ⟩ = E|ψ⟩`; and the spin expectation
`⟨ψ| n·σ |ψ⟩` equals `−1` (ground) and `+1` (excited) — i.e. the spin is
perfectly (anti)aligned with the field.
