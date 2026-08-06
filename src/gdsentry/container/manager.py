"""Container lifecycle management."""

from pathlib import Path
from typing import Dict, Optional

from gdsentry.container.podman import PodmanClient


class ContainerManager:
    """
    High-level container lifecycle management.

    Handles:
    - Container creation and cleanup
    - File copying
    - Health checks
    """

    def __init__(self, podman_client: Optional[PodmanClient] = None):
        """
        Initialize container manager.

        Args:
            podman_client: PodmanClient instance (creates new if None)
        """
        self.podman = podman_client or PodmanClient()

    def ensure_machine_running(self) -> None:
        """Ensure Podman machine is running."""
        self.podman.ensure_machine_running()

    def create_test_container(
        self,
        image: str,
        name: str,
        platform: str,
        workspace: Optional[Path] = None,
        volumes: Optional[Dict[str, str]] = None,
        environment: Optional[Dict[str, str]] = None,
    ) -> None:
        """
        Create a test container in detached mode.

        Args:
            image: Container image name
            name: Container name
            platform: Platform identifier
            workspace: Optional workspace mount point (legacy, use volumes instead)
            volumes: Optional volume mounts {host_path: container_path}
            environment: Environment variables

        Raises:
            ContainerError: If container creation fails
        """
        # Validate container name for security
        from gdsentry.cli import validate_container_name
        validate_container_name(name)
        
        # Handle volumes - support both old workspace param and new volumes dict
        final_volumes = volumes or {}
        if workspace and str(workspace) not in final_volumes:
            # Legacy support: if workspace provided but not in volumes, add it
            final_volumes[str(workspace)] = "/workspace"

        self.podman.run_container(
            image=image,
            name=name,
            platform=platform,
            volumes=final_volumes,
            environment=environment,
            detach=True,
            remove=False,  # Don't auto-remove, we'll clean up explicitly
            command=["sleep", "infinity"],  # Keep container running
        )

    def copy_project_to_container(
        self, container_name: str, source_dir: Path, dest_dir: str = "/workspace/gdsentry"
    ) -> None:
        """
        Copy project files to container.

        Args:
            container_name: Container name
            source_dir: Source directory on host
            dest_dir: Destination directory in container

        Raises:
            ContainerError: If copy fails
        """
        self.podman.copy_to_container(container_name, source_dir, dest_dir)

    def execute_in_container(
        self, container_name: str, command: list[str]
    ) -> str:
        """
        Execute command in container and return output.

        Args:
            container_name: Container name
            command: Command to execute

        Returns:
            Command output (stdout + stderr combined)

        Raises:
            ContainerError: If execution fails
        """
        result = self.podman.exec_in_container(container_name, command)
        # Combine stdout and stderr to capture all output
        return result.stdout + result.stderr

    def execute_in_container_stream(
        self, container_name: str, command: list[str], verbose: bool = False
    ):
        """
        Execute command in container and stream output line-by-line.

        Args:
            container_name: Container name
            command: Command to execute
            verbose: If True, log verbose information

        Yields:
            Output lines as they are produced

        Raises:
            ContainerError: If execution fails
        """
        yield from self.podman.exec_in_container_stream(container_name, command, verbose)

    def cleanup_container(self, container_name: str) -> None:
        """
        Clean up a container (stop and remove).

        Args:
            container_name: Container name
        """
        try:
            if self.podman.container_exists(container_name):
                self.podman.stop_container(container_name, timeout=5)
                self.podman.remove_container(container_name, force=True)
        except Exception:
            # Best effort cleanup - don't fail if already gone
            pass

