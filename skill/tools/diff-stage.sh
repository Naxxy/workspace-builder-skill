#!/usr/bin/env bash
# diff-stage.sh — Archive and diff stage outputs between runs
#
# Usage:
#   bash diff-stage.sh <stage-path> --archive
#       Copy current output files to output/_archive/ before re-running.
#
#   bash diff-stage.sh <stage-path>
#       Diff current output against the most recent archive.
#
# Typical workflow:
#   1. bash diff-stage.sh stages/02_script --archive   (save current output)
#   2. Re-run the stage in Claude Code
#   3. bash diff-stage.sh stages/02_script             (see what changed)
#
# Archives live in output/_archive/ with timestamp prefixes.
# The stage contract's ## Outputs section determines which files are tracked.
#
# Exit codes: 0 = success, 1 = diff showed changes, 2 = bad arguments

ARCHIVE_DIR='_archive'

# ---------------------------------------------------------------------------
# Shared utilities
# ---------------------------------------------------------------------------

# Extract expected output filenames from a stage CONTEXT.md ## Outputs section.
# Prints one filename per line.
extract_output_names() {
	local context="$1"
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
	done < "$context"
}

timestamp() {
	date '+%Y-%m-%dT%H-%M'
}

output_archive_dir() {
	local stage_dir="$1"
	echo "$stage_dir/output/$ARCHIVE_DIR"
}

# Find the most recent archived version of a given filename.
# Archives are named TIMESTAMP_filename, so sort gives chronological order.
find_latest_archive() {
	local arc_dir="$1" filename="$2"
	find "$arc_dir" -name "*_${filename}" -type f 2>/dev/null | sort | tail -1
}

validate_stage_dir() {
	local stage_dir="$1"
	if [[ ! -d "$stage_dir" ]]; then
		echo "ERROR: Stage directory not found: $stage_dir"
		exit 2
	fi
	if [[ ! -f "$stage_dir/CONTEXT.md" ]]; then
		echo "ERROR: No CONTEXT.md at $stage_dir — is this an ICM stage?"
		exit 2
	fi
}

# ---------------------------------------------------------------------------
# Archive mode — run before re-executing a stage
# ---------------------------------------------------------------------------

archive_one() {
	local stage_dir="$1" filename="$2"
	local src arc_dir dest ts

	src="$stage_dir/output/$filename"
	arc_dir=$(output_archive_dir "$stage_dir")
	ts=$(timestamp)
	dest="$arc_dir/${ts}_${filename}"

	if [[ ! -f "$src" ]]; then
		echo "  SKIP     $filename (not in output/ — stage not yet run)"
		return
	fi

	mkdir -p "$arc_dir"
	cp "$src" "$dest"
	echo "  ARCHIVED $filename → _archive/${ts}_${filename}"
}

archive_all() {
	local stage_dir="$1" name found=0

	echo "=== Archive: $(basename "$stage_dir") — $(date '+%Y-%m-%d %H:%M') ==="
	echo ''

	while IFS= read -r name; do
		found=1
		archive_one "$stage_dir" "$name"
	done < <(extract_output_names "$stage_dir/CONTEXT.md")

	if [[ "$found" -eq 0 ]]; then
		echo '  No output filenames in ## Outputs contract — nothing to archive.'
		return
	fi

	echo ''
	echo 'Done. Re-run the stage, then run this script without --archive to diff.'
}

# ---------------------------------------------------------------------------
# Diff mode — run after re-executing a stage
# ---------------------------------------------------------------------------

print_diff() {
	local archive="$1" current="$2"

	if diff -q "$archive" "$current" > /dev/null 2>&1; then
		echo '  No changes.'
		return 0
	fi

	# Unified diff, skip the --- / +++ file header lines
	diff -u "$archive" "$current" | tail -n +3
	return 1
}

diff_one() {
	local stage_dir="$1" filename="$2"
	local arc_dir current archive arc_basename changed=0

	arc_dir=$(output_archive_dir "$stage_dir")
	current="$stage_dir/output/$filename"
	archive=$(find_latest_archive "$arc_dir" "$filename")

	echo "--- $filename ---"

	if [[ -z "$archive" ]]; then
		echo '  No archive found. Run with --archive before re-running the stage.'
		echo ''
		return
	fi

	if [[ ! -f "$current" ]]; then
		echo '  Current output not found — stage has not been run yet.'
		echo ''
		return
	fi

	arc_basename=$(basename "$archive")
	echo "  old: $arc_basename"
	echo "  new: $filename"
	echo ''

	print_diff "$archive" "$current" || changed=1

	echo ''
	return "$changed"
}

diff_all() {
	local stage_dir="$1" name found=0 any_changed=0

	echo "=== Diff: $(basename "$stage_dir") — $(date '+%Y-%m-%d %H:%M') ==="
	echo ''

	while IFS= read -r name; do
		found=1
		diff_one "$stage_dir" "$name" || any_changed=1
	done < <(extract_output_names "$stage_dir/CONTEXT.md")

	if [[ "$found" -eq 0 ]]; then
		echo 'No output filenames in ## Outputs contract.'
	fi

	return "$any_changed"
}

# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------

usage() {
	cat <<-'EOF'
	Usage: bash diff-stage.sh <stage-path> [--archive]

	  --archive    Copy current output to output/_archive/ before re-running
	  (default)    Diff current output against the most recent archive

	Example:
	  bash diff-stage.sh stages/02_script --archive
	  # re-run the stage
	  bash diff-stage.sh stages/02_script
	EOF
}

main() {
	local stage_dir="${1:-}"
	local mode="${2:-diff}"

	if [[ -z "$stage_dir" ]]; then
		usage
		exit 2
	fi

	validate_stage_dir "$stage_dir"

	if [[ "$mode" == '--archive' ]]; then
		archive_all "$stage_dir"
		exit 0
	fi

	diff_all "$stage_dir"
	local changed=$?
	[[ "$changed" -gt 0 ]] && exit 1
	exit 0
}

main "$@"
