#!/bin/bash
#
# Agentic Workflow Updater
# Checks for newer versions and upgrades in-place
#
# Usage:
#   ./agentic-workflow/update.sh              # Update to latest
#   ./agentic-workflow/update.sh --check      # Check only, don't install
#   ./agentic-workflow/update.sh --version v2.0.0  # Update to specific version
#

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Get script directory and project root
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VERSION_FILE="$SCRIPT_DIR/VERSION"

# Defaults
REPO_OWNER="your-org"
REPO_NAME="agentic-workflow"
CHECK_ONLY=false
TARGET_VERSION=""

# Read current version
CURRENT_VERSION="unknown"
if [ -f "$VERSION_FILE" ]; then
    CURRENT_VERSION=$(cat "$VERSION_FILE" | tr -d '[:space:]')
fi

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --check|-c)
            CHECK_ONLY=true
            shift
            ;;
        --version|-v)
            TARGET_VERSION="$2"
            shift 2
            ;;
        --repo|-r)
            REPO_OWNER="${2%%/*}"
            REPO_NAME="${2##*/}"
            shift 2
            ;;
        --help|-h)
            echo "Usage: ./agentic-workflow/update.sh [OPTIONS]"
            echo ""
            echo "Options:"
            echo "  --check, -c          Check for updates without installing"
            echo "  --version, -v TAG    Update to specific version (e.g., v2.0.0)"
            echo "  --repo, -r OWNER/REPO  GitHub repository (default: $REPO_OWNER/$REPO_NAME)"
            echo "  --help, -h           Show this help"
            exit 0
            ;;
        *)
            echo -e "${RED}Unknown option: $1${NC}"
            exit 1
            ;;
    esac
done

echo -e "${BLUE}╔════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║    Agentic Workflow Updater                ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════╝${NC}"
echo ""
echo -e "Current version: ${GREEN}v${CURRENT_VERSION}${NC}"

# Fetch remote version
if [ -n "$TARGET_VERSION" ]; then
    REMOTE_VERSION="${TARGET_VERSION#v}"
    echo -e "Target version:  ${GREEN}v${REMOTE_VERSION}${NC}"
else
    echo -e "${BLUE}▸ Checking for updates...${NC}"
    LATEST_TAG=$(curl -sI "https://github.com/${REPO_OWNER}/${REPO_NAME}/releases/latest" \
        | grep -i "^location:" \
        | sed 's/.*tag\///' \
        | tr -d '\r\n')

    if [ -z "$LATEST_TAG" ]; then
        echo -e "  ${YELLOW}○${NC} No releases found on GitHub."
        echo -e "  Use --version to specify a tag manually."
        exit 0
    fi

    REMOTE_VERSION="${LATEST_TAG#v}"
    echo -e "Latest version:  ${GREEN}v${REMOTE_VERSION}${NC}"
fi

echo ""

# Compare versions
if [ "$CURRENT_VERSION" = "$REMOTE_VERSION" ]; then
    echo -e "${GREEN}✔ Already up to date (v${CURRENT_VERSION}).${NC}"
    exit 0
fi

echo -e "${YELLOW}Update available: v${CURRENT_VERSION} → v${REMOTE_VERSION}${NC}"

if [ "$CHECK_ONLY" = true ]; then
    echo ""
    echo -e "Run ${BLUE}./agentic-workflow/update.sh${NC} to install the update."
    exit 0
fi

# Confirm
echo ""
read -p "Proceed with update? [y/N] " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo -e "${YELLOW}Update cancelled.${NC}"
    exit 0
fi

# Determine project root (parent of agentic-workflow/)
PROJECT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

# Download and install
TAG="v${REMOTE_VERSION}"
DOWNLOAD_URL="https://github.com/${REPO_OWNER}/${REPO_NAME}/archive/refs/tags/${TAG}.tar.gz"

TMP_DIR=$(mktemp -d)
trap "rm -rf '$TMP_DIR'" EXIT

echo ""
echo -e "${BLUE}▸ Downloading v${REMOTE_VERSION}...${NC}"
HTTP_CODE=$(curl -sL -w "%{http_code}" -o "$TMP_DIR/archive.tar.gz" "$DOWNLOAD_URL")

if [ "$HTTP_CODE" != "200" ]; then
    echo -e "  ${RED}✗${NC} Download failed (HTTP $HTTP_CODE)"
    echo -e "  Tag '${TAG}' may not exist. Check available releases."
    exit 1
fi
echo -e "  ${GREEN}✔${NC} Downloaded"

echo -e "${BLUE}▸ Extracting...${NC}"
tar xzf "$TMP_DIR/archive.tar.gz" -C "$TMP_DIR"
EXTRACTED_DIR=$(find "$TMP_DIR" -mindepth 1 -maxdepth 1 -type d | head -1)

if [ -z "$EXTRACTED_DIR" ]; then
    echo -e "  ${RED}✗${NC} Extraction failed"
    exit 1
fi
echo -e "  ${GREEN}✔${NC} Extracted"

# Run the new installer
echo ""
"$EXTRACTED_DIR/install.sh" "$PROJECT_DIR"

# Update local agentic-workflow/ folder
echo ""
echo -e "${BLUE}▸ Updating agentic-workflow/ folder...${NC}"
rm -rf "$SCRIPT_DIR/agents" "$SCRIPT_DIR/templates"
cp -r "$EXTRACTED_DIR/agents" "$SCRIPT_DIR/agents"
cp -r "$EXTRACTED_DIR/templates" "$SCRIPT_DIR/templates"
cp "$EXTRACTED_DIR/VERSION" "$SCRIPT_DIR/VERSION"
cp "$EXTRACTED_DIR/install.sh" "$SCRIPT_DIR/install.sh"
cp "$EXTRACTED_DIR/uninstall.sh" "$SCRIPT_DIR/uninstall.sh"
cp "$EXTRACTED_DIR/update.sh" "$SCRIPT_DIR/update.sh"
cp "$EXTRACTED_DIR/remote-install.sh" "$SCRIPT_DIR/remote-install.sh"
cp "$EXTRACTED_DIR/README.md" "$SCRIPT_DIR/README.md"
echo -e "  ${GREEN}✔${NC} Local copy updated"

echo ""
echo -e "${GREEN}╔════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║    Update Complete! ✔                      ║${NC}"
echo -e "${GREEN}╚════════════════════════════════════════════╝${NC}"
echo ""
echo -e "Updated: ${YELLOW}v${CURRENT_VERSION}${NC} → ${GREEN}v${REMOTE_VERSION}${NC}"
