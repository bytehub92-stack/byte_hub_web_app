#!/bin/bash

# run_tests.sh - Smart test runner that skips web tests

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🧪 Flutter Test Runner${NC}"
echo -e "${BLUE}========================${NC}\n"

# Parse arguments
TEST_TYPE="${1:-unit}"
COVERAGE="${2:-false}"

# Function to run tests
run_tests() {
    local test_path=$1
    local description=$2
    local extra_args=$3
    
    echo -e "${YELLOW}▶ Running $description...${NC}"
    
    if [ "$COVERAGE" = "coverage" ]; then
        flutter test "$test_path" $extra_args --coverage --coverage-path=coverage/lcov.info
    else
        flutter test "$test_path" $extra_args --reporter expanded
    fi
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✓ $description passed!${NC}\n"
        return 0
    else
        echo -e "${RED}✗ $description failed!${NC}\n"
        return 1
    fi
}

# Clean before running
echo -e "${YELLOW}🧹 Cleaning build artifacts...${NC}"
flutter clean > /dev/null 2>&1
rm -rf coverage/

echo -e "${YELLOW}📦 Getting dependencies...${NC}"
flutter pub get > /dev/null 2>&1

echo ""

case $TEST_TYPE in
    unit)
        echo -e "${BLUE}Running UNIT tests (excluding web, integration, slow)${NC}\n"
        run_tests "test/" "Unit Tests" "--exclude-tags=web,integration,slow"
        ;;
    
    bloc)
        echo -e "${BLUE}Running BLOC tests only${NC}\n"
        run_tests "test/" "BLoC Tests" "--exclude-tags=web"
        ;;
    
    widget)
        echo -e "${BLUE}Running WIDGET tests only${NC}\n"
        run_tests "test/" "Widget Tests" "--exclude-tags=web"
        ;;
    
    page)
        echo -e "${BLUE}Running PAGE tests only${NC}\n"
        run_tests "test/" "Page Tests" "--exclude-tags=web"
        ;;
    
    all)
        echo -e "${BLUE}Running ALL tests (excluding web only)${NC}\n"
        run_tests "test/" "All Tests" "--exclude-tags=web"
        ;;
    
    integration)
        echo -e "${BLUE}Running INTEGRATION tests only${NC}\n"
        run_tests "integration_test/" "Integration Tests" ""
        ;;
    
    mobile)
        echo -e "${BLUE}Running MOBILE DEVICE tests${NC}\n"
        echo -e "${YELLOW}⚠️  Make sure a device is connected!${NC}\n"
        flutter devices
        echo ""
        read -p "Enter device ID: " device_id
        flutter test integration_test/ -d "$device_id"
        ;;
    
    coverage)
        echo -e "${BLUE}Running tests with COVERAGE${NC}\n"
        run_tests "test/" "All Tests with Coverage" "--exclude-tags=web --coverage"
        
        if command -v lcov &> /dev/null; then
            echo -e "${YELLOW}📊 Generating coverage report...${NC}"
            genhtml coverage/lcov.info -o coverage/html
            echo -e "${GREEN}✓ Coverage report generated at coverage/html/index.html${NC}"
        else
            echo -e "${YELLOW}⚠️  Install lcov to generate HTML reports: sudo apt-get install lcov${NC}"
        fi
        ;;
    
    clean)
        echo -e "${BLUE}Deep cleaning project${NC}\n"
        flutter clean
        rm -rf .dart_tool
        rm -rf build
        rm -f pubspec.lock
        echo -e "${GREEN}✓ Project cleaned!${NC}"
        exit 0
        ;;
    
    help|--help|-h)
        echo -e "${BLUE}Flutter Test Runner - Usage${NC}"
        echo ""
        echo "Usage: ./run_tests.sh [type] [coverage]"
        echo ""
        echo "Test Types:"
        echo "  unit        - Unit tests only (default, fast)"
        echo "  bloc        - BLoC tests only"
        echo "  widget      - Widget tests only"
        echo "  page        - Page tests only"
        echo "  all         - All tests except web"
        echo "  integration - Integration tests (slow)"
        echo "  mobile      - Run on connected mobile device"
        echo "  coverage    - Generate coverage report"
        echo "  clean       - Deep clean project"
        echo "  help        - Show this help message"
        echo ""
        echo "Examples:"
        echo "  ./run_tests.sh unit"
        echo "  ./run_tests.sh bloc"
        echo "  ./run_tests.sh all coverage"
        echo "  ./run_tests.sh integration"
        echo ""
        exit 0
        ;;
    
    *)
        echo -e "${RED}Unknown test type: $TEST_TYPE${NC}"
        echo ""
        echo "Run './run_tests.sh help' for usage information"
        exit 1
        ;;
esac

# Summary
if [ $? -eq 0 ]; then
    echo -e "${GREEN}╔════════════════════════════════╗${NC}"
    echo -e "${GREEN}║   ✓ All Tests Passed! 🎉      ║${NC}"
    echo -e "${GREEN}╚════════════════════════════════╝${NC}"
    exit 0
else
    echo -e "${RED}╔════════════════════════════════╗${NC}"
    echo -e "${RED}║   ✗ Some Tests Failed! ❌      ║${NC}"
    echo -e "${RED}╚════════════════════════════════╝${NC}"
    exit 1
fi