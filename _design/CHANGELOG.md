# Changelog

Completed improvements to the workspace-builder skill, most recent first.

---

## 2026-05-29

### Fix — Self-audit: add `core/task-protocol.md` to SKILL.md file listing

**Applied to:** `SKILL.md`

**What changed:**
- Added `core/task-protocol.md` to the Skill files table in `SKILL.md`. The file existed and was referenced from `core/engineering-standards.md` Section 7 ("Read `core/task-protocol.md` for the full format, coordinator procedure, and sub-agent guidance"), but was absent from SKILL.md's authoritative file listing. An agent consulting SKILL.md would not know the file exists unless it happened to read engineering-standards.md first.

**Gap addressed:** Missing file listing meant `core/task-protocol.md` was invisible at the entry-point level. The Skill files table is the canonical map of what the skill contains — every core file should appear in it.

---

### Fix — Rename `skill/` directory to `core/`

**Applied to:** `skill/` → `core/` (rename), `SKILL.md`, `README.md`, `VERSIONING.md`, all files under `core/` that referenced `skill/`, `_design/CHANGELOG.md`, `_design/IMPROVEMENTS.md`

**What changed:**
- Renamed the `skill/` directory to `core/` to align with the convention used across other skills in this repository (e.g. `adr-skill`), where `core/` holds the skill's own files and `skills/` (if present) holds referenced sub-skills.
- Updated all internal path references from `skill/` to `core/` across every affected file: `SKILL.md`, `README.md`, `VERSIONING.md`, all skill protocol and template files, all example workspace `setup/` files, and both `_design/` documents.
- Corrected the README installation example routing table path from `skill/workspace-builder/` to `skills/workspace-builder/` to match the actual directory convention.

**Gap addressed:** The `skill/` directory name was inconsistent with the `core/` convention established in other skills in this repo, making the structure harder to read at a glance and the convention less uniform across the skill library.

---

## 2026-05-28

### Fix — Versioning file and bash-style clarification (pre-existing untagged)

**Applied to:** `VERSIONING.md` (new), `skill/tools/bash-style.md`

**What changed:**
- Created `VERSIONING.md` — documents the date-based annotated tag convention (`v{YYYY-MM-DD}`), annotated-vs-lightweight distinction, tag message format (past-tense bullet list), the review-before-push rule, and a commands reference.
- Updated `skill/tools/bash-style.md`: clarified that large functions may be split into smaller focused functions; previously implied all functions must be single-block.

---

### 6 — Commit and changelog standards

**Applied to:** `skill/engineering-standards.md`

**What changed:**
- Added Section 6 "Commit and Changelog Standards" to `skill/engineering-standards.md`. Every session that changes files must produce small, independent, readable commits and a `CHANGELOG.md` entry. Defines: one-logical-change-per-commit rule, commit message format (imperative subject ≤72 chars, why-body, co-author line), selective staging rule (`git add <file>` not `git add -A`), submodule pointer commits as their own separate commit, and `CHANGELOG.md` entry format with required vs. not-required categories.

**Gap addressed:** No standard existed for how workspace changes should be committed. Sessions produced inconsistent commit history — some changes bundled, some atomic, commit messages describing what not why. The CHANGELOG.md format and update timing were undefined.

---

### 7 — Task-driven change management

**Applied to:** `skill/engineering-standards.md`, `skill/task-protocol.md` (new)

**What changed:**
- Added Section 7 "Task-Driven Change Management" to `skill/engineering-standards.md`: brief universal principle that non-trivial changes should be written to a task file (`setup/TASKS.md`) before being applied, each with a concrete success criterion. Points to `skill/task-protocol.md` for the full procedure.
- Created `skill/task-protocol.md`: full protocol covering task format (required fields: size, parallel-safe, files to read/edit, success criterion, pre-written changelog entry), size guide (small/medium/large with agent guidance per tier), coordinator agent wave-based execution procedure (dependency grouping, direct vs sub-agent decision, git worktree lifecycle for parallel large tasks), the four-condition task close (verify → changelog → remove from TASKS.md → commit), sub-agent context block template, what makes a good vs bad success criterion, and when not to use sub-agents.

**Gap addressed:** No structured pattern existed for deferring changes to a later session or applying multiple changes in a controlled, potentially parallel way. Changes were applied immediately or informally noted in conversation. This protocol enables a coordinator agent to read TASKS.md cold, build an execution plan, and apply changes with or without sub-agents.

---

### Fix — Rename task file convention from tasks.md to TASKS.md

**Applied to:** `skill/engineering-standards.md`, `skill/task-protocol.md`

**What changed:**
- Renamed all references to the task backlog file from `tasks.md` / `setup/tasks.md` to `TASKS.md` / `setup/TASKS.md` to match the uppercase convention used by `CHANGELOG.md` and `README.md`.

---

## 2026-05-25

### Fix — Safe deletion rule: prohibit `rm -rf` globally

**Applied to:** `core/engineering-standards.md`

**What changed:**
- Added Section 5 "Safe Deletion" to `core/engineering-standards.md` — a global rule prohibiting `rm -rf` in all workspace operations. Permitted alternatives: `rm` for single files, `rmdir` for empty directories, `rm -r` (without `-f`) for non-empty directories so errors surface rather than being silenced.
- Rule applies to all modes because `engineering-standards.md` is loaded as a pre-condition before any mode-specific skill file.

**Gap addressed:** No rule prevented forced recursive deletes. A typo in a path or an unexpected working directory during any workspace operation could silently destroy unintended files with no recovery path. Forced recursive deletes have no precise target boundary and suppress errors — both properties are unsafe in an agent context.

---

## 2026-05-21

### 4.1 — Engineering standards layer

**Applied to:** `core/engineering-standards.md` (new), `SKILL.md`

**What changed:**
- Created `core/engineering-standards.md` — four behavioral principles adapted from Karpathy's CLAUDE.md for ICM/system context: Think Before Acting, Simplicity First, Surgical Changes, Goal-Driven Execution. Generalised from coding-specific to consistent reproducible system behaviour.
- Added "All modes: Read `core/engineering-standards.md` before proceeding" to SKILL.md Modes section — standards apply universally as a pre-condition to any mode.
- Original Karpathy source saved to `_design/karpathy-engineering-standards-original.md` for reference.

**Gap addressed:** No universal behavioral baseline existed across modes. Each mode's protocol defined its own constraints in isolation. Engineering standards now provide a consistent foundation — minimal structure, surgical changes, verified outcomes — regardless of which mode is active.

---

### T5 — Tooling decision guides

**Applied to:** `core/tools/tool-decision.md` (new), `core/tools/bash-style.md` (new), `SKILL.md`

**What changed:**
- Created `core/tools/tool-decision.md` — decision guide for when to write a bash script vs. keep logic as Claude guidance vs. escalate to an external compiled tool. Grounded in the determinism principle: deterministic work belongs in deterministic tooling; AI handles intelligent/fuzzy work. Covers the inline → script → external tool escalation path, the risky-operation split-script pattern, and the skill's responsibility to flag (not build) compiled tools.
- Created `core/tools/bash-style.md` — concise style guide codifying conventions already in use across the four existing scripts: header format, section order, language choices (bashisms, quoting, safety), PASS/FAIL/NOTE output tokens, exit codes, and what not to do.
- Updated `SKILL.md` skill files table: `core/tools/` consolidated to single entry "Shell scripts and tooling guides (bash-style.md, tool-decision.md)".

**Gap addressed:** No documented standard for when to write a script or what a script should look like. New scripts risked inconsistent structure, unsafe patterns, or being written where Claude guidance would have been more appropriate.

---

### Fix — Audit cleanup and maintenance

**Applied to:** `core/questionnaire.md`, `core/templates/session-prompts.md.template` (new), `core/templates/session-history.md.template`, `core/anti-patterns.md`, `SKILL.md`

**Issues fixed:**

1. **Session prompts hardcoded in questionnaire** — Full `session-prompts.md` content was embedded inline in questionnaire.md step 9 with no single source of truth. Extracted to `core/templates/session-prompts.md.template`; step 9 now reads "copy `core/templates/session-prompts.md.template`".

2. **Stale "3.2" reference in session-history.md.template** — Comment referenced "3.2 pattern detection" — a dead section number from an earlier skill version. Replaced with "AP-12 (anti-patterns.md)".

3. **AP-12 fix missing Mode 5 route** — AP-12's Fix section went directly to Mode 3 (Update) even when the root cause was unclear. Recurring corrections are a primary Trace trigger. Fix section now routes to Mode 5 (Trace) as a diagnostic step when the root cause isn't clear from reading the contract alone.

4. **Quality gates led with manual checks** — Setup quality gates listed manual checks first; preflight.sh was buried in the "run a full Check" instruction. Reordered: preflight.sh runs first (mechanical checks), anti-patterns.md deferred checks second, manual checklist as script-unavailable fallback only.

5. **Feature flags stale** — `setup/skill-version.md` feature flag block in questionnaire.md step 10 predated today's additions. Added `engineering-standards: yes`, `tool-decision: yes`, `bash-style: yes`.

6. **SKILL.md templates/ description incomplete** — Said "Mode 1 only"; `REFERENCES.md.template` is also used by Mode 3 upgrade procedure. Updated to "Mode 1 primary; REFERENCES.md.template also used in Mode 3".

---

## 2026-05-08

### 3.2 — Recurring correction pattern detection via session-history/

**Applied to:** `core/templates/PROGRESS.md.template` (restructured), `core/templates/session-history.md.template` (new), `core/templates/CLAUDE.md.template` (rule 2), all three example workspaces, `core/anti-patterns.md` (AP-12), `core/review-checklist.md` (SP-3, SP-5), `core/tools/preflight.sh` (SP-3, SP-5), `core/tools/audit-all.sh` (last_session_date), `core/examples/README.md`, `core/questionnaire.md` (session-end prompt)

**What changed:**
- Session history separated from PROGRESS.md into individual `session-history/YYYY-MM-DD.md` files with YAML frontmatter. PROGRESS.md is now active state only: Current Status, Active stage, Decisions made, Open questions.
- New `session-history.md.template` with structured `corrections` field: `(stage, type, description)`. Correction types are a defined vocabulary: tone, structure, content, length, accuracy, constraint, format.
- CLAUDE.md template rule 2 updated to cover both mid-session PROGRESS.md updates and session-end history file creation.
- Session-end prompt updated across questionnaire.md and all example session-prompts.md: create `session-history/YYYY-MM-DD.md`, then update PROGRESS.md Current Status.
- AP-12 added: if the same `(stage, type)` correction pair appears in 3+ session history files, flag it. Fix is a source-level change to the stage contract or Layer 3 reference file.
- SP-3 updated: now checks "Active stage" section instead of "Last Session" (which moved out of PROGRESS.md). SP-5 added: checks `session-history/` directory existence.
- `audit-all.sh` last_session_date() now reads the most recent `session-history/` filename as the date, falling back to PROGRESS.md.
- All three example workspaces updated: lean PROGRESS.md, realistic session history files demonstrating pattern-detection data (script-to-animation has an emerging `02_script/length` pattern across two sessions).

**Gap addressed:** PROGRESS.md bloated with historical entries; free-text parsing for pattern detection was fragile; session history had no structure. Session history now has searchable date-named files, YAML frontmatter for machine-readable correction tracking, and PROGRESS.md stays lean enough to scan at a glance.

---

### E4 — Proactive Q3 identity suggestion in questionnaire

**Applied to:** `core/questionnaire.md`

**What changed:**
- Q3 guidance updated: "If the user is unsure, don't wait for them to figure it out. Derive a suggestion from Q2 immediately: 'Based on your role as [Q2 answer], Claude could be *a senior [domain] expert*. Does that feel right, or is there a specific voice you'd prefer?' Then let them accept, tweak, or replace it."
- "What to listen for" note updated to match: explicitly says to offer a concrete suggestion if the user hesitates rather than leaving them with an open question.

**Gap addressed:** The instruction "if unsure, suggest based on Q2" was passive and buried in the "What to listen for" section. Users who blank on Q3 would stall the interview. The proactive formula (derive from Q2, offer it, let them confirm or change) removes that friction while still allowing named personas and custom identities.

---

## 2026-05-07

### Fix — Full consistency review

**Applied to:** `core/questionnaire.md`, all three example `setup/questionnaire-answers.md`, `core/examples/README.md`, `_design/IMPROVEMENTS.md`

**Issues found and fixed:**
1. **Duplication path missing skill-version.md** — Step 4 of the duplication path generated session-prompts.md and questionnaire-answers.md but not skill-version.md. Added as step 9.
2. **questionnaire-answers.md missing Claude Identity** — All three example questionnaire-answers.md files were written before Q3 (Claude's identity) was added to Group A. Added `**Claude identity:**` field to all three, matching their respective CLAUDE.md identity statements.
3. **examples/README.md `setup/` section incomplete** — Described only questionnaire-answers.md and session-prompts.md. Rewritten to describe all three files (questionnaire-answers.md, session-prompts.md, skill-version.md) with their specific purposes.

**Issues checked and confirmed clean:**
- Identity format consistent across all examples and templates ("You are [identity] helping...")
- AP/IC numbering sequential (AP-1 through AP-11, IC-1 through IC-10)
- Review checklist check IDs consistent with anti-patterns
- Mode numbering consistent (1–5) across SKILL.md, detection table, and modes section
- Q number references in anti-patterns.md correct (Q3 = Claude identity, Q4 = workspace purpose)
- Upgrade procedure step numbering correct (10 → 11 → 12)
- All preflight.sh VR checks passing on all three examples

**`_design/IMPROVEMENTS.md` additions:** Six edge cases (E1–E6) and five future investigation items (F1–F5) documenting known gaps, maintenance discipline requirements, and open questions for skill evolution.

---

### T4 — Workspace version tracking

**Applied to:** `SKILL.md`, `core/questionnaire.md`, `core/anti-patterns.md`, `core/review-checklist.md`, `core/tools/preflight.sh`, `core/update-protocol.md`, all three example workspaces

**What changed:**
- Added `**Skill build:** 2026-05-07` to SKILL.md — single source of truth for the current skill version date.
- Added step 10 to questionnaire.md "After confirmation": generate `setup/skill-version.md` using the skill build date from SKILL.md and a fixed set of feature flags describing what this version of the skill generates. Also fixed the stale identity format string in the quality gate.
- Added AP-11 to anti-patterns.md: "Workspace missing setup generation artifacts" — Warning for absent `session-prompts.md` (session resilience gap), Suggestion for absent `skill-version.md` (no provenance record) and `questionnaire-answers.md` (no design rationale).
- Added "Workspace generation record" section to review-checklist.md with three checks: VR-1 (session-prompts.md), VR-2 (skill-version.md), VR-3 (questionnaire-answers.md).
- Added `check_generation_record()` to preflight.sh, wired into `main()`.
- Added step 11 to the upgrade procedure in update-protocol.md: generate `setup/skill-version.md` when upgrading a 3-file workspace.
- Added `setup/skill-version.md` and `setup/session-prompts.md` to all three example workspaces.

**Gap addressed:** No way to know which version of the skill generated a workspace, or to surface improvements that postdate it. A workspace from before the identity format change, skills column, or session prompts would silently lack those features with no indication that anything was missing.

---

### 3.1 — Output provenance tracking (Trace mode)

**Applied to:** `core/trace-protocol.md` (new), `SKILL.md`

**What changed:**
- Created `core/trace-protocol.md` — a 6-step procedure for walking backwards through the stage chain to find where a specific output problem originated. Steps: define the problem precisely → read the problem stage → check Layer 3 reference files → walk backwards → classify root cause (A: contract problem, B: reference material problem, C: input problem, D: compounding deviation) → report with specific actionable fix.
- Added Mode 5 (Trace) to SKILL.md: detection triggers ("Trace", "where did this go wrong", "find the source of", "why does the output"), option 4 in the ambiguous-case question, Mode 5 entry in the Modes section.
- Updated the modes table to include Trace, and the chaining note: "Trace hands off to Update."
- Added `core/trace-protocol.md` and `core/tools/` to the skill file structure listing.

**Design:** Trace is distinct from Review (Mode 2) and Check (Mode 4). Those find structural/anti-pattern problems in the workspace. Trace diagnoses a known content quality problem by tracing its origin through the stage chain — the equivalent of a stack trace for a content pipeline. After diagnosis, it hands off to Mode 3 (Update) to apply the source-level fix.

---

### T3 — Stage output diff

**Applied to:** `core/tools/diff-stage.sh` (new), `core/templates/stage-CONTEXT.md.template`

**What changed:**
- Created `core/tools/diff-stage.sh` — two-mode tool for comparing stage outputs between runs.
  - `--archive` mode: copies each file named in the stage's `## Outputs` contract to `output/_archive/` with a timestamp prefix (`YYYY-MM-DDTHH-MM_filename`). Run before re-executing the stage.
  - Default mode: finds the most recent archive for each contract-named output file and shows a unified diff against the current output. Exit code 1 if changes detected, 0 if identical.
- Filenames are driven by the stage's `## Outputs` section — the same contract that preflight.sh and reconcile-progress.sh use, so there is no separate configuration.
- Added a usage note to `stage-CONTEXT.md.template` `## Outputs` comment.

**Gap addressed:** When re-running a stage after improving its contract, practitioners had no way to compare old vs new output. They had to manually remember what changed or do their own archiving.

---

### T2 — Batch workspace audit

**Applied to:** `core/tools/audit-all.sh` (new)

**What changed:**
- Created `core/tools/audit-all.sh` — finds all direct subdirectories of a parent directory that contain a CLAUDE.md, runs `preflight.sh` on each, and produces a summary table: workspace name, critical count, warnings, suggestions, last session date from PROGRESS.md.
- Table rows truncate workspace names to 28 chars with ellipsis.
- Full preflight detail is shown only for workspaces with Critical or Warning issues; clean workspaces produce only a table row.
- Exit code 0 if all workspaces clean, 1 if any had issues.
- Locates `preflight.sh` automatically relative to its own script directory — no path configuration required.

**Usage:** `bash core/tools/audit-all.sh [parent-directory]`

**Gap addressed:** preflight.sh audited one workspace at a time. Users with multiple workspaces had no health overview across all of them.

---

### Fix — Identity statement format: explicit Claude persona before "helping"

**Applied to:** `core/templates/CLAUDE.md.template`, all three example workspaces, `core/questionnaire.md`, `core/anti-patterns.md`, `core/review-checklist.md`, `core/tools/preflight.sh`

**What changed:**
- Identity format changed from `"You are helping [name], a [role], [purpose]"` to `"You are [Claude's identity] helping [name], a [role], [purpose]"`. Claude now has an explicit identity it embodies before the helping relationship is established.
- Template updated with annotated placeholders explaining each slot, including examples of expertise-style ("a content creation and animation expert") and named persona ("Alex Hormozi") identities.
- Template comment explains that `[Claude's identity]` comes from Group A Q3, added as a new questionnaire question.
- Group A Q3 added to questionnaire: "Who should Claude be in this workspace?" — collects Claude's explicit identity/persona before the workspace purpose question.
- Confirmation summary updated to include "Claude identity:" line.
- Generation step 1 updated to populate identity from Q3.
- AP-10 updated: "You are helping..." (no explicit Claude persona) is now a Warning. Named personas ("Alex Hormozi") are explicitly noted as valid and should not be flagged.
- L0-7 updated to check for the new format.
- preflight.sh L0-7 check updated: detects missing persona (starts with "You are helping" directly), missing "helping" clause, and role category after "helping".
- All three example workspaces updated with appropriate expert identities.

**Rationale:** "You are helping X" hands Claude a relationship but no identity. "You are [identity] helping X" hands Claude both — it knows who it IS before working. Named personas add significant value: "You are Alex Hormozi helping Jake..." shapes not just vocabulary and depth but decision-making style and communication register throughout the session.

---

### T1 — PROGRESS.md reconciliation script

**Applied to:** `core/tools/reconcile-progress.sh` (new), `core/questionnaire.md`, `core/templates/PROGRESS.md.template`

**What changed:**
- Created `core/tools/reconcile-progress.sh` — reads all stage contracts' `## Outputs` sections, checks which files exist in `output/` with content, compares against PROGRESS.md completion records, and prints a reconciliation report with a recommended "Current Status" line.
- Output format: per-stage table showing file system status (COMPLETE/PARTIAL/EMPTY/NONE), PROGRESS.md status, and a match/discrepancy indicator. Ends with a recommended state the user can apply.
- Exit code 0 if consistent, 1 if discrepancies found.
- Updated session-start prompt in `questionnaire.md` to prefer the script when accessible, with the manual Claude approach as fallback.
- Updated `PROGRESS.md.template` comment to reference the script.

**Gap addressed:** The session-start prompt asked Claude to manually check output/ directories against stage contracts every session — a mechanical task taking tokens and attention. The script handles this automatically in seconds.

---

### 2.4 — Transitive dependency checking in Update

**Applied to:** `core/update-protocol.md`

**What changed:**
- Added step 6 to the Procedure: "Verify the full stage chain" for structural updates. Runs IC-1 (chain continuity), IC-3 (output/input filename match), and IC-8 (unexplained stage skips) across every adjacent stage pair in the workspace — not just the pair adjacent to the change.
- Existing steps 6 and 7 renumbered to 7 and 8.
- Step 6 clearly specifies which update types are structural (add/remove/rename/reorder a stage, change a stage's Outputs) vs non-structural (reference material, Process edits, naming, rules, skills wiring) — non-structural updates skip the chain check.

**Gap addressed:** Structural updates previously only checked the immediately adjacent stage. A stage insertion between stages 1 and 3 would update stage 3's Inputs to point to the new stage 2, but if stage 4 was referencing stage 3's output by a path that is now stale (e.g. stage 3 was renumbered), that break would go undetected until stage 4 ran.

---

### 3.3 — Pre-flight mechanical checks via script

**Applied to:** `core/tools/preflight.sh` (new), `core/anti-patterns.md`

**What changed:**
- Created `core/tools/preflight.sh` — a bash script (following style.ysap.sh conventions) that runs all mechanically-determinable ICM checks against a workspace. Decomposed into small, focused functions: `check_claude_md`, `check_context_md`, `check_stage_contracts`, `check_stage_dirs`, `check_output_contracts`, `check_session`, `check_fs_vs_progress`. Output uses `PASS/FAIL/NOTE` prefixes with check IDs mapping directly to review-checklist.md.
- Script ends with a `Deferred to Claude` heredoc listing every check that requires reading and judgment (AP-5, AP-6, all semantic content checks, IC-8 intentionality, etc.) so Claude knows exactly what to verify manually.
- Updated "How to run a full audit" in anti-patterns.md: when the script is available, run it first; PASS items can be skipped; FAIL/NOTE items are pre-populated findings; proceed only to the deferred checks manually.
- Added new tooling improvements to IMPROVEMENTS.md: T1 (PROGRESS.md reconciliation script), T2 (batch workspace audit), T3 (stage output diff), T4 (workspace version tracking).

**Token impact:** Claude no longer needs to read every workspace file to perform mechanical checks. On a workspace where all mechanical checks pass, Claude only needs to read the files relevant to the deferred (judgment-required) checks.

---

### 2.3 — Skills and MCP wiring in the routing table

**Applied to:** `core/questionnaire.md`, `core/update-protocol.md`

**What changed:**
- Added Group C Q6 to the questionnaire: "Does any stage need a specific skill or external tool?" with examples (web search MCP, code execution, design system skill, data tool). Answer populates the Skills column in the routing table.
- Updated "What to listen for" in Group C to note that skills/MCPs go in the routing table Skills column, not in reference files (unless the skill has its own configuration).
- Updated the confirmation summary to show skills inline per stage: `[stage name] — takes [input], produces [output] — skill: [name or —]`.
- Updated "After confirmation" step 1 to explicitly populate the Skills column from Group C Q6 answers.
- Added Skills question to the duplication path abbreviated interview.
- Added two rows to the update-protocol.md common update types table: "Add a skill or MCP to a stage" and "Remove a skill or MCP from a stage", specifying which files each touches.

**Original gap:** The routing table had a Skills column but Setup always generated `—` in it. No question collected skill information, and no Update procedure existed for adding or removing skills.

---

### 2.2 — Workspace duplication mode

**Applied to:** `core/questionnaire.md`, `SKILL.md`

**What changed:**
- Added a pre-flight question to the top of the questionnaire interview: "Are you building from scratch, or adapting an existing workspace?" Routes to either the standard Groups A–D or the new Duplication path.
- Added a full Duplication path section at the end of questionnaire.md with 4 steps: read the source workspace, abbreviated interview (identity / domain / stage review / reference material / rules), confirmation summary (showing inherited vs changed elements), and adapted generation (rewrite Process sections, adapt reference content, keep Inputs/Outputs structure, fresh PROGRESS.md, duplication-specific questionnaire-answers.md).
- Added "Duplicate", "adapt", "base this on" trigger phrases to SKILL.md mode detection table, pointing to Mode 1 (duplication path).
- Added option 5 ("Duplicate") to the ambiguous-case question in SKILL.md.

**Key design decision:** The duplication path inherits stage structure (count, folder names, Inputs/Outputs contracts) and adapts content (Process sections, reference file content, CONTEXT.md, Identity). The abbreviated interview focuses on what changes — domain differences, voice guide applicability, stage renames — rather than re-deriving what already works.

**Original gap:** Users had to manually copy a workspace and then run Update repeatedly to adapt it. No structured path existed for the common pattern of "I want something like X but for Y."

---

### Fix — Explicit identity statement in CLAUDE.md

**Applied to:** `core/templates/CLAUDE.md.template`, all three example workspaces, `core/anti-patterns.md`, `core/review-checklist.md`, `core/questionnaire.md`

**What changed:**
- CLAUDE.md template: replaced the bare one-liner description with a proper `## Identity` section — "You are helping [name], a [role], with [domain]." The Identity statement absorbs the workspace description while adding the role context the Foundation course identifies as critical.
- Template comment updated to note that Identity is populated from Group A questionnaire answers: name (Q1) + role (Q2) + domain/purpose (Q3).
- All three example workspaces updated with real Identity statements from their questionnaire-answers.md data.
- Added AP-10 to anti-patterns.md: "CLAUDE.md missing explicit identity statement." Severity Warning. Distinguishes between a workspace description (not sufficient) and an identity statement (required). Also flags "You are a [role]" (weaker) vs "You are helping [name], a [role]" (correct) as a Suggestion.
- Updated L0-7 in review-checklist.md: previously vaguely mapped "identity block" to AP-5 (AI personality vs work). Now specifically checks for the "You are helping [name/role] with [domain]" format, mapped to AP-10.
- Added identity statement to the quality gates in questionnaire.md's "After confirmation" section.
- Added explicit instruction in generation step 1: populate `## Identity` from Group A answers.

**Gap addressed:** CLAUDE.md files generated by the skill described what the workspace does but not who is being helped or in what role. The Foundation course (1.3) identifies identity as the element most often skipped and the one that most reduces output quality when absent — it shapes vocabulary, depth, and assumptions.

---

### 2.1 — Multiple domain examples

**Applied to:** `core/examples/`, `core/questionnaire.md`

**What changed:**
- Added `core/examples/research-synthesis/` — a 4-stage pipeline (collect → extract → synthesise → report) for literature review and research synthesis work. Includes CLAUDE.md, CONTEXT.md, PROGRESS.md, `_config/voice.md`, stage contracts for all four stages, `stages/04_report/references/report-structure.md`, and `setup/questionnaire-answers.md`.
- Added `core/examples/client-deliverable/` — a 3-stage pipeline (intake → analysis → draft) for consulting and professional deliverables. Includes CLAUDE.md, CONTEXT.md, PROGRESS.md, `_config/voice.md`, `_config/client-profile.md` (per-engagement template), stage contracts for all three stages, `stages/03_draft/references/deliverable-format.md`, and `setup/questionnaire-answers.md`.
- Added domain pointer note to questionnaire.md Group B: if the user's domain resembles an existing example, mention the relevant example path. No token cost — pointer only, not a load instruction.

**Token impact:** Zero runtime overhead. Examples are never loaded automatically; they are consulted on demand only.

---

### 1.4 — Stage contract validation after a pipeline run

**Applied to:** `core/anti-patterns.md`, `core/review-checklist.md`

**What changed:**
- Added IC-10 to anti-patterns.md: "Stage marked complete but Outputs contract not satisfied." Detects three failure cases for each stage PROGRESS.md shows as completed: (1) named output file absent from stated path, (2) file present but empty, (3) output/ contains files but none match the names the contract specifies.
- Added L4-5 to review-checklist.md Layer 4 section, mapping to IC-10.
- Also corrected IC-8/IC-9 ordering in anti-patterns.md (IC-9 had been inserted before IC-8 during a previous fix).

**Distinction from IC-6:** IC-6 checks whether output/ has any files. IC-10 checks whether the specific files the stage contract promises exist at the exact paths stated, with content.

**Original gap:** Mode 4 didn't verify that a "completed" stage produced the specific files its contract promised. A stage could be marked complete while its output was saved to the wrong path, named differently, or empty.

---

## 2026-05-06

### Fix — Proactive PROGRESS.md updates during sessions

**Applied to:** `core/templates/CLAUDE.md.template`, `core/templates/PROGRESS.md.template`, `core/examples/script-to-animation/CLAUDE.md`

**What changed:**
- Added a 4th default rule to CLAUDE.md.template: "Update PROGRESS.md when completing a task, hitting a blocker, or moving to a new stage — do not wait for session end." This puts the instruction in CLAUDE.md (always read at task start), keeping it persistently in context throughout a session.
- Updated the PROGRESS.md template comment to specify what to write at each transition type: completed → Completed/In Progress/Next; blocker → Blocked + reason; decision → Decisions Made; stage change → Current Status.
- Updated the example workspace CLAUDE.md to include the new default rule (41 lines, within limit).
- User-defined rule slots reduced from 2 to 1; total rule limit remains 5.

**Gap addressed:** PROGRESS.md was only updated at graceful session end or when the user manually ran a prompt. Mid-session transitions (task completion, stage change, blocker) went unrecorded until then.

---

### Fix — Session resilience: recovery from interrupted sessions

**Applied to:** `core/questionnaire.md` (session-prompts.md content), `core/templates/PROGRESS.md.template`, `core/anti-patterns.md`, `core/review-checklist.md`

**What changed:**
- Session-start prompt now checks actual `output/` directories against each stage's CONTEXT.md Outputs section, not just PROGRESS.md. Discrepancies are surfaced before proceeding, making recovery from interrupted sessions automatic at every session start.
- PROGRESS.md template updated to clarify it reflects "last graceful session end" rather than authoritative current state, and its embedded prompt template updated to match.
- IC-9 added to anti-patterns.md: detects when output files exist for stages PROGRESS.md doesn't show as complete (interrupted session indicator), and the reverse (IC-6 already existed for the other direction).
- SP-4 added to review-checklist.md session persistence checks, mapping to IC-9.

**Gap addressed:** Graceful session end was the only path to keeping PROGRESS.md current. Crashes, restarts, internet drops, and token-limit cutoffs left it stale with no recovery path. The file system (stage output/ directories) is now the ground truth; PROGRESS.md is "last known good state" that gets reconciled at every session start.

---

### 1.3 — Workspace upgrade path from simple 3-file setup

**Applied to:** `core/update-protocol.md`, `SKILL.md`

**What changed:**
- Added "Upgrade 3-file workspace to staged structure" row to the common update types table in update-protocol.md
- Added detailed 11-step upgrade procedure to update-protocol.md covering: abbreviated Group B interview, stages/ creation, REFERENCES.md migration to `_config/` with archiving of the original, additive (non-destructive) CLAUDE.md update, minimal CONTEXT.md changes, and PROGRESS.md/session-prompts generation
- Added 3-file workspace detection to SKILL.md mode detection: surfaces the upgrade option proactively when `stages/` is absent, adds "Upgrade" trigger phrase to the mode table, and adds option 5 to the ambiguous-case question (conditionally shown)

**Original gap:** Users arriving with a basic CLAUDE.md + CONTEXT.md + REFERENCES.md workspace from the Foundation course had no clear path to the full ICM 5-layer structure.

---

### 1.2 — Session-start and session-end prompts in Setup output

**Applied to:** `core/questionnaire.md`

**What changed:**
- Added step 9 to "After confirmation": generate `setup/session-prompts.md` with three ready-to-use prompts (session start, session end, before stepping away)
- Updated the completion report instruction to include the session prompts inline, so the user has them immediately without opening a file

**Original gap:** Setup generated the workspace structure and files but gave the user no copy-paste prompts for resuming work in future sessions.

---

### 1.1 — Draft Layer 3 reference files during Setup

**Applied to:** `core/questionnaire.md`

**What changed:**
- Step 5 of "After confirmation" now instructs Claude to draft the content of any stage-specific reference files described in Group C Q4, rather than creating empty directories
- Step 6 maps each Group C question to a specific `_config/` file with explicit content structure:
  - Q1 (voice/style) → `_config/voice.md`: Purpose, Voice/tone, sentence conventions, what to avoid, examples
  - Q2 (structural conventions) → `_config/conventions.md`: structural rules and format requirements
  - Q3 (domain knowledge) → `_config/domain.md`: key concepts, constraints, domain rules
- Guard rails: skip files with no input (no empty placeholders); mark sparse sections with `[TO EXPAND]`

**Original gap:** Setup collected voice, style, and domain information in Group C but then created empty placeholder files. The user had to re-enter the same information manually after generation.
