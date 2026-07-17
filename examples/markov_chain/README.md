# Markov chains — tomorrow's weather, the long run, and how fast we forget

A three-state weather model answers three timeless questions with three
one-liners of linear algebra.

## The mathematics

With column-stochastic transitions `P` (column j = "given state j today"):

1. **Forecasting**: the distribution k days out is `Pᵏ · today` — one
   `matrixPower` call.
2. **Climate**: the stationary distribution `π` satisfies `P π = π`, found by
   replacing one (dependent) balance equation with the normalisation
   `∑πᵢ = 1` and calling `solve`.
3. **Mixing speed**: initial conditions are forgotten geometrically at rate
   `|λ₂|`, the second-largest eigenvalue modulus — the *spectral gap* rules how
   quickly "certainly sunny today" fades into climate.

The example verifies all three against each other: `P³⁰·today` matches the
solved `π` to 1e-9, and the *measured* per-step decay of forecast error
matches `|λ₂|` from `eigenvalues` to 2%.

## How matcang is used

`matrixPower` (repeated squaring), `solve` (stationary distribution),
`eigenvalues` (complex spectrum → spectral gap), and vector norms.

## Running

```bash
cjpm run
```

## What the end-to-end test checks

Every `Pᵏ·today` remains a probability distribution; the 30-day forecast
equals the stationary solve; measured mixing rate matches `|λ₂|`.
