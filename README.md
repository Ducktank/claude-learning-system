# Claude Learning System

**Systematic capture and integration of learnings from AI-assisted development sessions**

Turn every Claude Code session into institutional knowledge by automatically capturing patterns, anti-patterns, and best practices directly into your project's CLAUDE.md documentation.

---

## What Is This?

The Claude Learning System is a framework for:
- 📝 **Capturing** session learnings via `/capture-learnings` slash command
- 🗺️ **Mapping** learnings to appropriate CLAUDE.md sections automatically
- 📦 **Archiving** old learnings quarterly to prevent documentation bloat
- 🔄 **Continuously improving** your project documentation with real experience

### Why Use It?

**Problem**: AI development sessions produce valuable insights that get lost in chat history.

**Solution**: Structured capture → automated mapping → manual review → integrated knowledge.

**Result**: Your CLAUDE.md becomes a living document that improves with every session.

---

## Quick Start (New Projects)

### 1. Install

**Automated (Recommended)**:
```bash
curl -sSL https://raw.githubusercontent.com/YOUR_ORG/claude-learning-system/main/scripts/setup-learning-system.sh | bash
```

**Manual**:
```bash
# Clone or download this repository
git clone https://github.com/YOUR_ORG/claude-learning-system.git

# Run installer
cd claude-learning-system
./scripts/setup-learning-system.sh
```

### 2. Verify Setup

```bash
make show-learnings-template  # Should display template
make list-learnings           # Should show empty list
```

### 3. First Learning Capture

In Claude Code:
```
/capture-learnings
```

Claude will analyze your session and generate:
- `docs/sessions/learnings/YYYY-MM-DD-description.md`

### 4. Map to CLAUDE.md

```bash
make map-learnings FILE=docs/sessions/learnings/2025-11-01-example.md
```

Review the suggested additions and manually integrate the high-confidence items.

---

## For Existing Projects

See **[INTEGRATION.md](INTEGRATION.md)** for step-by-step migration guide.

TL;DR:
```bash
# 1. Copy files
rsync -av claude-learning-system/.claude/ ./.claude/
rsync -av claude-learning-system/scripts/ ./scripts/

# 2. Add markers to CLAUDE.md
./scripts/add-learning-markers.sh  # Interactive helper

# 3. Merge Makefile targets
cat claude-learning-system/Makefile.fragment >> Makefile

# 4. Update .gitignore
cat claude-learning-system/.gitignore.fragment >> .gitignore
```

---

## How It Works

### Workflow

```
┌─────────────────────────────────────────────────────────────┐
│  1. Development Session (Claude Code)                       │
│     - Write code, fix bugs, explore codebase                │
└────────────────┬────────────────────────────────────────────┘
                 │
                 ▼
┌─────────────────────────────────────────────────────────────┐
│  2. Capture Learnings (/capture-learnings)                  │
│     - AI analyzes transcript                                 │
│     - Generates structured learning file                     │
│     - Saves to docs/sessions/learnings/YYYY-MM-DD.md        │
└────────────────┬────────────────────────────────────────────┘
                 │
                 ▼
┌─────────────────────────────────────────────────────────────┐
│  3. Map to CLAUDE.md (make map-learnings FILE=...)          │
│     - Python script analyzes learning file                   │
│     - Matches learnings to CLAUDE.md sections via markers    │
│     - Outputs confidence-rated suggestions                   │
└────────────────┬────────────────────────────────────────────┘
                 │
                 ▼
┌─────────────────────────────────────────────────────────────┐
│  4. Manual Review & Integration                              │
│     - You decide what enters CLAUDE.md                       │
│     - Copy high-confidence additions                         │
│     - Edit for clarity and brevity                           │
└────────────────┬────────────────────────────────────────────┘
                 │
                 ▼
┌─────────────────────────────────────────────────────────────┐
│  5. Quarterly Archive (make archive-learnings)               │
│     - Moves learnings >90 days old                           │
│     - Organizes by quarter (2025-Q1, 2025-Q2, etc.)         │
│     - Keeps CLAUDE.md focused on recent patterns             │
└─────────────────────────────────────────────────────────────┘
```

### The Marker System

CLAUDE.md sections are marked with HTML comments:

```markdown
## Git Workflow
<!-- LEARNINGS:git-workflow -->

Content about git workflow...

## Architecture
<!-- LEARNINGS:architecture -->

Content about architecture...
```

The mapper script uses these markers to suggest where learnings should be added.

---

## File Structure

```
your-project/
├── .claude/
│   ├── commands/
│   │   └── capture-learnings.md       # Slash command definition
│   └── templates/
│       └── session-learnings.md        # Learning file template
├── scripts/
│   ├── map-learnings-to-claude.py      # Mapping script
│   ├── archive-old-learnings.sh        # Archive script
│   └── add-learning-markers.sh         # Helper for existing projects
├── docs/
│   └── sessions/
│       ├── learnings/                   # Active learnings
│       │   └── 2025-11-01-example.md
│       └── archive/                     # Old learnings
│           └── 2025-Q4/
│               └── README.md
├── Makefile                             # With learning targets
├── .gitignore                           # Ignore learning content
└── CLAUDE.md                            # With LEARNINGS markers
```

---

## Commands

### Makefile Targets

```bash
# Show learning template
make show-learnings-template

# List current learnings
make list-learnings

# Map learning file to CLAUDE.md
make map-learnings FILE=docs/sessions/learnings/2025-11-01.md

# Archive learnings older than 90 days
make archive-learnings
```

### Slash Commands (in Claude Code)

```
/capture-learnings  # Analyze session and generate learning file
```

### Python Script (Advanced)

```bash
# Basic usage
python scripts/map-learnings-to-claude.py docs/sessions/learnings/2025-11-01.md

# Custom CLAUDE.md location
python scripts/map-learnings-to-claude.py \
  docs/sessions/learnings/2025-11-01.md \
  --claude-file MY_DOCS.md

# Named arguments
python scripts/map-learnings-to-claude.py \
  --learning-file learnings/today.md \
  --claude-file .docs/CLAUDE.md \
  --project-root /path/to/project
```

---

## Configuration

### Archive Threshold

Edit `scripts/archive-old-learnings.sh`:
```bash
DAYS_OLD=90  # Change to 60, 120, etc.
```

### Learning Categories

Edit `.claude/templates/session-learnings.md` to customize categories for your project type:

**Mobile (iOS/Android)**:
- SwiftUI / Jetpack Compose
- Core Data / Room Database
- Xcode / Android Studio
- App Store / Play Store

**Web (React/Node)**:
- React Patterns
- API Design
- State Management
- Build Tools

**Data Science (Python/ML)**:
- NumPy/Pandas Patterns
- ML Pipelines
- Jupyter Workflows
- Visualization

### Git Ignore Behavior

**Default** (recommended): Ignore learning content, keep structure
```gitignore
docs/sessions/learnings/*.md
docs/sessions/archive/*/
!docs/sessions/learnings/.gitkeep
```

**Alternative**: Track all learnings
```gitignore
# Don't ignore learnings
```

---

## Philosophy

### Core Principles

1. **Capture Everything**: Filter later during quarterly review
2. **AI Generates, Human Curates**: Claude creates suggestions, you decide what enters CLAUDE.md
3. **Confidence-Rated**: High/Medium/Low helps prioritization
4. **Archive Quarterly**: Prevents documentation bloat, maintains history
5. **Manual Gate**: You control what becomes institutional knowledge

### What Makes a Good Learning?

✅ **Good**:
- "Core Data saves must happen on background contexts to avoid UI blocking"
- "SwiftUI @Published properties auto-update via NSFetchedResultsController observation"
- "Pre-commit hooks fail silently when .pre-commit-config.yaml is malformed"

❌ **Bad**:
- "Fixed a bug" (too vague)
- "Added comments to file" (not a pattern)
- "Chatted with Claude about architecture" (not actionable)

### When to Capture Learnings

**Do capture**:
- After solving a non-obvious problem
- When discovering a project-specific pattern
- After debugging a tricky race condition
- When establishing a new best practice

**Don't capture**:
- After trivial fixes (typos, formatting)
- For well-known general patterns (already in docs)
- For one-off experimental code

---

## Troubleshooting

### "No learnings found"

Check:
1. Learning file exists: `ls docs/sessions/learnings/`
2. File follows template format
3. Has `<!-- LEARNINGS:category -->` markers
4. Sections match template structure

### "No matching section found"

Add HTML markers to CLAUDE.md:
```bash
./scripts/add-learning-markers.sh  # Interactive helper
```

Or manually add after section headers:
```markdown
## Your Section
<!-- LEARNINGS:your-section -->
```

### "Permission denied" on scripts

Make scripts executable:
```bash
chmod +x scripts/*.sh
```

### Python script errors

Check Python version:
```bash
python3 --version  # Requires 3.7+ for dataclasses
```

Install as standalone (no external deps needed):
```bash
# Script uses only standard library
python3 scripts/map-learnings-to-claude.py --help
```

---

## Examples

### Example Learning File

See: `.claude/templates/session-learnings.md`

### Example CLAUDE.md Integration

**Before**:
```markdown
## Core Data Architecture
<!-- LEARNINGS:architecture -->

PersistenceController manages app state...
```

**After mapping + integration**:
```markdown
## Core Data Architecture
<!-- LEARNINGS:architecture -->

PersistenceController manages app state...

### Thread Safety

All Core Data saves must happen on background contexts:
```swift
coreDataManager.performBackgroundTask { context in
    // Modify objects
    try context.save()
}
```

**Never** call `context.save()` on main thread (blocks UI).
```

---

## FAQ

**Q: Do I need to commit learning files?**
A: No (default .gitignore excludes them). Keep system structure, ignore content.

**Q: Can I use this with non-iOS projects?**
A: Yes! Customize the template categories for your domain (web, data, etc.)

**Q: What if my project uses DOCS.md instead of CLAUDE.md?**
A: Use `--claude-file` flag: `python scripts/map-learnings-to-claude.py learning.md --claude-file DOCS.md`

**Q: How do I share learnings across team?**
A: Commit curated learnings to git, or extract quarterly summaries to wiki/notion.

**Q: Can I automate integration into CLAUDE.md?**
A: Not recommended. Human review ensures quality and prevents documentation bloat.

---

## Contributing

Improvements welcome! Key areas:
- Domain-specific templates (contribute web/data/mobile variations)
- Auto-detection of project type in setup script
- VS Code / JetBrains IDE integrations
- GitHub Actions for automated archival

---

## License

MIT License - see LICENSE file

---

## Credits

Created for use with [Claude Code](https://claude.com/claude-code)

Copyright © 2025 MemoryForge, LLC. All rights reserved.
