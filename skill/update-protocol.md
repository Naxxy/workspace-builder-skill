# Update Protocol

Used by Mode 3 (Update). Defines how to apply changes to an existing workspace while keeping it consistent with the ICM/MWP methodology.

---

## Core constraint

**Minimum viable change.** Read only what you need to understand the current structure. Touch only the files the update requires. Never refactor, reorganise, or improve things you weren't asked to change.

---

## Procedure

1. **Clarify.** If what needs to change is not explicit, ask before reading any files.
2. **Read the existing workspace.** At minimum: `CLAUDE.md` and the `CONTEXT.md` of the most relevant stage. This establishes the conventions (naming, layer structure, routing paths) already in use.
3. **Identify the minimal set of files affected.** Most updates touch 1–3 files. If you find yourself planning changes to more than 5 files, check whether the scope is correct.
4. **Propose before acting.** State exactly what you plan to change and where. Get confirmation before writing anything.
5. **Make the change.** Respect existing naming conventions and structure.
6. **Verify the full stage chain** for structural updates — any update that adds, removes, renames, or reorders a stage, or changes a stage's Outputs. Read every stage CONTEXT.md in sequence and check:
   - **IC-1:** Each stage N+1's Layer 4 Inputs path points to stage N's `output/` directory (not a stale or skipped path)
   - **IC-3:** The filename in stage N's `## Outputs` matches the filename stage N+1 expects in its `## Inputs`
   - **IC-8:** Any stage skips are intentional and explained in the Inputs section

   Check **every adjacent pair across the whole chain** — not just the pair adjacent to the change. A stage rename, insertion, or removal can silently break non-adjacent stages through cascading path dependencies. Report any failures before proceeding to step 7.

   Skip this step for non-structural updates (reference material changes, Process section edits, naming convention updates, rules changes, skills wiring).

7. **Update `PROGRESS.md`** with what changed, why, and the current active stage if it changed.
8. **Offer a Check.** Ask if they want a full audit of the affected files (read `skill/anti-patterns.md`).

---

## Common update types

The following table maps the most common update requests to the exact files they require. Use this to scope the change before starting.

| Update | Files to touch | Files to leave alone |
|--------|---------------|----------------------|
| Add a new stage | New stage folder + `CONTEXT.md`; `CLAUDE.md` routing table (add row); root `CONTEXT.md` if scope changed | All other stage files |
| Remove a stage | `CLAUDE.md` routing table (remove row); next stage's `## Inputs` (now points to previous stage); root `CONTEXT.md` if scope changed | All other stage files |
| Rename a stage | Stage folder rename; `CLAUDE.md` routing table path; any adjacent stage Inputs that reference the old name | Content of the stage CONTEXT.md (unless also updating content) |
| Change what a stage produces | That stage's `## Outputs` section; the next stage's `## Inputs` section (new filename/path) | All other files |
| Add reference material to a stage | New file in that stage's `references/`; that stage's `## Inputs` → Layer 3 section (add the reference) | Other stages unless the material is shared |
| Add shared reference material | New file in `_config/`; every stage Inputs section that should use it | Stage files that don't use this material |
| Update voice or style conventions | `_config/voice.md` or equivalent Layer 3 file | Stage contracts — they point to the file, they don't contain the content |
| Expand a stage's scope (what it does) | That stage's `## Process` section; possibly its `## Inputs` if new sources are needed | Other stage contracts |
| Tighten a stage's constraints | That stage's `## Process` section (add constraint language) | Other files |
| Update naming conventions | `CLAUDE.md` naming conventions block; optionally rename existing output files to match | Stage contracts — they reference files by name, not by the convention pattern |
| Add rules to CLAUDE.md | `CLAUDE.md` Rules block (verify under 5 rules after addition; if over, move lower-priority rules to CONTEXT.md) | Stage files |
| Fix a broken stage chain | The downstream stage's `## Inputs` Layer 4 path | The upstream stage that produced the output (its path is correct) |
| Fix naming convention drift | Rename the drifted files in `output/`; optionally update the conventions in CLAUDE.md if the drift reflects actual workflow | Stage contracts |
| Update PROGRESS.md | `PROGRESS.md` | All other files |
| Add a skill or MCP to a stage | `CLAUDE.md` routing table (Skills column for that stage); that stage's `## Process` section if it needs to reference how to use the skill; optionally new files in that stage's `references/` if the skill has configuration that belongs there | Other stage files |
| Remove a skill or MCP from a stage | `CLAUDE.md` routing table (set Skills column to `—`); that stage's `## Process` section if it referenced the skill | Other stage files; the skill's files if they are used by other stages |
| Upgrade 3-file workspace to staged structure | `stages/` directory + stage `CONTEXT.md` files; `CLAUDE.md` (add routing table + folder structure — preserve existing content); `_config/` from REFERENCES.md; `PROGRESS.md` if absent; `setup/session-prompts.md` if absent | Root `CONTEXT.md` content; existing CLAUDE.md identity and rules |

---

## Adding a new stage — detailed procedure

This is the most structurally significant update. Follow these steps in order:

1. **Determine the stage number and name.** Stage folders are numbered sequentially: `01_research`, `02_script`, `03_production`. The new stage goes in the right position. If inserting between existing stages, renumber the affected stages (and update the routing table and any Inputs references to the renumbered stages).

2. **Confirm the input/output chain.** What does this stage consume? What does it produce? Make sure the answer is consistent with what the preceding stage currently produces (check its `## Outputs` section).

3. **Create the folder structure:**
   ```
   stages/NN_name/
   ├── CONTEXT.md      ← write the stage contract
   ├── references/     ← empty unless Layer 3 material is known
   └── output/         ← empty
   ```

4. **Write the stage CONTEXT.md** using the stage contract format (Inputs / Process / Outputs). The Layer 4 Inputs path must point to the preceding stage's `output/` directory.

5. **Update CLAUDE.md routing table** — add one row for this stage.

6. **Check whether the next stage's Inputs section needs updating.** If there was a stage after the insertion point, its Layer 4 Inputs may now need to point to the new stage's output instead of the previous stage's output.

7. **Update root CONTEXT.md** if the addition changes the scope or purpose of the workspace.

---

## Removing a stage — detailed procedure

1. **Check what depends on this stage.** Read the next stage's `## Inputs` Layer 4 section. If it points to the stage being removed, it will need updating.

2. **Update the next stage's Inputs** to point to the previous stage's `output/` (skipping the removed stage).

3. **Remove the routing table row** from `CLAUDE.md`.

4. **Archive the stage folder** (rename to `_archived/NN_name/`) rather than deleting it unless the user explicitly asks to delete. Removed stages often contain useful reference material.

5. **Update root CONTEXT.md** if the removal changes the workspace scope.

---

## Upgrading a 3-file workspace to staged structure — detailed procedure

**Pre-condition:** `CLAUDE.md` and `CONTEXT.md` exist at the workspace root, but there is no `stages/` directory. This workspace uses the basic Foundation-course structure. This procedure adds the full ICM 5-layer structure around the existing content without replacing it.

1. **Read the existing files.** Read `CLAUDE.md`, `CONTEXT.md`, and `REFERENCES.md` (if present). Build a working understanding of the domain, the work, and what reference material exists.

2. **Identify the stages using an abbreviated Group B interview.** Use what CONTEXT.md describes as a starting point — "Your CONTEXT.md describes [summary]. What are the main stages this breaks into?" — rather than starting from scratch. Get input/output for each stage. Apply the same stage count guidance as Setup: 2–3 stages to start, 5 maximum.

3. **Propose the structure before creating anything.** State the proposed stage names and the REFERENCES.md migration plan. Get confirmation.

4. **Create the `stages/` directory** with numbered folders for each confirmed stage.

5. **Write each stage `CONTEXT.md`** with Inputs / Process / Outputs. Use the CONTEXT.md descriptions and Group B answers to fill the Process sections.

6. **Migrate `REFERENCES.md`:**
   - Move all content to `_config/references.md` as a starting point.
   - If any content is clearly stage-specific (identified in step 2), split it into the relevant stage `references/` file.
   - Archive the original: rename `REFERENCES.md` to `_archived/REFERENCES-original.md`. Do not delete it.

7. **Update `CLAUDE.md` — add only what's missing, never overwrite existing content:**
   - Add `## Folder Structure` block listing the stages and `_config/`
   - Add `## Routing` table (one row per stage)
   - Add `## Naming Conventions` if not already present
   - Preserve the existing identity block, rules, and any other content already there

8. **Update root `CONTEXT.md` — minimal changes only:**
   - Add a "Last updated" marker if absent
   - Add a "Current focus" or "Active stage" line if absent
   - Do not rewrite content that is already accurate

9. **Generate `PROGRESS.md`** at root if not present.

10. **Generate `setup/session-prompts.md`** if not present (same content as Setup generates).

11. **Generate `setup/skill-version.md`** if not present — use the Skill build date from `SKILL.md` and the current feature flags (see questionnaire.md step 10 for the format).

12. Run a full Check (read `skill/anti-patterns.md`) on the upgraded workspace.

---

## Constraints that apply to every update

**Never modify Layer 3 files as part of a pipeline run.** Reference files (`references/`, `_config/`) are configuration, not artifacts. If a pipeline run produces something that belongs in a reference file, flag it for the user to decide whether to update the factory configuration — don't update it automatically.

**Never change stage numbering without updating all references.** If you renumber stages, update the routing table, all adjacent stage Inputs paths, and PROGRESS.md references in one operation. Partial renumbering creates broken chains.

**Respect existing naming conventions.** If CLAUDE.md defines a naming pattern for output files, new files created as part of an update must follow it. Do not introduce new naming patterns without updating the conventions block.

**Stage contracts define the interface.** When updating one stage's Outputs, always check the next stage's Inputs in the same operation. These are coupled — one side of a contract cannot change without the other.

---

## After completing an update

Update `PROGRESS.md` — include what the current active stage is if it changed.
