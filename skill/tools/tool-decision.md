# When to Write a Tool

Decision guide for whether a task warrants a new bash script, should stay as inline shell,
should remain as Claude guidance, or has outgrown what a script can provide.

---

## Core principle

**Deterministic work belongs in deterministic tooling. Intelligent work belongs to AI.**

Executable scripts are procedural and produce the same output for the same input every time.
AI reasoning is statistical and should be reserved for judgment, fuzzy logic, and generative tasks.
Where deterministic tooling can do the job — or pre-process the job — prefer it.
Claude's most reliable role is a thin orchestrator: deciding which tool to call and how, not
performing the work itself.

---

## Inline shell → script

Inline shell calls are fine for simple, one-off commands. Promote to a saved script when:

- The call is **multi-line** — too long to read and verify inline
- The call will run **again** — repeated commands should be codified once and reused
- The operation is **risky or irreversible** — a script forces you to write, read, and review
  the exact sequence before running it, which is its own audit trail

---

## Write a script when

- **Repeated file processing** using standard tools (`grep`, `find`, `jq`, `ffmpeg`, `tree`):
  wrap the invocation once, call it cleanly thereafter
- **Command abstraction**: 30 lines of flags and pipes become one call with named options
- **Context compression**: outsource mechanical work so Claude receives only essential output,
  not raw files — this reduces token cost and improves reasoning quality
- **Risky or destructive operations**: script the full workflow even if it only runs once;
  split it across multiple scripts so consequences can be confirmed before irreversible
  steps run (e.g. a "flag candidates" script reviewed before a "delete flagged" script)
- **Idempotent checks**: mechanical pass/fail checks safe to re-run on a correct workspace

---

## Keep it as Claude guidance when

- The work requires **reading and interpreting content**, not just processing structure
- Pass/fail depends on **judgment**: is this accurate? is this too vague? which is better?
- The task is a **simple one-off with no meaningful risk** — inline shell or Claude reasoning is
  sufficient; there is no value in a saved file
- The logic involves **fuzzy or generative decisions** — AI reasoning wins when the output is
  inherently variable or context-dependent

Hybrid approaches are valid and often preferable: scripts pre-process or distil data, Claude
reasons over the result. The script handles the deterministic layer; Claude handles the rest.

---

## When a script has outgrown itself

If a script requires handling hundreds of edge cases, carries a significant maintenance burden,
or the correctness guarantee of a bash script is no longer sufficient — it has outgrown this
skill's tooling layer. At that point it becomes a candidate for a compiled external tool
(a tested Go binary, a packaged CLI, etc.) owned and maintained outside this workspace.

**This skill's responsibility is to flag when that threshold is reached — not to build the tool.**

When flagging: describe what the tool should do, what guarantees it needs to provide, and why
a script is no longer adequate. Then note that until the tool exists, scripts and heavier Claude
reasoning can serve as a fallback — the absence of the compiled tool should not block the
workspace.

---

## Scope a script to one job

If a script exceeds ~150 lines of logic (excluding output formatting), it probably does too much.
Split it: one focused script, one caller. The `audit-all.sh → preflight.sh` relationship is
the model. Scripts call scripts. Don't merge them.

---

## Register new scripts in SKILL.md

Every new script added to `skill/tools/` must appear in the Skill files table in `SKILL.md`
with a description of what it does and when to use it.
