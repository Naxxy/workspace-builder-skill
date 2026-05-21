# Trace Protocol

Used by Mode 5 (Trace). Walks backwards through the stage chain to find where a
specific problem in a stage's output originated — the equivalent of a stack trace
for a content pipeline.

---

## When to use Trace

Use when a specific quality problem exists in a stage's output and the source is
unclear. The goal is to find the earliest stage where the output diverged from
intent, and to classify whether the root cause is a contract problem, a reference
material problem, or a propagated input problem.

Do not use for general workspace health checks (Mode 2 — Review) or structural
validation (Mode 4 — Check). Trace is for diagnosing a known content problem,
not for discovering whether structural problems exist.

---

## Step 1 — Define the problem precisely

Ask: "What specifically is wrong? Can you quote or describe the exact issue?"

Get specifics before reading any files. "It sounds generic" is a starting point.
"The opening paragraph restates the topic instead of stating the finding" is what
you need to trace. Vague problems produce vague diagnoses.

Also establish: which stage's output file contains the problem?

---

## Step 2 — Read the problem stage

Read in this order:
1. The problem stage's output file(s) — confirm the problem is present and
   understand exactly what form it takes
2. The stage's `CONTEXT.md` — what did the contract say this stage should do?

Note the gap: where does the output deviate from what the contract describes?

If the output violates the contract explicitly — e.g. the contract says "state the
finding in the first paragraph" and the output doesn't — the problem was produced
at this stage. If the output is consistent with the contract, the contract is the
problem (it permitted or encouraged the bad output).

---

## Step 3 — Check the Layer 3 reference files for this stage

Read each file listed in the stage's `## Inputs` Layer 3 section.

For each reference file, ask: is this instruction specific enough to have prevented
the problem? Reference files are constraints. If the voice guide says "be direct"
without specifying what directness looks like for this domain, Claude will fill the
gap with a generic interpretation. That is a Layer 3 problem — the constraint
exists but is underspecified.

---

## Step 4 — Walk backwards through the chain

For each preceding stage, working backwards from N-1 toward stage 1:

1. Read that stage's output file(s)
2. Ask: does the problem appear in this output too?

| Finding | Interpretation |
|---------|---------------|
| Problem present in preceding output | The problem originated here or earlier — continue backwards |
| Problem absent in preceding output | The problem was introduced at the stage you just came from — stop here |

Stop when you find the earliest stage where the problem first appears. That is the
origin point.

---

## Step 5 — Classify the root cause

Once you have identified the earliest stage where the output diverged, classify
the cause:

**A — Contract problem**
The stage's `## Process` section is too vague, missing a constraint, or actively
allowed the bad output. The output is consistent with the contract — the contract
is wrong.
→ Fix: update that stage's `## Process` section with the missing or corrected
constraint. This fix applies to every future run of that stage.

**B — Reference material problem**
The contract is correct, but a Layer 3 file it points to has a gap or ambiguity.
Claude followed the reference faithfully — the reference was inadequate.
→ Fix: update the relevant `_config/` or `references/` file. Because Layer 3 is
shared across runs, this fix propagates automatically.

**C — Input problem**
The stage processed its input correctly according to its contract, but the input
itself contained the problem. Apply this analysis recursively to the preceding
stage — the trace continues backwards.

**D — Compounding deviation**
No single stage introduced the full problem. Small deviations at two or more
stages compounded. The output at each stage was plausible given its input, but
the cumulative effect is wrong.
→ Fix: identify the earliest deviation, correct it at the source, and re-run from
that stage forward. Correcting only the final stage fixes this run; correcting the
source fixes all future runs.

---

## Step 6 — Report the diagnosis

State clearly:

1. **Origin stage** — the earliest stage where the problem appeared in the output
2. **Root cause** — which classification (A, B, C, or D) and why
3. **Specific fix** — exactly which file to change and what to change in it
4. **Re-run scope** — which stages need to be re-run after the fix

The fix should be specific enough to act on immediately. "The voice guide's
instruction to 'be direct' is underspecified — add a sentence clarifying that
directness means stating the finding before any supporting evidence" is actionable.
"The voice guide may need updating" is not.

---

## After the diagnosis

Offer to hand off to Mode 3 (read `skill/update-protocol.md`) to apply the fix.

If the fix is to a Layer 3 reference file, note that it will affect all future
pipeline runs — which is usually the intended outcome of a source-level fix.

If the fix is to a stage contract, note which stages need to be re-run and in what
order after the change is applied.
