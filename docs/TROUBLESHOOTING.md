# Troubleshooting Guide

Common issues and solutions for fork-yeah.

## Installation Issues

### setup.sh: Permission Denied

**Problem:**
Cannot run `./setup.sh` - permission denied

**Solution:**
```bash
chmod +x setup.sh
./setup.sh
```

---

### Missing Dependencies

**Problem:**
Error: "jq is NOT installed"

**Solution:**
```bash
# Ubuntu/Debian
sudo apt-get install jq python3 git

# macOS
brew install jq python3 git

# RHEL/CentOS/Fedora
sudo dnf install jq python3 git
```

---

## tmux Issues

### tmux Not Found

**Problem:**
fork-yeah works but without tmux features

**Solution:**
```bash
# Install tmux
# Ubuntu/Debian
sudo apt-get install tmux

# macOS
brew install tmux

# RHEL/CentOS/Fedora
sudo dnf install tmux

# Then re-run setup
cd fork-yeah
./setup.sh
```

---

### tmux Session Already Exists

**Problem:**
Error: "session already exists"

**Solution:**
```bash
# List existing sessions
tmux list-sessions

# Kill specific fork session
tmux kill-session -t fork-<fork-id>

# Or kill all fork sessions
tmux list-sessions | grep "^fork-" | cut -d: -f1 | xargs -I {} tmux kill-session -t {}
```

---

### Can't Attach to tmux Session

**Problem:**
Cannot attach to fork tmux session

**Solution:**
```bash
# Check if session exists
tmux has-session -t fork-<fork-id>

# If inside tmux, use switch instead of attach
tmux switch-client -t fork-<fork-id>

# If outside tmux, use attach
tmux attach -t fork-<fork-id>
```

---

## Git Worktree Issues

### Worktree Already Exists

**Problem:**
Error: "worktree already exists"

**Solution:**
```bash
# List existing worktrees
git worktree list

# Remove stale worktree
git worktree remove <path> --force

# Or prune all stale worktrees
git worktree prune
```

---

### Cannot Create Worktree

**Problem:**
Error when creating worktree

**Solution:**
```bash
# Make sure you're in a git repository
git status

# Check if branch already exists
git branch --list fork-*

# Delete conflicting branch
git branch -D fork-<id>

# Check for uncommitted changes
git status

# Commit or stash changes
git stash
```

---

### Worktree Path Not Found

**Problem:**
Fork exists but worktree directory is missing

**Solution:**
```bash
# Find fork ID
/fork list

# Manually remove the fork
/fork delete <fork-id>

# Clean up git worktrees
git worktree prune

# Create new fork
/fork create 1
```

---

## Fork Management Issues

### Fork Not Found

**Problem:**
Error: "Fork not found: fork-xxx"

**Solution:**
```bash
# List all available forks
/fork list

# Check fork data directory
ls -la ~/.claude-code/forks/

# If data is corrupted, clean up
rm -rf ~/.claude-code/forks/<bad-fork-id>
git worktree prune
```

---

### Cannot Switch to Fork

**Problem:**
Switch command fails

**Solution:**
```bash
# Verify fork exists
/fork list

# Check worktree path
cat ~/.claude-code/forks/<fork-id>/metadata.json

# Manually cd to worktree
cd ~/.claude-code/forks/<fork-id>/worktree

# If path doesn't exist, delete and recreate
/fork delete <fork-id>
/fork create 1
```

---

### Too Many Forks Created

**Problem:**
Accidentally created too many forks

**Solution:**
```bash
# List all forks
/fork list

# Delete unwanted forks one by one
/fork delete <fork-id-1>
/fork delete <fork-id-2>

# Or delete all forks (DANGER: removes all fork data)
rm -rf ~/.claude-code/forks/*
git worktree prune
git branch --list "fork-*" | xargs -I {} git branch -D {}
```

---

## State Management Issues

### Checkpoint Not Loading

**Problem:**
Cannot load checkpoint data

**Solution:**
```bash
# Check if checkpoint file exists
ls -la ~/.claude-code/forks/<fork-id>/checkpoint.json

# Validate JSON
cat ~/.claude-code/forks/<fork-id>/checkpoint.json | jq .

# If corrupted, delete and start fresh
rm ~/.claude-code/forks/<fork-id>/checkpoint.json

# Create new checkpoint
python3 src/state_manager.py create <fork-id>
```

---

### Python State Manager Errors

**Problem:**
Errors when running state_manager.py

**Solution:**
```bash
# Check Python version (needs 3.6+)
python3 --version

# Make sure script is executable
chmod +x src/state_manager.py

# Test state manager
python3 src/state_manager.py list

# Check for syntax errors
python3 -m py_compile src/state_manager.py
```

---

## Platform-Specific Issues

### macOS: Permission Denied for AppleScript

**Problem:**
Cannot launch forks in Terminal/iTerm

**Solution:**
- System Preferences → Security & Privacy → Privacy
- Grant Terminal/iTerm "Automation" permissions
- Try launching again

---

### macOS: iTerm Integration Not Working

**Problem:**
Forks not opening in iTerm tabs

**Solution:**
```bash
# Use launcher script manually
~/.claude-code/forks/<fork-id>/launch.sh

# Or install tmux
brew install tmux
```

---

### Linux: No Terminal Multiplexer

**Problem:**
No tmux and no GUI terminal

**Solution:**
```bash
# Install tmux
sudo apt-get install tmux  # or equivalent

# Or use launcher scripts
~/.claude-code/forks/<fork-id>/launch.sh

# Or manually cd to each fork
cd ~/.claude-code/forks/<fork-id>/worktree
```

---

### Windows (WSL): Path Issues

**Problem:**
Path errors in WSL

**Solution:**
```bash
# Make sure you're using Linux paths
pwd  # Should show /home/user/...

# Not Windows paths like /mnt/c/...

# Use WSL2 for better performance
wsl --set-version Ubuntu 2

# Install tmux in WSL
sudo apt-get install tmux
```

---

## Configuration Issues

### Config File Not Found

**Problem:**
Cannot find config.yaml

**Solution:**
```bash
# Create config directory
mkdir -p ~/.config/fork-yeah

# Copy default config
cp config/config.yaml ~/.config/fork-yeah/config.yaml

# Edit as needed
nano ~/.config/fork-yeah/config.yaml
```

---

### Colors Not Working

**Problem:**
No colored output in terminal

**Solution:**
```bash
# Check terminal supports colors
echo $TERM

# Try setting TERM
export TERM=xterm-256color

# Disable colors in config
nano ~/.config/fork-yeah/config.yaml
# Set use_colors: false
```

---

## Performance Issues

### Slow Fork Creation

**Problem:**
Creating forks takes a long time

**Solution:**
```bash
# Reduce number of forks
/fork create 2  # Instead of 10

# Clean up old forks
/fork delete <old-fork-id>

# Prune git objects
git gc
git worktree prune

# Check disk space
df -h
```

---

### Large Checkpoint Files

**Problem:**
Checkpoint files are very large

**Solution:**
```yaml
# Edit config to reduce checkpoint size
nano ~/.config/fork-yeah/config.yaml

# Set:
checkpoint:
  max_history_items: 50  # Reduce from 100
  compress: true         # Enable compression
```

---

## Recovery and Cleanup

### Complete Reset

If everything is broken:

```bash
# WARNING: This deletes ALL fork data

# 1. Remove all fork data
rm -rf ~/.claude-code/forks/*

# 2. Clean up git
git worktree prune
git branch --list "fork-*" | xargs -I {} git branch -D {}

# 3. Kill all fork tmux sessions
tmux list-sessions | grep "^fork-" | cut -d: -f1 | xargs -I {} tmux kill-session -t {}

# 4. Reinstall
cd fork-yeah
./setup.sh
```

---

### Backup Fork Data

Before major changes:

```bash
# Backup all fork data
cp -r ~/.claude-code/forks ~/fork-backup-$(date +%Y%m%d)

# Export specific fork
python3 src/state_manager.py export <fork-id> backup.json

# Restore from backup
python3 src/state_manager.py import backup.json <new-fork-id>
```

---

## Getting Help

If you're still experiencing issues:

1. **Check logs** (if logging enabled):
   ```bash
   cat ~/.claude-code/forks/fork-yeah.log
   ```

2. **Gather diagnostic info**:
   ```bash
   # System info
   uname -a
   git --version
   python3 --version
   tmux -V
   jq --version

   # Fork info
   /fork list
   /fork tree
   git worktree list
   ```

3. **Report issue**:
   - GitHub: https://github.com/mcfearsome/fork-yeah/issues
   - Include: OS, versions, error messages, steps to reproduce

4. **Community help**:
   - Discussions: https://github.com/mcfearsome/fork-yeah/discussions

---

## Debug Mode

Enable verbose output:

```bash
# Run commands with bash -x
bash -x src/fork_create.sh 2

# Enable logging
nano ~/.config/fork-yeah/config.yaml
# Set:
logging:
  enabled: true
  level: debug
```
