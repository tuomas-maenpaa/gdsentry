"""Resource monitoring and cleanup for Podman containers and images."""

import subprocess
from dataclasses import dataclass
from typing import List, Optional


@dataclass
class ContainerInfo:
    """Information about a container."""

    id: str
    name: str
    status: str
    image: str


@dataclass
class ImageInfo:
    """Information about an image."""

    id: str
    repository: str
    tag: str
    size: str


class ResourceMonitor:
    """Monitors and manages Podman resources."""

    def __init__(self):
        """Initialize resource monitor."""
        pass

    def list_containers(self, all_containers: bool = True) -> List[ContainerInfo]:
        """
        List Podman containers.

        Args:
            all_containers: If True, include stopped containers

        Returns:
            List of ContainerInfo objects
        """
        cmd = ["podman", "ps", "--format", "{{.ID}}|{{.Names}}|{{.Status}}|{{.Image}}"]
        if all_containers:
            cmd.append("-a")

        try:
            result = subprocess.run(cmd, capture_output=True, text=True, timeout=10)
            if result.returncode != 0:
                return []

            containers = []
            for line in result.stdout.strip().splitlines():
                if line:
                    parts = line.split("|")
                    if len(parts) == 4:
                        containers.append(
                            ContainerInfo(
                                id=parts[0], name=parts[1], status=parts[2], image=parts[3]
                            )
                        )
            return containers
        except (subprocess.TimeoutExpired, FileNotFoundError):
            return []

    def list_images(self) -> List[ImageInfo]:
        """
        List Podman images.

        Returns:
            List of ImageInfo objects
        """
        cmd = ["podman", "images", "--format", "{{.ID}}|{{.Repository}}|{{.Tag}}|{{.Size}}"]

        try:
            result = subprocess.run(cmd, capture_output=True, text=True, timeout=10)
            if result.returncode != 0:
                return []

            images = []
            for line in result.stdout.strip().splitlines():
                if line:
                    parts = line.split("|")
                    if len(parts) == 4:
                        images.append(
                            ImageInfo(
                                id=parts[0], repository=parts[1], tag=parts[2], size=parts[3]
                            )
                        )
            return images
        except (subprocess.TimeoutExpired, FileNotFoundError):
            return []

    def cleanup_stopped_containers(self) -> int:
        """
        Remove all stopped containers.

        Returns:
            Number of containers removed
        """
        try:
            result = subprocess.run(
                ["podman", "container", "prune", "-f"],
                capture_output=True,
                text=True,
                timeout=30,
            )
            # Count removed containers from output
            return result.stdout.count("Deleted Containers:") if result.returncode == 0 else 0
        except (subprocess.TimeoutExpired, FileNotFoundError):
            return 0

    def cleanup_dangling_images(self) -> int:
        """
        Remove dangling images.

        Returns:
            Number of images removed
        """
        try:
            result = subprocess.run(
                ["podman", "image", "prune", "-f"],
                capture_output=True,
                text=True,
                timeout=30,
            )
            return result.stdout.count("Deleted Images:") if result.returncode == 0 else 0
        except (subprocess.TimeoutExpired, FileNotFoundError):
            return 0

    def get_machine_info(self) -> Optional[dict]:
        """
        Get Podman machine information.

        Returns:
            Dictionary with machine info or None if not available
        """
        try:
            result = subprocess.run(
                ["podman", "machine", "list", "--format", "json"],
                capture_output=True,
                text=True,
                timeout=10,
            )
            if result.returncode == 0 and result.stdout:
                import json

                machines = json.loads(result.stdout)
                if machines and len(machines) > 0:
                    return machines[0]
            return None
        except (subprocess.TimeoutExpired, FileNotFoundError, json.JSONDecodeError):
            return None

