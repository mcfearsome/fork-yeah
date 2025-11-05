---
description: Merge changes from another fork branch into the current branch
---

# Fork Merge

Merges changes from another fork branch into your current branch, allowing you to combine work from different forks.

## Usage

```
/fork merge <source-fork-id>
```

## Arguments

- `{source-fork-id}` (required): The ID of the fork to merge from

## What This Command Does

1. Validates source fork exists
2. Checks current branch
3. Checks for uncommitted changes (warns if found)
4. Performs git merge from source fork branch
5. Displays merge results or conflict information

## Execution

To execute this command, run:

```bash
bash src/fork_merge.sh {source-fork-id}
```

## Examples

**Merge fork-2 into current branch:**
```
/fork merge fork-1730678901-abc123-2
```

## Before Merging

**Important checks:**
1. Know which fork you're currently in (`/fork status`)
2. Commit any uncommitted changes
3. Understand what changes exist in the source fork
4. Consider creating a backup branch

## Output Format

**Successful merge:**
```
Current branch: fork-1730678901-abc123-1
Merging from: fork-1730678901-abc123-2

Merge completed successfully!

Merge summary:
 README.md        | 10 +++++++---
 src/feature.py   | 45 +++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 52 insertions(+), 3 deletions(-)
```

**Merge with conflicts:**
```
Current branch: fork-1730678901-abc123-1
Merging from: fork-1730678901-abc123-2

Merge failed - conflicts detected
Resolve conflicts and commit the merge manually

Commands:
  git status          - See conflicted files
  git add <file>      - Mark conflicts as resolved
  git commit          - Complete the merge
  git merge --abort   - Cancel the merge
```

## Handling Conflicts

If conflicts occur:

1. **Review conflicts:**
   ```bash
   git status
   ```

2. **Edit conflicted files** - Look for conflict markers:
   ```
   <<<<<<< HEAD
   Your changes
   =======
   Their changes
   >>>>>>> fork-1730678901-abc123-2
   ```

3. **Resolve and stage:**
   ```bash
   git add <resolved-file>
   ```

4. **Complete merge:**
   ```bash
   git commit
   ```

5. **Or abort:**
   ```bash
   git merge --abort
   ```

## After Merging

- Review the merged code
- Run tests to ensure nothing broke
- Consider deleting the source fork if no longer needed
- Update documentation if needed

## Best Practices

- Merge small, focused changes frequently
- Test before and after merging
- Keep forks synchronized with target branch
- Document why you chose to merge specific changes
