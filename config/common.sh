#!/bin/bash

# common.sh
# Common utilities and functions for fork-yeah scripts

# Colors
export RED='\033[0;31m'
export GREEN='\033[0;32m'
export YELLOW='\033[1;33m'
export BLUE='\033[0;34m'
export CYAN='\033[0;36m'
export MAGENTA='\033[0;35m'
export NC='\033[0m'

# Print functions
print_error() { echo -e "${RED}✗ $@${NC}" >&2; }
print_success() { echo -e "${GREEN}✓ $@${NC}"; }
print_warning() { echo -e "${YELLOW}⚠ $@${NC}"; }
print_info() { echo -e "${BLUE}ℹ $@${NC}"; }
print_step() { echo -e "${CYAN}→ $@${NC}"; }

# Export for use in other scripts
export -f print_error
export -f print_success
export -f print_warning
export -f print_info
export -f print_step
