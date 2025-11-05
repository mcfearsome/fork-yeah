#!/bin/bash

# fork_delete.sh
# Delete a fork branch and its worktree

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/terminal_manager.sh"

FORK_DATA_DIR="$HOME/.claude-code/forks"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

print_error() { echo -e "${RED}✗ $@${NC}"; }
print_success() { echo -e "${GREEN}✓ $@${NC}"; }
print_warning() { echo -e "${YELLOW}⚠ $@${NC}"; }
print_info() { echo -e "${BLUE}ℹ $@${NC}"; }

# Show usage
usage() {
    cat << EOF
Usage: fork_delete.sh <fork_id>

Delete a fork branch and its worktree.

Arguments:
  fork_id   ID of the fork to delete

Examples:
  fork_delete.sh fork-1234567890-abc123-1

EOF
    exit 1
}

# Delete fork
delete_fork() {
    local fork_id=$1

    if [ -z "$fork_id" ]; then
        print_error "Fork ID required"
        usage
    fi

    # Check if fork exists
    local fork_dir="$FORK_DATA_DIR/$fork_id"
    if [ ! -d "$fork_dir" ]; then
        print_error "Fork not found: $fork_id"
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

    # Confirm deletion
    print_warning "About to delete fork: $fork_id"
    print_info "Worktree: $worktree_path"
    echo ""
    read -p "Are you sure? [y/N] " -n 1 -r
    echo ""

    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        print_info "Deletion cancelled"
        exit 0
    fi

    # Kill tmux session if it exists
    if is_tmux_available; then
        local session_name="fork-$fork_id"
        if tmux has-session -t "$session_name" 2>/dev/null; then
            print_info "Killing tmux session: $session_name"
            tmux kill-session -t "$session_name" 2>/dev/null || true
        fi
    fi

    # Remove git worktree
    if [ -d "$worktree_path" ]; then
        print_info "Removing worktree..."
        git worktree remove "$worktree_path" --force 2>/dev/null || {
            rm -rf "$worktree_path"
        }
        print_success "Worktree removed"
    fi

    # Delete git branch
    local branch_name="$fork_id"
    if git show-ref --verify --quiet "refs/heads/$branch_name"; then
        print_info "Deleting branch: $branch_name"
        git branch -D "$branch_name" 2>/dev/null || true
        print_success "Branch deleted"
    fi

    # Remove fork data directory
    print_info "Removing fork data..."
    rm -rf "$fork_dir"
    print_success "Fork data removed"

    echo ""
    print_success "Fork deleted successfully: $fork_id"
}

# Main entry point
main() {
    if [ $# -eq 0 ]; then
        usage
    fi

    delete_fork "$1"
}

# Run
main "$@"
