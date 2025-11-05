#!/bin/bash

# fork_create.sh
# Create N parallel fork branches from current conversation checkpoint

set -e

# Script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/terminal_manager.sh"

# Data directory
FORK_DATA_DIR="$HOME/.claude-code/forks"
STATE_MANAGER="$SCRIPT_DIR/state_manager.py"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

print_success() { echo -e "${GREEN}✓ $@${NC}"; }
print_error() { echo -e "${RED}✗ $@${NC}"; }
print_warning() { echo -e "${YELLOW}⚠ $@${NC}"; }
print_info() { echo -e "${BLUE}ℹ $@${NC}"; }
print_step() { echo -e "${CYAN}→ $@${NC}"; }

# Show usage
usage() {
    cat << EOF
Usage: fork_create.sh <number> [--target <branch_name>]

Create N parallel fork branches from the current conversation checkpoint.

Arguments:
  number              Number of parallel branches to create (1-10)
  --target <name>     Target branch name (all forks will merge to this branch)

Examples:
  fork_create.sh 2                      Create 2 parallel branches
  fork_create.sh 3 --target feature-x   Create 3 branches targeting feature-x
  fork_create.sh 5 --target my-feature  Create 5 branches for my-feature

When using --target:
  - Creates or checks out the target branch
  - All fork branches are created from the target branch
  - Forks are designed to merge back to the target branch

EOF
    exit 1
}

# Validate we're in a git repository
check_git_repo() {
    if ! git rev-parse --git-dir > /dev/null 2>&1; then
        print_error "Not in a git repository"
        exit 1
    fi
}

# Get current branch name
get_current_branch() {
    git rev-parse --abbrev-ref HEAD
}

# Get current commit hash
get_current_commit() {
    git rev-parse HEAD
}

# Generate unique fork ID
generate_fork_id() {
    local timestamp=$(date +%s)
    local random=$(openssl rand -hex 4 2>/dev/null || echo $(($RANDOM$RANDOM)))
    echo "fork-${timestamp}-${random}"
}

# Create git worktree for fork
create_worktree() {
    local fork_id=$1
    local base_commit=$2
    local branch_name="$fork_id"
    local worktree_path="$FORK_DATA_DIR/$fork_id/worktree"

    print_step "Creating worktree for $fork_id..."

    # Create fork directory
    mkdir -p "$FORK_DATA_DIR/$fork_id"

    # Create worktree
    git worktree add -b "$branch_name" "$worktree_path" "$base_commit" 2>&1 | grep -v "hint:" || true

    if [ -d "$worktree_path" ]; then
        print_success "Worktree created at $worktree_path"
        echo "$worktree_path"
    else
        print_error "Failed to create worktree"
        return 1
    fi
}

# Create checkpoint for fork
create_checkpoint() {
    local fork_id=$1
    local parent_id=$2
    local current_branch=$3
    local current_commit=$4

    print_step "Creating checkpoint for $fork_id..."

    # Prepare checkpoint data
    local checkpoint_data=$(cat <<EOF
{
  "fork_id": "$fork_id",
  "parent_id": "$parent_id",
  "base_branch": "$current_branch",
  "base_commit": "$current_commit",
  "created_at": "$(date -Iseconds)",
  "context": {
    "cwd": "$PWD",
    "git_status": "$(git status --porcelain | head -n 5)"
  }
}
EOF
)

    # Save via state manager
    echo "$checkpoint_data" | python3 "$STATE_MANAGER" create "$fork_id" "$parent_id" 2>/dev/null || {
        # Fallback: save directly
        echo "$checkpoint_data" > "$FORK_DATA_DIR/$fork_id/checkpoint.json"
    }

    print_success "Checkpoint created"
}

# Create fork metadata
create_fork_metadata() {
    local fork_id=$1
    local parent_id=$2
    local worktree_path=$3
    local branch_number=$4
    local total_branches=$5
    local target_branch=$6

    local metadata_file="$FORK_DATA_DIR/$fork_id/metadata.json"

    # Build metadata JSON with optional target_branch
    local target_branch_json=""
    if [ -n "$target_branch" ]; then
        target_branch_json=",\n  \"target_branch\": \"$target_branch\""
    fi

    cat > "$metadata_file" <<EOF
{
  "fork_id": "$fork_id",
  "parent_id": "$parent_id",
  "branch_number": $branch_number,
  "total_branches": $total_branches,
  "worktree_path": "$worktree_path",
  "status": "active",
  "created_at": "$(date -Iseconds)"${target_branch_json}
}
EOF

    print_success "Metadata created"
}

# Main fork creation logic
create_forks() {
    local num_forks=$1
    local target_branch=$2

    # Validation
    if [ -z "$num_forks" ]; then
        print_error "Number of forks required"
        usage
    fi

    if ! [[ "$num_forks" =~ ^[0-9]+$ ]] || [ "$num_forks" -lt 1 ] || [ "$num_forks" -gt 10 ]; then
        print_error "Number must be between 1 and 10"
        usage
    fi

    # Check git repo
    check_git_repo

    # Handle target branch if specified
    if [ -n "$target_branch" ]; then
        print_info "Target branch: $target_branch"

        # Check if target branch exists
        if git show-ref --verify --quiet "refs/heads/$target_branch"; then
            print_info "Target branch exists, checking it out..."
            git checkout "$target_branch"
        else
            print_info "Creating new target branch: $target_branch"
            git checkout -b "$target_branch"
        fi
    fi

    # Get current state
    local current_branch=$(get_current_branch)
    local current_commit=$(get_current_commit)

    print_info "Current branch: $current_branch"
    print_info "Current commit: ${current_commit:0:8}"
    print_info "Creating $num_forks fork branch(es)...\n"

    # Generate parent fork ID (for the fork group)
    local parent_fork_id=$(generate_fork_id)

    # Create each fork
    local fork_ids=()
    local worktree_paths=()

    for ((i=1; i<=num_forks; i++)); do
        echo -e "${CYAN}=======================================${NC}"
        print_info "Creating fork $i of $num_forks"
        echo -e "${CYAN}=======================================${NC}"

        # Generate fork ID
        local fork_id="${parent_fork_id}-$i"
        fork_ids+=("$fork_id")

        # Create worktree
        local worktree_path=$(create_worktree "$fork_id" "$current_commit")
        worktree_paths+=("$worktree_path")

        # Create checkpoint
        create_checkpoint "$fork_id" "$parent_fork_id" "$current_branch" "$current_commit"

        # Create metadata
        create_fork_metadata "$fork_id" "$parent_fork_id" "$worktree_path" "$i" "$num_forks" "$target_branch"

        # Launch terminal for this fork
        launch_fork "$fork_id" "$worktree_path"

        echo ""
    done

    # Summary
    echo -e "\n${GREEN}=========================================${NC}"
    print_success "Created $num_forks fork branch(es)!"
    echo -e "${GREEN}=========================================${NC}\n"

    # Show fork details
    print_info "Fork branches created:"
    for ((i=0; i<num_forks; i++)); do
        echo -e "  ${CYAN}$((i+1)).${NC} ${fork_ids[$i]}"
        echo -e "      Path: ${worktree_paths[$i]}"
    done

    # Show target branch info if applicable
    if [ -n "$target_branch" ]; then
        echo ""
        print_info "Target Branch: $target_branch"
        print_info "All forks created from and will merge to: $target_branch"
    fi

    # Show how to access
    echo ""
    print_info "To work with your forks:"

    local mode=$(get_terminal_mode)
    if [ "$mode" = "tmux" ]; then
        print_info "  - Attach to tmux session: tmux attach -t fork-${parent_fork_id}-1"
        print_info "  - List all fork sessions: tmux list-sessions | grep fork"
        print_info "  - Switch between forks: Ctrl-b + s (tmux session menu)"
    else
        print_info "  - Run launcher scripts in $FORK_DATA_DIR/<fork-id>/launch.sh"
        print_info "  - Or cd to worktree paths shown above"
    fi

    print_info "  - List forks: /fork list"
    print_info "  - View tree: /fork tree"
    print_info "  - Switch: /fork switch <fork-id>"

    # Save fork group info
    local group_file="$FORK_DATA_DIR/.fork-groups.json"
    local group_entry="{\"id\":\"$parent_fork_id\",\"forks\":$(printf '%s\n' "${fork_ids[@]}" | jq -R . | jq -s .),\"created_at\":\"$(date -Iseconds)\"}"

    if [ -f "$group_file" ]; then
        # Append to existing groups
        jq ". += [$group_entry]" "$group_file" > "${group_file}.tmp" && mv "${group_file}.tmp" "$group_file"
    else
        # Create new groups file
        echo "[$group_entry]" > "$group_file"
    fi

    echo ""
    print_success "Happy forking! 🍴"
}

# Main entry point
main() {
    if [ $# -eq 0 ]; then
        usage
    fi

    local num_forks=""
    local target_branch=""

    # Parse arguments
    while [ $# -gt 0 ]; do
        case $1 in
            --target)
                target_branch="$2"
                shift 2
                ;;
            -*)
                print_error "Unknown option: $1"
                usage
                ;;
            *)
                if [ -z "$num_forks" ]; then
                    num_forks="$1"
                else
                    print_error "Unexpected argument: $1"
                    usage
                fi
                shift
                ;;
        esac
    done

    # Validate num_forks is set
    if [ -z "$num_forks" ]; then
        print_error "Number of forks required"
        usage
    fi

    create_forks "$num_forks" "$target_branch"
}

# Run
main "$@"
