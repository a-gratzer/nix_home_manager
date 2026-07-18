---
description: >-
  Analyze a named feature/module in a codebase — domain entities, services,
  repositories, DTOs, data flow, dependencies, security surface, error handling,
  logging, test coverage, and Mermaid diagrams. Writes output to
  .claude/analyse/FEATURE_NAME/analysis.md. Best for Spring Boot/Java but
  works for any stack.

  Trigger on: analyze/analyse feature, feature analysis, analyze this
  module/package, document how X works, document the architecture, map out
  the module/flow, architecture overview/report, design overview, explain/
  trace the data flow, how does data come in and go out, generate a class/
  sequence/flow/dependency diagram, draw a mermaid diagram of, diagram this
  feature/module, reverse engineer this feature, onboard me to this
  codebase/module, give me an overview of this service/module. Also trigger
  on implicit requests to inspect a feature's entities, services,
  repositories, DTOs, or request/response flow, even without saying
  "analyze".
tools: Read, Bash, Glob, Grep
triggers:
  - "analyz?e (the |this |a |an |our )?(feature|module|component|endpoint|service|API|codebase|package)"
  - "document (the |this |a |an |our )?(architecture|design|module|feature)"
  - "(map out|diagram|reverse engineer) (the |this |a |an |our )?(feature|module|component)"
  - "(explain|trace|walk through) (the |this |a |an |our )?(data |code |request )?(flow|path)"
  - "how does .+ (work|fit)"
  - "onboard me to (the |this |a |an |our )?(codebase|module|feature)"
  - "(give|generate) (me )?(a |an )?(overview|diagram|report) of (the |this |a |an |our )?(service|module|feature)"
  - "what does (the |this |a |an |our )?(feature|module|endpoint|service|code) do"
  - "/analyse-feature"
  - "/feature-analysis"
---

# Feature Analysis

Produces a self-contained architecture report for one feature/module of a codebase, written to disk so it can be reused, diffed, and shared. Optimized for Spring Boot / Java projects but has a generic fallback for other stacks.

## Step 0: Establish scope

Determine the **feature name** (used as the output folder name — slug it: lowercase, hyphens, no spaces) and the **scope hint** (a package, directory, controller, topic/queue name, or keyword the user gives you).

If the user's request is vague ("analyze the payment stuff"), do a quick exploratory search first (grep for the keyword across the repo, list matching directories/packages) and confirm your interpretation in one sentence before going deep — don't ask a clarifying question if the search already makes the scope obvious.

Do not assume a repo is open — if no codebase is visible in the working directory, ask the user for the path or to open the project in Claude Code.

## Step 1: Discover the relevant files

Search broadly first, then narrow. Use `grep -ri`, `rg`, and directory listings — don't rely on filenames alone since naming conventions vary per team.

**Spring Boot / Java signals** (primary target stack):
- Entities: `@Entity`, `@Table`, `@Document` (Mongo), classes under `domain`/`entity`/`model`
- Repositories: `@Repository`, interfaces extending `JpaRepository`/`CrudRepository`/`ReactiveCrudRepository`
- Services: `@Service`, classes ending in `*Service`/`*ServiceImpl`
- Controllers / inbound HTTP: `@RestController`, `@Controller`, `@RequestMapping`, `@GetMapping`/`@PostMapping`/etc.
- Messaging inbound/outbound: `@RabbitListener`, `@KafkaListener`, `RabbitTemplate`/`KafkaTemplate` usage, `@JmsListener`
- DTOs: classes ending in `*Dto`/`*DTO`/`*Request`/`*Response`, or `record` types used at controller/service boundaries
- Mappers: MapStruct `@Mapper` interfaces, or manual `toDto()`/`toEntity()` methods
- Config/wiring: `@Configuration`, `@Bean`, `application.yml`/`application.properties` keys relevant to the feature

**Generic fallback** (Node/Express, Python/Django/FastAPI, Go, Rust, etc.): look for the equivalent layering — route/handler layer (inbound), service/use-case layer (business logic), data-access layer (repository/DAO/ORM model), and the schema/type definitions passed across boundaries (DTOs/serializers/schemas).

Build a file list before writing anything. If the feature spans multiple modules/services, note that explicitly and scope the report accordingly (don't silently drop parts of it).

## Step 2: Extract the substance

For each file/class found, capture only what's needed for the report sections below — don't paste entire file contents into your findings, summarize with the specific detail that matters (field names/types on entities, method signatures on services/repos, HTTP verb+path or queue/topic name on entry points).

Trace the **data flow** end to end:
- **Inbound**: what triggers this feature — HTTP request, message consumed, scheduled job, event. What shape does the data arrive in (DTO/request body/message payload)? What validation happens?
- **Processing**: which service(s) orchestrate the logic, what domain/entity objects are touched, any transactions, external calls, or side effects (events published, cache writes).
- **Outbound**: what's returned/emitted — HTTP response DTO, message published, DB rows written, event emitted. Include downstream consumers if visible in the code (e.g., who else listens to a queue this feature publishes to).

## Step 3: Collect dependencies and versions

Look at the build file (`pom.xml`, `build.gradle`/`build.gradle.kts`, `package.json`, `requirements.txt`/`pyproject.toml`, `go.mod`, etc.) and list only the dependencies actually relevant to this feature (e.g., don't dump the whole `pom.xml` — filter to things like spring-boot-starter-amqp, spring-data-jpa, mapstruct, the specific DB driver, messaging client libs) along with their resolved versions. If a version is inherited from a parent BOM/parent POM rather than pinned locally, say so rather than guessing a number.

## Step 4: Map error handling

Find and catalog all error paths:

```bash
grep -rn "throw\|reject\|return.*error\|res\.status\([45]\|http\.Status\|Error(\|Err(" --include="*.java" --include="*.ts" --include="*.go" <feature-files>
```

Document each error case:

| Error | Condition | HTTP Status | User-Visible? | Recovery |
|-------|-----------|-------------|---------------|----------|
| `InvalidTokenException` | Token expired/malformed | 401 | Yes | Re-login |
| `EntityNotFoundException` | Resource missing | 404 | Yes | None |
| `ServiceUnavailableException` | DB unreachable | 503 | No (generic) | Retry with backoff |

Note where errors are silently swallowed (empty catch blocks), where they propagate without context, and whether there's a global exception handler.

## Step 5: Review security surface

Identify security-relevant code:

```bash
# Auth / permission checks
grep -rn "auth\|authenticate\|authorize\|permission\|role\|canAccess\|@PreAuthorize\|@Secured" --include="*.java" --include="*.ts" --include="*.go" <feature-files>

# Input validation
grep -rn "validate\|sanitize\|escape\|@Valid\|@NotNull\|@NotEmpty\|@Size\|@Pattern" --include="*.java" --include="*.ts" <feature-files>

# Secrets in code
grep -rn "password\|secret\|apiKey\|api_key\|token\|credential\|private.*key" --include="*.java" --include="*.ts" --include="*.py" <feature-files> | grep -v "process\.env\|Env\.\|config\.\|@Value"
```

Checklist:
- [ ] Authentication required at all entry points?
- [ ] Authorization checked per-operation (not just per-endpoint)?
- [ ] Input validated at the boundary (not just in the DB)?
- [ ] Sensitive data masked in logs?
- [ ] SQL/NoSQL injection protection (parameterized queries)?
- [ ] Secrets hardcoded anywhere?

## Step 6: Review logging and observability

```bash
# Logging
grep -rn "log\.\|logger\.\|LOGGER\|log.info\|log.warn\|log.error\|slog\.\|console\.log" --include="*.java" --include="*.ts" --include="*.go" <feature-files>

# Metrics / tracing
grep -rn "metrics\|tracing\|span\|meter\|counter\|histogram\|@Timed\|@Counted" --include="*.java" --include="*.ts" <feature-files>
```

Document:

| What's Logged | Level | Contains PII? | Actionable? |
|---------------|-------|---------------|-------------|
| Login attempt | info | email (masked) | Yes (monitor failures) |
| Auth failure | warn | IP address | Yes (alert on spike) |

Note gaps: places where a failure path has no log, or where success isn't logged at all.

## Step 7: Assess test coverage

```bash
# Find test files
find . -path "*/test*" -o -path "*/__tests__*" -o -path "*/spec*" -o -name "*.test.*" -o -name "*.spec.*" -o -name "*Test.java" -o -name "*Tests.java" | grep -v node_modules
```

Document:

| Coverage Area | Tests Found | Missing Scenarios |
|---------------|-------------|-------------------|
| Happy path | 3 | — |
| Auth errors | 2 | Token expiry edge case |
| Input validation | 1 | XSS injection, oversized payload |
| DB failures | 0 | **GAP** — no DB error tests |
| Race conditions | 0 | **GAP** — concurrent requests |

## Step 8: Build the Mermaid diagrams

Produce all four, scoped to this feature only (don't try to diagram the whole codebase):

1. **Dependency graph** — this feature's classes/modules and the external libraries/other internal modules they depend on. `graph LR` or `graph TD`.
2. **Class diagram** — entities, DTOs, services, repositories relevant to the feature and their relationships (composition, implements, uses). `classDiagram`.
3. **Sequence diagram** — the primary happy-path flow from trigger (controller/listener) through service → repository/external call → response, for the main use case(s). `sequenceDiagram`.
4. **Flow diagram** — the data/decision flow including branches (validation failure, retry/DLQ paths, conditional logic). `flowchart TD`.

Keep each diagram readable — 8–15 nodes is usually the sweet spot. If a feature is large, split into "core flow" + call out that edge cases are omitted, rather than cramming everything into one unreadable diagram.

Mermaid syntax reminders:
- `classDiagram` relationship arrows: `-->` association, `--|>` inheritance, `--*` composition, `..>` dependency
- `sequenceDiagram` uses `participant`, `->>` for calls, `-->>` for returns, `Note over` for annotations
- Wrap diagrams in ` ```mermaid ` code fences in the output file — they render directly in most Markdown viewers and in Claude Code's UI

## Step 9: Write the report

Create the output directory and file:

```bash
mkdir -p .claude/analyse/<feature>
```

Write `.claude/analyse/<feature>/analysis.md` using this structure:

```markdown
# <Feature Name> — Architecture Analysis

## Short Description
One or two sentences: what this feature does, in plain terms.

## Long Description
A few paragraphs: purpose, where it sits in the system, key business rules,
notable design decisions or constraints found in the code (comments, TODOs,
non-obvious config).

## Domain Objects & Entities
| Entity | Fields (key ones) | Notes |
|---|---|---|

## Services
| Service | Responsibility | Key methods |
|---|---|---|

## Repositories
| Repository | Backing entity | Notable queries |
|---|---|---|

## DTOs
| DTO | Used at | Shape (key fields) |
|---|---|---|

## Data Flow
### Inbound
...

### Processing
...

### Outbound
...

## Dependencies
| Dependency | Version | Purpose | Source (pinned / inherited) |
|---|---|---|---|

## Error Handling
| Error | Condition | HTTP Status | User-Visible? | Recovery |
|---|---|---|---|---|

## Security Review
- [ ] Item
- [ ] Item

## Logging & Observability
| What's Logged | Level | Contains PII? | Actionable? |
|---|---|---|---|

## Test Coverage
| Coverage Area | Tests Found | Missing Scenarios |
|---|---|---|

## Diagrams

### Dependency Graph
```mermaid
graph LR
...
```

### Class Diagram
```mermaid
classDiagram
...
```

### Sequence Diagram
```mermaid
sequenceDiagram
...
```

### Flow Diagram
```mermaid
flowchart TD
...
```

## Findings & Recommendations
Bulleted list of the most notable observations — surprising dependencies,
missing tests, risky patterns (queue with no DLQ, no global exception
handler), configuration smells, or security gaps.
```

## Step 10: Wrap up

Tell the user where the file was written and give a one-paragraph summary of the most interesting finding (a surprising dependency, a missing test, a risky pattern like a queue with no DLQ) rather than just repeating the file path. If something couldn't be determined from the code (e.g. a version number, an external consumer of a published event), say so explicitly in the report instead of guessing.

If the user has an existing house style for docs (e.g. from other `.claude/` conventions in the repo), match it.
