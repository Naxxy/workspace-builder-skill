# When to Write a Tool

Decision guide for whether a task warrants a new bash script or should remain as Claude guidance.

---

## Write a script when

- The check is **mechanical**: it passes or fails without interpreting content.
- It runs **repeatedly** — on every workspace, every audit pass, in CI.
- The output is a **structured table or triage summary** humans use to prioritise.
- The operation is **idempotent**: safe to re-run on a workspace that already passes.
- The alternative is asking Claude to hold 10+ files in context and mentally compare them.

Examples from the existing toolset: file existence, line count thresholds, routing path resolution, output filename cross-matching between adjacent stage contracts.

---

## Keep it as Claude guidance when

- The check requires **reading and interpreting content**, not just structure.
- Pass/fail depends on **judgment**: is this description accurate? Is this too vague?
- The rule has **contextual exceptions** that need to be weighed.
- It applies only **once** — setup, one-off migration, upgrade.

Examples: whether a Process section is substantive, whether Layer 3/4 content is mixed, whether the identity statement names the right persona.

---

## Scope a script to one job

If a script exceeds ~150 lines of logic (excluding output formatting), it probably does too much.
Split it: one focused script, one caller. The `audit-all.sh → preflight.sh` relationship is the model.
Scripts call scripts. Don't merge them.

---

## Register new scripts in SKILL.md

Every new script added to `skill/tools/` must appear in the Skill files table in `SKILL.md`
with a description of what it does and when to use it.
