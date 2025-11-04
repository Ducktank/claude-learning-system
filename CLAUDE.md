# CLAUDE.md - Claude Learning System Instructions

**Project:** Claude Learning System
**Purpose:** Systematic capture and integration of learnings from AI-assisted development sessions
**For:** Claude Code and developers using AI-assisted workflows

---

## Project Overview
<!-- LEARNINGS:project-overview -->

This is the **Claude Learning System** - a framework for capturing, mapping, and integrating learnings from development sessions directly into project documentation.

### Core Concept

Transform ephemeral session insights into permanent institutional knowledge through:
1. **Capture** - Extract learnings via `/capture-learnings` slash command
2. **Map** - Automatically suggest where learnings fit in CLAUDE.md
3. **Review** - Human curator decides what becomes permanent knowledge
4. **Archive** - Quarterly cleanup prevents documentation bloat

### Key Files

```
.claude/
├── commands/capture-learnings.md       # Slash command for capturing learnings
└── templates/session-learnings.md      # Template for learning files

scripts/
├── map-learnings-to-claude.py          # Maps learnings to CLAUDE.md sections
├── add-learning-markers.sh             # Helper to add HTML markers
└── archive-old-learnings.sh            # Archives old learnings quarterly

docs/sessions/
├── learnings/                          # Active learning files (< 90 days)
└── archive/                            # Archived learnings by quarter
```

---

## Development Workflow
<!-- LEARNINGS:development-workflow -->

### When to Use This System

**✅ DO capture learnings when:**
- Solving non-obvious problems or debugging tricky issues
- Discovering project-specific patterns or anti-patterns
- Establishing new best practices or workflow improvements
- Finding time-saving techniques or optimization strategies
- Encountering platform-specific quirks or edge cases

**❌ DON'T capture learnings for:**
- Trivial fixes (typos, formatting)
- Well-known general patterns (already documented)
- One-off experimental code
- Simple feature additions without insights

### Standard Session Flow

1. **During Development**
   - Work on tasks normally
   - Mental note of non-obvious discoveries
   - Continue until logical stopping point

2. **End of Session**
   ```
   /capture-learnings
   ```
   - Claude analyzes entire transcript
   - Generates structured learning file
   - Saves to `docs/sessions/learnings/YYYY-MM-DD-description.md`

3. **Map Learnings to CLAUDE.md**
   ```bash
   make map-learnings FILE=docs/sessions/learnings/2025-11-04-example.md
   ```
   - Script analyzes learning file
   - Matches to CLAUDE.md sections via HTML markers
   - Outputs confidence-rated suggestions

4. **Manual Review & Integration**
   - Review HIGH confidence suggestions first
   - Copy relevant additions to CLAUDE.md
   - Edit for clarity and project consistency
   - Commit changes

5. **Quarterly Archive** (every 90 days)
   ```bash
   make archive-learnings
   ```
   - Moves old learnings to `docs/sessions/archive/YYYY-QN/`
   - Maintains history without cluttering active docs
   - Generates archive summary

---

## Claude Instructions for `/capture-learnings`
<!-- LEARNINGS:capture-learnings-instructions -->

When the user invokes `/capture-learnings`, follow this process:

### Step 1: Review Session Transcript

Analyze the **entire conversation** to identify:

**Technical Patterns:**
- Language-specific discoveries (e.g., Swift concurrency, React patterns)
- Architecture decisions and their rationale
- Performance optimizations that worked
- Thread safety or async patterns

**Workflow Efficiency:**
- Git commands that solved specific problems
- Build/tooling discoveries
- Debugging techniques that proved effective
- IDE or tool configurations

**Communication Patterns:**
- Prompts that led to better results
- Questions that clarified ambiguity
- Misunderstandings and how they were resolved

**Anti-Patterns:**
- Approaches that seemed correct but failed
- Common mistakes to avoid
- Misleading error messages

### Step 2: Generate Learning File

Use the template at `.claude/templates/session-learnings.md` and fill in:

**Header Section:**
```markdown
**Date:** {YYYY-MM-DD}
**Session Duration:** {approximate time}
**Branch:** {git branch name}
**Primary Task:** {one sentence description}
```

**Quick Summary:**
1-2 sentences covering what was accomplished AND what was learned (not just "we did X")

**Learnings by Category:**

For each category (Git Workflow, Swift Concurrency, Code Quality, etc.):

```markdown
### {Category Name}
<!-- LEARNINGS:{category-slug} -->

**Pattern Discovered:**
- {Specific, actionable description}

**CLAUDE.md Section:** {Target section name}
**Confidence:** High | Medium | Low
**Actionable:** Yes | No
**Suggested Addition:**
```markdown
{Exact text ready to paste into CLAUDE.md}
```
```

**Anti-Patterns Section:**
```markdown
## Anti-Patterns Discovered

**What Didn't Work:**
- {Pattern that seemed right but was wrong}

**Why It Failed:**
{Technical explanation}

**Correct Approach:**
{What should be done instead}
```

**Metrics:**
```markdown
- **Warnings Fixed:** {count}
- **Errors Resolved:** {count}
- **Commits Made:** {count}
- **Learning Density:** High | Medium | Low
```

### Step 3: Save Learning File

Save to: `docs/sessions/learnings/{YYYY-MM-DD}-{brief-description}.md`

**Filename format:**
- Use date: YYYY-MM-DD
- Add brief dash-separated description
- Keep filename under 50 chars
- Example: `2025-11-04-core-data-threading-fix.md`

### Step 4: Prompt User

After generating the file, ask:
```
I've captured the learnings from this session.

Next steps:
1. Review learnings: Open docs/sessions/learnings/{filename}
2. Map to CLAUDE.md: make map-learnings FILE=docs/sessions/learnings/{filename}
3. Manual integration: Copy HIGH confidence suggestions to CLAUDE.md

Would you like me to:
- Review and edit learnings before saving?
- Proceed with mapping to CLAUDE.md sections?
- Mark this as low-value (minimal learnings)?
```

### Quality Criteria

**✅ Good Learnings:**
- "Core Data saves must happen on background contexts to avoid UI blocking"
- "SwiftUI @Published properties trigger updates via Combine observation"
- "Pre-commit hooks fail silently when .pre-commit-config.yaml is malformed"

**❌ Bad Learnings:**
- "Fixed a bug" (too vague)
- "Added comments to file" (not a pattern)
- "Chatted about architecture" (not actionable)

### Learning Density Assessment

**High Density:**
- Multiple non-obvious discoveries
- Clear anti-patterns identified
- Significant debugging insights
- Time-saving techniques found

**Medium Density:**
- Some useful patterns
- Incremental improvements
- Clarifications of existing knowledge

**Low Density:**
- Mostly straightforward work
- No significant discoveries
- Better to skip formal capture

**If Low Density:** Say so honestly. Don't force insights.

---

## HTML Marker System
<!-- LEARNINGS:marker-system -->

CLAUDE.md sections are marked with HTML comments to enable automatic mapping:

### Marker Format

```markdown
## Section Name
<!-- LEARNINGS:section-slug -->

Content goes here...
```

### Marker Rules

1. **Placement:** Immediately after section header (## or ###)
2. **Format:** `<!-- LEARNINGS:category -->`
3. **Naming:**
   - Lowercase only
   - Use hyphens (not underscores or spaces)
   - Match template categories
   - Descriptive and unique

### Common Markers

```markdown
<!-- LEARNINGS:git-workflow -->          # Git commands, branching, commits
<!-- LEARNINGS:architecture -->          # System design, components, structure
<!-- LEARNINGS:code-quality -->          # Linting, standards, best practices
<!-- LEARNINGS:build-tooling -->         # Build systems, development tools
<!-- LEARNINGS:swift-concurrency -->     # Swift-specific async patterns
<!-- LEARNINGS:testing-debugging -->     # Test strategies, debug techniques
<!-- LEARNINGS:ai-interaction -->        # Effective AI communication patterns
<!-- LEARNINGS:troubleshooting -->       # Common issues and solutions
```

### Adding Markers

**Interactive helper:**
```bash
./scripts/add-learning-markers.sh
```

**Manual addition:**
Edit CLAUDE.md and add markers after headers

**Verify markers:**
```bash
grep -n "LEARNINGS:" CLAUDE.md
```

---

## Mapping Script Usage
<!-- LEARNINGS:mapping-script -->

The `map-learnings-to-claude.py` script automates matching learnings to CLAUDE.md sections.

### Basic Usage

```bash
# Via Makefile (recommended)
make map-learnings FILE=docs/sessions/learnings/2025-11-04-example.md

# Direct script execution
python3 scripts/map-learnings-to-claude.py docs/sessions/learnings/2025-11-04-example.md

# Custom CLAUDE.md location
python3 scripts/map-learnings-to-claude.py \
  docs/sessions/learnings/2025-11-04-example.md \
  --claude-file DOCS.md
```

### Script Process

1. **Parse learning file** - Extract categorized learnings
2. **Find CLAUDE.md sections** - Locate HTML markers
3. **Match learnings to sections** - Based on category names
4. **Generate confidence-rated diffs** - Show suggested additions
5. **Output summary** - High/Medium/Low confidence groupings

### Output Format

```
================================================================================
Session Learning Mapper
================================================================================

Project root: /path/to/project
Parsing: docs/sessions/learnings/2025-11-04-example.md
Target: CLAUDE.md

✓ Found 5 learnings

✓ Found 8 marked sections in CLAUDE.md

================================================================================
Suggested Changes
================================================================================

🔴 HIGH CONFIDENCE (Strongly recommend adding):

================================================================================
Learning: Core Data saves must use background context...
Target Section: Architecture (line 42)
Confidence: High
================================================================================
Suggested addition to CLAUDE.md:

@@ Line 50 @@
+### Thread Safety in Core Data
+
+All Core Data saves must happen on background contexts to avoid blocking the UI:
+
+```swift
+coreDataManager.performBackgroundTask { context in
+    // Modify objects
+    try context.save()
+}
+```
```

### Confidence Levels

**🔴 HIGH** - Strong pattern, clear section match, actionable
- Integrate immediately
- Minimal editing needed
- Clear benefit to future sessions

**🟡 MEDIUM** - Good pattern, may need refinement
- Review carefully
- Edit for clarity
- Ensure no duplication

**⚪ LOW** - Uncertain value or unclear placement
- Consider carefully
- May be too specific
- Might belong elsewhere

### Manual Integration Process

1. **Start with HIGH confidence** suggestions
2. **Open CLAUDE.md** in editor
3. **Navigate to suggested line number**
4. **Copy suggested text** and paste
5. **Edit for consistency** with existing content
6. **Remove redundancy** if overlapping with existing docs
7. **Commit changes** with clear message

---

## Makefile Targets
<!-- LEARNINGS:makefile-targets -->

### Available Commands

```bash
# Display the session learnings template
make show-learnings-template

# List current learning files
make list-learnings

# Map a learning file to CLAUDE.md sections
make map-learnings FILE=docs/sessions/learnings/YYYY-MM-DD-example.md

# Archive learnings older than 90 days
make archive-learnings
```

### Target Definitions

```makefile
.PHONY: map-learnings
map-learnings:
	@python3 scripts/map-learnings-to-claude.py $(FILE)

.PHONY: archive-learnings
archive-learnings:
	@scripts/archive-old-learnings.sh

.PHONY: list-learnings
list-learnings:
	@find docs/sessions/learnings -name "*.md" -type f -exec basename {} \; | sort

.PHONY: show-learnings-template
show-learnings-template:
	@cat .claude/templates/session-learnings.md
```

### Integration into Projects

**For existing Makefiles:**
```bash
cat Makefile.fragment >> Makefile
```

**For new projects:**
```bash
cp Makefile.fragment Makefile
```

**Without Make:**
Use scripts directly (see Development Workflow section)

---

## Archival System
<!-- LEARNINGS:archival-system -->

### Purpose

Prevent documentation bloat while maintaining history:
- Active learnings: < 90 days old
- Archived learnings: > 90 days old, moved to quarterly folders
- Searchable history: All learnings remain accessible

### Running Archive

```bash
make archive-learnings
```

### Archive Process

1. **Find old files** - Learnings older than 90 days
2. **Show candidates** - List files to be archived
3. **Confirm with user** - Requires Y/N confirmation
4. **Move to quarter folder** - `docs/sessions/archive/YYYY-QN/`
5. **Generate README** - Quarter summary with file list
6. **Update archive summary** - Global index of archives

### Archive Structure

```
docs/sessions/archive/
├── archive-summary.md              # Global index
├── 2025-Q1/
│   ├── README.md                   # Quarter metadata
│   ├── 2024-11-01-example.md
│   └── 2024-12-15-another.md
└── 2025-Q2/
    ├── README.md
    └── ...
```

### Accessing Archived Learnings

**Restore a learning:**
```bash
mv docs/sessions/archive/2025-Q1/filename.md docs/sessions/learnings/
```

**Search archives:**
```bash
grep -r "pattern" docs/sessions/archive/
```

**Review quarter summary:**
```bash
cat docs/sessions/archive/2025-Q1/README.md
```

### Customizing Archive Threshold

Edit `scripts/archive-old-learnings.sh`:
```bash
DAYS_THRESHOLD=90  # Change to 60, 120, etc.
```

---

## Git Workflow
<!-- LEARNINGS:git-workflow -->

### Committing Changes

**When to commit:**
- After mapping learnings and integrating to CLAUDE.md
- After creating new learning captures
- After quarterly archive operations

**What to commit:**
- System structure (directories, .gitkeep files)
- Scripts and templates
- CLAUDE.md updates

**What NOT to commit (default .gitignore):**
- Learning file content (`docs/sessions/learnings/*.md`)
- Archive content (`docs/sessions/archive/*/`)
- Keep structure files (`.gitkeep`)

### .gitignore Configuration

**Default (recommended):**
```gitignore
# Session Learnings (keep structure, ignore content)
docs/sessions/learnings/*.md
docs/sessions/archive/*/
!docs/sessions/learnings/.gitkeep
!docs/sessions/archive/.gitkeep
```

**Alternative (track all learnings):**
```gitignore
# Track all learnings
# (Don't add ignore rules)
```

### Branch Strategy

**For this repository:**
- Main development on feature branches
- Branch naming: `claude/feature-name-sessionid`
- PR-based integration to main

---

## Installation & Integration
<!-- LEARNINGS:installation -->

### New Projects

**Automated:**
```bash
curl -sSL https://raw.githubusercontent.com/Ducktank/claude-learning-system/main/scripts/setup-learning-system.sh | bash
```

**Manual:**
```bash
git clone https://github.com/Ducktank/claude-learning-system.git
cd claude-learning-system
./scripts/setup-learning-system.sh
```

### Existing Projects

See **INTEGRATION.md** for detailed migration guide.

**Quick integration:**
```bash
# 1. Copy files
rsync -av claude-learning-system/.claude/ ./.claude/
rsync -av claude-learning-system/scripts/ ./scripts/

# 2. Add markers to CLAUDE.md
./scripts/add-learning-markers.sh

# 3. Merge Makefile
cat claude-learning-system/Makefile.fragment >> Makefile

# 4. Update .gitignore
cat claude-learning-system/.gitignore.fragment >> .gitignore

# 5. Verify
make show-learnings-template
make list-learnings
```

---

## Troubleshooting
<!-- LEARNINGS:troubleshooting -->

### No Learnings Found

**Symptoms:** Script reports "0 learnings found"

**Solutions:**
1. Verify file follows template format
2. Check for required fields: Pattern, CLAUDE.md Section, Confidence
3. Ensure `**Suggested Addition:**` followed by ` ```markdown` block
4. Validate category headers (### Category Name)

### No Matching Section Found

**Symptoms:** "⚠️ No matching section found for: X"

**Solutions:**
1. Add HTML markers to CLAUDE.md: `./scripts/add-learning-markers.sh`
2. Verify marker matches category: `git-workflow` matches `Git Workflow`
3. Check marker format: `<!-- LEARNINGS:slug -->` (no spaces in slug)
4. Grep existing markers: `grep "LEARNINGS:" CLAUDE.md`

### Script Permission Denied

**Symptoms:** `bash: permission denied: ./scripts/...`

**Solution:**
```bash
chmod +x scripts/*.sh
```

### Python Script Errors

**Symptoms:** Import errors, syntax errors

**Solutions:**
1. Check Python version: `python3 --version` (requires 3.7+)
2. Verify script path: `which python3`
3. Use standard library only (no external dependencies)

### Markers Not Detected

**Symptoms:** Script doesn't find CLAUDE.md sections

**Solutions:**
1. Verify marker format exactly: `<!-- LEARNINGS:slug -->`
2. Ensure lowercase slugs with hyphens only
3. Check marker placement: immediately after ## or ### headers
4. Validate no typos: `LEARNINGS` not `LEARNING`

---

## Best Practices
<!-- LEARNINGS:best-practices -->

### For Developers

1. **Capture frequently** - Don't wait until end of day
2. **Be specific** - "Why" matters more than "what"
3. **Rate honestly** - Low density sessions are normal
4. **Review before integrating** - Claude suggests, you decide
5. **Archive quarterly** - Prevents documentation bloat
6. **Customize categories** - Match your project domain

### For Claude

1. **Analyze entire transcript** - Don't just summarize recent messages
2. **Distinguish learning from recap** - "We did X" vs "X is better than Y because..."
3. **Rate confidence accurately** - High = proven pattern, Low = uncertain
4. **Provide exact text** - Ready to paste, properly formatted
5. **Be honest about density** - Don't force insights
6. **Focus on actionable patterns** - Future sessions should benefit

### What Makes a Good Learning

**✅ Characteristics:**
- **Specific:** Names exact APIs, commands, or patterns
- **Actionable:** Can be applied in future sessions
- **Non-obvious:** Not common knowledge or in docs
- **Proven:** Actually solved a problem or improved workflow
- **Contextual:** Explains why, not just what

**❌ Avoid:**
- Vague generalizations ("be more careful")
- Recaps without insight ("we added feature X")
- Obvious facts ("functions should be tested")
- One-off hacks ("I tried X and it worked this time")

---

## Philosophy & Rationale
<!-- LEARNINGS:philosophy -->

### Core Principles

**1. Capture Everything, Filter Later**
- Low friction during development
- Quarterly review determines what's valuable
- History remains searchable even if not in main docs

**2. AI Generates, Human Curates**
- Claude analyzes patterns and suggests
- Developer decides what enters CLAUDE.md
- No automated integration (prevents bloat)

**3. Confidence-Rated Suggestions**
- High/Medium/Low helps prioritization
- Developers focus on high-confidence first
- Reduces review time

**4. Archive Quarterly**
- Prevents documentation bloat
- Maintains searchable history
- Focuses CLAUDE.md on recent patterns

**5. Manual Gate**
- You control institutional knowledge
- Ensures quality and relevance
- Builds understanding through review

### Why This Approach

**Problem:**
- Valuable insights from AI sessions are lost in chat history
- Repeating solved problems wastes time
- Tribal knowledge doesn't transfer to documentation

**Solution:**
- Structured capture at session end
- Automated suggestions reduce manual work
- Human review ensures quality

**Result:**
- CLAUDE.md becomes living document
- Each session improves future sessions
- Compounding returns on knowledge investment

### Comparison to Alternatives

**Manual note-taking:** Too much friction, often skipped

**Automated commit messages:** Too granular, lacks context

**Wiki/Notion docs:** Separate from codebase, goes stale

**This system:** In-repo, automated suggestions, human-curated, sustainable

---

## Customization
<!-- LEARNINGS:customization -->

### Adapt to Your Domain

**Mobile (iOS/Android):**
```markdown
### SwiftUI Patterns
<!-- LEARNINGS:swiftui-patterns -->

### Core Data / Room
<!-- LEARNINGS:persistence -->

### Xcode / Android Studio
<!-- LEARNINGS:ide-tooling -->
```

**Web (React/Node):**
```markdown
### React Patterns
<!-- LEARNINGS:react-patterns -->

### API Design
<!-- LEARNINGS:api-design -->

### State Management
<!-- LEARNINGS:state-management -->
```

**Data Science (Python/ML):**
```markdown
### NumPy/Pandas
<!-- LEARNINGS:data-manipulation -->

### ML Pipelines
<!-- LEARNINGS:ml-pipelines -->

### Jupyter Workflows
<!-- LEARNINGS:notebook-workflows -->
```

### Customizing Template

Edit `.claude/templates/session-learnings.md` to match your categories:

1. Change category headers (### Category Name)
2. Update HTML markers (<!-- LEARNINGS:slug -->)
3. Adjust confidence criteria for your domain
4. Add domain-specific metrics

### Customizing Markers

Edit CLAUDE.md and `add-learning-markers.sh`:

1. Add project-specific section names
2. Update marker patterns in script
3. Run marker helper: `./scripts/add-learning-markers.sh`

---

## Examples
<!-- LEARNINGS:examples -->

### Example Learning (High Confidence)

```markdown
### Swift Concurrency
<!-- LEARNINGS:swift-concurrency -->

**Pattern Discovered:**
- MainActor isolation requires all properties and methods to be accessed from main thread; calling @MainActor methods from Task requires await

**CLAUDE.md Section:** Development Patterns / Architecture
**Confidence:** High
**Actionable:** Yes
**Suggested Addition:**
```markdown
### MainActor Thread Safety

When working with @MainActor classes, all property access and method calls must happen on the main thread:

```swift
@MainActor class ViewModel {
    var data: String = ""

    func update() {
        data = "new value"
    }
}

// Calling from background thread requires await
Task {
    await viewModel.update()  // Switches to main thread
}
```

Forgetting `await` causes: "Expression is 'async' but is not marked with 'await'"
```
```

### Example Learning (Medium Confidence)

```markdown
### Build & Tooling
<!-- LEARNINGS:build-tooling -->

**Pattern Discovered:**
- Xcode sometimes caches old build artifacts; cleaning derived data fixes "mysterious" build errors

**CLAUDE.md Section:** Troubleshooting
**Confidence:** Medium
**Actionable:** Yes
**Suggested Addition:**
```markdown
### Build Cache Issues

If encountering unexplainable build errors after major refactors:

```bash
# Clean derived data
rm -rf ~/Library/Developer/Xcode/DerivedData
```

Then rebuild. This clears stale build artifacts that confuse incremental compilation.
```
```

### Example Anti-Pattern

```markdown
## Anti-Patterns Discovered

**What Didn't Work:**
- Attempting to use Task.sleep() to wait for UI updates

**Why It Failed:**
- UI updates are asynchronous and non-deterministic
- sleep() just delays execution without guaranteeing completion
- Race conditions caused intermittent test failures

**Correct Approach:**
Use expectations and wait for notifications/KVO:

```swift
let expectation = XCTestExpectation(description: "UI updated")
NotificationCenter.default.addObserver(forName: .dataUpdated, ...) { _ in
    expectation.fulfill()
}
// Trigger update
wait(for: [expectation], timeout: 2.0)
```

**CLAUDE.md Update Needed:** Yes (add to Testing section)
```

---

## Meta: Improving This System
<!-- LEARNINGS:meta-improvements -->

### Using This System on Itself

This learning system should capture its own improvements:

1. **Run `/capture-learnings`** after sessions improving this system
2. **Map to this CLAUDE.md** using markers defined above
3. **Integrate improvements** to make instructions clearer
4. **Archive old patterns** as system evolves

### Feedback Loop

```
Use system → Discover friction → Capture learning → Improve system → Use improved system
```

### Areas for Contribution

**High value:**
- Domain-specific templates (mobile, web, data science)
- IDE integrations (VS Code, JetBrains)
- GitHub Actions for automated archival
- Auto-detection of project type in setup script

**Medium value:**
- Visualization of learning trends over time
- Slack/Discord notifications for new learnings
- Web UI for browsing archived learnings
- LLM-powered duplicate detection

**Documentation:**
- More example learning files
- Video walkthrough of first capture
- Screenshots of mapping process
- Case studies from real projects

---

## Quick Reference
<!-- LEARNINGS:quick-reference -->

### Commands Cheat Sheet

```bash
# Capture learnings
/capture-learnings                                      # In Claude Code

# Map to CLAUDE.md
make map-learnings FILE=docs/sessions/learnings/{file}  # Via Makefile
python3 scripts/map-learnings-to-claude.py {file}      # Direct

# List current learnings
make list-learnings
find docs/sessions/learnings -name "*.md" -type f

# Archive old learnings (> 90 days)
make archive-learnings
./scripts/archive-old-learnings.sh

# Add markers to CLAUDE.md
./scripts/add-learning-markers.sh

# Verify markers
grep -n "LEARNINGS:" CLAUDE.md

# Show template
make show-learnings-template
cat .claude/templates/session-learnings.md
```

### File Locations

| Purpose | Path |
|---------|------|
| Capture command | `.claude/commands/capture-learnings.md` |
| Learning template | `.claude/templates/session-learnings.md` |
| Active learnings | `docs/sessions/learnings/` |
| Archived learnings | `docs/sessions/archive/YYYY-QN/` |
| Mapping script | `scripts/map-learnings-to-claude.py` |
| Archive script | `scripts/archive-old-learnings.sh` |
| Marker helper | `scripts/add-learning-markers.sh` |
| Setup script | `scripts/setup-learning-system.sh` |

### Marker Syntax

```markdown
## Section Name
<!-- LEARNINGS:section-slug -->
```

Rules:
- Lowercase only
- Hyphens not underscores
- Immediately after header
- Matches template categories

### Confidence Ratings

| Rating | Meaning | Action |
|--------|---------|--------|
| 🔴 High | Proven pattern, clear benefit | Integrate immediately |
| 🟡 Medium | Good pattern, needs review | Edit and integrate |
| ⚪ Low | Uncertain value | Consider carefully |

---

## Additional Resources

**Repository:** https://github.com/Ducktank/claude-learning-system
**Integration Guide:** See INTEGRATION.md
**Setup Script:** `scripts/setup-learning-system.sh`
**Issues/Feedback:** GitHub Issues

---

**Copyright © 2025 MemoryForge, LLC. All rights reserved.**

**License:** MIT - See LICENSE file
