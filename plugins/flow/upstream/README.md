# Upstream baselines

One directory per source this plugin forks from.
Each holds a `SOURCE` file (git url, the commit last compared, the date) and a copy of every upstream file that was forked, at the version last reviewed.
The tree is the manifest: a file under a source directory is a tracked file.

The verbatim skills under `references/verbatim/` are byte-identical to their files here; `scripts/upstream-check.sh` names them in `verbatim_forks`, and `tests/references.test.sh` fails when one drifts.

`scripts/upstream-check.sh` clones each source at depth 1, compares it with this baseline, and compares each verbatim copy with its baseline file.
With `--accept` it copies upstream into this baseline and the baseline into `references/verbatim/`, then records the commit.
The judgement step, reading the diffs and porting into the recipes and references, is the `/upstream` project skill of this checkout (`.claude/skills/upstream/SKILL.md`), not a plugin skill.
