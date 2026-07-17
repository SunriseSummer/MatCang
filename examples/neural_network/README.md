# Neural network — learning XOR with back-propagation

Train a small multi-layer perceptron (MLP) to compute the XOR function — the
classic example that a single linear layer provably *cannot* solve, motivating
hidden layers and non-linear activations.

## The mathematics

A two-layer network with a hidden layer of width `h` and sigmoid activations:

```
forward:   A₁ = σ(W₁ X + b₁)          A₂ = σ(W₂ A₁ + b₂)
loss:      L  = mean((A₂ − Y)²)
backward:  δ₂ = (A₂ − Y) ⊙ σ'(A₂)     dW₂ = δ₂ A₁ᵀ
           δ₁ = (W₂ᵀ δ₂) ⊙ σ'(A₁)     dW₁ = δ₁ Xᵀ
update:    W ← W − η dW
```

All four XOR samples are batched as the columns of a `2 × 4` input matrix `X`, so
each layer is a single matrix multiply over the whole dataset.

## How matcang is used

- **Forward pass**: `W * X` uses BLAS `dgemm` through matcang's `*` operator.
- **Back-propagation**: the gradients `δ₂ A₁ᵀ`, `W₂ᵀ δ₂` and `δ₁ Xᵀ` are matrix
  multiplies with a **transposed operand** — expressed as `dz2 * a1.t`,
  `w2.t * dz2`, `dz1 * x.t`. This is the example's showcase of transpose-aware
  BLAS.
- **Activations** use `Matrix.map` (sigmoid) and `hadamard` (element-wise
  gradient product).
- **Initialisation** uses `Matrix.randomNormal`.

## Running

```bash
cjpm run
```

Expected output:

```
epoch 0: loss = 0.37...
...
final loss     : 0.000...
predictions    : [ 0.02...  0.98...  0.98...  0.02... ]
targets        : [ 0.0000  1.0000  1.0000  0.0000 ]
correct        : 4 / 4
OK
```

## What the end-to-end test checks

Exits non-zero unless, after training, all four inputs are classified correctly
and the final loss is below `0.01` — i.e. the network genuinely learned XOR.
