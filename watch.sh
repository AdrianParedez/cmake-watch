#!/bin/bash

# USAGE: ./watch.sh [executable_name] [options]
# - executable_name: The target name from add_executable() in CMakeLists.txt (default: hello)
# - options: --no-initial, -v, --verbose
# EXAMPLE: ./watch.sh my_app -v

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# CHANGE: Modify BUILD_DIR if your cmake build directory is named differently
BUILD_DIR="build"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DEBOUNCE_TIME=0.3

SKIP_INITIAL=false
VERBOSE=false

# CHANGE: First argument is the executable name from add_executable() in CMakeLists.txt
EXECUTABLE_NAME="${1:-hello}"
shift 2>/dev/null || true

while [[ $# -gt 0 ]]; do
    case $1 in
        --no-initial) SKIP_INITIAL=true; shift ;;
        -v|--verbose) VERBOSE=true; shift ;;
        *) echo "Unknown option: $1"; exit 1 ;;
    esac
done

EXECUTABLE="${SCRIPT_DIR}/${BUILD_DIR}/${EXECUTABLE_NAME}"

log_info() {
    echo -e "${BLUE}ℹ${NC} $1"
}

log_success() {
    echo -e "${GREEN}✓${NC} $1"
}

log_error() {
    echo -e "${RED}✗${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

if ! command -v inotifywait &> /dev/null; then
    log_error "inotifywait not found. Install with: sudo apt-get install inotify-tools"
    exit 1
fi

if ! command -v cmake &> /dev/null; then
    log_error "cmake not found. Please install cmake."
    exit 1
fi

mkdir -p "$BUILD_DIR"

log_warning "Starting CMake watch mode..."
log_info "Watching for changes in: *.cpp, *.h, *.hpp, CMakeLists.txt"
log_info "Build directory: $BUILD_DIR"
log_info "Press Ctrl+C to stop"
echo ""

perform_build() {
    local build_start=$(date +%s%N)

    cd "$BUILD_DIR" || exit 1

    if [ "$VERBOSE" = true ]; then
        cmake .. && make
    else
        cmake .. > /dev/null 2>&1 && make > /dev/null 2>&1
    fi

    local build_result=$?
    local build_end=$(date +%s%N)
    local build_time=$(( (build_end - build_start) / 1000000 ))

    if [ $build_result -eq 0 ]; then
        log_success "Build completed in ${build_time}ms"

        if [ -f "$EXECUTABLE" ]; then
            echo "----------------------------------------"
            log_info "Running executable..."
            echo "----------------------------------------"
            "$EXECUTABLE"
            echo "----------------------------------------"
        else
            log_warning "Executable not found at $EXECUTABLE"
        fi
    else
        log_error "Build failed (took ${build_time}ms)"
        if [ "$VERBOSE" = false ]; then
            log_info "Run with -v or --verbose for detailed output"
        fi
    fi

    cd - > /dev/null || exit 1
}

if [ "$SKIP_INITIAL" = false ]; then
    log_warning "Running initial build..."
    echo ""
    perform_build
    echo ""
else
    log_info "Skipping initial build (--no-initial flag set)"
    echo ""
fi

log_warning "Watching for changes... (Press Ctrl+C to stop)"

while true; do
    inotifywait -e modify,create,delete,move \
        --include '\.(cpp|h|hpp|c|cc|cxx)$|CMakeLists\.txt$' \
        -r . 2>/dev/null

    if [ $? -eq 0 ]; then
        sleep "$DEBOUNCE_TIME"

        clear

        echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        log_warning "File change detected - Rebuilding..."
        echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        echo ""

        perform_build

        echo ""
        echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        log_warning "Watching for changes... (Press Ctrl+C to stop)"
        echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    fi
done
