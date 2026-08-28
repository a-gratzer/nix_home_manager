---
name: golang
description: >-
  Go development patterns and conventions — module initialization, HTTP server
  setup with stdlib, database integration via sqlc, table-driven testing, race
  condition detection, profiling, and optimized Docker builds. Use this skill
  whenever the user is working with Go code: creating a new Go project,
  adding HTTP endpoints, setting up database access, writing Go tests,
  debugging race conditions, profiling Go performance, or building Go
  Docker images. Also trigger on phrases like "create a Go service", "add
  an API in Go", "set up a Go module", "write Go tests", "profile this Go
  app", or any task where Go conventions and idioms matter.
---

# Go Development Skills

This skill covers Go development patterns optimized for production services. Each section is self-contained — use the one that matches the current task. The patterns emphasize stdlib-first (avoid unnecessary framework dependencies), clear project layout (cmd/internal/pkg), and production readiness (structured logging, health checks, graceful shutdown).

## Skill: Initialize a New Go Module

```bash
go mod init github.com/org/repo
```

Create standard directories:
```bash
mkdir -p cmd/server internal/handler internal/service internal/repository pkg/config api
```

Create `cmd/server/main.go`:
```go
package main

import (
    "log/slog"
    "os"
)

func main() {
    logger := slog.New(slog.NewJSONHandler(os.Stdout, nil))
    logger.Info("starting server")

    // Initialize and run server
    if err := run(); err != nil {
        logger.Error("server failed", "error", err)
        os.Exit(1)
    }
}

func run() error {
    // Setup and start HTTP server
    return nil
}
```

## Skill: Add HTTP Endpoint (stdlib)

```go
// internal/handler/user.go
package handler

import (
    "encoding/json"
    "net/http"
)

type UserHandler struct {
    svc UserService
}

func NewUserHandler(svc UserService) *UserHandler {
    return &UserHandler{svc: svc}
}

func (h *UserHandler) Create(w http.ResponseWriter, r *http.Request) {
    var req CreateUserRequest
    if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
        http.Error(w, `{"error":"invalid request"}`, http.StatusBadRequest)
        return
    }

    user, err := h.svc.Create(r.Context(), req)
    if err != nil {
        http.Error(w, `{"error":"`+err.Error()+`"}`, http.StatusInternalServerError)
        return
    }

    w.Header().Set("Content-Type", "application/json")
    w.WriteHeader(http.StatusCreated)
    json.NewEncoder(w).Encode(user)
}
```

## Skill: Add Database Integration

Using `sqlc` (preferred):
```bash
# Install sqlc
go install github.com/sqlc-dev/sqlc/cmd/sqlc@latest

# Initialize
sqlc init
```

Create `internal/repository/query.sql`:
```sql
-- name: GetUser :one
SELECT * FROM users WHERE id = $1;

-- name: ListUsers :many
SELECT * FROM users ORDER BY created_at DESC LIMIT $1 OFFSET $2;

-- name: CreateUser :one
INSERT INTO users (name, email) VALUES ($1, $2) RETURNING *;
```

Config `sqlc.yaml`:
```yaml
version: "2"
sql:
  - engine: "postgresql"
    queries: "internal/repository/query.sql"
    schema: "migrations/"
    gen:
      go:
        package: "repository"
        out: "internal/repository"
        emit_json_tags: true
```

Generate:
```bash
sqlc generate
```

## Skill: Write Table-Driven Tests

```go
func TestCreateUser(t *testing.T) {
    tests := []struct {
        name    string
        input   CreateUserRequest
        wantErr bool
        want    string
    }{
        {
            name:    "valid user",
            input:   CreateUserRequest{Name: "Alice", Email: "alice@example.com"},
            wantErr: false,
            want:    "Alice",
        },
        {
            name:    "empty name",
            input:   CreateUserRequest{Name: "", Email: "bob@example.com"},
            wantErr: true,
        },
        {
            name:    "invalid email",
            input:   CreateUserRequest{Name: "Bob", Email: "not-an-email"},
            wantErr: true,
        },
    }

    for _, tt := range tests {
        t.Run(tt.name, func(t *testing.T) {
            svc := NewService(testRepo())
            user, err := svc.Create(context.Background(), tt.input)
            if tt.wantErr {
                assert.Error(t, err)
                return
            }
            assert.NoError(t, err)
            assert.Equal(t, tt.want, user.Name)
        })
    }
}
```

## Skill: Race Condition Detection

```bash
# Run tests with race detector
go test -race ./...

# Run specific test with race
go test -race -run TestConcurrent -count=10 ./pkg/...

# Build with race (for binaries)
go build -race -o bin/app ./cmd/server
```

## Skill: Profile Go Application

```bash
# CPU profile
go test -cpuprofile=cpu.prof -bench=. ./pkg/...
go tool pprof -http=:8081 cpu.prof

# Memory profile
go test -memprofile=mem.prof -bench=. ./pkg/...
go tool pprof -http=:8081 mem.prof

# In production (with net/http/pprof imported)
go tool pprof http://localhost:6060/debug/pprof/heap
go tool pprof http://localhost:6060/debug/pprof/profile?seconds=30
```

## Skill: Optimize Docker Build

```bash
# Build with stripped binary
CGO_ENABLED=0 GOOS=linux go build \
  -ldflags="-s -w" \
  -trimpath \
  -o bin/server ./cmd/server

# Check binary size
ls -lh bin/server
file bin/server
```
