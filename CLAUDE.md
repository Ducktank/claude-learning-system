# CLAUDE.md

Project documentation for AI-assisted development.

## Build & Development
<!-- LEARNINGS:build-tooling -->

### Installation Script Best Practices

**Curl-Pipe Installation Pattern**

Anti-pattern: Relying on `${BASH_SOURCE[0]}` when supporting curl-pipe execution
```bash
# ❌ BREAKS with curl-pipe
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PACKAGE_ROOT="$(dirname "$SCRIPT_DIR")"
cp "$PACKAGE_ROOT/templates/file.md" destination/
```

Solution: Detect curl-pipe mode and download files from GitHub instead
```bash
# ✅ Works with both local and curl-pipe execution
if [ -z "$SCRIPT_DIR" ] || [ ! -d "$PACKAGE_ROOT" ]; then
    # Curl-pipe mode: download files from GitHub
    curl -sSL https://raw.githubusercontent.com/org/repo/main/templates/file.md -o destination/file.md
else
    # Local mode: copy from filesystem
    cp "$PACKAGE_ROOT/templates/file.md" destination/
fi
```

Workaround for current script:
```bash
# Clone first, then run
git clone https://github.com/org/repo.git /tmp/repo
cd /path/to/target-project
/tmp/repo/scripts/setup.sh
```

## Architecture
<!-- LEARNINGS:architecture -->

[Document your architecture here]

## Git Workflow
<!-- LEARNINGS:git-workflow -->

### Testing Installation Scripts

When validating setup/installation scripts:

```bash
# Clone to temp location for testing
git clone https://github.com/org/repo.git /tmp/repo

# Run from target project directory
cd /path/to/actual-project
/tmp/repo/scripts/setup.sh

# Cleanup after validation
rm -rf /tmp/repo
```

Benefits:
- Doesn't pollute project git history
- Easy to restart from clean state
- Can test multiple times without conflicts

## Code Quality
<!-- LEARNINGS:code-quality -->

### External Script Safety Protocol

Before executing scripts from the internet:

1. **Download and review first** (never blind pipe):
```bash
# ❌ Dangerous: zero visibility
curl -sSL https://example.com/install.sh | bash

# ✅ Safe: review before execution
curl -sSL https://example.com/install.sh -o /tmp/install.sh
cat /tmp/install.sh  # Review for malicious code
bash /tmp/install.sh
```

2. **Security checklist:**
- [ ] No credential harvesting (.env, API keys, tokens)
- [ ] No destructive operations without confirmation
- [ ] No privilege escalation (sudo without prompts)
- [ ] Backup mechanism for modified files
- [ ] Exit-on-error flag (`set -e`) present
- [ ] Interactive prompts for destructive changes

3. **Red flags:**
- Hidden network calls after initial download
- Obfuscated code (base64 encoding, eval commands)
- Modification of system files without backups
- Disabling security features (selinux, firewall)

## Troubleshooting
<!-- LEARNINGS:troubleshooting -->

### Debugging Installation Script Failures

Common failure pattern: File copy operations fail with "No such file or directory"

**First check:** Script's directory resolution logic
```bash
# Add debug output to script
echo "SCRIPT_DIR: $SCRIPT_DIR"
echo "PACKAGE_ROOT: $PACKAGE_ROOT"
echo "PROJECT_ROOT: $PROJECT_ROOT"
```

**Common causes:**
1. Curl-pipe execution: `SCRIPT_DIR` is empty
2. Symlinks: `dirname` doesn't resolve correctly
3. Running from wrong directory: Relative paths fail

**Fix:** Verify all path variables before file operations
