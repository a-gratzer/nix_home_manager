---
description: >-
  Create a structured, visual feature plan by breaking down a requested feature
  into tasks, identifying parallel work, mapping edge cases, defining the
  security surface, and optionally executing via sub-agents. Writes plan to
  .claude/plans/plan_NAME/plan.md and an interactive HTML dependency graph to
  .claude/plans/plan_NAME/plan.deps.html.

  Trigger on: plan a new feature, create a plan for, how should I implement,
  break down this feature, plan the implementation of, feature plan for,
  design a new feature, scope this feature, create an implementation plan,
  write a spec for, draft a technical design.
tools: Read, Bash, Glob, Grep
triggers:
  - "plan (a |the |this |an |our )?(new )?(feature|module|component|endpoint|service|API|integration|migration|refactor)"
  - "design (a |the |this |an |our )?(new )?(feature|module|component|endpoint|service|API)"
  - "scope (a |the |this |an |our )?(new )?(feature|module|component|endpoint)"
  - "break down (a |the |this |an |our )?(new )?(feature|task|story|epic)"
  - "create (a |the |an )?(implementation plan|plan|spec|specification|design doc|RFC)"
  - "how should (I |we )?(build|implement|add|create) .+"
  - "(write|create|draft) (a |the |an )?(spec|specification|RFC|design doc|technical design)"
  - "/plan-feature"
  - "/feature-plan"
---

# Plan Feature

Creates a structured, visual feature plan by breaking down a requested feature into tasks, identifying parallel work, mapping edge cases and security concerns, and optionally executing the plan using sub-agents.

## Step 1: Gather Requirements

Ask the user clarifying questions about the feature until the scope is clear. Cover:

- **What** — What exactly should the feature do? What is the core functionality?
- **Why** — What problem does it solve? Who is the target user?
- **Where** — Which parts of the codebase are affected? (frontend templates, backend routes, database, external integrations, etc.)
- **Dependencies** — Are there external projects, APIs, libraries, or services needed?
- **Acceptance criteria** — How do we know it's done? What are the minimum requirements?
- **Constraints** — Deadlines, infrastructure restrictions, compliance requirements?

## Step 2: Analyze the Codebase

Read the relevant parts of the codebase to understand existing patterns:

```bash
# Find similar existing features to understand patterns
ls -la src/features/ 2>/dev/null || ls -la src/modules/ 2>/dev/null || ls -la internal/ 2>/dev/null

# Check existing API conventions
grep -rn "router\.\|@Get\|@Post\|app\.\(get\|post\)" --include="*.ts" --include="*.java" --include="*.go" -l | head -5

# Check DB migration patterns
find . -path "*/migrations/*" -o -path "*/migrate/*" -o -name "*.sql" | grep -v node_modules | head -10
```

Understand and document:
- **Existing patterns to follow**: How does the codebase structure features? (controller → service → repository, handler → usecase → adapter)
- **Reusable components**: What can be reused? (auth middleware, validation schemas, DB helpers, logging setup, HTTP client wrappers)
- **Integration points**: Where will the new feature connect? (existing tables, APIs, event streams)

Ask for hints (path to relevant files) if needed.

## Step 3: Design the External Interface

Design the API contract, CLI surface, or SDK method before implementation:

### REST/GraphQL endpoints
```typescript
// POST /api/v1/webhooks
interface CreateWebhookRequest {
  url: string;
  events: WebhookEvent[];
  secret?: string;
  isActive?: boolean;
}
interface CreateWebhookResponse {
  id: string;
  url: string;
  events: WebhookEvent[];
  createdAt: string;
  isActive: boolean;
}
```

### CLI commands
```
mytool webhook create --url https://example.com/hook --events user.created,user.deleted
```

Document:
| Endpoint / Method | HTTP Verb | Input | Output | Auth | Rate Limit |
|-------------------|-----------|-------|--------|------|------------|

## Step 4: Design the Data Model

```sql
-- New table example
CREATE TABLE webhooks (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    workspace_id UUID NOT NULL REFERENCES workspaces(id) ON DELETE CASCADE,
    url TEXT NOT NULL CHECK (url ~ '^https?://'),
    events TEXT[] NOT NULL DEFAULT '{}',
    secret_hash TEXT,
    is_active BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    failure_count INTEGER NOT NULL DEFAULT 0
);
CREATE INDEX idx_webhooks_workspace_id ON webhooks(workspace_id);
```

Include a data flow diagram:

```
[User Action]
     │
     ▼
[API Gateway] ──auth──▶ [Auth Service]
     │
     ▼
[Controller] ──validate──▶ [Validation Schema]
     │
     ▼
[Service] ──persist──▶ [PostgreSQL]
     │           └──▶ [Redis cache]
     ▼
[Response]
```

## Step 5: Map Edge Cases and Failure Modes

Brainstorm edge cases upfront — categorize by type:

### Input Edge Cases
- [ ] Empty payload → return 400 with descriptive error
- [ ] Invalid format → reject with validation error
- [ ] Duplicate submission → 409 Conflict or idempotency key?
- [ ] Oversized payload → reject with clear limit

### Runtime Edge Cases
- [ ] External dependency unreachable → retry with backoff? circuit breaker?
- [ ] Database unavailable → return 503
- [ ] Concurrent requests → optimistic locking? queue?
- [ ] Partial failure (some writes succeed, others don't) → transaction rollback? compensation?

### Security Edge Cases
- [ ] SSRF potential (user-supplied URLs) → validate + blocklist internal IPs
- [ ] Secret exposure in logs → mask sensitive fields
- [ ] Replay attacks → timestamp + signature
- [ ] Privilege escalation → verify workspace/org membership per operation

Document:
| Category | Case | Severity | Mitigation |
|----------|------|----------|------------|

## Step 6: Security Checklist

Check each item for the planned feature:

- [ ] **Authentication**: Which auth is required? (session token, API key, service account?)
- [ ] **Authorization**: Which roles/permissions can access? Is it per-operation or per-endpoint?
- [ ] **Input validation**: All inputs validated at the boundary? Using shared validation schemas?
- [ ] **Rate limiting**: Per-user? Per-workspace? Per-IP? Burst allowance?
- [ ] **Audit logging**: Who created/modified/deleted? Log to immutable audit trail?
- [ ] **Secrets handling**: Any secrets in the feature? Stored encrypted? Masked in logs?
- [ ] **SSRF protection**: If feature makes outbound requests, are internal IPs blocked?
- [ ] **SQL injection**: Using parameterized queries or ORM?
- [ ] **XSS**: If rendering user content, is it sanitized?
- [ ] **CSRF**: If state-changing via browser, is CSRF token checked?

## Execution Guidance

Before implementing any step below, check for and prefer existing capabilities over writing new code from scratch:

1. **Skills** — Check both:
    - Project-local: `.claude/skills/` (or wherever this repo's skills live)
    - Global: `~/.claude/skills/` or `~/.claude/commands/skills/`

   If a skill matches a step's intent (e.g. docx/pptx/xlsx generation, PDF handling, deployment, testing conventions), read its `SKILL.md` and follow its instructions instead of improvising.

2. **Subagents** — Check both:
    - Project-local: `.claude/agents/`
    - Global: `~/.claude/agents/`

   If a subagent's description matches a step (e.g. a `code-reviewer`, `test-runner`, or `deploy` agent), delegate that step to it via the Task tool rather than doing it inline.

3. **MCP servers** — Check configured MCP servers (project `.mcp.json` and global `~/.claude.json` / settings) for tools that cover a step (e.g. GitHub, Jira, database, browser automation). Use these tools directly instead of shelling out or reimplementing equivalent functionality.

**Rule of thumb:** search for a matching skill → matching subagent → matching MCP tool → only then fall back to ad-hoc implementation. Do this check per step, not just once at the start, since later steps may need different tools than earlier ones.

## Step 7: Performance and Scaling Considerations

| Concern | Plan | Threshold |
|---------|------|-----------|
| High creation rate | Connection pooling, no row-level locks | >1000/min |
| High read volume | Pagination, cursor-based, cache | >10000 reads/min |
| Large datasets | Partitioning, TTL old data | >10M rows |
| Latency | Async dispatch, queue-based | p95 < 200ms |

## Step 8: Testing Strategy

| Layer | What to Test | Tools |
|-------|-------------|-------|
| Unit | Service logic, validation, state transitions | Mocked dependencies |
| Integration | DB operations, API endpoints, message queues | Test containers, embedded broker |
| E2E | Full lifecycle: create → trigger → verify → delete | Real or test environment |
| Performance | Sustained load, throughput measurement | k6, locust, artillery |

Note gaps in test data setup or missing test infrastructure.

## Step 9: Break Down into Tasks

Decompose the feature into discrete, actionable tasks. Each task should:
- Have a clear, one-line title
- Include a brief description of what to implement
- List the specific files that need to be created or modified
- Note any dependencies on other tasks
- Estimate relative effort (small, medium, large)

### Phase Structure

```
Phase 1: Foundation (prerequisites)
├── T1: DB migration and model types           [2h]
├── T2: Repository/DAO layer                   [3h]
└── T3: Validation schemas                     [1h]

Phase 2: Core Implementation (parallel-ready)
├── T4A: API endpoint (create)                 [4h]
├── T4B: API endpoint (list/get)               [2h]
├── T4C: API endpoint (update/delete)          [2h]
└── T5:  Service layer business logic          [4h]

Phase 3: Integration & Polish
├── T6: Integration tests                      [4h]
├── T7: E2E tests                              [3h]
├── T8: API documentation                      [2h]
├── T9: UI component (if applicable)           [6h]
└── T10: Monitoring + alerts                   [2h]

Total estimate: ~33h
```

## Step 10: Identify Parallel Work

Analyze the dependency graph and group tasks that:
- **Can run in parallel** — tasks with no interdependencies (e.g., backend endpoint + frontend component can often be done together)
- **Are sequential** — tasks that depend on another task's output (e.g., DB migration must precede repository implementation)
- **Are blocking** — tasks everything else depends on (e.g., config keys, domain models)

## Step 11: Generate the Plan Markdown File

```bash
mkdir -p .claude/plans/plan_<name>
```

Create `.claude/plans/plan_<name>/plan.md` with the following structure:

```markdown
# Feature Plan: <Feature Name>

## Overview
Brief description of the feature.

## External Interface
| Endpoint | Verb | Input | Output | Auth |
|---|---|---|---|---|

## Data Model
```sql
...
```

## Edge Cases
| Category | Case | Severity | Mitigation |
|---|---|---|---|

## Security Checklist
- [ ] Item ...

## Execution Guidance

Before implementing any step below, check for and prefer existing capabilities over writing new code from scratch:

1. **Skills** — Check both:
    - Project-local: `.claude/skills/` (or wherever this repo's skills live)
    - Global: `~/.claude/skills/` or `~/.claude/commands/skills/`

   If a skill matches a step's intent (e.g. docx/pptx/xlsx generation, PDF handling, deployment, testing conventions), read its `SKILL.md` and follow its instructions instead of improvising.

2. **Subagents** — Check both:
    - Project-local: `.claude/agents/`
    - Global: `~/.claude/agents/`

   If a subagent's description matches a step (e.g. a `code-reviewer`, `test-runner`, or `deploy` agent), delegate that step to it via the Task tool rather than doing it inline.

3. **MCP servers** — Check configured MCP servers (project `.mcp.json` and global `~/.claude.json` / settings) for tools that cover a step (e.g. GitHub, Jira, database, browser automation). Use these tools directly instead of shelling out or reimplementing equivalent functionality.

**Rule of thumb:** search for a matching skill → matching subagent → matching MCP tool → only then fall back to ad-hoc implementation. Do this check per step, not just once at the start, since later steps may need different tools than earlier ones.

## Tasks

### Phase 1: Foundation (prerequisites)
- [ ] **Task 1**: Title — Description. *Files: ...* *Effort: M*

### Phase 2: Core Implementation (parallel-ready)
- [ ] **Task 2A**: Title — Description. *Files: ...* *Effort: L*
- [ ] **Task 2B**: Title — Description. *Files: ...* *Effort: M*

### Phase 3: Integration & Polish
- [ ] **Task 3**: Title — Description. *Files: ...* *Effort: S*

## Dependency Graph

\```mermaid
graph TD
    T1[Task 1: Title] --> T2A[Task 2A: Title]
    T1 --> T2B[Task 2B: Title]
    T2A --> T3[Task 3: Title]
    T2B --> T3
\```

## Parallel Groups
- **Group 1** (parallel): Task 2A, Task 2B
- **Sequential**: Task 1 → Group 1 → Task 3

## Open Questions
1. Question for stakeholders...
2. Question for stakeholders...
```

## Step 12: Generate the Dependency Visualization HTML

Create `.claude/plans/plan_<name>/plan.deps.html` using **Mermaid.js** via CDN. This renders a clean, interactive graph showing task dependencies and parallel groups.

The HTML file must:
- Use `https://cdn.jsdelivr.net/npm/mermaid@11/dist/mermaid.min.js`
- Render a flowchart with task boxes colored by phase
- Use different colors for each phase:
    - **Foundation**: `#3B82F6` (blue)
    - **Core Implementation**: `#10B981` (green) for parallel/multiple or `#F59E0B` (amber) for single
    - **Integration & Polish**: `#8B5CF6` (purple)
- Show parallel groups visually by placing tasks side-by-side using subgraphs
- Include a legend
- Be fully self-contained (no external deps except the Mermaid CDN)

**Template for the HTML file:**

```html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Plan: <Feature Name> — Dependency Graph</title>
    <script src="https://cdn.jsdelivr.net/npm/mermaid@11/dist/mermaid.min.js"></script>
    <style>
        body { background: #f8fafc; font-family: system-ui, sans-serif; padding: 2rem; }
        .container { max-width: 1200px; margin: 0 auto; }
        h1 { color: #1e293b; font-size: 1.5rem; margin-bottom: 0.5rem; }
        .subtitle { color: #64748b; margin-bottom: 2rem; }
        .info { background: #eff6ff; border: 1px solid #bfdbfe; border-radius: 0.5rem; padding: 1rem; margin-bottom: 2rem; }
        .info h2 { font-size: 1rem; color: #1e40af; margin: 0 0 0.5rem; }
        .info ul { margin: 0; padding-left: 1.25rem; color: #1e293b; }
        .info li { margin-bottom: 0.25rem; }
        .legend { display: flex; gap: 1.5rem; flex-wrap: wrap; margin-bottom: 2rem; padding: 1rem; background: white; border-radius: 0.5rem; border: 1px solid #e2e8f0; }
        .legend-item { display: flex; align-items: center; gap: 0.5rem; font-size: 0.875rem; color: #475569; }
        .legend-swatch { width: 1rem; height: 1rem; border-radius: 0.25rem; }
        #graph { background: white; padding: 1.5rem; border-radius: 0.5rem; border: 1px solid #e2e8f0; overflow-x: auto; }
        .footer { margin-top: 2rem; font-size: 0.75rem; color: #94a3b8; text-align: center; }
    </style>
</head>
<body>
    <div class="container">
        <h1>🧩 <Feature Name></h1>
        <p class="subtitle">Task dependency graph — <created date></p>

        <div class="info">
            <h2>📋 Parallel Execution Groups</h2>
            <ul>
                <li><strong>Group 1</strong> (Foundation, sequential): Task 1 → Task 2</li>
                <li><strong>Group 2</strong> (Can run in parallel): Task 3, Task 4, Task 5</li>
                <li><strong>Group 3</strong> (Depends on Group 2): Task 6 → Task 7</li>
            </ul>
        </div>

        <div class="legend">
            <div class="legend-item"><span class="legend-swatch" style="background:#3B82F6;"></span> Foundation</div>
            <div class="legend-item"><span class="legend-swatch" style="background:#10B981;"></span> Core Implementation</div>
            <div class="legend-item"><span class="legend-swatch" style="background:#8B5CF6;"></span> Integration & Polish</div>
        </div>

        <div id="graph">
            <pre class="mermaid">
                graph TB
                    %% Styles
                    classDef foundation fill:#3B82F6,color:#fff,stroke:#2563EB,stroke-width:2px
                    classDef core fill:#10B981,color:#fff,stroke:#059669,stroke-width:2px
                    classDef integration fill:#8B5CF6,color:#fff,stroke:#7C3AED,stroke-width:2px

                    %% Tasks
                    T1[Task 1: Title]:::foundation
                    T2[Task 2: Title]:::core
                    T3[Task 3: Title]:::core
                    T4[Task 4: Title]:::integration

                    %% Dependencies
                    T1 --> T2
                    T1 --> T3
                    T2 --> T4
                    T3 --> T4
            </pre>
        </div>

        <div class="footer">
            Generated by Claude Code on <date>
        </div>
    </div>
</body>
</html>
```

## Step 13: Prepare the execution manifest

Before asking the user to execute, annotate each task in the plan with the **skill** and **subagent** it needs. This ensures every task gets the right expertise.

### Skill-to-Task Mapping

Match each task to the best-fitting skill from the project's skill library:

| Task Type | Skill to Use | Subagent Prompt Pattern |
|-----------|-------------|------------------------|
| DB migration, schema, SQL | _(stack-specific)_ | "Create the database migration for..." |
| API endpoint (REST/GraphQL) | `golang` / `java-springboot` / _(stack)_ | "Implement the POST /api/... endpoint. Follow existing controller/service/repository patterns." |
| Service/business logic | _(stack-specific)_ | "Implement the business logic for... Follow the existing service pattern." |
| Frontend component/UI | _(no dedicated skill — use general coding)_ | "Create the React component for... Match existing component patterns in the codebase." |
| Docker/build/deployment | `docker-optimization` | "Set up the Dockerfile for... and optimize using droast." |
| Kubernetes manifests | `kubernetes` | "Create the K8s deployment and service manifests for..." |
| Ansible/Infrastructure | `ansible` | "Create the Ansible playbook for..." |
| Configuration/env/secrets | _(stack-specific)_ | "Add configuration keys for... following the existing config pattern." |
| Tests (unit/integration) | _(stack-specific — same as the code under test)_ | "Write unit and integration tests for... Follow existing test patterns and naming conventions." |
| Tests (E2E) | _(general coding)_ | "Write E2E tests covering the full lifecycle of..." |
| Documentation | _(general coding)_ | "Write API documentation for... following the existing docs format." |
| Monitoring/alerts | `linux-admin` / _(stack-specific)_ | "Add monitoring metrics and alerts for..." |

**Stack-specific skills**: Use `golang` for Go projects, `java-springboot` for Spring Boot/Java, etc. If no stack-specific skill exists, delegate with detailed instructions referencing the existing codebase patterns discovered in Step 2.

### Execution Manifest Format

Produce an execution manifest that maps every task to its subagent configuration:

```markdown
## Execution Manifest

| Phase | Task | Skill | Subagent | Dependencies |
|-------|------|-------|----------|--------------|
| 1: Foundation | T1: DB migration | — | subagent-1 | — |
| 1: Foundation | T2: Repository layer | golang | subagent-2 | T1 |
| 2: Core | T3A: POST endpoint | golang | subagent-3 | T2 |
| 2: Core | T3B: GET endpoint | golang | subagent-4 | T2 |
| 2: Core | T4: Service logic | golang | subagent-5 | T2 |
| 3: Polish | T5: Integration tests | golang | subagent-6 | T3A, T3B, T4 |
| 3: Polish | T6: E2E tests | — | subagent-7 | T5 |
| 3: Polish | T7: Docker setup | docker-optimization | subagent-8 | T3A |
| 3: Polish | T8: Docs | — | subagent-9 | T3A, T3B |
```

Present this manifest to the user alongside the execution prompt.

## Step 14: Ask for Execution

After creating the plan files and execution manifest, present a summary and ask:

> "The plan and execution manifest are ready. I'll dispatch subagents with the appropriate skills to execute tasks in dependency order, running parallel groups simultaneously. Should I execute it now?"

Also ask:
> "Should I create a new branch `feature/<feature-name>` for this work, or use the current branch?"

## Step 15: Execute the Plan via Subagents and Skills

The orchestrator (you, the main agent) is responsible for phase management and integration. You **do not** implement tasks yourself — you dispatch subagents with appropriate skills.

### Orchestrator Responsibilities

- **Phase gating**: Start Phase N+1 only after all tasks in Phase N complete successfully
- **Parallel dispatch**: For tasks in the same parallel group, launch all subagents simultaneously
- **Skill injection**: Each subagent prompt includes the relevant skill's instructions and codebase context from Step 2
- **Integration**: After parallel tasks complete, review the combined output for conflicts (import collisions, overlapping file edits, schema mismatches)
- **Commit coordination**: After each phase or logical unit, use the `commit-message` skill to create a clean, conventional commit

### Subagent Dispatch Pattern

For each task, dispatch a subagent with:

1. **The skill**: Load and include the relevant skill's instructions (e.g., `golang` for Go endpoints, `docker-optimization` for Dockerfiles)
2. **Codebase context**: Existing patterns discovered in Step 2 — file conventions, naming, error handling style, test patterns, import paths
3. **The specific task**: Exactly what files to create/modify, the interface contract from Step 3, the data model from Step 4
4. **Dependencies**: Which other tasks this depends on (files those tasks created that this task needs to import or reference)
5. **Acceptance criteria**: How to verify the task is done (compile, tests pass, linter clean)

Example subagent prompt structure:

```
## Task: T3A — POST /api/v1/webhooks endpoint

### Skill: golang (Go HTTP endpoint patterns)

### Codebase Context
- Controllers live in `internal/handler/`, follow pattern: `func (h *XHandler) Create(w http.ResponseWriter, r *http.Request)`
- Services are in `internal/service/`, constructor pattern: `func NewXService(deps) *XService`
- Repositories are in `internal/repository/`, use sqlc-generated queries
- Error handling: return `internal/errors` typed errors, global middleware maps to HTTP status
- Validation: use `internal/validator` package with struct tags

### What to Implement
Create `internal/handler/webhook.go` with Create handler that:
- Accepts POST to /api/v1/webhooks
- Validates request body against CreateWebhookRequest schema
- Calls WebhookService.Create(ctx, input)
- Returns 201 with CreateWebhookResponse

### Dependencies
- T1 (DB migration) and T2 (WebhookRepository) must be complete before this runs
- Import path: `github.com/org/repo/internal/repository` for the repo

### Acceptance Criteria
- File compiles without errors
- All existing tests still pass
- New handler follows the same pattern as existing handlers (see internal/handler/user.go)
```

### Phase Execution Flow

```
Phase 1: Foundation
│
├── [subagent-1] T1: DB migration          ← no skill needed, direct task
│   └── ✅ Complete → commit via commit-message
│
├── [subagent-2] T2: Repository layer       ← golang skill
│   └── ✅ Complete → commit
│
├── Phase 1 gate: all tasks done
│
Phase 2: Core Implementation (parallel group)
│
├── [subagent-3] T3A: POST endpoint         ← golang skill ─┐
├── [subagent-4] T3B: GET endpoint          ← golang skill  ├─ dispatched simultaneously
├── [subagent-5] T4: Service logic          ← golang skill ─┘
│
├── All subagents complete → orchestrator reviews combined output
│   ├── Check for import conflicts between subagent-3, -4, -5
│   ├── Verify all new files reference each other correctly
│   ├── Run `go build ./...` to catch integration issues
│   └── ✅ Integration clean → commit via commit-message
│
Phase 3: Polish (parallel group)
│
├── [subagent-6] T5: Integration tests      ← golang skill ─┐
├── [subagent-7] T6: E2E tests              ← general       ├─ dispatched simultaneously
├── [subagent-8] T7: Docker setup           ← docker-opt.   │
├── [subagent-9] T8: Docs                   ← general       ─┘
│
├── All subagents complete → final integration review
│   ├── Run full test suite
│   ├── Verify Docker build succeeds
│   └── ✅ All green → final commit via commit-message
│
▼
Feature complete → create PR description
```

### Subagent Failure Handling

If a subagent fails (compile error, test failure, incomplete output):
1. **Single failure in a phase**: Re-dispatch only the failed task with the error output as additional context. Other completed tasks in the phase are unaffected.
2. **Blocking failure**: If a foundation task (Phase 1) fails, pause all subsequent phases until fixed. Tasks are blocked by dependency, not by phase — if T2 depends on T1 and T1 fails, T2 cannot start.
3. **Integration conflict**: If parallel subagents produce conflicting changes (same file edited differently, incompatible types), the orchestrator resolves the conflict manually or re-dispatches both subagents with the conflict context.

### Commit Strategy

After each task or logical group completes, use the `commit-message` skill:

```
[orchestrator] "I'll now create a commit for the completed T1: DB migration."
[invoke commit-message skill] → generates conventional commit
[orchestrator] commits with the generated message
```

Group commits logically: one commit per completed phase is cleaner than per-task, but don't batch unrelated work. A good pattern:
- One commit per foundation task (each is a distinct, reviewable unit)
- One commit per phase (groups related parallel work)
- One commit for tests + docs + polish

## Step 16: Final Integration and PR

After all phases complete:

1. **Run the full test suite** to confirm nothing is broken
2. **Use `commit-message` skill** to create a final integration commit if any fixups were needed
3. **Generate a PR description** summarizing:
   - What was built (from the feature plan overview)
   - Key architectural decisions made during implementation
   - Files changed (high-level, not full diff)
   - Testing performed
   - Any open questions or follow-up work
4. **Ask the user** if they want to push to remote and open a PR

## Output Files

- `.claude/plans/plan_<name>/plan.md` — Markdown plan with task list, Mermaid graph, edge cases, and security checklist
- `.claude/plans/plan_<name>/plan.deps.html` — Standalone interactive dependency graph
- `.claude/plans/plan_<name>/manifest.md` — Execution manifest mapping tasks to subagents and skills
