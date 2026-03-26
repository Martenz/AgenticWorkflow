#!/bin/bash
#
# Agentic Workflow Remote Installer & Updater
# Install:  curl -sL https://raw.githubusercontent.com/Martenz/AgenticWorkflow/master/remote-install.sh | bash
# Update:   (same command — detects existing install and updates agents)
#
# Usage:
#   curl -sL https://raw.githubusercontent.com/Martenz/AgenticWorkflow/master/remote-install.sh | bash
#   curl -sL https://raw.githubusercontent.com/Martenz/AgenticWorkflow/master/remote-install.sh | bash -s -- /path/to/proj
#   curl -sL https://raw.githubusercontent.com/Martenz/AgenticWorkflow/master/remote-install.sh | bash -s -- --version v1.2.0
#

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Defaults
REPO_OWNER="Martenz"
REPO_NAME="AgenticWorkflow"
VERSION="latest"
TARGET_DIR="."

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --version|-v)
            VERSION="$2"
            shift 2
            ;;
        --repo|-r)
            REPO_OWNER="${2%%/*}"
            REPO_NAME="${2##*/}"
            shift 2
            ;;
        --help|-h)
            echo "Usage: curl -sL https://raw.githubusercontent.com/Martenz/AgenticWorkflow/master/remote-install.sh | bash -s -- [OPTIONS] [TARGET_DIR]"
            echo ""
            echo "Options:"
            echo "  --version, -v TAG    Install specific version (e.g., v1.0.0). Default: latest"
            echo "  --repo, -r OWNER/REPO  GitHub repository (default: $REPO_OWNER/$REPO_NAME)"
            echo "  --help, -h           Show this help"
            echo ""
            echo "Examples:"
            echo "  curl -sL https://raw.githubusercontent.com/Martenz/AgenticWorkflow/master/remote-install.sh | bash"
            echo "  curl -sL https://raw.githubusercontent.com/Martenz/AgenticWorkflow/master/remote-install.sh | bash -s -- --version v1.0.0"
            echo "  curl -sL https://raw.githubusercontent.com/Martenz/AgenticWorkflow/master/remote-install.sh | bash -s -- /path/to/project"
            exit 0
            ;;
        *)
            TARGET_DIR="$1"
            shift
            ;;
    esac
done

# Resolve target dir
if [ ! -d "$TARGET_DIR" ]; then
    echo -e "${RED}Error: Target directory '$TARGET_DIR' does not exist.${NC}"
    exit 1
fi
TARGET_DIR="$(cd "$TARGET_DIR" && pwd)"

# Detect existing install
VERSION_MARKER="$TARGET_DIR/.agentic-workflow-version"
INSTALLED_VERSION=""
IS_UPDATE=false
if [ -f "$VERSION_MARKER" ]; then
    INSTALLED_VERSION=$(cat "$VERSION_MARKER" | tr -d '[:space:]')
    IS_UPDATE=true
fi

if [ "$IS_UPDATE" = true ]; then
    echo -e "${BLUE}╔════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║    Agentic Workflow Updater                ║${NC}"
    echo -e "${BLUE}╚════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "Installed: ${YELLOW}${INSTALLED_VERSION}${NC}"
else
    echo -e "${BLUE}╔════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║    Agentic Workflow Remote Installer       ║${NC}"
    echo -e "${BLUE}╚════════════════════════════════════════════╝${NC}"
fi
echo ""
echo -e "Repository: ${GREEN}${REPO_OWNER}/${REPO_NAME}${NC}"
echo -e "Version:    ${GREEN}${VERSION}${NC}"
echo -e "Target:     ${GREEN}${TARGET_DIR}${NC}"
echo ""

# Create temp directory
TMP_DIR=$(mktemp -d)
trap "rm -rf '$TMP_DIR'" EXIT

# Determine download URL
if [ "$VERSION" = "latest" ]; then
    echo -e "${BLUE}▸ Fetching latest version...${NC}"
    LOCATION_HEADER=$(curl -sI "https://github.com/${REPO_OWNER}/${REPO_NAME}/releases/latest" \
        | grep -i "^location:" \
        | tr -d '\r\n')

    # Only extract tag if the location URL actually contains /tag/
    LATEST_TAG=""
    if echo "$LOCATION_HEADER" | grep -q '/tag/'; then
        LATEST_TAG=$(echo "$LOCATION_HEADER" | sed 's/.*tag\///')
    fi

    if [ -z "$LATEST_TAG" ]; then
        LATEST_TAG="master"
        echo -e "  ${YELLOW}○${NC} No releases found, using master branch"
    else
        echo -e "  ${GREEN}✔${NC} Latest version: $LATEST_TAG"
    fi

    DOWNLOAD_URL="https://github.com/${REPO_OWNER}/${REPO_NAME}/archive/refs/heads/master.tar.gz"
    if [ "$LATEST_TAG" != "master" ]; then
        DOWNLOAD_URL="https://github.com/${REPO_OWNER}/${REPO_NAME}/archive/refs/tags/${LATEST_TAG}.tar.gz"
    fi
else
    LATEST_TAG="$VERSION"
    DOWNLOAD_URL="https://github.com/${REPO_OWNER}/${REPO_NAME}/archive/refs/tags/${VERSION}.tar.gz"
fi

# Download
echo -e "${BLUE}▸ Downloading...${NC}"
HTTP_CODE=$(curl -sL -w "%{http_code}" -o "$TMP_DIR/archive.tar.gz" "$DOWNLOAD_URL")

if [ "$HTTP_CODE" != "200" ]; then
    echo -e "  ${RED}✗${NC} Download failed (HTTP $HTTP_CODE)"
    echo -e "  URL: $DOWNLOAD_URL"
    echo -e "  Check that the version tag exists."
    exit 1
fi
echo -e "  ${GREEN}✔${NC} Downloaded"

# Extract
echo -e "${BLUE}▸ Extracting...${NC}"
tar xzf "$TMP_DIR/archive.tar.gz" -C "$TMP_DIR"
EXTRACTED_DIR=$(find "$TMP_DIR" -mindepth 1 -maxdepth 1 -type d | head -1)

if [ -z "$EXTRACTED_DIR" ]; then
    echo -e "  ${RED}✗${NC} Extraction failed"
    exit 1
fi
echo -e "  ${GREEN}✔${NC} Extracted"

# Read new version from extracted archive
NEW_VERSION="unknown"
if [ -f "$EXTRACTED_DIR/VERSION" ]; then
    NEW_VERSION=$(cat "$EXTRACTED_DIR/VERSION" | tr -d '[:space:]')
fi

# Check if update is needed
if [ "$IS_UPDATE" = true ] && [ "$INSTALLED_VERSION" = "$NEW_VERSION" ] && [ "$LATEST_TAG" != "master" ]; then
    echo ""
    echo -e "${YELLOW}Already at version ${NEW_VERSION}. Nothing to do.${NC}"
    exit 0
fi

# --- Install / Update files directly ---

echo ""
echo -e "${BLUE}▸ Creating folder structure...${NC}"

for dir in ".github/agents" "docs" "docs/docs" "docs/plans" "docs/roadmaps" "tests/e2e"; do
    if [ ! -d "$TARGET_DIR/$dir" ]; then
        mkdir -p "$TARGET_DIR/$dir"
        echo -e "  ${GREEN}✔${NC} Created: $dir/"
    else
        echo -e "  ${YELLOW}○${NC} Exists:  $dir/"
    fi
done

echo ""
echo -e "${BLUE}▸ Installing agents...${NC}"

for agent_file in "$EXTRACTED_DIR"/agents/*.agent.md; do
    [ -f "$agent_file" ] || continue
    filename=$(basename "$agent_file")
    dest="$TARGET_DIR/.github/agents/$filename"
    if [ ! -f "$dest" ]; then
        cp "$agent_file" "$dest"
        echo -e "  ${GREEN}✔${NC} Installed: $filename"
    elif ! cmp -s "$agent_file" "$dest"; then
        cp "$agent_file" "$dest"
        echo -e "  ${GREEN}✔${NC} Updated:   $filename"
    else
        echo -e "  ${YELLOW}○${NC} Up to date: $filename"
    fi
done

echo ""
echo -e "${BLUE}▸ Installing templates...${NC}"

# Copy roadmap readme (only on fresh install)
if [ -f "$EXTRACTED_DIR/templates/readme_roadmap.md" ]; then
    dest="$TARGET_DIR/docs/docs/readme_roadmap.md"
    if [ ! -f "$dest" ]; then
        cp "$EXTRACTED_DIR/templates/readme_roadmap.md" "$dest"
        echo -e "  ${GREEN}✔${NC} Installed: docs/docs/readme_roadmap.md"
    else
        echo -e "  ${YELLOW}○${NC} Exists:    docs/docs/readme_roadmap.md"
    fi
fi

# Create sample roadmap only on fresh install into empty folder
if [ -z "$(ls -A "$TARGET_DIR/docs/roadmaps" 2>/dev/null)" ]; then
    cat > "$TARGET_DIR/docs/roadmaps/example-roadmap.md" << 'ROADMAP_EOF'
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
ROADMAP_EOF
    echo -e "  ${GREEN}✔${NC} Created:   docs/roadmaps/example-roadmap.md"
fi

# Copy how-to guide (always overwrite to keep it current)
HOWTO_SRC="$EXTRACTED_DIR/templates/agentic-workflow-how-to.md"
HOWTO_DEST="$TARGET_DIR/agentic-workflow-how-to.md"
if [ -f "$HOWTO_SRC" ]; then
    cp "$HOWTO_SRC" "$HOWTO_DEST"
    if [ "$IS_UPDATE" = true ]; then
        echo -e "  ${GREEN}✔${NC} Updated:   agentic-workflow-how-to.md"
    else
        echo -e "  ${GREEN}✔${NC} Created:   agentic-workflow-how-to.md"
    fi
fi

# Write version marker
echo "$NEW_VERSION" > "$VERSION_MARKER"

echo ""
if [ "$IS_UPDATE" = true ]; then
    echo -e "${GREEN}╔════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║    Update Complete! ✔                      ║${NC}"
    echo -e "${GREEN}╚════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "Updated: ${YELLOW}${INSTALLED_VERSION}${NC} → ${GREEN}${NEW_VERSION}${NC}"
else
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
fi
echo ""
echo -e "Version: ${GREEN}${NEW_VERSION}${NC}"
echo -e "Target:  ${GREEN}${TARGET_DIR}${NC}"
echo ""
echo -e "To update later, run the same command:"
echo -e "  ${BLUE}curl -sL https://raw.githubusercontent.com/Martenz/AgenticWorkflow/master/remote-install.sh | bash${NC}"
