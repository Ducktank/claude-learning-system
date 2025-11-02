Analyze the current session conversation and extract key learnings to help improve future AI-assisted development sessions.

## Your Task

1. **Review the entire session transcript** to identify patterns, insights, and anti-patterns
2. **Categorize learnings** by type (Git, Swift, Code Quality, AI Interaction, etc.)
3. **Generate a structured learning summary** using the template at `.claude/templates/session-learnings.md`
4. **Map each learning to a CLAUDE.md section** where it should be integrated
5. **Provide exact suggested text** ready to copy into CLAUDE.md
6. **Save the output** to `docs/sessions/learnings/YYYY-MM-DD-{brief-description}.md`

## Focus Areas

- **Technical patterns:** Swift concurrency, Core Data threading, actor isolation
- **Workflow efficiency:** Git commands, build optimization, debugging techniques
- **Communication patterns:** What prompts worked well, what caused confusion
- **Anti-patterns:** Things that seemed right but were wrong
- **Time-savers:** Discoveries that will speed up future sessions

## Quality Criteria

- **Actionable:** Each learning should lead to a concrete change in CLAUDE.md or workflow
- **Specific:** Avoid vague insights like "be more careful" - provide exact patterns
- **Confidence-rated:** Mark each learning as High/Medium/Low confidence
- **CLAUDE.md-mapped:** Explicitly state which section each learning belongs in

## Output Format

Use the session learnings template. Fill in all sections. For each learning, provide:

1. **Pattern Discovered:** What was learned
2. **CLAUDE.md Section:** Where it should go
3. **Confidence:** How certain you are this is a good pattern
4. **Suggested Addition:** Exact markdown text to add to CLAUDE.md

## Important

- Focus on LEARNINGS, not just a summary of what was done
- Distinguish between "we did X" (recap) and "we learned doing X is better than Y" (learning)
- If no significant learnings occurred, say so - don't force insights
- Rate the session's "learning density" (High/Medium/Low)

After generating the learning summary, ask if I want to:
1. Review and edit the learnings before saving
2. Proceed with integration into CLAUDE.md
3. Archive this as low-value if minimal learnings occurred
