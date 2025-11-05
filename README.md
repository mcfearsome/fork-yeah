# 🍴 fork-yeah

**A Claude Code plugin for branching conversation paths**

Fork-yeah enables you to create parallel branches of your Claude Code conversations, allowing you to explore different approaches while "saving your spot." Think of it as git branches for your AI conversations.

## Features

- **Parallel Conversation Paths**: Create N parallel branches from any point in your conversation
- **Git Worktrees**: Each fork gets its own isolated git worktree
- **State Checkpointing**: Saves complete conversation state at fork points
- **Terminal Multiplexing**: Seamless integration with tmux for managing multiple forks
- **Nested Forks**: Support for creating forks within fork branches
- **Visual Fork Tree**: See your fork hierarchy at a glance
- **Cross-Platform**: Works on Linux, macOS, and Windows (WSL)

## Quick Start

### Installation

```bash
# Clone the repository
git clone https://github.com/mcfearsome/fork-yeah
cd fork-yeah

# Run setup
./setup.sh
```

The setup script will:
- Check for required dependencies (git, python3, jq)
- Optionally install tmux for the best experience
- Create necessary directories
- Link the plugin to Claude Code

### Basic Usage

Inside Claude Code:

```bash
# Create 3 parallel branches from current conversation
/fork create 3

# List all your forks
/fork list

# View fork hierarchy
/fork tree

# Switch to a specific fork
/fork switch fork-1234567890-abc123-2

# Check current fork status
/fork status

# Merge changes from another fork
/fork merge fork-1234567890-abc123-1

# Delete a fork
/fork delete fork-1234567890-abc123-3
```

## How It Works

### The Fork Workflow

1. **Checkpoint**: When you create a fork, fork-yeah saves the current conversation state and git commit
2. **Branch**: Creates N git branches from that commit point
3. **Worktree**: Sets up isolated git worktrees for each fork
4. **Launch**: Spawns terminal sessions (tmux panes/windows) for each fork
5. **Work**: Each fork can evolve independently
6. **Merge**: Optionally merge successful approaches back together

### Example Scenario

```bash
# You're working on a feature and want to try two approaches

# Save your current work
git add . && git commit -m "baseline before fork"

# Create two parallel branches
/fork create 2

# This creates:
# - fork-xxx-1: Try approach A
# - fork-xxx-2: Try approach B

# Work on each approach independently
# Then merge the better one back to main
```

## Commands Reference

### `/fork create <number> [--target <branch_name>]`

Create N parallel fork branches.

**Arguments:**
- `number`: Number of branches (1-10)
- `--target <branch_name>` (optional): Target branch all forks will merge to

**Examples:**
```bash
# Create 3 parallel branches from current point
/fork create 3

# Create 3 branches targeting feature-auth branch
/fork create 3 --target feature-auth

# All forks will be created from and merge back to feature-auth
```

**What it does:**
- Captures current conversation state
- Creates or checks out target branch (if --target specified)
- Creates git branches from current commit
- Sets up worktrees for each fork
- Launches terminal sessions (if tmux available)
- Stores target branch info for future merges

**Target Branch Benefits:**
- All forks start from the same named branch
- Makes it clear where work should merge back to
- Useful for feature development with multiple approaches
- Target branch is shown in fork metadata

---

### `/fork list`

List all active fork branches.

**Output:**
- Fork ID
- Creation time
- Status
- Worktree path
- Branch number

---

### `/fork switch <fork_id>`

Switch to a different fork branch.

**Arguments:**
- `fork_id`: ID of fork to switch to

**Example:**
```bash
/fork switch fork-1730678901-a1b2c3d4-2
```

**What it does:**
- Changes to fork's worktree directory
- Attaches to tmux session (if using tmux)
- Updates shell environment

---

### `/fork tree`

Visualize fork hierarchy as a tree structure.

**Output:**
- ASCII tree showing fork relationships
- Parent-child connections
- Fork metadata

---

### `/fork status`

Show status of current fork and conversation state.

**Output:**
- Current fork (if in one)
- Fork details
- Git status
- Worktree information

---

### `/fork merge <fork_id>`

Merge changes from another fork branch.

**Arguments:**
- `fork_id`: Source fork to merge from

**Example:**
```bash
/fork merge fork-1730678901-a1b2c3d4-1
```

---

### `/fork delete <fork_id>`

Delete a fork and its worktree.

**Arguments:**
- `fork_id`: Fork to delete

**Example:**
```bash
/fork delete fork-1730678901-a1b2c3d4-3
```

**What it does:**
- Kills associated tmux session
- Removes git worktree
- Deletes git branch
- Cleans up fork data

## Terminal Modes

Fork-yeah adapts to your environment:

### tmux Mode (Recommended)

When tmux is installed:
- Creates dedicated sessions for fork groups
- Uses panes/windows for each fork
- Seamless switching between forks
- Full multiplexing capabilities

### Fallback Modes

When tmux is not available:
- **macOS**: Generates iTerm2/Terminal.app launchers
- **Linux**: Creates shell launcher scripts
- **Basic**: Simple directory switching

## Configuration

Edit `~/.config/fork-yeah/config.yaml` to customize:

```yaml
# Terminal mode: auto, tmux, macos, linux, basic
terminal:
  mode: auto

# Fork creation settings
fork:
  max_forks: 10
  auto_checkpoint: true
  confirm_multiple: true

# Display settings
display:
  use_colors: true
  tree_ascii: true
  date_format: iso
```

## File Structure

```
~/.claude-code/forks/          # Fork data directory
├── fork-xxx-1/
│   ├── checkpoint.json        # Conversation state
│   ├── metadata.json          # Fork metadata
│   ├── worktree/              # Git worktree
│   └── launch.sh              # Launcher script
├── fork-xxx-2/
│   └── ...
└── .fork-groups.json          # Fork group relationships

~/.config/fork-yeah/           # Configuration
├── config.yaml                # User config
└── tmux.conf                  # tmux settings
```

## Requirements

### Required
- Git
- Python 3
- jq (JSON processor)

### Optional
- tmux (highly recommended for best experience)

## Troubleshooting

See [TROUBLESHOOTING.md](docs/TROUBLESHOOTING.md) for common issues and solutions.

## Advanced Usage

### Nested Forks

You can create forks within fork branches:

```bash
# In main conversation
/fork create 2

# Switch to fork-1
/fork switch fork-xxx-1

# Create sub-forks
/fork create 2

# Now you have:
# - fork-xxx-1
#   - fork-yyy-1
#   - fork-yyy-2
# - fork-xxx-2
```

### Programmatic Access

Use the Python state manager directly:

```bash
# List all forks
python3 src/state_manager.py list

# Export checkpoint
python3 src/state_manager.py export fork-xxx-1 backup.json

# Import checkpoint
python3 src/state_manager.py import backup.json
```

## Contributing

Contributions welcome! Please:
1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Submit a pull request

## License

MIT License - see LICENSE file for details

## Support

- **Issues**: https://github.com/mcfearsome/fork-yeah/issues
- **Discussions**: https://github.com/mcfearsome/fork-yeah/discussions
- **Documentation**: https://github.com/mcfearsome/fork-yeah/wiki

## Credits

Created by mcfearsome for the Claude Code community.

---

**Happy Forking!** 🍴
