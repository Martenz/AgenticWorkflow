#!/bin/bash
#
# Agentic Workflow Installer
# Installs the agentic development workflow into a project
#

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
AGENTS_DIR="$SCRIPT_DIR/agents"
TEMPLATES_DIR="$SCRIPT_DIR/templates"
VERSION_FILE="$SCRIPT_DIR/VERSION"

# Read version
VERSION="unknown"
if [ -f "$VERSION_FILE" ]; then
    VERSION=$(cat "$VERSION_FILE" | tr -d '[:space:]')
fi

# Target directory (default: current directory)
TARGET_DIR="${1:-.}"
TARGET_DIR="$(cd "$TARGET_DIR" && pwd)"

echo -e "${BLUE}╔════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║    Agentic Workflow Installer  v${VERSION}       ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════╝${NC}"
echo ""
echo -e "Version: ${GREEN}v${VERSION}${NC}"
echo -e "Target:  ${GREEN}$TARGET_DIR${NC}"
echo ""

# Function to create directory if it doesn't exist
create_dir() {
    if [ ! -d "$1" ]; then
        mkdir -p "$1"
        echo -e "  ${GREEN}✔${NC} Created: $1"
    else
        echo -e "  ${YELLOW}○${NC} Exists:  $1"
    fi
}

# Function to copy file if it doesn't exist or is different
copy_file() {
    local src="$1"
    local dest="$2"
    local filename=$(basename "$src")
    
    if [ ! -f "$dest" ]; then
        cp "$src" "$dest"
        echo -e "  ${GREEN}✔${NC} Installed: $filename"
    elif ! cmp -s "$src" "$dest"; then
        echo -e "  ${YELLOW}!${NC} File exists with changes: $filename"
        if [ -t 0 ]; then
            read -p "    Overwrite? [y/N] " -n 1 -r
            echo
        else
            # Non-interactive (e.g. curl | bash) — skip overwrite
            REPLY="n"
        fi
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            cp "$src" "$dest"
            echo -e "  ${GREEN}✔${NC} Updated: $filename"
        else
            echo -e "  ${YELLOW}○${NC} Skipped: $filename"
        fi
    else
        echo -e "  ${YELLOW}○${NC} Up to date: $filename"
    fi
}

# Check if agents directory exists
if [ ! -d "$AGENTS_DIR" ]; then
    echo -e "${RED}Error: Agents directory not found at $AGENTS_DIR${NC}"
    exit 1
fi

echo -e "${BLUE}▸ Creating folder structure...${NC}"

# Create required directories
create_dir "$TARGET_DIR/.github/agents"
create_dir "$TARGET_DIR/docs"
create_dir "$TARGET_DIR/docs/docs"
create_dir "$TARGET_DIR/docs/plans"
create_dir "$TARGET_DIR/docs/roadmaps"
create_dir "$TARGET_DIR/tests/e2e"

echo ""
echo -e "${BLUE}▸ Installing agents...${NC}"

# Copy all agent files
for agent_file in "$AGENTS_DIR"/*.agent.md; do
    if [ -f "$agent_file" ]; then
        copy_file "$agent_file" "$TARGET_DIR/.github/agents/$(basename "$agent_file")"
    fi
done

echo ""
echo -e "${BLUE}▸ Installing templates...${NC}"

# Copy roadmap readme if it doesn't exist
if [ -f "$TEMPLATES_DIR/readme_roadmap.md" ]; then
    if [ ! -f "$TARGET_DIR/docs/docs/readme_roadmap.md" ]; then
        cp "$TEMPLATES_DIR/readme_roadmap.md" "$TARGET_DIR/docs/docs/readme_roadmap.md"
        echo -e "  ${GREEN}✔${NC} Installed: docs/docs/readme_roadmap.md"
    else
        echo -e "  ${YELLOW}○${NC} Exists: docs/docs/readme_roadmap.md"
    fi
fi

# Create sample roadmap if roadmaps folder is empty
if [ -z "$(ls -A "$TARGET_DIR/docs/roadmaps" 2>/dev/null)" ]; then
    cat > "$TARGET_DIR/docs/roadmaps/example-roadmap.md" << 'EOF'
# Example Roadmap

This is a sample roadmap. Replace with your actual development roadmap.

## Feature: User Authentication

### Objectives
- Implement secure user login
- Add password reset functionality
- Support OAuth providers

### Requirements
- JWT token-based authentication
- Password hashing with bcrypt
- Rate limiting on auth endpoints

### Milestones
1. Basic login/logout
2. Password reset flow
3. OAuth integration

---

To use this roadmap:
```
@plan-orchestrator Run workflow from docs/roadmaps/example-roadmap.md
```

Or generate a plan first:
```
@plan-generator Create plan from docs/roadmaps/example-roadmap.md
```
EOF
    echo -e "  ${GREEN}✔${NC} Created: docs/roadmaps/example-roadmap.md"
fi

echo ""
echo -e "${GREEN}╔════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║    Installation Complete! ✔                ║${NC}"
echo -e "${GREEN}╚════════════════════════════════════════════╝${NC}"
echo ""
echo -e "Installed agents:"
echo -e "  • ${BLUE}@plan-orchestrator${NC} - Autonomous full workflow"
echo -e "  • ${BLUE}@plan-generator${NC}    - Create plans from roadmaps"
echo -e "  • ${BLUE}@plan-implementer${NC}  - Implement plan steps"
echo -e "  • ${BLUE}@plan-tester${NC}       - Unit tests & code quality"
echo -e "  • ${BLUE}@plan-validator${NC}    - E2E tests"
echo -e "  • ${BLUE}@plan-documenter${NC}   - Documentation"
echo ""
echo -e "Get started:"
echo -e "  1. Add your roadmap to ${YELLOW}docs/roadmaps/${NC}"
echo -e "  2. Run: ${GREEN}@plan-orchestrator Run workflow from docs/roadmaps/your-roadmap.md${NC}"
echo ""
echo -e "Or see the example: ${YELLOW}docs/roadmaps/example-roadmap.md${NC}"
