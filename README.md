[![Deploy on Railway](https://railway.com/button.svg)](https://railway.com/new/template/claude-code-viewer?utm_medium=integration&utm_source=button&utm_campaign=claude-code-viewer)

# Claude Code Viewer on Railway

One-click Railway template for [Claude Code Viewer](https://github.com/d-kimuson/claude-code-viewer) **v0.8.2** (MIT): a web client for Claude Code. Browse and search your Claude Code sessions, start or resume them, schedule prompts, review Git diffs and use a terminal, all from a browser or phone.

## What it deploys

| Service | What it does |
|---|---|
| **Claude Code Viewer** | The web UI and API on Railway's port, with the Claude Code CLI 2.1.220 it drives. Built from this repo's `Dockerfile`: the npm release `@kimuson/claude-code-viewer@0.8.2` (locked in `package-lock.json`) on `node:24.22.3-bookworm-slim@sha256:dc26ae92c9fb15cf6b1d63e20f0944b2efe0f115b20e00be48fb23fceb061c54`. Upstream publishes no container image, and the server needs Node 24. |
| Volume `/data` | Everything that must survive a redeploy: Claude Code sessions and settings (`/data/.claude`, `/data/.claude.json`), the viewer's cache and schedules (`/data/.claude-code-viewer`) and your projects (`/data/workspace`). |

Health check: `GET /api/version` (no login needed). Restart policy: on failure. Any crash of the web server exits non-zero so Railway restarts it.

## Variables

| Variable | Default | Notes |
|---|---|---|
| `ANTHROPIC_API_KEY` | *(you enter it)* | Your Anthropic API key from https://console.anthropic.com/settings/keys. Claude Code uses it for every session. |
| `CCV_PASSWORD` | `${{secret(24)}}` | Generated sign-in password for the UI. Also accepted as `Authorization: Bearer <password>` on the API. The server refuses to start without it. |
| `ANTHROPIC_BASE_URL` | empty | Optional: an Anthropic-compatible gateway URL. Leave empty for Anthropic's API. |
| `PORT` | `3400` | Port the server listens on. |

## After deploy

1. Open the public URL and sign in with `CCV_PASSWORD` (Variables tab).
2. Choose **API Key** as the authentication mode.
3. Open the terminal panel at the bottom, `git clone` a repo into `/data/workspace`, then add the project path (for example `/data/workspace/my-repo`) and start a session.

Private repos need a token or deploy key you add yourself. The terminal is a restricted bash running as the unprivileged `node` user.

## Memory

The web server uses about 140 MB. Each open Claude Code session runs its own Claude Code process of about 250 MB, which stays alive while the session is open. On Railway's Free/Trial plan (0.5 GB) one session at a time fits. Each Claude Code process runs with a high OOM score (`claude-wrapper.sh`), so if memory runs out the kernel ends a session, not the web server. For two or three parallel sessions give the service 1 GB or more (Hobby plan).

## Updates

The service builds from this repo's `main` branch. When we bump Claude Code Viewer, Railway shows deployers an "update available" notice; read [CHANGELOG.md](CHANGELOG.md) first (breaking changes are listed first). The `/data` volume is kept across updates.

To bump the version yourself: change the version in `package.json`, regenerate `package-lock.json` with `npm install --package-lock-only` on Node 24, and redeploy.

## Testing

`test/compose.yml` runs the image locally at 512 MB next to a small stub of the Anthropic Messages API (`test/anthropic-stub`), so a session can be started without a real key. The stub is not part of the template.

## Licence

Claude Code Viewer is MIT-licensed by its authors. Claude Code is Anthropic's software under Anthropic's terms; using it with an API key is subject to Anthropic's Commercial Terms. This wrapper repo is MIT.
