#!/usr/bin/env bash
# audit-all.sh — Batch ICM workspace audit
#
# Usage: bash audit-all.sh [parent-directory]
#        Defaults to current directory.
#
# Finds all direct subdirectories containing a CLAUDE.md (ICM workspaces),
# runs preflight.sh on each, and produces a summary table showing critical
# count, warning count, suggestion count, and last session date.
#
# Full preflight detail is shown only for workspaces with issues.
# For individual workspace detail, run preflight.sh directly.
#
# Exit codes: 0 = all workspaces clean, 1 = one or more had issues, 2 = bad path

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PREFLIGHT="$SCRIPT_DIR/preflight.sh"

# Parallel arrays: one entry per workspace, populated by audit_all()
ws_names=()
ws_crits=()
ws_warns=()
ws_suggs=()
ws_dates=()
ws_fails=()   # FAIL lines from preflight, newline-separated per workspace

# Table formatting constants
TABLE_FMT='%-28s  %8s  %8s  %11s  %12s\n'
TABLE_SEP='----------------------------  --------  --------  -----------  ------------'

# ---------------------------------------------------------------------------
# Validation
# ---------------------------------------------------------------------------

validate() {
	local parent="$1"
	if [[ ! -d "$parent" ]]; then
		echo "ERROR: Cannot access directory: $parent"
		exit 2
	fi
	if [[ ! -f "$PREFLIGHT" ]]; then
		echo "ERROR: preflight.sh not found at $PREFLIGHT"
		exit 2
	fi
}

# ---------------------------------------------------------------------------
# Discovery
# ---------------------------------------------------------------------------

find_workspaces() {
	local parent="$1" d
	while IFS= read -r -d '' d; do
		[[ -f "$d/CLAUDE.md" ]] && echo "$d"
	done < <(find "$parent" -mindepth 1 -maxdepth 1 -type d -print0 2>/dev/null \
		| sort -z)
}

# ---------------------------------------------------------------------------
# Data extraction helpers
# ---------------------------------------------------------------------------

extract_count() {
	local output="$1" label="$2"
	echo "$output" | grep "  ${label}:" | grep -o '[0-9]*' | head -1
}

extract_failures() {
	local output="$1"
	echo "$output" | grep '^FAIL'
}

# Get most recent session date.
# Prefers session-history/ filenames (new format); falls back to PROGRESS.md.
last_session_date() {
	local dir="$1" latest date

	if [[ -d "$dir/session-history" ]]; then
		latest=$(find "$dir/session-history" -name '*.md' -type f 2>/dev/null \
			| sort | tail -1)
		if [[ -n "$latest" ]]; then
			basename "$latest" .md | grep -o '[0-9]\{4\}-[0-9]\{2\}-[0-9]\{2\}'
			return
		fi
	fi

	[[ ! -f "$dir/PROGRESS.md" ]] && echo '—' && return
	date=$(grep -i 'last session' "$dir/PROGRESS.md" \
		| grep -o '[0-9]\{4\}-[0-9]\{2\}-[0-9]\{2\}' \
		| head -1)
	echo "${date:-—}"
}

# ---------------------------------------------------------------------------
# Per-workspace audit — populates one entry in each global array
# ---------------------------------------------------------------------------

run_preflight() {
	local dir="$1"
	bash "$PREFLIGHT" "$dir" 2>&1
}

audit_one() {
	local dir="$1" output

	output=$(run_preflight "$dir")

	ws_names+=("$(basename "$dir")")
	ws_crits+=("$(extract_count "$output" 'Critical')")
	ws_warns+=("$(extract_count "$output" 'Warnings')")
	ws_suggs+=("$(extract_count "$output" 'Suggestions')")
	ws_dates+=("$(last_session_date "$dir")")
	ws_fails+=("$(extract_failures "$output")")
}

audit_all() {
	local parent="$1" dir
	while IFS= read -r dir; do
		audit_one "$dir"
	done < <(find_workspaces "$parent")
}

# ---------------------------------------------------------------------------
# Table presentation
# ---------------------------------------------------------------------------

truncate() {
	local s="$1" n="$2"
	[[ "${#s}" -gt "$n" ]] && echo "${s:0:$(( n - 1 ))}…" || echo "$s"
}

print_table_header() {
	printf "$TABLE_FMT" 'Workspace' 'Critical' 'Warnings' 'Suggestions' 'Last Session'
	echo "$TABLE_SEP"
}

print_table_row() {
	local i="$1"
	printf "$TABLE_FMT" \
		"$(truncate "${ws_names[$i]}" 28)" \
		"${ws_crits[$i]:-0}" \
		"${ws_warns[$i]:-0}" \
		"${ws_suggs[$i]:-0}" \
		"${ws_dates[$i]}"
}

print_table() {
	local i
	print_table_header
	for (( i = 0; i < ${#ws_names[@]}; i++ )); do
		print_table_row "$i"
	done
}

# ---------------------------------------------------------------------------
# Summary and issues presentation
# ---------------------------------------------------------------------------

total_criticals() {
	local total=0 i
	for (( i = 0; i < ${#ws_crits[@]}; i++ )); do
		total=$(( total + ${ws_crits[$i]:-0} ))
	done
	echo "$total"
}

total_warnings() {
	local total=0 i
	for (( i = 0; i < ${#ws_warns[@]}; i++ )); do
		total=$(( total + ${ws_warns[$i]:-0} ))
	done
	echo "$total"
}

total_suggestions() {
	local total=0 i
	for (( i = 0; i < ${#ws_suggs[@]}; i++ )); do
		total=$(( total + ${ws_suggs[$i]:-0} ))
	done
	echo "$total"
}

print_summary() {
	echo ''
	echo "=== Summary: ${#ws_names[@]} workspace(s) audited ==="
	printf '  Critical:    %d\n' "$(total_criticals)"
	printf '  Warnings:    %d\n' "$(total_warnings)"
	printf '  Suggestions: %d\n' "$(total_suggestions)"
}

print_clean_result() {
	echo ''
	echo 'All workspaces passed mechanical checks.'
}

print_issues() {
	local i has_issues=0

	for (( i = 0; i < ${#ws_names[@]}; i++ )); do
		[[ -n "${ws_fails[$i]}" ]] && { has_issues=1; break; }
	done
	[[ "$has_issues" -eq 0 ]] && return

	echo ''
	echo '=== Workspaces with issues ==='
	for (( i = 0; i < ${#ws_names[@]}; i++ )); do
		[[ -z "${ws_fails[$i]}" ]] && continue
		echo "  ${ws_names[$i]}:"
		while IFS= read -r line; do
			echo "    $line"
		done <<< "${ws_fails[$i]}"
	done
}

has_issues() {
	local i
	for (( i = 0; i < ${#ws_names[@]}; i++ )); do
		if [[ "${ws_crits[$i]:-0}" -gt 0 || "${ws_warns[$i]:-0}" -gt 0 ]]; then
			return 0
		fi
	done
	return 1
}

# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------

main() {
	local parent="${1:-.}"

	validate "$parent"

	echo "=== Workspace Audit: $(cd "$parent" && pwd) ==="
	echo "=== $(date '+%Y-%m-%d %H:%M') ==="
	echo ''

	audit_all "$parent"

	if [[ "${#ws_names[@]}" -eq 0 ]]; then
		echo 'No ICM workspaces found (no subdirectories containing CLAUDE.md).'
		exit 0
	fi

	echo "Found ${#ws_names[@]} workspace(s)."
	echo ''

	print_table
	print_summary

	if has_issues; then
		print_issues
	else
		print_clean_result
	fi

	has_issues && exit 1
	exit 0
}

main "$@"
