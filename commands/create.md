---
description: Create N parallel fork branches from the current conversation checkpoint
---

# Fork Create

Creates N parallel conversation branches using git worktrees, allowing you to explore multiple approaches simultaneously.

## Usage

```
/fork create <number> [--target <branch-name>]
```

## Arguments

- `{number}` (required): Number of parallel branches to create (1-10)
- `--target <branch-name>` (optional): Target branch all forks will merge to

## What This Command Does

1. Validates you're in a git repository
2. Optionally creates or checks out the target branch
3. Captures current conversation state as a checkpoint
4. Creates N git worktrees (one per fork)
5. Sets up metadata for each fork
6. Launches terminal sessions (tmux if available, or launcher scripts)

## Before Running

Ensure you have committed any current work:
```bash
git add . && git commit -m "checkpoint before forking"
```

## Examples

**Create 3 parallel branches:**
```
/fork create 3
```

**Create 3 branches for a feature:**
```
/fork create 3 --target feature-auth
```

**Create 2 branches to compare approaches:**
```
/fork create 2 --target refactor-api
```

## Execution

To execute this command, run the fork creation script:

```bash
bash src/fork_create.sh {number} {--target} {branch-name}
```

After execution, inform the user:
- How many forks were created
- The fork IDs
- The worktree paths
- How to access each fork (tmux commands or launcher script paths)
- Next steps for working with forks

## Error Handling

If the command fails:
- **Not in git repo**: Ask user to navigate to a git repository
- **Uncommitted changes**: Suggest committing or stashing changes
- **Invalid number**: Number must be 1-10
- **Worktree exists**: Suggest running `git worktree prune`

## Output Format

Show a clear summary:
```
Created 3 fork branches!

Fork branches created:
  1. fork-1730678901-abc123-1
     Path: /home/user/.claude-code/forks/fork-1730678901-abc123-1/worktree
  2. fork-1730678901-abc123-2
     Path: /home/user/.claude-code/forks/fork-1730678901-abc123-2/worktree
  3. fork-1730678901-abc123-3
     Path: /home/user/.claude-code/forks/fork-1730678901-abc123-3/worktree

Target Branch: feature-auth

To work with your forks:
  - Attach to tmux session: tmux attach -t fork-1730678901-abc123-1
  - List forks: /fork list
  - View tree: /fork tree
```
