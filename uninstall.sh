#!/bin/bash
#
# Agentic Workflow Uninstaller
# Removes the agentic development workflow from a project
#

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Target directory (default: current directory)
TARGET_DIR="${1:-.}"
TARGET_DIR="$(cd "$TARGET_DIR" && pwd)"

echo -e "${RED}╔════════════════════════════════════════════╗${NC}"
echo -e "${RED}║    Agentic Workflow Uninstaller            ║${NC}"
echo -e "${RED}╚════════════════════════════════════════════╝${NC}"
echo ""
echo -e "Target: ${YELLOW}$TARGET_DIR${NC}"
echo ""

# Agent files to remove
AGENTS=(
    "plan-orchestrator.agent.md"
    "plan-generator.agent.md"
    "plan-implementer.agent.md"
    "plan-tester.agent.md"
    "plan-validator.agent.md"
    "plan-documenter.agent.md"
)

# Confirm uninstall
echo -e "${YELLOW}This will remove:${NC}"
echo -e "  • Agent files from .github/agents/ (plan + task agents)"
echo -e "  • docs/README.md (workflow documentation)"
echo -e "  • docs/docs/readme_roadmap.md"
echo -e "  • Example task files from tasks/"
echo ""
echo -e "${YELLOW}This will NOT remove:${NC}"
echo -e "  • docs/plans/ (your generated plans)"
echo -e "  • docs/roadmaps/ (your roadmaps)"
echo -e "  • tasks/ (your custom task descriptions)"
echo -e "  • tests/e2e/ (generated tests)"
echo -e "  • Any implemented code"
echo ""

read -p "Are you sure you want to uninstall? [y/N] " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo -e "${GREEN}Uninstall cancelled.${NC}"
    exit 0
fi

echo ""
echo -e "${BLUE}▸ Removing agent files...${NC}"

# Remove agent files
for agent in "${AGENTS[@]}"; do
    agent_path="$TARGET_DIR/.github/agents/$agent"
    if [ -f "$agent_path" ]; then
        rm "$agent_path"
        echo -e "  ${RED}✗${NC} Removed: $agent"
    else
        echo -e "  ${YELLOW}○${NC} Not found: $agent"
    fi
done

# Remove task agent files
echo ""
echo -e "${BLUE}▸ Removing task agent files...${NC}"

for task_agent in "$TARGET_DIR"/.github/agents/task-agent-*.agent.md; do
    if [ -f "$task_agent" ]; then
        filename=$(basename "$task_agent")
        rm "$task_agent"
        echo -e "  ${RED}✗${NC} Removed: $filename"
    fi
done

# Check if .github/agents is empty and remove if so
if [ -d "$TARGET_DIR/.github/agents" ] && [ -z "$(ls -A "$TARGET_DIR/.github/agents")" ]; then
    rmdir "$TARGET_DIR/.github/agents"
    echo -e "  ${RED}✗${NC} Removed empty: .github/agents/"
fi

# Check if .github is empty and remove if so
if [ -d "$TARGET_DIR/.github" ] && [ -z "$(ls -A "$TARGET_DIR/.github")" ]; then
    rmdir "$TARGET_DIR/.github"
    echo -e "  ${RED}✗${NC} Removed empty: .github/"
fi

echo ""
echo -e "${BLUE}▸ Removing template files...${NC}"

# Remove docs README if it's the template version
if [ -f "$TARGET_DIR/docs/README.md" ]; then
    # Check if it contains our signature
    if grep -q "@plan-orchestrator" "$TARGET_DIR/docs/README.md" 2>/dev/null; then
        rm "$TARGET_DIR/docs/README.md"
        echo -e "  ${RED}✗${NC} Removed: docs/README.md"
    else
        echo -e "  ${YELLOW}○${NC} Skipped: docs/README.md (modified)"
    fi
fi

# Remove roadmap readme
if [ -f "$TARGET_DIR/docs/docs/readme_roadmap.md" ]; then
    # Check if it's still the template (only has header)
    line_count=$(wc -l < "$TARGET_DIR/docs/docs/readme_roadmap.md")
    if [ "$line_count" -lt 15 ]; then
        rm "$TARGET_DIR/docs/docs/readme_roadmap.md"
        echo -e "  ${RED}✗${NC} Removed: docs/docs/readme_roadmap.md"
    else
        echo -e "  ${YELLOW}○${NC} Skipped: docs/docs/readme_roadmap.md (has content)"
    fi
fi

# Remove example roadmap if unchanged
if [ -f "$TARGET_DIR/docs/roadmaps/example-roadmap.md" ]; then
    if grep -q "This is a sample roadmap" "$TARGET_DIR/docs/roadmaps/example-roadmap.md" 2>/dev/null; then
        rm "$TARGET_DIR/docs/roadmaps/example-roadmap.md"
        echo -e "  ${RED}✗${NC} Removed: docs/roadmaps/example-roadmap.md"
    fi
fi

# Remove example task files (only if unchanged)
if [ -f "$TARGET_DIR/tasks/example-task.md" ]; then
    if grep -q "This is a sample task description" "$TARGET_DIR/tasks/example-task.md" 2>/dev/null; then
        rm "$TARGET_DIR/tasks/example-task.md"
        echo -e "  ${RED}✗${NC} Removed: tasks/example-task.md"
    fi
fi
if [ -f "$TARGET_DIR/tasks/example-task-map-builder.md" ]; then
    if grep -q "This is an example task description" "$TARGET_DIR/tasks/example-task-map-builder.md" 2>/dev/null; then
        rm "$TARGET_DIR/tasks/example-task-map-builder.md"
        echo -e "  ${RED}✗${NC} Removed: tasks/example-task-map-builder.md"
    fi
fi

# Clean up empty directories
echo ""
echo -e "${BLUE}▸ Cleaning up empty directories...${NC}"

for dir in "tasks" "docs/docs" "docs/plans" "docs/roadmaps" "tests/e2e" "tests" "docs"; do
    full_path="$TARGET_DIR/$dir"
    if [ -d "$full_path" ] && [ -z "$(ls -A "$full_path")" ]; then
        rmdir "$full_path"
        echo -e "  ${RED}✗${NC} Removed empty: $dir/"
    fi
done

echo ""
echo -e "${GREEN}╔════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║    Uninstall Complete                      ║${NC}"
echo -e "${GREEN}╚════════════════════════════════════════════╝${NC}"
echo ""
echo -e "The agentic workflow has been removed."
echo -e "Your plans, roadmaps, and tests were preserved."
echo ""
echo -e "To reinstall: ${BLUE}./agentic-workflow/install.sh${NC}"
