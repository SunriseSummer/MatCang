#!/usr/bin/env bash
# Rebuild the vendored OpenBLAS runtime from source.
#
# Produces a portable DYNAMIC_ARCH build (runtime CPU dispatch) and installs the
# shared library + headers into third_party/openblas, then refreshes the symbol
# allowlist and regenerates the Cangjie bindings.
#
# Requirements: git, gcc, gfortran, make.
set -euo pipefail

VERSION="v0.3.33"
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BUILD_DIR="${REPO_ROOT}/.openblas-build"
PREFIX="${REPO_ROOT}/third_party/openblas"
JOBS="$(nproc 2>/dev/null || echo 4)"

echo ">> cloning OpenBLAS ${VERSION}"
rm -rf "${BUILD_DIR}"
git clone --depth 1 --branch "${VERSION}" \
    https://github.com/OpenMathLib/OpenBLAS.git "${BUILD_DIR}"

echo ">> building (DYNAMIC_ARCH, ${JOBS} jobs)"
make -C "${BUILD_DIR}" -j"${JOBS}" FC=gfortran CC=gcc USE_THREAD=1 DYNAMIC_ARCH=1 NO_WARMUP=1

echo ">> installing into ${PREFIX}"
rm -rf "${PREFIX}/lib" "${PREFIX}/include"
make -C "${BUILD_DIR}" PREFIX="${PREFIX}" install

echo ">> refreshing symbol allowlist"
nm -D --defined-only "${PREFIX}/lib/libopenblas.so" \
    | awk '{print $NF}' \
    | grep -E '^(cblas_|LAPACKE_|openblas_|goto_|blas_)' \
    | sort -u > "${PREFIX}/openblas_symbols.txt"

echo ">> regenerating bindings"
rm -f "${REPO_ROOT}"/matcang/src/ffi_cblas.cj \
      "${REPO_ROOT}"/matcang/src/ffi_openblas_util.cj \
      "${REPO_ROOT}"/matcang/src/ffi_lapacke_*.cj \
      "${REPO_ROOT}"/matcang/src/blas_binding.cj \
      "${REPO_ROOT}"/matcang/src/lapack_binding_*.cj
python3 "${REPO_ROOT}/tools/gen_bindings.py" \
    "${PREFIX}/include/cblas.h" "${PREFIX}/include/lapacke.h" \
    "${REPO_ROOT}/matcang/src" work "${PREFIX}/openblas_symbols.txt"

echo ">> done. Rebuild the library with: (cd matcang && cjpm build)"
