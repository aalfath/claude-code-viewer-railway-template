#!/bin/sh
# Claude Code Viewer starts one Claude Code process per session (about 250 MB each).
# If the service runs out of memory, the kernel should end a session, not the web server,
# so each Claude Code process volunteers as the first OOM victim.
echo 900 > /proc/self/oom_score_adj 2>/dev/null || true
exec /app/node_modules/@anthropic-ai/claude-code/bin/claude.exe "$@"
