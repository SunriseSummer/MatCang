#!/usr/bin/env python3
"""Generate Cangjie `foreign func` bindings for the OpenBLAS C API.

Parses cblas.h and lapacke.h and emits Cangjie declarations into the
matcang.ffi package. This is the mechanical "map all interfaces" layer.
"""
import re
import sys
import os

# ---- type mapping ---------------------------------------------------------
VALUE_MAP = {
    'void': 'Unit',
    'float': 'Float32',
    'double': 'Float64',
    'int': 'Int32',
    'blasint': 'Int32',
    'lapack_int': 'Int32',
    'lapack_logical': 'Int32',
    'char': 'Int8',
    'size_t': 'UIntNative',
    'CBLAS_INDEX': 'UIntNative',
    'CBLAS_ORDER': 'Int32',
    'CBLAS_TRANSPOSE': 'Int32',
    'CBLAS_UPLO': 'Int32',
    'CBLAS_DIAG': 'Int32',
    'CBLAS_SIDE': 'Int32',
    'CBLAS_LAYOUT': 'Int32',
    'lapack_complex_float': 'CxF32',
    'openblas_complex_float': 'CxF32',
    'lapack_complex_double': 'CxF64',
    'openblas_complex_double': 'CxF64',
    'cpu_set_t': 'Unit',
    'bfloat16': 'UInt16',
    'hfloat16': 'UInt16',
    'openblas_threads_callback': 'CPointer<Unit>',
    'openblas_dojob_callback': 'CPointer<Unit>',
}
PTR_INNER = {
    'void': 'Unit',
    'float': 'Float32',
    'double': 'Float64',
    'int': 'Int32',
    'blasint': 'Int32',
    'lapack_int': 'Int32',
    'lapack_logical': 'Int32',
    'size_t': 'UIntNative',
    'lapack_complex_float': 'CxF32',
    'openblas_complex_float': 'CxF32',
    'lapack_complex_double': 'CxF64',
    'openblas_complex_double': 'CxF64',
    'cpu_set_t': 'Unit',
    'bfloat16': 'UInt16',
    'hfloat16': 'UInt16',
    'char': 'Int8',
    'CBLAS_ORDER': 'Int32',
    'CBLAS_TRANSPOSE': 'Int32',
    'CBLAS_UPLO': 'Int32',
    'CBLAS_DIAG': 'Int32',
    'CBLAS_SIDE': 'Int32',
    'CBLAS_LAYOUT': 'Int32',
}
SELECT_RE = re.compile(r'LAPACK_[SDCZ]_SELECT[123]')

unknown_types = set()


def clean_header(text):
    # strip C block comments
    text = re.sub(r'/\*.*?\*/', ' ', text, flags=re.S)
    # strip // line comments
    text = re.sub(r'//[^\n]*', ' ', text)
    # drop preprocessor lines
    lines = [ln for ln in text.split('\n') if not ln.lstrip().startswith('#')]
    text = '\n'.join(lines)
    return text


def map_type(base, ptr, name_for_msg):
    base = base.strip()
    if SELECT_RE.fullmatch(base):
        return 'CPointer<Unit>'  # opaque callback pointer
    if ptr == 0:
        if base in VALUE_MAP:
            return VALUE_MAP[base]
        unknown_types.add((base, 0, name_for_msg))
        return 'Int32'
    # pointer (possibly multi-level)
    if base == 'char' and ptr == 1:
        return 'CString'
    if base in PTR_INNER:
        inner = PTR_INNER[base]
    else:
        unknown_types.add((base, ptr, name_for_msg))
        inner = 'Unit'
    t = inner
    for _ in range(ptr):
        t = 'CPointer<{}>'.format(t)
    return t


def parse_arg(arg):
    """Return (cj_type, is_vararg)."""
    a = arg.strip()
    if a == '...':
        return ('...', True)
    if a == 'void' or a == '':
        return (None, False)
    # remove qualifiers
    a = re.sub(r'\b(const|OPENBLAS_CONST|enum|struct|register)\b', ' ', a)
    ptr = a.count('*')
    a = a.replace('*', ' ')
    toks = a.split()
    # drop trailing param name if there is more than one token
    if len(toks) >= 2:
        base = ' '.join(toks[:-1])
    else:
        base = toks[0]
    # base could be multiword like 'lapack complex float' -> rejoin underscores? no,
    # multiword C types here are single tokens already (lapack_complex_float).
    # If base has spaces it means unexpected; take last token.
    if ' ' in base:
        base = base.split()[-1]
    return (map_type(base, ptr, arg), False)


def parse_proto(chunk):
    chunk = chunk.strip()
    if not chunk or 'typedef' in chunk:
        return None
    lp = chunk.find('(')
    if lp < 0:
        return None
    rp = chunk.rfind(')')
    if rp < lp:
        return None
    header = chunk[:lp].strip()
    argstr = chunk[lp + 1:rp].strip()
    # function name = last identifier in header
    m = re.match(r'^(.*?)([A-Za-z_]\w*)\s*$', header, re.S)
    if not m:
        return None
    ret_spec = m.group(1)
    name = m.group(2)
    if not re.match(r'^(cblas_|LAPACKE_|LAPACK_|openblas_|goto_|blas_)', name):
        return None
    if '(*' in argstr:  # inline function pointer param - skip (none expected)
        return None
    # return type
    ret_spec2 = re.sub(r'\b(const|OPENBLAS_CONST|enum|struct)\b', ' ', ret_spec)
    ret_ptr = ret_spec2.count('*')
    ret_spec2 = ret_spec2.replace('*', ' ')
    rtoks = ret_spec2.split()
    ret_base = rtoks[-1] if rtoks else 'void'
    ret_cj = map_type(ret_base, ret_ptr, name)
    # args
    args = []
    varargs = False
    if argstr and argstr != 'void':
        for part in argstr.split(','):
            t, isv = parse_arg(part)
            if isv:
                varargs = True
                continue
            if t is None:
                continue
            args.append(t)
    return (name, args, ret_cj, varargs)


def emit(protos):
    lines = []
    for (name, args, ret, va) in protos:
        params = []
        for i, t in enumerate(args):
            params.append('p{}: {}'.format(i, t))
        if va:
            params.append('...')
        sig = 'func {}({}): {}'.format(name, ', '.join(params), ret)
        lines.append(sig)
    return lines


def wrapper_short_name(name):
    """Canonical BLAS/LAPACK routine name (drop the C-interface prefix)."""
    if name.startswith('cblas_'):
        return name[len('cblas_'):]
    if name.startswith('LAPACKE_'):
        return name[len('LAPACKE_'):]
    return None


def emit_wrappers(protos):
    """Public, module-linkable `unsafe` wrappers that forward to the foreign
    decls (which are only directly callable inside their own package)."""
    lines = []
    names = []
    for (name, args, ret, va) in protos:
        short = wrapper_short_name(name)
        if short is None or va:
            continue
        params = ', '.join('p{}: {}'.format(i, t) for i, t in enumerate(args))
        callargs = ', '.join('p{}'.format(i) for i in range(len(args)))
        body = '{}({})'.format(name, callargs)
        lines.append('public unsafe func {}({}): {} {{ {} }}'.format(short, params, ret, body))
        names.append(short)
    return lines, names


def collect(header_path):
    text = open(header_path, 'r', errors='replace').read()
    text = clean_header(text)
    protos = []
    seen = set()
    for chunk in text.split(';'):
        p = parse_proto(chunk)
        if p:
            if p[0] in seen:
                continue
            seen.add(p[0])
            protos.append(p)
    return protos


def main():
    cblas_h = sys.argv[1]
    lapacke_h = sys.argv[2]
    outdir = sys.argv[3]
    include_work = (len(sys.argv) > 4 and sys.argv[4] == 'work')
    symbol_file = sys.argv[5] if len(sys.argv) > 5 else None
    os.makedirs(outdir, exist_ok=True)

    allow = None
    if symbol_file:
        with open(symbol_file) as f:
            allow = set(line.strip() for line in f if line.strip())

    cblas = collect(cblas_h)
    lapacke = collect(lapacke_h)

    if allow is not None:
        before = len(cblas) + len(lapacke)
        cblas = [p for p in cblas if p[0] in allow]
        lapacke = [p for p in lapacke if p[0] in allow]
        after = len(cblas) + len(lapacke)
        print("symbol filter: kept {} of {} (dropped {} not exported by the library)".format(
            after, before, before - after))

    # split cblas into cblas_ vs openblas/util
    cblas_funcs = [p for p in cblas if p[0].startswith('cblas_')]
    util_funcs = [p for p in cblas if not p[0].startswith('cblas_')]

    if not include_work:
        lapacke = [p for p in lapacke if not p[0].endswith('_work')]

    # split lapacke by precision letter (LAPACKE_x...)
    buckets = {'s': [], 'd': [], 'c': [], 'z': [], 'aux': []}
    for p in lapacke:
        nm = p[0]
        rest = nm[len('LAPACKE_'):] if nm.startswith('LAPACKE_') else nm
        c0 = rest[0] if rest else 'aux'
        if c0 in ('s', 'd', 'c', 'z'):
            buckets[c0].append(p)
        else:
            buckets['aux'].append(p)

    header = ("/*\n * Raw foreign declarations for the OpenBLAS C API.\n"
              " * AUTO-GENERATED from OpenBLAS v0.3.33 headers (cblas.h / lapacke.h).\n"
              " * Do not edit by hand; regenerate with tools/gen_bindings.py.\n *\n"
              " * These live in the root `matcang` package (not a subpackage) because\n"
              " * Cangjie `foreign` functions are package-internal and can carry no access\n"
              " * modifier; keeping them at the root lets every matcang.* subpackage call\n"
              " * them while remaining hidden from external importers.\n */\n"
              "package matcang\n\n")

    wrap_header = ("/*\n * Public, safe-to-link wrappers over the raw OpenBLAS foreign decls.\n"
                   " * AUTO-GENERATED; do not edit by hand (see tools/gen_bindings.py).\n *\n"
                   " * Cangjie `foreign` functions only resolve to their C symbol when called\n"
                   " * from inside their declaring package, so these thin `unsafe` forwarders\n"
                   " * (regular public functions, hence linkable across the whole module) give\n"
                   " * every subpackage - and external users - access to the full BLAS/LAPACK\n"
                   " * surface under its canonical routine name (e.g. `dgemm`, `dgesv`).\n */\n"
                   "package matcang\n\n")

    all_wrapper_names = []

    def write_file(fname, protos, note):
        path = os.path.join(outdir, fname)
        with open(path, 'w') as f:
            f.write(header)
            f.write("// {} : {} functions\n\n".format(note, len(protos)))
            f.write("foreign {\n")
            for line in emit(protos):
                f.write("    " + line + "\n")
            f.write("}\n")
        return len(protos)

    def write_wrap_file(fname, protos, note):
        wlines, wnames = emit_wrappers(protos)
        all_wrapper_names.extend(wnames)
        path = os.path.join(outdir, fname)
        with open(path, 'w') as f:
            f.write(wrap_header)
            f.write("// {} : {} wrappers\n\n".format(note, len(wlines)))
            for line in wlines:
                f.write(line + "\n")
        return len(wlines)

    total = 0
    total += write_file('ffi_cblas.cj', cblas_funcs, 'CBLAS interface')
    total += write_file('ffi_openblas_util.cj', util_funcs, 'OpenBLAS utility/control functions')
    for k in ('s', 'd', 'c', 'z', 'aux'):
        total += write_file('ffi_lapacke_{}.cj'.format(k), buckets[k],
                            'LAPACKE {} routines'.format(k))

    # public wrappers (canonical BLAS/LAPACK names)
    wtotal = 0
    wtotal += write_wrap_file('blas_binding.cj', cblas_funcs, 'CBLAS bindings')
    for k in ('s', 'd', 'c', 'z', 'aux'):
        wtotal += write_wrap_file('lapack_binding_{}.cj'.format(k), buckets[k],
                                  'LAPACK {} bindings'.format(k))

    # collision check across all public wrapper names
    dupes = {}
    for nm in all_wrapper_names:
        dupes[nm] = dupes.get(nm, 0) + 1
    collisions = sorted(k for k, v in dupes.items() if v > 1)

    print("cblas_: {}  util: {}  lapacke: {} (s={} d={} c={} z={} aux={})".format(
        len(cblas_funcs), len(util_funcs), len(lapacke),
        len(buckets['s']), len(buckets['d']), len(buckets['c']),
        len(buckets['z']), len(buckets['aux'])))
    print("TOTAL foreign decls:", total)
    print("TOTAL public wrappers:", wtotal)
    if collisions:
        print("WRAPPER NAME COLLISIONS ({}): {}".format(len(collisions), collisions[:20]))
    if unknown_types:
        print("UNKNOWN TYPES (mapped to fallback):")
        for t in sorted(unknown_types):
            print("   ", t)


if __name__ == '__main__':
    main()
