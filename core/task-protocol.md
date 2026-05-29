# Task Protocol

The procedure for writing, applying, and closing workspace change tasks. Referenced from Engineering Standard 7.

Tasks decouple *identifying* changes from *applying* them. A session can end with a full task backlog and no edits made — the next session (or a coordinator agent) picks up the tasks and applies them with no loss of context.

---

## Task file location

`setup/TASKS.md` at the workspace root. If the workspace has no `setup/` directory, use `TASKS.md` at the root.

---

## Task format

Each task is a level-2 heading followed by structured fields and a self-contained description.

```markdown
## TASK-NNN — Title [Priority]

**Added:** YYYY-MM-DD
**Size:** small | medium | large
**Parallel-safe:** yes | no | depends on TASK-NNN
**Files to read:** comma-separated list
**Files to edit:** comma-separated list
**Success criterion:** <a concrete, verifiable check — something you can confirm without judgment>

### What to do

[Self-contained instructions. An agent with zero session history must be able to read
this block alone and execute the task correctly. Do not assume knowledge of prior
conversation. Include specific file paths, exact text to change, and the reason.]

### Changelog entry

[Write this verbatim into CHANGELOG.md when the task is done. Fill in the date.]

- [What changed and why, in the CHANGELOG entry format]
```

### Size guide

| Size | Scope | Agent guidance |
|------|-------|----------------|
| `small` | Single file edit, mechanical change | Primary agent does it directly — sub-agent overhead exceeds the work |
| `medium` | 2–5 files, requires reading context first | Primary agent by default; sub-agent acceptable if the primary context is already large |
| `large` | Multi-file, structural, or requires deep document reading | Consider sub-agent; consider git worktree if running in parallel with other tasks |

### Parallel-safe guide

A task is `parallel-safe: yes` if it edits files that no other pending task touches.
A task is `parallel-safe: no` if it must complete before another task can run (e.g. Task B reads the output of Task A).
A task is `parallel-safe: depends on TASK-NNN` if it can run in parallel with everything except the named task.

---

## Coordinator agent procedure

A coordinator agent — or a primary agent with no other active work — reads `setup/TASKS.md` and applies tasks using this procedure.

### Step 1: Read and classify

Read every pending task. For each, record:
- Size
- Parallel-safe status and dependency chain
- Which files it edits

### Step 2: Build an execution plan

Group tasks into waves:
- **Wave 1:** All tasks with no dependencies and `parallel-safe: yes` — these can run simultaneously
- **Wave 2:** Tasks that depend only on Wave 1 completions
- Continue until all tasks are placed

Within each wave, decide per task: direct execution (small/medium) or sub-agent (large, or medium when primary context is already large).

State the plan before executing. Example:

```
Wave 1 (parallel):
  TASK-001 [small] — direct
  TASK-003 [large] — sub-agent, worktree: task-003

Wave 2 (after Wave 1):
  TASK-002 [medium] — direct (depends on TASK-001)
```

### Step 3: Execute

For each task in the current wave:

**Direct execution:**
1. Read the files listed in "Files to read"
2. Apply the change described in "What to do"
3. Verify the success criterion
4. Write the changelog entry into `CHANGELOG.md`
5. Remove the task block from `setup/TASKS.md`
6. Commit: task changes + CHANGELOG.md update + TASKS.md removal in one commit

**Sub-agent execution:**
1. Create a git worktree if the task is large or if running in parallel: `git worktree add ../<workspace-name>-task-NNN -b task-NNN`
2. Spawn the sub-agent against the worktree path, passing the full task block as context
3. When the sub-agent returns, verify the success criterion against the worktree
4. If verified: merge the branch, write the changelog entry, remove the task from `setup/TASKS.md`, commit
5. If not verified: do not merge; re-run or escalate
6. Remove the worktree: `git worktree remove ../<workspace-name>-task-NNN`

### Step 4: Close each task

A task is closed when all four conditions are met:
1. **Success criterion verified** — run the check described in the task
2. **Changelog updated** — the changelog entry from the task block is written into `CHANGELOG.md`
3. **Task removed from TASKS.md** — the task block is deleted (not commented out, not marked "done" and left in place)
4. **Changes committed** — per the commit standards in Engineering Standard 6

Do not close a task if the success criterion has not been checked. Do not leave completed tasks in `TASKS.md` — the file should only contain pending work.

---

## Writing tasks (for the agent proposing changes)

When you identify a change that should be made but not applied immediately:

1. Write it as a task using the format above
2. Make the task self-contained — include all context needed to execute it cold
3. Set `parallel-safe` honestly — if unsure, set `no`
4. Write the success criterion as something checkable: a file path that exists, a line count, a grep match, a preflight result. Not "looks correct" or "feels right"
5. Pre-write the changelog entry — this removes ambiguity about how the change should be described when it's done
6. Commit the addition to `TASKS.md` separately from any other work in the session

### What makes a good success criterion

Good: `bash skills/workspace-builder/core/tools/preflight.sh . | grep "L0-2"` returns `PASS`
Good: `wc -l CLAUDE.md` returns a number ≤ 50
Good: file `stages/02_server-infra/references/new-file.md` exists and is non-empty
Good: `git log --oneline -1` shows the expected commit subject

Bad: "the file looks correct"
Bad: "CLAUDE.md is shorter"
Bad: "the workspace feels cleaner"

---

## Sub-agent context block

When spawning a sub-agent to execute a task, pass this context alongside the task block:

```
Workspace root: <absolute path>
Working branch / worktree: <branch name>
Task to execute: <paste full TASK-NNN block>

Instructions:
1. Read the files listed in "Files to read" before making any changes.
2. Apply exactly the change described in "What to do". Do not make other improvements.
3. Verify the success criterion. Report the result.
4. Do not update CHANGELOG.md or TASKS.md — the coordinator handles those.
5. Do not commit — the coordinator handles that too.
6. Report back: success criterion result, files changed, any blockers.
```

The coordinator, not the sub-agent, owns the changelog update, TASKS.md removal, and commit. This keeps the audit trail centralised.

---

## When NOT to use sub-agents

- The task is `small` — the overhead of spawning, briefing, and relaying exceeds the work itself
- The task requires iterative judgment or depends on accumulated session context (e.g. "review this output and decide what to fix") — sub-agents start cold
- The workspace has fewer than 3 pending tasks — just do them directly
- The tasks are sequential with tight dependencies — parallelism adds coordination cost with no time benefit
