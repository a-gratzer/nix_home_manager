---
description: Lint and optimize Dockerfiles using dockerfile-roast (droast), then apply manual hardening improvements. Covers Dockerfiles and docker-compose files.
tools: Read, Write, Edit, Bash, Glob, Grep
triggers:
  - "optimize (my |the |this |our )?dockerfile"
  - "optimize (my |the |this |our )?docker file"
  - "optimize (my |the |this |our )?docker-compose"
  - "optimize (my |the |this |our )?compose file"
  - "dockerfile (optimiz|improv|review|lint|harden|audit|check|fix|clean)"
  - "docker-compose (optimiz|improv|review|lint|harden|audit|check|fix|clean)"
  - "(optimiz|improv|review|lint|harden|audit|check|fix|clean) (my |the |this |our )?dockerfile"
  - "(optimiz|improv|review|lint|harden|audit|check|fix|clean) (my |the |this |our )?docker-compose"
  - "(optimiz|improv|review|lint|harden|audit|check|fix) (my |the |this |our )?docker (image|container|build)"
  - "docker (image|container) (optimiz|improv|size|security|hardening)"
  - "droast"
  - "dockerfile(-| )?roast"
  - "multi-stage (build|docker)"
  - "docker layer (cach|optimiz)"
  - "reduce docker image size"
  - "docker best practice"
  - "containerize"
  - "dockerize"
  - "scan (my |the |this )?docker"
  - "docker (security|vulnerability) (scan|check|audit)"
---

# Docker Optimization Skill

Use this skill whenever you need to review, lint, or optimize Dockerfiles or docker-compose files. Always run droast first to catch baseline issues, then apply manual enhancements.

## Step 1: Lint with droast

Find the Dockerfile(s) and docker-compose file(s) in scope, then run droast on each Dockerfile.

### Basic lint (with roast — playful feedback)
```bash
# Dockerfile in current directory
docker run --rm -v "$(pwd)/Dockerfile":/Dockerfile ghcr.io/immanuwell/droast /Dockerfile

# Any path
docker run --rm -v /path/to/Dockerfile:/Dockerfile ghcr.io/immanuwell/droast /Dockerfile
```

### Serious lint (no roast, only issues)
```bash
docker run --rm -v "$(pwd)/Dockerfile":/Dockerfile ghcr.io/immanuwell/droast \
    --no-roast --min-severity warning /Dockerfile
```

### Batch lint multiple Dockerfiles
```bash
for f in $(find . -name 'Dockerfile*' -type f); do
  echo "=== $f ==="
  docker run --rm -v "$(realpath "$f")":/Dockerfile ghcr.io/immanuwell/droast --no-roast /Dockerfile
done
```

## Step 2: Analyze droast Output

Review every warning/error from droast. Common issues and their fixes:

| Issue | Fix |
|-------|-----|
| `:latest` tag | Pin to specific version or digest |
| Multiple `RUN` lines | Combine with `&& \` |
| `apt-get install` without cleanup | Add `rm -rf /var/lib/apt/lists/*` in same layer |
| Missing `--no-install-recommends` | Add the flag |
| `ADD` used for local files | Replace with `COPY` |
| Root user at runtime | Add `USER` directive after creating non-root user |
| No `.dockerignore` | Create one with node_modules, .git, build artifacts |
| Large image | Switch to alpine/distroless base, use multi-stage builds |

## Step 3: Apply Manual Optimizations

After droast fixes, apply these additional improvements:

### 3a. Layer ordering
Ensure instructions are ordered from least-frequent to most-frequent changes:
1. Base image
2. System packages / tools
3. Dependency manifests + install
4. Application source
5. Build / compile
6. Runtime configuration

### 3b. Multi-stage conversion
If the Dockerfile isn't multi-stage and uses build tools, convert it:
- **Stage 1 (builder)**: install build deps, compile
- **Stage 2 (runtime)**: copy only the artifact, minimal deps only

### 3c. Security hardening
```dockerfile
# Add non-root user
RUN addgroup -S app && adduser -S app -G app
USER app

# Or with UID for K8s compatibility
RUN addgroup -g 1000 app && adduser -u 1000 -G app -S app
USER 1000:1000
```

Add HEALTHCHECK if missing:
```dockerfile
HEALTHCHECK --interval=30s --timeout=3s --retries=3 \
    CMD wget -qO- http://localhost:8080/health || exit 1
```

### 3d. BuildKit cache mounts (Go, npm, pip, apt)
```dockerfile
# Go
RUN --mount=type=cache,target=/root/.cache/go-build \
    --mount=type=cache,target=/go/pkg/mod \
    go build -o /app ./cmd/server

# npm
RUN --mount=type=cache,target=/root/.npm \
    npm ci --production

# apt
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt,sharing=locked \
    apt-get update && apt-get install -y --no-install-recommends curl
```

### 3e. .dockerignore
Create or update `.dockerignore`:
```
.git
.gitignore
*.md
README*
node_modules
.venv
__pycache__
*.pyc
.env
*.log
Dockerfile*
docker-compose*
.dockerignore
dist
build
target          # Maven/Gradle
.idea
.vscode
.cache
```

## Step 4: docker-compose Specific Checks

For docker-compose files, check:

- [ ] Remove `version:` key (deprecated in Compose v2)
- [ ] Named volumes for all persistent data
- [ ] `restart: unless-stopped` on production services
- [ ] `healthcheck` on stateful services (DB, cache)
- [ ] `depends_on` with `condition: service_healthy`
- [ ] Resource limits set (`deploy.resources.limits`)
- [ ] No hardcoded secrets (use `${VAR}` from `.env` or Docker secrets)
- [ ] Internal networks for services that don't need external access
- [ ] Ports only exposed where necessary
- [ ] `docker compose config` passes without errors

## Step 5: Final Verification

```bash
# Validate compose file
docker compose config --quiet

# Build and check image size
docker build -t test-image .
docker image inspect test-image | jq '.[0].Size' | numfmt --to=iec

# Security scan
docker scout quickview test-image 2>/dev/null || echo "docker scout not available"
```

## Summary

After running this skill, present:
1. **droast findings** — what was flagged and how it was fixed
2. **Layer optimization** — before/after layer count
3. **Security improvements** — non-root user, HEALTHCHECK, pinned versions
4. **Size reduction** — estimated savings from multi-stage/slim base
5. **Any remaining recommendations** — things that need human judgment (e.g., custom base image tradeoffs)
