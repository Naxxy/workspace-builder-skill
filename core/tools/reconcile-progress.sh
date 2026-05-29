#!/usr/bin/env bash
# reconcile-progress.sh — Reconcile PROGRESS.md with actual file system state
#
# Usage: bash reconcile-progress.sh [workspace-root]
#        Defaults to current directory.
#
# Determines the real completion status of each stage by inspecting output/
# directories, compares against what PROGRESS.md records, and prints a
# reconciliation report. Useful after interrupted sessions or when PROGRESS.md
# is suspected to be stale.
#
# The script reports only. To apply changes, update PROGRESS.md manually
# or ask Claude to apply the recommended state.
#
# Exit codes: 0 = PROGRESS.md consistent with file system
#             1 = discrepancies found
#             2 = workspace path inaccessible

discrepancies=0

# ---------------------------------------------------------------------------
# Utilities
# ---------------------------------------------------------------------------

find_stages() {
	find stages -mindepth 1 -maxdepth 1 -type d 2>/dev/null | sort
}

# Extract expected output filenames from a stage CONTEXT.md ## Outputs section.
# Prints one filename per line (basename only, no backticks, no path).
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
			filename=$(echo "$line" \
				| grep -o '`[^`/]*\.[^`]*`' \
				| head -1 \
				| tr -d '`')
			[[ -n "$filename" ]] && echo "$filename"
		fi
	done < "$file"
}

# Determine file system status for a stage.
# Prints: COMPLETE, PARTIAL, EMPTY, or NONE
stage_fs_status() {
	local stage_dir="$1"
	local total=0 present=0 name

	if [[ ! -d "$stage_dir/output" ]]; then
		echo 'NONE'
		return
	fi

	if [[ ! -f "$stage_dir/CONTEXT.md" ]]; then
		# No contract — check if output/ has any files at all
		if [[ -n "$(ls -A "$stage_dir/output" 2>/dev/null)" ]]; then
			echo 'HAS_FILES'
		else
			echo 'EMPTY'
		fi
		return
	fi

	while IFS= read -r name; do
		total=$(( total + 1 ))
		[[ -s "$stage_dir/output/$name" ]] && present=$(( present + 1 ))
	done < <(extract_output_names "$stage_dir/CONTEXT.md")

	if [[ $total -eq 0 ]]; then
		# Contract has no named outputs; fall back to directory check
		if [[ -n "$(ls -A "$stage_dir/output" 2>/dev/null)" ]]; then
			echo 'HAS_FILES'
		else
			echo 'EMPTY'
		fi
		return
	fi

	if [[ $present -eq $total ]]; then
		echo 'COMPLETE'
	elif [[ $present -gt 0 ]]; then
		echo 'PARTIAL'
	else
		echo 'EMPTY'
	fi
}

# Check whether a stage is recorded as completed in PROGRESS.md.
# Returns 0 (true) if recorded, 1 (false) if not.
stage_recorded_complete() {
	local stage_name="$1"
	[[ ! -f 'PROGRESS.md' ]] && return 1
	grep -qi 'completed' PROGRESS.md \
		&& grep -i 'completed' PROGRESS.md | grep -qi "$stage_name"
}

# File size in human-readable form, or empty string if file absent
file_size() {
	local f="$1"
	[[ -f "$f" ]] || { echo '—'; return; }
	local bytes
	bytes=$(wc -c < "$f" | tr -d ' ')
	if [[ $bytes -lt 1024 ]]; then
		echo "${bytes} B"
	else
		echo "$(( bytes / 1024 )) KB"
	fi
}

# ---------------------------------------------------------------------------
# Per-stage analysis
# ---------------------------------------------------------------------------

analyse_stage() {
	local stage_dir="$1"
	local name="${stage_dir##*/}"
	local fs_status recorded_label match_symbol detail

	fs_status=$(stage_fs_status "$stage_dir")

	# Build file detail line
	detail=''
	if [[ -f "$stage_dir/CONTEXT.md" ]]; then
		while IFS= read -r fname; do
			local fpath="$stage_dir/output/$fname"
			local sz
			sz=$(file_size "$fpath")
			if [[ -s "$fpath" ]]; then
				detail="${detail}${fname} (${sz})  "
			else
				detail="${detail}${fname} [missing or empty]  "
			fi
		done < <(extract_output_names "$stage_dir/CONTEXT.md")
	fi
	[[ -z "$detail" ]] && detail='(no contract outputs)'

	# PROGRESS.md status
	if stage_recorded_complete "$name"; then
		recorded_label='recorded as completed'
	else
		recorded_label='not recorded as completed'
	fi

	# Determine if consistent
	case "$fs_status" in
		COMPLETE)
			if stage_recorded_complete "$name"; then
				match_symbol='✓'
			else
				match_symbol='⚠  needs update'
				discrepancies=$(( discrepancies + 1 ))
			fi
			;;
		PARTIAL)
			match_symbol='⚠  interrupted session (partial outputs)'
			discrepancies=$(( discrepancies + 1 ))
			;;
		EMPTY|NONE)
			if stage_recorded_complete "$name"; then
				match_symbol='⚠  PROGRESS.md overclaims (no output files)'
				discrepancies=$(( discrepancies + 1 ))
			else
				match_symbol='✓'
			fi
			;;
		HAS_FILES)
			if stage_recorded_complete "$name"; then
				match_symbol='✓ (uncontracted files)'
			else
				match_symbol='⚠  has output files but not recorded'
				discrepancies=$(( discrepancies + 1 ))
			fi
			;;
	esac

	printf '  Stage: %s\n' "$name"
	printf '    File system:  %-10s %s\n' "$fs_status" "$detail"
	printf '    PROGRESS.md:  %s\n' "$recorded_label"
	printf '    Status:       %s\n' "$match_symbol"
	echo ''
}

# ---------------------------------------------------------------------------
# Recommendation
# ---------------------------------------------------------------------------

print_recommendation() {
	local complete=() active='' not_started=()
	local stage_dir name fs_status found_active=0

	while IFS= read -r stage_dir; do
		name="${stage_dir##*/}"
		fs_status=$(stage_fs_status "$stage_dir")
		if [[ "$fs_status" == 'COMPLETE' || "$fs_status" == 'HAS_FILES' ]]; then
			complete+=("$name")
		elif [[ "$found_active" -eq 0 ]]; then
			active="$name"
			found_active=1
		else
			not_started+=("$name")
		fi
	done < <(find_stages)

	echo '=== Recommended PROGRESS.md state ==='
	echo ''

	if [[ ${#complete[@]} -gt 0 ]]; then
		printf '  Completed: %s\n' "$(IFS=', '; echo "${complete[*]}")"
	else
		echo '  Completed: (none)'
	fi

	if [[ -n "$active" ]]; then
		printf '  Active stage: %s\n' "$active"
	else
		echo '  Active stage: (all stages complete — pipeline ready for next run)'
	fi

	echo ''
	echo '  Suggested Current Status line:'
	if [[ -n "$active" ]]; then
		if [[ ${#complete[@]} -gt 0 ]]; then
			printf '    "%s is the active stage. %s complete."\n' \
				"$active" \
				"$(IFS=', '; echo "${complete[*]}")"
		else
			printf '    "%s is the active stage. No stages complete yet."\n' "$active"
		fi
	else
		echo '    "Pipeline complete. Ready for next run."'
	fi

	echo ''
	echo '  To apply: update PROGRESS.md manually, or ask Claude to apply'
	echo '  these changes using Mode 3 (Update).'
}

# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------

main() {
	local workspace="${1:-.}"

	cd "$workspace" || {
		echo "ERROR: Cannot access: $workspace"
		exit 2
	}

	echo "=== PROGRESS.md Reconciliation: $(pwd) ==="
	echo "=== $(date '+%Y-%m-%d %H:%M') ==="
	echo ''

	if [[ ! -d 'stages' ]]; then
		echo 'No stages/ directory found — nothing to reconcile.'
		exit 0
	fi

	if [[ ! -f 'PROGRESS.md' ]]; then
		echo 'NOTE: PROGRESS.md not found — reporting file system state only.'
		echo ''
	fi

	echo '=== Stage analysis ==='
	echo ''

	local stage_dir
	while IFS= read -r stage_dir; do
		analyse_stage "$stage_dir"
	done < <(find_stages)

	if [[ "$discrepancies" -gt 0 ]]; then
		echo "=== $discrepancies discrepancy/discrepancies found ==="
	else
		echo '=== PROGRESS.md is consistent with file system ==='
	fi

	echo ''
	print_recommendation

	[[ "$discrepancies" -gt 0 ]] && exit 1
	exit 0
}

main "$@"
