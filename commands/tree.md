---
description: Visualize the fork hierarchy as an ASCII tree
---

# Fork Tree

Displays a visual tree representation of all forks and their parent-child relationships, useful for understanding nested fork structures.

## Usage

```
/fork tree
```

## What This Command Does

1. Scans all fork metadata
2. Builds parent-child relationships
3. Identifies root-level forks
4. Recursively builds and displays the tree structure
5. Shows metadata for each fork

## Execution

To execute this command, run:

```bash
bash src/fork_tree.sh
```

## Output Format

Example tree output:
```
=========================================
Fork Tree
=========================================

● fork-1730678901-abc123-1
  Created: 2025-11-05T10:30:00-05:00
  Status: active
  ├── fork-1730678902-def456-1
  │   Created: 2025-11-05T11:00:00-05:00
  │   Status: active
  └── fork-1730678902-def456-2
      Created: 2025-11-05T11:00:00-05:00
      Status: active

● fork-1730678901-abc123-2
  Created: 2025-11-05T10:30:00-05:00
  Status: active

=========================================
Total forks: 4
=========================================
```

## Tree Symbols

- `●` - Root fork
- `├──` - Child fork (not last)
- `└──` - Child fork (last)
- `│` - Connection line

## Understanding the Tree

- **Root forks**: Top-level forks created directly
- **Nested forks**: Forks created from other forks
- **Groups**: Forks with the same parent ID

## When No Forks Exist

Display:
```
No forks found. Create one with: /fork create <number>
```

## After Displaying

Suggest:
- Use `/fork switch <id>` to navigate to a specific fork
- Use `/fork list` for detailed fork information
- Note which forks are nested for cleanup planning
