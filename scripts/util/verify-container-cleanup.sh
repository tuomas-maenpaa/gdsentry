#!/bin/bash

# GDSentry - Container Cleanup Verification
# This script verifies that containers are properly cleaned up
#
# Usage: verify-container-cleanup.sh
#
# Author: GDSentry Framework
# Version: 1.0.0

set -e

echo "Verifying container cleanup..."

# Check for running GDSentry containers
RUNNING_CONTAINERS=$(podman ps -a --filter "name=gdsentry" --format "{{.Names}}" 2>/dev/null || true)

if [ -z "$RUNNING_CONTAINERS" ]; then
    echo "✅ No GDSentry containers found"
else
    echo "Found GDSentry containers:"
    echo "$RUNNING_CONTAINERS"
    
    read -p "Stop and remove these containers? (y/N) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        for container in $RUNNING_CONTAINERS; do
            echo "Stopping and removing $container..."
            podman stop "$container" >/dev/null 2>&1 || true
            podman rm "$container" >/dev/null 2>&1 || true
        done
        echo "✅ Containers cleaned up"
    fi
fi

# Check for dangling GDSentry images
DANGLING_IMAGES=$(podman images -f "dangling=true" --format "{{.ID}}" 2>/dev/null || true)

if [ -n "$DANGLING_IMAGES" ]; then
    echo "Found dangling images"
    read -p "Remove dangling images? (y/N) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        podman image prune -f >/dev/null 2>&1
        echo "✅ Dangling images removed"
    fi
else
    echo "✅ No dangling images found"
fi

echo ""
echo "Container cleanup verification complete"
echo "Tip: Use 'gdsentry info resources --cleanup' for automated cleanup"

exit 0
