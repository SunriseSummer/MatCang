# GPS trilateration — "where am I?" as nonlinear least squares

Four satellites, four noisy range measurements, one unknown position: the
problem every GPS receiver, surveying rig and sensor network solves — cracked
here with six lines of Gauss–Newton around `lstsq`.

## The mathematics

Each satellite `sᵢ` with measured distance `dᵢ` contributes a nonlinear
residual `rᵢ(x) = ‖sᵢ − x‖ − dᵢ`. Gauss–Newton repeatedly linearises:

```
J·dx ≈ −r        row i of J:  (x − sᵢ)ᵀ / ‖sᵢ − x‖
x ← x + dx       dx from lstsq(J, −r)
```

Near the solution the iteration converges superlinearly — watch the residual
column collapse from 13.9 to 1.6e-3 in four steps, starting from a guess ~15
units away.

## How matcang is used

`lstsq` (LAPACK `dgelsd`) solves each linearised step; `Vector` arithmetic and
norms drive the loop. The same pattern (Jacobian + `lstsq`) powers curve
fitting, camera calibration and bundle adjustment.

## Running

```bash
cjpm run
```

## What the end-to-end test checks

The residual must shrink by >100× within three iterations (fast convergence),
and the final position must agree with the ground truth to measurement-noise
accuracy (< 0.01).
