# Versioning

This project uses date-based annotated git tags to mark significant versions.

---

## Convention

**Tag name format:** `v{YYYY-MM-DD}` — the date the version was completed, e.g. `v2026-05-25`.

**Always use annotated tags** (`git tag -a`), not lightweight tags. Annotated tags carry a tagger identity, timestamp, and message — lightweight tags do not.

**Tag message format:** a bullet list, one bullet per distinct change, written as past-tense statements describing what changed and why. Match the level of detail to the scope of the change — a single rule addition needs one bullet; a multi-file feature needs one bullet per meaningful unit.

---

## Process

1. **Check the previous tag** before writing a new one: `git show <tag> --stat` — match the message style.
2. **Create the tag:** `git tag -a v{YYYY-MM-DD} -m "..."` — use a HEREDOC for multi-line messages.
3. **Review before pushing:** show the tag output (`git show <tag> --stat`) and wait for confirmation.
4. **Push explicitly:** `git push origin v{YYYY-MM-DD}` — never push tags automatically.

---

## When to tag

Tag after a meaningful batch of related changes is complete and validated — not after every commit. A good signal: if the changelog would get a new dated entry, the tag should too.

---

## Examples

### Single-concern change

```
tag v2026-05-25
Tagger: Ashar Guglielmino

- Added engineering-standards.md Section 5 (Safe Deletion): global rule prohibiting
  rm -rf across all modes; permits rm, rmdir, and rm -r (without -f) — forced
  recursive deletes suppress errors and have no precise target boundary
- Added version update reminder to SKILL.md adjacent to the build date so the
  process is visible before any skill work begins
- Skill build bumped to 2026-05-25
```

### Multi-feature release

```
tag v2026-05-21
Tagger: Ashar Guglielmino

- Added skill/engineering-standards.md: four universal behavioral principles
  (Think Before Acting, Simplicity First, Surgical Changes, Goal-Driven Execution)
  applied to all modes
- Added skill/tools/tool-decision.md: decision guide for scripting vs. Claude
  guidance vs. external tool, grounded in the determinism principle
- Added skill/tools/bash-style.md: concise style guide codifying conventions
  from existing scripts
- Extracted session-prompts content to skill/templates/session-prompts.md.template;
  AP-12 now routes to Mode 5 (Trace) before Mode 3 when root cause is unclear
- Skill build bumped to 2026-05-21
```

---

## Commands reference

```bash
# List all tags
git tag -l

# Inspect a tag
git show v2026-05-25 --stat

# Create an annotated tag (multi-line message via HEREDOC)
git tag -a v2026-05-25 -m "$(cat <<'EOF'
- Change one
- Change two
EOF
)"

# Push a specific tag
git push origin v2026-05-25

# Push all tags (use sparingly — prefer explicit single-tag pushes)
git push origin --tags
```
