#!/bin/bash

# fork_status.sh
# Show status of current fork and conversation state

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
FORK_DATA_DIR="$HOME/.claude-code/forks"

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

print_header() {
    echo -e "${BLUE}=========================================${NC}"
    echo -e "${BLUE}$@${NC}"
    echo -e "${BLUE}=========================================${NC}"
}

# Try to detect current fork from working directory
detect_current_fork() {
    local current_dir="$PWD"

    # Check if we're in a fork worktree
    for fork_dir in "$FORK_DATA_DIR"/*; do
        if [ -d "$fork_dir" ]; then
            local metadata_file="$fork_dir/metadata.json"
            if [ -f "$metadata_file" ]; then
                local worktree_path=$(jq -r '.worktree_path // ""' "$metadata_file" 2>/dev/null)
                if [ -n "$worktree_path" ] && [[ "$current_dir" == "$worktree_path"* ]]; then
                    echo "$(basename "$fork_dir")"
                    return 0
                fi
            fi
        fi
    done

    return 1
}

# Display fork status
show_status() {
    print_header "Fork Status"
    echo ""

    # Try to detect current fork
    local current_fork=$(detect_current_fork)

    if [ -n "$current_fork" ]; then
        echo -e "${GREEN}Current Fork:${NC} $current_fork"
        echo ""

        # Show fork details
        local fork_dir="$FORK_DATA_DIR/$current_fork"
        local metadata_file="$fork_dir/metadata.json"

        if [ -f "$metadata_file" ]; then
            local parent_id=$(jq -r '.parent_id // "none"' "$metadata_file" 2>/dev/null)
            local created_at=$(jq -r '.created_at // "unknown"' "$metadata_file" 2>/dev/null)
            local status=$(jq -r '.status // "unknown"' "$metadata_file" 2>/dev/null)
            local worktree_path=$(jq -r '.worktree_path // "unknown"' "$metadata_file" 2>/dev/null)
            local branch_num=$(jq -r '.branch_number // "-"' "$metadata_file" 2>/dev/null)

            echo -e "${CYAN}Details:${NC}"
            echo -e "  Parent Fork: $parent_id"
            echo -e "  Created: $created_at"
            echo -e "  Status: $status"
            echo -e "  Branch #: $branch_num"
            echo -e "  Worktree: $worktree_path"
            echo ""
        fi

        # Show git status
        echo -e "${CYAN}Git Status:${NC}"
        git status --short --branch
        echo ""

        # Show worktree info
        echo -e "${CYAN}Worktree Info:${NC}"
        git worktree list | grep "$current_fork" || echo "  Not found"
        echo ""
    else
        echo -e "${YELLOW}Not in a fork worktree${NC}"
        echo -e "Current directory: $PWD"
        echo ""
    fi

    # Show all forks count
    local fork_count=$(find "$FORK_DATA_DIR" -mindepth 1 -maxdepth 1 -type d 2>/dev/null | wc -l)
    echo -e "${BLUE}=========================================${NC}"
    echo -e "${GREEN}Total forks: $fork_count${NC}"
    echo -e "${BLUE}=========================================${NC}"
    echo ""

    # Show commands
    echo -e "${BLUE}Commands:${NC}"
    echo -e "  /fork list    - List all forks"
    echo -e "  /fork tree    - View fork hierarchy"
    echo -e "  /fork switch  - Switch to another fork"
}

# Main entry point
main() {
    show_status
}

# Run
main "$@"
