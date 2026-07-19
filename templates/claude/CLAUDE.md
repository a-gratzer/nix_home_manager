# Global Claude Code Configuration

## Available Slash Commands (Skills)

The following skills are available as slash commands across all projects:

| Skill | Description |
|-------|-------------|
| `/analyse_feature` | Analyze a named feature/module in a codebase — domain entities, services, repositories, DTOs, data flow, dependencies, security surface, error handling, logging, test coverage, and Mermaid diagrams. |
| `/ansible` | Ansible automation workflows — playbook authoring, role creation, inventory management, vault encryption, and troubleshooting. |
| `/commit-message` | Create conventional git commit messages from staged changes. Analyzes diffs, classifies commit type, supports optional gitmoji, and handles branching — with user approval at each step. |
| `/commit-push` | Stage all changes, create a short commit message summarizing changes, and push after confirmation. |
| `/docker-optimization` | Lint and optimize Dockerfiles using dockerfile-roast (droast), then apply manual hardening improvements. Covers Dockerfiles and docker-compose files. |
| `/golang` | Go development workflows — module init, HTTP server setup, database integration, testing patterns, build optimization, and debugging. |
| `/java-springboot` | Java & Spring Boot development workflows — project setup, REST APIs, JPA entities, testing, Docker builds, and dependency management. |
| `/kubernetes` | Kubernetes workflows — resource authoring, Helm chart development, debugging, scaling, and cluster operations. |
| `/linux-admin` | Linux server administration workflows — system diagnostics, service management, user administration, security hardening, storage, and backup. |
| `/planning_feature` | Create a structured, visual feature plan by breaking down a requested feature into tasks, identifying parallel work, mapping edge cases, defining the security surface, and optionally executing via sub-agents. |

## Available Sub-Agents

The following specialized sub-agents are available for task delegation:

| Agent | Purpose |
|-------|---------|
| **Ansible** | Playbooks, roles, inventories, Ansible Galaxy collections, AWX/AAP, and infrastructure as code. |
| **Docker Optimization** | Dockerfile hardening, layer caching, image size reduction, multi-stage builds, compose best practices, and security scanning. |
| **Golang** | CLI tools, microservices, APIs, concurrency patterns, and Go project structure. |
| **Java SpringBoot** | Backend services, REST APIs, microservices, JPA/Hibernate, testing, and build tooling. |
| **Kubernetes** | Manifests, Helm charts, operators, cluster administration, troubleshooting, and cloud-native patterns. |
| **Linux Admin** | System configuration, troubleshooting, security hardening, performance tuning, and shell scripting. |

## Usage Guidelines

- Use **skills** via slash commands (e.g., `/golang`) for guided interactive workflows.
- Delegate complex, self-contained tasks to **sub-agents** for parallel execution.
- Skills and agents are available in ALL projects — always check if one applies before writing code from scratch.
