---
description: Show status of the current fork and conversation state
---

# Fork Status

Shows the current fork's status including git status, worktree information, and fork metadata. Helps you understand which fork you're currently working in.

## Usage

```
/fork status
```

## What This Command Does

1. Detects current fork from working directory
2. Displays fork metadata
3. Shows git status for the fork
4. Lists worktree information
5. Shows total fork count

## Execution

To execute this command, run:

```bash
bash src/fork_status.sh
```

## Output Format

**When in a fork:**
```
=========================================
Fork Status
=========================================

Current Fork: fork-1730678901-abc123-2

Details:
  Parent Fork: fork-1730678901-abc123
  Created: 2025-11-05T10:30:00-05:00
  Status: active
  Branch #: 2
  Worktree: /home/user/.claude-code/forks/fork-1730678901-abc123-2/worktree

Git Status:
## fork-1730678901-abc123-2
 M README.md
 M src/main.py

Worktree Info:
/home/user/.claude-code/forks/fork-1730678901-abc123-2/worktree  abc123de [fork-1730678901-abc123-2]

=========================================
Total forks: 3
=========================================

Commands:
  /fork list    - List all forks
  /fork tree    - View fork hierarchy
  /fork switch  - Switch to another fork
```

**When not in a fork:**
```
=========================================
Fork Status
=========================================

Not in a fork worktree
Current directory: /home/user/project

=========================================
Total forks: 3
=========================================

Commands:
  /fork list    - List all forks
  /fork tree    - View fork hierarchy
  /fork switch  - Switch to another fork
```

## Information Provided

The status shows:
- **Current fork ID**: Which fork you're in
- **Parent fork**: If this is a nested fork
- **Creation time**: When fork was created
- **Git status**: Modified, staged, untracked files
- **Worktree info**: Git worktree details
- **Total forks**: Count of all forks

## When to Use

Use `/fork status` when:
- You're unsure which fork you're in
- You want to check for uncommitted changes
- You need the fork ID for other commands
- You want to verify fork metadata
