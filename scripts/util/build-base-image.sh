#!/bin/bash

# GDSentry - Base Container Image Builder
# Builds the base container image for GDSentry testing
#
# This script creates the foundation container image that includes
# all common dependencies for GDSentry development and testing.
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
BASE_IMAGE_NAME="gdsentry-base"
BASE_IMAGE_TAG="latest"
UBUNTU_VERSION="22.04"
CONTAINERFILE=".runtime/containerfiles/Containerfile.base"

# Cross-platform utilities integration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CROSS_PLATFORM_UTILS="$SCRIPT_DIR/cross-platform-utilities.sh"

if [ -f "$CROSS_PLATFORM_UTILS" ]; then
    # shellcheck source=cross-platform-utilities.sh
    source "$CROSS_PLATFORM_UTILS"
    echo "Loaded cross-platform utilities for architecture-aware building"
    CROSS_PLATFORM_AVAILABLE=true
else
    echo "Cross-platform utilities not found, using legacy build mode"
    CROSS_PLATFORM_AVAILABLE=false
fi

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

create_containerfile() {
    log_info "Using existing Containerfile from infra/containers/..."
    
    # Ensure .runtime/containerfiles directory exists
    mkdir -p .runtime/containerfiles
    
    # Copy the Containerfile from infra/containers if it exists
    if [ -f "infra/containers/Containerfile.base" ]; then
        cp "infra/containers/Containerfile.base" "$CONTAINERFILE"
        log_success "Using Containerfile from infra/containers/Containerfile.base"
        return 0
    fi
    
    log_warning "Containerfile not found in infra/containers, creating legacy version..."

    cat > "$CONTAINERFILE" << 'EOF'
# GDSentry Base Container Image
# Foundation image for GDSentry development and testing
#
# Includes common dependencies for Godot testing framework development

FROM ubuntu:22.04

# Prevent interactive prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive

# Set metadata
LABEL maintainer="GDSentry Framework"
LABEL version="1.0.0"
LABEL description="Base container for GDSentry testing framework"

# Update package lists and install system dependencies
RUN apt-get update && apt-get upgrade -y && \
    apt-get install -y \
        # Core build tools
        build-essential \
        make \
        cmake \
        # Development tools
        git \
        curl \
        wget \
        unzip \
        tar \
        # Python development
        python3 \
        python3-pip \
        python3-venv \
        python3-dev \
        # Documentation tools
        python3-sphinx \
        python3-sphinx-rtd-theme \
        # Text processing
        sed \
        gawk \
        grep \
        # File utilities
        file \
        tree \
        # Network utilities
        net-tools \
        iputils-ping \
        # Compression
        gzip \
        bzip2 \
        xz-utils \
        # Version control
        git-lfs \
        # Development libraries
        libssl-dev \
        libffi-dev \
        # Testing tools
        jq \
        # Cleanup
        && rm -rf /var/lib/apt/lists/*

# Install Python package manager and tools
RUN pip3 install --upgrade pip setuptools wheel

# Install pre-commit for code quality
RUN pip3 install pre-commit

# Install Sphinx documentation tools
RUN pip3 install \
    sphinx \
    sphinx-rtd-theme \
    myst-parser \
    docutils

# Create development user
RUN useradd -m -s /bin/bash developer && \
    usermod -aG sudo developer && \
    echo "developer ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# Set up workspace directory
RUN mkdir -p /workspace && \
    chown -R developer:developer /workspace

# Switch to development user
USER developer

# Set working directory
WORKDIR /workspace

# Set environment variables
ENV PATH="/home/developer/.local/bin:${PATH}"
ENV HOME="/home/developer"
ENV USER="developer"

# Create basic directory structure for GDSentry
RUN mkdir -p /workspace/gdsentry && \
    mkdir -p /workspace/reports && \
    mkdir -p /workspace/artifacts

# Set up Git configuration
RUN git config --global user.name "GDSentry Developer" && \
    git config --global user.email "developer@gdsentry.local"

# Create entrypoint script
RUN echo '#!/bin/bash\n\
cd /workspace\n\
exec "$@"' > /home/developer/entrypoint.sh && \
    chmod +x /home/developer/entrypoint.sh

ENTRYPOINT ["/home/developer/entrypoint.sh"]
EOF

    log_success "Containerfile created: $CONTAINERFILE"
}

build_base_image() {
    log_info "Building base container image..."

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
    log_info "Building $BASE_IMAGE_NAME:$BASE_IMAGE_TAG..."
    if [ -n "$PLATFORM_FLAG" ]; then
        # When cross-compiling, also pass build args
        podman build $PLATFORM_FLAG \
            --build-arg TARGETARCH="${TARGET_ARCH}" \
            --build-arg BUILDPLATFORM="linux/$(uname -m)" \
            -f "$CONTAINERFILE" -t "$BASE_IMAGE_NAME:$BASE_IMAGE_TAG" .
    else
        podman build -f "$CONTAINERFILE" -t "$BASE_IMAGE_NAME:$BASE_IMAGE_TAG" .
    fi

    # Tag with additional names (ensure the expected tag exists)
    podman tag "$BASE_IMAGE_NAME:$BASE_IMAGE_TAG" "$BASE_IMAGE_NAME:latest"
    podman tag "$BASE_IMAGE_NAME:$BASE_IMAGE_TAG" "localhost/$BASE_IMAGE_NAME:$BASE_IMAGE_TAG"

    # Verify the tags were created
    log_info "Verifying image tags..."
    if podman images | grep -q "$BASE_IMAGE_NAME"; then
        log_success "Base image tags created successfully"
        log_info "Available tags:"
        podman images | grep "$BASE_IMAGE_NAME"
    else
        log_error "Failed to create base image tags"
        exit 1
    fi

    log_success "Base image built successfully"
}

validate_base_image() {
    log_info "Validating base image..."

    # Check if image exists
    if ! podman images | grep -q "$BASE_IMAGE_NAME"; then
        log_error "Base image not found after build"
        exit 1
    fi

    # Run basic tests
    log_info "Testing base image functionality..."

    # Test 1: Basic container execution
    if podman run --rm "$BASE_IMAGE_NAME:$BASE_IMAGE_TAG" echo "Container test successful" | grep -q "successful"; then
        log_success "Base container executes correctly"
    else
        log_error "Base container execution failed"
        exit 1
    fi

    # Test 2: Python availability
    if podman run --rm "$BASE_IMAGE_NAME:$BASE_IMAGE_TAG" python3 --version >/dev/null 2>&1; then
        log_success "Python 3 is available"
    else
        log_error "Python 3 is not available"
        exit 1
    fi

    # Test 3: Git availability
    if podman run --rm "$BASE_IMAGE_NAME:$BASE_IMAGE_TAG" git --version >/dev/null 2>&1; then
        log_success "Git is available"
    else
        log_error "Git is not available"
        exit 1
    fi

    # Test 4: User setup
    if podman run --rm "$BASE_IMAGE_NAME:$BASE_IMAGE_TAG" whoami | grep -q "developer"; then
        log_success "Development user is configured"
    else
        log_error "Development user is not configured"
        exit 1
    fi

    # Test 5: Pre-commit availability
    if podman run --rm "$BASE_IMAGE_NAME:$BASE_IMAGE_TAG" pre-commit --version >/dev/null 2>&1; then
        log_success "Pre-commit is available"
    else
        log_error "Pre-commit is not available"
        exit 1
    fi

    log_success "Base image validation completed"
}

push_base_image() {
    log_info "Pushing base image to registry..."

    # Check if we should push to external registry
    if [ -n "$CONTAINER_REGISTRY" ] && [ "$CONTAINER_REGISTRY" != "localhost" ]; then
        log_info "Pushing to $CONTAINER_REGISTRY/$BASE_IMAGE_NAME:$BASE_IMAGE_TAG"

        # Login to registry if credentials are available
        if [ -n "$REGISTRY_USERNAME" ] && [ -n "$REGISTRY_PASSWORD" ]; then
            podman login $CONTAINER_REGISTRY -u $REGISTRY_USERNAME -p $REGISTRY_PASSWORD
        fi

        podman push "$BASE_IMAGE_NAME:$BASE_IMAGE_TAG" "$CONTAINER_REGISTRY/$BASE_IMAGE_NAME:$BASE_IMAGE_TAG"
        log_success "Base image pushed to registry"
    else
        log_info "Skipping registry push (using localhost or no registry configured)"
    fi
}


main() {
    log_info "Starting GDSentry base container image build..."

    # Check prerequisites
    check_command podman
    check_podman_machine

    # Architecture-aware setup (if utilities are available)
    if [ "$CROSS_PLATFORM_AVAILABLE" = "true" ]; then
        log_info "Architecture-aware building enabled"

        # Detect host architecture
        if host_arch=$(detect_host_architecture 2>/dev/null | tail -1); then
            # Only set TARGET_ARCH if not already specified
            if [ -z "$TARGET_ARCH" ]; then
                export TARGET_ARCH="$host_arch"
                log_info "Building base image for $host_arch architecture (native)"
            else
                log_info "Building base image for $TARGET_ARCH architecture (requested)"
                log_info "Host architecture: $host_arch"
            fi
            log_info "Base image will support cross-platform testing"
        else
            log_warning "Could not detect host architecture, using legacy mode"
        fi
    else
        log_info "Building base image in legacy mode"
    fi

    # Create Containerfile
    create_containerfile

    # Build image
    build_base_image

    # Validate image
    validate_base_image

    # Push image (optional)
    if [ "$1" = "--push" ]; then
        push_base_image
    fi

    log_success "Base container image build completed successfully!"
    log_info "Next step: Build Godot-specific containers"
    log_info "Run: scripts/util/build-godot-3.5.sh"
    log_info "Run: scripts/util/build-godot-4.2.sh"

    # Show image information
    echo ""
    log_info "Built images:"
    podman images | grep "$BASE_IMAGE_NAME"

    log_info "Test the image with:"
    log_info "podman run --rm -it $BASE_IMAGE_NAME:$BASE_IMAGE_TAG /bin/bash"
}

# Run main function
main "$@"
