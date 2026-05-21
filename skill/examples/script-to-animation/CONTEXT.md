# Script to Animation — Context

Last updated: 2026-05-06

---

## What we are building

A repeating pipeline that takes a content topic and produces a finished animated explainer video. Each run starts with a topic brief, moves through research and scripting, and ends with Remotion animation code ready to render. The audience is technically literate professionals who prefer clear explanations over simplified analogies.

---

## What good looks like

- A research output that identifies 3–5 angles on the topic, each with at least one concrete source or data point, structured so the script stage can build directly from it without needing to re-research
- A script that runs 90–120 seconds, matches the voice guide in `_config/voice.md`, and is structured into distinct scenes that map cleanly to animation sections
- An animation spec that accounts for every line of the script with timing, visual direction, and code that renders without manual fixes

---

## What to avoid

- Hallucinating statistics or attributing claims to sources without checking
- Scripts that exceed 130 seconds — the production stage has hard timing constraints
- Introducing new terminology in the production stage that wasn't in the script
- Skipping the human review step between stages — each stage boundary requires a check before continuing
- Treating the voice guide as optional — it is a hard constraint, not a preference

---

## Current focus

Currently in `01_research`. Starting run for "AI in education" topic.
Research brief is in `stages/01_research/output/` when ready.
