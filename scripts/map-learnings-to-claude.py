#!/usr/bin/env python3
"""
Map session learnings to CLAUDE.md sections and generate suggested diffs.

Usage:
    python scripts/map-learnings-to-claude.py docs/sessions/learnings/2025-11-01.md
    python scripts/map-learnings-to-claude.py docs/sessions/learnings/2025-11-01.md --claude-file DOCS.md
    python scripts/map-learnings-to-claude.py --learning-file learnings/today.md --claude-file .docs/CLAUDE.md

This script:
1. Parses a session learnings file
2. Identifies which CLAUDE.md sections each learning belongs to
3. Generates a diff showing suggested additions
4. Outputs a review file for manual integration

Copyright © 2025 MemoryForge, LLC. All rights reserved.
"""

import re
import sys
import argparse
from pathlib import Path
from typing import List, Dict, Optional
from dataclasses import dataclass
from datetime import datetime


@dataclass
class Learning:
    """Represents a single learning from a session."""
    category: str
    pattern: str
    claude_section: str
    confidence: str
    actionable: bool
    suggested_text: str
    line_number: int


@dataclass
class CLAUDESection:
    """Represents a section in CLAUDE.md."""
    name: str
    marker: str
    start_line: int
    end_line: int
    content: str


def parse_learnings_file(file_path: Path) -> List[Learning]:
    """Parse a session learnings markdown file and extract structured learnings."""
    if not file_path.exists():
        print(f"Error: File not found: {file_path}")
        sys.exit(1)

    with open(file_path, 'r') as f:
        content = f.read()

    learnings = []
    current_category = None
    current_learning = {}
    line_num = 0
    debug = False  # Set to True for debugging
    suggested_lines = None
    code_block_depth = 0

    for line_num, line in enumerate(content.split('\n'), 1):
        # Skip all parsing if we're inside a suggested text code block
        if suggested_lines is not None:
            # Handle nested code blocks
            if line.strip().startswith('```'):
                if line.strip() == '```':
                    # Closing marker
                    code_block_depth -= 1
                    if code_block_depth == 0:
                        # End of outer markdown block
                        current_learning['suggested_text'] = '\n'.join(suggested_lines)

                        # Create Learning object if we have all required fields
                        required_fields = ['category', 'pattern', 'claude_section', 'confidence', 'actionable', 'suggested_text']
                        has_all = all(k in current_learning for k in required_fields)
                        if debug:
                            print(f"Line {line_num}: End of code block")
                            print(f"  Current learning keys: {current_learning.keys()}")
                            print(f"  Has all required fields: {has_all}")
                            if not has_all:
                                missing = [k for k in required_fields if k not in current_learning]
                                print(f"  Missing fields: {missing}")

                        if has_all:
                            learnings.append(Learning(**current_learning))
                            if debug:
                                print(f"  ✓ Created learning: {current_learning['pattern'][:40]}...")

                        current_learning = {'category': current_category, 'line_number': line_num}
                        suggested_lines = None
                        continue
                else:
                    # Opening marker for nested block (e.g., ```swift)
                    code_block_depth += 1

            # Add line to suggested text (including nested code block markers)
            suggested_lines.append(line)
            continue

        # Detect category headers (only when NOT inside code block)
        if line.startswith('### '):
            current_category = line[4:].strip()
            current_learning = {'category': current_category, 'line_number': line_num}
            if debug:
                print(f"Line {line_num}: Found category: {current_category}")

        # Extract learning details
        elif line.startswith('**Pattern Discovered:**'):
            # Next line contains the pattern
            continue
        elif line.startswith('- ') and current_category and 'pattern' not in current_learning:
            current_learning['pattern'] = line[2:].strip()
            if debug:
                print(f"Line {line_num}: Found pattern: {current_learning['pattern'][:50]}...")

        elif line.startswith('**CLAUDE.md Section:**'):
            section = line.split(':', 1)[1].strip().lstrip('*').strip()
            current_learning['claude_section'] = section
            if debug:
                print(f"Line {line_num}: Found section: {section}")

        elif line.startswith('**Confidence:**'):
            confidence = line.split(':', 1)[1].strip().lstrip('*').strip().split('|')[0].strip()
            current_learning['confidence'] = confidence
            if debug:
                print(f"Line {line_num}: Found confidence: {confidence}")

        elif line.startswith('**Actionable:**'):
            value = line.split(':', 1)[1].strip().lstrip('*').strip()
            actionable = 'Yes' in value
            current_learning['actionable'] = actionable
            if debug:
                print(f"Line {line_num}: Found actionable: {actionable}")

        elif line.startswith('**Suggested Addition:**'):
            # Capture code block that follows
            suggested_lines = []
            continue

        elif line.startswith('```markdown') and current_category:
            # Start of suggested text block
            suggested_lines = []
            code_block_depth = 1
            continue

    return learnings


def find_claude_sections(claude_path: Path) -> List[CLAUDESection]:
    """Find all sections in CLAUDE.md using HTML comment markers."""
    if not claude_path.exists():
        print(f"Error: CLAUDE.md not found at {claude_path}")
        sys.exit(1)

    with open(claude_path, 'r') as f:
        lines = f.readlines()

    sections = []
    current_section = None

    for i, line in enumerate(lines, 1):
        # Look for section markers like <!-- LEARNINGS:git-workflow -->
        marker_match = re.search(r'<!-- LEARNINGS:([a-z-]+) -->', line)
        if marker_match:
            marker = marker_match.group(1)
            # Find the previous heading
            for j in range(i-1, max(0, i-20), -1):
                if lines[j].startswith('#'):
                    section_name = lines[j].strip('#').strip()
                    current_section = CLAUDESection(
                        name=section_name,
                        marker=marker,
                        start_line=j+1,
                        end_line=i,
                        content=''.join(lines[j:i])
                    )
                    break

            if current_section:
                sections.append(current_section)

    return sections


def generate_diff(learning: Learning, claude_sections: List[CLAUDESection], claude_path: Path) -> str:
    """Generate a diff showing where to insert the learning in CLAUDE.md."""
    # Find matching section
    matching_section = None
    for section in claude_sections:
        if learning.claude_section.lower().replace(' ', '-') in section.marker:
            matching_section = section
            break

    if not matching_section:
        return f"⚠️  No matching section found for: {learning.claude_section}"

    diff_output = []
    diff_output.append(f"\n{'='*80}")
    diff_output.append(f"Learning: {learning.pattern[:60]}...")
    diff_output.append(f"Target Section: {matching_section.name} (line {matching_section.start_line})")
    diff_output.append(f"Confidence: {learning.confidence}")
    diff_output.append(f"{'='*80}\n")
    diff_output.append(f"Suggested addition to {claude_path}:\n")
    diff_output.append(f"@@ Line {matching_section.end_line} @@")
    diff_output.append(f"+{learning.suggested_text}\n")

    return '\n'.join(diff_output)


def parse_args():
    """Parse command line arguments."""
    parser = argparse.ArgumentParser(
        description='Map session learnings to CLAUDE.md sections',
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  %(prog)s docs/sessions/learnings/2025-11-01.md
  %(prog)s docs/sessions/learnings/2025-11-01.md --claude-file DOCS.md
  %(prog)s --learning-file learnings/today.md --claude-file .docs/CLAUDE.md
        """
    )

    parser.add_argument(
        'learning_file',
        nargs='?',
        type=Path,
        help='Path to session learnings markdown file'
    )

    parser.add_argument(
        '--learning-file',
        type=Path,
        dest='learning_file_alt',
        help='Path to session learnings markdown file (alternative flag)'
    )

    parser.add_argument(
        '--claude-file',
        type=Path,
        default=Path('CLAUDE.md'),
        help='Path to CLAUDE.md file (default: CLAUDE.md in current directory)'
    )

    parser.add_argument(
        '--project-root',
        type=Path,
        default=None,
        help='Project root directory (default: auto-detect from script location)'
    )

    args = parser.parse_args()

    # Handle learning file from either positional or named argument
    if args.learning_file_alt:
        args.learning_file = args.learning_file_alt

    if not args.learning_file:
        parser.error('Learning file is required (provide as positional argument or --learning-file)')

    # Auto-detect project root if not specified
    if args.project_root is None:
        args.project_root = Path.cwd()

    return args


def main():
    """Main entry point."""
    args = parse_args()

    learnings_file = args.learning_file
    claude_file = args.claude_file
    project_root = args.project_root

    # Resolve paths relative to project root
    if not learnings_file.is_absolute():
        learnings_file = project_root / learnings_file
    if not claude_file.is_absolute():
        claude_file = project_root / claude_file

    print(f"\n{'='*80}")
    print(f"Session Learning Mapper")
    print(f"{'='*80}\n")
    print(f"Project root: {project_root}")
    print(f"Parsing: {learnings_file}")
    print(f"Target: {claude_file}\n")

    # Parse learnings
    learnings = parse_learnings_file(learnings_file)
    print(f"✓ Found {len(learnings)} learnings\n")

    if not learnings:
        print("No actionable learnings found. Nothing to map.")
        return

    # Find CLAUDE.md sections
    claude_sections = find_claude_sections(claude_file)
    print(f"✓ Found {len(claude_sections)} marked sections in {claude_file.name}\n")

    # Generate diffs
    print(f"{'='*80}")
    print(f"Suggested Changes")
    print(f"{'='*80}\n")

    high_confidence = []
    medium_confidence = []
    low_confidence = []

    for learning in learnings:
        if not learning.actionable:
            continue

        diff = generate_diff(learning, claude_sections, claude_file)

        if learning.confidence == 'High':
            high_confidence.append(diff)
        elif learning.confidence == 'Medium':
            medium_confidence.append(diff)
        else:
            low_confidence.append(diff)

    # Output by confidence level
    if high_confidence:
        print("\n🔴 HIGH CONFIDENCE (Strongly recommend adding):\n")
        print('\n'.join(high_confidence))

    if medium_confidence:
        print("\n🟡 MEDIUM CONFIDENCE (Review before adding):\n")
        print('\n'.join(medium_confidence))

    if low_confidence:
        print("\n⚪ LOW CONFIDENCE (Consider carefully):\n")
        print('\n'.join(low_confidence))

    # Summary
    print(f"\n{'='*80}")
    print(f"Summary")
    print(f"{'='*80}\n")
    print(f"Total learnings: {len(learnings)}")
    print(f"Actionable: {sum(1 for l in learnings if l.actionable)}")
    print(f"High confidence: {len(high_confidence)}")
    print(f"Medium confidence: {len(medium_confidence)}")
    print(f"Low confidence: {len(low_confidence)}")
    print(f"\nNext step: Manually review and integrate suggested changes into {claude_file.name}")
    print(f"{'='*80}\n")


if __name__ == '__main__':
    main()
