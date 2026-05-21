# Questionnaire Answers

Completed: 2026-04-15
Workspace built with: workspace-builder skill

---

## Group A — Identity

**Name:** David McDermott
**Role:** Research analyst producing literature reviews for policy and strategy teams
**Claude identity:** A senior research analyst and synthesis expert
**Workspace purpose:** Automate the repeating pipeline from research question → structured synthesis, while preserving human review points at each stage so the quality of sourcing and argument can be verified
**Workspace name:** research-synthesis

---

## Group B — Workflow mapping

**Stages identified:** 4

**Stage 1 — Collect**
- Input: A research question with any scope notes or known sources
- Output: An annotated source list — each source summarised with key claims and reliability notes
- Human review: Remove out-of-scope sources; flag any gaps before extraction begins

**Stage 2 — Extract**
- Input: The reviewed source collection
- Output: Material re-organised by theme and claim rather than by source
- Human review: Verify that the thematic organisation is accurate; correct any misattributed claims

**Stage 3 — Synthesise**
- Input: The reviewed extraction
- Output: A synthesis that answers the research question — convergences, divergences, gaps, implications
- Human review: Verify the argument; check that the conclusion is warranted by the evidence; edit before the report stage sees it

**Stage 4 — Report**
- Input: The reviewed synthesis
- Output: The final document following the required structure
- Human review: Final quality check before delivery

**Over-splitting check:** Extract and synthesise were initially considered as one stage. Separated because they require different mental operations (re-organisation vs argument construction) and because errors in the extraction — misattributed claims, missed themes — are much cheaper to fix before the synthesis is written than after.

---

## Group C — Reference material

**Voice/style:** Yes. Precise and evidence-linked. Qualified proportionally to the strength of evidence. Readable without being casual. Stored in `_config/voice.md` — applies to all stages that produce written output.

**Structural conventions:** Yes. The final report must follow a defined section structure (research question → summary → convergence → divergence → gaps → implications → sources) with specific length guidance per section. Stored in `stages/04_report/references/report-structure.md` — specific to Stage 04.

**Domain knowledge:** No standing domain knowledge file. The research question defines the domain per run.

**Shared reference material:** Voice guide applies to Stages 03 and 04. Stored in `_config/`.

---

## Group D — Rules and naming conventions

**Always:** Never assert a claim that can't be traced to a source from the collection stage.
**Never:** Modify reference files during a pipeline run.

**Naming conventions:**
- Source collections: `topic_sources.md`
- Extraction outputs: `topic_extracts.md`
- Synthesis outputs: `topic_synthesis.md`
- Report drafts: `topic_report.md`
