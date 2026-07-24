---
name: docker-optimization
description: >-
  Lint, harden, and optimize Dockerfiles and docker-compose files — reducing
  image size, improving security, and following best practices. Runs droast
  (dockerfile-roast) for automated linting, then applies manual hardening.
  Use this skill whenever the user mentions Docker optimization, Dockerfile
  review, Docker linting, reducing image size, container security, Docker
  best practices, multi-stage builds, layer caching, docker-compose
  improvements, droast, containerizing an application, or scanning Docker
  images for vulnerabilities. Also trigger on phrases like "optimize my
  Docker build", "review this Dockerfile", "harden this container",
  "dockerize this app", or "make my image smaller". The skill produces
  before/after size comparisons with concrete metrics.
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

## Step 5: Before vs. After — Capture Baseline, Then Compare

**IMPORTANT**: You must capture the baseline BEFORE making changes, then build again AFTER to produce concrete metrics.

### 5a. Capture baseline (before any changes)
```bash
# Record original image size (if image exists)
ORIGINAL_IMAGE="<existing-image:tag>"
docker image inspect "$ORIGINAL_IMAGE" 2>/dev/null | jq '.[0].Size' | numfmt --to=iec || echo "no existing image"

# Or build the original Dockerfile and measure
docker build -t app:before -f Dockerfile .
BEFORE_SIZE=$(docker image inspect app:before | jq '.[0].Size')
BEFORE_LAYERS=$(docker history app:before | tail -n +2 | wc -l)
echo "BEFORE: size=$(echo $BEFORE_SIZE | numfmt --to=iec) layers=$BEFORE_LAYERS"

# Count original RUN/COPY/ADD instructions
BEFORE_INSTRUCTIONS=$(grep -cE '^(RUN|COPY|ADD) ' Dockerfile)
echo "BEFORE: instructions=$BEFORE_INSTRUCTIONS"
```

### 5b. Apply all optimizations from Steps 1–4
Make each fix, document what was changed, then apply the next.

### 5c. Build optimized image and compare
```bash
# Build optimized image
docker build -t app:after -f Dockerfile .
AFTER_SIZE=$(docker image inspect app:after | jq '.[0].Size')
AFTER_LAYERS=$(docker history app:after | tail -n +2 | wc -l)
echo "AFTER: size=$(echo $AFTER_SIZE | numfmt --to=iec) layers=$AFTER_LAYERS"

# Count optimized instructions
AFTER_INSTRUCTIONS=$(grep -cE '^(RUN|COPY|ADD) ' Dockerfile)
echo "AFTER: instructions=$AFTER_INSTRUCTIONS"

# Calculate savings
SAVED_BYTES=$((BEFORE_SIZE - AFTER_SIZE))
SAVED_PCT=$(echo "scale=1; ($BEFORE_SIZE - $AFTER_SIZE) * 100 / $BEFORE_SIZE" | bc)
echo "SAVED: $(echo $SAVED_BYTES | numfmt --to=iec) ($SAVED_PCT%)"

# Validate compose (if applicable)
docker compose config --quiet 2>/dev/null && echo "compose: valid" || true
```

### 5d. Security scan (if available)
```bash
docker scout quickview app:after 2>/dev/null || echo "docker scout not available"
# Fallback: check for common issues
docker run --rm app:after whoami 2>/dev/null && echo "WARNING: may be running as root" || true
```

---

## Final Report Template

After completing all steps, present this structured summary:

```
## 📊 Docker Optimization Report

### Size
| Metric       | Before     | After      | Change      |
|-------------|-----------|------------|-------------|
| Image size  | xxx MB    | xxx MB     | **-xx%**    |
| Layers      | xx        | xx         | -x          |

### Droast Issues Fixed
| # | Issue | Fix Applied |
|---|-------|-------------|
| 1 | `<droast finding>` | `<what was changed>` |
| 2 | ... | ... |

### Security Improvements
- [x] Non-root user added (`USER 1000:1000`)
- [x] Base image pinned to digest
- [x] HEALTHCHECK added
- [x] apt cache cleaned in same layer (`--no-install-recommends` + `rm -rf /var/lib/apt/lists/*`)
- [x] `.dockerignore` created/updated

### Build Optimizations
- [x] Multi-stage build (if converted)
- [x] Layer ordering optimized (deps before source)
- [x] BuildKit cache mounts added (if applicable)
- [x] Binary stripped (`-ldflags="-s -w"` for Go, `--no-install-recommends` for apt)

### docker-compose Improvements (if applicable)
- [x] Removed deprecated `version:` key
- [x] Added `restart: unless-stopped`
- [x] Added resource limits
- [x] Added healthchecks for stateful services
- [x] Named volumes for persistent data

### Recommendations (human judgment needed)
- `<any remaining issues that need user decision>`
```

**Always include concrete before/after numbers. Never present a report without measured size savings and layer count reduction.**
