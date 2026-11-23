# Deploy and Host Claude Code Viewer on Railway

Claude Code Viewer is an open-source web client for Claude Code, Anthropic's coding agent. It lists your Claude Code projects and sessions, shows each conversation in full with tool calls and diffs, and lets you start, resume and schedule sessions, review Git changes and use a built-in terminal from any browser, including as a phone app (PWA).

## About Hosting Claude Code Viewer

This template runs one service: Claude Code Viewer v0.8.2 with the Claude Code CLI it needs, built from our public GitHub repo on the official Node.js 24 image. It listens on Railway's port, answers a health check at `/api/version`, and keeps everything on a volume at `/data`: Claude Code's sessions (`~/.claude`), the viewer's cache and schedules, and the projects you work on in `/data/workspace`. The UI and API are locked with a generated password. You bring an Anthropic API key. After deploy, open the URL, sign in, add a project path under `/data/workspace` (clone one in the built-in terminal) and start a session.

## Common Use Cases

* Run Claude Code on a server and drive it from a browser or phone instead of a local terminal
* Browse, search and export Claude Code session history with every tool call and diff
* Schedule recurring Claude Code prompts and review the resulting Git changes before pushing

## Dependencies for Claude Code Viewer Hosting

* An Anthropic API key (from console.anthropic.com) for the sessions Claude Code runs
* A Railway volume for sessions, settings and project files (created by the template)

### Deployment Dependencies

* Claude Code Viewer: https://github.com/d-kimuson/claude-code-viewer
* Template repo: https://github.com/aalfath/claude-code-viewer-railway-template
* Anthropic API keys: https://console.anthropic.com/settings/keys

### Implementation Details

**After deploy:** find the password in the service's Variables tab as `CCV_PASSWORD` and sign in. The first screen asks for the authentication mode: pick **API Key**. To work on a repo, open the terminal panel at the bottom, run `git clone https://github.com/YOUR-USER/YOUR-REPO` inside `/data/workspace`, then add the project path `/data/workspace/YOUR-REPO`. Private repos need a token or deploy key you add yourself.

**Variables:** `ANTHROPIC_API_KEY` is the only prompt. `ANTHROPIC_BASE_URL` is optional, for an Anthropic-compatible gateway. `CCV_PASSWORD` is generated; it also works as `Authorization: Bearer YOUR-PASSWORD` for the API.

**Memory:** the web server uses about 140 MB, and each open Claude Code session about 250 MB while it stays open. On Railway's Free and Trial plans (0.5 GB) one session at a time fits; if more are opened, the kernel ends a Claude Code session process rather than the web server, which keeps running. Use 1 GB or more (Hobby plan) for two or three sessions at once.

**Security:** anyone with the password can run commands in the container and spend your API key. Keep the password private and rotate it in Variables if it leaks. The built-in terminal is a restricted bash shell running as an unprivileged user.

**Updates:** the template builds from a GitHub repo, so Railway shows an "update available" notice when we publish a new Claude Code Viewer version; read the repo's CHANGELOG.md before you apply it. Your `/data` volume is kept.

## Why Deploy Claude Code Viewer on Railway?

<!-- Recommended: Keep this section as shown below -->
Railway is a singular platform to deploy your infrastructure stack. Railway will host your infrastructure so you don't have to deal with configuration, while allowing you to vertically and horizontally scale it.

By deploying Claude Code Viewer on Railway, you are one step closer to supporting a complete full-stack application with minimal burden. Host your servers, databases, AI agents, and more on Railway.
<!-- End recommended section -->
