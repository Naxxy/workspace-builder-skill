# Stage 03 — Production

Last updated: 2026-05-01

---

## Inputs

### Layer 4 — Working artifacts (per-run)

- `../02_script/output/topic-name_script.md` — The reviewed and approved script from Stage 02. Every line of this script must appear in the animation spec. Do not drop, merge, or reorder scenes without flagging it.

### Layer 3 — Reference material (stable)

- `../../_config/voice.md` — Voice conventions. On-screen text must follow the same register as spoken content — same sentence lengths, no filler phrases.
- `references/animation-conventions.md` — Visual conventions, component library, colour palette, typography rules, and Remotion component patterns. Use the components defined here. Do not invent new component types.

---

## Process

Read all inputs before producing any output.

Produce an animation specification (`topic-name_spec.md`) that maps every scene from the script to a visual structure. For each scene, the spec must define:
- The spoken line (copied exactly from the script — do not paraphrase)
- Duration in seconds (derived from word count at 135 words per minute)
- The visual layout (which components, what text appears on screen, what appears/disappears)
- Any motion or transition specified in `references/animation-conventions.md` that applies

After completing the spec, produce the Remotion component code for each scene. Use only the components defined in `references/animation-conventions.md`. Each scene becomes one Remotion component. The components must compose into a complete video at the correct total duration.

Check that the total duration of all scenes adds up to the script's target length (90–120 seconds). If it does not, flag the discrepancy before writing the final output — do not silently adjust timings.

---

## Outputs

- `topic-name_spec.md` → `output/`
- `topic-name_remotion.tsx` → `output/`
