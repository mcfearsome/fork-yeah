# Installing the mcfearsome Marketplace

This guide helps you add the **mcfearsome** marketplace to your Claude Code installation.

## Quick Install

### Option 1: Single Plugin Installation

If you just want **fork-yeah**:

```bash
# Clone and install
git clone https://github.com/mcfearsome/fork-yeah
cd fork-yeah
./setup.sh

# Start using
# In Claude Code, you can now use:
# /fork create 3
```

✅ **Done!** You can start using fork-yeah immediately.

---

### Option 2: Marketplace Integration (Future)

When Claude Code supports plugin marketplaces, you'll be able to:

```bash
# Add the marketplace
claude plugins marketplace add mcfearsome https://github.com/mcfearsome/fork-yeah

# Browse plugins
claude plugins marketplace search

# Install from marketplace
claude plugins marketplace install fork-yeah
```

*Note: Check Claude Code documentation for current marketplace support.*

---

## Manual Marketplace Setup

If you want to manage multiple plugins from this marketplace:

### Step 1: Create Marketplace Directory

```bash
# Create a directory for marketplaces
mkdir -p ~/.claude-code/marketplaces/mcfearsome
cd ~/.claude-code/marketplaces/mcfearsome
```

### Step 2: Clone Marketplace Plugins

```bash
# Clone fork-yeah
git clone https://github.com/mcfearsome/fork-yeah

# Future plugins will go here too
# git clone https://github.com/mcfearsome/another-plugin
```

### Step 3: Install Plugins

```bash
# Install fork-yeah
cd fork-yeah
./setup.sh

# Return to marketplace directory
cd ..
```

### Step 4: Create Update Script

Create `~/.claude-code/marketplaces/mcfearsome/update.sh`:

```bash
#!/bin/bash

echo "Updating mcfearsome marketplace plugins..."

# Update fork-yeah
cd fork-yeah && git pull && cd ..

# Add more plugins as they're released

echo "Marketplace plugins updated!"
```

Make it executable:
```bash
chmod +x update.sh
```

---

## Verifying Installation

### Check Plugin is Installed

In Claude Code:
```bash
# Should show fork-yeah commands
/help

# Test fork-yeah
/fork status
```

### Check Installation Paths

```bash
# Plugin should be linked here
ls -la ~/.claude-code/skills/fork-yeah

# Config should exist
ls -la ~/.config/fork-yeah/

# Data directory
ls -la ~/.claude-code/forks/
```

---

## Updating Plugins

### Update fork-yeah

```bash
cd ~/.claude-code/marketplaces/mcfearsome/fork-yeah
git pull
./setup.sh  # Re-run if needed
```

### Auto-Update Script

Create `~/bin/update-claude-plugins.sh`:

```bash
#!/bin/bash

MARKETPLACE_DIR="$HOME/.claude-code/marketplaces/mcfearsome"

if [ -d "$MARKETPLACE_DIR" ]; then
    cd "$MARKETPLACE_DIR"

    for plugin in */; do
        echo "Updating $plugin..."
        cd "$plugin"
        git pull
        cd ..
    done

    echo "All plugins updated!"
else
    echo "Marketplace not found at $MARKETPLACE_DIR"
fi
```

Add to cron for weekly updates:
```bash
# Edit crontab
crontab -e

# Add line (runs every Sunday at 3am)
0 3 * * 0 ~/bin/update-claude-plugins.sh
```

---

## Troubleshooting

### Plugin Commands Not Found

**Problem:** `/fork` commands don't work

**Solutions:**
1. Verify installation:
   ```bash
   ls -la ~/.claude-code/skills/fork-yeah
   ```

2. Re-run setup:
   ```bash
   cd /path/to/fork-yeah
   ./setup.sh
   ```

3. Restart Claude Code

### Dependencies Missing

**Problem:** Setup fails due to missing dependencies

**Solution:**
```bash
# Ubuntu/Debian
sudo apt-get update
sudo apt-get install git python3 jq tmux

# macOS
brew install git python3 jq tmux

# Fedora
sudo dnf install git python3 jq tmux
```

### Permission Issues

**Problem:** Permission denied errors

**Solution:**
```bash
# Make sure scripts are executable
chmod +x setup.sh
chmod +x src/*.sh
chmod +x src/*.py
```

---

## Uninstalling

### Remove fork-yeah

```bash
# Remove symlink
rm ~/.claude-code/skills/fork-yeah

# Remove config
rm -rf ~/.config/fork-yeah

# Remove data (WARNING: deletes all forks!)
rm -rf ~/.claude-code/forks

# Remove plugin files
rm -rf ~/.claude-code/marketplaces/mcfearsome/fork-yeah
```

### Remove Entire Marketplace

```bash
# Remove all mcfearsome plugins
rm -rf ~/.claude-code/marketplaces/mcfearsome
```

---

## Getting Help

- **Documentation:** [README.md](README.md)
- **Marketplace Guide:** [MARKETPLACE.md](MARKETPLACE.md)
- **Troubleshooting:** [docs/TROUBLESHOOTING.md](docs/TROUBLESHOOTING.md)
- **Issues:** https://github.com/mcfearsome/fork-yeah/issues
- **Discussions:** https://github.com/mcfearsome/fork-yeah/discussions

---

## Supporting the Project

If you find this marketplace useful:

- ⭐ **Star** the repository
- 🐛 **Report** bugs and issues
- 💡 **Suggest** new features
- 📖 **Improve** documentation
- 🔀 **Contribute** code

---

**Enjoy the mcfearsome marketplace!** 🎉
