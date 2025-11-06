#!/usr/bin/env bash
# Copyright © 2025 MemoryForge, LLC. All rights reserved.
#
# Claude Learning System - Automated Setup Script
#
# This script installs the learning system into a new or existing project.
#
# Usage:
#   ./scripts/setup-learning-system.sh
#   curl -sSL https://raw.githubusercontent.com/YOUR_ORG/claude-learning-system/main/scripts/setup-learning-system.sh | bash

set -e  # Exit on error

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Detect execution mode
if [ -n "${BASH_SOURCE[0]}" ] && [ -f "${BASH_SOURCE[0]}" ]; then
    # Local execution mode
    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    PACKAGE_ROOT="$(dirname "$SCRIPT_DIR")"
    CURL_PIPE_MODE=false
else
    # Curl-pipe execution mode
    SCRIPT_DIR=""
    PACKAGE_ROOT=""
    CURL_PIPE_MODE=true
fi

PROJECT_ROOT="$(pwd)"
GITHUB_RAW_BASE="https://raw.githubusercontent.com/Ducktank/claude-learning-system/main"

echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}  Claude Learning System - Installer${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "Project root: ${GREEN}$PROJECT_ROOT${NC}"

if [ "$CURL_PIPE_MODE" = true ]; then
    echo -e "Mode: ${YELLOW}Curl-pipe (downloading from GitHub)${NC}"
else
    echo -e "Package root: ${GREEN}$PACKAGE_ROOT${NC}"
    echo -e "Mode: ${GREEN}Local execution${NC}"

    # Check if we're in the package directory itself
    if [ "$PROJECT_ROOT" = "$PACKAGE_ROOT" ]; then
        echo -e "${YELLOW}⚠️  You're inside the learning system package directory.${NC}"
        echo -e "${YELLOW}   Please run this from your target project root.${NC}"
        echo ""
        echo "Example:"
        echo "  cd /path/to/your/project"
        echo "  /path/to/claude-learning-system/scripts/setup-learning-system.sh"
        exit 1
    fi
fi

echo ""

# Function: Prompt for yes/no
ask_yes_no() {
    local prompt="$1"
    local default="${2:-n}"
    local response

    if [ "$default" = "y" ]; then
        prompt="$prompt [Y/n]: "
    else
        prompt="$prompt [y/N]: "
    fi

    read -p "$(echo -e ${BLUE}${prompt}${NC})" response
    response="${response:-$default}"

    case "$response" in
        [yY][eE][sS]|[yY])
            return 0
            ;;
        *)
            return 1
            ;;
    esac
}

# Step 1: Check prerequisites
echo -e "${BLUE}[1/7] Checking prerequisites...${NC}"

# Check Python
if ! command -v python3 &> /dev/null; then
    echo -e "${RED}❌ Python 3 not found${NC}"
    echo "Please install Python 3.7+ and try again"
    exit 1
fi

python_version=$(python3 --version | awk '{print $2}')
echo -e "  ✅ Python $python_version"

# Check git
if ! command -v git &> /dev/null; then
    echo -e "${YELLOW}⚠️  Git not found (optional but recommended)${NC}"
else
    echo -e "  ✅ Git installed"
fi

echo ""

# Step 2: Backup existing files
echo -e "${BLUE}[2/7] Creating backups...${NC}"

backup_needed=false

if [ -f "CLAUDE.md" ]; then
    cp CLAUDE.md CLAUDE.md.backup
    echo -e "  ✅ Backed up CLAUDE.md → CLAUDE.md.backup"
    backup_needed=true
fi

if [ -f "Makefile" ]; then
    cp Makefile Makefile.backup
    echo -e "  ✅ Backed up Makefile → Makefile.backup"
    backup_needed=true
fi

if [ -f ".gitignore" ]; then
    cp .gitignore .gitignore.backup
    echo -e "  ✅ Backed up .gitignore → .gitignore.backup"
    backup_needed=true
fi

if [ "$backup_needed" = false ]; then
    echo -e "  ${YELLOW}⚠️  No existing files to backup${NC}"
fi

echo ""

# Step 3: Create directory structure
echo -e "${BLUE}[3/7] Creating directory structure...${NC}"

mkdir -p .claude/templates
mkdir -p .claude/commands
mkdir -p scripts
mkdir -p docs/sessions/learnings
mkdir -p docs/sessions/archive

touch docs/sessions/learnings/.gitkeep
touch docs/sessions/archive/.gitkeep

echo -e "  ✅ Created .claude/{templates,commands}"
echo -e "  ✅ Created scripts/"
echo -e "  ✅ Created docs/sessions/{learnings,archive}"
echo ""

# Step 4: Copy/download learning system files
echo -e "${BLUE}[4/7] Installing learning system files...${NC}"

if [ "$CURL_PIPE_MODE" = true ]; then
    # Download from GitHub
    curl -sSL "$GITHUB_RAW_BASE/.claude/templates/session-learnings.md" -o .claude/templates/session-learnings.md
    echo -e "  ✅ Downloaded session-learnings.md template"

    curl -sSL "$GITHUB_RAW_BASE/.claude/commands/capture-learnings.md" -o .claude/commands/capture-learnings.md
    echo -e "  ✅ Downloaded capture-learnings slash command"

    curl -sSL "$GITHUB_RAW_BASE/scripts/map-learnings-to-claude.py" -o scripts/map-learnings-to-claude.py
    echo -e "  ✅ Downloaded map-learnings-to-claude.py"

    curl -sSL "$GITHUB_RAW_BASE/scripts/archive-old-learnings.sh" -o scripts/archive-old-learnings.sh
    echo -e "  ✅ Downloaded archive-old-learnings.sh"

    if curl -sSL "$GITHUB_RAW_BASE/scripts/add-learning-markers.sh" -o scripts/add-learning-markers.sh 2>/dev/null; then
        echo -e "  ✅ Downloaded add-learning-markers.sh"
    fi
else
    # Copy from local filesystem
    cp "$PACKAGE_ROOT/.claude/templates/session-learnings.md" .claude/templates/
    echo -e "  ✅ Copied session-learnings.md template"

    cp "$PACKAGE_ROOT/.claude/commands/capture-learnings.md" .claude/commands/
    echo -e "  ✅ Copied capture-learnings slash command"

    cp "$PACKAGE_ROOT/scripts/map-learnings-to-claude.py" scripts/
    echo -e "  ✅ Copied map-learnings-to-claude.py"

    cp "$PACKAGE_ROOT/scripts/archive-old-learnings.sh" scripts/
    echo -e "  ✅ Copied archive-old-learnings.sh"

    if [ -f "$PACKAGE_ROOT/scripts/add-learning-markers.sh" ]; then
        cp "$PACKAGE_ROOT/scripts/add-learning-markers.sh" scripts/
        echo -e "  ✅ Copied add-learning-markers.sh"
    fi
fi

# Make scripts executable
chmod +x scripts/map-learnings-to-claude.py
chmod +x scripts/archive-old-learnings.sh
[ -f scripts/add-learning-markers.sh ] && chmod +x scripts/add-learning-markers.sh

echo ""

# Step 5: Add markers to CLAUDE.md
echo -e "${BLUE}[5/7] Configuring CLAUDE.md markers...${NC}"

if [ -f "CLAUDE.md" ]; then
    if grep -q "<!-- LEARNINGS:" CLAUDE.md; then
        echo -e "  ${GREEN}✅ CLAUDE.md already has learning markers${NC}"
    else
        echo -e "  ${YELLOW}⚠️  CLAUDE.md exists but has no learning markers${NC}"

        if [ -f "scripts/add-learning-markers.sh" ] && ask_yes_no "Run interactive marker helper?" "y"; then
            ./scripts/add-learning-markers.sh
        else
            echo -e "  ${YELLOW}   You'll need to add markers manually.${NC}"
            echo -e "  ${YELLOW}   See INTEGRATION.md Step 3 for instructions.${NC}"
        fi
    fi
else
    echo -e "  ${YELLOW}⚠️  No CLAUDE.md found${NC}"

    if ask_yes_no "Create minimal CLAUDE.md with markers?" "y"; then
        cat > CLAUDE.md <<'EOF'
# CLAUDE.md

Project documentation for AI-assisted development.

## Build & Development
<!-- LEARNINGS:build-tooling -->

[Document your build commands here]

## Architecture
<!-- LEARNINGS:architecture -->

[Document your architecture here]

## Git Workflow
<!-- LEARNINGS:git-workflow -->

[Document your git workflow here]

## Code Quality
<!-- LEARNINGS:code-quality -->

[Document code quality standards here]

## Troubleshooting
<!-- LEARNINGS:troubleshooting -->

[Document common issues and solutions here]
EOF
        echo -e "  ${GREEN}✅ Created CLAUDE.md with learning markers${NC}"
    else
        echo -e "  ${YELLOW}   Skipped CLAUDE.md creation${NC}"
    fi
fi

echo ""

# Step 6: Integrate Makefile targets
echo -e "${BLUE}[6/7] Configuring Makefile...${NC}"

if [ -f "Makefile" ]; then
    if grep -q "map-learnings" Makefile; then
        echo -e "  ${GREEN}✅ Makefile already has learning targets${NC}"
    else
        if ask_yes_no "Append learning targets to Makefile?" "y"; then
            if [ "$CURL_PIPE_MODE" = true ]; then
                curl -sSL "$GITHUB_RAW_BASE/Makefile.fragment" >> Makefile
            else
                cat "$PACKAGE_ROOT/Makefile.fragment" >> Makefile
            fi
            echo -e "  ${GREEN}✅ Added learning targets to Makefile${NC}"
        else
            echo -e "  ${YELLOW}   Skipped Makefile integration${NC}"
            echo -e "  ${YELLOW}   You can manually append Makefile.fragment later${NC}"
        fi
    fi
else
    if ask_yes_no "Create Makefile with learning targets?" "y"; then
        if [ "$CURL_PIPE_MODE" = true ]; then
            curl -sSL "$GITHUB_RAW_BASE/Makefile.fragment" -o Makefile
        else
            cp "$PACKAGE_ROOT/Makefile.fragment" Makefile
        fi
        echo -e "  ${GREEN}✅ Created Makefile with learning targets${NC}"
    else
        echo -e "  ${YELLOW}   Skipped Makefile creation${NC}"
        echo -e "  ${YELLOW}   You can run scripts directly instead${NC}"
    fi
fi

echo ""

# Step 7: Update .gitignore
echo -e "${BLUE}[7/7] Configuring .gitignore...${NC}"

if [ -f ".gitignore" ]; then
    if grep -q "docs/sessions/learnings" .gitignore; then
        echo -e "  ${GREEN}✅ .gitignore already has learning rules${NC}"
    else
        if ask_yes_no "Append learning ignore rules to .gitignore?" "y"; then
            echo "" >> .gitignore
            if [ "$CURL_PIPE_MODE" = true ]; then
                curl -sSL "$GITHUB_RAW_BASE/.gitignore.fragment" >> .gitignore
            else
                cat "$PACKAGE_ROOT/.gitignore.fragment" >> .gitignore
            fi
            echo -e "  ${GREEN}✅ Added learning rules to .gitignore${NC}"
        else
            echo -e "  ${YELLOW}   Skipped .gitignore update${NC}"
        fi
    fi
else
    if ask_yes_no "Create .gitignore with learning rules?" "y"; then
        if [ "$CURL_PIPE_MODE" = true ]; then
            curl -sSL "$GITHUB_RAW_BASE/.gitignore.fragment" -o .gitignore
        else
            cp "$PACKAGE_ROOT/.gitignore.fragment" .gitignore
        fi
        echo -e "  ${GREEN}✅ Created .gitignore with learning rules${NC}"
    else
        echo -e "  ${YELLOW}   Skipped .gitignore creation${NC}"
    fi
fi

echo ""

# Summary
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}  ✅ Installation Complete!${NC}"
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo "Next steps:"
echo ""
echo "1. Verify installation:"
if [ -f "Makefile" ]; then
    echo "   make show-learnings-template"
    echo "   make list-learnings"
else
    echo "   python3 scripts/map-learnings-to-claude.py --help"
    echo "   ls docs/sessions/learnings"
fi
echo ""
echo "2. In Claude Code, run:"
echo "   /capture-learnings"
echo ""
echo "3. Map your first learning:"
if [ -f "Makefile" ]; then
    echo "   make map-learnings FILE=docs/sessions/learnings/YYYY-MM-DD.md"
else
    echo "   python3 scripts/map-learnings-to-claude.py docs/sessions/learnings/YYYY-MM-DD.md"
fi
echo ""
echo "4. Read the documentation:"
if [ "$CURL_PIPE_MODE" = true ]; then
    echo "   https://github.com/Ducktank/claude-learning-system"
else
    echo "   cat $PACKAGE_ROOT/README.md"
    echo "   cat $PACKAGE_ROOT/INTEGRATION.md"
fi
echo ""

if [ "$backup_needed" = true ]; then
    echo -e "${YELLOW}Note: Backups created (.backup files). Remove after verifying installation.${NC}"
    echo ""
fi

echo -e "${BLUE}Happy learning! 🎓${NC}"
echo ""
