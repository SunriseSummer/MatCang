# DFT spectrum — the Fourier transform is a matrix

The Discrete Fourier Transform of a length-`N` signal is *literally* a
multiplication by the `N×N` Fourier matrix `F`, with

```
F[j,k] = exp(-2πi · j · k / N).
```

This example builds `F` as a `ComplexMatrix`, transforms a synthesised signal
with a single complex matrix–vector product, reads the frequency content off
the magnitude spectrum, and reconstructs the signal with the inverse transform.

## The mathematics

The forward transform is `X = F x`. Since `F` is symmetric and `Fᴴ F = N·I`,
the inverse is simply

```
x = (1/N) Fᴴ X.
```

The test signal is a sum of two pure tones (a full-amplitude cosine at bin 5
and a half-amplitude cosine at bin 12). A real signal has a conjugate-symmetric
spectrum, so each tone shows up as a peak in the lower half of `|X|`.

## How matcang is used

- `ComplexMatrix` / `ComplexVector` hold `F` and the signal;
- `F * x` is a complex `zgemv`; `F.h` is the conjugate transpose (Hermitian
  adjoint) used by the inverse transform;
- `Complex.abs` gives the magnitude spectrum.

See [`src/main.cj`](src/main.cj).

## Running

```bash
cjpm run
```

## What the end-to-end test checks

Exits non-zero unless the two dominant spectral peaks land **exactly** on the
injected bins (5 and 12), the amplitude ordering is right (bin 5 dominates bin
12), and the inverse DFT reconstructs the original samples to `1e-9`.
