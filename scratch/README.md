# /scratch

Temporary working directory for subagent outputs, experiments, and intermediate analysis.

**Rules** (from CLAUDE.md Section 4.2):
- Subagent outputs >50 lines go here as files.
- Never pollute the real codebase with scratch files.
- Files here are ephemeral — do not depend on them persisting across sessions.
- Clean up after tasks complete if files are no longer needed.

**Gitignore**: All files in this directory are ignored except `.gitkeep` and this README.
