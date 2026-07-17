/*
 * Raw foreign declarations for the OpenBLAS C API.
 * AUTO-GENERATED from OpenBLAS v0.3.33 headers (cblas.h / lapacke.h).
 * Do not edit by hand; regenerate with .devtools/gen_bindings.py.
 *
 * These live in the root `matcang` package (not a subpackage) because
 * Cangjie `foreign` functions are package-internal and can carry no access
 * modifier; keeping them at the root lets every matcang.* subpackage call
 * them while remaining hidden from external importers.
 */
package matcang

// CBLAS interface : 201 functions

foreign {
    func cblas_sdsdot(p0: Int32, p1: Float32, p2: CPointer<Float32>, p3: Int32, p4: CPointer<Float32>, p5: Int32): Float32
    func cblas_dsdot(p0: Int32, p1: CPointer<Float32>, p2: Int32, p3: CPointer<Float32>, p4: Int32): Float64
    func cblas_sdot(p0: Int32, p1: CPointer<Float32>, p2: Int32, p3: CPointer<Float32>, p4: Int32): Float32
    func cblas_ddot(p0: Int32, p1: CPointer<Float64>, p2: Int32, p3: CPointer<Float64>, p4: Int32): Float64
    func cblas_cdotu(p0: Int32, p1: CPointer<CxF32>, p2: Int32, p3: CPointer<CxF32>, p4: Int32): CxF32
    func cblas_cdotc(p0: Int32, p1: CPointer<CxF32>, p2: Int32, p3: CPointer<CxF32>, p4: Int32): CxF32
    func cblas_zdotu(p0: Int32, p1: CPointer<CxF64>, p2: Int32, p3: CPointer<CxF64>, p4: Int32): CxF64
    func cblas_zdotc(p0: Int32, p1: CPointer<CxF64>, p2: Int32, p3: CPointer<CxF64>, p4: Int32): CxF64
    func cblas_cdotu_sub(p0: Int32, p1: CPointer<CxF32>, p2: Int32, p3: CPointer<CxF32>, p4: Int32, p5: CPointer<CxF32>): Unit
    func cblas_cdotc_sub(p0: Int32, p1: CPointer<CxF32>, p2: Int32, p3: CPointer<CxF32>, p4: Int32, p5: CPointer<CxF32>): Unit
    func cblas_zdotu_sub(p0: Int32, p1: CPointer<CxF64>, p2: Int32, p3: CPointer<CxF64>, p4: Int32, p5: CPointer<CxF64>): Unit
    func cblas_zdotc_sub(p0: Int32, p1: CPointer<CxF64>, p2: Int32, p3: CPointer<CxF64>, p4: Int32, p5: CPointer<CxF64>): Unit
    func cblas_sasum(p0: Int32, p1: CPointer<Float32>, p2: Int32): Float32
    func cblas_dasum(p0: Int32, p1: CPointer<Float64>, p2: Int32): Float64
    func cblas_scasum(p0: Int32, p1: CPointer<CxF32>, p2: Int32): Float32
    func cblas_dzasum(p0: Int32, p1: CPointer<CxF64>, p2: Int32): Float64
    func cblas_ssum(p0: Int32, p1: CPointer<Float32>, p2: Int32): Float32
    func cblas_dsum(p0: Int32, p1: CPointer<Float64>, p2: Int32): Float64
    func cblas_scsum(p0: Int32, p1: CPointer<CxF32>, p2: Int32): Float32
    func cblas_dzsum(p0: Int32, p1: CPointer<CxF64>, p2: Int32): Float64
    func cblas_snrm2(p0: Int32, p1: CPointer<Float32>, p2: Int32): Float32
    func cblas_dnrm2(p0: Int32, p1: CPointer<Float64>, p2: Int32): Float64
    func cblas_scnrm2(p0: Int32, p1: CPointer<CxF32>, p2: Int32): Float32
    func cblas_dznrm2(p0: Int32, p1: CPointer<CxF64>, p2: Int32): Float64
    func cblas_isamax(p0: Int32, p1: CPointer<Float32>, p2: Int32): UIntNative
    func cblas_idamax(p0: Int32, p1: CPointer<Float64>, p2: Int32): UIntNative
    func cblas_icamax(p0: Int32, p1: CPointer<CxF32>, p2: Int32): UIntNative
    func cblas_izamax(p0: Int32, p1: CPointer<CxF64>, p2: Int32): UIntNative
    func cblas_isamin(p0: Int32, p1: CPointer<Float32>, p2: Int32): UIntNative
    func cblas_idamin(p0: Int32, p1: CPointer<Float64>, p2: Int32): UIntNative
    func cblas_icamin(p0: Int32, p1: CPointer<CxF32>, p2: Int32): UIntNative
    func cblas_izamin(p0: Int32, p1: CPointer<CxF64>, p2: Int32): UIntNative
    func cblas_samax(p0: Int32, p1: CPointer<Float32>, p2: Int32): Float32
    func cblas_damax(p0: Int32, p1: CPointer<Float64>, p2: Int32): Float64
    func cblas_scamax(p0: Int32, p1: CPointer<CxF32>, p2: Int32): Float32
    func cblas_dzamax(p0: Int32, p1: CPointer<CxF64>, p2: Int32): Float64
    func cblas_samin(p0: Int32, p1: CPointer<Float32>, p2: Int32): Float32
    func cblas_damin(p0: Int32, p1: CPointer<Float64>, p2: Int32): Float64
    func cblas_scamin(p0: Int32, p1: CPointer<CxF32>, p2: Int32): Float32
    func cblas_dzamin(p0: Int32, p1: CPointer<CxF64>, p2: Int32): Float64
    func cblas_ismax(p0: Int32, p1: CPointer<Float32>, p2: Int32): UIntNative
    func cblas_idmax(p0: Int32, p1: CPointer<Float64>, p2: Int32): UIntNative
    func cblas_icmax(p0: Int32, p1: CPointer<CxF32>, p2: Int32): UIntNative
    func cblas_izmax(p0: Int32, p1: CPointer<CxF64>, p2: Int32): UIntNative
    func cblas_ismin(p0: Int32, p1: CPointer<Float32>, p2: Int32): UIntNative
    func cblas_idmin(p0: Int32, p1: CPointer<Float64>, p2: Int32): UIntNative
    func cblas_icmin(p0: Int32, p1: CPointer<CxF32>, p2: Int32): UIntNative
    func cblas_izmin(p0: Int32, p1: CPointer<CxF64>, p2: Int32): UIntNative
    func cblas_saxpy(p0: Int32, p1: Float32, p2: CPointer<Float32>, p3: Int32, p4: CPointer<Float32>, p5: Int32): Unit
    func cblas_daxpy(p0: Int32, p1: Float64, p2: CPointer<Float64>, p3: Int32, p4: CPointer<Float64>, p5: Int32): Unit
    func cblas_caxpy(p0: Int32, p1: CPointer<CxF32>, p2: CPointer<CxF32>, p3: Int32, p4: CPointer<CxF32>, p5: Int32): Unit
    func cblas_zaxpy(p0: Int32, p1: CPointer<CxF64>, p2: CPointer<CxF64>, p3: Int32, p4: CPointer<CxF64>, p5: Int32): Unit
    func cblas_caxpyc(p0: Int32, p1: CPointer<CxF32>, p2: CPointer<CxF32>, p3: Int32, p4: CPointer<CxF32>, p5: Int32): Unit
    func cblas_zaxpyc(p0: Int32, p1: CPointer<CxF64>, p2: CPointer<CxF64>, p3: Int32, p4: CPointer<CxF64>, p5: Int32): Unit
    func cblas_scopy(p0: Int32, p1: CPointer<Float32>, p2: Int32, p3: CPointer<Float32>, p4: Int32): Unit
    func cblas_dcopy(p0: Int32, p1: CPointer<Float64>, p2: Int32, p3: CPointer<Float64>, p4: Int32): Unit
    func cblas_ccopy(p0: Int32, p1: CPointer<CxF32>, p2: Int32, p3: CPointer<CxF32>, p4: Int32): Unit
    func cblas_zcopy(p0: Int32, p1: CPointer<CxF64>, p2: Int32, p3: CPointer<CxF64>, p4: Int32): Unit
    func cblas_sswap(p0: Int32, p1: CPointer<Float32>, p2: Int32, p3: CPointer<Float32>, p4: Int32): Unit
    func cblas_dswap(p0: Int32, p1: CPointer<Float64>, p2: Int32, p3: CPointer<Float64>, p4: Int32): Unit
    func cblas_cswap(p0: Int32, p1: CPointer<CxF32>, p2: Int32, p3: CPointer<CxF32>, p4: Int32): Unit
    func cblas_zswap(p0: Int32, p1: CPointer<CxF64>, p2: Int32, p3: CPointer<CxF64>, p4: Int32): Unit
    func cblas_srot(p0: Int32, p1: CPointer<Float32>, p2: Int32, p3: CPointer<Float32>, p4: Int32, p5: Float32, p6: Float32): Unit
    func cblas_drot(p0: Int32, p1: CPointer<Float64>, p2: Int32, p3: CPointer<Float64>, p4: Int32, p5: Float64, p6: Float64): Unit
    func cblas_csrot(p0: Int32, p1: CPointer<CxF32>, p2: Int32, p3: CPointer<CxF32>, p4: Int32, p5: Float32, p6: Float32): Unit
    func cblas_zdrot(p0: Int32, p1: CPointer<CxF64>, p2: Int32, p3: CPointer<CxF64>, p4: Int32, p5: Float64, p6: Float64): Unit
    func cblas_srotg(p0: CPointer<Float32>, p1: CPointer<Float32>, p2: CPointer<Float32>, p3: CPointer<Float32>): Unit
    func cblas_drotg(p0: CPointer<Float64>, p1: CPointer<Float64>, p2: CPointer<Float64>, p3: CPointer<Float64>): Unit
    func cblas_crotg(p0: CPointer<CxF32>, p1: CPointer<CxF32>, p2: CPointer<Float32>, p3: CPointer<CxF32>): Unit
    func cblas_zrotg(p0: CPointer<CxF64>, p1: CPointer<CxF64>, p2: CPointer<Float64>, p3: CPointer<CxF64>): Unit
    func cblas_srotm(p0: Int32, p1: CPointer<Float32>, p2: Int32, p3: CPointer<Float32>, p4: Int32, p5: CPointer<Float32>): Unit
    func cblas_drotm(p0: Int32, p1: CPointer<Float64>, p2: Int32, p3: CPointer<Float64>, p4: Int32, p5: CPointer<Float64>): Unit
    func cblas_srotmg(p0: CPointer<Float32>, p1: CPointer<Float32>, p2: CPointer<Float32>, p3: Float32, p4: CPointer<Float32>): Unit
    func cblas_drotmg(p0: CPointer<Float64>, p1: CPointer<Float64>, p2: CPointer<Float64>, p3: Float64, p4: CPointer<Float64>): Unit
    func cblas_sscal(p0: Int32, p1: Float32, p2: CPointer<Float32>, p3: Int32): Unit
    func cblas_dscal(p0: Int32, p1: Float64, p2: CPointer<Float64>, p3: Int32): Unit
    func cblas_cscal(p0: Int32, p1: CPointer<CxF32>, p2: CPointer<CxF32>, p3: Int32): Unit
    func cblas_zscal(p0: Int32, p1: CPointer<CxF64>, p2: CPointer<CxF64>, p3: Int32): Unit
    func cblas_csscal(p0: Int32, p1: Float32, p2: CPointer<CxF32>, p3: Int32): Unit
    func cblas_zdscal(p0: Int32, p1: Float64, p2: CPointer<CxF64>, p3: Int32): Unit
    func cblas_sgemv(p0: Int32, p1: Int32, p2: Int32, p3: Int32, p4: Float32, p5: CPointer<Float32>, p6: Int32, p7: CPointer<Float32>, p8: Int32, p9: Float32, p10: CPointer<Float32>, p11: Int32): Unit
    func cblas_dgemv(p0: Int32, p1: Int32, p2: Int32, p3: Int32, p4: Float64, p5: CPointer<Float64>, p6: Int32, p7: CPointer<Float64>, p8: Int32, p9: Float64, p10: CPointer<Float64>, p11: Int32): Unit
    func cblas_cgemv(p0: Int32, p1: Int32, p2: Int32, p3: Int32, p4: CPointer<CxF32>, p5: CPointer<CxF32>, p6: Int32, p7: CPointer<CxF32>, p8: Int32, p9: CPointer<CxF32>, p10: CPointer<CxF32>, p11: Int32): Unit
    func cblas_zgemv(p0: Int32, p1: Int32, p2: Int32, p3: Int32, p4: CPointer<CxF64>, p5: CPointer<CxF64>, p6: Int32, p7: CPointer<CxF64>, p8: Int32, p9: CPointer<CxF64>, p10: CPointer<CxF64>, p11: Int32): Unit
    func cblas_sger(p0: Int32, p1: Int32, p2: Int32, p3: Float32, p4: CPointer<Float32>, p5: Int32, p6: CPointer<Float32>, p7: Int32, p8: CPointer<Float32>, p9: Int32): Unit
    func cblas_dger(p0: Int32, p1: Int32, p2: Int32, p3: Float64, p4: CPointer<Float64>, p5: Int32, p6: CPointer<Float64>, p7: Int32, p8: CPointer<Float64>, p9: Int32): Unit
    func cblas_cgeru(p0: Int32, p1: Int32, p2: Int32, p3: CPointer<CxF32>, p4: CPointer<CxF32>, p5: Int32, p6: CPointer<CxF32>, p7: Int32, p8: CPointer<CxF32>, p9: Int32): Unit
    func cblas_cgerc(p0: Int32, p1: Int32, p2: Int32, p3: CPointer<CxF32>, p4: CPointer<CxF32>, p5: Int32, p6: CPointer<CxF32>, p7: Int32, p8: CPointer<CxF32>, p9: Int32): Unit
    func cblas_zgeru(p0: Int32, p1: Int32, p2: Int32, p3: CPointer<CxF64>, p4: CPointer<CxF64>, p5: Int32, p6: CPointer<CxF64>, p7: Int32, p8: CPointer<CxF64>, p9: Int32): Unit
    func cblas_zgerc(p0: Int32, p1: Int32, p2: Int32, p3: CPointer<CxF64>, p4: CPointer<CxF64>, p5: Int32, p6: CPointer<CxF64>, p7: Int32, p8: CPointer<CxF64>, p9: Int32): Unit
    func cblas_strsv(p0: Int32, p1: Int32, p2: Int32, p3: Int32, p4: Int32, p5: CPointer<Float32>, p6: Int32, p7: CPointer<Float32>, p8: Int32): Unit
    func cblas_dtrsv(p0: Int32, p1: Int32, p2: Int32, p3: Int32, p4: Int32, p5: CPointer<Float64>, p6: Int32, p7: CPointer<Float64>, p8: Int32): Unit
    func cblas_ctrsv(p0: Int32, p1: Int32, p2: Int32, p3: Int32, p4: Int32, p5: CPointer<CxF32>, p6: Int32, p7: CPointer<CxF32>, p8: Int32): Unit
    func cblas_ztrsv(p0: Int32, p1: Int32, p2: Int32, p3: Int32, p4: Int32, p5: CPointer<CxF64>, p6: Int32, p7: CPointer<CxF64>, p8: Int32): Unit
    func cblas_strmv(p0: Int32, p1: Int32, p2: Int32, p3: Int32, p4: Int32, p5: CPointer<Float32>, p6: Int32, p7: CPointer<Float32>, p8: Int32): Unit
    func cblas_dtrmv(p0: Int32, p1: Int32, p2: Int32, p3: Int32, p4: Int32, p5: CPointer<Float64>, p6: Int32, p7: CPointer<Float64>, p8: Int32): Unit
    func cblas_ctrmv(p0: Int32, p1: Int32, p2: Int32, p3: Int32, p4: Int32, p5: CPointer<CxF32>, p6: Int32, p7: CPointer<CxF32>, p8: Int32): Unit
    func cblas_ztrmv(p0: Int32, p1: Int32, p2: Int32, p3: Int32, p4: Int32, p5: CPointer<CxF64>, p6: Int32, p7: CPointer<CxF64>, p8: Int32): Unit
    func cblas_ssyr(p0: Int32, p1: Int32, p2: Int32, p3: Float32, p4: CPointer<Float32>, p5: Int32, p6: CPointer<Float32>, p7: Int32): Unit
    func cblas_dsyr(p0: Int32, p1: Int32, p2: Int32, p3: Float64, p4: CPointer<Float64>, p5: Int32, p6: CPointer<Float64>, p7: Int32): Unit
    func cblas_cher(p0: Int32, p1: Int32, p2: Int32, p3: Float32, p4: CPointer<CxF32>, p5: Int32, p6: CPointer<CxF32>, p7: Int32): Unit
    func cblas_zher(p0: Int32, p1: Int32, p2: Int32, p3: Float64, p4: CPointer<CxF64>, p5: Int32, p6: CPointer<CxF64>, p7: Int32): Unit
    func cblas_ssyr2(p0: Int32, p1: Int32, p2: Int32, p3: Float32, p4: CPointer<Float32>, p5: Int32, p6: CPointer<Float32>, p7: Int32, p8: CPointer<Float32>, p9: Int32): Unit
    func cblas_dsyr2(p0: Int32, p1: Int32, p2: Int32, p3: Float64, p4: CPointer<Float64>, p5: Int32, p6: CPointer<Float64>, p7: Int32, p8: CPointer<Float64>, p9: Int32): Unit
    func cblas_cher2(p0: Int32, p1: Int32, p2: Int32, p3: CPointer<CxF32>, p4: CPointer<CxF32>, p5: Int32, p6: CPointer<CxF32>, p7: Int32, p8: CPointer<CxF32>, p9: Int32): Unit
    func cblas_zher2(p0: Int32, p1: Int32, p2: Int32, p3: CPointer<CxF64>, p4: CPointer<CxF64>, p5: Int32, p6: CPointer<CxF64>, p7: Int32, p8: CPointer<CxF64>, p9: Int32): Unit
    func cblas_sgbmv(p0: Int32, p1: Int32, p2: Int32, p3: Int32, p4: Int32, p5: Int32, p6: Float32, p7: CPointer<Float32>, p8: Int32, p9: CPointer<Float32>, p10: Int32, p11: Float32, p12: CPointer<Float32>, p13: Int32): Unit
    func cblas_dgbmv(p0: Int32, p1: Int32, p2: Int32, p3: Int32, p4: Int32, p5: Int32, p6: Float64, p7: CPointer<Float64>, p8: Int32, p9: CPointer<Float64>, p10: Int32, p11: Float64, p12: CPointer<Float64>, p13: Int32): Unit
    func cblas_cgbmv(p0: Int32, p1: Int32, p2: Int32, p3: Int32, p4: Int32, p5: Int32, p6: CPointer<CxF32>, p7: CPointer<CxF32>, p8: Int32, p9: CPointer<CxF32>, p10: Int32, p11: CPointer<CxF32>, p12: CPointer<CxF32>, p13: Int32): Unit
    func cblas_zgbmv(p0: Int32, p1: Int32, p2: Int32, p3: Int32, p4: Int32, p5: Int32, p6: CPointer<CxF64>, p7: CPointer<CxF64>, p8: Int32, p9: CPointer<CxF64>, p10: Int32, p11: CPointer<CxF64>, p12: CPointer<CxF64>, p13: Int32): Unit
    func cblas_ssbmv(p0: Int32, p1: Int32, p2: Int32, p3: Int32, p4: Float32, p5: CPointer<Float32>, p6: Int32, p7: CPointer<Float32>, p8: Int32, p9: Float32, p10: CPointer<Float32>, p11: Int32): Unit
    func cblas_dsbmv(p0: Int32, p1: Int32, p2: Int32, p3: Int32, p4: Float64, p5: CPointer<Float64>, p6: Int32, p7: CPointer<Float64>, p8: Int32, p9: Float64, p10: CPointer<Float64>, p11: Int32): Unit
    func cblas_stbmv(p0: Int32, p1: Int32, p2: Int32, p3: Int32, p4: Int32, p5: Int32, p6: CPointer<Float32>, p7: Int32, p8: CPointer<Float32>, p9: Int32): Unit
    func cblas_dtbmv(p0: Int32, p1: Int32, p2: Int32, p3: Int32, p4: Int32, p5: Int32, p6: CPointer<Float64>, p7: Int32, p8: CPointer<Float64>, p9: Int32): Unit
    func cblas_ctbmv(p0: Int32, p1: Int32, p2: Int32, p3: Int32, p4: Int32, p5: Int32, p6: CPointer<CxF32>, p7: Int32, p8: CPointer<CxF32>, p9: Int32): Unit
    func cblas_ztbmv(p0: Int32, p1: Int32, p2: Int32, p3: Int32, p4: Int32, p5: Int32, p6: CPointer<CxF64>, p7: Int32, p8: CPointer<CxF64>, p9: Int32): Unit
    func cblas_stbsv(p0: Int32, p1: Int32, p2: Int32, p3: Int32, p4: Int32, p5: Int32, p6: CPointer<Float32>, p7: Int32, p8: CPointer<Float32>, p9: Int32): Unit
    func cblas_dtbsv(p0: Int32, p1: Int32, p2: Int32, p3: Int32, p4: Int32, p5: Int32, p6: CPointer<Float64>, p7: Int32, p8: CPointer<Float64>, p9: Int32): Unit
    func cblas_ctbsv(p0: Int32, p1: Int32, p2: Int32, p3: Int32, p4: Int32, p5: Int32, p6: CPointer<CxF32>, p7: Int32, p8: CPointer<CxF32>, p9: Int32): Unit
    func cblas_ztbsv(p0: Int32, p1: Int32, p2: Int32, p3: Int32, p4: Int32, p5: Int32, p6: CPointer<CxF64>, p7: Int32, p8: CPointer<CxF64>, p9: Int32): Unit
    func cblas_stpmv(p0: Int32, p1: Int32, p2: Int32, p3: Int32, p4: Int32, p5: CPointer<Float32>, p6: CPointer<Float32>, p7: Int32): Unit
    func cblas_dtpmv(p0: Int32, p1: Int32, p2: Int32, p3: Int32, p4: Int32, p5: CPointer<Float64>, p6: CPointer<Float64>, p7: Int32): Unit
    func cblas_ctpmv(p0: Int32, p1: Int32, p2: Int32, p3: Int32, p4: Int32, p5: CPointer<CxF32>, p6: CPointer<CxF32>, p7: Int32): Unit
    func cblas_ztpmv(p0: Int32, p1: Int32, p2: Int32, p3: Int32, p4: Int32, p5: CPointer<CxF64>, p6: CPointer<CxF64>, p7: Int32): Unit
    func cblas_stpsv(p0: Int32, p1: Int32, p2: Int32, p3: Int32, p4: Int32, p5: CPointer<Float32>, p6: CPointer<Float32>, p7: Int32): Unit
    func cblas_dtpsv(p0: Int32, p1: Int32, p2: Int32, p3: Int32, p4: Int32, p5: CPointer<Float64>, p6: CPointer<Float64>, p7: Int32): Unit
    func cblas_ctpsv(p0: Int32, p1: Int32, p2: Int32, p3: Int32, p4: Int32, p5: CPointer<CxF32>, p6: CPointer<CxF32>, p7: Int32): Unit
    func cblas_ztpsv(p0: Int32, p1: Int32, p2: Int32, p3: Int32, p4: Int32, p5: CPointer<CxF64>, p6: CPointer<CxF64>, p7: Int32): Unit
    func cblas_ssymv(p0: Int32, p1: Int32, p2: Int32, p3: Float32, p4: CPointer<Float32>, p5: Int32, p6: CPointer<Float32>, p7: Int32, p8: Float32, p9: CPointer<Float32>, p10: Int32): Unit
    func cblas_dsymv(p0: Int32, p1: Int32, p2: Int32, p3: Float64, p4: CPointer<Float64>, p5: Int32, p6: CPointer<Float64>, p7: Int32, p8: Float64, p9: CPointer<Float64>, p10: Int32): Unit
    func cblas_chemv(p0: Int32, p1: Int32, p2: Int32, p3: CPointer<CxF32>, p4: CPointer<CxF32>, p5: Int32, p6: CPointer<CxF32>, p7: Int32, p8: CPointer<CxF32>, p9: CPointer<CxF32>, p10: Int32): Unit
    func cblas_zhemv(p0: Int32, p1: Int32, p2: Int32, p3: CPointer<CxF64>, p4: CPointer<CxF64>, p5: Int32, p6: CPointer<CxF64>, p7: Int32, p8: CPointer<CxF64>, p9: CPointer<CxF64>, p10: Int32): Unit
    func cblas_sspmv(p0: Int32, p1: Int32, p2: Int32, p3: Float32, p4: CPointer<Float32>, p5: CPointer<Float32>, p6: Int32, p7: Float32, p8: CPointer<Float32>, p9: Int32): Unit
    func cblas_dspmv(p0: Int32, p1: Int32, p2: Int32, p3: Float64, p4: CPointer<Float64>, p5: CPointer<Float64>, p6: Int32, p7: Float64, p8: CPointer<Float64>, p9: Int32): Unit
    func cblas_sspr(p0: Int32, p1: Int32, p2: Int32, p3: Float32, p4: CPointer<Float32>, p5: Int32, p6: CPointer<Float32>): Unit
    func cblas_dspr(p0: Int32, p1: Int32, p2: Int32, p3: Float64, p4: CPointer<Float64>, p5: Int32, p6: CPointer<Float64>): Unit
    func cblas_chpr(p0: Int32, p1: Int32, p2: Int32, p3: Float32, p4: CPointer<CxF32>, p5: Int32, p6: CPointer<CxF32>): Unit
    func cblas_zhpr(p0: Int32, p1: Int32, p2: Int32, p3: Float64, p4: CPointer<CxF64>, p5: Int32, p6: CPointer<CxF64>): Unit
    func cblas_sspr2(p0: Int32, p1: Int32, p2: Int32, p3: Float32, p4: CPointer<Float32>, p5: Int32, p6: CPointer<Float32>, p7: Int32, p8: CPointer<Float32>): Unit
    func cblas_dspr2(p0: Int32, p1: Int32, p2: Int32, p3: Float64, p4: CPointer<Float64>, p5: Int32, p6: CPointer<Float64>, p7: Int32, p8: CPointer<Float64>): Unit
    func cblas_chpr2(p0: Int32, p1: Int32, p2: Int32, p3: CPointer<CxF32>, p4: CPointer<CxF32>, p5: Int32, p6: CPointer<CxF32>, p7: Int32, p8: CPointer<CxF32>): Unit
    func cblas_zhpr2(p0: Int32, p1: Int32, p2: Int32, p3: CPointer<CxF64>, p4: CPointer<CxF64>, p5: Int32, p6: CPointer<CxF64>, p7: Int32, p8: CPointer<CxF64>): Unit
    func cblas_chbmv(p0: Int32, p1: Int32, p2: Int32, p3: Int32, p4: CPointer<CxF32>, p5: CPointer<CxF32>, p6: Int32, p7: CPointer<CxF32>, p8: Int32, p9: CPointer<CxF32>, p10: CPointer<CxF32>, p11: Int32): Unit
    func cblas_zhbmv(p0: Int32, p1: Int32, p2: Int32, p3: Int32, p4: CPointer<CxF64>, p5: CPointer<CxF64>, p6: Int32, p7: CPointer<CxF64>, p8: Int32, p9: CPointer<CxF64>, p10: CPointer<CxF64>, p11: Int32): Unit
    func cblas_chpmv(p0: Int32, p1: Int32, p2: Int32, p3: CPointer<CxF32>, p4: CPointer<CxF32>, p5: CPointer<CxF32>, p6: Int32, p7: CPointer<CxF32>, p8: CPointer<CxF32>, p9: Int32): Unit
    func cblas_zhpmv(p0: Int32, p1: Int32, p2: Int32, p3: CPointer<CxF64>, p4: CPointer<CxF64>, p5: CPointer<CxF64>, p6: Int32, p7: CPointer<CxF64>, p8: CPointer<CxF64>, p9: Int32): Unit
    func cblas_sgemm(p0: Int32, p1: Int32, p2: Int32, p3: Int32, p4: Int32, p5: Int32, p6: Float32, p7: CPointer<Float32>, p8: Int32, p9: CPointer<Float32>, p10: Int32, p11: Float32, p12: CPointer<Float32>, p13: Int32): Unit
    func cblas_dgemm(p0: Int32, p1: Int32, p2: Int32, p3: Int32, p4: Int32, p5: Int32, p6: Float64, p7: CPointer<Float64>, p8: Int32, p9: CPointer<Float64>, p10: Int32, p11: Float64, p12: CPointer<Float64>, p13: Int32): Unit
    func cblas_cgemm(p0: Int32, p1: Int32, p2: Int32, p3: Int32, p4: Int32, p5: Int32, p6: CPointer<CxF32>, p7: CPointer<CxF32>, p8: Int32, p9: CPointer<CxF32>, p10: Int32, p11: CPointer<CxF32>, p12: CPointer<CxF32>, p13: Int32): Unit
    func cblas_zgemm(p0: Int32, p1: Int32, p2: Int32, p3: Int32, p4: Int32, p5: Int32, p6: CPointer<CxF64>, p7: CPointer<CxF64>, p8: Int32, p9: CPointer<CxF64>, p10: Int32, p11: CPointer<CxF64>, p12: CPointer<CxF64>, p13: Int32): Unit
    func cblas_sgemmt(p0: Int32, p1: Int32, p2: Int32, p3: Int32, p4: Int32, p5: Int32, p6: Float32, p7: CPointer<Float32>, p8: Int32, p9: CPointer<Float32>, p10: Int32, p11: Float32, p12: CPointer<Float32>, p13: Int32): Unit
    func cblas_dgemmt(p0: Int32, p1: Int32, p2: Int32, p3: Int32, p4: Int32, p5: Int32, p6: Float64, p7: CPointer<Float64>, p8: Int32, p9: CPointer<Float64>, p10: Int32, p11: Float64, p12: CPointer<Float64>, p13: Int32): Unit
    func cblas_cgemmt(p0: Int32, p1: Int32, p2: Int32, p3: Int32, p4: Int32, p5: Int32, p6: CPointer<CxF32>, p7: CPointer<CxF32>, p8: Int32, p9: CPointer<CxF32>, p10: Int32, p11: CPointer<CxF32>, p12: CPointer<CxF32>, p13: Int32): Unit
    func cblas_zgemmt(p0: Int32, p1: Int32, p2: Int32, p3: Int32, p4: Int32, p5: Int32, p6: CPointer<CxF64>, p7: CPointer<CxF64>, p8: Int32, p9: CPointer<CxF64>, p10: Int32, p11: CPointer<CxF64>, p12: CPointer<CxF64>, p13: Int32): Unit
    func cblas_ssymm(p0: Int32, p1: Int32, p2: Int32, p3: Int32, p4: Int32, p5: Float32, p6: CPointer<Float32>, p7: Int32, p8: CPointer<Float32>, p9: Int32, p10: Float32, p11: CPointer<Float32>, p12: Int32): Unit
    func cblas_dsymm(p0: Int32, p1: Int32, p2: Int32, p3: Int32, p4: Int32, p5: Float64, p6: CPointer<Float64>, p7: Int32, p8: CPointer<Float64>, p9: Int32, p10: Float64, p11: CPointer<Float64>, p12: Int32): Unit
    func cblas_csymm(p0: Int32, p1: Int32, p2: Int32, p3: Int32, p4: Int32, p5: CPointer<CxF32>, p6: CPointer<CxF32>, p7: Int32, p8: CPointer<CxF32>, p9: Int32, p10: CPointer<CxF32>, p11: CPointer<CxF32>, p12: Int32): Unit
    func cblas_zsymm(p0: Int32, p1: Int32, p2: Int32, p3: Int32, p4: Int32, p5: CPointer<CxF64>, p6: CPointer<CxF64>, p7: Int32, p8: CPointer<CxF64>, p9: Int32, p10: CPointer<CxF64>, p11: CPointer<CxF64>, p12: Int32): Unit
    func cblas_ssyrk(p0: Int32, p1: Int32, p2: Int32, p3: Int32, p4: Int32, p5: Float32, p6: CPointer<Float32>, p7: Int32, p8: Float32, p9: CPointer<Float32>, p10: Int32): Unit
    func cblas_dsyrk(p0: Int32, p1: Int32, p2: Int32, p3: Int32, p4: Int32, p5: Float64, p6: CPointer<Float64>, p7: Int32, p8: Float64, p9: CPointer<Float64>, p10: Int32): Unit
    func cblas_csyrk(p0: Int32, p1: Int32, p2: Int32, p3: Int32, p4: Int32, p5: CPointer<CxF32>, p6: CPointer<CxF32>, p7: Int32, p8: CPointer<CxF32>, p9: CPointer<CxF32>, p10: Int32): Unit
    func cblas_zsyrk(p0: Int32, p1: Int32, p2: Int32, p3: Int32, p4: Int32, p5: CPointer<CxF64>, p6: CPointer<CxF64>, p7: Int32, p8: CPointer<CxF64>, p9: CPointer<CxF64>, p10: Int32): Unit
    func cblas_ssyr2k(p0: Int32, p1: Int32, p2: Int32, p3: Int32, p4: Int32, p5: Float32, p6: CPointer<Float32>, p7: Int32, p8: CPointer<Float32>, p9: Int32, p10: Float32, p11: CPointer<Float32>, p12: Int32): Unit
    func cblas_dsyr2k(p0: Int32, p1: Int32, p2: Int32, p3: Int32, p4: Int32, p5: Float64, p6: CPointer<Float64>, p7: Int32, p8: CPointer<Float64>, p9: Int32, p10: Float64, p11: CPointer<Float64>, p12: Int32): Unit
    func cblas_csyr2k(p0: Int32, p1: Int32, p2: Int32, p3: Int32, p4: Int32, p5: CPointer<CxF32>, p6: CPointer<CxF32>, p7: Int32, p8: CPointer<CxF32>, p9: Int32, p10: CPointer<CxF32>, p11: CPointer<CxF32>, p12: Int32): Unit
    func cblas_zsyr2k(p0: Int32, p1: Int32, p2: Int32, p3: Int32, p4: Int32, p5: CPointer<CxF64>, p6: CPointer<CxF64>, p7: Int32, p8: CPointer<CxF64>, p9: Int32, p10: CPointer<CxF64>, p11: CPointer<CxF64>, p12: Int32): Unit
    func cblas_strmm(p0: Int32, p1: Int32, p2: Int32, p3: Int32, p4: Int32, p5: Int32, p6: Int32, p7: Float32, p8: CPointer<Float32>, p9: Int32, p10: CPointer<Float32>, p11: Int32): Unit
    func cblas_dtrmm(p0: Int32, p1: Int32, p2: Int32, p3: Int32, p4: Int32, p5: Int32, p6: Int32, p7: Float64, p8: CPointer<Float64>, p9: Int32, p10: CPointer<Float64>, p11: Int32): Unit
    func cblas_ctrmm(p0: Int32, p1: Int32, p2: Int32, p3: Int32, p4: Int32, p5: Int32, p6: Int32, p7: CPointer<CxF32>, p8: CPointer<CxF32>, p9: Int32, p10: CPointer<CxF32>, p11: Int32): Unit
    func cblas_ztrmm(p0: Int32, p1: Int32, p2: Int32, p3: Int32, p4: Int32, p5: Int32, p6: Int32, p7: CPointer<CxF64>, p8: CPointer<CxF64>, p9: Int32, p10: CPointer<CxF64>, p11: Int32): Unit
    func cblas_strsm(p0: Int32, p1: Int32, p2: Int32, p3: Int32, p4: Int32, p5: Int32, p6: Int32, p7: Float32, p8: CPointer<Float32>, p9: Int32, p10: CPointer<Float32>, p11: Int32): Unit
    func cblas_dtrsm(p0: Int32, p1: Int32, p2: Int32, p3: Int32, p4: Int32, p5: Int32, p6: Int32, p7: Float64, p8: CPointer<Float64>, p9: Int32, p10: CPointer<Float64>, p11: Int32): Unit
    func cblas_ctrsm(p0: Int32, p1: Int32, p2: Int32, p3: Int32, p4: Int32, p5: Int32, p6: Int32, p7: CPointer<CxF32>, p8: CPointer<CxF32>, p9: Int32, p10: CPointer<CxF32>, p11: Int32): Unit
    func cblas_ztrsm(p0: Int32, p1: Int32, p2: Int32, p3: Int32, p4: Int32, p5: Int32, p6: Int32, p7: CPointer<CxF64>, p8: CPointer<CxF64>, p9: Int32, p10: CPointer<CxF64>, p11: Int32): Unit
    func cblas_chemm(p0: Int32, p1: Int32, p2: Int32, p3: Int32, p4: Int32, p5: CPointer<CxF32>, p6: CPointer<CxF32>, p7: Int32, p8: CPointer<CxF32>, p9: Int32, p10: CPointer<CxF32>, p11: CPointer<CxF32>, p12: Int32): Unit
    func cblas_zhemm(p0: Int32, p1: Int32, p2: Int32, p3: Int32, p4: Int32, p5: CPointer<CxF64>, p6: CPointer<CxF64>, p7: Int32, p8: CPointer<CxF64>, p9: Int32, p10: CPointer<CxF64>, p11: CPointer<CxF64>, p12: Int32): Unit
    func cblas_cherk(p0: Int32, p1: Int32, p2: Int32, p3: Int32, p4: Int32, p5: Float32, p6: CPointer<CxF32>, p7: Int32, p8: Float32, p9: CPointer<CxF32>, p10: Int32): Unit
    func cblas_zherk(p0: Int32, p1: Int32, p2: Int32, p3: Int32, p4: Int32, p5: Float64, p6: CPointer<CxF64>, p7: Int32, p8: Float64, p9: CPointer<CxF64>, p10: Int32): Unit
    func cblas_cher2k(p0: Int32, p1: Int32, p2: Int32, p3: Int32, p4: Int32, p5: CPointer<CxF32>, p6: CPointer<CxF32>, p7: Int32, p8: CPointer<CxF32>, p9: Int32, p10: Float32, p11: CPointer<CxF32>, p12: Int32): Unit
    func cblas_zher2k(p0: Int32, p1: Int32, p2: Int32, p3: Int32, p4: Int32, p5: CPointer<CxF64>, p6: CPointer<CxF64>, p7: Int32, p8: CPointer<CxF64>, p9: Int32, p10: Float64, p11: CPointer<CxF64>, p12: Int32): Unit
    func cblas_xerbla(p0: Int32, p1: CString, p2: CString, ...): Unit
    func cblas_saxpby(p0: Int32, p1: Float32, p2: CPointer<Float32>, p3: Int32, p4: Float32, p5: CPointer<Float32>, p6: Int32): Unit
    func cblas_daxpby(p0: Int32, p1: Float64, p2: CPointer<Float64>, p3: Int32, p4: Float64, p5: CPointer<Float64>, p6: Int32): Unit
    func cblas_caxpby(p0: Int32, p1: CPointer<CxF32>, p2: CPointer<CxF32>, p3: Int32, p4: CPointer<CxF32>, p5: CPointer<CxF32>, p6: Int32): Unit
    func cblas_zaxpby(p0: Int32, p1: CPointer<CxF64>, p2: CPointer<CxF64>, p3: Int32, p4: CPointer<CxF64>, p5: CPointer<CxF64>, p6: Int32): Unit
    func cblas_somatcopy(p0: Int32, p1: Int32, p2: Int32, p3: Int32, p4: Float32, p5: CPointer<Float32>, p6: Int32, p7: CPointer<Float32>, p8: Int32): Unit
    func cblas_domatcopy(p0: Int32, p1: Int32, p2: Int32, p3: Int32, p4: Float64, p5: CPointer<Float64>, p6: Int32, p7: CPointer<Float64>, p8: Int32): Unit
    func cblas_comatcopy(p0: Int32, p1: Int32, p2: Int32, p3: Int32, p4: CPointer<Float32>, p5: CPointer<Float32>, p6: Int32, p7: CPointer<Float32>, p8: Int32): Unit
    func cblas_zomatcopy(p0: Int32, p1: Int32, p2: Int32, p3: Int32, p4: CPointer<Float64>, p5: CPointer<Float64>, p6: Int32, p7: CPointer<Float64>, p8: Int32): Unit
    func cblas_simatcopy(p0: Int32, p1: Int32, p2: Int32, p3: Int32, p4: Float32, p5: CPointer<Float32>, p6: Int32, p7: Int32): Unit
    func cblas_dimatcopy(p0: Int32, p1: Int32, p2: Int32, p3: Int32, p4: Float64, p5: CPointer<Float64>, p6: Int32, p7: Int32): Unit
    func cblas_cimatcopy(p0: Int32, p1: Int32, p2: Int32, p3: Int32, p4: CPointer<Float32>, p5: CPointer<Float32>, p6: Int32, p7: Int32): Unit
    func cblas_zimatcopy(p0: Int32, p1: Int32, p2: Int32, p3: Int32, p4: CPointer<Float64>, p5: CPointer<Float64>, p6: Int32, p7: Int32): Unit
    func cblas_sgeadd(p0: Int32, p1: Int32, p2: Int32, p3: Float32, p4: CPointer<Float32>, p5: Int32, p6: Float32, p7: CPointer<Float32>, p8: Int32): Unit
    func cblas_dgeadd(p0: Int32, p1: Int32, p2: Int32, p3: Float64, p4: CPointer<Float64>, p5: Int32, p6: Float64, p7: CPointer<Float64>, p8: Int32): Unit
    func cblas_cgeadd(p0: Int32, p1: Int32, p2: Int32, p3: CPointer<Float32>, p4: CPointer<Float32>, p5: Int32, p6: CPointer<Float32>, p7: CPointer<Float32>, p8: Int32): Unit
    func cblas_zgeadd(p0: Int32, p1: Int32, p2: Int32, p3: CPointer<Float64>, p4: CPointer<Float64>, p5: Int32, p6: CPointer<Float64>, p7: CPointer<Float64>, p8: Int32): Unit
    func cblas_sgemm_batch(p0: Int32, p1: CPointer<Int32>, p2: CPointer<Int32>, p3: CPointer<Int32>, p4: CPointer<Int32>, p5: CPointer<Int32>, p6: CPointer<Float32>, p7: CPointer<CPointer<Float32>>, p8: CPointer<Int32>, p9: CPointer<CPointer<Float32>>, p10: CPointer<Int32>, p11: CPointer<Float32>, p12: CPointer<CPointer<Float32>>, p13: CPointer<Int32>, p14: Int32, p15: CPointer<Int32>): Unit
    func cblas_dgemm_batch(p0: Int32, p1: CPointer<Int32>, p2: CPointer<Int32>, p3: CPointer<Int32>, p4: CPointer<Int32>, p5: CPointer<Int32>, p6: CPointer<Float64>, p7: CPointer<CPointer<Float64>>, p8: CPointer<Int32>, p9: CPointer<CPointer<Float64>>, p10: CPointer<Int32>, p11: CPointer<Float64>, p12: CPointer<CPointer<Float64>>, p13: CPointer<Int32>, p14: Int32, p15: CPointer<Int32>): Unit
    func cblas_cgemm_batch(p0: Int32, p1: CPointer<Int32>, p2: CPointer<Int32>, p3: CPointer<Int32>, p4: CPointer<Int32>, p5: CPointer<Int32>, p6: CPointer<CxF32>, p7: CPointer<CPointer<CxF32>>, p8: CPointer<Int32>, p9: CPointer<CPointer<CxF32>>, p10: CPointer<Int32>, p11: CPointer<CxF32>, p12: CPointer<CPointer<CxF32>>, p13: CPointer<Int32>, p14: Int32, p15: CPointer<Int32>): Unit
    func cblas_zgemm_batch(p0: Int32, p1: CPointer<Int32>, p2: CPointer<Int32>, p3: CPointer<Int32>, p4: CPointer<Int32>, p5: CPointer<Int32>, p6: CPointer<CxF64>, p7: CPointer<CPointer<CxF64>>, p8: CPointer<Int32>, p9: CPointer<CPointer<CxF64>>, p10: CPointer<Int32>, p11: CPointer<CxF64>, p12: CPointer<CPointer<CxF64>>, p13: CPointer<Int32>, p14: Int32, p15: CPointer<Int32>): Unit
}
