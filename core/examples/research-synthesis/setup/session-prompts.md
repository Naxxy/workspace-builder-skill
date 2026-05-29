# Session Prompts

Copy these at the start and end of each Claude Code session.

## Session start
If `core/tools/reconcile-progress.sh` is accessible, run it first:
`bash core/tools/reconcile-progress.sh`
It compares the actual output/ directories against stage contracts and PROGRESS.md,
and prints any discrepancies with a recommended state.

If the script is not accessible: read CLAUDE.md and PROGRESS.md, then check each
stage's output/ directory against its CONTEXT.md Outputs section. If actual state
doesn't match what PROGRESS.md records, describe the discrepancy and reconcile
before asking what to do next.

## Session end
Create session-history/YYYY-MM-DD.md using core/templates/session-history.md.template.
Record: what was completed, any corrections made to stage outputs (stage name, type, description),
decisions, and what's next. Then update PROGRESS.md Current Status and Active stage.

## Before stepping away
Update PROGRESS.md Current Status in case this session ends unexpectedly.
