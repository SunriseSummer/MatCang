#!/usr/bin/env python3
"""Run every example under examples/ as an end-to-end test.

Each example is a standalone cjpm project whose `main` returns 0 and prints
`OK` only when its numerical claims hold. This harness builds and runs each one,
and reports a failure if the process exits non-zero or does not print `OK`.

Usage:
    python3 .devtools/run_examples.py            # run all examples
    python3 .devtools/run_examples.py dft_spectrum rlc_circuit   # a subset

Requires the Cangjie toolchain (cjc/cjpm) on PATH. Exit code is the number of
failed examples (0 = all passed).
"""
import os
import subprocess
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
EXAMPLES = os.path.join(ROOT, "examples")


def discover(selection):
    names = []
    for entry in sorted(os.listdir(EXAMPLES)):
        d = os.path.join(EXAMPLES, entry)
        if os.path.isfile(os.path.join(d, "cjpm.toml")):
            if not selection or entry in selection:
                names.append(entry)
    return names


def run_one(name):
    d = os.path.join(EXAMPLES, name)
    try:
        proc = subprocess.run(
            ["cjpm", "run"], cwd=d, capture_output=True, text=True, timeout=600)
    except FileNotFoundError:
        print("  cjpm not found on PATH - source the Cangjie envsetup first", file=sys.stderr)
        sys.exit(2)
    except subprocess.TimeoutExpired:
        return (name, False, "timeout")
    out = proc.stdout
    ok = proc.returncode == 0 and "OK" in out
    # last non-empty content line, for a compact summary
    tail = ""
    for line in reversed(out.splitlines()):
        if line.strip():
            tail = line.strip()
            break
    reason = "" if ok else "exit={} tail={!r}".format(proc.returncode, tail)
    return (name, ok, reason)


def main():
    selection = set(sys.argv[1:])
    names = discover(selection)
    if not names:
        print("no examples found")
        return 1
    print("Running {} example(s)...".format(len(names)))
    failures = []
    for name in names:
        name, ok, reason = run_one(name)
        status = "OK  " if ok else "FAIL"
        print("  [{}] {}{}".format(status, name, "" if ok else "   " + reason))
        if not ok:
            failures.append(name)
    print("-" * 60)
    if failures:
        print("{} of {} FAILED: {}".format(len(failures), len(names), ", ".join(failures)))
    else:
        print("all {} examples passed".format(len(names)))
    return len(failures)


if __name__ == "__main__":
    sys.exit(main())
