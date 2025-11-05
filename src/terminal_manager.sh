#!/bin/bash

# terminal_manager.sh
# Abstraction layer for terminal multiplexing with tmux and fallback modes

# Source common utilities
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../config/common.sh" 2>/dev/null || true

# Check if tmux is available
is_tmux_available() {
    command -v tmux &> /dev/null
}

# Check if running inside tmux
is_in_tmux() {
    [ -n "$TMUX" ]
}

# Get terminal type
get_terminal_mode() {
    if is_tmux_available; then
        echo "tmux"
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        echo "macos"
    elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
        echo "linux"
    else
        echo "basic"
    fi
}

# Create new tmux session for fork
tmux_create_fork_session() {
    local session_name=$1
    local worktree_path=$2
    local num_panes=${3:-1}

    # Create new session detached
    tmux new-session -d -s "$session_name" -c "$worktree_path"

    # Create additional panes if requested
    if [ "$num_panes" -gt 1 ]; then
        for ((i=1; i<num_panes; i++)); do
            tmux split-window -t "$session_name" -c "$worktree_path"
            tmux select-layout -t "$session_name" tiled
        done
    fi

    # Set up status bar
    tmux set-option -t "$session_name" status-right "#[fg=blue]Fork: $session_name #[fg=white]| %H:%M"
    tmux set-option -t "$session_name" status-left "#[fg=green]fork-yeah #[fg=white]|"

    echo "$session_name"
}

# Create tmux window in existing session
tmux_create_window() {
    local session_name=$1
    local window_name=$2
    local worktree_path=$3

    if ! tmux has-session -t "$session_name" 2>/dev/null; then
        # Session doesn't exist, create it
        tmux_create_fork_session "$session_name" "$worktree_path" 1
    else
        # Add new window to existing session
        tmux new-window -t "$session_name" -n "$window_name" -c "$worktree_path"
    fi
}

# Attach to tmux session
tmux_attach_session() {
    local session_name=$1

    if is_in_tmux; then
        # Already in tmux, switch to session
        tmux switch-client -t "$session_name"
    else
        # Not in tmux, attach to session
        tmux attach-session -t "$session_name"
    fi
}

# List tmux sessions
tmux_list_sessions() {
    tmux list-sessions -F "#{session_name}" 2>/dev/null | grep "^fork-" || true
}

# Kill tmux session
tmux_kill_session() {
    local session_name=$1
    tmux kill-session -t "$session_name" 2>/dev/null || true
}

# Create launcher script for fallback mode
create_launcher_script() {
    local fork_id=$1
    local worktree_path=$2
    local launcher_path=$3

    cat > "$launcher_path" << 'EOF'
#!/bin/bash

# Fork launcher script
FORK_ID="%FORK_ID%"
WORKTREE_PATH="%WORKTREE_PATH%"

echo "========================================="
echo "  fork-yeah: Branch $FORK_ID"
echo "========================================="
echo ""
echo "Working directory: $WORKTREE_PATH"
echo ""

cd "$WORKTREE_PATH" || exit 1

# Start Claude Code session or interactive shell
if command -v claude &> /dev/null; then
    echo "Starting Claude Code session..."
    claude
else
    echo "Starting interactive shell..."
    echo "To start Claude Code, run: claude"
    exec $SHELL
fi
EOF

    # Replace placeholders
    sed -i "s|%FORK_ID%|$fork_id|g" "$launcher_path"
    sed -i '' "s|%WORKTREE_PATH%|$worktree_path|g" "$launcher_path" 2>/dev/null || sed -i "s|%WORKTREE_PATH%|$worktree_path|g" "$launcher_path"

    chmod +x "$launcher_path"
}

# Create macOS iTerm/Terminal launcher
create_macos_launcher() {
    local fork_id=$1
    local worktree_path=$2
    local launcher_path=$3

    cat > "$launcher_path" << 'EOF'
#!/bin/bash

FORK_ID="%FORK_ID%"
WORKTREE_PATH="%WORKTREE_PATH%"

# Detect terminal app
if [ -n "$ITERM_SESSION_ID" ]; then
    # iTerm2
    osascript <<APPLESCRIPT
tell application "iTerm"
    tell current window
        create tab with default profile
        tell current session
            write text "cd '$WORKTREE_PATH' && echo 'Fork: $FORK_ID' && claude"
        end tell
    end tell
end tell
APPLESCRIPT
else
    # Terminal.app
    osascript <<APPLESCRIPT
tell application "Terminal"
    do script "cd '$WORKTREE_PATH' && echo 'Fork: $FORK_ID' && claude"
    activate
end tell
APPLESCRIPT
fi
EOF

    # Replace placeholders
    sed -i '' "s|%FORK_ID%|$fork_id|g" "$launcher_path" 2>/dev/null || sed -i "s|%FORK_ID%|$fork_id|g" "$launcher_path"
    sed -i '' "s|%WORKTREE_PATH%|$worktree_path|g" "$launcher_path" 2>/dev/null || sed -i "s|%WORKTREE_PATH%|$worktree_path|g" "$launcher_path"

    chmod +x "$launcher_path"
}

# Launch fork in appropriate terminal
launch_fork() {
    local fork_id=$1
    local worktree_path=$2
    local mode=$(get_terminal_mode)

    case $mode in
        tmux)
            local session_name="fork-$fork_id"
            tmux_create_fork_session "$session_name" "$worktree_path" 1
            echo "Created tmux session: $session_name"
            echo "Attach with: tmux attach -t $session_name"
            ;;
        macos)
            local launcher="$HOME/.claude-code/forks/$fork_id/launch.sh"
            create_macos_launcher "$fork_id" "$worktree_path" "$launcher"
            echo "Created launcher: $launcher"
            echo "Run: $launcher"
            ;;
        *)
            local launcher="$HOME/.claude-code/forks/$fork_id/launch.sh"
            create_launcher_script "$fork_id" "$worktree_path" "$launcher"
            echo "Created launcher: $launcher"
            echo "Run: $launcher"
            ;;
    esac
}

# Switch to fork
switch_to_fork() {
    local fork_id=$1
    local worktree_path=$2
    local mode=$(get_terminal_mode)

    case $mode in
        tmux)
            local session_name="fork-$fork_id"
            if tmux has-session -t "$session_name" 2>/dev/null; then
                tmux_attach_session "$session_name"
            else
                echo "Session $session_name doesn't exist. Creating..."
                tmux_create_fork_session "$session_name" "$worktree_path" 1
                tmux_attach_session "$session_name"
            fi
            ;;
        *)
            cd "$worktree_path" || exit 1
            echo "Switched to fork: $fork_id"
            echo "Working directory: $worktree_path"
            ;;
    esac
}

# Create multiple fork panes/windows
create_fork_layout() {
    local base_fork_id=$1
    local num_forks=$2
    local mode=$(get_terminal_mode)

    case $mode in
        tmux)
            local session_name="fork-session-$(date +%s)"
            echo "Creating tmux session with $num_forks panes: $session_name"

            # Create first fork
            local first_fork_path="$HOME/.claude-code/forks/${base_fork_id}-1/worktree"
            tmux_create_fork_session "$session_name" "$first_fork_path" 1

            # Create additional panes for other forks
            for ((i=2; i<=num_forks; i++)); do
                local fork_path="$HOME/.claude-code/forks/${base_fork_id}-${i}/worktree"
                if [ -d "$fork_path" ]; then
                    tmux split-window -t "$session_name" -c "$fork_path"
                    tmux select-layout -t "$session_name" tiled
                fi
            done

            echo "Tmux session ready: $session_name"
            echo "Attach with: tmux attach -t $session_name"
            ;;
        *)
            echo "Created $num_forks fork branches."
            echo "Launch scripts created for each fork."
            echo "Run them individually to start working."
            ;;
    esac
}

# Export functions for use in other scripts
export -f is_tmux_available
export -f is_in_tmux
export -f get_terminal_mode
export -f launch_fork
export -f switch_to_fork
export -f create_fork_layout
