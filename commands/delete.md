---
description: Delete a fork branch and its worktree
---

# Fork Delete

Deletes a fork branch, removes its git worktree, and cleans up all associated metadata. This action prompts for confirmation before proceeding.

## Usage

```
/fork delete <fork-id>
```

## Arguments

- `{fork-id}` (required): The ID of the fork to delete

## What This Command Does

1. Validates fork exists
2. Displays fork information
3. Prompts for confirmation
4. Kills associated tmux session (if exists)
5. Removes git worktree
6. Deletes git branch
7. Removes fork data directory

## Execution

To execute this command, run:

```bash
bash src/fork_delete.sh {fork-id}
```

## Examples

```
/fork delete fork-1730678901-abc123-3
```

## Confirmation Process

The command will prompt:
```
About to delete fork: fork-1730678901-abc123-3
Worktree: /home/user/.claude-code/forks/fork-1730678901-abc123-3/worktree

Are you sure? [y/N]
```

Type `y` to confirm or `n` to cancel.

## What Gets Deleted

1. **Tmux session**: `fork-<fork-id>` session killed
2. **Git worktree**: Removed from filesystem
3. **Git branch**: Branch `fork-<fork-id>` deleted
4. **Fork data**: Directory `~/.claude-code/forks/<fork-id>` removed

## Output Format

**Successful deletion:**
```
Killing tmux session: fork-1730678901-abc123-3
Removing worktree...
✓ Worktree removed

Deleting branch: fork-1730678901-abc123-3
✓ Branch deleted

Removing fork data...
✓ Fork data removed

Fork deleted successfully: fork-1730678901-abc123-3
```

**Cancelled:**
```
Deletion cancelled
```

## Before Deleting

**Important considerations:**

1. **Backup important changes**: Make sure any work you want to keep has been merged
2. **Check for nested forks**: Deleting a parent fork doesn't delete children
3. **Verify fork ID**: Use `/fork list` to confirm the correct fork
4. **Consider archiving**: Instead of deleting, you could keep the fork for reference

## Recovering Deleted Forks

**Warning**: Deletion is permanent! You cannot undo this action.

If you deleted a fork by mistake:
- The git commits may still be in reflog (for ~30 days)
- Use `git reflog` to find the commit
- Create a new branch from that commit

## When to Delete Forks

Delete forks when:
- The experiment failed and you don't need the code
- Changes have been merged and fork is no longer needed
- You're cleaning up old forks to save disk space
- The fork was created by mistake

## Don't Delete Forks When

Keep forks if:
- You might want to reference the code later
- The approach might be useful in the future
- You haven't fully evaluated the work
- Others might benefit from seeing the alternative approach

## Cleaning Up Multiple Forks

To delete multiple forks:

1. List all forks: `/fork list`
2. Delete one at a time: `/fork delete <fork-id>`
3. Verify with: `/fork tree`

## After Deletion

- Removed fork won't appear in `/fork list`
- Fork won't appear in `/fork tree`
- Git worktree is cleaned up
- Disk space is reclaimed
