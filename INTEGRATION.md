# Integration Guide for Existing Projects

This guide walks you through adding the Claude Learning System to a project that already has CLAUDE.md documentation.

---

## Prerequisites

Before starting, ensure you have:
- ✅ Existing CLAUDE.md file (or similar documentation file)
- ✅ Make installed (for Makefile targets) OR willingness to run scripts manually
- ✅ Python 3.7+ installed
- ✅ Git repository initialized

---

## Step-by-Step Integration

### Step 1: Backup

**Always backup before making changes:**

```bash
# Backup critical files
cp CLAUDE.md CLAUDE.md.backup
cp Makefile Makefile.backup 2>/dev/null || true
cp .gitignore .gitignore.backup 2>/dev/null || true

# Create backup branch
git checkout -b backup-before-learning-system
git add -A
git commit -m "backup: before installing learning system"
git checkout -  # Return to original branch
```

---

### Step 2: Copy Learning System Files

**Option A: Automated (Recommended)**

```bash
# Clone the learning system repository
git clone https://github.com/YOUR_ORG/claude-learning-system.git /tmp/learning-system

# Copy files into your project
rsync -av /tmp/learning-system/.claude/ ./.claude/
rsync -av /tmp/learning-system/scripts/ ./scripts/
mkdir -p docs/sessions/{learnings,archive}
touch docs/sessions/learnings/.gitkeep
touch docs/sessions/archive/.gitkeep

# Cleanup
rm -rf /tmp/learning-system
```

**Option B: Manual**

```bash
# Create directories
mkdir -p .claude/{templates,commands}
mkdir -p scripts
mkdir -p docs/sessions/{learnings,archive}

# Copy files (adjust paths as needed)
cp claude-learning-system/.claude/templates/session-learnings.md .claude/templates/
cp claude-learning-system/.claude/commands/capture-learnings.md .claude/commands/
cp claude-learning-system/scripts/map-learnings-to-claude.py scripts/
cp claude-learning-system/scripts/archive-old-learnings.sh scripts/
cp claude-learning-system/scripts/add-learning-markers.sh scripts/

# Create .gitkeep files
touch docs/sessions/learnings/.gitkeep
touch docs/sessions/archive/.gitkeep

# Make scripts executable
chmod +x scripts/*.sh
```

**Verify**:
```bash
ls -la .claude/templates/
ls -la .claude/commands/
ls -la scripts/
ls -la docs/sessions/
```

---

### Step 3: Add HTML Markers to CLAUDE.md

The learning system uses HTML comment markers to map learnings to sections.

**Option A: Interactive Helper (Recommended)**

```bash
./scripts/add-learning-markers.sh
```

This script will:
1. Scan your CLAUDE.md for common section headers
2. Suggest marker placements
3. Ask for confirmation before modifying

**Option B: Manual**

Add markers after each major section header:

```markdown
## Git Workflow
<!-- LEARNINGS:git-workflow -->

[existing content]

## Architecture
<!-- LEARNINGS:architecture -->

[existing content]

## Code Quality
<!-- LEARNINGS:code-quality -->

[existing content]

## Build & Development
<!-- LEARNINGS:build-tooling -->

[existing content]

## Troubleshooting
<!-- LEARNINGS:troubleshooting -->

[existing content]
```

**Marker naming rules**:
- Use lowercase
- Use hyphens (not underscores or spaces)
- Match the category names in `.claude/templates/session-learnings.md`

**Verify**:
```bash
grep -n "LEARNINGS:" CLAUDE.md
```

Should show at least 3-5 markers.

---

### Step 4: Integrate Makefile Targets

**If you have a Makefile**:

```bash
# Append learning system targets
cat claude-learning-system/Makefile.fragment >> Makefile

# Verify
grep "map-learnings" Makefile
```

**If you DON'T have a Makefile**:

Create one:
```bash
cp claude-learning-system/Makefile.fragment Makefile
```

Or run scripts directly:
```bash
# Instead of: make map-learnings FILE=...
python3 scripts/map-learnings-to-claude.py docs/sessions/learnings/2025-11-01.md

# Instead of: make archive-learnings
./scripts/archive-old-learnings.sh

# Instead of: make list-learnings
find docs/sessions/learnings -name "*.md" -type f
```

---

### Step 5: Update .gitignore

```bash
# Append learning system ignore rules
cat claude-learning-system/.gitignore.fragment >> .gitignore
```

**Or manually add**:
```gitignore
# Session Learnings (keep structure, ignore content)
docs/sessions/learnings/*.md
docs/sessions/archive/*/
!docs/sessions/learnings/.gitkeep
!docs/sessions/archive/.gitkeep
```

**Rationale**: Learning files are working documents. The system (structure) is committed, but content is local.

**Alternative** (if you want to track learnings):
```gitignore
# Track all learnings
# (Don't add ignore rules)
```

---

### Step 6: Test Installation

```bash
# 1. Show template
make show-learnings-template
# Expected: Display template content

# 2. List learnings
make list-learnings
# Expected: Empty or existing learnings

# 3. Test Python script
python3 scripts/map-learnings-to-claude.py --help
# Expected: Show help message

# 4. Verify markers
grep -c "LEARNINGS:" CLAUDE.md
# Expected: Number >= 3
```

---

### Step 7: First Test Run

**Create a test learning file**:

```bash
cp .claude/templates/session-learnings.md docs/sessions/learnings/2025-test.md
```

**Edit the file** and fill in one example learning (use real data from your project).

**Run mapper**:
```bash
make map-learnings FILE=docs/sessions/learnings/2025-test.md
```

**Expected output**:
```
================================================================================
Session Learning Mapper
================================================================================

Project root: /path/to/your/project
Parsing: docs/sessions/learnings/2025-test.md
Target: CLAUDE.md

✓ Found 1 learnings

✓ Found 5 marked sections in CLAUDE.md

================================================================================
Suggested Changes
================================================================================

🔴 HIGH CONFIDENCE (Strongly recommend adding):

================================================================================
Learning: Example pattern...
Target Section: Git Workflow (line 42)
Confidence: High
================================================================================
Suggested addition to CLAUDE.md:

@@ Line 50 @@
+[Your suggested text]
```

If this works, you're all set!

---

## Common Integration Challenges

### Challenge 1: CLAUDE.md Has Non-Standard Structure

**Problem**: Your CLAUDE.md uses different section names than expected.

**Solution**: Customize markers to match your structure:

```markdown
## Our Special Workflow Section
<!-- LEARNINGS:workflow -->

## Platform Architecture
<!-- LEARNINGS:architecture -->
```

Then update `.claude/templates/session-learnings.md` categories to match.

---

### Challenge 2: No Makefile in Project

**Problem**: Project doesn't use Make.

**Solutions**:

**Option A**: Create a minimal Makefile just for learning system:
```bash
cp claude-learning-system/Makefile.fragment Makefile
```

**Option B**: Create shell aliases:
```bash
# Add to ~/.bashrc or ~/.zshrc
alias map-learnings='python3 scripts/map-learnings-to-claude.py'
alias archive-learnings='./scripts/archive-old-learnings.sh'
alias list-learnings='find docs/sessions/learnings -name "*.md" -type f'
```

**Option C**: Use scripts directly (see examples in Step 4).

---

### Challenge 3: Existing `docs/` Directory Structure

**Problem**: You already have `docs/` for other purposes.

**Solution**: Choose different path:

1. Update paths in scripts:
   ```bash
   # In archive-old-learnings.sh
   LEARNINGS_DIR="documentation/learnings"  # Instead of docs/sessions/learnings

   # In capture-learnings slash command
   # Change save path to match
   ```

2. Create directories:
   ```bash
   mkdir -p documentation/{learnings,archive}
   ```

---

### Challenge 4: Team Uses Different Documentation File

**Problem**: Your team uses `DOCS.md` instead of `CLAUDE.md`.

**Solution**: Use `--claude-file` flag:

```bash
# Update Makefile targets
.PHONY: map-learnings
map-learnings:
	python3 scripts/map-learnings-to-claude.py $(FILE) --claude-file DOCS.md

# Or run directly
python3 scripts/map-learnings-to-claude.py \
  docs/sessions/learnings/2025-11-01.md \
  --claude-file DOCS.md
```

---

### Challenge 5: Merge Conflicts with Existing Scripts

**Problem**: You already have `scripts/` directory with files.

**Solution**:

```bash
# Move learning system scripts to subdirectory
mkdir -p scripts/learning-system
mv scripts/map-learnings-to-claude.py scripts/learning-system/
mv scripts/archive-old-learnings.sh scripts/learning-system/

# Update Makefile paths
# Change:  scripts/map-learnings-to-claude.py
# To:      scripts/learning-system/map-learnings-to-claude.py
```

---

## Rollback Procedure

If something goes wrong:

```bash
# Restore from backup branch
git checkout backup-before-learning-system

# Copy back files
git checkout - CLAUDE.md
git checkout - Makefile
git checkout - .gitignore

# Remove learning system files
rm -rf .claude/templates/session-learnings.md
rm -rf .claude/commands/capture-learnings.md
rm -rf scripts/map-learnings-to-claude.py
rm -rf scripts/archive-old-learnings.sh
rm -rf docs/sessions/
```

---

## Post-Integration Checklist

After integration, verify:

- [ ] `.claude/templates/session-learnings.md` exists
- [ ] `.claude/commands/capture-learnings.md` exists
- [ ] `scripts/map-learnings-to-claude.py` is executable
- [ ] `scripts/archive-old-learnings.sh` is executable
- [ ] `docs/sessions/{learnings,archive}/` directories exist
- [ ] CLAUDE.md has at least 3 `<!-- LEARNINGS:... -->` markers
- [ ] Makefile has `map-learnings` target (or scripts work directly)
- [ ] `.gitignore` excludes learning content
- [ ] `make show-learnings-template` works
- [ ] `make list-learnings` works
- [ ] Test learning file maps successfully

---

## Next Steps

1. **Run your first `/capture-learnings` session**
2. **Map one learning** to verify end-to-end flow
3. **Customize template categories** for your domain
4. **Share with team** (commit system, not content)
5. **Schedule quarterly archive** (add to calendar)

---

## Getting Help

**Issue**: Script errors
- Check Python version: `python3 --version` (need 3.7+)
- Verify file paths are correct
- Check execute permissions: `ls -la scripts/`

**Issue**: Markers not detected
- Verify marker format: `<!-- LEARNINGS:category -->`
- Check case sensitivity (must be lowercase)
- Ensure markers are AFTER section headers

**Issue**: Makefile targets not working
- Check syntax: tabs not spaces for indentation
- Verify Python path: `which python3`
- Try running scripts directly

---

## Comparison: Before vs. After

### Before Learning System

```
Session ends → Insights lost
    ↓
Ask same questions next week
    ↓
Repeat solved problems
```

### After Learning System

```
Session ends → /capture-learnings
    ↓
Map to CLAUDE.md sections
    ↓
Review and integrate
    ↓
Future Claude knows the pattern
    ↓
Never repeat the same debug session
```

---

**Estimated integration time**: 15-30 minutes

**Maintenance burden**: ~5 minutes/week (capture + map)

**Quarterly review**: 15-20 minutes (archive old learnings)

**ROI**: Compounding knowledge that improves every session

---

Copyright © 2025 MemoryForge, LLC. All rights reserved.
