# Changelog

## 0.8.2 (2026-11-23)

- First release of the template: Claude Code Viewer v0.8.2 with Claude Code 2.1.220 on `node:24.22.3-bookworm-slim@sha256:dc26ae92c9fb15cf6b1d63e20f0944b2efe0f115b20e00be48fb23fceb061c54`.
- All state on the `/data` volume; the UI is locked with a generated `CCV_PASSWORD`; the server refuses to start without it.
- The app runs as the unprivileged `node` user; Claude Code processes get a high OOM score so the web server survives memory pressure on 0.5 GB plans.
