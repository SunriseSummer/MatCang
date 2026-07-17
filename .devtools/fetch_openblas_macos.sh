#!/usr/bin/env bash
# Fetch the macOS arm64 OpenBLAS 0.3.33 runtime (conda-forge) and assemble a
# self-contained bundle under third_party/openblas/lib/macos_arm64/ by bundling
# the Fortran runtime and rewriting every inter-library reference to @loader_path.
#
# Cross-building OpenBLAS for macOS from Linux is impractical (no darwin Fortran
# cross-compiler), so we relocate the official conda-forge binary instead.
#
# Requirements: curl, unzip, zstd, llvm-otool, llvm-install-name-tool.
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DEST="${REPO_ROOT}/.openblas/lib/macos_arm64"
WORK="${REPO_ROOT}/.openblas-mac-work"
CHANNEL="https://conda.anaconda.org/conda-forge/osx-arm64"

# conda-forge package files (pinned to OpenBLAS 0.3.33 + its runtime deps)
OPENBLAS_PKG="libopenblas-0.3.33-pthreads_hddb8425_0.conda"
GFORTRAN_PKG="libgfortran5-15.2.0-hdae7583_19.conda"
LIBGCC_PKG="libgcc-15.2.0-hcbb3090_19.conda"

OTOOL="$(command -v llvm-otool llvm-otool-18 2>/dev/null | head -1)"
INT="$(command -v llvm-install-name-tool llvm-install-name-tool-18 2>/dev/null | head -1)"

rm -rf "${WORK}"; mkdir -p "${WORK}/extracted"
for pkg in "${OPENBLAS_PKG}" "${GFORTRAN_PKG}" "${LIBGCC_PKG}"; do
    echo ">> ${pkg}"
    curl -fsSL -o "${WORK}/p.conda" "${CHANNEL}/${pkg}"
    (cd "${WORK}" && unzip -o p.conda "pkg-*.tar.zst" >/dev/null && \
        tar --zstd -xf pkg-*.tar.zst -C extracted && rm -f p.conda pkg-*.tar.zst)
done

echo ">> assembling self-contained bundle"
rm -rf "${DEST}"; mkdir -p "${DEST}"
BUNDLED="libopenblas.0.dylib libgfortran.5.dylib libquadmath.0.dylib libgcc_s.1.1.dylib"
for lib in ${BUNDLED}; do
    cp "${WORK}/extracted/lib/${lib}" "${DEST}/"
done
chmod u+w "${DEST}"/*.dylib

for dylib in ${BUNDLED}; do
    for dep in $("${OTOOL}" -L "${DEST}/${dylib}" | tail -n +2 | awk '{print $1}'); do
        base="$(basename "${dep}")"
        case "${dep}" in
            @rpath/*)
                for b in ${BUNDLED}; do
                    [ "${base}" = "${b}" ] && "${INT}" -change "${dep}" "@loader_path/${b}" "${DEST}/${dylib}"
                done ;;
        esac
    done
    "${INT}" -id "@loader_path/${dylib}" "${DEST}/${dylib}"
done
ln -sf libopenblas.0.dylib "${DEST}/libopenblas.dylib"

echo ">> done. Bundle (only /usr/lib/libSystem should remain external):"
"${OTOOL}" -L "${DEST}/libopenblas.0.dylib" | tail -n +2
