# Questionnaire Answers

Completed: 2026-04-18
Workspace built with: workspace-builder skill

---

## Group A — Identity

**Name:** Jake Van Clief
**Role:** Content creator / educator producing animated explainer videos
**Claude identity:** A content creation and animation expert
**Workspace purpose:** Automate the repeating pipeline from topic → animated video, while keeping a human review point at each stage so quality stays consistent across runs
**Workspace name:** script-to-animation

---

## Group B — Workflow mapping

**Stages identified:** 3

**Stage 1 — Research**
- Input: A topic brief (what to cover, any sources to include, any angles to consider)
- Output: A structured research document with 3–5 angles, each with supporting evidence
- Human review: Choose which angle to develop; trim or edit the research document before handing to script stage

**Stage 2 — Script**
- Input: The reviewed research document from Stage 1
- Output: A 90–120 second script in the required scene structure
- Human review: Check timing, voice conformance, and whether the explanation is accurate; edit before handing to production

**Stage 3 — Production**
- Input: The reviewed script from Stage 2
- Output: An animation spec and Remotion component code
- Human review: Check timing totals, component usage, and whether the visual structure matches the script intent; approve or send back for revision

**Stage boundary decisions confirmed:** Yes — all three stages require human review before the next stage runs. This is a deliberate choice: the output of each stage is the most expensive thing to fix in the next stage if wrong.

**Over-splitting check:** Research and scripting were considered as one stage initially. Decided to split because they require different reference material (no voice guide needed for research; both voice and structure needed for scripting) and different human judgments at the boundary (choose angle vs approve quality).

---

## Group C — Reference material

**Voice guide:** Yes. Direct, technically literate register. No filler. Sentence-length constraints. Detailed in `_config/voice.md` — applies to scripting and production stages.

**Structural conventions:** Yes. Four-scene structure (Hook / Setup / Explanation / Close) with timing targets. Stored in `stages/02_script/references/script-structure.md` — specific to the script stage.

**Visual/design conventions:** Yes. Remotion component library, colour palette, typography. Stored in `stages/03_production/references/animation-conventions.md` — specific to the production stage.

**Shared reference material:** Voice guide applies to both Stage 02 and Stage 03 (on-screen text must match spoken register). Stored in `_config/` for that reason.

**Stage-specific reference material:** Script structure is only relevant to Stage 02. Animation conventions are only relevant to Stage 03. Stored in each stage's own `references/` folder.

---

## Group D — Rules and naming conventions

**Always:**
- Read CLAUDE.md and the active stage CONTEXT.md before starting any task
- Ask before crossing a stage boundary

**Never:**
- Modify files in `references/` or `_config/` during a pipeline run
- Create files outside the active stage's `output/` directory without asking

**Naming conventions:**
- Research outputs: `topic-name_research.md`
- Script drafts: `topic-name_script.md`
- Animation specs: `topic-name_spec.md`
- Remotion files: `topic-name_remotion.tsx`
