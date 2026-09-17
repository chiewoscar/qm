#!/usr/bin/env python3
"""Reproduce the Lean build and record verification evidence."""

from __future__ import annotations

import argparse
import hashlib
import json
import re
import subprocess
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
VERIFY = ROOT / "verification"
MAIN = ROOT / "JSP000399.lean"
FORBIDDEN = {
    "sorry": re.compile(r"\bsorry\b"),
    "admit": re.compile(r"\badmit\b"),
    "custom axiom": re.compile(r"^\s*axiom\b", re.MULTILINE),
    "native_decide": re.compile(r"\bnative_decide\b"),
    "unsafe": re.compile(r"\bunsafe\b"),
    "implemented_by": re.compile(r"\bimplemented_by\b"),
}


def run(command: list[str], log_name: str) -> None:
    proc = subprocess.run(
        command,
        cwd=ROOT,
        text=True,
        stdout=subprocess.PIPE,
        stderr=subprocess.STDOUT,
        check=False,
    )
    (VERIFY / log_name).write_text(proc.stdout, encoding="utf-8")
    if proc.returncode != 0:
        raise SystemExit(f"command failed ({proc.returncode}): {' '.join(command)}")


def sha256(path: Path) -> str:
    h = hashlib.sha256()
    with path.open("rb") as f:
        for chunk in iter(lambda: f.read(1024 * 1024), b""):
            h.update(chunk)
    return h.hexdigest()


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--clean", action="store_true")
    args = parser.parse_args()

    VERIFY.mkdir(exist_ok=True)
    source = MAIN.read_text(encoding="utf-8")
    failures = [name for name, rx in FORBIDDEN.items() if rx.search(source)]
    if failures:
        raise SystemExit("forbidden constructs in JSP000399.lean: " + ", ".join(failures))

    run(["python3", "scripts/crosscheck.py"], "crosscheck.log")
    if args.clean:
        run(["lake", "clean"], "lake-clean.log")
    run(["lake", "build"], "lake-build.log")
    run(["lake", "env", "lean", "Audit.lean"], "axioms.log")

    files = [
        p for p in ROOT.rglob("*")
        if p.is_file()
        and ".lake" not in p.parts
        and ".git" not in p.parts
        and p.name != "SHA256SUMS"
        and not ("verification" in p.parts and p.suffix == ".log")
        and p.name != "result.json"
    ]
    records = {str(p.relative_to(ROOT)): sha256(p) for p in sorted(files)}
    (ROOT / "SHA256SUMS").write_text(
        "".join(f"{digest}  {name}\n" for name, digest in records.items()),
        encoding="utf-8",
    )
    result = {
        "status": "passed",
        "lean_toolchain": (ROOT / "lean-toolchain").read_text().strip(),
        "external_packages": [],
        "source_sha256": sha256(MAIN),
        "audited_declarations": [
            "JSP000399.pairSums_perm_parametric",
            "JSP000399.leftFamily_nodup",
            "JSP000399.rightFamily_nodup",
            "JSP000399.leftFamily_not_same_elements",
            "JSP000399.parametric_counterexample",
            "JSP000399.concrete_counterexample",
            "JSP000399.jsp_000399",
        ],
    }
    (VERIFY / "result.json").write_text(json.dumps(result, indent=2) + "\n")
    print("verification passed")


if __name__ == "__main__":
    main()
