#!/usr/bin/env bash
# preflight.sh — ICM workspace mechanical checks
#
# Usage: bash preflight.sh [workspace-root]
#        Defaults to current directory.
#
# Runs all checks that can be determined mechanically.
# Output maps to review-checklist.md check IDs.
# Checks requiring Claude's judgment are in the Deferred section.
#
# Exit codes: 0 = all pass, 1 = failures found, 2 = bad path

passes=0
warnings=0
criticals=0
suggestions=0

# ---------------------------------------------------------------------------
# Output helpers
# ---------------------------------------------------------------------------

pass() {
	local id="$1" msg="$2"
	echo "PASS  [$id] $msg"
	(( passes++ )) || true
}

warn() {
	local id="$1" msg="$2"
	echo "FAIL  [$id] Warning:  $msg"
	(( warnings++ )) || true
}

crit() {
	local id="$1" msg="$2"
	echo "FAIL  [$id] Critical: $msg"
	(( criticals++ )) || true
}

suggest() {
	local id="$1" msg="$2"
	echo "NOTE  [$id] Suggest:  $msg"
	(( suggestions++ )) || true
}

# ---------------------------------------------------------------------------
# Utilities
# ---------------------------------------------------------------------------

section() {
	echo ""
	echo "-- $* --"
}

find_stages() {
	find stages -mindepth 1 -maxdepth 1 -type d 2>/dev/null | sort
}

count_lines() {
	wc -l < "$1" | tr -d ' '
}

has_section() {
	grep -q "^$2" "$1"
}

# Extract filenames from the ## Outputs section of a stage CONTEXT.md
# Prints one filename per line (no path, no backticks)
extract_output_names() {
	local file="$1"
	local in_outputs=0 filename
	while IFS= read -r line; do
		if [[ "$line" =~ ^##\ Outputs ]]; then
			in_outputs=1
			continue
		fi
		[[ "$in_outputs" -eq 1 && "$line" =~ ^## ]] && break
		if [[ "$in_outputs" -eq 1 && "$line" =~ ^-\  ]]; then
			filename=$(echo "$line" | grep -o '`[^`/]*\.[^`]*`' | head -1 | tr -d '`')
			[[ -n "$filename" ]] && echo "$filename"
		fi
	done < "$file"
}

# Extract stage paths from the routing table in CLAUDE.md
extract_routing_paths() {
	grep '^|' CLAUDE.md \
		| grep -v '^|[-[:space:]|]*|$' \
		| grep -o '`stages/[^`]*`' \
		| tr -d '`'
}

# ---------------------------------------------------------------------------
# Layer 0 — CLAUDE.md
# ---------------------------------------------------------------------------

check_identity() {
	local identity_line

	# Extract the first non-empty line in the ## Identity section
	identity_line=$(awk '
		/^## Identity/ { found=1; next }
		found && /^## /  { exit }
		found && /[^[:space:]]/ { print; exit }
	' CLAUDE.md)

	if [[ -z "$identity_line" ]]; then
		warn 'L0-7' \
			"No identity statement — add '## Identity / You are [persona] helping [name]...'"
		return
	fi

	# Must start with "You are"
	if ! echo "$identity_line" | grep -qi '^you are'; then
		warn 'L0-7' "Identity statement doesn't start with 'You are' (AP-10)"
		return
	fi

	# Must contain "helping" — establishes the relationship
	if ! echo "$identity_line" | grep -qi 'helping'; then
		warn 'L0-7' \
			"Identity missing 'helping [name]' clause — format: 'You are [identity] helping [name]...' (AP-10)"
		return
	fi

	# Must NOT start with "You are helping" — Claude's own identity must come first
	if echo "$identity_line" | grep -qi '^you are helping'; then
		warn 'L0-7' \
			"Identity lacks explicit Claude persona — add expertise or persona before 'helping' (AP-10)"
		return
	fi

	# "helping" must be followed by a name, not a role category
	if echo "$identity_line" | grep -qi 'helping a \|helping an '; then
		warn 'L0-7' \
			"Identity names a role category after 'helping', not a real person (AP-10)"
		return
	fi

	pass 'L0-7' "Identity statement present: Claude persona + named person"
}

check_routing_table() {
	if ! grep -q '^|' CLAUDE.md; then
		crit 'L0-3' 'No routing table found — add Task | Go to | Read columns'
		return
	fi
	pass 'L0-3' 'Routing table present'

	if ! grep -q 'Task' CLAUDE.md \
		|| ! grep -q 'Go to' CLAUDE.md \
		|| ! grep -q 'Read' CLAUDE.md; then
		crit 'L0-4' 'Routing table missing required column headers (Task, Go to, Read)'
	else
		pass 'L0-4' 'Routing table has required column headers'
	fi

	local path found_bad=0
	while IFS= read -r path; do
		if [[ ! -d "$path" ]]; then
			crit 'L0-5' "Routing path not found as directory: $path"
			found_bad=1
		fi
	done < <(extract_routing_paths)
	[[ "$found_bad" -eq 0 ]] && pass 'L0-5' 'All routing paths resolve to directories'
}

check_claude_md() {
	section 'Layer 0: CLAUDE.md'

	if [[ ! -f 'CLAUDE.md' ]]; then
		crit 'L0-1' 'CLAUDE.md not found — no routing map exists'
		return
	fi
	pass 'L0-1' 'CLAUDE.md exists'

	local lines
	lines=$(count_lines CLAUDE.md)
	if [[ "$lines" -gt 50 ]]; then
		warn 'L0-2' "CLAUDE.md has $lines lines (limit: 50)"
	else
		pass 'L0-2' "CLAUDE.md has $lines lines"
	fi

	check_routing_table
	check_identity

	if grep -q '## Naming' CLAUDE.md; then
		pass 'L0-8' 'Naming Conventions section present'
	else
		warn 'L0-8' 'No Naming Conventions section found'
	fi

	if grep -q '## Rules' CLAUDE.md; then
		local rule_count
		rule_count=$(awk '
			/^## Rules/ { in_rules=1; next }
			in_rules && /^## /  { exit }
			in_rules && /^- /   { count++ }
			END { print count+0 }
		' CLAUDE.md)
		if [[ "$rule_count" -gt 5 ]]; then
			suggest 'L0-9' \
				"Rules section has $rule_count rules (limit: 5)"
		else
			pass 'L0-9' "Rules section has $rule_count rule(s)"
		fi
	else
		warn 'L0-9' 'No Rules section found'
	fi
}

# ---------------------------------------------------------------------------
# Layer 1 — CONTEXT.md
# ---------------------------------------------------------------------------

check_context_md() {
	section 'Layer 1: CONTEXT.md'

	if [[ ! -f 'CONTEXT.md' ]]; then
		warn 'L1-1' 'CONTEXT.md not found — no project description'
		return
	fi
	pass 'L1-1' 'CONTEXT.md exists'

	if grep -q 'Last updated' CONTEXT.md; then
		pass 'L1-7' 'CONTEXT.md has Last updated marker'
	else
		suggest 'L1-7' 'CONTEXT.md has no Last updated marker'
	fi
}

# ---------------------------------------------------------------------------
# Layer 2 — Stage contracts
# ---------------------------------------------------------------------------

check_one_stage() {
	local stage_dir="$1"
	local name
	name="${stage_dir##*/}"

	if [[ ! -f "$stage_dir/CONTEXT.md" ]]; then
		crit 'L2-1' "$name: CONTEXT.md missing — stage has no contract"
		return
	fi
	pass 'L2-1' "$name: CONTEXT.md exists"

	local section_label check_id
	for entry in 'L2-2:## Inputs' 'L2-4:## Process' 'L2-7:## Outputs'; do
		check_id="${entry%%:*}"
		section_label="${entry#*:}"
		if grep -q "^${section_label}" "$stage_dir/CONTEXT.md"; then
			pass "$check_id" "$name: '$section_label' present"
		else
			crit "$check_id" "$name: '$section_label' missing — contract incomplete"
		fi
	done

	if ! grep -q 'Last updated' "$stage_dir/CONTEXT.md"; then
		suggest 'L2-9' "$name: No Last updated marker"
	fi
}

check_stage_contracts() {
	section 'Layer 2: Stage contracts'

	if [[ ! -d 'stages' ]]; then
		warn 'L2-0' 'No stages/ directory found'
		return
	fi

	local stages=()
	while IFS= read -r d; do
		stages+=("$d")
	done < <(find_stages)

	if [[ "${#stages[@]}" -eq 0 ]]; then
		warn 'L2-0' 'No stage directories found under stages/'
		return
	fi

	pass 'L2-0' "Found ${#stages[@]} stage(s)"

	if [[ "${#stages[@]}" -gt 5 ]]; then
		warn 'AP-7' "${#stages[@]} stages — consider consolidating for a new workspace"
	fi

	local stage_dir
	for stage_dir in "${stages[@]}"; do
		check_one_stage "$stage_dir"
	done
}

# ---------------------------------------------------------------------------
# Layers 3 & 4 — reference and output directories
# ---------------------------------------------------------------------------

check_stage_dirs() {
	section 'Layers 3 & 4: references/ and output/'

	local stage_dir name
	while IFS= read -r stage_dir; do
		name="${stage_dir##*/}"

		if [[ -d "$stage_dir/references" ]]; then
			pass 'L3-1' "$name: references/ exists"
		else
			suggest 'L3-1' "$name: No references/ directory"
		fi

		if [[ -d "$stage_dir/output" ]]; then
			pass 'L4-1' "$name: output/ exists"
		else
			warn 'L4-1' "$name: No output/ directory"
		fi
	done < <(find_stages)
}

# ---------------------------------------------------------------------------
# IC-10 — Output contract satisfaction
# ---------------------------------------------------------------------------

check_output_contracts() {
	section 'IC-10: Output contract satisfaction'

	local stage_dir name filename filepath
	while IFS= read -r stage_dir; do
		name="${stage_dir##*/}"
		[[ ! -f "$stage_dir/CONTEXT.md" ]] && continue

		while IFS= read -r filename; do
			filepath="$stage_dir/output/$filename"
			if [[ ! -f "$filepath" ]]; then
				suggest 'IC-10' \
					"$name: '$filename' in Outputs contract not found at $filepath"
			elif [[ ! -s "$filepath" ]]; then
				warn 'IC-10' "$name: '$filename' exists but is empty"
			else
				pass 'IC-10' "$name: '$filename' exists with content"
			fi
		done < <(extract_output_names "$stage_dir/CONTEXT.md")
	done < <(find_stages)
}

# ---------------------------------------------------------------------------
# Session persistence — PROGRESS.md
# ---------------------------------------------------------------------------

check_session() {
	section 'Session persistence'

	if [[ ! -f 'PROGRESS.md' ]]; then
		suggest 'SP-1' 'PROGRESS.md not found'
		return
	fi
	pass 'SP-1' 'PROGRESS.md exists'

	if grep -qi 'current status' PROGRESS.md; then
		pass 'SP-2' 'PROGRESS.md has Current Status section'
	else
		warn 'SP-2' "PROGRESS.md missing 'Current Status' section"
	fi

	if grep -qi 'active stage' PROGRESS.md; then
		pass 'SP-3' 'PROGRESS.md has Active stage section'
	else
		warn 'SP-3' \
			"PROGRESS.md missing 'Active stage' section (new format — session history now in session-history/)"
	fi

	# SP-5: session-history/ directory
	if [[ -d 'session-history' ]]; then
		local count
		count=$(find session-history -name '*.md' -type f 2>/dev/null | wc -l | tr -d ' ')
		pass 'SP-5' "session-history/ exists with $count session file(s)"
	else
		suggest 'SP-5' \
			'session-history/ absent — log sessions to session-history/YYYY-MM-DD.md at session end'
	fi
}

# ---------------------------------------------------------------------------
# IC-9 — File system vs PROGRESS.md
# ---------------------------------------------------------------------------

check_generation_record() {
	section 'Workspace generation record'

	if [[ -f 'setup/session-prompts.md' ]]; then
		pass 'VR-1' 'setup/session-prompts.md exists'
	else
		warn 'VR-1' \
			'setup/session-prompts.md absent — user lacks session start/end/recovery prompts (AP-11)'
	fi

	if [[ -f 'setup/skill-version.md' ]]; then
		pass 'VR-2' 'setup/skill-version.md exists'
	else
		suggest 'VR-2' \
			'setup/skill-version.md absent — no generation record; workspace may predate key improvements (AP-11)'
	fi

	if [[ -f 'setup/questionnaire-answers.md' ]]; then
		pass 'VR-3' 'setup/questionnaire-answers.md exists'
	else
		suggest 'VR-3' \
			'setup/questionnaire-answers.md absent — no record of workspace design decisions (AP-11)'
	fi
}

check_fs_vs_progress() {
	section 'IC-9: File system vs PROGRESS.md'

	if [[ ! -f 'PROGRESS.md' ]]; then
		suggest 'IC-9' 'PROGRESS.md absent — cannot reconcile'
		return
	fi

	local stage_dir name has_output is_complete
	while IFS= read -r stage_dir; do
		name="${stage_dir##*/}"
		has_output=0
		is_complete=0

		if [[ -d "$stage_dir/output" ]] \
			&& [[ -n "$(ls -A "$stage_dir/output" 2>/dev/null)" ]]; then
			has_output=1
		fi

		if grep -qi 'completed' PROGRESS.md \
			&& grep -i 'completed' PROGRESS.md | grep -qi "$name"; then
			is_complete=1
		fi

		if [[ "$has_output" -eq 1 && "$is_complete" -eq 0 ]]; then
			warn 'IC-9' \
				"$name: output/ has files but not recorded as completed — interrupted session?"
		elif [[ "$has_output" -eq 0 && "$is_complete" -eq 1 ]]; then
			warn 'IC-6' \
				"$name: recorded as completed but output/ is empty"
		fi
	done < <(find_stages)
}

# ---------------------------------------------------------------------------
# Summary and deferred list
# ---------------------------------------------------------------------------

print_summary() {
	local total=$(( criticals + warnings + suggestions + passes ))
	echo ""
	echo "=== Preflight summary ==="
	printf '  Critical:    %d\n' "$criticals"
	printf '  Warnings:    %d\n' "$warnings"
	printf '  Suggestions: %d\n' "$suggestions"
	printf '  Passing:     %d\n' "$passes"
	printf '  Total:       %d\n' "$total"
}

print_deferred() {
	cat <<-'EOF'

	=== Deferred to Claude (require reading and judgment) ===
	  AP-5   Content ratio: work-description vs AI-personality instructions
	  AP-6   Context file currency — contents still match current project?
	  AP-8   Layer 3/4 mixing — are file types correct for their locations?
	  AP-9   Rules content — routing behaviour or writing style?
	  L0-10  Rules describe structural behaviour, not Claude personality
	  L0-11  CLAUDE.md contains no multi-paragraph project descriptions
	  L1-2   CONTEXT.md describes what the workspace is for
	  L1-3   CONTEXT.md describes what good output looks like
	  L1-4   CONTEXT.md describes what to avoid
	  L1-5   CONTEXT.md describes the work, not how Claude should behave
	  L2-3   Stage Inputs distinguishes Layer 4 (working) from Layer 3 (reference)
	  L2-5   Stage Process has substantive instruction (≥2 sentences)
	  L2-6   Stage Process describes the work, not Claude personality
	  L2-8   Stage Outputs names specific files with destination paths
	  L3-2   Shared reference files are in _config/ not duplicated
	  L3-3   Files in references/ and _config/ are stable config, not outputs
	  L3-4   Every reference file loaded by at least one stage Inputs section
	  L4-2   Files in output/ are per-run artifacts, not stable reference
	  L4-3   Output filenames follow naming conventions from CLAUDE.md
	  CI-1   Stage chain: does stage N+1 Inputs point to stage N output/?
	  CI-2   Output filename in stage N Outputs matches stage N+1 Inputs
	  CI-3   Stage skipping is intentional and documented
	  IC-2   Layer 3 input paths actually exist
	  IC-5   Reference files referenced in at least one stage Inputs
	  IC-8   Stage skipping is intentional vs unintentional
	EOF
}

print_result() {
	echo ""
	if [[ "$criticals" -gt 0 ]]; then
		echo "RESULT: $criticals critical issue(s) — fix before using the workspace"
	elif [[ "$warnings" -gt 0 ]]; then
		echo "RESULT: $warnings warning(s) — review recommended"
	else
		echo "RESULT: All mechanical checks passed"
	fi
}

# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------

main() {
	local workspace="${1:-.}"

	cd "$workspace" || { echo "ERROR: Cannot access: $workspace"; exit 2; }

	echo "=== ICM Preflight: $(pwd) ==="
	echo "=== $(date '+%Y-%m-%d %H:%M') ==="

	check_claude_md
	check_context_md
	check_stage_contracts
	check_stage_dirs
	check_output_contracts
	check_session
	check_generation_record
	check_fs_vs_progress
	print_summary
	print_result
	print_deferred

	[[ "$criticals" -gt 0 || "$warnings" -gt 0 ]] && exit 1
	return 0
}

main "$@"
