# Bash Style Guide

Applies when writing or modifying scripts in `core/tools/`. Describes the conventions
already in use across `preflight.sh`, `audit-all.sh`, `diff-stage.sh`, and `reconcile-progress.sh`.

---

## File header

```bash
#!/usr/bin/env bash
# script-name.sh — one-line description
#
# Usage: bash script-name.sh [arg]
#        Defaults to current directory.
#
# What the script checks or produces.
#
# Exit codes: 0 = pass, 1 = issues found, 2 = bad path/input
```

---

## Internal structure

Sections in order, separated by labelled dividers:

```bash
# ---------------------------------------------------------------------------
# Section Name
# ---------------------------------------------------------------------------
```

Order:
1. Global state — counters, parallel arrays, format constants
2. Output helpers — `pass`, `warn`, `crit`, `suggest`, `section`
3. Utilities — small reusable functions with no side effects
4. Domain logic — one function per concern
5. Presentation — summary tables, result lines
6. `main()` — always last; reads as a table of contents

Parallel arrays are declared together at the top with a comment stating their shared index relationship.

---

## Language choices

- Shebang: `#!/usr/bin/env bash`
- Conditionals: `[[ ]]` not `[ ]`
- Arithmetic: `(( ))` and `$(( ))` — no `let`, no `declare -i`
- Substitution: `$()` not backticks
- Sequences: brace expansion — no `seq`
- Functions: `name() {` form — no `function` keyword
- Local variables: always `local` inside functions
- Variable names: `lower_snake_case`; `ALL_CAPS` for script-level constants only

---

## Quoting and input

- Double-quote all expansions: `"$var"`, `"${arr[@]}"`
- `IFS= read -r` when reading lines
- `read -r -d ''` with `find -print0` when filenames may contain spaces
- Single quotes for string literals

---

## Safety

- No `set -e` — handle errors explicitly at each call site
- No `eval`
- `(( count++ )) || true` to prevent arithmetic returning non-zero exit
- `2>/dev/null` on `find` and `ls` calls that may hit absent paths
- Validate before `cd`: `cd "$dir" || { echo "ERROR: ..."; exit 2; }`
- Never parse `ls` output — use `find -print0`

---

## Output format

Audit/check scripts use consistent tokens for scannable, grep-friendly output:

```
PASS  [ID] message
FAIL  [ID] Critical: message
FAIL  [ID] Warning:  message
NOTE  [ID] Suggest:  message
```

`printf` for aligned/tabular output. `echo` for plain lines.
Heredoc (`cat <<-'EOF'`) for static multi-line output blocks only (e.g. deferred-checks list).

---

## Exit codes

| Code | Meaning |
|------|---------|
| 0 | All checks passed / success |
| 1 | Issues found |
| 2 | Bad path, missing dependency, or invalid input |

---

## What not to do

- No `set -e`
- No `eval`
- No unnecessary `cat` — use redirection or built-in file reading
- No GNU-specific flags — keep portable across macOS and Linux
- No opaque one-liner pipelines — break into named functions
- No global state mutation inside loops — accumulate results into arrays via dedicated functions
