"""Restore the Neovim sources pinned by dots, then compile their parser revisions."""

import argparse
from concurrent.futures import ThreadPoolExecutor
import json
import os
from pathlib import Path
import subprocess
import sys
import tempfile


def run(args, **kwargs):
    return subprocess.run(args, check=True, text=True, **kwargs)


def ensure_remote_head(target, revision, branch):
    remote_head = subprocess.run(
        ["git", "-C", str(target), "symbolic-ref", "-q", "refs/remotes/origin/HEAD"],
        capture_output=True,
    )
    if remote_head.returncode:
        run(["git", "-C", str(target), "update-ref", f"refs/remotes/origin/{branch}", revision])
        run(["git", "-C", str(target), "symbolic-ref", "refs/remotes/origin/HEAD", f"refs/remotes/origin/{branch}"])


def restore_plugin(item):
    name, spec = item
    target = plugin_root / name
    revision = locks[name]["commit"]
    if not target.exists():
        target.mkdir(parents=True)
        run(["git", "init", "-q", str(target)])
        run(["git", "-C", str(target), "remote", "add", "origin", spec["url"]])
    if not (target / ".git").exists():
        raise RuntimeError(f"{target} is not a Git checkout; move it aside before restoring")
    head = subprocess.run(
        ["git", "-C", str(target), "rev-parse", "HEAD"], capture_output=True, text=True
    ).stdout.strip()
    dirty = run(
        ["git", "-C", str(target), "status", "--porcelain", "--untracked-files=no"],
        capture_output=True,
    ).stdout
    if dirty:
        raise RuntimeError(f"{target} has local changes; save them before restoring")
    branch = locks[name]["branch"]
    if head == revision:
        ensure_remote_head(target, revision, branch)
        return
    exists = subprocess.run(
        ["git", "-C", str(target), "cat-file", "-e", f"{revision}^{{commit}}"],
        capture_output=True,
    ).returncode == 0
    if not exists:
        run(["git", "-C", str(target), "fetch", "--quiet", "--depth=1", "origin", revision])
    run(["git", "-C", str(target), "-c", "advice.detachedHead=false", "checkout", "--quiet", "--detach", revision])
    ensure_remote_head(target, revision, branch)
    print(f"Restored {name} at {revision[:12]}", flush=True)


parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument("--source", type=Path, required=True)
parser.add_argument("--nvim", required=True)
parser.add_argument("--update", action="store_true")
args = parser.parse_args()
app = os.environ.get("NVIM_APPNAME", "nvim")
data = Path(os.environ.get("XDG_DATA_HOME", Path.home() / ".local/share")) / app
plugin_root = data / "lazy"
source = args.source.resolve()
lockfile = source / "config/lazy-lock.json"
if args.update:
    checkout = Path(os.environ.get("NH_FLAKE", Path.home() / "dots"))
    lockfile = checkout / "home/modules/neovim/config/lazy-lock.json"
    if not lockfile.is_file() or not os.access(lockfile, os.W_OK):
        sys.exit(f"Cannot update {lockfile}; set NH_FLAKE to your writable dots checkout")
locks = json.loads(lockfile.read_text())
plugins = json.loads((source / "plugins.json").read_text())
if not plugins.keys() <= locks.keys():
    sys.exit("A plugin is missing its lockfile entry")
with ThreadPoolExecutor(max_workers=4) as pool:
    list(pool.map(restore_plugin, plugins.items()))
environment = dict(os.environ, DOTS_NVIM_PARSERS=str(source / "parsers.json"))
if args.update:
    with tempfile.TemporaryDirectory(prefix=".nvim-update-", dir=lockfile.parent) as temporary:
        candidate = Path(temporary) / "lazy-lock.json"
        candidate.write_text(json.dumps(locks))
        environment["DOTS_NVIM_LOCKFILE"] = str(candidate)
        run([args.nvim, "--headless", "+lua vim.api.nvim_create_autocmd('VimEnter', {once=true, callback=function() vim.schedule(function() dofile(vim.env.DOTS_NVIM_UPDATE) end) end})"], env=dict(environment, DOTS_NVIM_UPDATE=str(source / "update.lua")))
        updated = json.loads(candidate.read_text())
        if not plugins.keys() <= updated.keys():
            sys.exit("Updated lockfile is incomplete; original pins were preserved")
        # Replace the real pins only after Lazy has written valid JSON successfully.
        os.replace(candidate, lockfile)
    environment["DOTS_NVIM_LOCKFILE"] = str(lockfile)
for script in ["restore.lua", "verify.lua"]:
    run(
        [args.nvim, "--headless", "+lua vim.api.nvim_create_autocmd('VimEnter', {once=true, callback=function() vim.schedule(function() dofile(vim.env.DOTS_NVIM_RESTORE) end) end})"],
        env=dict(environment, DOTS_NVIM_RESTORE=str(source / script)),
    )
print("Neovim restore complete. Plugin commits and parser revisions come from dots.")
if args.update:
    print("Review the lockfile change, then rebuild to activate the new pins.")
