# Example Workspaces

This folder contains three complete, working workspaces that demonstrate the ICM (Interpretable Context Methodology) approach in practice across different domains. They are reference material for humans — look at them when you want to understand what a finished workspace actually looks like before building your own.

The AI skill does not load these automatically. They exist for you to read.

---

## The three examples

| Workspace | Domain | Stages |
|-----------|--------|--------|
| `script-to-animation/` | Content production — turning a topic into an animated video | Research → Script → Production |
| `research-synthesis/` | Academic/professional research — turning a question into a literature review | Collect → Extract → Synthesise → Report |
| `client-deliverable/` | Consulting — turning a client brief into a finished deliverable | Intake → Analysis → Draft |

Each example covers a meaningfully different kind of work, with different stage counts and different reasons for where the stage boundaries sit. That variation is intentional — there is no single correct pipeline shape.

---

## How a workspace is structured

Every example follows the same five-layer structure. Here is what each part does and why it exists.

### `CLAUDE.md` — the routing map (Layer 0)

The first thing Claude reads when it enters a workspace. It contains:

- **Identity** — who is being helped and in what role. This shapes vocabulary, depth, and assumptions throughout the session.
- **Folder structure** — a brief map of what each directory is for.
- **Routing table** — for each type of task, which stage folder to go to and which file to read. This is the mechanism that keeps Claude from loading irrelevant context.
- **Naming conventions** — how output files should be named, so files can be identified without opening them.
- **Rules** — a small set of structural constraints (where to write output, when to update PROGRESS.md, what not to touch during a run).

CLAUDE.md is kept deliberately short — under 50 lines. It is a routing file, not a project description. Project detail lives in CONTEXT.md.

### `CONTEXT.md` — the project description (Layer 1)

One level below the routing map. Describes what the workspace is actually for: the problem being solved, what good output looks like, and what to avoid. This is where the project's character lives — not in CLAUDE.md.

CONTEXT.md changes when the project changes. It has a "Last updated" marker for that reason.

### `PROGRESS.md` — session tracking

Records the current state of the workspace across sessions. Because Claude doesn't remember between sessions, PROGRESS.md is what lets work continue from where it left off. It tracks: current status, what happened in the last session (completed / in progress / blocked / next), decisions made, and open questions.

PROGRESS.md is updated during sessions at natural transition points — when a task completes, when a stage changes, when a blocker appears — not just at the end of a session. If a session ends unexpectedly, the session-start prompt reconciles PROGRESS.md against the actual state of the output directories.

### `_config/` — shared reference material (Layer 3)

Files in `_config/` apply across the whole workspace and don't change between pipeline runs. Common examples: a voice and tone guide, a house style document, a client profile template. Claude reads these as constraints — rules it should follow — not as material to transform.

The `_config/` directory solves a maintenance problem: if a voice guide applies to three stages, it lives in one place rather than being duplicated into each stage's reference folder.

### `stages/` — the pipeline

Each stage is a numbered folder: `01_research/`, `02_script/`, `03_production/`. The number determines the order. Each stage folder contains:

**`CONTEXT.md` — the stage contract (Layer 2)**

The most important file in the system. It defines exactly what the stage does and what it touches, in three sections:

```
## Inputs
  Layer 4 (working): the output file from the previous stage
  Layer 3 (reference): any stable reference files this stage needs

## Process
  Instructions for Claude — what to do, how to use the inputs,
  what constraints apply, what the human will check.

## Outputs
  The specific file(s) this stage produces, and where they go.
```

This contract is what allows a single agent to orchestrate the whole pipeline without a framework. The Inputs section scopes what context gets loaded (so Claude isn't reading irrelevant files). The Outputs section defines exactly what gets handed to the next stage.

**`references/` — stage-specific reference material (Layer 3)**

Reference files that only apply to this stage. For example, `04_report/references/report-structure.md` in the research-synthesis example defines the required section structure for the final document — it's only relevant at the report stage, so it lives there rather than in `_config/`.

**`output/` — per-run working artifacts (Layer 4)**

Where the stage writes its output. These files change every run — each pipeline run produces a new set of output files here. The previous stage's `output/` is what the next stage reads as its Layer 4 input.

### `setup/` — workspace configuration records

Contains three files generated at creation time. These are records for the human, not instructions for Claude.

- **`questionnaire-answers.md`** — the answered interview from when the workspace was built, including who it's for, the Claude identity used, the stage rationale, and the reference material decisions. Explains *why* the workspace is structured the way it is.
- **`session-prompts.md`** — copy-paste prompts for session start (which reconciles PROGRESS.md against actual file system state), session end, and mid-session before stepping away.
- **`skill-version.md`** — records the skill build date and feature flags active at generation time. Used by Review mode to surface improvements added after this workspace was created.

### `session-history/` — per-session records

One markdown file per session, named `YYYY-MM-DD.md`. Each file has YAML frontmatter with structured fields and a human-readable body.

```yaml
---
date: 2026-05-07
stages_active: [02_script]
completed: true
corrections:
  - stage: 02_script
    type: length
    description: "Script ran 138 seconds — trimmed opening scene"
next: "Run 03_production"
---
```

The `corrections` field is machine-readable and is what Mode 4 (Check) uses for AP-12 pattern detection: if the same `(stage, type)` correction appears across 3 or more session files, it flags the stage contract or reference file as needing a source-level fix.

PROGRESS.md holds the current active state only (status, active stage, decisions, open questions). All historical detail lives here.

---

## Layer 3 vs Layer 4 — the factory and the product

This distinction runs through everything and is worth understanding clearly.

**Layer 3** is the factory configuration: stable files that define the rules, style, structure, and constraints that apply every time the pipeline runs. A voice guide. A report structure template. A client profile. Claude reads Layer 3 material as constraints to follow — these files shape how it works.

**Layer 4** is the product: the output files that a pipeline run produces and consumes. A research document. A script draft. An animation spec. These change every run — they are what the pipeline is making.

The reason they're kept in separate locations is that Claude needs to treat them differently. "Here is the voice guide for this workspace" requires internalising rules. "Here is the research output from stage 01" requires transforming input into something new. When they're mixed in the same folder, Claude has to figure out which is which on its own, and gets it wrong.

---

## The stage chain

The output of stage N becomes the Layer 4 input of stage N+1. This is the pipeline.

In the script-to-animation example:
- Stage 01 produces `topic-name_research.md` → `output/`
- Stage 02 reads `../01_research/output/topic-name_research.md` as its Layer 4 input
- Stage 02 produces `topic-name_script.md` → `output/`
- Stage 03 reads `../02_script/output/topic-name_script.md` as its Layer 4 input

At each stage boundary, the human reviews what was produced before the next stage runs. This review gate is why the boundaries exist — they are decision points, not just sequencing.

---

## How to use these examples

**As a reference before building your own workspace:** Read the CLAUDE.md and the stage CONTEXT.md files of whichever example is closest to your domain. The questionnaire-answers.md in each `setup/` folder shows the reasoning behind the structural choices.

**As a starting point:** Copy the closest example, update the Identity in CLAUDE.md, rewrite the CONTEXT.md and stage contracts to match your actual workflow, and update the reference files in `_config/` and `stages/*/references/`. The folder structure can stay the same if the stage count fits.

**To understand a specific concept:** The examples are designed to demonstrate particular patterns:
- `script-to-animation/` — standard 3-stage pipeline; how `_config/` and per-stage `references/` both appear in Layer 3 Inputs
- `research-synthesis/` — 4-stage pipeline with a clear rationale for each split; stage contracts where Layer 3 reference material doesn't apply until later stages
- `client-deliverable/` — 3-stage pipeline where the `_config/client-profile.md` pattern shows a Layer 3 file that gets updated between runs (not during them), and a stage contract that explicitly prevents new material from entering at the draft stage

---

## What makes a stage boundary real

Looking at these examples, a genuine stage boundary has two properties:

1. **Different mental mode.** The work you do at stage N is genuinely different from the work at stage N+1. Collecting sources is different from extracting themes. Extracting themes is different from constructing an argument. These differences mean different instructions, different reference material, and a human with a different judgment to apply.

2. **A human review gate.** The human should read the output of stage N and make a decision before stage N+1 runs. If you'd never want to stop and check between two steps, they probably belong in the same stage.

Over-splitting — creating stages that share the same mental mode — is the most common structural mistake. More stages means more files to maintain, more stage boundaries for Claude to navigate, and more opportunities for the chain to break.
