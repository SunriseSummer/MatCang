# Kalman filter — tracking from noisy measurements

Estimate the position and velocity of an object moving at (roughly) constant
velocity, given only noisy position measurements. The **Kalman filter** is the
optimal linear recursive estimator for this problem and a cornerstone of signal
processing, navigation and control.

## The mathematics

The state is `x = [position, velocity]ᵀ`. Each step alternates *predict* and
*update*:

```
predict:  x⁻ = F x            P⁻ = F P Fᵀ + Q
update:   y  = z − H x⁻       S  = H P⁻ Hᵀ + R
          K  = P⁻ Hᵀ S⁻¹      x  = x⁻ + K y
          P  = (I − K H) P⁻
```

with transition `F = [[1, dt],[0, 1]]`, measurement `H = [[1, 0]]`, and process /
measurement noise covariances `Q`, `R`. `K` is the Kalman gain balancing the
model prediction against the new measurement.

## How matcang is used

The entire recursion is written directly with matcang operators: matrix product
`*`, transpose `.t`, addition/subtraction, and `matcang.linalg.inverse` for the
innovation covariance `S`. The state and all covariances are small `Matrix`
values, so the code mirrors the equations line for line (see
[`src/main.cj`](src/main.cj), function `kalmanStep`).

## Running

```bash
cjpm run
```

Expected output (deterministic seed):

```
Kalman filter — constant-velocity tracking
  measurement RMSE     : 7.38...
  filtered   RMSE      : 2.84...
  final velocity est.  : 1.05... (true 1.000000)
  error reduction      : 61...%
OK
```

## What the end-to-end test checks

The program exits non-zero unless the filtered track's RMSE against the ground
truth is strictly smaller than the raw measurement RMSE, and the estimated
velocity has converged to the true value within 0.2. In other words, it fails
unless the filter actually filters.
