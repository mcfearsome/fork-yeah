#!/bin/bash

# fork_tree.sh
# Visualize fork hierarchy as a tree

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
FORK_DATA_DIR="$HOME/.claude-code/forks"

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
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

# Build fork relationships
declare -A fork_parents
declare -A fork_children
declare -a all_forks

# Read all forks and build parent-child relationships
while IFS= read -r -d '' fork_dir; do
    fork_id=$(basename "$fork_dir")
    all_forks+=("$fork_id")

    metadata_file="$fork_dir/metadata.json"
    if [ -f "$metadata_file" ]; then
        parent_id=$(jq -r '.parent_id // "root"' "$metadata_file" 2>/dev/null)
        fork_parents["$fork_id"]="$parent_id"

        # Add to parent's children list
        if [ -n "${fork_children[$parent_id]}" ]; then
            fork_children["$parent_id"]="${fork_children[$parent_id]} $fork_id"
        else
            fork_children["$parent_id"]="$fork_id"
        fi
    fi
done < <(find "$FORK_DATA_DIR" -mindepth 1 -maxdepth 1 -type d -print0 2>/dev/null)

# Check if any forks exist
if [ ${#all_forks[@]} -eq 0 ]; then
    echo -e "${YELLOW}No forks found. Create one with: /fork create <number>${NC}"
    exit 0
fi

# Print tree recursively
print_tree() {
    local parent_id=$1
    local prefix=$2
    local is_last=$3

    # Get children of this parent
    local children=(${fork_children[$parent_id]})

    if [ ${#children[@]} -eq 0 ]; then
        return
    fi

    # Sort children for consistent display
    IFS=$'\n' sorted_children=($(sort <<<"${children[*]}"))
    unset IFS

    local child_count=${#sorted_children[@]}
    local idx=0

    for child in "${sorted_children[@]}"; do
        idx=$((idx + 1))
        local is_last_child=false

        if [ $idx -eq $child_count ]; then
            is_last_child=true
        fi

        # Determine tree characters
        if [ "$is_last_child" = true ]; then
            local branch="└── "
            local extension="    "
        else
            local branch="├── "
            local extension="│   "
        fi

        # Print this fork
        echo -ne "${prefix}${branch}"
        echo -e "${CYAN}${child}${NC}"

        # Print metadata if available
        local metadata_file="$FORK_DATA_DIR/$child/metadata.json"
        if [ -f "$metadata_file" ]; then
            local created_at=$(jq -r '.created_at // ""' "$metadata_file" 2>/dev/null)
            local status=$(jq -r '.status // ""' "$metadata_file" 2>/dev/null)
            local branch_num=$(jq -r '.branch_number // ""' "$metadata_file" 2>/dev/null)

            if [ -n "$created_at" ]; then
                echo -e "${prefix}${extension}${GREEN}Created:${NC} $created_at"
            fi
            if [ -n "$status" ]; then
                echo -e "${prefix}${extension}${GREEN}Status:${NC} $status"
            fi
            if [ -n "$branch_num" ]; then
                echo -e "${prefix}${extension}${GREEN}Branch:${NC} #$branch_num"
            fi
        fi

        # Recursively print children
        print_tree "$child" "${prefix}${extension}" "$is_last_child"
    done
}

# Display header
print_header "Fork Tree"
echo ""

# Find root-level forks (those with parent_id = "root" or parent that doesn't exist)
root_forks=()
for fork_id in "${all_forks[@]}"; do
    parent_id="${fork_parents[$fork_id]}"

    # Check if parent is root or doesn't exist in our fork list
    if [ "$parent_id" = "root" ] || [ "$parent_id" = "null" ] || [ -z "$parent_id" ]; then
        root_forks+=("$fork_id")
    fi
done

# If no clear root forks, group by parent_id
if [ ${#root_forks[@]} -eq 0 ]; then
    # Group forks by their parent_id
    declare -A parent_groups
    for fork_id in "${all_forks[@]}"; do
        parent_id="${fork_parents[$fork_id]}"
        if [ -n "${parent_groups[$parent_id]}" ]; then
            parent_groups["$parent_id"]="${parent_groups[$parent_id]} $fork_id"
        else
            parent_groups["$parent_id"]="$fork_id"
        fi
    done

    # Display each group
    for parent_id in "${!parent_groups[@]}"; do
        echo -e "${MAGENTA}Group:${NC} $parent_id"

        children=(${parent_groups[$parent_id]})
        for child in "${children[@]}"; do
            echo -e "  ${CYAN}├──${NC} $child"

            metadata_file="$FORK_DATA_DIR/$child/metadata.json"
            if [ -f "$metadata_file" ]; then
                created_at=$(jq -r '.created_at // ""' "$metadata_file" 2>/dev/null)
                status=$(jq -r '.status // ""' "$metadata_file" 2>/dev/null)

                [ -n "$created_at" ] && echo -e "  ${CYAN}│${NC}   ${GREEN}Created:${NC} $created_at"
                [ -n "$status" ] && echo -e "  ${CYAN}│${NC}   ${GREEN}Status:${NC} $status"
            fi
        done
        echo ""
    done
else
    # Display tree from root forks
    for root_fork in "${root_forks[@]}"; do
        echo -e "${MAGENTA}●${NC} ${CYAN}${root_fork}${NC}"

        # Print metadata for root
        metadata_file="$FORK_DATA_DIR/$root_fork/metadata.json"
        if [ -f "$metadata_file" ]; then
            created_at=$(jq -r '.created_at // ""' "$metadata_file" 2>/dev/null)
            status=$(jq -r '.status // ""' "$metadata_file" 2>/dev/null)

            [ -n "$created_at" ] && echo -e "  ${GREEN}Created:${NC} $created_at"
            [ -n "$status" ] && echo -e "  ${GREEN}Status:${NC} $status"
        fi

        # Print children recursively
        print_tree "$root_fork" "" false
        echo ""
    done
fi

# Summary
echo -e "${BLUE}=========================================${NC}"
echo -e "${GREEN}Total forks: ${#all_forks[@]}${NC}"
echo -e "${BLUE}=========================================${NC}"
