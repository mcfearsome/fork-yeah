#!/bin/bash

# fork_merge.sh
# Merge changes from another fork branch

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
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
Usage: fork_merge.sh <source_fork_id>

Merge changes from another fork branch into the current branch.

Arguments:
  source_fork_id   ID of the fork to merge from

Examples:
  fork_merge.sh fork-1234567890-abc123-2

EOF
    exit 1
}

# Check if we're in a git repo
check_git_repo() {
    if ! git rev-parse --git-dir > /dev/null 2>&1; then
        print_error "Not in a git repository"
        exit 1
    fi
}

# Merge fork
merge_fork() {
    local source_fork_id=$1

    if [ -z "$source_fork_id" ]; then
        print_error "Source fork ID required"
        usage
    fi

    # Check if source fork exists
    local source_fork_dir="$FORK_DATA_DIR/$source_fork_id"
    if [ ! -d "$source_fork_dir" ]; then
        print_error "Source fork not found: $source_fork_id"
        exit 1
    fi

    # Check git repo
    check_git_repo

    # Get current branch
    local current_branch=$(git rev-parse --abbrev-ref HEAD)

    print_info "Current branch: $current_branch"
    print_info "Merging from: $source_fork_id"
    echo ""

    # Check for uncommitted changes
    if [ -n "$(git status --porcelain)" ]; then
        print_warning "You have uncommitted changes in the current branch"
        echo ""
        git status --short
        echo ""
        read -p "Continue with merge? [y/N] " -n 1 -r
        echo ""

        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            print_info "Merge cancelled"
            exit 0
        fi
    fi

    # Perform merge
    print_info "Merging branch $source_fork_id into $current_branch..."
    echo ""

    if git merge "$source_fork_id" --no-ff -m "Merge fork $source_fork_id into $current_branch"; then
        echo ""
        print_success "Merge completed successfully!"

        # Show merge stats
        echo ""
        print_info "Merge summary:"
        git diff --stat HEAD~1 HEAD
    else
        echo ""
        print_error "Merge failed - conflicts detected"
        print_warning "Resolve conflicts and commit the merge manually"
        print_info "Commands:"
        print_info "  git status          - See conflicted files"
        print_info "  git add <file>      - Mark conflicts as resolved"
        print_info "  git commit          - Complete the merge"
        print_info "  git merge --abort   - Cancel the merge"
        exit 1
    fi
}

# Main entry point
main() {
    if [ $# -eq 0 ]; then
        usage
    fi

    merge_fork "$1"
}

# Run
main "$@"
