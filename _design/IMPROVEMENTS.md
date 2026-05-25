# Suggested Improvements

Open improvements to the workspace-builder skill, grouped by scope. Completed items are in `CHANGELOG.md`.

---

## Priority 3 — More ambitious, requires new infrastructure

### 3.2 ✓ applied 2026-05-08

---

## Edge cases and known gaps

Issues identified during consistency review that don't yet have a corresponding improvement or fix.

### E1: skill-version.md flags are static, not inspected

The feature flags in `setup/skill-version.md` record what the skill generated at creation time. They are NOT a current-state check — if the user later manually adds session-prompts.md or updates their CLAUDE.md identity format, the version file won't reflect it. The VR checks in preflight.sh independently inspect the actual files, which is the reliable mechanism. The version file is provenance only.

**Implication:** Don't rely on skill-version.md to determine current workspace state. Use preflight.sh VR checks for that. The version file answers "when was this made and what was available then," not "does this workspace currently have all features."

### E2 ✓ applied 2026-05-25

### E3: Duplication path doesn't inspect source workspace's skill-version.md

When duplicating a workspace, the skill reads CLAUDE.md, CONTEXT.md, stage contracts, etc. — but doesn't check the source workspace's `setup/skill-version.md`. If the source was generated before key improvements, the duplicate inherits those gaps silently.

**Improvement idea:** In the duplication path Step 1, check whether the source workspace has a skill-version.md. If it does, compare its feature flags against the current skill's capabilities. Surface any gaps to the user before confirming the duplication — so the adapted workspace gets the new features, not just the inherited structure.

### E4 ✓ applied 2026-05-08

### E5: session-prompts.md content duplicated in two places *(was three — session history now in template)*

The exact session prompts content appears in: (1) questionnaire.md step 9 as the canonical template, (2) the PROGRESS.md.template comment, (3) all generated/example session-prompts.md files. If the prompts need updating (e.g., when reconcile-progress.sh path changes), all three must be updated manually.

**Improvement idea:** Create `skill/templates/session-prompts.md.template` as the single source of truth. Setup generates from it. PROGRESS.md.template comment references it. Currently the duplication is manageable, but will become a maintenance burden if the prompts change frequently.

### E6: preflight.sh doesn't check for `setup/` directory itself

The VR checks (VR-1 through VR-3) check for individual files but not whether `setup/` exists as a directory. On a workspace that has `setup/` but with different contents, the file checks handle it correctly. But if someone manually created a workspace without a `setup/` directory at all, the file-not-found checks would report the same warnings as missing files. Not harmful, but slightly imprecise.

### E7: L0-6 (AP-3) absent from preflight.sh — not automated and not deferred

**Check:** L0-6 — "Every stage folder in the workspace has at least one corresponding row in the routing table" — mapped to AP-3 in `skill/review-checklist.md`.

**The gap:** This check exists in `skill/review-checklist.md` (Mode 2 / Review) but is absent from `skill/tools/preflight.sh` entirely — it appears neither in the automated check functions nor in the `Deferred to Claude` heredoc at the end of the script. This means it is silently skipped in Mode 4 (Check), even though it is mechanically verifiable.

**What the check does:** Cross-references the routing table rows in `CLAUDE.md` against the actual `stages/` subdirectory names. Detects two failure modes: (1) a stage folder exists with no routing row — the orchestrator can't find it; (2) a routing row points to a folder that doesn't exist — a dead route.

**How to fix:** In `preflight.sh`, add a function (e.g. `check_routing_coverage`) that: (a) extracts stage folder names from `stages/` directory listing, (b) reads the routing table rows from `CLAUDE.md`, (c) cross-references both directions, (d) emits `FAIL [L0-6]` for any stage folder with no routing row, and `FAIL [L0-6]` for any routing row pointing to a non-existent folder. Wire it into `main()` after `check_claude_md`. Use the same `pass/fail/warn/note` helper functions already in the script. Follow `skill/tools/bash-style.md` conventions throughout.

**Files to change:** `skill/tools/preflight.sh` only. No changes to review-checklist.md or anti-patterns.md — the check is already correctly defined there.

### E8: L1-6 (AP-1) absent from preflight.sh — not automated and not deferred

**Check:** L1-6 — "File is one page or less" (applied to root `CONTEXT.md`) — mapped to AP-1 in `skill/review-checklist.md`.

**The gap:** Same class of issue as E7. L1-6 exists in `skill/review-checklist.md` but is absent from `skill/tools/preflight.sh` — neither automated nor in the deferred list. AP-1 (CLAUDE.md > 50 lines) is in preflight but the equivalent check for CONTEXT.md length is not.

**What the check does:** Flags root `CONTEXT.md` files that have grown beyond one page (~50 lines is the working threshold used for CLAUDE.md in AP-1/L0-2; apply the same). A CONTEXT.md that has grown to multiple pages has accumulated project-brief content that belongs elsewhere, degrading Layer 1's role as a concise routing layer.

**How to fix:** In `preflight.sh`, inside the existing `check_context_md` function (which already checks that CONTEXT.md exists and is readable), add a line-count check: if `wc -l < CONTEXT.md` exceeds the threshold (suggest 60 lines, giving more headroom than CLAUDE.md's 50 given CONTEXT.md's broader scope), emit `warn 'L1-6' "CONTEXT.md exceeds one page — check for project detail that belongs in stage files (AP-1)"`. No new function needed — it slots directly into the existing function.

**Files to change:** `skill/tools/preflight.sh` only. No changes to review-checklist.md or anti-patterns.md.

---

## Future investigation

Questions and context for future evolution of the skill — not yet actionable but worth tracking.

### F1: Cross-model compatibility

The ICM paper (Section 4.1) states MWP is model-agnostic: "A workspace built for Claude could be run with a different model by pointing that model at the same files." All skill content, examples, and tooling are currently Claude-specific (references to `CLAUDE.md`, Claude Code tooling, Anthropic subscription requirements, Remotion/animation terminology in the script-to-animation example). A genuine cross-model test has not been done.

**Questions:** Does the 5-layer hierarchy produce equivalent behaviour in GPT-4, Gemini, or open-weight models? Does the identity format ("You are [persona] helping [name]...") work the same way? Does the routing table concept translate? This would be high-value research for the course material if the answer is broadly yes.

### F2: PROGRESS.md as a structured data source

Currently PROGRESS.md is free text, which makes machine-readable parsing fragile (the reconcile-progress.sh IC-9 check uses a heuristic grep). As the skill adds more tooling that reads PROGRESS.md (reconcile-progress, audit-all for last session date), there may be value in defining a lightweight structured format — YAML front matter or a fixed section schema — that tools can parse reliably.

**Tradeoff:** Structured format reduces editability and increases the chance of invalid syntax. The current free-text format is part of what makes it easy to update mid-session. Any structured approach needs to preserve that.

### F3: Stage contract as a test specification

The stage contract's `## Outputs` section describes what a stage should produce. This is functionally a specification. IC-10 uses it to verify contract satisfaction. The natural extension is using it as a test: given a run's output, does it satisfy the contract's intent — not just that the file exists, but that it contains what was specified?

This connects to the recurring pattern detection idea (3.2) and the provenance tracking (3.1). A stage contract that says "produce 3–5 distinct angles" could be checked mechanically (count heading-level sections). This opens the door to lightweight automated quality assessment — not semantic grading, but structural conformance checking.

### F4: Workspace-level skill as a meta-ICM pattern

The workspace-builder skill is itself structured as a workspace: SKILL.md at Layer 0, mode behaviour files at Layer 2, templates and examples at Layer 3, tools as executables. This is the ICM pattern applied to the skill itself. This meta-level consistency is worth noting for teaching purposes — demonstrating that the methodology is self-applicable.

A natural extension: use the skill to build workspaces for building skills. The "duplication" mode is almost this — take an existing skill structure and adapt it for a different domain. There may be a generalized "skill builder" pattern here worth exploring.

### F5: Tension between minimal-first and growing setup complexity

The design principle "minimal first — build 2–3 stages, start using it" is in tension with a questionnaire that now has: 5 Group A questions, 4 Group B questions, 6 Group C questions, 3 Group D questions = 18 questions total before the user sees any workspace. The interview is conversational and follow-up-based, which helps, but the cognitive overhead before first use has grown.

**Question:** Is there a "quick start" path that generates a minimal workspace from fewer answers (name, identity, 2–3 stage names, basic naming convention) and defers the reference material configuration to later? This would honour minimal-first more faithfully while still getting the structure right.

---

## Out of scope

Known limitations of the underlying ICM methodology — the skill should not attempt to solve these.

- **Real-time multi-agent coordination** — MWP is sequential by design. Concurrent execution requires a framework.
- **Automated branching between stages** — Human review gates are a feature, not a limitation. Automated branching pushes toward framework territory.
- **High-concurrency or multi-user workspaces** — MWP is local-first. Concurrent users require infrastructure the skill is designed to avoid.
