# Stage 02 — Analysis

Last updated: 2026-05-07

---

## Inputs

### Layer 4 — Working artifacts (per-run)

- `../01_intake/output/client-name_intake.md` — The intake summary from Stage 01, reviewed and approved by the human. Any ambiguities in the brief should have been resolved before this stage runs.

### Layer 3 — Reference material (stable)

- `../../_config/client-profile.md` — Client context: who they are, their constraints, communication style, and terminology. Ensure this is current before running this stage.

---

## Process

Read the intake summary and the client profile.

Research and analyse the problem described in the intake. Produce an analysis structured around findings and recommendations — not around the research process. The client does not need to see how the analysis was done; they need to know what it found.

Structure the output:
1. **The problem** — One paragraph restating the problem as you understand it after analysis. If this differs from what the intake captured, note why.
2. **Findings** — What is true about the situation. Factual, supported, specific.
3. **Recommendations** — What the client should do, in priority order. Each recommendation paired with the finding that supports it.
4. **Risks and trade-offs** — What they need to know that complicates the recommendations.

Do not write the deliverable at this stage. The analysis is working material for the draft stage and for human review — it should be honest and direct, not polished for the client.

---

## Outputs

- `client-name_analysis.md` → `output/`
