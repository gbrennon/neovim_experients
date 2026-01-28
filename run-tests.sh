#!/bin/bash

# Neovim Configuration Test Runner

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Default values
COVERAGE=false
LINT=false
VERBOSE=false

# Parse command line arguments
while [[ $# -gt 0 ]]; do
  case $1 in
    -c|--coverage)
      COVERAGE=true
      shift
      ;;
    -l|--lint)
      LINT=true
      shift
      ;;
    -v|--verbose)
      VERBOSE=true
      shift
      ;;
    -h|--help)
      echo "Usage: $0 [OPTIONS]"
      echo "Options:"
      echo "  -c, --coverage    Run tests with coverage report"
      echo "  -l, --lint        Run linter (luacheck)"
      echo "  -v, --verbose     Verbose output"
      echo "  -h, --help        Show this help message"
      exit 0
      ;;
    *)
      echo -e "${RED}Unknown option: $1${NC}"
      exit 1
      ;;
  esac
done

# Check if dependencies are installed
check_dependencies() {
  echo -e "${YELLOW}Checking dependencies...${NC}"
  
  local missing=false
  
  if ! command -v ~/.luarocks/bin/busted &> /dev/null; then
    echo -e "${RED}busted is not installed. Run: luarocks install busted --local${NC}"
    missing=true
  fi
  
  if [ "$COVERAGE" = true ] && ! command -v ~/.luarocks/bin/luacov &> /dev/null; then
    echo -e "${RED}luacov is not installed. Run: luarocks install luacov --local${NC}"
    missing=true
  fi
  
  if [ "$LINT" = true ] && ! command -v ~/.luarocks/bin/luacheck &> /dev/null; then
    echo -e "${RED}luacheck is not installed. Run: luarocks install luacheck --local${NC}"
    missing=true
  fi
  
  if [ "$missing" = true ]; then
    echo -e "${YELLOW}Install missing dependencies with: make install-deps${NC}"
    exit 1
  fi
  
  echo -e "${GREEN}Dependencies OK${NC}"
}

# Run linter
run_lint() {
  echo -e "${YELLOW}Running linter...${NC}"
  if luacheck ~/.luarocks/bin/luacheck lua/ spec/ --exclude-files "spec/helpers/vim_mock.lua"; then
    echo -e "${GREEN}Linting passed${NC}"
  else
    echo -e "${RED}Linting failed${NC}"
    exit 1
  fi
}

# Run tests
run_tests() {
  echo -e "${YELLOW}Running tests...${NC}"
  
  local busted_args=""
  if [ "$VERBOSE" = true ]; then
    busted_args="--verbose"
  fi
  
  if [ "$COVERAGE" = true ]; then
    busted_args="$busted_args --coverage"
  fi
  
  # Set LUA_PATH to include local modules
  export LUA_PATH="./lua/?.lua;./lua/?/init.lua;./spec/?.lua;./spec/?/init.lua;$LUA_PATH"
  
  if ~/.luarocks/bin/busted $busted_args spec/; then
    echo -e "${GREEN}Tests passed${NC}"
    
    if [ "$COVERAGE" = true ]; then
      echo -e "${YELLOW}Generating coverage report...${NC}"
      ~/.luarocks/bin/luacov
      echo -e "${GREEN}Coverage report generated: luacov.report.out${NC}"
    fi
  else
    echo -e "${RED}Tests failed${NC}"
    exit 1
  fi
}

# Main execution
main() {
  echo -e "${GREEN}Neovim Configuration Test Runner${NC}"
  echo "==============================="
  
  check_dependencies
  
  if [ "$LINT" = true ]; then
    run_lint
    echo ""
  fi
  
  run_tests
  
  echo ""
  echo -e "${GREEN}All checks completed successfully!${NC}"
}

main "$@"