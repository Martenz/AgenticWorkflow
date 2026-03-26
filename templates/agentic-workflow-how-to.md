# Agentic Workflow — Developer Guide

## Updating

Re-run the same command you used to install:

```bash
curl -sL https://raw.githubusercontent.com/Martenz/AgenticWorkflow/master/remote-install.sh | bash
```

This detects the existing install and updates only the agent files.
Your roadmaps, plans, and docs are never overwritten.

Pin a specific version:

```bash
curl -sL https://raw.githubusercontent.com/Martenz/AgenticWorkflow/master/remote-install.sh | bash -s -- --version v1.2.0
```

---

## Using the Agents

### Autonomous Mode (Full Workflow)

Hand off an entire feature to the orchestrator. It runs all agents in sequence:
plan → implement → test → validate → document.

```
@plan-orchestrator Run workflow from docs/roadmaps/my-feature.md
```

### Step-by-Step Mode

Run individual agents when you want more control:

```
@plan-generator Create plan from docs/roadmaps/my-feature.md
@plan-implementer Start plan my-feature
@plan-tester Test plan my-feature
@plan-validator Validate plan my-feature
@plan-documenter Document plan my-feature
```

### Partial Workflows

You can start from any agent. Common patterns:

| Goal | Command |
|------|---------|
| Just generate a plan | `@plan-generator Create plan from docs/roadmaps/my-feature.md` |
| Implement an existing plan | `@plan-implementer Start plan my-feature` |
| Test after manual coding | `@plan-tester Test plan my-feature` |
| Add docs to existing code | `@plan-documenter Document plan my-feature` |

---

## Workflow

```
1. Write a roadmap         →  docs/roadmaps/your-feature.md
2. Generate a plan         →  @plan-generator (creates docs/plans/your-feature.md)
3. Implement the plan      →  @plan-implementer (writes code, updates plan flags)
4. Run tests               →  @plan-tester (unit tests, code quality)
5. Validate end-to-end     →  @plan-validator (e2e tests)
6. Generate documentation  →  @plan-documenter (docstrings, README updates)
```

The orchestrator runs steps 2–6 automatically. If a step fails,
the agent loops back to implementation for a fix.

---

## Writing Good Roadmaps

Place your roadmap in `docs/roadmaps/` with this structure:

```markdown
# Feature Name

## Objectives
- What the feature should accomplish

## Requirements
- Technical constraints and specifics

## Milestones
1. First deliverable
2. Second deliverable
```

The more specific your requirements, the better the generated plan.

---

## File Structure

```
.agentic-workflow-version     ← version tracker (do not edit)
.github/agents/               ← agent definitions (updated via curl)
docs/
  docs/readme_roadmap.md      ← implemented features log
  plans/                      ← generated plans (auto-created)
  roadmaps/                   ← YOUR roadmaps go here
tests/e2e/                    ← generated e2e tests
```

---

## Status Flags

Plans use these status markers that agents update automatically:

**Step-level:** `NOT_STARTED` → `IN_PROGRESS` → `REVIEW` → `VERIFIED`
**Plan-level:** `Draft` → `Ready for Implementation` → `VALIDATED` → `DOCUMENTED`

If a step fails, it gets marked `FAILED_*` and loops back for rework.
