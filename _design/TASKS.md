# TASKS: workspace-builder skill

## What this skill does

A Claude Code skill with four operating modes, all grounded in the Interpretable Context Methodology (ICM/MWP) by Van Clief & McDermott. The modes are:

1. **Setup** — Create a new workspace from scratch following the ICM 5-layer architecture
2. **Review** — Read an existing workspace and assess whether CLAUDE.md, CONTEXT.md, and stage files can/should be improved
3. **Update** — Apply incremental changes to an existing workspace that stay consistent with the overall methodology
4. **Check** — Run a structured audit against known anti-patterns and edge cases, with a prioritised fix list

All four modes share the same knowledge base (ICM hierarchy, design principles, anti-patterns). They differ in what they read, what they produce, and when they're appropriate.

The core thesis: **folder structure is agent architecture.** A properly layered workspace eliminates the need for a framework. The folder does what LangChain and CrewAI do with code — but with plain files any human can open, edit, and understand.

---

## Source material (in order of authority)

1. **ICM paper** (Van Clief & McDermott, University of Edinburgh) — formal specification of the 5-layer hierarchy, stage contracts, design principles, anti-patterns, practitioner findings. This is the ground truth for all structural decisions.
2. **CLIEF Notes course** (Foundation 1–4, Implementation Playbooks, Building Your Stack) — practical translation: how to write CLAUDE.md, the 7 common mistakes, the PRD pattern, session persistence, tool ladder.
3. **example-workspace/** — a concrete instance showing the 3-file minimum applied to a real domain.

---

## The 5-layer ICM hierarchy (shared across all modes)

| Layer | File | Token budget | Question it answers |
|-------|------|-------------|---------------------|
| 0 | `CLAUDE.md` (root) | ~800 tok | "Where am I?" |
| 1 | `CONTEXT.md` (root) | ~300 tok | "Where do I go?" |
| 2 | `stages/NN_name/CONTEXT.md` | 200–500 tok | "What do I do?" |
| 3 | `stages/NN_name/references/` + `_config/` | 500–2k tok | "What rules apply?" |
| 4 | `stages/NN_name/output/` | varies | "What am I working with?" |

**The Layer 3 / Layer 4 distinction is critical and must be enforced in all modes.** Layer 3 = factory configuration (stable across runs: voice guides, style conventions, domain knowledge). Layer 4 = product (per-run artifacts that change every time). Mixing them causes the model to treat stable rules as transient input, degrading output quality.

---

## Mode 1: Setup

**Trigger:** User wants to create a new workspace. Directory is empty or no ICM files exist.

**What Claude does:**
1. Reads `questionnaire.md` and asks the user the questions conversationally (Group A → B → C → D, with follow-up questions)
2. Confirms understanding: workspace name, domain, stages, input/output chain, reference material, rules
3. Gets user approval before generating anything
4. Generates the full workspace structure in this order:
   - Root `CLAUDE.md` (Layer 0: identity, routing table, naming conventions)
   - Root `CONTEXT.md` (Layer 1: what this workspace is, what good looks like, what to avoid)
   - `stages/` directory with numbered stage folders
   - Each stage's `CONTEXT.md` (Layer 2: stage contract — Inputs / Process / Outputs)
   - Each stage's `references/` directory (Layer 3, empty or pre-seeded from user answers)
   - Each stage's `output/` directory (Layer 4, empty)
   - `_config/` directory with shared reference files if the user described any
   - `PROGRESS.md` at root
   - `setup/questionnaire-answers.md` (the filled questionnaire, documents why structure exists)
5. Runs a Mode 4 (Check) pass on the generated workspace before confirming done
6. Reports what was created and how to start using it

**Key constraints:**
- Start minimal: 2–3 stages unless the user clearly has more distinct workflow modes
- CLAUDE.md must fit in 40–50 lines — routing file only, not a project brief
- Every stage CONTEXT.md must have all three contract sections (Inputs / Process / Outputs)
- Questionnaire answers go in `setup/` — this documents the factory configuration

---

## Mode 2: Review

**Trigger:** User wants to assess an existing workspace. They have CLAUDE.md, CONTEXT.md, and/or stage files and want to know if they can be improved.

**What Claude does:**
1. Reads all available workspace files (CLAUDE.md, root CONTEXT.md, stage CONTEXT.md files, any reference files)
2. Runs the review checklist (see `review-checklist.md`) against each layer
3. Produces a structured assessment:
   - **Layer-by-layer findings**: Pass / Warning / Fail for each check
   - **Priority order**: what to fix first (high-impact, low-effort changes first)
   - **Specific recommendations**: not "improve this section" but "add a routing table with these rows" or "move lines 23–40 to stage 01 CONTEXT.md"
4. Asks: "Do you want me to apply these changes?"
5. If yes, hands off to Mode 3 (Update) for each recommended change

**What the review checklist covers (Layer 0 — CLAUDE.md):**
- Is it present?
- Under 50 lines?
- Contains a routing table?
- Routing table has Task / Go to / Read columns at minimum?
- Identity block is present and describes the user and project (not Claude's personality)?
- Naming conventions are defined?
- No project detail that belongs in CONTEXT.md?

**What the review checklist covers (Layer 1 — root CONTEXT.md):**
- Is it present?
- Describes the work (not instructions to Claude about how to behave)?
- Has "what good looks like" and "what to avoid" sections?
- Under one page?
- Has a "last updated" marker?

**What the review checklist covers (Layer 2 — stage CONTEXT.md files):**
- Does each stage folder have a CONTEXT.md?
- Does each CONTEXT.md have all three sections: Inputs, Process, Outputs?
- Inputs section distinguishes Layer 3 (reference) from Layer 4 (working) files?
- Process section describes the work, not Claude's personality?
- Outputs section names specific files and their destinations?

**What the review checklist covers (Layer 3 — reference material):**
- Does each stage have a `references/` directory?
- Is `_config/` present if there's shared reference material?
- Are reference files in Layer 3 locations, not mixed into Layer 4 output/?

**What the review checklist covers (Layer 4 — working artifacts):**
- Does each stage have an `output/` directory?
- Are output files named consistently with the naming conventions in CLAUDE.md?
- Are Layer 4 files clearly separate from Layer 3?

---

## Mode 3: Update

**Trigger:** User wants to modify an existing workspace — new stage, changed scope, new reference material, evolved conventions, or applying fixes from a Mode 2 review.

**What Claude does:**
1. Reads existing workspace files to understand current structure
2. Asks the user: "What has changed, or what specifically needs updating?"
3. Identifies the minimal set of files that need to change — touches nothing else
4. Proposes specific edits before making them ("I'll add a row to the routing table in CLAUDE.md for the new research stage — is that right?")
5. Makes the changes, respecting existing structure and naming conventions
6. Updates `PROGRESS.md` with what changed and why
7. Optionally: runs Mode 4 (Check) on the affected files to confirm no new anti-patterns introduced

**Key constraints:**
- Never rebuild what's working — minimum viable change only
- Always read the existing CLAUDE.md and at least one stage CONTEXT.md before making changes, to infer the workspace's conventions
- If the change requires adding a new stage: follow Setup Mode step-generation for that stage only (don't touch others)
- If the change modifies a routing table: check that the new row doesn't conflict with existing rows
- If the change modifies a stage contract: verify the Inputs / Process / Outputs chain is still intact across adjacent stages

**Common update types and where they touch:**
| Update | Files affected |
|--------|---------------|
| Add a new stage | New stage folder + CONTEXT.md; CLAUDE.md routing table; root CONTEXT.md if scope changed |
| Remove a stage | CLAUDE.md routing table; adjacent stage Inputs (now points to different source) |
| Change naming conventions | CLAUDE.md conventions block; optionally rename existing files |
| Add reference material | New file in `_config/` or stage `references/`; relevant stage CONTEXT.md Inputs section |
| Expand scope of a stage | Stage CONTEXT.md Process section; possibly add to Inputs if new sources needed |
| Add rules | CLAUDE.md Rules block (check under 5 rules) or stage CONTEXT.md Process section |
| Update voice/style | `_config/voice.md` or equivalent Layer 3 file |

---

## Mode 4: Check

**Trigger:** User wants to audit an existing workspace for anti-patterns, inconsistencies, or structural problems. Can be run standalone or automatically after Setup/Update.

**What Claude does:**
1. Reads all workspace files
2. Runs the anti-pattern checklist (see `anti-patterns.md`)
3. Runs the structural integrity checks
4. Produces a report: **Finding / Severity / Recommended fix** for each issue
5. Groups findings by severity: Critical (breaks the workflow) / Warning (degrades quality) / Suggestion (improvement)
6. Asks: "Do you want me to fix the Critical and Warning items?"
7. If yes, hands off to Mode 3 (Update) for each fix

**Anti-pattern checklist (from 3.3 Common Mistakes + ICM Section 4.5):**

| Anti-pattern | How to detect | Severity |
|---|---|---|
| CLAUDE.md > 50 lines | Line count | Warning |
| No routing table in CLAUDE.md | Check for markdown table | Critical |
| Routing table missing columns (Task / Go to / Read) | Parse table headers | Critical |
| More than 5 stages on initial workspace | Count stage folders | Warning |
| CONTEXT.md describes Claude personality not work | Check for "be concise", "be creative", ratio of AI-behaviour vs work-description | Warning |
| Stage CONTEXT.md missing Inputs section | Check for `## Inputs` | Critical |
| Stage CONTEXT.md missing Process section | Check for `## Process` | Critical |
| Stage CONTEXT.md missing Outputs section | Check for `## Outputs` | Critical |
| Layer 3 and Layer 4 mixed (references in output/ or vice versa) | Check file locations vs naming | Warning |
| No `output/` directory for a stage | Directory check | Warning |
| No `references/` directory for a stage with reference material | Directory check | Suggestion |
| No `_config/` when reference material is shared across stages | Check for duplicate reference files | Suggestion |
| PROGRESS.md absent | File check | Suggestion |
| Context files not updated (no "Last updated" or stale date) | Check for date markers | Suggestion |
| Routing table row that doesn't match any stage folder name | Cross-reference routing table paths against actual folders | Warning |

**Structural integrity checks (edge cases):**

| Check | What to look for | Severity |
|---|---|---|
| Stage chain continuity | Does stage N+1's Inputs point to stage N's output/? | Critical |
| Input path validity | Do all file paths in stage Inputs sections actually exist? | Critical |
| Naming convention drift | Are files in output/ named consistently with CLAUDE.md conventions? | Warning |
| Context bleed | Does any stage Inputs section point to another stage's output/ (skipping a stage)? | Warning |
| Orphaned reference files | Are there files in references/ that no stage CONTEXT.md Inputs section loads? | Suggestion |
| Empty stage | Does any stage folder have only CONTEXT.md and no outputs from past runs? If so, is it the current active stage? | Suggestion |

---

## Mode detection logic

When the skill is invoked, Claude determines mode by checking:

1. **Is there a workspace here?** (Does CLAUDE.md exist at root?)
   - No → Mode 1 (Setup)
   - Yes → Ask the user: "I can see a workspace here. What do you want to do?" with options:
     - "Review it — is it well structured?" → Mode 2
     - "Update it — something has changed" → Mode 3
     - "Check it for problems" → Mode 4

2. **Can the mode be inferred from the user's request?**
   - "Build me a workspace" / "Create a workspace" / "Start a new project" → Mode 1
   - "Review my CLAUDE.md" / "Is this well structured?" / "Can this be improved?" → Mode 2
   - "Add a stage" / "Update my context" / "I've changed my workflow" → Mode 3
   - "Check for problems" / "Audit this" / "Anti-pattern check" → Mode 4

3. **If ambiguous:** Ask directly. One question, four options.

**Mode chaining (natural transitions):**
- Mode 1 → Mode 4 (auto-check after setup, before confirming done)
- Mode 2 → Mode 3 (review produces a list; update applies the list)
- Mode 4 → Mode 3 (check produces findings; update applies the Critical/Warning fixes)

---

## Files to build

### Skill infrastructure
| File | Purpose | Used by |
|------|---------|---------|
| `SKILL.md` | Main entry point. Mode detection, shared knowledge, design principles | All modes |
| `CONTEXT.md` | Describes what this skill is and how to invoke it | Skill folder context |

### Mode 1 — Setup
| File | Purpose |
|------|---------|
| `questionnaire.md` | The structured interview Claude runs with the user |
| `templates/CLAUDE.md.template` | Layer 0 template with placeholders |
| `templates/CONTEXT.md.template` | Layer 1 template |
| `templates/stage-CONTEXT.md.template` | Layer 2 template (Inputs/Process/Outputs) |
| `templates/REFERENCES.md.template` | Layer 3 reference placeholder |
| `templates/PROGRESS.md.template` | Session persistence file |

### Modes 2 & 4 — Review and Check
| File | Purpose |
|------|---------|
| `review-checklist.md` | Layer-by-layer checks for Mode 2 (structured assessment) |
| `anti-patterns.md` | Anti-pattern + structural integrity checks for Mode 4 |

### Mode 3 — Update
| File | Purpose |
|------|---------|
| `update-protocol.md` | Rules for minimal-change updates and common update type map |

### Examples
| File | Purpose |
|------|---------|
| `examples/script-to-animation/` | Complete 3-stage reference workspace (from ICM Section 4.2) |

---

## Specification: `questionnaire.md`

Questions in four groups, asked conversationally (not all at once):

**Group A — Identity**
- Your name and role?
- What problem does this workspace solve?
- What is the workspace called?

**Group B — Workflow mapping** (most important group)
- What are the 2–4 major stages? Name them.
- For each stage: what does it receive as input? what does it produce?
- What does the human review or decide at each stage boundary?
- Are any of these "the same mental mode at different stages"? (catches over-splitting)

**Group C — Reference material**
- Is there a voice or style guide? (yes → describe it briefly)
- Are there visual or design conventions? (yes → describe them)
- Domain-specific rules or constraints Claude must follow?
- Any material that applies to all stages (→ `_config/`)?

**Group D — Rules and naming**
- What should Claude always do in this workspace?
- What should Claude never do?
- How should output files be named? (e.g. topic-name_draft.md)

---

## Specification: `templates/stage-CONTEXT.md.template`

This is the most critical template. Every stage CONTEXT.md must follow this exact structure:

```markdown
# [Stage Name]

## Inputs

### Layer 4 (working — changes each run)
- `[path/to/previous-stage/output/filename.md]` — [brief description]

### Layer 3 (reference — stable across runs)
- `[path/to/references/file.md]` or `[path/to/../../_config/file.md]` — [brief description]

## Process

[Clear instructions to Claude about what to do in this stage. Written as directives.
Describes the work, not Claude's personality. Specific output requirements go here.
Include any constraints that apply to this stage only.]

## Outputs

- `[output-filename.md]` → `output/`
```

---

## Specification: `templates/CLAUDE.md.template`

Strict size constraint: 40–50 lines maximum. This is a routing file, not a project document.

```markdown
# [Workspace Name]

[One sentence. What this workspace is.]

## Folder Structure
- `stages/01_[name]/` — [one-line description]
- `stages/02_[name]/` — [one-line description]
- `stages/03_[name]/` — [one-line description]
- `_config/` — Shared reference material (voice, style, conventions)

## Routing

| Task | Go to | Read | Skills |
|------|-------|------|--------|
| [task type] | `stages/01_[name]/` | `CONTEXT.md` | — |
| [task type] | `stages/02_[name]/` | `CONTEXT.md` | — |
| [task type] | `stages/03_[name]/` | `CONTEXT.md` | — |

## Naming Conventions
- [file type]: [naming pattern]
- [file type]: [naming pattern]

## Rules
- Read this file and the relevant stage CONTEXT.md before starting any task
- Ask before creating files outside of designated output/ directories
- Layer 3 reference files (references/, _config/) are never modified during pipeline runs
- [user-defined rule 1]
- [user-defined rule 2]
```

---

## Specification: `examples/script-to-animation/`

Complete example workspace from ICM Section 4.2. Must demonstrate:
1. A routing table with 3 rows and a Skills column
2. Layer 0 CLAUDE.md under 40 lines
3. A stage CONTEXT.md with all three contract sections
4. The `_config/voice.md` pattern (Layer 3, stable)
5. `output/` and `references/` clearly separated
6. PROGRESS.md with a realistic past-session entry
7. The chain: `01_research/output/` → `02_script/CONTEXT.md Inputs` → `02_script/output/` → `03_production/CONTEXT.md Inputs`

---

## Design principles (enforced across all modes)

1. **One stage, one job.** A stage that fetches data does not also filter it. A stage that filters does not also format.
2. **Plain text as interface.** Markdown and JSON only. No databases, no proprietary serialization.
3. **Layered context loading.** Each stage loads only its own context. Never load all stages' instructions at once.
4. **Every output is an edit surface.** A human must be able to open, read, and edit any stage output before the next stage runs. This is not a nice-to-have — it is the control surface.
5. **Configure the factory, not the product.** Layer 3 is set up once. Each run produces a new product using the same factory.
6. **Routing table is mandatory.** Without it, Claude guesses which files to read. Guessing produces inconsistent results.
7. **Stage contracts are the core.** The Inputs/Process/Outputs structure is what makes a single agent orchestrate the whole pipeline without a framework.
8. **Minimal first.** Build the minimum. Use it. Add what's missing. Never build to anticipate hypothetical future stages.
9. **CLAUDE.md fits on one screen.** If it doesn't, context that belongs in CONTEXT.md or stage files has leaked into Layer 0.

---

## Build order

Dependencies are explicit:

- [ ] 1. Write `anti-patterns.md` — foundational, referenced by SKILL.md, Mode 2, and Mode 4
- [ ] 2. Write `review-checklist.md` — depends on knowing the anti-patterns
- [ ] 3. Write `questionnaire.md` — standalone
- [ ] 4. Write `update-protocol.md` — depends on review-checklist to know what updates look like
- [ ] 5. Write `templates/stage-CONTEXT.md.template` — core template, others depend on it
- [ ] 6. Write `templates/CLAUDE.md.template` — depends on knowing stage structure
- [ ] 7. Write `templates/CONTEXT.md.template` — simple, standalone
- [ ] 8. Write `templates/REFERENCES.md.template` — simple, standalone
- [ ] 9. Write `templates/PROGRESS.md.template` — standalone
- [ ] 10. Build `examples/script-to-animation/` — all templates must exist first
- [ ] 11. Write `SKILL.md` — master entry point, references all other files, written last when everything is specified
- [ ] 12. Write `CONTEXT.md` for the skill folder — written last, describes the completed skill
