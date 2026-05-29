# Stage 02 — Script

Last updated: 2026-05-01

---

## Inputs

### Layer 4 — Working artifacts (per-run)

- `../01_research/output/topic-name_research.md` — The research document from Stage 01, reviewed and edited by the human. The chosen angle will be marked or the document will have been trimmed to the selected angle. Build the script from what is here — do not re-research or add material the research document does not contain.

### Layer 3 — Reference material (stable)

- `../../_config/voice.md` — Voice, tone, sentence-length conventions, and what to avoid. These are hard constraints. The script must conform to every convention in this file.
- `references/script-structure.md` — Required scene structure, timing targets per scene, and formatting conventions for the script file.

---

## Process

Read the research document and the two reference files before writing anything.

Write a script for the topic. The script must:
- Follow the scene structure defined in `references/script-structure.md` exactly
- Conform to the voice conventions in `_config/voice.md` — every sentence
- Run 90–120 seconds when read aloud at a normal speaking pace (roughly 135–180 words)
- Be structured so each scene maps to a discrete visual moment — the production stage must be able to read any scene and know exactly what should be on screen

Do not introduce claims, data, or examples that are not in the research document. The script translates the research — it does not add to it.

If the research document contains unverified claims marked by the research stage, do not include them in the script. Flag their absence in a comment at the bottom of the script file so the human reviewer knows what was excluded and why.

---

## Outputs

- `topic-name_script.md` → `output/`
