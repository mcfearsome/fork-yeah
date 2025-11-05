#!/bin/bash

# test_fork.sh
# Basic functionality tests for fork-yeah

set -e

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

# Test counter
TESTS_RUN=0
TESTS_PASSED=0
TESTS_FAILED=0

# Print functions
print_test() { echo -e "${BLUE}[TEST]${NC} \"$@\""; }
print_pass() { echo -e "${GREEN}[PASS]${NC} \"$@\""; ((TESTS_PASSED++)); }
print_fail() { echo -e "${RED}[FAIL]${NC} \"$@\""; ((TESTS_FAILED++)); }

# Run a test
run_test() {
    local test_name=$1
    shift
    local test_command="$@"

    ((TESTS_RUN++))
    print_test "$test_name"

    if eval "$test_command"; then
        print_pass "$test_name"
        return 0
    else
        print_fail "$test_name"
        return 1
    fi
}

# Test: Dependencies installed
test_dependencies() {
    command -v git > /dev/null 2>&1 && \
    command -v python3 > /dev/null 2>&1 && \
    command -v jq > /dev/null 2>&1
}

# Test: Scripts exist and are executable
test_scripts_exist() {
    [ -x "$PROJECT_ROOT/setup.sh" ] && \
    [ -x "$PROJECT_ROOT/src/fork_create.sh" ] && \
    [ -x "$PROJECT_ROOT/src/fork_list.sh" ] && \
    [ -x "$PROJECT_ROOT/src/fork_switch.sh" ] && \
    [ -x "$PROJECT_ROOT/src/fork_tree.sh" ] && \
    [ -x "$PROJECT_ROOT/src/state_manager.py" ]
}

# Test: Config files exist
test_config_files() {
    [ -f "$PROJECT_ROOT/config/config.yaml" ] && \
    [ -f "$PROJECT_ROOT/config/tmux.conf" ] && \
    [ -f "$PROJECT_ROOT/skill.yaml" ]
}

# Test: State manager list command
test_state_manager_list() {
    python3 "$PROJECT_ROOT/src/state_manager.py" list > /dev/null 2>&1
}

# Test: State manager create/delete
test_state_manager_create_delete() {
    local test_fork_id="test-fork-$$"

    # Create
    python3 "$PROJECT_ROOT/src/state_manager.py" create "$test_fork_id" > /dev/null 2>&1 && \

    # Verify it exists
    python3 "$PROJECT_ROOT/src/state_manager.py" list | grep -q "$test_fork_id" && \

    # Delete
    python3 "$PROJECT_ROOT/src/state_manager.py" delete "$test_fork_id" > /dev/null 2>&1
}

# Test: Terminal manager functions load
test_terminal_manager() {
    source "$PROJECT_ROOT/src/terminal_manager.sh" && \
    type get_terminal_mode > /dev/null 2>&1 && \
    type is_tmux_available > /dev/null 2>&1
}

# Test: SKILL.md exists and has valid frontmatter
test_skill_md_valid() {
    [ -f "$PROJECT_ROOT/SKILL.md" ] && \
    grep -q "^---$" "$PROJECT_ROOT/SKILL.md" && \
    grep -q "^name:" "$PROJECT_ROOT/SKILL.md" && \
    grep -q "^description:" "$PROJECT_ROOT/SKILL.md"
}

# Test: config.yaml is valid YAML
test_config_yaml_valid() {
    python3 -c "import yaml; yaml.safe_load(open('$PROJECT_ROOT/config/config.yaml'))" 2>/dev/null
}

# Test: Documentation exists
test_documentation() {
    [ -f "$PROJECT_ROOT/README.md" ] && \
    [ -f "$PROJECT_ROOT/docs/TROUBLESHOOTING.md" ] && \
    [ -s "$PROJECT_ROOT/README.md" ]
}

# Main test suite
main() {
    echo "======================================"
    echo "  fork-yeah Test Suite"
    echo "======================================"
    echo ""

    # Run tests
    run_test "Dependencies installed" test_dependencies
    run_test "Scripts exist and executable" test_scripts_exist
    run_test "Config files exist" test_config_files
    run_test "State manager list" test_state_manager_list
    run_test "State manager create/delete" test_state_manager_create_delete
    run_test "Terminal manager loads" test_terminal_manager
    run_test "SKILL.md is valid" test_skill_md_valid
    run_test "config.yaml is valid" test_config_yaml_valid
    run_test "Documentation exists" test_documentation

    # Summary
    echo ""
    echo "======================================"
    echo "  Test Summary"
    echo "======================================"
    echo "Tests run:    $TESTS_RUN"
    echo -e "${GREEN}Tests passed: $TESTS_PASSED${NC}"
    if [ $TESTS_FAILED -gt 0 ]; then
        echo -e "${RED}Tests failed: $TESTS_FAILED${NC}"
        exit 1
    else
        echo -e "${GREEN}All tests passed!${NC}"
        exit 0
    fi
}

# Run tests
main "$@"
