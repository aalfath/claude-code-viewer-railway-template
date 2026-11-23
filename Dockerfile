# Claude Code Viewer v0.8.2 (https://github.com/d-kimuson/claude-code-viewer, MIT).
# Upstream publishes no container image, so this installs the pinned npm release
# (@kimuson/claude-code-viewer@0.8.2, locked in package-lock.json) on the official Node 24 image.
# The server refuses to start on Node < 24 (node:sqlite).
FROM node:24.22.3-bookworm-slim@sha256:dc26ae92c9fb15cf6b1d63e20f0944b2efe0f115b20e00be48fb23fceb061c54

RUN apt-get update \
 && apt-get install -y --no-install-recommends git openssh-client ca-certificates tini curl \
 && rm -rf /var/lib/apt/lists/*

WORKDIR /app
COPY package.json package-lock.json ./
RUN npm ci --omit=dev --no-audit --no-fund \
 && npm cache clean --force \
 && /app/node_modules/@anthropic-ai/claude-code/bin/claude.exe --version

COPY start.sh claude-wrapper.sh /app/
RUN chmod 755 /app/start.sh /app/claude-wrapper.sh \
 && ln -s /app/claude-wrapper.sh /usr/local/bin/claude

ENV NODE_ENV=production \
    CCV_ENV=production \
    HOME=/data \
    DATA_DIR=/data \
    CCV_CC_EXECUTABLE_PATH=/app/claude-wrapper.sh \
    DISABLE_AUTOUPDATER=1 \
    CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC=1 \
    PORT=3400

EXPOSE 3400
ENTRYPOINT ["/usr/bin/tini", "-g", "--", "/app/start.sh"]
