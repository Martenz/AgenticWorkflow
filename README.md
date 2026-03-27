# Agentic Development Workflow

[![Version](https://img.shields.io/badge/version-1.0.0-blue.svg)](VERSION)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

A reusable template for AI-assisted development using a cascade of specialized VS Code agents. Automates the full development cycle from roadmap to documented, tested code.

## Quick Start

### One-liner Install (Recommended)

```bash
curl -sL https://raw.githubusercontent.com/Martenz/AgenticWorkflow/master/remote-install.sh | bash
```

Re-run the same command to **update** agents to the latest version.

With options:

```bash
# Into a specific project
curl -sL https://raw.githubusercontent.com/Martenz/AgenticWorkflow/master/remote-install.sh | bash -s -- /path/to/project

# Specific version
curl -sL https://raw.githubusercontent.com/Martenz/AgenticWorkflow/master/remote-install.sh | bash -s -- --version v1.0.0
```

### Git Submodule (For Teams)

```bash
git submodule add https://github.com/Martenz/AgenticWorkflow.git agentic-workflow
./agentic-workflow/install.sh
```

### Local Clone

```bash
git clone https://github.com/Martenz/AgenticWorkflow.git
./agentic-workflow/install.sh /path/to/your-project
```



## Overview

```
┌───────────────────┐
│ @plan-orchestrator│ ← Single command runs entire workflow
│   (autonomous)    │
└─────────┬─────────┘
          │ orchestrates
          ▼
┌─────────────────┐     ┌──────────────────┐     ┌──────────────┐     ┌────────────────┐     ┌─────────────────┐
│ @plan-generator │ ──▶ │ @plan-implementer│ ──▶ │ @plan-tester │ ──▶ │ @plan-validator│ ──▶ │ @plan-documenter│
│   Create Plan   │     │  Implement Code  │     │  Unit Tests  │     │   E2E Tests    │     │  Documentation  │
└─────────────────┘     └──────────────────┘     └──────────────┘     └────────────────┘     └─────────────────┘
                               │                        │                     │
                               ◀────── Rework ──────────┴─────────────────────┘
```

## Usage

After installation, use the orchestrator for autonomous development:

```
@plan-orchestrator Run workflow from docs/roadmaps/my-feature.md
```

Or run agents individually:

```
@plan-generator Create plan from docs/roadmaps/my-feature.md
@plan-implementer Start plan my-feature
@plan-tester Test plan my-feature
@plan-validator Validate plan my-feature
@plan-documenter Document plan my-feature
```

### Task Agents

Run standalone task agents for specific jobs:

```
@task-agent-map-builder Generate map from tasks/my-map-task.md
```

Task agents read structured task descriptions from the `tasks/` folder and produce outputs independently. They can also be integrated into plan workflows.

## Agents

| Agent | Purpose | Triggers |
|-------|---------|----------|
| **plan-orchestrator** | Runs full autonomous workflow | `orchestrate`, `full workflow`, `run all agents` |
| **plan-generator** | Creates structured plans from roadmaps | `plan`, `roadmap`, `development plan` |
| **plan-implementer** | Implements plan steps, updates flags | `implement`, `execute plan`, `start plan` |
| **plan-tester** | Unit tests, formatting, complexity | `test plan`, `check code quality` |
| **plan-validator** | E2E tests, workflow validation | `e2e test`, `validate feature` |
| **plan-documenter** | Code docs, roadmap summary | `document code`, `add docstrings` |

### Task Agents

Standalone agents for specific tasks. Can run independently or be composed with plan agents.

| Agent | Purpose | Triggers |
|-------|---------|----------|
| **task-agent-map-builder** | Interactive map HTML from local geodata | `map visualization`, `map builder`, `interactive map`, `maplibre` |

Task agent documentation: see `agents/task-agent-<name>/readme.md` in the repository.

## Folder Structure

After installation:

```
your-project/
├── .agentic-workflow-version  # Version marker (auto-generated)
├── .github/
│   └── agents/                # Agent definitions
│       ├── plan-orchestrator.agent.md
│       ├── plan-generator.agent.md
│       ├── plan-implementer.agent.md
│       ├── plan-tester.agent.md
│       ├── plan-validator.agent.md
│       ├── plan-documenter.agent.md
│       └── task-agent-map-builder.agent.md
├── docs/
│   ├── README.md         # Workflow documentation
│   ├── docs/
│   │   └── readme_roadmap.md  # Implemented features log
│   ├── plans/            # Generated plan documents
│   └── roadmaps/         # Your input roadmaps
├── tasks/                 # Task descriptions for task agents
│   ├── example-task.md
│   └── example-task-map-builder.md
└── tests/
    └── e2e/              # Generated E2E tests
```

## Status Flow

### Step-Level Status

```
NOT_STARTED → IN_PROGRESS → REVIEW → VERIFIED
                   ↑           │
                   └── FAILED_* ┘
```

### Plan-Level Status

```
Draft → Ready for Implementation → VALIDATED → DOCUMENTED ✅
              ↑                         │
              └─────── ROLLBACK ────────┘
```

## Uninstall

```bash
./agentic-workflow/uninstall.sh

# Or specify target
./agentic-workflow/uninstall.sh /path/to/project
```

## Updating

For curl installs, re-run the install command — it detects the existing version and updates agents:

```bash
curl -sL https://raw.githubusercontent.com/Martenz/AgenticWorkflow/master/remote-install.sh | bash
```

For submodule installs:

```bash
cd agentic-workflow && git pull origin master && cd ..
./agentic-workflow/install.sh
```

## Versioning

Releases use semantic versioning via git tags:

```bash
git tag v1.1.0
git push origin v1.1.0
```

The current version is tracked in `VERSION`. The installer and updater read this file automatically.

## Repository Structure

```
agentic-workflow/
├── agents/                # Agent .md definitions
│   ├── plan-orchestrator.agent.md
│   ├── plan-generator.agent.md
│   ├── plan-implementer.agent.md
│   ├── plan-tester.agent.md
│   ├── plan-validator.agent.md
│   ├── plan-documenter.agent.md
│   └── task-agent-map-builder/    # Task agent: map builder
│       ├── task-agent-map-builder.agent.md
│       └── readme.md
├── templates/             # Project scaffolding templates
│   ├── docs-readme.md
│   ├── readme_roadmap.md
│   ├── example-task.md
│   └── example-task-map-builder.md
├── install.sh             # Local installer (for clone/submodule)
├── uninstall.sh           # Clean removal
├── remote-install.sh      # Curl one-liner installer & updater
├── VERSION                # Current semver
├── LICENSE
└── README.md
```

After `install.sh` runs in your project:

## Customization

### Adding New Agents

Create new agents in `agents/` following the pattern:

#### Plan Agents

Place directly in `agents/`:

```yaml
---
description: "Use when: {triggers}. Triggers: {keywords}."
tools: [read, edit, search]
---
You are a {Role}. Your job is to {purpose}.

## Constraints
- DO NOT {restriction}
- ALWAYS {requirement}

## Approach
1. Step one
2. Step two
```

#### Task Agents

Create a subfolder `agents/task-agent-<name>/` with:
- `task-agent-<name>.agent.md` — agent definition
- `readme.md` — usage documentation

Optionally add a task template in `templates/example-task-<name>.md`.

Task agents are installed to `.github/agents/` alongside plan agents and read task descriptions from `tasks/`.

### Modifying Templates

Edit files in `templates/` to customize:
- `docs-readme.md` → Initial docs/README.md
- `readme_roadmap.md` → Initial roadmap tracking file

## License

MIT - Use freely in your projects. See [LICENSE](LICENSE).
