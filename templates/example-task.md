# Example Task: Getting Started

This is a sample task description. Replace it with your own task definition.

A task description tells a **task agent** what to produce. Each task agent reads this file and executes accordingly.

## How to Use

1. Copy this template or create a new `.md` file in `tasks/`
2. Fill in the sections relevant to the task agent you want to invoke
3. Run the task agent:

```
@task-agent-<name> Generate from tasks/your-task.md
```

## Template Structure

Every task description should include:

- **Title** — what this task produces
- **Input data** — files, paths, or resources the agent will read
- **Configuration** — settings, parameters, and preferences
- **Output** — where and how to save results

---

## Available Task Agents

| Agent | Purpose | Example |
|-------|---------|---------|
| `@task-agent-map-builder` | Interactive map HTML from geodata | `tasks/example-task-map-builder.md` |

---

For plan-based workflows, see `docs/roadmaps/` and use `@plan-orchestrator`.
