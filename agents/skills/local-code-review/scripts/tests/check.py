#!/usr/bin/env python3
"""Check the bundled review helper with a current, focused review plan."""

import argparse
import json
import os
from pathlib import Path
import subprocess
import sys
import tempfile


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("plan", type=Path)
    parser.add_argument("--worktree", type=Path, default=Path.cwd())
    args = parser.parse_args()
    plan_path = args.plan.expanduser().resolve()
    plan = json.loads(plan_path.read_text())
    chunks = plan["chunks"]
    if len(chunks) < 2 or any(not chunk.get("focus") for chunk in chunks):
        parser.error("Use at least two chunks, each with a focus anchor")
    if (
        len(chunks[0]["files"]) < 2
        or chunks[0]["focus"]["path"] != chunks[0]["files"][0]
    ):
        parser.error("First chunk needs two files and focus in its first file")

    env = {**os.environ, "GIT_OPTIONAL_LOCKS": "0"}

    root_result = subprocess.run(
        ["git", "-c", "core.fsmonitor=false", "-C",
         str(args.worktree.expanduser()), "rev-parse", "--show-toplevel"],
        env=env, text=True, capture_output=True, check=True,
    )

    root = Path(root_result.stdout.strip()).resolve()
    tests = Path(__file__).resolve().parent
    state = Path(tempfile.mkdtemp(prefix="nvim-review-checks-"))
    env.update({
        "NVIM_REVIEW_ROOT": str(root),
        "NVIM_REVIEW_PLAN": str(plan_path),
        "NVIM_REVIEW_HELPER": str(tests.parent / "lua" / "review.lua"),
        "XDG_CACHE_HOME": str(state / "cache"),
        "XDG_STATE_HOME": str(state / "state"),
    })

    print(f"Temporary check state and logs: {state}", flush=True)

    for name, phase in [
        ("review", "navigation"),
        ("file_marks", "seed"),
        ("file_marks", "resume"),
    ]:
        env.update({
            "NVIM_REVIEW_STATE_DIR": str(
                state / ("navigation" if name == "review" else "marks")
            ),
            "NVIM_REVIEW_TEST_PHASE": phase,
            "NVIM_REVIEW_TEST_SCRIPT": str(tests / f"{name}.lua"),
        })

        result = subprocess.run(
            ["nvim", "--headless", "-n", "-i", "NONE", "-c",
             "lua dofile(vim.env.NVIM_REVIEW_TEST_SCRIPT)"],
            env=env, cwd=root, text=True, stdout=subprocess.PIPE,
            stderr=subprocess.STDOUT, timeout=45,
        )

        (state / f"{phase}.log").write_text(result.stdout)

        print(f"{phase}: {result.stdout.strip()}", flush=True)

        if result.returncode or "Error detected" in result.stdout:
            sys.exit(result.returncode or 1)

    print("All review checks passed.")


if __name__ == "__main__":
    main()
