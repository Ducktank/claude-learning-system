#!/usr/bin/env bash
# Copyright © 2025 MemoryForge, LLC. All rights reserved.
#
# Claude Learning System - Interactive Marker Placement Helper
#
# This script helps add <!-- LEARNINGS:category --> markers to existing CLAUDE.md files.
#
# Usage:
#   ./scripts/add-learning-markers.sh

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

CLAUDE_FILE="${1:-CLAUDE.md}"

echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}  Learning Marker Placement Helper${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# Check if CLAUDE.md exists
if [ ! -f "$CLAUDE_FILE" ]; then
    echo -e "${RED}❌ $CLAUDE_FILE not found${NC}"
    echo ""
    echo "Please ensure CLAUDE.md exists before running this script."
    exit 1
fi

echo -e "Target file: ${GREEN}$CLAUDE_FILE${NC}"
echo ""

# Check if markers already exist
existing_markers=$(grep -c "<!-- LEARNINGS:" "$CLAUDE_FILE" || true)

if [ "$existing_markers" -gt 0 ]; then
    echo -e "${GREEN}✅ Found $existing_markers existing learning markers:${NC}"
    grep -n "<!-- LEARNINGS:" "$CLAUDE_FILE" | sed 's/^/   /'
    echo ""

    read -p "$(echo -e ${YELLOW}Do you want to add more markers? [y/N]: ${NC})" response
    case "$response" in
        [yY][eE][sS]|[yY])
            ;;
        *)
            echo "Exiting."
            exit 0
            ;;
    esac
    echo ""
fi

# Common section patterns to look for
declare -A section_patterns=(
    ["build-tooling"]="Build|Development|Commands|Setup|Installation"
    ["architecture"]="Architecture|Structure|Design|Components|Modules"
    ["git-workflow"]="Git|Version Control|Workflow|Branching"
    ["code-quality"]="Code Quality|Standards|Linting|Quality|Style"
    ["development-patterns"]="Development|Patterns|Practices|Guidelines"
    ["troubleshooting"]="Troubleshooting|Debugging|Issues|Problems|FAQ"
)

echo -e "${BLUE}Scanning $CLAUDE_FILE for common sections...${NC}"
echo ""

# Find section headers (lines starting with ## or ###)
sections=$(grep -n "^##\s" "$CLAUDE_FILE" || true)

if [ -z "$sections" ]; then
    echo -e "${RED}❌ No section headers found in $CLAUDE_FILE${NC}"
    echo ""
    echo "Expected headers like:"
    echo "  ## Section Name"
    echo "  ### Subsection Name"
    exit 1
fi

echo -e "${GREEN}Found sections:${NC}"
echo "$sections" | sed 's/^/  /'
echo ""

# Suggest markers
echo -e "${BLUE}Suggested marker placements:${NC}"
echo ""

suggestions=""

while IFS= read -r line; do
    line_num=$(echo "$line" | cut -d: -f1)
    header=$(echo "$line" | cut -d: -f2-)

    # Check if line already has a marker immediately after
    next_line_num=$((line_num + 1))
    next_line=$(sed -n "${next_line_num}p" "$CLAUDE_FILE")

    if echo "$next_line" | grep -q "<!-- LEARNINGS:"; then
        continue  # Skip, already has marker
    fi

    # Match against patterns
    for category in "${!section_patterns[@]}"; do
        pattern="${section_patterns[$category]}"
        if echo "$header" | grep -qi "$pattern"; then
            echo -e "  Line $line_num: $header"
            echo -e "  ${GREEN}→ Suggest: <!-- LEARNINGS:$category -->${NC}"
            echo ""

            suggestions+="$line_num:$category\n"
            break
        fi
    done
done <<< "$sections"

if [ -z "$suggestions" ]; then
    echo -e "${YELLOW}⚠️  No new marker suggestions found${NC}"
    echo ""
    echo "Your sections may not match common patterns."
    echo "You can manually add markers using this format:"
    echo ""
    echo "  ## Your Section Name"
    echo "  <!-- LEARNINGS:your-section -->"
    echo ""
    exit 0
fi

# Ask for confirmation
echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
read -p "$(echo -e ${BLUE}Apply these markers to $CLAUDE_FILE? [y/N]: ${NC})" response

case "$response" in
    [yY][eE][sS]|[yY])
        ;;
    *)
        echo "Cancelled. No changes made."
        exit 0
        ;;
esac

echo ""
echo -e "${BLUE}Applying markers...${NC}"

# Create temporary file
temp_file=$(mktemp)
trap "rm -f $temp_file" EXIT

# Apply markers
current_line=0
while IFS=: read -r target_line category; do
    if [ -z "$target_line" ]; then
        continue
    fi

    # Read file line by line and insert marker after target line
    {
        while IFS= read -r line; do
            current_line=$((current_line + 1))
            echo "$line"

            if [ "$current_line" -eq "$target_line" ]; then
                echo "<!-- LEARNINGS:$category -->"
                echo -e "  ${GREEN}✅ Added marker at line $target_line: <!-- LEARNINGS:$category -->${NC}"
            fi
        done < "$CLAUDE_FILE"
    } > "$temp_file"

    # Replace original with temp
    mv "$temp_file" "$CLAUDE_FILE"
    current_line=0
done <<< "$(echo -e "$suggestions")"

echo ""
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}  ✅ Markers added successfully!${NC}"
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# Show final marker count
final_count=$(grep -c "<!-- LEARNINGS:" "$CLAUDE_FILE")
echo -e "Total markers in $CLAUDE_FILE: ${GREEN}$final_count${NC}"
echo ""

# Verify
echo "Verify markers:"
grep -n "<!-- LEARNINGS:" "$CLAUDE_FILE" | sed 's/^/  /'
echo ""

echo "Next steps:"
echo "  1. Review $CLAUDE_FILE to ensure markers are placed correctly"
echo "  2. Run: make map-learnings FILE=docs/sessions/learnings/YYYY-MM-DD.md"
echo ""
