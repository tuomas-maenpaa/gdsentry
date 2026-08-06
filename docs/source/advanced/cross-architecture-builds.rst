Cross-Architecture Builds for GDSentry
=====================================

This document explains how to build and test GDSentry containers for different CPU architectures.

Quick Reference
===============

.. list-table:: Build Commands and Times
   :header-rows: 1
   :widths: 30 40 15 15

   * - Command
     - What It Does
     - Time on ARM64
     - Time on x86_64
   * - ``gdsentry build all``
     - Build for native arch
     - ~5 min
     - ~5 min
   * - ``gdsentry build godot --architecture arm64``
     - Build ARM64 containers
     - ~5 min native

       30-60 min on x86
     - 30-60 min emulated
   * - ``gdsentry build godot --architecture x86_64``
     - Build x86_64 containers
     - 30-60 min emulated
     - ~5 min native
   * - ``gdsentry build all --all-architectures``
     - Build both architectures
     - 35-65 min
     - 35-65 min

Architecture Support
=====================

GDSentry containers are built using **Podman with QEMU emulation** for cross-architecture support:

- **Native builds**: Fast (~5 minutes)
- **Cross-architecture builds**: Slower (30-60 minutes due to QEMU emulation)

Modern Podman Architecture (v5.x+)
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

**Important:** GDSentry uses **Option B (QEMU Emulation)** exclusively:

- ✅ **Single Podman machine** (`podman-machine-default`)
- ✅ **QEMU built-in** for cross-architecture emulation
- ✅ **Container platform selection** (`--platform=linux/amd64` or `--platform=linux/arm64`)
- ❌ **No architecture-specific machines** (not possible in Podman 5.x)

**Why?** Modern Podman (v5.x) removed the `--arch` parameter from `podman machine init`. 
All cross-architecture support is now handled via:
1. QEMU emulation inside the single VM
2. Container `--platform` flags at runtime
3. Multi-arch container images (buildx)

Supported Architectures

.. list-table:: Architecture Support Matrix
   :header-rows: 1
   :widths: 40 15 15 30

   * - Architecture
     - Godot 3.5
     - Godot 4.2
     - Notes
   * - **x86_64** (AMD/Intel)
     - ✅ Native
     - ✅ Native
     - Full support
   * - **ARM64** (Apple Silicon, ARM servers)
     - ⚠️ Emulated
     - ✅ Native
     - Godot 3.5 has no ARM64 binary

Usage
=====

For Daily Development

**Build and test natively** (fastest):

.. code-block:: bash

   # Build for your current architecture
   gdsentry build all

   # Run tests
   gdsentry test run

~~~~~~~~~~~~~~~~~~~~~~~~~For Pre-Commit Verification

**Build for the architecture you need to verify**:

# .. code-block:: bash
# 
# On ARM64 Mac - verify x86_64 compatibility before commit
gdsentry build godot --architecture x86_64
# ⏱️ Takes 30-60 minutes - go get coffee!

# Then test
gdsentry test run


# .. code-block:: bash
# 
# On x86_64 Linux - verify ARM64 compatibility
gdsentry build godot --architecture arm64
# ⏱️ Takes 30-60 minutes


~~~~~~~~~~~~~~~~~~~~~~~~~For Full Multi-Architecture Testing

**Build both architectures** (for comprehensive CI-like verification):

# .. code-block:: bash
# 
gdsentry build all --all-architectures
# ⏱️ Takes 35-65 minutes total


==================How It Works

~~~~~~~~~~~~~~~~~~~~~~~~~Native Build (Fast)

When building for your native architecture:

1. Downloads Ubuntu base image (native arch)
2. Installs dependencies (native speed)
3. Downloads Godot binary (appropriate arch)
4. Creates container (~5 minutes total)

~~~~~~~~~~~~~~~~~~~~~~~~~Cross-Architecture Build (Slow)

When building for a different architecture (e.g., x86_64 on ARM64):

1. Downloads Ubuntu base image with `--platform=linux/amd64`
2. **Every instruction runs through QEMU emulation**
   - `apt-get install` → emulated
   - Shell commands → emulated
   - File operations → emulated overhead
3. Downloads Godot binary
4. Creates container (~30-60 minutes total)

**Why so slow?** QEMU emulates every CPU instruction. A simple `apt-get update` that takes 10 seconds natively can take 5-10 minutes when emulated.

==================Technical Details

~~~~~~~~~~~~~~~~~~~~~~~~~Implementation

The cross-architecture support uses:

# .. code-block:: bash
# 
# Build scripts detect TARGET_ARCH
TARGET_ARCH=x86_64 ./scripts/util/build-base-image.sh

# Internally, this runs:
podman build --platform=linux/amd64 \
  --build-arg TARGETARCH=x86_64 \
  -f infra/containers/Containerfile.base .


~~~~~~~~~~~~~~~~~~~~~~~~~Containerfile Multi-Arch Support

Containerfiles use build arguments for architecture detection:

dockerfile
ARG TARGETARCH
ARG BUILDPLATFORM
ARG TARGETPLATFORM

# QEMU for cross-architecture support
RUN apt-get install -y qemu-user-static binfmt-support

# Architecture-specific logic
RUN if [ "${TARGETARCH}" = "arm64" ]; then \
        GODOT_PLATFORM="linux.arm64"; \
    else \
        GODOT_PLATFORM="linux.x86_64"; \
    fi


~~~~~~~~~~~~~~~~~~~~~~~~~QEMU Emulation

Podman machine includes QEMU binfmt support:

# .. code-block:: bash
# 
# Verify QEMU is available
podman machine ssh podman-machine-default \
  "ls /proc/sys/fs/binfmt_misc/ | grep qemu"

# Output shows:
# qemu-x86_64  - for running x86_64 on ARM64
# qemu-aarch64 - for running ARM64 on x86_64


==================Performance Expectations

~~~~~~~~~~~~~~~~~~~~~~~~~Build Time Breakdown

**Native build (ARM64 on ARM64):**

Base image:    ~2 min
Godot 3.5:     ~1.5 min
Godot 4.2:     ~1.5 min
Total:         ~5 min


**Cross-arch build (x86_64 on ARM64):**

Base image:    ~15-20 min  (apt-get packages are slow)
Godot 3.5:     ~8-10 min   (emulated unzip, file ops)
Godot 4.2:     ~8-10 min   (emulated unzip, file ops)
Total:         ~30-40 min  (can vary up to 60 min)


~~~~~~~~~~~~~~~~~~~~~~~~~What Affects Speed

**Faster:**
- SSD vs HDD
- More CPU cores
- More RAM
- Fewer Containerfile layers

**Slower:**
- Many `apt-get install` commands
- Complex shell scripts in RUN commands
- Large file operations

==================Alternatives

~~~~~~~~~~~~~~~~~~~~~~~~~Option 1: Use CI for Cross-Architecture (Recommended)

Let GitHub Actions build both architectures in parallel:

yaml
# .github/workflows/multi-arch.yml
jobs:
  build-amd64:
    runs-on: ubuntu-latest
    steps:
      - run: gdsentry build all  # Fast on x86_64

  build-arm64:
    runs-on: ubuntu-24.04-arm64
    steps:
      - run: gdsentry build all  # Fast on ARM64


**Result:** Both architectures built in ~5 minutes (parallel)

~~~~~~~~~~~~~~~~~~~~~~~~~Option 2: Docker Buildx

Docker Buildx is faster than Podman for cross-arch:

# .. code-block:: bash
# 
docker buildx create --use
docker buildx build --platform linux/amd64,linux/arm64 \
  -t gdsentry-base:latest .


**Speed:** ~10-15 minutes (vs 30-60 with Podman)

~~~~~~~~~~~~~~~~~~~~~~~~~Option 3: Remote Builder

Build on actual hardware:

# .. code-block:: bash
# 
# Configure remote builder
export DOCKER_HOST=ssh://user@x86-server

# Build runs on remote x86_64 machine
gdsentry build all


**Speed:** ~5 minutes (native on remote machine)

==================Troubleshooting

~~~~~~~~~~~~~~~~~~~~~~~~~Build Takes Forever

**Expected**: Cross-arch builds are slow (30-60 min)

**If stuck >60 min:**
# .. code-block:: bash
# 
# Check if it's actually progressing
podman ps -a

# View live logs
podman logs -f <container-id>


~~~~~~~~~~~~~~~~~~~~~~~~~Platform Mismatch Warning


WARNING: image platform (linux/amd64) does not match the expected platform (linux/arm64)


**This is normal** when running x86_64 containers on ARM64. QEMU handles it.

~~~~~~~~~~~~~~~~~~~~~~~~~Out of Memory

Cross-arch builds use more RAM. Increase Podman machine memory:

# .. code-block:: bash
# 
podman machine stop
podman machine set --memory 8192  # 8GB
podman machine start


==================Best Practices

~~~~~~~~~~~~~~~~~~~~~~~~~For Daily Development

✅ **Do:**
- Build natively: `gdsentry build all`
- Test natively: `gdsentry test run`
- Iterate quickly

❌ **Don't:**
- Build cross-arch every time
- Wait 30-60 min per iteration

~~~~~~~~~~~~~~~~~~~~~~~~~For Pre-Commit Verification

✅ **Do:**
- Run cross-arch build before major commits
- Start build and do other work while waiting
- Use `gdsentry build godot --architecture x86_64` or `gdsentry build godot --architecture arm64`

❌ **Don't:**
- Run cross-arch build on every commit
- Block on cross-arch builds

~~~~~~~~~~~~~~~~~~~~~~~~~For CI/CD

✅ **Do:**
- Build each arch on native runners (parallel, fast)
- Use container registry with manifest lists
- Cache layers aggressively

❌ **Don't:**
- Build all architectures on one runner
- Rely on emulation in CI

==================Examples

~~~~~~~~~~~~~~~~~~~~~~~~~Example 1: Pre-Commit Verification on ARM64 Mac

# .. code-block:: bash
# 
# Make your code changes
vim src/core/gdsentry.gd

# Quick test with native build
gdsentry build all && gdsentry test run  # ~5 min

# Before committing, verify x86_64 compatibility
gdsentry build godot --architecture x86_64  # ~30-60 min - start this and work on docs/tests

# Once complete, final test
gdsentry test run

# Commit with confidence
git commit -m "feat: added new feature, verified on both architectures"


~~~~~~~~~~~~~~~~~~~~~~~~~Example 2: Full Multi-Arch Verification

# .. code-block:: bash
# 
# Clean slate (optional - gdsentry handles this automatically)
# Build everything
gdsentry build all --all-architectures  # ~35-65 min total

# Test both
gdsentry test run --all-architectures

# All architectures verified ✅


~~~~~~~~~~~~~~~~~~~~~~~~~Example 3: Quick Native Iteration

# .. code-block:: bash
# 
# Fast iteration loop
while true; do
  gdsentry build all      # ~5 min
  gdsentry test run       # ~2 min
  # Review results, make changes
done


==================Summary

**Cross-architecture builds work** and are useful for pre-commit verification:

- ✅ `gdsentry build all` - Native, fast (~5 min)
- ✅ `gdsentry build godot --architecture x86_64` - Cross-arch, slow (~30-60 min) - **Use before commits**
- ✅ `gdsentry build all --all-architectures` - Both archs (~35-65 min) - **Use for major releases**

**The slowness is inherent to QEMU emulation** - this is expected and acceptable for occasional verification before committing.

