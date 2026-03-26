#!/bin/bash
#
# Agentic Workflow Remote Installer
# One-liner install: curl -sL https://raw.githubusercontent.com/Martenz/AgenticWorkflow/master/remote-install.sh | bash
#
# Usage:
#   curl -sL https://raw.githubusercontent.com/Martenz/AgenticWorkflow/master/remote-install.sh | bash                     # Latest, install to current dir
#   curl -sL https://raw.githubusercontent.com/Martenz/AgenticWorkflow/master/remote-install.sh | bash -s -- /path/to/proj # Latest, specific target
#   curl -sL https://raw.githubusercontent.com/Martenz/AgenticWorkflow/master/remote-install.sh | bash -s -- --version v1.2.0  # Specific version
#   curl -sL https://raw.githubusercontent.com/Martenz/AgenticWorkflow/master/remote-install.sh | bash -s -- --version v1.2.0 /path/to/proj
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
KEEP_LOCAL=true

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
        --no-keep)
            KEEP_LOCAL=false
            shift
            ;;
        --help|-h)
            echo "Usage: curl -sL https://raw.githubusercontent.com/Martenz/AgenticWorkflow/master/remote-install.sh | bash -s -- [OPTIONS] [TARGET_DIR]"
            echo ""
            echo "Options:"
            echo "  --version, -v TAG    Install specific version (e.g., v1.0.0). Default: latest"
            echo "  --repo, -r OWNER/REPO  GitHub repository (default: $REPO_OWNER/$REPO_NAME)"
            echo "  --no-keep            Don't keep agentic-workflow/ folder in project"
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

echo -e "${BLUE}╔════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║    Agentic Workflow Remote Installer       ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════╝${NC}"
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
    # Get latest release tag
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
        # No releases yet, use master branch
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

# Find extracted directory (name varies by tag)
EXTRACTED_DIR=$(find "$TMP_DIR" -mindepth 1 -maxdepth 1 -type d | head -1)

if [ -z "$EXTRACTED_DIR" ]; then
    echo -e "  ${RED}✗${NC} Extraction failed"
    exit 1
fi
echo -e "  ${GREEN}✔${NC} Extracted"

# Run install.sh
echo ""
"$EXTRACTED_DIR/install.sh" "$TARGET_DIR"

# Optionally keep agentic-workflow folder
if [ "$KEEP_LOCAL" = true ]; then
    echo ""
    echo -e "${BLUE}▸ Saving agentic-workflow/ locally...${NC}"
    
    if [ -d "$TARGET_DIR/agentic-workflow" ]; then
        # Check version
        INSTALLED_VERSION=""
        if [ -f "$TARGET_DIR/agentic-workflow/VERSION" ]; then
            INSTALLED_VERSION=$(cat "$TARGET_DIR/agentic-workflow/VERSION" | tr -d '[:space:]')
        fi
        NEW_VERSION=""
        if [ -f "$EXTRACTED_DIR/VERSION" ]; then
            NEW_VERSION=$(cat "$EXTRACTED_DIR/VERSION" | tr -d '[:space:]')
        fi
        
        if [ "$INSTALLED_VERSION" = "$NEW_VERSION" ]; then
            echo -e "  ${YELLOW}○${NC} Already at version $NEW_VERSION"
        else
            echo -e "  ${GREEN}✔${NC} Updating: $INSTALLED_VERSION → $NEW_VERSION"
            rm -rf "$TARGET_DIR/agentic-workflow"
            cp -r "$EXTRACTED_DIR" "$TARGET_DIR/agentic-workflow"
        fi
    else
        cp -r "$EXTRACTED_DIR" "$TARGET_DIR/agentic-workflow"
        echo -e "  ${GREEN}✔${NC} Saved to agentic-workflow/"
    fi
fi

echo ""
echo -e "${GREEN}╔════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║    Remote Install Complete! ✔              ║${NC}"
echo -e "${GREEN}╚════════════════════════════════════════════╝${NC}"
echo ""
echo -e "Version: ${GREEN}${LATEST_TAG}${NC}"
echo -e "Target:  ${GREEN}${TARGET_DIR}${NC}"
echo ""
echo -e "To update later:"
echo -e "  ${BLUE}./agentic-workflow/update.sh${NC}"
echo ""
echo -e "Or reinstall remotely:"
echo -e "  ${BLUE}curl -sL https://raw.githubusercontent.com/Martenz/AgenticWorkflow/master/remote-install.sh | bash${NC}"
