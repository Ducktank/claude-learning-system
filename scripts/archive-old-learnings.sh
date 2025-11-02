#!/bin/bash
# Archive session learnings older than 90 days
# Copyright © 2025 MemoryForge, LLC. All rights reserved.

set -e

LEARNINGS_DIR="docs/sessions/learnings"
ARCHIVE_DIR="docs/sessions/archive"
ARCHIVE_SUMMARY="$ARCHIVE_DIR/archive-summary.md"
DAYS_THRESHOLD=90

echo "=================================="
echo "Quarterly Learning Archive"
echo "=================================="
echo ""

# Create archive directory if it doesn't exist
mkdir -p "$ARCHIVE_DIR"

# Find files older than threshold
echo "🔍 Finding learnings older than $DAYS_THRESHOLD days..."
OLD_FILES=$(find "$LEARNINGS_DIR" -name "*.md" -type f -mtime +$DAYS_THRESHOLD 2>/dev/null || true)

if [ -z "$OLD_FILES" ]; then
    echo "✅ No files older than $DAYS_THRESHOLD days found"
    echo ""
    echo "Current learnings:"
    find "$LEARNINGS_DIR" -name "*.md" -type f -exec basename {} \; | sort
    exit 0
fi

# Count files
FILE_COUNT=$(echo "$OLD_FILES" | wc -l | tr -d ' ')
echo "📦 Found $FILE_COUNT files to archive"
echo ""

# Show files to be archived
echo "Files to archive:"
echo "$OLD_FILES" | while read -r file; do
    basename "$file"
done
echo ""

# Ask for confirmation
read -p "Archive these files? (y/N) " -n 1 -r
echo ""

if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "❌ Archive cancelled"
    exit 0
fi

# Archive files
ARCHIVE_DATE=$(date +%Y-%m-%d)
QUARTER=$(date +%Y-Q$(($(date +%-m)/3+1)))
QUARTER_DIR="$ARCHIVE_DIR/$QUARTER"

mkdir -p "$QUARTER_DIR"

echo "📂 Archiving to: $QUARTER_DIR"
echo ""

ARCHIVED_COUNT=0
echo "$OLD_FILES" | while read -r file; do
    if [ -f "$file" ]; then
        filename=$(basename "$file")
        mv "$file" "$QUARTER_DIR/$filename"
        echo "✓ Archived: $filename"
        ARCHIVED_COUNT=$((ARCHIVED_COUNT + 1))
    fi
done

# Generate archive summary
echo ""
echo "📝 Generating archive summary..."

cat > "$QUARTER_DIR/README.md" <<EOF
# Archived Learnings - $QUARTER

**Archived on:** $ARCHIVE_DATE
**Files archived:** $(find "$QUARTER_DIR" -name "*.md" -type f | wc -l | tr -d ' ')

## Files in This Archive

$(find "$QUARTER_DIR" -name "*.md" -type f -not -name "README.md" -exec basename {} \; | sort | sed 's/^/- /')

## Accessing Archived Learnings

These learnings are older than $DAYS_THRESHOLD days and have been archived for historical reference.

**To restore a learning:**
\`\`\`bash
mv "$QUARTER_DIR/{filename}" $LEARNINGS_DIR/
\`\`\`

**To search archived learnings:**
\`\`\`bash
grep -r "pattern" $ARCHIVE_DIR/
\`\`\`

---

Copyright © 2025 MemoryForge, LLC. All rights reserved.
EOF

# Update global archive summary
if [ ! -f "$ARCHIVE_SUMMARY" ]; then
    cat > "$ARCHIVE_SUMMARY" <<EOF
# Session Learnings Archive

This directory contains archived session learnings organized by quarter.

## Archive Structure

- Learnings are automatically archived after $DAYS_THRESHOLD days
- Archives are organized by quarter (YYYY-Q1, YYYY-Q2, etc.)
- Each quarter has a README with metadata

## Archives

EOF
fi

# Add this quarter to the summary if not already present
if ! grep -q "$QUARTER" "$ARCHIVE_SUMMARY"; then
    cat >> "$ARCHIVE_SUMMARY" <<EOF

### $QUARTER
- **Archived:** $ARCHIVE_DATE
- **Files:** $(find "$QUARTER_DIR" -name "*.md" -type f -not -name "README.md" | wc -l | tr -d ' ')
- **Location:** \`$QUARTER_DIR\`

EOF
fi

echo ""
echo "=================================="
echo "✅ Archive Complete"
echo "=================================="
echo ""
echo "Archived: $FILE_COUNT files"
echo "Location: $QUARTER_DIR"
echo "Summary: $QUARTER_DIR/README.md"
echo ""
echo "Current active learnings:"
find "$LEARNINGS_DIR" -name "*.md" -type f -exec basename {} \; | sort
echo ""
