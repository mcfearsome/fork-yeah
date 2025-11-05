# mcfearsome's Claude Code Plugin Marketplace

Welcome to the **mcfearsome** marketplace for Claude Code plugins! This marketplace offers quality plugins to enhance your Claude Code experience.

## Available Plugins

### 🍴 fork-yeah
**Version:** 0.1.0
**Category:** Workflow / Development Tools

Branch your Claude Code conversations to try different approaches in parallel. Uses git worktrees and conversation checkpointing to let you explore multiple solution paths.

**Features:**
- Create N parallel conversation branches
- Git worktree integration
- Target branch workflow for feature development
- tmux terminal multiplexing
- Visual fork tree
- Cross-platform support (Linux, macOS, Windows/WSL)

**Installation:** See below

---

## How to Use This Marketplace

### Method 1: Direct Plugin Installation (Recommended)

Install plugins directly from this marketplace:

```bash
# Clone the plugin repository
git clone https://github.com/mcfearsome/fork-yeah
cd fork-yeah

# Run the setup script
./setup.sh
```

The setup script will:
- Check dependencies
- Install optional components (like tmux)
- Set up Claude Code integration
- Configure the plugin

### Method 2: Add Marketplace to Claude Code

If Claude Code supports marketplace URLs, you can add this marketplace:

```bash
# Add mcfearsome marketplace
claude-code marketplace add mcfearsome https://github.com/mcfearsome/fork-yeah

# List available plugins
claude-code marketplace search mcfearsome

# Install a plugin
claude-code marketplace install fork-yeah
```

### Method 3: Manual Installation

1. **Clone the repository:**
   ```bash
   cd ~/.claude-code/plugins  # or your plugins directory
   git clone https://github.com/mcfearsome/fork-yeah
   ```

2. **Run setup:**
   ```bash
   cd fork-yeah
   ./setup.sh
   ```

3. **Verify installation:**
   ```bash
   # In Claude Code
   /fork --help
   ```

---

## Plugin: fork-yeah

### Quick Start

```bash
# Install
git clone https://github.com/mcfearsome/fork-yeah
cd fork-yeah
./setup.sh

# Use in Claude Code
/fork create 3                      # Create 3 parallel branches
/fork create 3 --target my-feature  # Create 3 branches for my-feature
/fork list                          # List all forks
/fork tree                          # Visualize hierarchy
/fork switch <fork-id>              # Switch to a fork
```

### Requirements

**Required:**
- Git
- Python 3.6+
- jq (JSON processor)

**Optional:**
- tmux (highly recommended for best experience)

### Supported Platforms

- ✅ Linux (all distributions)
- ✅ macOS (10.14+)
- ✅ Windows via WSL/WSL2

### Configuration

Edit `~/.config/fork-yeah/config.yaml` to customize behavior:

```yaml
terminal:
  mode: auto  # auto, tmux, macos, linux, basic

fork:
  max_forks: 10
  auto_checkpoint: true

display:
  use_colors: true
  tree_ascii: true
```

### Documentation

- **Full Documentation:** [README.md](README.md)
- **Troubleshooting:** [docs/TROUBLESHOOTING.md](docs/TROUBLESHOOTING.md)
- **Issues:** https://github.com/mcfearsome/fork-yeah/issues
- **Discussions:** https://github.com/mcfearsome/fork-yeah/discussions

---

## Marketplace Information

### About mcfearsome

This marketplace is curated by mcfearsome, focused on providing high-quality, well-documented plugins for Claude Code.

**Philosophy:**
- Quality over quantity
- Comprehensive documentation
- Cross-platform support
- Active maintenance
- Community-driven

### Contributing

Want to contribute a plugin to this marketplace?

1. **Fork this repository**
2. **Create your plugin** following the structure:
   ```
   your-plugin/
   ├── SKILL.md         # Plugin definition
   ├── setup.sh         # Installation script
   ├── README.md        # Documentation
   └── src/             # Plugin code
   ```
3. **Update marketplace.yaml** to include your plugin
4. **Submit a pull request**

**Plugin Requirements:**
- Must have comprehensive documentation
- Must include setup/installation script
- Must specify dependencies clearly
- Must be tested on at least one platform
- Must have MIT or compatible license

### Plugin Standards

All plugins in this marketplace follow these standards:

1. **Documentation**
   - Clear README with examples
   - Troubleshooting guide
   - Platform-specific notes

2. **Installation**
   - Automated setup script
   - Dependency checking
   - User-friendly error messages

3. **Code Quality**
   - Clean, readable code
   - Comments where necessary
   - Error handling

4. **Compatibility**
   - Cross-platform support (or clearly documented limitations)
   - Version compatibility noted

### Roadmap

Future plugins planned for this marketplace:

- **session-save** - Save and restore Claude Code sessions
- **context-manager** - Advanced context window management
- **git-flow** - Git workflow automation for Claude Code
- **test-runner** - Integrated test running with Claude feedback
- **doc-gen** - Automated documentation generation

### Support

- **Issues:** Report bugs or request features
- **Discussions:** Ask questions, share tips
- **Wiki:** Community-contributed guides and tutorials

### License

All plugins in the mcfearsome marketplace are open source.

- **fork-yeah:** MIT License

---

## Updates

### Stay Updated

Watch this repository for updates:

```bash
# Star the repo to get notifications
gh repo clone mcfearsome/fork-yeah
cd fork-yeah
git pull  # Get latest updates
```

### Changelog

**v0.1.0** (2025-11-05)
- Initial release of fork-yeah plugin
- Core fork management functionality
- Target branch support
- tmux integration
- Cross-platform support

---

## Feedback

We value your feedback! Please:

- ⭐ Star the repository if you find it useful
- 🐛 Report bugs via Issues
- 💡 Suggest features via Discussions
- 🤝 Contribute improvements via Pull Requests

---

**Happy Claude Coding!** 🚀
