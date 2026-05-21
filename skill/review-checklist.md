# Review Checklist

Used by Mode 2 (Review). This is a layer-by-layer assessment tool. Run through each layer in order, record the result of each check, then produce a structured report.

For full explanations of each issue — why it matters and how to fix it — see `anti-patterns.md`.

---

## How to run

1. Read all workspace files: `CLAUDE.md`, root `CONTEXT.md`, all stage `CONTEXT.md` files, files in `_config/` and stage `references/` directories.
2. Mark each check **Pass**, **Fail**, or **N/A** (not applicable). Collect all findings before presenting.
3. Present findings using this format. Be specific — not "improve this section" but "CLAUDE.md has 73 lines — extract lines 31–62 to root CONTEXT.md":

```
## Review findings: [workspace name]

### Critical
- [Check ID] [File]: [specific finding]
  → [specific fix]

### Warnings
- [Check ID] [File]: [specific finding]
  → [specific fix]

### Suggestions
- [Check ID] [File]: [specific finding]
  → [specific fix]

### Passing: [N] of [total] checks
```

4. Ask: "Do you want me to apply the recommended fixes?" If yes, read `skill/update-protocol.md` and apply changes one at a time, confirming before each.

---

## Layer 0 — CLAUDE.md (routing map)

Read `CLAUDE.md` at the workspace root.

| # | Check | Fail → Anti-Pattern |
|---|-------|---------------------|
| L0-1 | File exists at workspace root | — |
| L0-2 | Line count is 50 or fewer | AP-1 |
| L0-3 | Contains a markdown routing table (rows with `\|` separators) | AP-2 |
| L0-4 | Routing table has at minimum: `Task`, `Go to`, `Read` column headers | AP-3 |
| L0-5 | Every path in the "Go to" column matches an actual folder in the workspace | AP-3 |
| L0-6 | Every stage folder in the workspace has at least one corresponding row in the routing table | AP-3 |
| L0-7 | CLAUDE.md contains an explicit identity statement of the form "You are [Claude's identity] helping [person's name], a [role], [purpose]" — Claude's identity (expertise or persona) must appear before "helping"; a real person's name must follow "helping", not a role category | AP-10 |
| L0-8 | Naming conventions section is present and defines at least one file pattern | AP-9 |
| L0-9 | Rules section is present and contains 5 or fewer rules | AP-9 |
| L0-10 | Rules describe structural/routing behaviour, not writing style or AI personality | AP-5, AP-9 |
| L0-11 | File contains no multi-paragraph project descriptions or background context | AP-1 |

**What L0-1 Fail means in practice:** The workspace has no routing map. Claude loads all files or guesses. Run Mode 1 (Setup) instead of continuing the review.

---

## Layer 1 — Root CONTEXT.md (workspace description)

Read `CONTEXT.md` at the workspace root.

| # | Check | Fail → Anti-Pattern |
|---|-------|---------------------|
| L1-1 | File exists at workspace root | — |
| L1-2 | Describes what the workspace is for (what problem it solves, what domain) | AP-5 |
| L1-3 | Describes what good output looks like | AP-5 |
| L1-4 | Describes what to avoid | AP-5 |
| L1-5 | Content describes the work, not how Claude should behave | AP-5 |
| L1-6 | File is one page or less | AP-1 |
| L1-7 | Has a "Last updated" marker | AP-6 |

**Note on L1-1 Fail:** If CLAUDE.md exists but CONTEXT.md does not, Claude is working from routing only with no project description. This is workable for very simple workspaces but should be flagged. Ask the user if they want to create one.

---

## Layer 2 — Stage CONTEXT.md files (stage contracts)

For each numbered stage folder (`stages/NN_name/` or equivalent), read its `CONTEXT.md`.

Run these checks once per stage. Record which stage each finding belongs to.

| # | Check | Fail → Anti-Pattern |
|---|-------|---------------------|
| L2-1 | Stage folder contains a `CONTEXT.md` | AP-4 |
| L2-2 | `CONTEXT.md` has an `## Inputs` section | AP-4 |
| L2-3 | `## Inputs` distinguishes Layer 4 (working/per-run) from Layer 3 (reference/stable) | AP-8 |
| L2-4 | `CONTEXT.md` has a `## Process` section | AP-4 |
| L2-5 | `## Process` contains at least two sentences of substantive instruction | AP-4 |
| L2-6 | `## Process` describes the work, not Claude's personality or tone | AP-5 |
| L2-7 | `CONTEXT.md` has an `## Outputs` section | AP-4 |
| L2-8 | `## Outputs` names specific output files and their destination paths | AP-4 |
| L2-9 | Has a "Last updated" marker | AP-6 |

**Check count:** If there are N stages, there are N × 9 checks in this layer. Report findings per stage.

---

## Layer 3 — Reference material (stable factory configuration)

Check `_config/`, and each stage's `references/` directory.

| # | Check | Fail → Anti-Pattern |
|---|-------|---------------------|
| L3-1 | Each stage with Layer 3 files in its Inputs section has a `references/` directory | — |
| L3-2 | If the same reference file is needed by more than one stage, it is in `_config/` not duplicated | IC-7 |
| L3-3 | Files in `references/` and `_config/` are stable configuration (voice guides, conventions, domain knowledge) — not per-run outputs | AP-8 |
| L3-4 | Every file in `references/` and `_config/` is referenced in at least one stage Inputs section | IC-5 |
| L3-5 | File paths in stage Inputs sections that point to Layer 3 material actually exist | IC-2 |

---

## Layer 4 — Working artifacts (per-run outputs)

Check each stage's `output/` directory.

| # | Check | Fail → Anti-Pattern |
|---|-------|---------------------|
| L4-1 | Each stage has an `output/` directory | — |
| L4-2 | Files in `output/` are per-run artifacts (scripts, research outputs, specs) — not stable reference material | AP-8 |
| L4-3 | Filenames in `output/` follow the naming conventions defined in CLAUDE.md | IC-4 |
| L4-4 | If PROGRESS.md lists a stage as completed, its `output/` is not empty | IC-6 |
| L4-5 | For each stage PROGRESS.md shows as completed: the specific files named in its `## Outputs` section exist at the stated paths with non-zero content | IC-10 |

---

## Cross-layer integrity checks

These checks span multiple layers and must be run after all layer checks are complete.

| # | Check | Fail → Anti-Pattern |
|---|-------|---------------------|
| CI-1 | For each adjacent stage pair: stage N+1's Layer 4 Inputs path points to stage N's `output/` directory | IC-1 |
| CI-2 | Output filename in stage N's `## Outputs` matches the filename stage N+1 expects in its `## Inputs` | IC-3 |
| CI-3 | No stage skips the chain without an explanation in its Inputs section | IC-8 |
| CI-4 | Total stage count is ≤ 5 for a workspace where PROGRESS.md shows no completed sessions | AP-7 |

---

## Session persistence check

| # | Check | Fail → Anti-Pattern |
|---|-------|---------------------|
| SP-1 | `PROGRESS.md` exists at workspace root | AP-6 |
| SP-2 | `PROGRESS.md` has a "Current Status" section | — |
| SP-3 | `PROGRESS.md` has an "Active stage" section | AP-6 |
| SP-4 | No stage has files in `output/` that aren't reflected in PROGRESS.md as completed (indicates interrupted session) | IC-9 |
| SP-5 | If `session-history/` exists and has 3+ files: no `(stage, type)` correction pair appears in 3 or more files | AP-12 |

---

## Workspace generation record

These checks detect setup artifacts from the generation process. Their absence indicates the workspace may have been created before key skill improvements were introduced, or was set up manually without using the skill.

| # | Check | Fail → Anti-Pattern |
|---|-------|---------------------|
| VR-1 | `setup/session-prompts.md` exists — user has copy-paste prompts for session start/end/recovery | AP-11 |
| VR-2 | `setup/skill-version.md` exists — workspace has a generation record for version tracking | AP-11 |
| VR-3 | `setup/questionnaire-answers.md` exists — records why the workspace was structured this way | AP-11 |

