#!/bin/sh
# Start Claude Code Viewer on Railway.
# - Everything (Claude Code sessions in ~/.claude, the viewer's cache.db and schedules in
#   ~/.claude-code-viewer, and the projects you work on in /data/workspace) lives on the /data volume.
# - Refuses to start without CCV_PASSWORD, so the UI and API are never open.
# - Runs the app as the unprivileged "node" user (Claude Code refuses some modes as root).
# - Any failure exits non-zero so Railway's ON_FAILURE restart policy restarts it.
set -eu

DATA_DIR="${DATA_DIR:-/data}"
PORT="${PORT:-3400}"

if [ -z "${CCV_PASSWORD:-}" ]; then
  echo "CCV_PASSWORD is empty: refusing to start an unprotected Claude Code Viewer." >&2
  exit 1
fi

# Empty optional variables would be passed to Claude Code as "set but empty": drop them.
for v in ANTHROPIC_API_KEY ANTHROPIC_BASE_URL ANTHROPIC_AUTH_TOKEN ANTHROPIC_MODEL ANTHROPIC_SMALL_FAST_MODEL; do
  eval "val=\${$v:-}"
  [ -z "$val" ] && unset "$v"
done
# Railway's Docker HOSTNAME is the container id; the server reads HOSTNAME as its bind address.
unset HOSTNAME

mkdir -p "$DATA_DIR/.claude/projects" "$DATA_DIR/.claude-code-viewer" "$DATA_DIR/workspace"
if [ ! -f "$DATA_DIR/.gitconfig" ]; then
  # Keep git's pack work small on 0.5 GB plans.
  cat > "$DATA_DIR/.gitconfig" <<'G'
[pack]
	threads = 1
	windowMemory = 64m
[core]
	packedGitLimit = 64m
	packedGitWindowSize = 16m
[init]
	defaultBranch = main
G
fi
if [ "$(id -u)" = "0" ]; then
  # Railway mounts the volume as root: hand anything not yet owned to the app user.
  find "$DATA_DIR" -xdev ! -user node -exec chown -h node:node {} +
fi

cd "$DATA_DIR/workspace"
set -- node /app/node_modules/@kimuson/claude-code-viewer/dist/main.js --hostname :: --port "$PORT"
if [ "$(id -u)" = "0" ]; then
  exec setpriv --reuid=node --regid=node --init-groups env HOME="$DATA_DIR" USER=node "$@"
fi
exec "$@"
