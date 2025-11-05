#!/bin/bash

# fork_switch.sh
# Switch to a different fork branch

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/terminal_manager.sh"

FORK_DATA_DIR="$HOME/.claude-code/forks"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

print_error() { echo -e "${RED}✗ $@${NC}"; }
print_success() { echo -e "${GREEN}✓ $@${NC}"; }
print_info() { echo -e "${BLUE}ℹ $@${NC}"; }

# Show usage
usage() {
    cat << EOF
Usage: fork_switch.sh <fork_id>

Switch to a different fork branch.

Arguments:
  fork_id   ID of the fork to switch to

Examples:
  fork_switch.sh fork-1234567890-abc123-1

EOF
    exit 1
}

# Main switch logic
switch_fork() {
    local fork_id=$1

    if [ -z "$fork_id" ]; then
        print_error "Fork ID required"
        usage
    fi

    # Check if fork exists
    local fork_dir="$FORK_DATA_DIR/$fork_id"
    if [ ! -d "$fork_dir" ]; then
        print_error "Fork not found: $fork_id"
        echo ""
        print_info "Available forks:"
        ls -1 "$FORK_DATA_DIR" 2>/dev/null | grep "^fork-" || echo "  (none)"
        exit 1
    fi

    # Get worktree path
    local metadata_file="$fork_dir/metadata.json"
    local worktree_path=""

    if [ -f "$metadata_file" ]; then
        worktree_path=$(jq -r '.worktree_path // ""' "$metadata_file" 2>/dev/null)
    fi

    if [ -z "$worktree_path" ]; then
        worktree_path="$fork_dir/worktree"
    fi

    # Check if worktree exists
    if [ ! -d "$worktree_path" ]; then
        print_error "Worktree not found: $worktree_path"
        print_info "The fork may have been deleted or moved."
        exit 1
    fi

    print_info "Switching to fork: $fork_id"
    print_info "Worktree: $worktree_path"
    echo ""

    # Switch based on terminal mode
    switch_to_fork "$fork_id" "$worktree_path"

    print_success "Switched to fork: $fork_id"
}

# Main entry point
main() {
    if [ $# -eq 0 ]; then
        usage
    fi

    switch_fork "$1"
}

# Run
main "$@"
