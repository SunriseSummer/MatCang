# ALS recommender — matrix factorisation at application scale

The Netflix-Prize workhorse end to end: recover the low-rank structure of a
partially observed rating matrix by **Alternating Least Squares** and predict
the held-out ratings.

## The mathematics

Model `R ≈ U Vᵀ` with `U ∈ R^{users×k}`, `V ∈ R^{items×k}`. With one side
fixed, each row of the other solves an independent ridge system over its
observed entries:

```
(Fᵀ F + λI) x = Fᵀ r        — k×k, symmetric positive definite
```

Alternating the two sides monotonically decreases the regularised training
loss. Prediction is a single `U Vᵀ`.

## Why it is the "larger application" example

Unlike the single-algorithm demos, this wires several components together:
synthetic data generation, train/test masking, an iterative optimiser that
issues **hundreds of small SPD solves per sweep** (`solveSPDMatrix` on k×k
Gram matrices), RMSE tracking, and a baseline comparison — ~200 lines of
application logic on the matcang API.

## Running

```bash
cjpm run
```

Expected: training RMSE drops from ~1.37 to ~0.046 in a dozen sweeps; held-out
test RMSE ~0.055 versus ~1.81 for the predict-the-mean baseline (≈33× better).

## What the end-to-end test checks

Exits non-zero unless training RMSE decreases monotonically, the test RMSE
beats the global-mean baseline by at least 5×, and the planted structure is
recovered (test RMSE ≤ 0.15).
