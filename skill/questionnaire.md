# Setup Questionnaire

Used by Mode 1 (Setup). This defines the interview Claude runs with the user before generating a workspace.

---

## How to run this interview

**Before starting Group A, ask one question:** "Are you building this workspace from scratch, or adapting an existing workspace you already have?"
- **From scratch** → proceed with Groups A through D below.
- **Adapting an existing workspace** → skip to the Duplication path section at the end of this file.

Ask follow-up questions within each group before moving to the next. Group B is the most important — stage structure is the hardest thing to get right and the most expensive to change later. Do not generate anything until the user confirms the summary at the end.

---

## Group A — Identity

**Purpose:** Establish who this workspace is for and what it's called.

Questions:
1. What is your name?
2. What is your role or what kind of work do you do?
3. Who should Claude be in this workspace? This is Claude's explicit identity — the expertise, voice, or persona it embodies when working with you.
   - Examples: "a senior content strategist", "a research scientist specialising in neuroscience", "a management consultant"
   - Or a named expert persona whose thinking and communication style you want: "Alex Hormozi", "Cal Newport", "Richard Feynman"
   - **If the user is unsure**, don't wait for them to figure it out. Derive a suggestion from Q2 immediately: "Based on your role as [Q2 answer], Claude could be *a senior [domain] expert*. Does that feel right, or is there a specific voice you'd prefer?" Then let them accept, tweak, or replace it.
4. What is this workspace for — what problem does it solve or what work does it support?
5. What should the workspace folder be called? (Suggest a name based on Q4 if they're unsure.)

**What to listen for:**
- The domain (research, content production, client work, development, etc.)
- Whether the workspace is for solo use or shared with others
- The scale — a one-off project or a repeating workflow
- For Q3: whether the user wants expertise-style identity ("a senior X") or a named persona — both are valid. If they hesitate, offer a concrete suggestion derived from Q2 and ask them to confirm or adjust rather than leaving them with an open question.

---

## Group B — Workflow mapping

**Purpose:** Identify the stages. This is the core of the workspace. Get this right.

Questions:
1. Walk me through how this work gets done from start to finish. What are the main steps?
2. At what points do you stop, review what was produced, and make a decision before continuing?
   *(Each decision point is a stage boundary.)*
3. For each stage you've described:
   - What does it receive as input? Where does that input come from?
   - What does it produce as output? What does that output look like?
   - What does the human review or change at the end of this stage before the next one starts?
4. Are any of the steps you described actually the same kind of thinking at different points? For example: "writing a rough draft" and "polishing the draft" — is that one stage with two sub-steps, or genuinely two different modes of work?

**What to listen for:**
- Natural breakpoints where the *type* of work changes (research vs writing vs production)
- Review gates where a human must make a judgment call
- The input/output chain — what stage N produces must be what stage N+1 consumes
- Signs of over-splitting: two stages that do the same kind of work and would have identical Process instructions

**Follow-up prompts if the user is unsure:**
- "If you had to explain what you're doing at each point to a new person, would the explanation be substantially different?" (If yes, different stages. If no, same stage.)
- "If something went wrong at this point and you had to redo it, would you redo just this step or the whole thing?" (Redo just this step = stage boundary.)
- "Do you ever skip straight from step X to step Z without doing Y?" (If yes, Y might not be a real stage boundary.)

**Stage count guidance:**
- 2–3 stages is right for most new workspaces
- 4 stages is reasonable for complex workflows
- 5 is a maximum for a first build — suggest consolidating if the user lists more

**If the user's domain resembles an existing example, mention it:**
- Content/media production → `skill/examples/script-to-animation/`
- Research, literature review, or synthesis work → `skill/examples/research-synthesis/`
- Client or consulting deliverables → `skill/examples/client-deliverable/`

---

## Group C — Reference material

**Purpose:** Identify what Layer 3 (stable factory configuration) content the workspace needs.

Questions:
1. Is there a voice, tone, or style that Claude should consistently apply? 
   - If yes: describe it. (This becomes a voice.md or style.md in `_config/`.)
2. Are there visual or structural conventions Claude should follow?
   - If yes: describe them. (Templates, formatting rules, structural requirements.)
3. Are there domain-specific rules, constraints, or knowledge that applies to every stage?
   - If yes: describe them. (Domain knowledge file in `_config/`.)
4. Is there any reference material that applies to only one specific stage?
   - If yes: describe it. (Goes in that stage's `references/` folder.)
5. Do you have existing documents, examples, or templates that should be included?
   - If yes: note their names/contents so they can be represented in the workspace.
6. Does any stage need a specific skill or external tool to do its work?
   - Examples: a web search MCP for a research stage, a code execution environment for a production stage, a design system skill for a visual output stage, a data tool for an analysis stage.
   - If yes: which stage, and what skill or tool? (This populates the Skills column in the routing table.)
   - If no: the Skills column will use `—` for all stages.

**What to listen for:**
- Anything stable that doesn't change between runs → Layer 3 (`_config/` or stage `references/`)
- Anything specific to a single run → Layer 4 (`output/`) — not reference material
- Whether reference material is shared across all stages (→ `_config/`) or specific to one stage (→ that stage's `references/`)
- Skills and MCPs are named in the routing table Skills column — they don't go in reference files unless the skill has its own configuration that belongs in `references/`

---

## Group D — Rules and naming conventions

**Purpose:** Capture any constraints on Claude's behaviour and establish file naming patterns.

Questions:
1. Are there things Claude should always do in this workspace regardless of the stage?
   *(Keep this short — 2 rules maximum. These go in CLAUDE.md.)*
2. Are there things Claude should never do in this workspace?
   *(e.g. never modify reference files, never create files outside output/, never assume a stage is done without producing the output file.)*
3. How should output files be named?
   - Suggest formats if the user is unsure:
     - By topic and status: `topic-name_draft.md`, `topic-name_final.md`
     - By date: `YYYY-MM-DD-topic.md`
     - By version: `topic_v1.md`, `topic_v2.md`
   - The naming convention should make it possible to find a file without opening it.

**What to listen for:**
- Rules that are actually Layer-2 stage-specific constraints (these belong in stage CONTEXT.md, not CLAUDE.md)
- Naming patterns that match how the user already names files — don't introduce a new convention if they have one
- Rules about asking before acting vs acting autonomously — this affects how Claude behaves during pipeline runs

---

## Confirmation step

Before generating anything, summarise what you've understood:

```
Here's what I'll build:

Workspace: [name]
Claude identity: [Q3 answer — expertise or persona]
For: [user name], [role]
Purpose: [one sentence]

Stages:
1. [stage name] — takes [input], produces [output] — skill: [name or —]
2. [stage name] — takes [input], produces [output] — skill: [name or —]
3. [stage name] — takes [input], produces [output] — skill: [name or —]

Reference material:
- [_config/ files to create]
- [per-stage reference files]

Rules: [list]
Naming: [pattern]

Does this look right? Anything to change before I generate?
```

Do not proceed until the user confirms. If they correct something, update your understanding and confirm again.

---

## After confirmation

Generate the workspace in this order:

1. Root `CLAUDE.md` (use `skill/templates/CLAUDE.md.template`). Populate the `## Identity` section: "You are [Q3 Claude identity] helping [Q1 name], a [Q2 role], [Q4 purpose/context]." Populate the Skills column in the routing table from Group C Q6: use the skill or tool name for stages that have one, `—` for all others.
2. Root `CONTEXT.md` (use `skill/templates/CONTEXT.md.template`)
3. `stages/` with numbered folders (`01_name/`, `02_name/`, etc.)
4. Each stage `CONTEXT.md` with Inputs/Process/Outputs filled (use `skill/templates/stage-CONTEXT.md.template`)
5. Each stage's `references/` and `output/` directories. For any stage-specific reference material described in Group C Q4, draft the file content from the user's description — do not leave it blank.
6. `_config/` files, drafted from Group C answers:
   - **Group C Q1 (voice/style)** → `_config/voice.md`: draft Purpose, Voice/tone description, sentence-level conventions, what to avoid, and at least one concrete example of correct vs incorrect register if the user gave enough to work from.
   - **Group C Q2 (structural/visual conventions)** → `_config/conventions.md` or equivalent: draft the structural rules and format requirements the user described.
   - **Group C Q3 (domain knowledge)** → `_config/domain.md` or equivalent: draft the key concepts, constraints, and domain-specific rules.
   - If the user described nothing for a given category, skip that file — do not create empty placeholders.
   - If the user gave a brief description, draft from it and mark any sections that need more detail with `[TO EXPAND]`.
7. `PROGRESS.md` at root (use `skill/templates/PROGRESS.md.template`)
8. `setup/questionnaire-answers.md` with the interview answers recorded
9. `setup/session-prompts.md` with this exact content:

```markdown
# Session Prompts

Copy these at the start and end of each Claude Code session.

## Session start
If `skill/tools/reconcile-progress.sh` is accessible, run it first:
`bash skill/tools/reconcile-progress.sh`
It compares the actual output/ directories against stage contracts and PROGRESS.md,
and prints any discrepancies with a recommended state.

If the script is not accessible: read CLAUDE.md and PROGRESS.md, then check each
stage's output/ directory against its CONTEXT.md Outputs section. If actual state
doesn't match what PROGRESS.md records, describe the discrepancy and reconcile
before asking what to do next.

## Session end
Create session-history/YYYY-MM-DD.md using skill/templates/session-history.md.template.
Record what was completed, any corrections made to stage outputs (these feed pattern detection),
decisions, and what's next. Then update PROGRESS.md Current Status and Active stage.

## Before stepping away
Update PROGRESS.md Current Status in case this session ends unexpectedly.
```

10. `setup/skill-version.md` — read the Skill build date from `SKILL.md` and generate:

```markdown
# Workspace Generation Record

Skill build: [date from SKILL.md]

## Feature flags at generation

identity-format: explicit-persona   — "You are [identity] helping [name], a [role], [context]"
session-prompts: yes                 — setup/session-prompts.md generated
skills-column: yes                   — routing table includes Skills column
progress-update-rule: yes            — CLAUDE.md Rules includes proactive PROGRESS.md update
trace-mode: yes                      — Mode 5 (Trace) available
preflight-tool: yes                  — skill/tools/preflight.sh available
```

(This file is a record, not a configuration. Future reviews use it to flag improvements added after this workspace was generated.)



**Quality gates before confirming done:**
- `CLAUDE.md` is under 50 lines
- `CLAUDE.md` contains an explicit identity statement ("You are [identity] helping [name], a [role], [purpose]")
- Routing table present with paths matching actual stage folders
- Every stage `CONTEXT.md` has Inputs, Process, and Outputs sections
- Layer 3 (`references/`, `_config/`) and Layer 4 (`output/`) locations are clearly separated

Then read `skill/anti-patterns.md` and run a full Check on the generated workspace. The completion report must include: the audit results, and the contents of `setup/session-prompts.md` so the user has the prompts immediately without opening another file.

If the user wants to see a finished workspace for reference, point them to `skill/examples/script-to-animation/`.

---

## Duplication path

Use this instead of Groups A–D when the user is adapting an existing workspace for a new domain or use case. The stage structure is inherited; the interview focuses on what changes.

### Step 1 — Identify and read the source workspace

Ask: "Which workspace are you basing this on? Give me the path or describe it."

Read the source workspace: `CLAUDE.md`, root `CONTEXT.md`, all stage `CONTEXT.md` files, `_config/` files, and `setup/questionnaire-answers.md` if present. Build a working understanding of the stage structure, reference material, and rules.

### Step 2 — Abbreviated interview

Ask these questions. They replace Groups A–D:

**Identity**
Is this workspace for the same person and role as the source, or someone different? If different, get their name and role.

**Domain**
What is this new workspace actually for? How does the new use case differ from the source? Focus on what changes in the *work* — the inputs, the audience, the output type — not on surface-level differences.

**Stages**
Do the source stages map to your new workflow? Walk through each:
- Does this stage still make sense? (keep / rename / drop)
- Does any new stage need to be added?
- Does the stage count feel right, or does the new domain need more or fewer boundaries?

**Reference material**
- Does the voice guide carry over, or does the register change significantly for the new domain?
- Do any structural conventions change (report format, naming patterns, etc.)?
- Does the new domain introduce constraints the source didn't have?

**Skills**
- Do the source workspace's skills or MCP connections still apply to the same stages?
- Does the new domain require any new skills or tools that the source didn't have?

**Rules and naming**
- Do the existing rules still apply?
- Does the naming convention need updating for the new output types?

### Step 3 — Confirm before generating

Summarise what you understood:

```
Source workspace: [path or name]
New workspace: [name]
For: [name], [role]

Inherited from source:
  Stages: [list — note any renames]
  Reference file types: [voice guide, conventions, etc.]
  Rules: [unchanged / modified as follows]

Changed:
  Identity: [new identity statement]
  Domain: [how the new use case differs]
  Stage processes: rewritten for [new domain]
  Reference content: [what's updated]

Does this look right? Anything to change before I generate?
```

Do not generate until the user confirms.

### Step 4 — Generate the adapted workspace

Generate in this order:

1. Root `CLAUDE.md`: adapt from source — update Identity statement; update stage descriptions in Folder Structure and Routing table for the new domain; keep Rules (adjust only if user specified changes)
2. Root `CONTEXT.md`: rewrite entirely for the new domain — new "what we are building", "what good looks like", "what to avoid"
3. `stages/` directory: copy source stage structure (renamed as confirmed). For each stage `CONTEXT.md`:
   - Keep the `## Inputs` and `## Outputs` structure and path patterns
   - Rewrite `## Process` entirely for the new domain — this is where the new use case lives
4. `_config/` files: adapt content for the new domain. If the voice guide applies unchanged, keep it. If the domain changes the register significantly, rewrite it. Preserve the file structure.
5. Stage `references/` files: adapt content for new domain; preserve structure.
6. `PROGRESS.md` — fresh (new workspace, no history from source)
7. `setup/session-prompts.md` — same content as the scratch path
8. `setup/questionnaire-answers.md` — document the duplication: source workspace, what was inherited, what was changed and why
9. `setup/skill-version.md` — same format as the scratch path (Skill build date from `SKILL.md`, current feature flags)

Apply the same quality gates as the scratch path, then run a full Check (read `skill/anti-patterns.md`). Include audit results and session prompts in the completion report.

