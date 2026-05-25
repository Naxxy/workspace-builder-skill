# Engineering Standards

Applies to every mode. These are the baseline behavioral rules for all workspace work.

**Tradeoff:** These guidelines bias toward caution over speed. For trivial tasks, use judgment.

---

## 1. Think Before Acting

**Don't assume. Don't hide confusion. Surface tradeoffs.**

Before taking action:
- State your assumptions explicitly. If uncertain, ask.
- If multiple interpretations exist, present them — don't pick silently.
- If a simpler approach exists, say so. Push back when warranted.
- If something is unclear, stop. Name what's confusing. Ask.

## 2. Simplicity First

**Minimum structure that achieves the goal. Nothing speculative.**

- No stages, files, or rules beyond what was asked.
- No abstractions for single-use patterns.
- No "flexibility" or "configurability" that wasn't requested.
- No checks or handling for scenarios that can't happen.
- If you build 5 stages and 2 would do, cut it.

Ask yourself: "Would an experienced practitioner say this is overcomplicated?" If yes, simplify.

## 3. Surgical Changes

**Touch only what you must. Clean up only your own mess.**

When modifying existing workspaces:
- Don't "improve" adjacent files, structure, or conventions.
- Don't reorganise things that aren't broken.
- Match existing style, even if you'd do it differently.
- If you notice unrelated issues, flag them — don't fix them.

When your changes create orphans:
- Remove routing rows, Inputs references, or config entries that YOUR changes made unused.
- Don't remove pre-existing issues unless asked.

The test: every changed file should trace directly to the user's request.

## 4. Goal-Driven Execution

**Define success criteria. Loop until verified.**

Transform tasks into verifiable outcomes:
- "Add a stage" → "Contract written, routing table updated, chain verified, Check run"
- "Fix a broken workspace" → "Identify which check fails, fix it, re-run preflight to confirm pass"
- "Update reference material" → "File updated, all stages that load it still have accurate Inputs sections"

For multi-step tasks, state a brief plan:
```
1. [Step] → verify: [check]
2. [Step] → verify: [check]
3. [Step] → verify: [check]
```

Strong success criteria enable independent execution. Weak criteria ("make it better") require constant clarification.

## 5. Safe Deletion

**Never use `rm -rf`. Delete files or directories, never both at once with a forced recursive command.**

- To delete a file: `rm path/to/file`
- To delete an empty directory: `rmdir path/to/dir`
- To delete a non-empty directory: remove its contents first, then the directory — or use `rm -r` (without `-f`) so errors surface rather than being silenced
- Never use `rm -rf` under any circumstances

Why: forced recursive deletes hide errors and have no precise target boundary. A typo or wrong working directory can silently destroy unintended files with no recovery path.

---

**These standards are working if:** fewer unnecessary changes in diffs, fewer rewrites due to overcomplication, and clarifying questions come before action rather than after mistakes.
