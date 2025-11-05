---
description: List all active fork branches with their metadata and status
---

# Fork List

Displays all active fork branches with their creation time, status, worktree paths, and branch numbers.

## Usage

```
/fork list
```

## What This Command Does

1. Scans the `~/.claude-code/forks/` directory for fork data
2. Reads metadata for each fork
3. Checks if worktrees still exist
4. Displays formatted list with status indicators

## Execution

To execute this command, run:

```bash
bash src/fork_list.sh
```

## Output Format

The command displays:
- Fork ID
- Status (active, archived)
- Creation timestamp
- Branch number (if part of a group)
- Worktree path
- Warning if worktree is missing

Example output:
```
=========================================
Active Fork Branches
=========================================

Fork: fork-1730678901-abc123-1
  Status: active
  Created: 2025-11-05T10:30:00-05:00
  Branch #: 1
  Path: /home/user/.claude-code/forks/fork-1730678901-abc123-1/worktree

Fork: fork-1730678901-abc123-2
  Status: active
  Created: 2025-11-05T10:30:00-05:00
  Branch #: 2
  Path: /home/user/.claude-code/forks/fork-1730678901-abc123-2/worktree

=========================================
Total forks: 2
=========================================

Commands:
  /fork switch <fork-id>  - Switch to a fork
  /fork tree              - View fork hierarchy
  /fork delete <fork-id>  - Delete a fork
```

## When No Forks Exist

If there are no forks, display:
```
No forks found. Create one with: /fork create <number>
```

## After Displaying

Suggest relevant next actions:
- Use `/fork switch <id>` to work on a specific fork
- Use `/fork tree` to see the hierarchy
- Use `/fork create` to make new forks
