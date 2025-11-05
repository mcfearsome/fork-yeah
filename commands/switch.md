---
description: Switch to a different fork branch
---

# Fork Switch

Switches the working environment to a different fork branch.

## Usage

```
/fork switch <fork-id>
```

## Arguments

- `{fork-id}` (required): The ID of the fork to switch to

## What This Command Does

1. Validates the fork exists
2. Retrieves the fork's worktree path
3. Switches to the fork based on terminal mode:
   - **tmux mode**: Attaches to or switches to the fork's tmux session
   - **Other modes**: Changes to the worktree directory

## Execution

To execute this command, run:

```bash
bash src/fork_switch.sh {fork-id}
```

## Examples

```
/fork switch fork-1730678901-abc123-2
```

## Before Switching

Consider:
- Committing any work in the current fork
- Note which fork you're currently in
- Check fork status with `/fork status`

## Output

On success:
```
Switching to fork: fork-1730678901-abc123-2
Worktree: /home/user/.claude-code/forks/fork-1730678901-abc123-2/worktree

[If tmux available]
Attached to tmux session: fork-1730678901-abc123-2

[Otherwise]
Switched to fork: fork-1730678901-abc123-2
Working directory: /home/user/.claude-code/forks/fork-1730678901-abc123-2/worktree
```

## Error Handling

- **Fork not found**: Display available forks with `/fork list`
- **Worktree missing**: Suggest deleting the fork and recreating
- **Invalid fork-id**: Check the ID with `/fork list`

## After Switching

Remind the user:
- They're now in a different fork
- Current git branch
- Use `/fork status` to see fork details
- Changes made here won't affect other forks
