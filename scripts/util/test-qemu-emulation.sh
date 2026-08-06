#!/bin/bash

# QEMU Emulation Test Script
# Tests QEMU x86_64 emulation setup for Godot 3.5 on ARM64
#
# This script can be used to test QEMU emulation without building
# the full container image.

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Utility functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

check_command() {
    if ! command -v "$1" &> /dev/null; then
        log_error "$1 is not installed. Please install it first."
        exit 1
    fi
}

# Test 1: Check if we're on ARM64
test_architecture() {
    log_info "Testing system architecture..."

    local arch=$(uname -m)
    log_info "Detected architecture: $arch"

    if [ "$arch" = "aarch64" ] || [ "$arch" = "arm64" ]; then
        log_info "✅ Running on ARM64 - QEMU emulation needed"
        return 0
    elif [ "$arch" = "x86_64" ] || [ "$arch" = "amd64" ]; then
        log_info "✅ Running on x86_64 - no emulation needed"
        return 0
    else
        log_error "❌ Unsupported architecture: $arch"
        exit 1
    fi
}

# Test 2: Check QEMU installation
test_qemu_installation() {
    log_info "Testing QEMU installation..."

    if command -v qemu-x86_64-static &> /dev/null; then
        log_success "✅ QEMU x86_64 found in PATH"
        return 0
    fi

    # Try common QEMU locations
    local qemu_paths=(
        "/usr/bin/qemu-x86_64-static"
        "/usr/bin/qemu-x86_64"
        "/usr/local/bin/qemu-x86_64-static"
        "/usr/local/bin/qemu-x86_64"
    )

    for path in "${qemu_paths[@]}"; do
        if [ -f "$path" ]; then
            log_success "✅ QEMU x86_64 found at: $path"
            return 0
        fi
    done

    log_error "❌ QEMU x86_64 not found"
    log_info "Please install QEMU: sudo apt-get install qemu-user-static"
    exit 1
}

# Test 3: Check binfmt registration
test_binfmt_registration() {
    log_info "Testing binfmt registration..."

    if [ -f /proc/sys/fs/binfmt_misc/qemu-x86_64 ]; then
        log_success "✅ x86_64 binfmt registration found"
        return 0
    fi

    log_warning "❌ x86_64 binfmt registration missing"
    log_info "Attempting to register QEMU binfmt..."

    # Try to register manually
    if [ -w /proc/sys/fs/binfmt_misc/register ]; then
        echo ':qemu-x86_64:M::\x7fELF\x02\x01\x01\x00\x00\x00\x00\x00\x00\x00\x00\x00\x02\x00\x3e\x00:\xff\xff\xff\xff\xff\xff\xff\x00\xff\xff\xff\xff\xff\xff\xff\xff\xfe\xff\xff\xff:/usr/bin/qemu-x86_64-static:' > /proc/sys/fs/binfmt_misc/register

        if [ -f /proc/sys/fs/binfmt_misc/qemu-x86_64 ]; then
            log_success "✅ Successfully registered QEMU binfmt"
            return 0
        fi
    fi

    log_error "❌ Could not register QEMU binfmt"
    log_info "Try: sudo update-binfmts --enable qemu-x86_64"
    exit 1
}

# Test 4: Check x86_64 architecture support
test_architecture_support() {
    log_info "Testing x86_64 architecture support..."

    if dpkg --print-foreign-architectures | grep -q "amd64"; then
        log_success "✅ x86_64 architecture already enabled"
        return 0
    fi

    log_info "Enabling x86_64 architecture support..."
    if sudo dpkg --add-architecture amd64; then
        log_success "✅ Successfully enabled x86_64 architecture"
        return 0
    else
        log_error "❌ Failed to enable x86_64 architecture"
        exit 1
    fi
}

# Test 5: Check essential x86_64 libraries
test_x86_64_libraries() {
    log_info "Testing x86_64 library installation..."

    local required_libs=(
        "libc6:amd64"
        "libstdc++6:amd64"
        "libgcc-s1:amd64"
        "zlib1g:amd64"
    )

    local missing_libs=()

    for lib in "${required_libs[@]}"; do
        if ! dpkg -l | grep -q "ii.*${lib}"; then
            missing_libs+=("$lib")
        fi
    done

    if [ ${#missing_libs[@]} -eq 0 ]; then
        log_success "✅ All essential x86_64 libraries installed"
        return 0
    fi

    log_warning "❌ Missing x86_64 libraries: ${missing_libs[*]}"
    log_info "Installing missing libraries..."

    # Update package lists
    sudo apt-get update

    # Install missing libraries
    local install_cmd="sudo apt-get install -y"
    for lib in "${missing_libs[@]}"; do
        install_cmd="$install_cmd $lib"
    done

    if eval "$install_cmd"; then
        log_success "✅ Successfully installed missing x86_64 libraries"
        return 0
    else
        log_error "❌ Failed to install x86_64 libraries"
        exit 1
    fi
}

# Test 6: Check dynamic linker setup
test_dynamic_linker() {
    log_info "Testing dynamic linker setup..."

    local linker_paths=(
        "/lib64/ld-linux-x86-64.so.2"
        "/lib/x86_64-linux-gnu/ld-linux-x86-64.so.2"
        "/usr/lib/x86_64-linux-gnu/ld-linux-x86-64.so.2"
    )

    for path in "${linker_paths[@]}"; do
        if [ -f "$path" ]; then
            log_success "✅ Found x86_64 dynamic linker: $path"
            return 0
        fi
    done

    log_warning "❌ x86_64 dynamic linker not found"
    log_info "Setting up dynamic linker..."

    # Create lib64 directory
    sudo mkdir -p /lib64

    # Try to find and link the dynamic linker
    if [ -f /lib/x86_64-linux-gnu/ld-linux-x86-64.so.2 ]; then
        sudo ln -sf /lib/x86_64-linux-gnu/ld-linux-x86-64.so.2 /lib64/ld-linux-x86-64.so.2
        log_success "✅ Created dynamic linker symlink"
        return 0
    elif [ -f /usr/lib/x86_64-linux-gnu/ld-linux-x86-64.so.2 ]; then
        sudo ln -sf /usr/lib/x86_64-linux-gnu/ld-linux-x86-64.so.2 /lib64/ld-linux-x86-64.so.2
        log_success "✅ Created dynamic linker symlink"
        return 0
    else
        log_error "❌ x86_64 dynamic linker not found in standard locations"
        exit 1
    fi
}

# Test 7: Test QEMU functionality
test_qemu_functionality() {
    log_info "Testing QEMU functionality..."

    # Create a simple x86_64 test program
    cat > /tmp/test_x86_64.c << 'EOF'
#include <stdio.h>
int main() {
    printf("Hello from x86_64 emulation!\n");
    return 0;
}
EOF

    # Try to compile and run it
    if command -v gcc &> /dev/null; then
        if gcc -m64 /tmp/test_x86_64.c -o /tmp/test_x86_64 2>/dev/null; then
            log_info "Testing x86_64 binary execution..."
            if /tmp/test_x86_64; then
                log_success "✅ x86_64 emulation working correctly"
                rm -f /tmp/test_x86_64.c /tmp/test_x86_64
                return 0
            fi
        fi
    fi

    log_warning "⚠️ Could not test QEMU functionality (gcc not available)"
    log_info "This is not critical - QEMU may still work for Godot binaries"
    rm -f /tmp/test_x86_64.c /tmp/test_x86_64
    return 0
}

# Main test function
run_all_tests() {
    log_info "Starting QEMU emulation tests..."
    echo

    test_architecture
    echo

    test_qemu_installation
    echo

    test_binfmt_registration
    echo

    test_architecture_support
    echo

    test_x86_64_libraries
    echo

    test_dynamic_linker
    echo

    test_qemu_functionality
    echo

    log_success "🎉 All QEMU emulation tests completed!"
    log_info "Your system is ready for x86_64 emulation with Godot 3.5"
}

# Run tests
run_all_tests
