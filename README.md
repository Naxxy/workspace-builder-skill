# workspace-builder

A Claude Code skill for creating, reviewing, updating, and auditing ICM-compliant workspaces.

**Skill build:** 2026-05-21

---

## What this is

workspace-builder is a skill file for Claude Code. It implements the **Interpretable Context Methodology (ICM)** — a way of structuring a project folder so that a single Claude instance can orchestrate a multi-stage content or knowledge pipeline without a framework, without code, and without server infrastructure.

The core idea: **folder structure is agent architecture.** A properly layered workspace gives Claude exactly the context it needs at each stage, no more. Each stage has a contract (Inputs / Process / Outputs). The stage chain connects them. Claude reads only what it needs and produces exactly what the next stage expects.

This skill builds and maintains those workspaces.

---

## Why it exists

Working with Claude across a multi-stage pipeline without a structured workspace means:

- Claude re-reads everything at every session start
- Context bleeds between stages (research assumptions appearing in final output)
- There is no record of why the workspace was structured a particular way
- Recurring output problems are corrected by hand each run rather than fixed at the source

A well-structured ICM workspace addresses all of these. But building one correctly — with the right layer separation, stage contracts, routing table, reference material, and session persistence — requires knowing the methodology well. This skill encodes that knowledge and applies it consistently.

---

## The 5-layer ICM hierarchy

Every workspace this skill produces follows the same layered structure:

| Layer | File | Token budget | Question it answers |
|-------|------|-------------|---------------------|
| 0 | `CLAUDE.md` (root) | ~800 tok | "Where am I?" |
| 1 | `CONTEXT.md` (root) | ~300 tok | "Where do I go?" |
| 2 | `stages/NN_name/CONTEXT.md` | 200–500 tok | "What do I do?" |
| 3 | `stages/NN_name/references/` + `_config/` | 500–2k tok | "What rules apply?" |
| 4 | `stages/NN_name/output/` | varies | "What am I working with?" |

**Layer 3 is the factory. Layer 4 is the product.** Layer 3 holds stable reference material (voice guides, domain knowledge, structural conventions) unchanged across every run. Layer 4 holds per-run working artifacts. Mixing them is the most common structural failure mode — the skill detects and fixes it.

---

## Modes

The skill has five modes, selected automatically based on what you say:

| Mode | When to use | What it does |
|------|-------------|--------------|
| **Setup** | No workspace exists | Interviews you, generates a complete workspace |
| **Review** | "Is this well structured?" | Layer-by-layer assessment with prioritised fixes |
| **Update** | "Change X" or "Add a stage" | Minimum-viable-change to an existing workspace |
| **Check** | "Audit this" | Full anti-pattern and integrity check |
| **Trace** | "Where did this go wrong?" | Walks backwards through the pipeline to find the origin of a specific output problem |

Modes chain: Setup auto-runs Check. Review hands off to Update. Check hands off to Update. Trace hands off to Update.

---

## How to use

### Installation

Clone or copy this repository. In your workspace's `CLAUDE.md`, add an entry to the routing table pointing to `SKILL.md`:

```markdown
| Build or review a workspace | skill/workspace-builder/ | SKILL.md |
```

Or invoke it directly in a session by asking Claude to read `SKILL.md`.

### Triggering modes

Speak naturally — the skill detects your intent:

```
"Build me a workspace for my research synthesis workflow"     → Setup
"Is this workspace well structured?"                          → Review
"Add a stage between research and writing"                    → Update
"Audit this workspace for problems"                           → Check
"The output from stage 3 keeps coming out too generic"        → Trace
```

If ambiguous, the skill asks.

### Setup interview

Mode 1 runs a structured interview across four groups:
- **Group A** — Identity: who you are, what Claude should be, what the workspace is for
- **Group B** — Workflow mapping: your stages, their inputs and outputs, natural review gates
- **Group C** — Reference material: voice/style, structural conventions, domain knowledge, skills and MCPs
- **Group D** — Rules and naming conventions

It confirms a summary before generating anything. The output is a complete workspace including all stage contracts, `_config/` reference files drafted from your answers, `PROGRESS.md`, and session start/end prompts.

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

## Skill file structure

```
SKILL.md                             Entry point — mode detection and skill index

skill/engineering-standards.md       Universal behavioral principles (all modes)
skill/questionnaire.md               Mode 1: interview and generation workflow
skill/review-checklist.md            Mode 2: layer-by-layer assessment checklist
skill/anti-patterns.md               Modes 2 & 4: anti-pattern catalogue and audit procedure
skill/update-protocol.md             Mode 3: change procedure and update type map
skill/trace-protocol.md              Mode 5: pipeline trace procedure

skill/templates/                     Generation templates
  CLAUDE.md.template
  CONTEXT.md.template
  stage-CONTEXT.md.template
  PROGRESS.md.template
  REFERENCES.md.template
  session-history.md.template
  session-prompts.md.template

skill/tools/                         Shell scripts and tooling guides
  preflight.sh                       Mechanical workspace checks (PASS/FAIL/NOTE output)
  audit-all.sh                       Batch audit across multiple workspaces
  diff-stage.sh                      Compare stage output before and after a contract change
  reconcile-progress.sh              Reconcile file system state against PROGRESS.md
  bash-style.md                      Style guide for scripts in this skill
  tool-decision.md                   When to write a script vs. Claude guidance vs. external tool

skill/examples/                      Reference workspaces (consult on demand)
  script-to-animation/
  research-synthesis/
  client-deliverable/
```

---

## The mechanical audit tool

`skill/tools/preflight.sh` runs all checks that can be determined without reading and interpreting content — file existence, line counts, routing table validity, stage contract completeness, cross-stage filename matching, output contract satisfaction, and session state consistency.

```bash
bash skill/tools/preflight.sh [workspace-path]
```

Output uses `PASS / FAIL / NOTE` prefixes with check IDs that map directly to `review-checklist.md`. The script ends with a `Deferred to Claude` section listing the checks that require judgment — so Claude only reads what the script cannot handle.

For multiple workspaces:

```bash
bash skill/tools/audit-all.sh [parent-directory]
```

---

## Engineering standards

All modes apply four behavioral principles drawn from Karpathy's CLAUDE.md template, adapted for ICM/system context:

1. **Think Before Acting** — state assumptions, surface ambiguity, ask before guessing
2. **Simplicity First** — minimum structure that achieves the goal, nothing speculative
3. **Surgical Changes** — touch only what the request requires, flag but don't fix unrelated issues
4. **Goal-Driven Execution** — state success criteria upfront, verify before declaring done

These live in `skill/engineering-standards.md` and are loaded before every mode.

---

## Methodology

This skill is grounded in the **Interpretable Context Methodology** developed by Van Clief & McDermott (MWP). The methodology's central claim: for a single-agent pipeline to produce consistent, high-quality output, the agent needs the right context at each stage — not all context everywhere.

The workspace structure this skill produces is the methodology's implementation. The stage contracts (Inputs / Process / Outputs) are the interface. The routing table in `CLAUDE.md` is the dispatch layer. The separation of Layer 3 (stable factory configuration) from Layer 4 (per-run artifacts) is what makes the pipeline reproducible.
