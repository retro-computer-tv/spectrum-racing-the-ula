"""Build every program here with sjasmplus (1.24.0 or later, on the PATH or named by the SJASMPLUS environment variable).

  python build.py   ->  run/: a tape of each program (.tap) and a type-in listing of the short ones (.bas.txt)

The sound of each tape (.wav, for a real Spectrum's EAR socket) is made from the .tap by tape2wav, from fuse-utils.
"""

import os
import shutil
import subprocess
import sys
import tempfile
from pathlib import Path

HERE = Path(__file__).resolve().parent
OUT = HERE / "run"
SJASMPLUS = os.environ.get("SJASMPLUS", "sjasmplus")

# output: (folder, source, defines, short enough to type in)
PROGRAMS = {
    "stripes.tap": ("stripes", "stripes.asm", {}, True),
    "floatbus.tap": ("probe", "floatbus.asm", {}, True),
    "band-16.tap": ("band", "band.asm", {"COLS": 16, "START": 228, "PAD": 0}, False),
    "band-17.tap": ("band", "band.asm", {"COLS": 17, "START": 228, "PAD": 0}, False),
}


def assemble(out: str, folder: str, src: str, defines: dict) -> None:
    with tempfile.TemporaryDirectory() as work:
        args = [SJASMPLUS, "--nologo", str(HERE / folder / src)] + [f"-D{k}={v}" for k, v in defines.items()]
        r = subprocess.run(args, cwd=work, capture_output=True, text=True)
        if r.returncode:
            sys.exit(f"{out}: sjasmplus failed\n{r.stdout}\n{r.stderr}")
        (tap,) = Path(work).glob("*.tap")
        shutil.copyfile(tap, OUT / out)


def blocks(tap: bytes) -> list[bytes]:
    """A .tap file's blocks, each without its length, flag and checksum."""
    out, i = [], 0
    while i < len(tap):
        n = tap[i] | tap[i + 1] << 8
        out.append(tap[i + 3 : i + 1 + n])
        i += 2 + n
    return out


def type_in(code: bytes, start: int) -> str:
    """A BASIC listing that POKEs the code in from DATA lines, eight bytes and their sum to a line, then runs it."""
    code = code + bytes(-len(code) % 8)  # the last line is filled out with 0s
    rows = [code[i : i + 8] for i in range(0, len(code), 8)]
    last = 100 + 10 * (len(rows) - 1)
    lines = [
        f"10 CLEAR {start - 1}: LET a={start}",
        f"20 FOR l=100 TO {last} STEP 10",
        "30 LET s=0: FOR i=1 TO 8: READ b: POKE a,b: LET a=a+1: LET s=s+b: NEXT i",
        '40 READ c: IF s<>c THEN PRINT "Check line ";l: STOP',
        "50 NEXT l",
        f"60 RANDOMIZE USR {start}",
    ]
    lines += [f"{100 + 10 * n} DATA {','.join(map(str, row))},{sum(row)}" for n, row in enumerate(rows)]
    return "\n".join(lines) + "\n"


def main() -> None:
    OUT.mkdir(exist_ok=True)
    for out, (folder, src, defines, short) in PROGRAMS.items():
        assemble(out, folder, src, defines)
        header, code = blocks((OUT / out).read_bytes())[-2:]
        start = header[13] | header[14] << 8
        print(f"run/{out}  {len(code)} bytes of code at {start}")
        if short:
            listing = OUT / f"{Path(out).stem}.bas.txt"
            listing.write_text(type_in(code, start), newline="\n")
            print(f"run/{listing.name}")


if __name__ == "__main__":
    main()
