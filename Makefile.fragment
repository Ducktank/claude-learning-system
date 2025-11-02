# ==============================================================================
# Claude Learning System - Makefile Targets
# ==============================================================================
# Copy these targets into your project's Makefile
#
# Usage:
#   cat claude-learning-system/Makefile.fragment >> Makefile
#
# Or manually copy the targets below
# ==============================================================================

# Session Learnings Management
.PHONY: map-learnings
map-learnings: ## Map session learnings to CLAUDE.md sections
	@if [ -z "$(FILE)" ]; then \
		echo "Error: Please specify a learnings file"; \
		echo "Usage: make map-learnings FILE=docs/sessions/learnings/2025-11-01.md"; \
		exit 1; \
	fi
	@echo "Mapping learnings to CLAUDE.md..."
	@python3 scripts/map-learnings-to-claude.py $(FILE)

.PHONY: archive-learnings
archive-learnings: ## Archive session learnings older than 90 days
	@echo "Archiving old learnings..."
	@scripts/archive-old-learnings.sh

.PHONY: list-learnings
list-learnings: ## List current session learnings
	@echo "Current session learnings:"
	@find docs/sessions/learnings -name "*.md" -type f -exec basename {} \; | sort || echo "No learnings found"

.PHONY: show-learnings-template
show-learnings-template: ## Display the session learnings template
	@echo "Session Learnings Template:"
	@echo "============================="
	@cat .claude/templates/session-learnings.md

# ==============================================================================
# End of Claude Learning System Targets
# ==============================================================================
