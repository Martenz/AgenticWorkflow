# Agentic Development Workflow

[![Version](https://img.shields.io/badge/version-1.0.0-blue.svg)](VERSION)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

A reusable template for AI-assisted development using a cascade of specialized VS Code agents. Automates the full development cycle from roadmap to documented, tested code.

## Quick Start

### One-liner Install (Remote)

```bash
curl -sL https://raw.githubusercontent.com/your-org/agentic-workflow/main/remote-install.sh | bash
```

Or with options:

```bash
# Specific version
curl -sL https://raw.githubusercontent.com/your-org/agentic-workflow/main/remote-install.sh | bash -s -- --version v1.0.0

# Into a specific project
curl -sL https://raw.githubusercontent.com/your-org/agentic-workflow/main/remote-install.sh | bash -s -- /path/to/project
```

### Git Submodule (Recommended for Teams)

```bash
git submodule add https://github.com/your-org/agentic-workflow.git agentic-workflow
./agentic-workflow/install.sh
```

### Local Install

```bash
# Clone and install
git clone https://github.com/your-org/agentic-workflow.git
./agentic-workflow/install.sh /path/to/your-project
```

> **Note:** Replace `your-org` with your GitHub username or organization.

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

## Agents

| Agent | Purpose | Triggers |
|-------|---------|----------|
| **plan-orchestrator** | Runs full autonomous workflow | `orchestrate`, `full workflow`, `run all agents` |
| **plan-generator** | Creates structured plans from roadmaps | `plan`, `roadmap`, `development plan` |
| **plan-implementer** | Implements plan steps, updates flags | `implement`, `execute plan`, `start plan` |
| **plan-tester** | Unit tests, formatting, complexity | `test plan`, `check code quality` |
| **plan-validator** | E2E tests, workflow validation | `e2e test`, `validate feature` |
| **plan-documenter** | Code docs, roadmap summary | `document code`, `add docstrings` |

## Folder Structure

After installation:

```
your-project/
├── .github/
│   └── agents/           # Agent definitions
│       ├── plan-orchestrator.agent.md
│       ├── plan-generator.agent.md
│       ├── plan-implementer.agent.md
│       ├── plan-tester.agent.md
│       ├── plan-validator.agent.md
│       └── plan-documenter.agent.md
├── docs/
│   ├── README.md         # Workflow documentation
│   ├── docs/
│   │   └── readme_roadmap.md  # Implemented features log
│   ├── plans/            # Generated plan documents
│   └── roadmaps/         # Your input roadmaps
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

```bash
# Check for updates
./agentic-workflow/update.sh --check

# Update to latest
./agentic-workflow/update.sh

# Update to specific version
./agentic-workflow/update.sh --version v2.0.0
```

If installed as a submodule:

```bash
cd agentic-workflow && git pull origin main && cd ..
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
│   └── plan-documenter.agent.md
├── templates/             # Project scaffolding templates
│   ├── docs-readme.md
│   └── readme_roadmap.md
├── install.sh             # Local installer
├── uninstall.sh           # Clean removal
├── update.sh              # Version updater
├── remote-install.sh      # Curl one-liner installer
├── VERSION                # Current semver
├── LICENSE
└── README.md
```

After `install.sh` runs in your project:

## Customization

### Adding New Agents

Create new agents in `agents/` following the pattern:

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

### Modifying Templates

Edit files in `templates/` to customize:
- `docs-readme.md` → Initial docs/README.md
- `readme_roadmap.md` → Initial roadmap tracking file

## License

MIT - Use freely in your projects. See [LICENSE](LICENSE).
