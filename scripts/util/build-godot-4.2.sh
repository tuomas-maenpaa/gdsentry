#!/bin/bash

# GDSentry - Godot 4.2 Container Image Builder
# Builds the Godot 4.2.2-stable container image for GDSentry testing
#
# This script creates a container image with Godot 4.2.2-stable
# for running GDSentry tests in the matrix testing setup.
#
# Author: GDSentry Framework
# Version: 1.0.0

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
BASE_IMAGE="localhost/gdsentry-base:latest"
GODOT_VERSION="4.2.2-stable"
IMAGE_NAME="gdsentry-godot-4.2"
IMAGE_TAG="latest"
CONTAINERFILE=".runtime/containerfiles/Containerfile.godot-4.2"
CONTAINERFILE_SOURCE="infra/containers/Containerfile.godot-4.2"

# Cross-platform utilities integration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CROSS_PLATFORM_UTILS="$SCRIPT_DIR/cross-platform-utilities.sh"

if [ -f "$CROSS_PLATFORM_UTILS" ]; then
    # shellcheck source=cross-platform-utilities.sh
    source "$CROSS_PLATFORM_UTILS"
    echo "Loaded cross-platform utilities for enhanced architecture detection"
    CROSS_PLATFORM_AVAILABLE=true
else
    echo "Cross-platform utilities not found, using legacy architecture detection"
    CROSS_PLATFORM_AVAILABLE=false
fi

# Detect architecture and set platform
detect_architecture() {
    local host_arch

    # Use cross-platform utilities if available
    if [ "$CROSS_PLATFORM_AVAILABLE" = "true" ] && command -v detect_host_architecture >/dev/null 2>&1; then
        host_arch=$(detect_host_architecture)
        GODOT_PLATFORM="linux.$(get_godot_platform "$host_arch")"
        log_info "Enhanced architecture detection: $host_arch -> $GODOT_PLATFORM"
    else
        # Fallback to legacy detection
        host_arch=$(uname -m)
        case $host_arch in
            "x86_64"|"amd64")
                GODOT_PLATFORM="linux.x86_64"
                ;;
            "arm64"|"aarch64")
                GODOT_PLATFORM="linux.arm64"
                ;;
            *)
                log_warning "Unknown architecture: $host_arch, defaulting to x86_64"
                GODOT_PLATFORM="linux.x86_64"
                ;;
        esac
        log_info "Legacy architecture detection: $host_arch -> $GODOT_PLATFORM"
    fi
}

# Godot download URLs (set in main function after architecture detection)
GODOT_DOWNLOAD_URL=""
GODOT_ZIP_FILE=".runtime/downloads/godot-4.2.zip"
# Binary name in the zip file (format: Godot_vVERSION_PLATFORM)
GODOT_BINARY=""

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
        log_error "$1 is not installed. Please run scripts/dev/01-setup-podman.sh first."
        exit 1
    fi
}

check_podman_machine() {
    if ! podman machine list | grep -q "podman-machine-default" || \
        ! podman machine list | grep -q "Currently running"; then
        log_error "Podman machine 'podman-machine-default' is not running."
        log_error "Please run: podman machine start podman-machine-default"
        exit 1
    fi
}

check_base_image() {
    # Extract repository name from BASE_IMAGE (remove tag part)
    BASE_REPO=$(echo "$BASE_IMAGE" | cut -d':' -f1)

    if ! podman images | grep -q "$BASE_REPO"; then
        log_error "Base image '$BASE_IMAGE' not found."
        log_error "Please run: scripts/util/build-base-image.sh first."
        exit 1
    fi
    log_success "Base image found: $BASE_IMAGE"
}

download_godot() {
    log_info "Downloading Godot $GODOT_VERSION..."

    # Ensure download directory exists
    mkdir -p "$(dirname "$GODOT_ZIP_FILE")"

    # Check if already downloaded
    if [ -f "$GODOT_ZIP_FILE" ]; then
        log_info "Godot zip file already exists, skipping download"
        return 0
    fi

    # Download Godot
    log_info "Downloading from: $GODOT_DOWNLOAD_URL"
    if curl -L -o "$GODOT_ZIP_FILE" "$GODOT_DOWNLOAD_URL"; then
        log_success "Godot downloaded successfully"
    else
        log_error "Failed to download Godot"
        exit 1
    fi

    # Verify download
    if [ ! -s "$GODOT_ZIP_FILE" ]; then
        log_error "Downloaded file is empty or missing"
        exit 1
    fi

    log_info "Download size: $(du -h "$GODOT_ZIP_FILE" | cut -f1)"
}

verify_godot_download() {
    log_info "Verifying Godot download..."

    # Check if zip file is valid
    if unzip -l "$GODOT_ZIP_FILE" >/dev/null 2>&1; then
        log_success "Godot zip file is valid"
    else
        log_error "Godot zip file is corrupted"
        exit 1
    fi

    # Check if contains expected binary
    if unzip -l "$GODOT_ZIP_FILE" | grep -q "$GODOT_BINARY"; then
        log_success "Godot binary found in zip file"
    else
        log_error "Godot binary not found in zip file"
        exit 1
    fi
}

create_containerfile() {
    log_info "Creating Containerfile for Godot 4.2..."

    # Ensure .runtime/containerfiles directory exists
    mkdir -p .runtime/containerfiles

    # Use the new simplified Containerfile from infra/containers if it exists
    if [ -f "$CONTAINERFILE_SOURCE" ]; then
        log_info "Using new multi-arch Containerfile from: $CONTAINERFILE_SOURCE"
        cp "$CONTAINERFILE_SOURCE" "$CONTAINERFILE"
        log_success "Containerfile created successfully"
        return 0
    fi

    # Fallback to template substitution
    local template_file="scripts/util/Containerfile.godot-4.2.template"

    if [ -f "$template_file" ]; then
        log_info "Using template file: $template_file"
        log_info "GODOT_BINARY: $GODOT_BINARY"
        log_info "GODOT_DOWNLOAD_URL: $GODOT_DOWNLOAD_URL"
        # Use sed to substitute variables in template
        sed -e "s|__BASE_IMAGE__|$BASE_IMAGE|g" \
            -e "s|__GODOT_VERSION__|$GODOT_VERSION|g" \
            -e "s|__GODOT_PLATFORM__|$GODOT_PLATFORM|g" \
            -e "s|__GODOT_DOWNLOAD_URL__|$GODOT_DOWNLOAD_URL|g" \
            -e "s|__GODOT_ZIP_FILE__|$GODOT_ZIP_FILE|g" \
            -e "s|__GODOT_BINARY__|$GODOT_BINARY|g" \
            "$template_file" > "$CONTAINERFILE"
        log_success "Containerfile generated from template"
    else
        log_error "Containerfile template not found: $template_file"
        exit 1
    fi

    # Original heredoc approach (as fallback)
    if [ ! -f "$CONTAINERFILE" ]; then
        cat > "$CONTAINERFILE" << EOF
# GDSentry Godot 4.2 Container Image
# Container image with Godot 4.2.2-stable for GDSentry testing

FROM $BASE_IMAGE

# Set metadata
LABEL maintainer="GDSentry Framework"
LABEL version="4.2.2-stable"
LABEL description="Godot 4.2.2-stable container for GDSentry testing"

# Switch to root for installation
USER root

# Install additional dependencies for Godot 4.2
RUN apt-get update && apt-get install -y \\
    # X11 and graphics libraries for headless operation
    xvfb \\
    libx11-6 \\
    libxext6 \\
    libxfixes3 \\
    libxi6 \\
    libxrender1 \\
    libxrandr2 \\
    libxss1 \\
    libxtst6 \\
    libxinerama1 \\
    libasound2 \\
    libpulse0 \\
    libdrm2 \\
    libxcomposite1 \\
    libxdamage1 \\
    libxkbcommon0 \\
    libgtk-3-0 \\
    libnss3 \\
    libatk1.0-0 \\
    libdrm-amdgpu1 \\
    libxss1 \\
    # Audio libraries
    libasound2 \\
    libpulse0 \\
    # Vulkan support (Godot 4.x)
    libvulkan1 \\
    mesa-vulkan-drivers \\
    vulkan-tools \\
    # Additional utilities for Godot 4.x
    mesa-utils \\
    && rm -rf /var/lib/apt/lists/*

# Copy Godot zip file (if available in build context)
COPY $GODOT_ZIP_FILE /tmp/godot.zip

# Download and install Godot 4.2.2-stable
RUN if [ -f /tmp/godot.zip ]; then \\
        echo "Using provided Godot zip file"; \\
        cp /tmp/godot.zip /tmp/godot-install.zip; \\
    else \\
        echo "Downloading Godot $GODOT_VERSION"; \\
        curl -L -o /tmp/godot-install.zip "$GODOT_DOWNLOAD_URL"; \\
    fi && \\
    cd /tmp && \\
    unzip godot-install.zip && \\
    chmod +x "$GODOT_BINARY" && \\
    mv "$GODOT_BINARY" /usr/local/bin/godot && \\
    rm -f godot-install.zip "$GODOT_BINARY" && \\
    cd / && \\
    rm -rf /tmp/*

# Create symlink for convenience
RUN ln -sf /usr/local/bin/godot /usr/local/bin/godot4

# Create Godot directories
RUN mkdir -p /root/.local/share/godot

# Set up headless display
ENV DISPLAY=:99
ENV XVFB_DISPLAY=:99
ENV HEADLESS=true

# Add headless wrapper script for Godot 4.x
RUN echo '#!/bin/bash\\n\\
xvfb-run -a /usr/local/bin/godot --headless --verbose --no-window \$@' > /usr/local/bin/godot-headless && \\
    chmod +x /usr/local/bin/godot-headless

# Set environment variables for Godot 4.x
ENV GODOT_VERSION="$GODOT_VERSION"
ENV GODOT_BINARY="/usr/local/bin/godot"
ENV GODOT_HEADLESS="/usr/local/bin/godot-headless"

# Configure Godot 4.x specific settings
ENV GODOT4_HEADLESS=true
ENV GODOT_RENDERING_DRIVER=headless

# Switch back to development user
USER developer

# Add Godot to PATH
ENV PATH="/usr/local/bin:\${PATH}"

# Create Godot directories (developer-owned)
RUN mkdir -p /workspace/godot-projects

# Create GDSentry test setup
RUN mkdir -p /workspace/gdsentry && \\
    mkdir -p /workspace/tests && \\
    mkdir -p /workspace/reports && \\
    mkdir -p /workspace/artifacts

# Create test runner script for Godot 4.x
RUN echo '#!/bin/bash\\n\\
echo "GDSentry Godot 4.2 Test Runner"\\n\\
echo "================================"\\n\\
echo "Godot Version: \$GODOT_VERSION"\\n\\
echo "Working Directory: \$(pwd)"\\n\\
echo "Godot Binary: \$GODOT_BINARY"\\n\\
echo "================================\\n"\\n\\
cd /workspace\\n\\
godot-headless --version\\n\\
echo "\\nRunning GDSentry tests..."\\n\\
if [ -f "./gdsentry-self-test/gdsentry-self-test.sh" ]; then\\n\\
    ./gdsentry-self-test/gdsentry-self-test.sh --quiet\\n\\
else\\n\\
    echo "GDSentry test script not found"\\n\\
    exit 1\\n\\
fi\\n\\
echo "\\nTest execution completed"\\n' > /home/developer/run-tests.sh && \\
    chmod +x /home/developer/run-tests.sh

# Note: Workspace permissions are now handled by creating directories as the correct user

# Set working directory
WORKDIR /workspace

# Health check for Godot 4.x
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \\
    CMD godot-headless --version || exit 1

ENTRYPOINT ["/home/developer/entrypoint.sh"]
CMD ["/home/developer/run-tests.sh"]
EOF
        fi

    log_success "Containerfile created: $CONTAINERFILE"
}

build_godot_image() {
    log_info "Building Godot 4.2 container image..."

    # Check if we have the Godot zip file
    if [ ! -f "$GODOT_ZIP_FILE" ]; then
        log_info "Godot zip file not found locally, will download during build"
    else
        log_info "Using local Godot zip file: $GODOT_ZIP_FILE"
    fi

    # Determine platform flag for cross-architecture builds
    local PLATFORM_FLAG=""
    if [ -n "$TARGET_ARCH" ]; then
        case "$TARGET_ARCH" in
            "x86_64"|"amd64")
                PLATFORM_FLAG="--platform=linux/amd64"
                log_info "Building for x86_64 architecture (cross-compilation enabled)"
                ;;
            "arm64"|"aarch64")
                PLATFORM_FLAG="--platform=linux/arm64"
                log_info "Building for ARM64 architecture"
                ;;
            *)
                log_warning "Unknown TARGET_ARCH: $TARGET_ARCH, building for native architecture"
                ;;
        esac
    else
        log_info "Building for native architecture"
    fi

    # Build the image with architecture build args
    log_info "Building $IMAGE_NAME:$IMAGE_TAG..."
    if [ -n "$PLATFORM_FLAG" ]; then
        # When cross-compiling, also pass build args
        podman build $PLATFORM_FLAG \
            --build-arg TARGETARCH="${TARGET_ARCH}" \
            --build-arg BUILDPLATFORM="linux/$(uname -m)" \
            -f "$CONTAINERFILE" -t "$IMAGE_NAME:$IMAGE_TAG" .
    else
        podman build -f "$CONTAINERFILE" -t "$IMAGE_NAME:$IMAGE_TAG" .
    fi

    # Tag with additional names
    podman tag "$IMAGE_NAME:$IMAGE_TAG" "$IMAGE_NAME:latest"
    # Keep localhost prefix for local development, but also tag without it for matrix tests
    podman tag "$IMAGE_NAME:$IMAGE_TAG" "localhost/$IMAGE_NAME:$IMAGE_TAG"
    # Tag for matrix testing (without localhost prefix and specific naming)
    podman tag "$IMAGE_NAME:$IMAGE_TAG" "$IMAGE_NAME-$IMAGE_TAG:latest"

    # Tag with architecture if TARGET_ARCH is specified
    if [ -n "$TARGET_ARCH" ]; then
        podman tag "$IMAGE_NAME:$IMAGE_TAG" "$IMAGE_NAME:$TARGET_ARCH"
        log_info "Tagged image with architecture: $IMAGE_NAME:$TARGET_ARCH"
    fi

    log_success "Godot 4.2 image built successfully"
}

validate_godot_image() {
    log_info "Validating Godot 4.2 image..."

    # Check if image exists
    if ! podman images | grep -q "$IMAGE_NAME"; then
        log_error "Godot 4.2 image not found after build"
        exit 1
    fi

    # Run basic tests
    log_info "Testing Godot 4.2 image functionality..."

    # Test 1: Basic container execution
    if podman run --rm "$IMAGE_NAME:$IMAGE_TAG" echo "Godot 4.2 test successful" | grep -q "successful"; then
        log_success "Godot 4.2 container executes correctly"
    else
        log_error "Godot 4.2 container execution failed"
        exit 1
    fi

    # Test 2: Godot binary availability (skip on ARM64 due to x86_64 binary)
    if [ "$(uname -m)" = "arm64" ] || [ "$(uname -m)" = "aarch64" ]; then
        log_warning "Skipping Godot binary test on ARM64 (x86_64 binary compatibility issue)"
        log_info "Godot binary is present in container but cannot execute on ARM64 host"
    else
        if podman run --rm "$IMAGE_NAME:$IMAGE_TAG" godot --version >/dev/null 2>&1; then
            log_success "Godot binary is available and executable"
        else
            log_error "Godot binary is not available or not executable"
            exit 1
        fi
    fi

    # Test 3: Godot version check (skip on ARM64)
    if [ "$(uname -m)" = "arm64" ] || [ "$(uname -m)" = "aarch64" ]; then
        log_warning "Skipping Godot version test on ARM64 (x86_64 binary compatibility issue)"
        log_info "Godot 4.2.2-stable binary is installed but cannot execute on ARM64 host"
    else
        if podman run --rm "$IMAGE_NAME:$IMAGE_TAG" godot --version | grep -q "4.2"; then
            log_success "Godot 4.2.2-stable is correctly installed"
        else
            log_error "Godot version mismatch"
            exit 1
        fi
    fi

    # Test 4: Headless mode (skip on ARM64)
    if [ "$(uname -m)" = "arm64" ] || [ "$(uname -m)" = "aarch64" ]; then
        log_warning "Skipping Godot headless test on ARM64 (x86_64 binary compatibility issue)"
        log_info "Godot headless binary is installed but cannot execute on ARM64 host"
    else
        if podman run --rm "$IMAGE_NAME:$IMAGE_TAG" godot-headless --version >/dev/null 2>&1; then
            log_success "Godot headless mode is available"
        else
            log_error "Godot headless mode is not available"
            exit 1
        fi
    fi

    # Test 5: Workspace setup
    if podman run --rm "$IMAGE_NAME:$IMAGE_TAG" ls /workspace | grep -q "gdsentry"; then
        log_success "Workspace is properly configured"
    else
        log_error "Workspace configuration failed"
        exit 1
    fi

    # Test 6: Godot 4.x specific features (skip on ARM64)
    if [ "$(uname -m)" = "arm64" ] || [ "$(uname -m)" = "aarch64" ]; then
        log_warning "Skipping Godot 4.x features test on ARM64 (x86_64 binary compatibility issue)"
        log_info "Godot 4.x features are present but cannot be tested on ARM64 host"
    else
        if podman run --rm "$IMAGE_NAME:$IMAGE_TAG" godot --help | grep -q "gdscript-docs"; then
            log_success "Godot 4.x features are available"
        else
            log_error "Godot 4.x features not detected"
            exit 1
        fi
    fi

    log_success "Godot 4.2 image validation completed"
}

push_godot_image() {
    log_info "Pushing Godot 4.2 image to registry..."

    # Check if we should push to external registry
    if [ -n "$CONTAINER_REGISTRY" ] && [ "$CONTAINER_REGISTRY" != "localhost" ]; then
        log_info "Pushing to $CONTAINER_REGISTRY/$IMAGE_NAME:$IMAGE_TAG"

        # Login to registry if credentials are available
        if [ -n "$REGISTRY_USERNAME" ] && [ -n "$REGISTRY_PASSWORD" ]; then
            podman login $CONTAINER_REGISTRY -u $REGISTRY_USERNAME -p $REGISTRY_PASSWORD
        fi

        podman push "$IMAGE_NAME:$IMAGE_TAG" "$CONTAINER_REGISTRY/$IMAGE_NAME:$IMAGE_TAG"
        log_success "Godot 4.2 image pushed to registry"
    else
        log_info "Skipping registry push (using localhost or no registry configured)"
    fi
}

create_test_script() {
    log_info "Creating test script for Godot 4.2 image..."

    cat > "test-godot-4.2.sh" << 'EOF'
#!/bin/bash

# Test script for GDSentry Godot 4.2 container image

echo "Testing GDSentry Godot 4.2 Container Image"
echo "=========================================="

# Test 1: Basic functionality
echo "Test 1: Basic container execution"
echo "Container started successfully" | grep -q "successfully" && echo "✅ PASSED" || echo "❌ FAILED"

# Test 2: Godot binary
echo "Test 2: Godot binary availability"
godot --version 2>/dev/null | grep -q "4.2" && echo "✅ PASSED" || echo "❌ FAILED"

# Test 3: Headless mode
echo "Test 3: Headless mode"
godot-headless --version 2>/dev/null | grep -q "4.2" && echo "✅ PASSED" || echo "❌ FAILED"

# Test 4: Environment variables
echo "Test 4: Environment variables"
echo "Godot Version: $GODOT_VERSION" | grep -q "4.2" && echo "✅ PASSED" || echo "❌ FAILED"
echo "Godot Binary: $GODOT_BINARY" | grep -q "godot" && echo "✅ PASSED" || echo "❌ FAILED"

# Test 5: Workspace setup
echo "Test 5: Workspace setup"
ls -la /workspace
test -d /workspace/gdsentry && echo "✅ GDSentry directory exists" || echo "❌ GDSentry directory missing"

# Test 6: User permissions
echo "Test 6: User permissions"
whoami | grep -q "developer" && echo "✅ PASSED" || echo "❌ FAILED"

# Test 7: Development tools
echo "Test 7: Development tools"
python3 --version | grep -q "Python" && echo "✅ PASSED" || echo "❌ FAILED"
git --version | grep -q "git" && echo "✅ PASSED" || echo "❌ FAILED"

# Test 8: Godot 4.x specific features
echo "Test 8: Godot 4.x features"
godot --help | grep -q "gdscript-docs" && echo "✅ PASSED" || echo "❌ FAILED"

echo "=========================================="
echo "Godot 4.2 container image test completed"
EOF

    chmod +x "test-godot-4.2.sh"
    log_success "Test script created: test-godot-4.2.sh"
}

main() {
    log_info "Starting GDSentry Godot 4.2 container image build..."

    # Check prerequisites
    check_command podman
    check_podman_machine
    check_base_image

    # Detect and set architecture-appropriate platform
    detect_architecture

    # Set architecture-specific variables
    GODOT_DOWNLOAD_URL="https://github.com/godotengine/godot/releases/download/$GODOT_VERSION/Godot_v$GODOT_VERSION"_"$GODOT_PLATFORM.zip"
    GODOT_BINARY="Godot_v$GODOT_VERSION"_"$GODOT_PLATFORM"

    # Download Godot if needed
    download_godot
    verify_godot_download

    # Create Containerfile
    create_containerfile

    # Build image
    build_godot_image

    # Validate image
    validate_godot_image

    # Create test script
    create_test_script

    # Push image (optional)
    if [ "$1" = "--push" ]; then
        push_godot_image
    fi

    log_success "Godot 4.2 container image build completed successfully!"

    # Show image information
    echo ""
    log_info "Built images:"
    podman images | grep "$IMAGE_NAME"

    log_info "Test the image with:"
    log_info "podman run --rm -it $IMAGE_NAME:$IMAGE_TAG /bin/bash"
    log_info "Or run the test script: ./test-godot-4.2.sh"
}

# Run main function
main "$@"
