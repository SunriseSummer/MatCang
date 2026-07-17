/*
 * Public, safe-to-link wrappers over the raw OpenBLAS foreign decls.
 * AUTO-GENERATED; do not edit by hand (see .devtools/gen_bindings.py).
 *
 * Cangjie `foreign` functions only resolve to their C symbol when called
 * from inside their declaring package, so these thin `unsafe` forwarders
 * (regular public functions, hence linkable across the whole module) give
 * every subpackage - and external users - access to the full BLAS/LAPACK
 * surface under its canonical routine name (e.g. `dgemm`, `dgesv`).
 */
package matcang

// CBLAS bindings : 200 wrappers

public unsafe func sdsdot(p0: Int32, p1: Float32, p2: CPointer<Float32>, p3: Int32, p4: CPointer<Float32>, p5: Int32): Float32 { cblas_sdsdot(p0, p1, p2, p3, p4, p5) }
public unsafe func dsdot(p0: Int32, p1: CPointer<Float32>, p2: Int32, p3: CPointer<Float32>, p4: Int32): Float64 { cblas_dsdot(p0, p1, p2, p3, p4) }
public unsafe func sdot(p0: Int32, p1: CPointer<Float32>, p2: Int32, p3: CPointer<Float32>, p4: Int32): Float32 { cblas_sdot(p0, p1, p2, p3, p4) }
public unsafe func ddot(p0: Int32, p1: CPointer<Float64>, p2: Int32, p3: CPointer<Float64>, p4: Int32): Float64 { cblas_ddot(p0, p1, p2, p3, p4) }
public unsafe func cdotu(p0: Int32, p1: CPointer<CxF32>, p2: Int32, p3: CPointer<CxF32>, p4: Int32): CxF32 { cblas_cdotu(p0, p1, p2, p3, p4) }
public unsafe func cdotc(p0: Int32, p1: CPointer<CxF32>, p2: Int32, p3: CPointer<CxF32>, p4: Int32): CxF32 { cblas_cdotc(p0, p1, p2, p3, p4) }
public unsafe func zdotu(p0: Int32, p1: CPointer<CxF64>, p2: Int32, p3: CPointer<CxF64>, p4: Int32): CxF64 { cblas_zdotu(p0, p1, p2, p3, p4) }
public unsafe func zdotc(p0: Int32, p1: CPointer<CxF64>, p2: Int32, p3: CPointer<CxF64>, p4: Int32): CxF64 { cblas_zdotc(p0, p1, p2, p3, p4) }
public unsafe func cdotu_sub(p0: Int32, p1: CPointer<CxF32>, p2: Int32, p3: CPointer<CxF32>, p4: Int32, p5: CPointer<CxF32>): Unit { cblas_cdotu_sub(p0, p1, p2, p3, p4, p5) }
public unsafe func cdotc_sub(p0: Int32, p1: CPointer<CxF32>, p2: Int32, p3: CPointer<CxF32>, p4: Int32, p5: CPointer<CxF32>): Unit { cblas_cdotc_sub(p0, p1, p2, p3, p4, p5) }
public unsafe func zdotu_sub(p0: Int32, p1: CPointer<CxF64>, p2: Int32, p3: CPointer<CxF64>, p4: Int32, p5: CPointer<CxF64>): Unit { cblas_zdotu_sub(p0, p1, p2, p3, p4, p5) }
public unsafe func zdotc_sub(p0: Int32, p1: CPointer<CxF64>, p2: Int32, p3: CPointer<CxF64>, p4: Int32, p5: CPointer<CxF64>): Unit { cblas_zdotc_sub(p0, p1, p2, p3, p4, p5) }
public unsafe func sasum(p0: Int32, p1: CPointer<Float32>, p2: Int32): Float32 { cblas_sasum(p0, p1, p2) }
public unsafe func dasum(p0: Int32, p1: CPointer<Float64>, p2: Int32): Float64 { cblas_dasum(p0, p1, p2) }
public unsafe func scasum(p0: Int32, p1: CPointer<CxF32>, p2: Int32): Float32 { cblas_scasum(p0, p1, p2) }
public unsafe func dzasum(p0: Int32, p1: CPointer<CxF64>, p2: Int32): Float64 { cblas_dzasum(p0, p1, p2) }
public unsafe func ssum(p0: Int32, p1: CPointer<Float32>, p2: Int32): Float32 { cblas_ssum(p0, p1, p2) }
public unsafe func dsum(p0: Int32, p1: CPointer<Float64>, p2: Int32): Float64 { cblas_dsum(p0, p1, p2) }
public unsafe func scsum(p0: Int32, p1: CPointer<CxF32>, p2: Int32): Float32 { cblas_scsum(p0, p1, p2) }
public unsafe func dzsum(p0: Int32, p1: CPointer<CxF64>, p2: Int32): Float64 { cblas_dzsum(p0, p1, p2) }
public unsafe func snrm2(p0: Int32, p1: CPointer<Float32>, p2: Int32): Float32 { cblas_snrm2(p0, p1, p2) }
public unsafe func dnrm2(p0: Int32, p1: CPointer<Float64>, p2: Int32): Float64 { cblas_dnrm2(p0, p1, p2) }
public unsafe func scnrm2(p0: Int32, p1: CPointer<CxF32>, p2: Int32): Float32 { cblas_scnrm2(p0, p1, p2) }
public unsafe func dznrm2(p0: Int32, p1: CPointer<CxF64>, p2: Int32): Float64 { cblas_dznrm2(p0, p1, p2) }
public unsafe func isamax(p0: Int32, p1: CPointer<Float32>, p2: Int32): UIntNative { cblas_isamax(p0, p1, p2) }
public unsafe func idamax(p0: Int32, p1: CPointer<Float64>, p2: Int32): UIntNative { cblas_idamax(p0, p1, p2) }
public unsafe func icamax(p0: Int32, p1: CPointer<CxF32>, p2: Int32): UIntNative { cblas_icamax(p0, p1, p2) }
public unsafe func izamax(p0: Int32, p1: CPointer<CxF64>, p2: Int32): UIntNative { cblas_izamax(p0, p1, p2) }
public unsafe func isamin(p0: Int32, p1: CPointer<Float32>, p2: Int32): UIntNative { cblas_isamin(p0, p1, p2) }
public unsafe func idamin(p0: Int32, p1: CPointer<Float64>, p2: Int32): UIntNative { cblas_idamin(p0, p1, p2) }
public unsafe func icamin(p0: Int32, p1: CPointer<CxF32>, p2: Int32): UIntNative { cblas_icamin(p0, p1, p2) }
public unsafe func izamin(p0: Int32, p1: CPointer<CxF64>, p2: Int32): UIntNative { cblas_izamin(p0, p1, p2) }
public unsafe func samax(p0: Int32, p1: CPointer<Float32>, p2: Int32): Float32 { cblas_samax(p0, p1, p2) }
public unsafe func damax(p0: Int32, p1: CPointer<Float64>, p2: Int32): Float64 { cblas_damax(p0, p1, p2) }
public unsafe func scamax(p0: Int32, p1: CPointer<CxF32>, p2: Int32): Float32 { cblas_scamax(p0, p1, p2) }
public unsafe func dzamax(p0: Int32, p1: CPointer<CxF64>, p2: Int32): Float64 { cblas_dzamax(p0, p1, p2) }
public unsafe func samin(p0: Int32, p1: CPointer<Float32>, p2: Int32): Float32 { cblas_samin(p0, p1, p2) }
public unsafe func damin(p0: Int32, p1: CPointer<Float64>, p2: Int32): Float64 { cblas_damin(p0, p1, p2) }
public unsafe func scamin(p0: Int32, p1: CPointer<CxF32>, p2: Int32): Float32 { cblas_scamin(p0, p1, p2) }
public unsafe func dzamin(p0: Int32, p1: CPointer<CxF64>, p2: Int32): Float64 { cblas_dzamin(p0, p1, p2) }
public unsafe func ismax(p0: Int32, p1: CPointer<Float32>, p2: Int32): UIntNative { cblas_ismax(p0, p1, p2) }
public unsafe func idmax(p0: Int32, p1: CPointer<Float64>, p2: Int32): UIntNative { cblas_idmax(p0, p1, p2) }
public unsafe func icmax(p0: Int32, p1: CPointer<CxF32>, p2: Int32): UIntNative { cblas_icmax(p0, p1, p2) }
public unsafe func izmax(p0: Int32, p1: CPointer<CxF64>, p2: Int32): UIntNative { cblas_izmax(p0, p1, p2) }
public unsafe func ismin(p0: Int32, p1: CPointer<Float32>, p2: Int32): UIntNative { cblas_ismin(p0, p1, p2) }
public unsafe func idmin(p0: Int32, p1: CPointer<Float64>, p2: Int32): UIntNative { cblas_idmin(p0, p1, p2) }
public unsafe func icmin(p0: Int32, p1: CPointer<CxF32>, p2: Int32): UIntNative { cblas_icmin(p0, p1, p2) }
public unsafe func izmin(p0: Int32, p1: CPointer<CxF64>, p2: Int32): UIntNative { cblas_izmin(p0, p1, p2) }
public unsafe func saxpy(p0: Int32, p1: Float32, p2: CPointer<Float32>, p3: Int32, p4: CPointer<Float32>, p5: Int32): Unit { cblas_saxpy(p0, p1, p2, p3, p4, p5) }
public unsafe func daxpy(p0: Int32, p1: Float64, p2: CPointer<Float64>, p3: Int32, p4: CPointer<Float64>, p5: Int32): Unit { cblas_daxpy(p0, p1, p2, p3, p4, p5) }
public unsafe func caxpy(p0: Int32, p1: CPointer<CxF32>, p2: CPointer<CxF32>, p3: Int32, p4: CPointer<CxF32>, p5: Int32): Unit { cblas_caxpy(p0, p1, p2, p3, p4, p5) }
public unsafe func zaxpy(p0: Int32, p1: CPointer<CxF64>, p2: CPointer<CxF64>, p3: Int32, p4: CPointer<CxF64>, p5: Int32): Unit { cblas_zaxpy(p0, p1, p2, p3, p4, p5) }
public unsafe func caxpyc(p0: Int32, p1: CPointer<CxF32>, p2: CPointer<CxF32>, p3: Int32, p4: CPointer<CxF32>, p5: Int32): Unit { cblas_caxpyc(p0, p1, p2, p3, p4, p5) }
public unsafe func zaxpyc(p0: Int32, p1: CPointer<CxF64>, p2: CPointer<CxF64>, p3: Int32, p4: CPointer<CxF64>, p5: Int32): Unit { cblas_zaxpyc(p0, p1, p2, p3, p4, p5) }
public unsafe func scopy(p0: Int32, p1: CPointer<Float32>, p2: Int32, p3: CPointer<Float32>, p4: Int32): Unit { cblas_scopy(p0, p1, p2, p3, p4) }
public unsafe func dcopy(p0: Int32, p1: CPointer<Float64>, p2: Int32, p3: CPointer<Float64>, p4: Int32): Unit { cblas_dcopy(p0, p1, p2, p3, p4) }
public unsafe func ccopy(p0: Int32, p1: CPointer<CxF32>, p2: Int32, p3: CPointer<CxF32>, p4: Int32): Unit { cblas_ccopy(p0, p1, p2, p3, p4) }
public unsafe func zcopy(p0: Int32, p1: CPointer<CxF64>, p2: Int32, p3: CPointer<CxF64>, p4: Int32): Unit { cblas_zcopy(p0, p1, p2, p3, p4) }
public unsafe func sswap(p0: Int32, p1: CPointer<Float32>, p2: Int32, p3: CPointer<Float32>, p4: Int32): Unit { cblas_sswap(p0, p1, p2, p3, p4) }
public unsafe func dswap(p0: Int32, p1: CPointer<Float64>, p2: Int32, p3: CPointer<Float64>, p4: Int32): Unit { cblas_dswap(p0, p1, p2, p3, p4) }
public unsafe func cswap(p0: Int32, p1: CPointer<CxF32>, p2: Int32, p3: CPointer<CxF32>, p4: Int32): Unit { cblas_cswap(p0, p1, p2, p3, p4) }
public unsafe func zswap(p0: Int32, p1: CPointer<CxF64>, p2: Int32, p3: CPointer<CxF64>, p4: Int32): Unit { cblas_zswap(p0, p1, p2, p3, p4) }
public unsafe func srot(p0: Int32, p1: CPointer<Float32>, p2: Int32, p3: CPointer<Float32>, p4: Int32, p5: Float32, p6: Float32): Unit { cblas_srot(p0, p1, p2, p3, p4, p5, p6) }
public unsafe func drot(p0: Int32, p1: CPointer<Float64>, p2: Int32, p3: CPointer<Float64>, p4: Int32, p5: Float64, p6: Float64): Unit { cblas_drot(p0, p1, p2, p3, p4, p5, p6) }
public unsafe func csrot(p0: Int32, p1: CPointer<CxF32>, p2: Int32, p3: CPointer<CxF32>, p4: Int32, p5: Float32, p6: Float32): Unit { cblas_csrot(p0, p1, p2, p3, p4, p5, p6) }
public unsafe func zdrot(p0: Int32, p1: CPointer<CxF64>, p2: Int32, p3: CPointer<CxF64>, p4: Int32, p5: Float64, p6: Float64): Unit { cblas_zdrot(p0, p1, p2, p3, p4, p5, p6) }
public unsafe func srotg(p0: CPointer<Float32>, p1: CPointer<Float32>, p2: CPointer<Float32>, p3: CPointer<Float32>): Unit { cblas_srotg(p0, p1, p2, p3) }
public unsafe func drotg(p0: CPointer<Float64>, p1: CPointer<Float64>, p2: CPointer<Float64>, p3: CPointer<Float64>): Unit { cblas_drotg(p0, p1, p2, p3) }
public unsafe func crotg(p0: CPointer<CxF32>, p1: CPointer<CxF32>, p2: CPointer<Float32>, p3: CPointer<CxF32>): Unit { cblas_crotg(p0, p1, p2, p3) }
public unsafe func zrotg(p0: CPointer<CxF64>, p1: CPointer<CxF64>, p2: CPointer<Float64>, p3: CPointer<CxF64>): Unit { cblas_zrotg(p0, p1, p2, p3) }
public unsafe func srotm(p0: Int32, p1: CPointer<Float32>, p2: Int32, p3: CPointer<Float32>, p4: Int32, p5: CPointer<Float32>): Unit { cblas_srotm(p0, p1, p2, p3, p4, p5) }
public unsafe func drotm(p0: Int32, p1: CPointer<Float64>, p2: Int32, p3: CPointer<Float64>, p4: Int32, p5: CPointer<Float64>): Unit { cblas_drotm(p0, p1, p2, p3, p4, p5) }
public unsafe func srotmg(p0: CPointer<Float32>, p1: CPointer<Float32>, p2: CPointer<Float32>, p3: Float32, p4: CPointer<Float32>): Unit { cblas_srotmg(p0, p1, p2, p3, p4) }
public unsafe func drotmg(p0: CPointer<Float64>, p1: CPointer<Float64>, p2: CPointer<Float64>, p3: Float64, p4: CPointer<Float64>): Unit { cblas_drotmg(p0, p1, p2, p3, p4) }
public unsafe func sscal(p0: Int32, p1: Float32, p2: CPointer<Float32>, p3: Int32): Unit { cblas_sscal(p0, p1, p2, p3) }
public unsafe func dscal(p0: Int32, p1: Float64, p2: CPointer<Float64>, p3: Int32): Unit { cblas_dscal(p0, p1, p2, p3) }
public unsafe func cscal(p0: Int32, p1: CPointer<CxF32>, p2: CPointer<CxF32>, p3: Int32): Unit { cblas_cscal(p0, p1, p2, p3) }
public unsafe func zscal(p0: Int32, p1: CPointer<CxF64>, p2: CPointer<CxF64>, p3: Int32): Unit { cblas_zscal(p0, p1, p2, p3) }
public unsafe func csscal(p0: Int32, p1: Float32, p2: CPointer<CxF32>, p3: Int32): Unit { cblas_csscal(p0, p1, p2, p3) }
public unsafe func zdscal(p0: Int32, p1: Float64, p2: CPointer<CxF64>, p3: Int32): Unit { cblas_zdscal(p0, p1, p2, p3) }
public unsafe func sgemv(p0: Int32, p1: Int32, p2: Int32, p3: Int32, p4: Float32, p5: CPointer<Float32>, p6: Int32, p7: CPointer<Float32>, p8: Int32, p9: Float32, p10: CPointer<Float32>, p11: Int32): Unit { cblas_sgemv(p0, p1, p2, p3, p4, p5, p6, p7, p8, p9, p10, p11) }
public unsafe func dgemv(p0: Int32, p1: Int32, p2: Int32, p3: Int32, p4: Float64, p5: CPointer<Float64>, p6: Int32, p7: CPointer<Float64>, p8: Int32, p9: Float64, p10: CPointer<Float64>, p11: Int32): Unit { cblas_dgemv(p0, p1, p2, p3, p4, p5, p6, p7, p8, p9, p10, p11) }
public unsafe func cgemv(p0: Int32, p1: Int32, p2: Int32, p3: Int32, p4: CPointer<CxF32>, p5: CPointer<CxF32>, p6: Int32, p7: CPointer<CxF32>, p8: Int32, p9: CPointer<CxF32>, p10: CPointer<CxF32>, p11: Int32): Unit { cblas_cgemv(p0, p1, p2, p3, p4, p5, p6, p7, p8, p9, p10, p11) }
public unsafe func zgemv(p0: Int32, p1: Int32, p2: Int32, p3: Int32, p4: CPointer<CxF64>, p5: CPointer<CxF64>, p6: Int32, p7: CPointer<CxF64>, p8: Int32, p9: CPointer<CxF64>, p10: CPointer<CxF64>, p11: Int32): Unit { cblas_zgemv(p0, p1, p2, p3, p4, p5, p6, p7, p8, p9, p10, p11) }
public unsafe func sger(p0: Int32, p1: Int32, p2: Int32, p3: Float32, p4: CPointer<Float32>, p5: Int32, p6: CPointer<Float32>, p7: Int32, p8: CPointer<Float32>, p9: Int32): Unit { cblas_sger(p0, p1, p2, p3, p4, p5, p6, p7, p8, p9) }
public unsafe func dger(p0: Int32, p1: Int32, p2: Int32, p3: Float64, p4: CPointer<Float64>, p5: Int32, p6: CPointer<Float64>, p7: Int32, p8: CPointer<Float64>, p9: Int32): Unit { cblas_dger(p0, p1, p2, p3, p4, p5, p6, p7, p8, p9) }
public unsafe func cgeru(p0: Int32, p1: Int32, p2: Int32, p3: CPointer<CxF32>, p4: CPointer<CxF32>, p5: Int32, p6: CPointer<CxF32>, p7: Int32, p8: CPointer<CxF32>, p9: Int32): Unit { cblas_cgeru(p0, p1, p2, p3, p4, p5, p6, p7, p8, p9) }
public unsafe func cgerc(p0: Int32, p1: Int32, p2: Int32, p3: CPointer<CxF32>, p4: CPointer<CxF32>, p5: Int32, p6: CPointer<CxF32>, p7: Int32, p8: CPointer<CxF32>, p9: Int32): Unit { cblas_cgerc(p0, p1, p2, p3, p4, p5, p6, p7, p8, p9) }
public unsafe func zgeru(p0: Int32, p1: Int32, p2: Int32, p3: CPointer<CxF64>, p4: CPointer<CxF64>, p5: Int32, p6: CPointer<CxF64>, p7: Int32, p8: CPointer<CxF64>, p9: Int32): Unit { cblas_zgeru(p0, p1, p2, p3, p4, p5, p6, p7, p8, p9) }
public unsafe func zgerc(p0: Int32, p1: Int32, p2: Int32, p3: CPointer<CxF64>, p4: CPointer<CxF64>, p5: Int32, p6: CPointer<CxF64>, p7: Int32, p8: CPointer<CxF64>, p9: Int32): Unit { cblas_zgerc(p0, p1, p2, p3, p4, p5, p6, p7, p8, p9) }
public unsafe func strsv(p0: Int32, p1: Int32, p2: Int32, p3: Int32, p4: Int32, p5: CPointer<Float32>, p6: Int32, p7: CPointer<Float32>, p8: Int32): Unit { cblas_strsv(p0, p1, p2, p3, p4, p5, p6, p7, p8) }
public unsafe func dtrsv(p0: Int32, p1: Int32, p2: Int32, p3: Int32, p4: Int32, p5: CPointer<Float64>, p6: Int32, p7: CPointer<Float64>, p8: Int32): Unit { cblas_dtrsv(p0, p1, p2, p3, p4, p5, p6, p7, p8) }
public unsafe func ctrsv(p0: Int32, p1: Int32, p2: Int32, p3: Int32, p4: Int32, p5: CPointer<CxF32>, p6: Int32, p7: CPointer<CxF32>, p8: Int32): Unit { cblas_ctrsv(p0, p1, p2, p3, p4, p5, p6, p7, p8) }
public unsafe func ztrsv(p0: Int32, p1: Int32, p2: Int32, p3: Int32, p4: Int32, p5: CPointer<CxF64>, p6: Int32, p7: CPointer<CxF64>, p8: Int32): Unit { cblas_ztrsv(p0, p1, p2, p3, p4, p5, p6, p7, p8) }
public unsafe func strmv(p0: Int32, p1: Int32, p2: Int32, p3: Int32, p4: Int32, p5: CPointer<Float32>, p6: Int32, p7: CPointer<Float32>, p8: Int32): Unit { cblas_strmv(p0, p1, p2, p3, p4, p5, p6, p7, p8) }
public unsafe func dtrmv(p0: Int32, p1: Int32, p2: Int32, p3: Int32, p4: Int32, p5: CPointer<Float64>, p6: Int32, p7: CPointer<Float64>, p8: Int32): Unit { cblas_dtrmv(p0, p1, p2, p3, p4, p5, p6, p7, p8) }
public unsafe func ctrmv(p0: Int32, p1: Int32, p2: Int32, p3: Int32, p4: Int32, p5: CPointer<CxF32>, p6: Int32, p7: CPointer<CxF32>, p8: Int32): Unit { cblas_ctrmv(p0, p1, p2, p3, p4, p5, p6, p7, p8) }
public unsafe func ztrmv(p0: Int32, p1: Int32, p2: Int32, p3: Int32, p4: Int32, p5: CPointer<CxF64>, p6: Int32, p7: CPointer<CxF64>, p8: Int32): Unit { cblas_ztrmv(p0, p1, p2, p3, p4, p5, p6, p7, p8) }
public unsafe func ssyr(p0: Int32, p1: Int32, p2: Int32, p3: Float32, p4: CPointer<Float32>, p5: Int32, p6: CPointer<Float32>, p7: Int32): Unit { cblas_ssyr(p0, p1, p2, p3, p4, p5, p6, p7) }
public unsafe func dsyr(p0: Int32, p1: Int32, p2: Int32, p3: Float64, p4: CPointer<Float64>, p5: Int32, p6: CPointer<Float64>, p7: Int32): Unit { cblas_dsyr(p0, p1, p2, p3, p4, p5, p6, p7) }
public unsafe func cher(p0: Int32, p1: Int32, p2: Int32, p3: Float32, p4: CPointer<CxF32>, p5: Int32, p6: CPointer<CxF32>, p7: Int32): Unit { cblas_cher(p0, p1, p2, p3, p4, p5, p6, p7) }
public unsafe func zher(p0: Int32, p1: Int32, p2: Int32, p3: Float64, p4: CPointer<CxF64>, p5: Int32, p6: CPointer<CxF64>, p7: Int32): Unit { cblas_zher(p0, p1, p2, p3, p4, p5, p6, p7) }
public unsafe func ssyr2(p0: Int32, p1: Int32, p2: Int32, p3: Float32, p4: CPointer<Float32>, p5: Int32, p6: CPointer<Float32>, p7: Int32, p8: CPointer<Float32>, p9: Int32): Unit { cblas_ssyr2(p0, p1, p2, p3, p4, p5, p6, p7, p8, p9) }
public unsafe func dsyr2(p0: Int32, p1: Int32, p2: Int32, p3: Float64, p4: CPointer<Float64>, p5: Int32, p6: CPointer<Float64>, p7: Int32, p8: CPointer<Float64>, p9: Int32): Unit { cblas_dsyr2(p0, p1, p2, p3, p4, p5, p6, p7, p8, p9) }
public unsafe func cher2(p0: Int32, p1: Int32, p2: Int32, p3: CPointer<CxF32>, p4: CPointer<CxF32>, p5: Int32, p6: CPointer<CxF32>, p7: Int32, p8: CPointer<CxF32>, p9: Int32): Unit { cblas_cher2(p0, p1, p2, p3, p4, p5, p6, p7, p8, p9) }
public unsafe func zher2(p0: Int32, p1: Int32, p2: Int32, p3: CPointer<CxF64>, p4: CPointer<CxF64>, p5: Int32, p6: CPointer<CxF64>, p7: Int32, p8: CPointer<CxF64>, p9: Int32): Unit { cblas_zher2(p0, p1, p2, p3, p4, p5, p6, p7, p8, p9) }
public unsafe func sgbmv(p0: Int32, p1: Int32, p2: Int32, p3: Int32, p4: Int32, p5: Int32, p6: Float32, p7: CPointer<Float32>, p8: Int32, p9: CPointer<Float32>, p10: Int32, p11: Float32, p12: CPointer<Float32>, p13: Int32): Unit { cblas_sgbmv(p0, p1, p2, p3, p4, p5, p6, p7, p8, p9, p10, p11, p12, p13) }
public unsafe func dgbmv(p0: Int32, p1: Int32, p2: Int32, p3: Int32, p4: Int32, p5: Int32, p6: Float64, p7: CPointer<Float64>, p8: Int32, p9: CPointer<Float64>, p10: Int32, p11: Float64, p12: CPointer<Float64>, p13: Int32): Unit { cblas_dgbmv(p0, p1, p2, p3, p4, p5, p6, p7, p8, p9, p10, p11, p12, p13) }
public unsafe func cgbmv(p0: Int32, p1: Int32, p2: Int32, p3: Int32, p4: Int32, p5: Int32, p6: CPointer<CxF32>, p7: CPointer<CxF32>, p8: Int32, p9: CPointer<CxF32>, p10: Int32, p11: CPointer<CxF32>, p12: CPointer<CxF32>, p13: Int32): Unit { cblas_cgbmv(p0, p1, p2, p3, p4, p5, p6, p7, p8, p9, p10, p11, p12, p13) }
public unsafe func zgbmv(p0: Int32, p1: Int32, p2: Int32, p3: Int32, p4: Int32, p5: Int32, p6: CPointer<CxF64>, p7: CPointer<CxF64>, p8: Int32, p9: CPointer<CxF64>, p10: Int32, p11: CPointer<CxF64>, p12: CPointer<CxF64>, p13: Int32): Unit { cblas_zgbmv(p0, p1, p2, p3, p4, p5, p6, p7, p8, p9, p10, p11, p12, p13) }
public unsafe func ssbmv(p0: Int32, p1: Int32, p2: Int32, p3: Int32, p4: Float32, p5: CPointer<Float32>, p6: Int32, p7: CPointer<Float32>, p8: Int32, p9: Float32, p10: CPointer<Float32>, p11: Int32): Unit { cblas_ssbmv(p0, p1, p2, p3, p4, p5, p6, p7, p8, p9, p10, p11) }
public unsafe func dsbmv(p0: Int32, p1: Int32, p2: Int32, p3: Int32, p4: Float64, p5: CPointer<Float64>, p6: Int32, p7: CPointer<Float64>, p8: Int32, p9: Float64, p10: CPointer<Float64>, p11: Int32): Unit { cblas_dsbmv(p0, p1, p2, p3, p4, p5, p6, p7, p8, p9, p10, p11) }
public unsafe func stbmv(p0: Int32, p1: Int32, p2: Int32, p3: Int32, p4: Int32, p5: Int32, p6: CPointer<Float32>, p7: Int32, p8: CPointer<Float32>, p9: Int32): Unit { cblas_stbmv(p0, p1, p2, p3, p4, p5, p6, p7, p8, p9) }
public unsafe func dtbmv(p0: Int32, p1: Int32, p2: Int32, p3: Int32, p4: Int32, p5: Int32, p6: CPointer<Float64>, p7: Int32, p8: CPointer<Float64>, p9: Int32): Unit { cblas_dtbmv(p0, p1, p2, p3, p4, p5, p6, p7, p8, p9) }
public unsafe func ctbmv(p0: Int32, p1: Int32, p2: Int32, p3: Int32, p4: Int32, p5: Int32, p6: CPointer<CxF32>, p7: Int32, p8: CPointer<CxF32>, p9: Int32): Unit { cblas_ctbmv(p0, p1, p2, p3, p4, p5, p6, p7, p8, p9) }
public unsafe func ztbmv(p0: Int32, p1: Int32, p2: Int32, p3: Int32, p4: Int32, p5: Int32, p6: CPointer<CxF64>, p7: Int32, p8: CPointer<CxF64>, p9: Int32): Unit { cblas_ztbmv(p0, p1, p2, p3, p4, p5, p6, p7, p8, p9) }
public unsafe func stbsv(p0: Int32, p1: Int32, p2: Int32, p3: Int32, p4: Int32, p5: Int32, p6: CPointer<Float32>, p7: Int32, p8: CPointer<Float32>, p9: Int32): Unit { cblas_stbsv(p0, p1, p2, p3, p4, p5, p6, p7, p8, p9) }
public unsafe func dtbsv(p0: Int32, p1: Int32, p2: Int32, p3: Int32, p4: Int32, p5: Int32, p6: CPointer<Float64>, p7: Int32, p8: CPointer<Float64>, p9: Int32): Unit { cblas_dtbsv(p0, p1, p2, p3, p4, p5, p6, p7, p8, p9) }
public unsafe func ctbsv(p0: Int32, p1: Int32, p2: Int32, p3: Int32, p4: Int32, p5: Int32, p6: CPointer<CxF32>, p7: Int32, p8: CPointer<CxF32>, p9: Int32): Unit { cblas_ctbsv(p0, p1, p2, p3, p4, p5, p6, p7, p8, p9) }
public unsafe func ztbsv(p0: Int32, p1: Int32, p2: Int32, p3: Int32, p4: Int32, p5: Int32, p6: CPointer<CxF64>, p7: Int32, p8: CPointer<CxF64>, p9: Int32): Unit { cblas_ztbsv(p0, p1, p2, p3, p4, p5, p6, p7, p8, p9) }
public unsafe func stpmv(p0: Int32, p1: Int32, p2: Int32, p3: Int32, p4: Int32, p5: CPointer<Float32>, p6: CPointer<Float32>, p7: Int32): Unit { cblas_stpmv(p0, p1, p2, p3, p4, p5, p6, p7) }
public unsafe func dtpmv(p0: Int32, p1: Int32, p2: Int32, p3: Int32, p4: Int32, p5: CPointer<Float64>, p6: CPointer<Float64>, p7: Int32): Unit { cblas_dtpmv(p0, p1, p2, p3, p4, p5, p6, p7) }
public unsafe func ctpmv(p0: Int32, p1: Int32, p2: Int32, p3: Int32, p4: Int32, p5: CPointer<CxF32>, p6: CPointer<CxF32>, p7: Int32): Unit { cblas_ctpmv(p0, p1, p2, p3, p4, p5, p6, p7) }
public unsafe func ztpmv(p0: Int32, p1: Int32, p2: Int32, p3: Int32, p4: Int32, p5: CPointer<CxF64>, p6: CPointer<CxF64>, p7: Int32): Unit { cblas_ztpmv(p0, p1, p2, p3, p4, p5, p6, p7) }
public unsafe func stpsv(p0: Int32, p1: Int32, p2: Int32, p3: Int32, p4: Int32, p5: CPointer<Float32>, p6: CPointer<Float32>, p7: Int32): Unit { cblas_stpsv(p0, p1, p2, p3, p4, p5, p6, p7) }
public unsafe func dtpsv(p0: Int32, p1: Int32, p2: Int32, p3: Int32, p4: Int32, p5: CPointer<Float64>, p6: CPointer<Float64>, p7: Int32): Unit { cblas_dtpsv(p0, p1, p2, p3, p4, p5, p6, p7) }
public unsafe func ctpsv(p0: Int32, p1: Int32, p2: Int32, p3: Int32, p4: Int32, p5: CPointer<CxF32>, p6: CPointer<CxF32>, p7: Int32): Unit { cblas_ctpsv(p0, p1, p2, p3, p4, p5, p6, p7) }
public unsafe func ztpsv(p0: Int32, p1: Int32, p2: Int32, p3: Int32, p4: Int32, p5: CPointer<CxF64>, p6: CPointer<CxF64>, p7: Int32): Unit { cblas_ztpsv(p0, p1, p2, p3, p4, p5, p6, p7) }
public unsafe func ssymv(p0: Int32, p1: Int32, p2: Int32, p3: Float32, p4: CPointer<Float32>, p5: Int32, p6: CPointer<Float32>, p7: Int32, p8: Float32, p9: CPointer<Float32>, p10: Int32): Unit { cblas_ssymv(p0, p1, p2, p3, p4, p5, p6, p7, p8, p9, p10) }
public unsafe func dsymv(p0: Int32, p1: Int32, p2: Int32, p3: Float64, p4: CPointer<Float64>, p5: Int32, p6: CPointer<Float64>, p7: Int32, p8: Float64, p9: CPointer<Float64>, p10: Int32): Unit { cblas_dsymv(p0, p1, p2, p3, p4, p5, p6, p7, p8, p9, p10) }
public unsafe func chemv(p0: Int32, p1: Int32, p2: Int32, p3: CPointer<CxF32>, p4: CPointer<CxF32>, p5: Int32, p6: CPointer<CxF32>, p7: Int32, p8: CPointer<CxF32>, p9: CPointer<CxF32>, p10: Int32): Unit { cblas_chemv(p0, p1, p2, p3, p4, p5, p6, p7, p8, p9, p10) }
public unsafe func zhemv(p0: Int32, p1: Int32, p2: Int32, p3: CPointer<CxF64>, p4: CPointer<CxF64>, p5: Int32, p6: CPointer<CxF64>, p7: Int32, p8: CPointer<CxF64>, p9: CPointer<CxF64>, p10: Int32): Unit { cblas_zhemv(p0, p1, p2, p3, p4, p5, p6, p7, p8, p9, p10) }
public unsafe func sspmv(p0: Int32, p1: Int32, p2: Int32, p3: Float32, p4: CPointer<Float32>, p5: CPointer<Float32>, p6: Int32, p7: Float32, p8: CPointer<Float32>, p9: Int32): Unit { cblas_sspmv(p0, p1, p2, p3, p4, p5, p6, p7, p8, p9) }
public unsafe func dspmv(p0: Int32, p1: Int32, p2: Int32, p3: Float64, p4: CPointer<Float64>, p5: CPointer<Float64>, p6: Int32, p7: Float64, p8: CPointer<Float64>, p9: Int32): Unit { cblas_dspmv(p0, p1, p2, p3, p4, p5, p6, p7, p8, p9) }
public unsafe func sspr(p0: Int32, p1: Int32, p2: Int32, p3: Float32, p4: CPointer<Float32>, p5: Int32, p6: CPointer<Float32>): Unit { cblas_sspr(p0, p1, p2, p3, p4, p5, p6) }
public unsafe func dspr(p0: Int32, p1: Int32, p2: Int32, p3: Float64, p4: CPointer<Float64>, p5: Int32, p6: CPointer<Float64>): Unit { cblas_dspr(p0, p1, p2, p3, p4, p5, p6) }
public unsafe func chpr(p0: Int32, p1: Int32, p2: Int32, p3: Float32, p4: CPointer<CxF32>, p5: Int32, p6: CPointer<CxF32>): Unit { cblas_chpr(p0, p1, p2, p3, p4, p5, p6) }
public unsafe func zhpr(p0: Int32, p1: Int32, p2: Int32, p3: Float64, p4: CPointer<CxF64>, p5: Int32, p6: CPointer<CxF64>): Unit { cblas_zhpr(p0, p1, p2, p3, p4, p5, p6) }
public unsafe func sspr2(p0: Int32, p1: Int32, p2: Int32, p3: Float32, p4: CPointer<Float32>, p5: Int32, p6: CPointer<Float32>, p7: Int32, p8: CPointer<Float32>): Unit { cblas_sspr2(p0, p1, p2, p3, p4, p5, p6, p7, p8) }
public unsafe func dspr2(p0: Int32, p1: Int32, p2: Int32, p3: Float64, p4: CPointer<Float64>, p5: Int32, p6: CPointer<Float64>, p7: Int32, p8: CPointer<Float64>): Unit { cblas_dspr2(p0, p1, p2, p3, p4, p5, p6, p7, p8) }
public unsafe func chpr2(p0: Int32, p1: Int32, p2: Int32, p3: CPointer<CxF32>, p4: CPointer<CxF32>, p5: Int32, p6: CPointer<CxF32>, p7: Int32, p8: CPointer<CxF32>): Unit { cblas_chpr2(p0, p1, p2, p3, p4, p5, p6, p7, p8) }
public unsafe func zhpr2(p0: Int32, p1: Int32, p2: Int32, p3: CPointer<CxF64>, p4: CPointer<CxF64>, p5: Int32, p6: CPointer<CxF64>, p7: Int32, p8: CPointer<CxF64>): Unit { cblas_zhpr2(p0, p1, p2, p3, p4, p5, p6, p7, p8) }
public unsafe func chbmv(p0: Int32, p1: Int32, p2: Int32, p3: Int32, p4: CPointer<CxF32>, p5: CPointer<CxF32>, p6: Int32, p7: CPointer<CxF32>, p8: Int32, p9: CPointer<CxF32>, p10: CPointer<CxF32>, p11: Int32): Unit { cblas_chbmv(p0, p1, p2, p3, p4, p5, p6, p7, p8, p9, p10, p11) }
public unsafe func zhbmv(p0: Int32, p1: Int32, p2: Int32, p3: Int32, p4: CPointer<CxF64>, p5: CPointer<CxF64>, p6: Int32, p7: CPointer<CxF64>, p8: Int32, p9: CPointer<CxF64>, p10: CPointer<CxF64>, p11: Int32): Unit { cblas_zhbmv(p0, p1, p2, p3, p4, p5, p6, p7, p8, p9, p10, p11) }
public unsafe func chpmv(p0: Int32, p1: Int32, p2: Int32, p3: CPointer<CxF32>, p4: CPointer<CxF32>, p5: CPointer<CxF32>, p6: Int32, p7: CPointer<CxF32>, p8: CPointer<CxF32>, p9: Int32): Unit { cblas_chpmv(p0, p1, p2, p3, p4, p5, p6, p7, p8, p9) }
public unsafe func zhpmv(p0: Int32, p1: Int32, p2: Int32, p3: CPointer<CxF64>, p4: CPointer<CxF64>, p5: CPointer<CxF64>, p6: Int32, p7: CPointer<CxF64>, p8: CPointer<CxF64>, p9: Int32): Unit { cblas_zhpmv(p0, p1, p2, p3, p4, p5, p6, p7, p8, p9) }
public unsafe func sgemm(p0: Int32, p1: Int32, p2: Int32, p3: Int32, p4: Int32, p5: Int32, p6: Float32, p7: CPointer<Float32>, p8: Int32, p9: CPointer<Float32>, p10: Int32, p11: Float32, p12: CPointer<Float32>, p13: Int32): Unit { cblas_sgemm(p0, p1, p2, p3, p4, p5, p6, p7, p8, p9, p10, p11, p12, p13) }
public unsafe func dgemm(p0: Int32, p1: Int32, p2: Int32, p3: Int32, p4: Int32, p5: Int32, p6: Float64, p7: CPointer<Float64>, p8: Int32, p9: CPointer<Float64>, p10: Int32, p11: Float64, p12: CPointer<Float64>, p13: Int32): Unit { cblas_dgemm(p0, p1, p2, p3, p4, p5, p6, p7, p8, p9, p10, p11, p12, p13) }
public unsafe func cgemm(p0: Int32, p1: Int32, p2: Int32, p3: Int32, p4: Int32, p5: Int32, p6: CPointer<CxF32>, p7: CPointer<CxF32>, p8: Int32, p9: CPointer<CxF32>, p10: Int32, p11: CPointer<CxF32>, p12: CPointer<CxF32>, p13: Int32): Unit { cblas_cgemm(p0, p1, p2, p3, p4, p5, p6, p7, p8, p9, p10, p11, p12, p13) }
public unsafe func zgemm(p0: Int32, p1: Int32, p2: Int32, p3: Int32, p4: Int32, p5: Int32, p6: CPointer<CxF64>, p7: CPointer<CxF64>, p8: Int32, p9: CPointer<CxF64>, p10: Int32, p11: CPointer<CxF64>, p12: CPointer<CxF64>, p13: Int32): Unit { cblas_zgemm(p0, p1, p2, p3, p4, p5, p6, p7, p8, p9, p10, p11, p12, p13) }
public unsafe func sgemmt(p0: Int32, p1: Int32, p2: Int32, p3: Int32, p4: Int32, p5: Int32, p6: Float32, p7: CPointer<Float32>, p8: Int32, p9: CPointer<Float32>, p10: Int32, p11: Float32, p12: CPointer<Float32>, p13: Int32): Unit { cblas_sgemmt(p0, p1, p2, p3, p4, p5, p6, p7, p8, p9, p10, p11, p12, p13) }
public unsafe func dgemmt(p0: Int32, p1: Int32, p2: Int32, p3: Int32, p4: Int32, p5: Int32, p6: Float64, p7: CPointer<Float64>, p8: Int32, p9: CPointer<Float64>, p10: Int32, p11: Float64, p12: CPointer<Float64>, p13: Int32): Unit { cblas_dgemmt(p0, p1, p2, p3, p4, p5, p6, p7, p8, p9, p10, p11, p12, p13) }
public unsafe func cgemmt(p0: Int32, p1: Int32, p2: Int32, p3: Int32, p4: Int32, p5: Int32, p6: CPointer<CxF32>, p7: CPointer<CxF32>, p8: Int32, p9: CPointer<CxF32>, p10: Int32, p11: CPointer<CxF32>, p12: CPointer<CxF32>, p13: Int32): Unit { cblas_cgemmt(p0, p1, p2, p3, p4, p5, p6, p7, p8, p9, p10, p11, p12, p13) }
public unsafe func zgemmt(p0: Int32, p1: Int32, p2: Int32, p3: Int32, p4: Int32, p5: Int32, p6: CPointer<CxF64>, p7: CPointer<CxF64>, p8: Int32, p9: CPointer<CxF64>, p10: Int32, p11: CPointer<CxF64>, p12: CPointer<CxF64>, p13: Int32): Unit { cblas_zgemmt(p0, p1, p2, p3, p4, p5, p6, p7, p8, p9, p10, p11, p12, p13) }
public unsafe func ssymm(p0: Int32, p1: Int32, p2: Int32, p3: Int32, p4: Int32, p5: Float32, p6: CPointer<Float32>, p7: Int32, p8: CPointer<Float32>, p9: Int32, p10: Float32, p11: CPointer<Float32>, p12: Int32): Unit { cblas_ssymm(p0, p1, p2, p3, p4, p5, p6, p7, p8, p9, p10, p11, p12) }
public unsafe func dsymm(p0: Int32, p1: Int32, p2: Int32, p3: Int32, p4: Int32, p5: Float64, p6: CPointer<Float64>, p7: Int32, p8: CPointer<Float64>, p9: Int32, p10: Float64, p11: CPointer<Float64>, p12: Int32): Unit { cblas_dsymm(p0, p1, p2, p3, p4, p5, p6, p7, p8, p9, p10, p11, p12) }
public unsafe func csymm(p0: Int32, p1: Int32, p2: Int32, p3: Int32, p4: Int32, p5: CPointer<CxF32>, p6: CPointer<CxF32>, p7: Int32, p8: CPointer<CxF32>, p9: Int32, p10: CPointer<CxF32>, p11: CPointer<CxF32>, p12: Int32): Unit { cblas_csymm(p0, p1, p2, p3, p4, p5, p6, p7, p8, p9, p10, p11, p12) }
public unsafe func zsymm(p0: Int32, p1: Int32, p2: Int32, p3: Int32, p4: Int32, p5: CPointer<CxF64>, p6: CPointer<CxF64>, p7: Int32, p8: CPointer<CxF64>, p9: Int32, p10: CPointer<CxF64>, p11: CPointer<CxF64>, p12: Int32): Unit { cblas_zsymm(p0, p1, p2, p3, p4, p5, p6, p7, p8, p9, p10, p11, p12) }
public unsafe func ssyrk(p0: Int32, p1: Int32, p2: Int32, p3: Int32, p4: Int32, p5: Float32, p6: CPointer<Float32>, p7: Int32, p8: Float32, p9: CPointer<Float32>, p10: Int32): Unit { cblas_ssyrk(p0, p1, p2, p3, p4, p5, p6, p7, p8, p9, p10) }
public unsafe func dsyrk(p0: Int32, p1: Int32, p2: Int32, p3: Int32, p4: Int32, p5: Float64, p6: CPointer<Float64>, p7: Int32, p8: Float64, p9: CPointer<Float64>, p10: Int32): Unit { cblas_dsyrk(p0, p1, p2, p3, p4, p5, p6, p7, p8, p9, p10) }
public unsafe func csyrk(p0: Int32, p1: Int32, p2: Int32, p3: Int32, p4: Int32, p5: CPointer<CxF32>, p6: CPointer<CxF32>, p7: Int32, p8: CPointer<CxF32>, p9: CPointer<CxF32>, p10: Int32): Unit { cblas_csyrk(p0, p1, p2, p3, p4, p5, p6, p7, p8, p9, p10) }
public unsafe func zsyrk(p0: Int32, p1: Int32, p2: Int32, p3: Int32, p4: Int32, p5: CPointer<CxF64>, p6: CPointer<CxF64>, p7: Int32, p8: CPointer<CxF64>, p9: CPointer<CxF64>, p10: Int32): Unit { cblas_zsyrk(p0, p1, p2, p3, p4, p5, p6, p7, p8, p9, p10) }
public unsafe func ssyr2k(p0: Int32, p1: Int32, p2: Int32, p3: Int32, p4: Int32, p5: Float32, p6: CPointer<Float32>, p7: Int32, p8: CPointer<Float32>, p9: Int32, p10: Float32, p11: CPointer<Float32>, p12: Int32): Unit { cblas_ssyr2k(p0, p1, p2, p3, p4, p5, p6, p7, p8, p9, p10, p11, p12) }
public unsafe func dsyr2k(p0: Int32, p1: Int32, p2: Int32, p3: Int32, p4: Int32, p5: Float64, p6: CPointer<Float64>, p7: Int32, p8: CPointer<Float64>, p9: Int32, p10: Float64, p11: CPointer<Float64>, p12: Int32): Unit { cblas_dsyr2k(p0, p1, p2, p3, p4, p5, p6, p7, p8, p9, p10, p11, p12) }
public unsafe func csyr2k(p0: Int32, p1: Int32, p2: Int32, p3: Int32, p4: Int32, p5: CPointer<CxF32>, p6: CPointer<CxF32>, p7: Int32, p8: CPointer<CxF32>, p9: Int32, p10: CPointer<CxF32>, p11: CPointer<CxF32>, p12: Int32): Unit { cblas_csyr2k(p0, p1, p2, p3, p4, p5, p6, p7, p8, p9, p10, p11, p12) }
public unsafe func zsyr2k(p0: Int32, p1: Int32, p2: Int32, p3: Int32, p4: Int32, p5: CPointer<CxF64>, p6: CPointer<CxF64>, p7: Int32, p8: CPointer<CxF64>, p9: Int32, p10: CPointer<CxF64>, p11: CPointer<CxF64>, p12: Int32): Unit { cblas_zsyr2k(p0, p1, p2, p3, p4, p5, p6, p7, p8, p9, p10, p11, p12) }
public unsafe func strmm(p0: Int32, p1: Int32, p2: Int32, p3: Int32, p4: Int32, p5: Int32, p6: Int32, p7: Float32, p8: CPointer<Float32>, p9: Int32, p10: CPointer<Float32>, p11: Int32): Unit { cblas_strmm(p0, p1, p2, p3, p4, p5, p6, p7, p8, p9, p10, p11) }
public unsafe func dtrmm(p0: Int32, p1: Int32, p2: Int32, p3: Int32, p4: Int32, p5: Int32, p6: Int32, p7: Float64, p8: CPointer<Float64>, p9: Int32, p10: CPointer<Float64>, p11: Int32): Unit { cblas_dtrmm(p0, p1, p2, p3, p4, p5, p6, p7, p8, p9, p10, p11) }
public unsafe func ctrmm(p0: Int32, p1: Int32, p2: Int32, p3: Int32, p4: Int32, p5: Int32, p6: Int32, p7: CPointer<CxF32>, p8: CPointer<CxF32>, p9: Int32, p10: CPointer<CxF32>, p11: Int32): Unit { cblas_ctrmm(p0, p1, p2, p3, p4, p5, p6, p7, p8, p9, p10, p11) }
public unsafe func ztrmm(p0: Int32, p1: Int32, p2: Int32, p3: Int32, p4: Int32, p5: Int32, p6: Int32, p7: CPointer<CxF64>, p8: CPointer<CxF64>, p9: Int32, p10: CPointer<CxF64>, p11: Int32): Unit { cblas_ztrmm(p0, p1, p2, p3, p4, p5, p6, p7, p8, p9, p10, p11) }
public unsafe func strsm(p0: Int32, p1: Int32, p2: Int32, p3: Int32, p4: Int32, p5: Int32, p6: Int32, p7: Float32, p8: CPointer<Float32>, p9: Int32, p10: CPointer<Float32>, p11: Int32): Unit { cblas_strsm(p0, p1, p2, p3, p4, p5, p6, p7, p8, p9, p10, p11) }
public unsafe func dtrsm(p0: Int32, p1: Int32, p2: Int32, p3: Int32, p4: Int32, p5: Int32, p6: Int32, p7: Float64, p8: CPointer<Float64>, p9: Int32, p10: CPointer<Float64>, p11: Int32): Unit { cblas_dtrsm(p0, p1, p2, p3, p4, p5, p6, p7, p8, p9, p10, p11) }
public unsafe func ctrsm(p0: Int32, p1: Int32, p2: Int32, p3: Int32, p4: Int32, p5: Int32, p6: Int32, p7: CPointer<CxF32>, p8: CPointer<CxF32>, p9: Int32, p10: CPointer<CxF32>, p11: Int32): Unit { cblas_ctrsm(p0, p1, p2, p3, p4, p5, p6, p7, p8, p9, p10, p11) }
public unsafe func ztrsm(p0: Int32, p1: Int32, p2: Int32, p3: Int32, p4: Int32, p5: Int32, p6: Int32, p7: CPointer<CxF64>, p8: CPointer<CxF64>, p9: Int32, p10: CPointer<CxF64>, p11: Int32): Unit { cblas_ztrsm(p0, p1, p2, p3, p4, p5, p6, p7, p8, p9, p10, p11) }
public unsafe func chemm(p0: Int32, p1: Int32, p2: Int32, p3: Int32, p4: Int32, p5: CPointer<CxF32>, p6: CPointer<CxF32>, p7: Int32, p8: CPointer<CxF32>, p9: Int32, p10: CPointer<CxF32>, p11: CPointer<CxF32>, p12: Int32): Unit { cblas_chemm(p0, p1, p2, p3, p4, p5, p6, p7, p8, p9, p10, p11, p12) }
public unsafe func zhemm(p0: Int32, p1: Int32, p2: Int32, p3: Int32, p4: Int32, p5: CPointer<CxF64>, p6: CPointer<CxF64>, p7: Int32, p8: CPointer<CxF64>, p9: Int32, p10: CPointer<CxF64>, p11: CPointer<CxF64>, p12: Int32): Unit { cblas_zhemm(p0, p1, p2, p3, p4, p5, p6, p7, p8, p9, p10, p11, p12) }
public unsafe func cherk(p0: Int32, p1: Int32, p2: Int32, p3: Int32, p4: Int32, p5: Float32, p6: CPointer<CxF32>, p7: Int32, p8: Float32, p9: CPointer<CxF32>, p10: Int32): Unit { cblas_cherk(p0, p1, p2, p3, p4, p5, p6, p7, p8, p9, p10) }
public unsafe func zherk(p0: Int32, p1: Int32, p2: Int32, p3: Int32, p4: Int32, p5: Float64, p6: CPointer<CxF64>, p7: Int32, p8: Float64, p9: CPointer<CxF64>, p10: Int32): Unit { cblas_zherk(p0, p1, p2, p3, p4, p5, p6, p7, p8, p9, p10) }
public unsafe func cher2k(p0: Int32, p1: Int32, p2: Int32, p3: Int32, p4: Int32, p5: CPointer<CxF32>, p6: CPointer<CxF32>, p7: Int32, p8: CPointer<CxF32>, p9: Int32, p10: Float32, p11: CPointer<CxF32>, p12: Int32): Unit { cblas_cher2k(p0, p1, p2, p3, p4, p5, p6, p7, p8, p9, p10, p11, p12) }
public unsafe func zher2k(p0: Int32, p1: Int32, p2: Int32, p3: Int32, p4: Int32, p5: CPointer<CxF64>, p6: CPointer<CxF64>, p7: Int32, p8: CPointer<CxF64>, p9: Int32, p10: Float64, p11: CPointer<CxF64>, p12: Int32): Unit { cblas_zher2k(p0, p1, p2, p3, p4, p5, p6, p7, p8, p9, p10, p11, p12) }
public unsafe func saxpby(p0: Int32, p1: Float32, p2: CPointer<Float32>, p3: Int32, p4: Float32, p5: CPointer<Float32>, p6: Int32): Unit { cblas_saxpby(p0, p1, p2, p3, p4, p5, p6) }
public unsafe func daxpby(p0: Int32, p1: Float64, p2: CPointer<Float64>, p3: Int32, p4: Float64, p5: CPointer<Float64>, p6: Int32): Unit { cblas_daxpby(p0, p1, p2, p3, p4, p5, p6) }
public unsafe func caxpby(p0: Int32, p1: CPointer<CxF32>, p2: CPointer<CxF32>, p3: Int32, p4: CPointer<CxF32>, p5: CPointer<CxF32>, p6: Int32): Unit { cblas_caxpby(p0, p1, p2, p3, p4, p5, p6) }
public unsafe func zaxpby(p0: Int32, p1: CPointer<CxF64>, p2: CPointer<CxF64>, p3: Int32, p4: CPointer<CxF64>, p5: CPointer<CxF64>, p6: Int32): Unit { cblas_zaxpby(p0, p1, p2, p3, p4, p5, p6) }
public unsafe func somatcopy(p0: Int32, p1: Int32, p2: Int32, p3: Int32, p4: Float32, p5: CPointer<Float32>, p6: Int32, p7: CPointer<Float32>, p8: Int32): Unit { cblas_somatcopy(p0, p1, p2, p3, p4, p5, p6, p7, p8) }
public unsafe func domatcopy(p0: Int32, p1: Int32, p2: Int32, p3: Int32, p4: Float64, p5: CPointer<Float64>, p6: Int32, p7: CPointer<Float64>, p8: Int32): Unit { cblas_domatcopy(p0, p1, p2, p3, p4, p5, p6, p7, p8) }
public unsafe func comatcopy(p0: Int32, p1: Int32, p2: Int32, p3: Int32, p4: CPointer<Float32>, p5: CPointer<Float32>, p6: Int32, p7: CPointer<Float32>, p8: Int32): Unit { cblas_comatcopy(p0, p1, p2, p3, p4, p5, p6, p7, p8) }
public unsafe func zomatcopy(p0: Int32, p1: Int32, p2: Int32, p3: Int32, p4: CPointer<Float64>, p5: CPointer<Float64>, p6: Int32, p7: CPointer<Float64>, p8: Int32): Unit { cblas_zomatcopy(p0, p1, p2, p3, p4, p5, p6, p7, p8) }
public unsafe func simatcopy(p0: Int32, p1: Int32, p2: Int32, p3: Int32, p4: Float32, p5: CPointer<Float32>, p6: Int32, p7: Int32): Unit { cblas_simatcopy(p0, p1, p2, p3, p4, p5, p6, p7) }
public unsafe func dimatcopy(p0: Int32, p1: Int32, p2: Int32, p3: Int32, p4: Float64, p5: CPointer<Float64>, p6: Int32, p7: Int32): Unit { cblas_dimatcopy(p0, p1, p2, p3, p4, p5, p6, p7) }
public unsafe func cimatcopy(p0: Int32, p1: Int32, p2: Int32, p3: Int32, p4: CPointer<Float32>, p5: CPointer<Float32>, p6: Int32, p7: Int32): Unit { cblas_cimatcopy(p0, p1, p2, p3, p4, p5, p6, p7) }
public unsafe func zimatcopy(p0: Int32, p1: Int32, p2: Int32, p3: Int32, p4: CPointer<Float64>, p5: CPointer<Float64>, p6: Int32, p7: Int32): Unit { cblas_zimatcopy(p0, p1, p2, p3, p4, p5, p6, p7) }
public unsafe func sgeadd(p0: Int32, p1: Int32, p2: Int32, p3: Float32, p4: CPointer<Float32>, p5: Int32, p6: Float32, p7: CPointer<Float32>, p8: Int32): Unit { cblas_sgeadd(p0, p1, p2, p3, p4, p5, p6, p7, p8) }
public unsafe func dgeadd(p0: Int32, p1: Int32, p2: Int32, p3: Float64, p4: CPointer<Float64>, p5: Int32, p6: Float64, p7: CPointer<Float64>, p8: Int32): Unit { cblas_dgeadd(p0, p1, p2, p3, p4, p5, p6, p7, p8) }
public unsafe func cgeadd(p0: Int32, p1: Int32, p2: Int32, p3: CPointer<Float32>, p4: CPointer<Float32>, p5: Int32, p6: CPointer<Float32>, p7: CPointer<Float32>, p8: Int32): Unit { cblas_cgeadd(p0, p1, p2, p3, p4, p5, p6, p7, p8) }
public unsafe func zgeadd(p0: Int32, p1: Int32, p2: Int32, p3: CPointer<Float64>, p4: CPointer<Float64>, p5: Int32, p6: CPointer<Float64>, p7: CPointer<Float64>, p8: Int32): Unit { cblas_zgeadd(p0, p1, p2, p3, p4, p5, p6, p7, p8) }
public unsafe func sgemm_batch(p0: Int32, p1: CPointer<Int32>, p2: CPointer<Int32>, p3: CPointer<Int32>, p4: CPointer<Int32>, p5: CPointer<Int32>, p6: CPointer<Float32>, p7: CPointer<CPointer<Float32>>, p8: CPointer<Int32>, p9: CPointer<CPointer<Float32>>, p10: CPointer<Int32>, p11: CPointer<Float32>, p12: CPointer<CPointer<Float32>>, p13: CPointer<Int32>, p14: Int32, p15: CPointer<Int32>): Unit { cblas_sgemm_batch(p0, p1, p2, p3, p4, p5, p6, p7, p8, p9, p10, p11, p12, p13, p14, p15) }
public unsafe func dgemm_batch(p0: Int32, p1: CPointer<Int32>, p2: CPointer<Int32>, p3: CPointer<Int32>, p4: CPointer<Int32>, p5: CPointer<Int32>, p6: CPointer<Float64>, p7: CPointer<CPointer<Float64>>, p8: CPointer<Int32>, p9: CPointer<CPointer<Float64>>, p10: CPointer<Int32>, p11: CPointer<Float64>, p12: CPointer<CPointer<Float64>>, p13: CPointer<Int32>, p14: Int32, p15: CPointer<Int32>): Unit { cblas_dgemm_batch(p0, p1, p2, p3, p4, p5, p6, p7, p8, p9, p10, p11, p12, p13, p14, p15) }
public unsafe func cgemm_batch(p0: Int32, p1: CPointer<Int32>, p2: CPointer<Int32>, p3: CPointer<Int32>, p4: CPointer<Int32>, p5: CPointer<Int32>, p6: CPointer<CxF32>, p7: CPointer<CPointer<CxF32>>, p8: CPointer<Int32>, p9: CPointer<CPointer<CxF32>>, p10: CPointer<Int32>, p11: CPointer<CxF32>, p12: CPointer<CPointer<CxF32>>, p13: CPointer<Int32>, p14: Int32, p15: CPointer<Int32>): Unit { cblas_cgemm_batch(p0, p1, p2, p3, p4, p5, p6, p7, p8, p9, p10, p11, p12, p13, p14, p15) }
public unsafe func zgemm_batch(p0: Int32, p1: CPointer<Int32>, p2: CPointer<Int32>, p3: CPointer<Int32>, p4: CPointer<Int32>, p5: CPointer<Int32>, p6: CPointer<CxF64>, p7: CPointer<CPointer<CxF64>>, p8: CPointer<Int32>, p9: CPointer<CPointer<CxF64>>, p10: CPointer<Int32>, p11: CPointer<CxF64>, p12: CPointer<CPointer<CxF64>>, p13: CPointer<Int32>, p14: Int32, p15: CPointer<Int32>): Unit { cblas_zgemm_batch(p0, p1, p2, p3, p4, p5, p6, p7, p8, p9, p10, p11, p12, p13, p14, p15) }
