# Upstream baselines

One directory per source plugin this plugin forks from.
Each holds a `SOURCE` file (git url, the commit last compared, the date) and a copy of every upstream file that was forked, at the version last reviewed.
The tree is the manifest: a file under a source directory is a tracked file.

`scripts/upstream-check.sh` clones each source at depth 1 and compares; `/flow:upstream` reads the diffs, ports what is worth porting and accepts the new baseline.
