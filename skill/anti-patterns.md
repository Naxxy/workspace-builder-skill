# Anti-Patterns and Integrity Checks

## How to run a full audit (Mode 4)

**If `skill/tools/preflight.sh` is accessible**, run it first:

```bash
bash skill/tools/preflight.sh [workspace-path]
```

Read its output. Checks marked `PASS` are mechanically verified — skip them below.
Use `FAIL` and `NOTE` items as pre-populated findings. Then proceed to the
`Deferred to Claude` section at the bottom of the script output, which lists
the checks that require reading and judgment — run only those manually.

**If the script is not accessible**, proceed manually:

1. Read all workspace files.
2. Run every check below — AP-1 through AP-9, then IC-1 through IC-8.
3. Collect all findings before presenting.
4. Present the report:

```
## Audit: [workspace name]

### Critical
- [AP/IC ID] [File]: [specific finding]
  → [specific fix]

### Warnings
- [AP/IC ID] [File]: [specific finding]
  → [specific fix]

### Suggestions
- [AP/IC ID] [File]: [specific finding]
  → [specific fix]

### Clean: [N] of [total] checks passed
```

5. If no findings, confirm the workspace is clean.
6. Ask: "Do you want me to fix the Critical and Warning items?" If yes, read `skill/update-protocol.md` and apply fixes.

---

## Severity levels

| Level | Meaning | When to fix |
|-------|---------|-------------|
| **Critical** | Breaks the workflow or causes consistent output degradation | Before using the workspace |
| **Warning** | Degrades output quality or creates maintenance problems | In the current session |
| **Suggestion** | Improvement worth making; does not block good output | When convenient |

---

## Part 1: Anti-Patterns

### AP-1 — CLAUDE.md exceeds routing scope

**Severity:** Warning

**Detect:** Line count exceeds 50. Or: file contains multi-paragraph project descriptions, background context, prior decisions, or audience descriptions — anything that reads like a project brief rather than a routing map.

**Fix:** Extract project description content to root `CONTEXT.md`. Extract stage-specific content to the relevant stage `CONTEXT.md`. CLAUDE.md should contain: identity block, folder structure, routing table, naming conventions, rules. Nothing else.

---

### AP-2 — No routing table in CLAUDE.md

**Severity:** Critical

**Detect:** No markdown table present in CLAUDE.md (look for rows with `|` separators and a header row containing `---`).

**Fix:** Add a routing table with at minimum three columns: `Task | Go to | Read`. One row per task type or workflow stage. Paths in "Go to" must match actual folder names exactly.

---

### AP-3 — Routing table is incomplete or has broken paths

**Severity:** Critical (broken paths) / Warning (missing rows)

**Detect:**
- Check every path in the "Go to" column against actual folder names. Any mismatch is a broken path.
- Check that every stage folder has at least one routing table row.
- Check column headers — minimum required: `Task`, `Go to`, `Read`.

**Fix:** Correct broken paths. Add a row for any stage with no coverage. Add missing column headers.

---

### AP-4 — Stage CONTEXT.md missing contract sections

**Severity:** Critical (Inputs or Outputs missing) / Warning (Process absent or single-line)

**Detect:** Check each stage `CONTEXT.md` for all three headers: `## Inputs`, `## Process`, `## Outputs`. If any is missing, the contract is incomplete. If Process has fewer than two sentences, flag as Warning.

**Fix:** Add missing sections:

```
## Inputs
### Layer 4 (working)
- `path/to/previous-stage/output/file.md`
### Layer 3 (reference)
- `path/to/references/file.md`

## Process
[Instructions to Claude. Describe the work, not Claude's personality.]

## Outputs
- `filename.md` → `output/`
```

---

### AP-5 — Context file describes AI behaviour rather than work

**Severity:** Warning

**Detect:** Read the context file. If more than 30% of sentences describe how Claude should behave (tone, style, personality) rather than the work (project, audience, input, good output, what to avoid), flag it.

Trigger phrases: "be concise", "be creative", "be professional", "think step by step", "use a warm tone", "write clearly".

**Fix:** Rewrite to describe the work. Test: could a new team member read this file and immediately know what the project is, who it's for, what to produce, and what mistakes to avoid? If not, rewrite it.

---

### AP-6 — Context files are stale or have no update marker

**Severity:** Warning

**Detect:**
- Check each context file for a "Last updated" line.
- If PROGRESS.md exists, check whether context file content is consistent with the most recent session date and active stage.

**Fix:** Add "Last updated: YYYY-MM-DD" to each context file. Review content for currency against PROGRESS.md.

---

### AP-7 — Too many stages for the workspace's current maturity

**Severity:** Warning

**Detect:** More than 5 stage folders AND PROGRESS.md shows no completed sessions (or PROGRESS.md is absent). Also flag if two or more stages have nearly identical Process sections.

**Fix:** Ask: "Are these two stages the same mental mode at different points in the process?" If yes, consolidate into one stage with a Process section that covers the progression.

---

### AP-8 — Layer 3 and Layer 4 content are mixed

**Severity:** Warning

**Detect:**
- Check `references/` folders for per-run output files (dated names, draft numbers, content-specific names like `script-draft.md`). These are Layer 4 artifacts in a Layer 3 location.
- Check `output/` folders for stable reference files (voice guides, style rules, conventions, templates). These are Layer 3 artifacts in a Layer 4 location.
- Check `_config/` for run-specific content.

**Fix:** Move stable reference files to `references/` or `_config/`. Move per-run outputs to `output/`. Update any Inputs sections that reference the moved files.

---

### AP-9 — CLAUDE.md Rules section is over-specified or off-topic

**Severity:** Suggestion

**Detect:** Rules section contains more than 5 rules. Or: rules describe output formatting, writing style, or Claude's personality rather than structural/routing behaviour.

**Fix:** Keep Rules to structural routing behaviour only. Maximum 5. Move style and quality rules to the relevant context files.

---

### AP-10 — CLAUDE.md missing or incomplete identity statement

**Severity:** Warning (absent, workspace-description, or role without name) / Suggestion (domain describes output not person)

**Detect:** Check for these failure modes in order:

1. **No identity section** — `## Identity` heading absent, or present but empty. → Warning
2. **Workspace description substituted** — the statement describes what the workspace does rather than who Claude is and who it's helping. → Warning
3. **Missing explicit Claude identity** — statement starts with "You are helping..." without establishing who Claude IS first. Claude needs an identity to embody before it can help effectively. → Warning
4. **Role category instead of real name** — "You are an expert helping a research analyst..." — a type of person, not a specific individual. → Warning
5. **Named persona used correctly** — "You are Alex Hormozi helping Jake..." is valid and intentional. Do not flag named personas as errors.

**Fix:** The statement must follow this structure:
`"You are [Claude's identity] helping [real person's name], a [role], [purpose or context]."`

- `[Claude's identity]` — who Claude IS: an expertise ("a content creation and animation expert"), a named persona ("Alex Hormozi"), or a specific framing ("a senior research analyst"). From Group A Q3.
- `[real person's name]` — a name, not a category. From Group A Q1.
- `[role]` — what the person does. From Group A Q2.
- `[purpose or context]` — what the workspace produces, as a verb phrase. From Group A Q4.

---

### AP-11 — Workspace missing setup generation artifacts

**Severity:** Warning (`setup/session-prompts.md` absent) / Suggestion (others absent)

**Detect:**

- **`setup/session-prompts.md` absent** — the user has no copy-paste prompts for session start, end, and mid-session recovery. This is a session resilience gap. → Warning
- **`setup/skill-version.md` absent** — no record of when the workspace was generated or which skill features were active at that time. The workspace may predate key improvements: the explicit identity format, the Skills routing column, the proactive PROGRESS.md update rule, etc. → Suggestion
- **`setup/questionnaire-answers.md` absent** — no record of why the workspace was structured this way. → Suggestion

**Fix:**
- `session-prompts.md`: generate it with the three standard prompts from `skill/questionnaire.md` step 9.
- `skill-version.md`: create it manually noting the current skill build date from `SKILL.md` and which feature flags apply to this workspace's current state.
- `questionnaire-answers.md`: cannot be retroactively generated accurately; note in PROGRESS.md that it is absent if the workspace history is important to preserve.

---

### AP-12 — Recurring corrections to the same stage output

**Severity:** Warning

**Detect:** Read `session-history/*.md` files. For each file, parse the `corrections` YAML frontmatter field. Group corrections by `(stage, type)` pair. If the same `(stage, type)` combination appears in 3 or more session history files, flag it as a recurring pattern.

Example trigger: `02_script / length` appearing in session history files dated 2026-04-25, 2026-05-05, and 2026-05-12 — three consecutive runs required length corrections on the same stage.

If session-history/ does not exist or has fewer than 3 files, skip this check — insufficient history to detect meaningful patterns.

**Fix:** Examine the `description` field of the flagged corrections across the matching session files. Identify the common thread.

If the root cause isn't clear from reading the contract and reference files, use Mode 5 (Trace) before applying a fix — recurring corrections often indicate a compounding deviation across stages rather than a single missing constraint.

If the root cause is clear, apply a source-level fix:
- If the stage's `## Process` section is missing the relevant constraint → add it (Mode 3 Update)
- If the relevant Layer 3 reference file is underspecified → add the missing specificity (Mode 3 Update)

Editing the stage output fixes the current run. Fixing the contract or reference file fixes every future run.

---

## Part 2: Integrity Checks

### IC-1 — Broken stage chain

**Severity:** Critical

**Detect:** For each stage, read its `## Inputs` section. Verify that the Layer 4 path points to the actual output directory of the preceding stage — both that the path exists and that it matches stage N's `output/`.

**Fix:** Correct the Inputs path to point to the actual preceding stage output directory.

---

### IC-2 — Input paths reference files that don't exist

**Severity:** Critical (Layer 4) / Warning (Layer 3)

**Detect:** For every file path in every stage `## Inputs` section, check whether it exists in the workspace.

**Fix:** Correct paths to non-existent files. Create missing reference files if intentional. Remove Inputs entries for files no longer in use.

---

### IC-3 — Output filename mismatch between adjacent stages

**Severity:** Warning

**Detect:** For each adjacent stage pair (N and N+1): compare stage N's `## Outputs` filename against stage N+1's `## Inputs` filename for the same artifact. A path-correct but name-mismatched pair is still a broken contract.

**Fix:** Align the filename — update either the Outputs or the Inputs section so both sides of the contract agree.

---

### IC-4 — Naming convention drift

**Severity:** Warning

**Detect:** Read the Naming Conventions section in CLAUDE.md. Check files in every `output/` directory against the defined patterns. Files that don't match have drifted.

**Fix:** Either rename the drifted files to match the conventions, or update the conventions in CLAUDE.md to reflect actual usage.

---

### IC-5 — Orphaned reference files

**Severity:** Suggestion

**Detect:** List all files in every `references/` directory and `_config/`. Cross-reference against every stage `## Inputs` section. Files present in reference locations but not referenced in any Inputs section are orphaned.

**Fix:** For each orphaned file: if still relevant, add it to the appropriate stage Inputs section. If outdated, remove or archive it.

---

### IC-6 — Completed stage has empty output directory

**Severity:** Warning (if PROGRESS.md shows stage as completed) / Suggestion (if stage hasn't run yet)

**Detect:** Check PROGRESS.md for stages listed as completed. Verify their `output/` directory contains files.

**Fix:** Determine whether the stage actually ran. If output was moved or deleted, update PROGRESS.md. If the stage was marked complete prematurely, re-run it.

---

### IC-7 — Duplicate reference files across stage directories

**Severity:** Suggestion

**Detect:** Compare content of files across multiple `references/` directories. Identical or near-identical files in more than one stage's Layer 3 location are candidates for consolidation.

**Fix:** Move the shared file to `_config/`. Update all stage Inputs sections to reference the `_config/` version. Delete the per-stage copies.

---

### IC-8 — Stage skipping in the input chain

**Severity:** Warning

**Detect:** For each stage N+1, check whether its `## Inputs` Layer 4 section references stage N-1's output (skipping stage N). Flag for review — some skips are intentional, unintentional skips mean stage N's output is never used.

**Fix:** If intentional, add a comment in the Inputs section explaining why. If unintentional, correct the path to reference the correct preceding stage output.

---

### IC-9 — File system state inconsistent with PROGRESS.md

**Severity:** Warning

**Detect:** For each stage, compare two things: (1) what files exist in its `output/` directory, and (2) what PROGRESS.md records about that stage's completion status.

Two failure directions:
- **Output exists, not recorded:** A stage's `output/` contains files but PROGRESS.md does not list that stage as completed. This indicates a session was interrupted after the stage ran but before PROGRESS.md was updated.
- **Recorded complete, output missing:** PROGRESS.md lists a stage as completed but its `output/` is empty or missing the files named in its `## Outputs` contract. (Also caught by IC-6.)

**Fix:** Read the output files to assess actual completeness. If outputs look complete and correct, update PROGRESS.md to record the stage as completed. If outputs look partial — very short, contain `[TO EXPAND]` markers, or lack the structure the stage contract describes — update PROGRESS.md's "In Progress" section to accurately reflect the interrupted state.

---

### IC-10 — Stage marked complete but Outputs contract not satisfied

**Severity:** Warning

**Detect:** For each stage PROGRESS.md lists as completed:
1. Read the stage's `## Outputs` section — note each filename and its stated destination path (e.g. `topic-name_research.md → output/`)
2. Check whether each named file exists at exactly that path
3. Check whether each named file has non-zero content

Flag if:
- A named output file is absent from the stated path
- A named output file exists but is empty
- The `output/` directory contains files but none match the names the contract specifies (stage ran but produced differently-named output)

Note: IC-6 checks whether `output/` has any files. This check goes further — it verifies that the specific files the contract promises exist at the stated paths with content.

**Fix:**
- File absent or in wrong location: check whether it was saved elsewhere and move it; or if the contract path is wrong, update `## Outputs` and the following stage's `## Inputs` together
- File present but empty: the stage run did not complete; mark the stage as "In Progress" in PROGRESS.md and re-run
- File named differently: either rename to match the contract, or update `## Outputs` and the next stage's `## Inputs` to reflect the actual filename — both sides of the contract must agree
