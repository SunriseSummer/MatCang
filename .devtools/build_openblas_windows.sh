#!/usr/bin/env bash
# Cross-build the vendored Windows x64 OpenBLAS runtime from source (mingw-w64)
# and assemble the self-contained DLL bundle under
# third_party/openblas/lib/windows_x86_64/.
#
# Requirements: git, gcc-mingw-w64-x86-64, gfortran-mingw-w64-x86-64, make.
set -euo pipefail

VERSION="v0.3.33"
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BUILD_DIR="${REPO_ROOT}/.openblas-win-build"
DEST="${REPO_ROOT}/third_party/openblas/lib/windows_x86_64"
JOBS="$(nproc 2>/dev/null || echo 4)"

echo ">> cloning OpenBLAS ${VERSION}"
rm -rf "${BUILD_DIR}"
git clone --depth 1 --branch "${VERSION}" \
    https://github.com/OpenMathLib/OpenBLAS.git "${BUILD_DIR}"

echo ">> cross-building for x86_64-w64-mingw32 (DYNAMIC_ARCH, ${JOBS} jobs)"
make -C "${BUILD_DIR}" -j"${JOBS}" BINARY=64 HOSTCC=gcc \
    CC=x86_64-w64-mingw32-gcc FC=x86_64-w64-mingw32-gfortran \
    DYNAMIC_ARCH=1 NO_WARMUP=1 NUM_THREADS=64

echo ">> assembling bundle in ${DEST}"
mkdir -p "${DEST}"
cp "${BUILD_DIR}/libopenblas.dll" "${DEST}/"
cp "${BUILD_DIR}/libopenblas.dll.a" "${DEST}/"
cp "${DEST}/libopenblas.dll" "${DEST}/openblas.dll" # cjpm runtime wants no lib prefix

# bundle the matching (win32-threads) mingw runtime DLLs the DLL depends on
GCCDIR="$(dirname "$(x86_64-w64-mingw32-gcc -print-libgcc-file-name)")"
for dll in libgcc_s_seh-1 libgfortran-5 libquadmath-0; do
    cp "${GCCDIR}/${dll}.dll" "${DEST}/"
done
cp /usr/x86_64-w64-mingw32/lib/libwinpthread-1.dll "${DEST}/" 2>/dev/null || true

echo ">> done. Bundle:"
ls -1 "${DEST}"
