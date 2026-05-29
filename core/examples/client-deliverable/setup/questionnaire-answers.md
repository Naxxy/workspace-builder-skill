# Questionnaire Answers

Completed: 2026-04-01
Workspace built with: workspace-builder skill

---

## Group A — Identity

**Name:** Jake Van Clief
**Role:** Independent consultant producing client deliverables across strategy, operations, and research engagements
**Claude identity:** A senior management consultant
**Workspace purpose:** Structure the repeating pipeline from client brief to finished deliverable, with human review at each stage boundary so the problem framing and analysis can be corrected before the writing begins
**Workspace name:** client-deliverable

---

## Group B — Workflow mapping

**Stages identified:** 3

**Stage 1 — Intake**
- Input: Client brief, scoping notes, or initial request (raw or structured)
- Output: Structured intake summary: who the client is, what they asked for, what they actually need, success criteria, constraints
- Human review: Confirm the problem framing is correct; resolve ambiguities before analysis begins — this is the cheapest point to course-correct

**Stage 2 — Analysis**
- Input: The reviewed intake summary + client profile
- Output: Internal working document: situation, findings, recommendations, risks
- Human review: Verify findings are sound; check that recommendations follow from findings; edit before the draft stage sees it — analysis errors are expensive to fix in the draft

**Stage 3 — Draft**
- Input: The reviewed analysis + voice guide + client profile + deliverable format
- Output: Client-facing deliverable document
- Human review: Final quality check — tone, structure, client-appropriateness — before delivery

**Over-splitting check:** Considered separating "research" from "analysis" as distinct stages. Decided against it — research and analysis happen in the same mental mode and separating them adds a handoff without adding a meaningful review gate.

---

## Group C — Reference material

**Voice/style:** Yes. Direct, professional, client-facing register. Recommendations lead; methodology follows. Stored in `_config/voice.md` — applies to Stage 03.

**Structural conventions:** Yes. Advisory report format with defined sections and length guidance. Stored in `stages/03_draft/references/deliverable-format.md` — updated per engagement type if needed.

**Domain knowledge:** No standing domain knowledge. The client profile fills this role per engagement — it captures client-specific terminology and context.

**Shared reference material:** Client profile applies to both Stage 02 (analysis needs client context) and Stage 03 (draft needs client terminology and format preferences). Stored in `_config/client-profile.md`.

---

## Group D — Rules and naming conventions

**Always:** Update `_config/client-profile.md` between engagements, not during a run.
**Never:** Introduce findings or recommendations in the draft stage that weren't in the analysis.

**Naming conventions:**
- Intake summaries: `client-name_intake.md`
- Analysis outputs: `client-name_analysis.md`
- Deliverable drafts: `client-name_deliverable.md`
