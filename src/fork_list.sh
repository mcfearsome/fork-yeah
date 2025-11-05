#!/bin/bash

# fork_list.sh
# List all active fork branches

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

# Check if forks directory exists
if [ ! -d "$FORK_DATA_DIR" ]; then
    echo -e "${YELLOW}No forks found. Create one with: /fork create <number>${NC}"
    exit 0
fi

# Get list of forks
forks=()
while IFS= read -r -d '' fork_dir; do
    forks+=("$(basename "$fork_dir")")
done < <(find "$FORK_DATA_DIR" -mindepth 1 -maxdepth 1 -type d -print0 2>/dev/null)

# Check if any forks exist
if [ ${#forks[@]} -eq 0 ]; then
    echo -e "${YELLOW}No forks found. Create one with: /fork create <number>${NC}"
    exit 0
fi

# Display header
print_header "Active Fork Branches"
echo ""

# Display each fork
for fork_id in "${forks[@]}"; do
    metadata_file="$FORK_DATA_DIR/$fork_id/metadata.json"

    if [ -f "$metadata_file" ]; then
        # Parse metadata
        created_at=$(jq -r '.created_at // "unknown"' "$metadata_file" 2>/dev/null)
        status=$(jq -r '.status // "unknown"' "$metadata_file" 2>/dev/null)
        worktree_path=$(jq -r '.worktree_path // "unknown"' "$metadata_file" 2>/dev/null)
        branch_num=$(jq -r '.branch_number // "-"' "$metadata_file" 2>/dev/null)

        # Format output
        echo -e "${CYAN}Fork:${NC} $fork_id"
        echo -e "  ${GREEN}Status:${NC} $status"
        echo -e "  ${GREEN}Created:${NC} $created_at"
        [ "$branch_num" != "-" ] && echo -e "  ${GREEN}Branch #:${NC} $branch_num"
        echo -e "  ${GREEN}Path:${NC} $worktree_path"

        # Check if worktree still exists
        if [ ! -d "$worktree_path" ]; then
            echo -e "  ${YELLOW}⚠ Worktree not found${NC}"
        fi

        echo ""
    else
        echo -e "${CYAN}Fork:${NC} $fork_id"
        echo -e "  ${YELLOW}⚠ No metadata found${NC}"
        echo ""
    fi
done

# Summary
echo -e "${BLUE}=========================================${NC}"
echo -e "${GREEN}Total forks: ${#forks[@]}${NC}"
echo -e "${BLUE}=========================================${NC}"
echo ""

# Show usage hints
echo -e "${BLUE}Commands:${NC}"
echo -e "  /fork switch <fork-id>  - Switch to a fork"
echo -e "  /fork tree              - View fork hierarchy"
echo -e "  /fork delete <fork-id>  - Delete a fork"
