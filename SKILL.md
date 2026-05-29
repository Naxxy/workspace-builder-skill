# workspace-builder

A Claude Code skill for creating, reviewing, updating, and auditing ICM/MWP-compliant workspaces. Grounded in the Interpretable Context Methodology (Van Clief & McDermott): folder structure is agent architecture. A properly layered workspace gives a single orchestrating agent the context it needs at each stage — without a framework, without code, without server infrastructure.

**Skill build:** 2026-05-29
**After any significant change:** update the build date above and add an entry to `_design/CHANGELOG.md` (format: date → change ID → what changed → gap addressed).

---

## What this skill does

| Mode | When to use | What it does |
|------|-------------|-------------|
| **Setup** | No workspace exists | Interviews the user, generates a complete workspace |
| **Review** | "Is this well structured?" | Layer-by-layer assessment with prioritised fixes |
| **Update** | "Change X" or "Add a stage" | Minimum-viable-change to an existing workspace |
| **Check** | "Audit this" | Full anti-pattern and integrity check |
| **Trace** | "Where did this go wrong?" | Walks backwards through the pipeline to find the origin of a specific output problem |

Modes chain: Setup auto-runs Check. Review hands off to Update. Check hands off to Update. Trace hands off to Update.

---

## Skill files

```
core/engineering-standards.md   Engineering standards applied in every mode
core/questionnaire.md           Mode 1: interview and generation workflow
core/review-checklist.md        Mode 2: checklist, report format, and procedure
core/anti-patterns.md           Modes 2 & 4: anti-pattern catalogue and audit procedure
core/update-protocol.md         Mode 3: change procedure and update type map
core/trace-protocol.md          Mode 5: pipeline trace procedure
core/templates/                 Generation templates (Mode 1 primary; REFERENCES.md.template also used in Mode 3)
core/examples/                  Reference workspace (consult on demand)
core/tools/                     Shell scripts and tooling guides (bash-style.md, tool-decision.md)
```

---

## The 5-layer ICM hierarchy

| Layer | File | Token budget | Question it answers |
|-------|------|-------------|---------------------|
| 0 | `CLAUDE.md` (root) | ~800 tok | "Where am I?" |
| 1 | `CONTEXT.md` (root) | ~300 tok | "Where do I go?" |
| 2 | `stages/NN_name/CONTEXT.md` | 200–500 tok | "What do I do?" |
| 3 | `stages/NN_name/references/` + `_config/` | 500–2k tok | "What rules apply?" |
| 4 | `stages/NN_name/output/` | varies | "What am I working with?" |

**Layer 3 is the factory. Layer 4 is the product.** Layer 3 holds stable reference material unchanged across every run. Layer 4 holds per-run working artifacts. Mixing them degrades output. Enforce this separation in every mode.

---

## Design principles

1. **One stage, one job.** A stage that fetches data does not also filter it.
2. **Plain text as interface.** Markdown only. No databases, no proprietary formats.
3. **Layered context loading.** Each stage loads only the context it needs.
4. **Every output is an edit surface.** The human must be able to open, read, and edit any stage output before the next stage runs.
5. **Configure the factory, not the product.** Layer 3 is set up once. Each run uses the same factory to produce a new product.
6. **Routing table is mandatory.** Without it, Claude guesses which context to load.
7. **Stage contracts are the core.** Inputs / Process / Outputs in every stage `CONTEXT.md` is what lets one agent orchestrate the pipeline without a framework.
8. **Minimal first.** Build 2–3 stages. Add more based on real use, not anticipation.
9. **CLAUDE.md fits on one screen.** Over 50 lines means project detail has leaked into the routing file.

---

## Mode detection

**If `CLAUDE.md` does not exist at the workspace root:** → Mode 1 (Setup).

**If `CLAUDE.md` exists but no `stages/` directory exists:** this is a 3-file workspace (Foundation-course structure). Mention the upgrade option proactively. Add it as option 5 in the ambiguous-case question below.

**If `CLAUDE.md` exists:**

| User says | Mode |
|-----------|------|
| "Build", "create", "set up a workspace" | Mode 1 — Setup (scratch path) |
| "Duplicate", "adapt", "base this on", "something like [existing workspace]" | Mode 1 — Setup (duplication path) |
| "Review", "assess", "is this well structured?" | Mode 2 — Review |
| "Update", "add a stage", "change X", "fix" | Mode 3 — Update |
| "Check", "audit", "find problems" | Mode 4 — Check |
| "Trace", "where did this go wrong", "find the source of", "why does the output" | Mode 5 — Trace |
| "Upgrade", "add stages", "convert to ICM" | Mode 3 — Update (upgrade procedure) |

**If ambiguous**, ask:
> "What do you want to do?
> 1. Review — assess whether it's well structured
> 2. Update — apply a specific change
> 3. Check — full anti-pattern audit
> 4. Trace — find where a specific output problem originated in the pipeline
> 5. Build — start a new workspace from scratch
> 6. Duplicate — adapt an existing workspace for a new domain
> 7. Upgrade — convert a 3-file workspace to full staged ICM structure" *(include only if no `stages/` directory exists)*

---

## Modes

**All modes:** Read `core/engineering-standards.md` before proceeding.

**Mode 1 — Setup:** Read `core/questionnaire.md`.

**Mode 2 — Review:** Read `core/review-checklist.md` and `core/anti-patterns.md`.

**Mode 3 — Update:** Read `core/update-protocol.md`.

**Mode 4 — Check:** Read `core/anti-patterns.md`.

**Mode 5 — Trace:** Read `core/trace-protocol.md`.
