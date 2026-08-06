"""Podman client wrapper for container operations."""

import subprocess
from pathlib import Path
from typing import Dict, List, Optional

from gdsentry.core.exceptions import ContainerError


class PodmanError(ContainerError):
    """Raised when Podman operations fail."""

    pass


class PodmanClient:
    """
    Wrapper around Podman CLI for container operations.

    Provides high-level API for:
    - Image management (list, build, remove)
    - Container lifecycle (run, exec, stop, remove)
    - Machine status checks
    """

    def __init__(self, timeout: int = 300):
        """
        Initialize Podman client.

        Args:
            timeout: Default timeout for operations in seconds
        """
        self.timeout = timeout
        self._check_podman_available()

    def _check_podman_available(self) -> None:
        """Check if Podman is installed and available."""
        try:
            result = self._run_command(["podman", "version"], timeout=5)
            if result.returncode != 0:
                raise PodmanError("Podman is not responding correctly")
        except FileNotFoundError:
            raise PodmanError(
                "Podman is not installed. "
                "Please install Podman: https://podman.io/getting-started/installation"
            )

    def _run_command(
        self,
        cmd: List[str],
        capture_output: bool = True,
        timeout: Optional[int] = None,
        check: bool = False,
    ) -> subprocess.CompletedProcess:
        """
        Run a command with subprocess.

        Args:
            cmd: Command and arguments
            capture_output: Whether to capture stdout/stderr
            timeout: Timeout in seconds (uses self.timeout if None)
            check: Whether to raise on non-zero exit

        Returns:
            CompletedProcess instance

        Raises:
            PodmanError: If command fails and check=True
        """
        timeout = timeout or self.timeout

        try:
            result = subprocess.run(
                cmd,
                capture_output=capture_output,
                timeout=timeout,
                text=True,
            )

            if check and result.returncode != 0:
                raise PodmanError(
                    f"Command failed: {' '.join(cmd)}\n"
                    f"Exit code: {result.returncode}\n"
                    f"stderr: {result.stderr}"
                )

            return result

        except subprocess.TimeoutExpired as e:
            raise PodmanError(f"Command timed out after {timeout}s: {' '.join(cmd)}") from e
        except Exception as e:
            raise PodmanError(f"Command failed: {' '.join(cmd)}\nError: {e}") from e

    # Image operations

    def image_exists(self, image_name: str) -> bool:
        """
        Check if an image exists locally.

        Args:
            image_name: Image name (e.g., "gdsentry-base:latest")

        Returns:
            True if image exists, False otherwise
        """
        result = self._run_command(["podman", "images", "-q", image_name])
        return bool(result.stdout.strip())

    def list_images(self, filter_name: Optional[str] = None) -> List[str]:
        """
        List images, optionally filtered by name.

        Args:
            filter_name: Filter images by name (e.g., "gdsentry")

        Returns:
            List of image names
        """
        cmd = ["podman", "images", "--format", "{{.Repository}}:{{.Tag}}"]
        if filter_name:
            cmd.extend(["--filter", f"reference=*{filter_name}*"])

        result = self._run_command(cmd)
        return [line.strip() for line in result.stdout.splitlines() if line.strip()]

    def build_image(
        self,
        containerfile: Path,
        tag: str,
        context: Path = Path("."),
        platform: Optional[str] = None,
        build_args: Optional[Dict[str, str]] = None,
    ) -> None:
        """
        Build a container image.

        Args:
            containerfile: Path to Containerfile/Dockerfile
            tag: Image tag (e.g., "gdsentry-base:latest")
            context: Build context directory
            platform: Platform identifier (e.g., "linux/amd64")
            build_args: Build arguments

        Raises:
            PodmanError: If build fails
        """
        cmd = [
            "podman",
            "build",
            "-f",
            str(containerfile),
            "-t",
            tag,
        ]

        if platform:
            cmd.extend(["--platform", platform])

        if build_args:
            for key, value in build_args.items():
                cmd.extend(["--build-arg", f"{key}={value}"])

        cmd.append(str(context))

        self._run_command(cmd, check=True)

    def remove_image(self, image_name: str, force: bool = False) -> None:
        """
        Remove an image.

        Args:
            image_name: Image name to remove
            force: Force removal even if in use

        Raises:
            PodmanError: If removal fails
        """
        cmd = ["podman", "rmi"]
        if force:
            cmd.append("-f")
        cmd.append(image_name)

        self._run_command(cmd, check=True)

    # Container operations

    def run_container(
        self,
        image: str,
        name: Optional[str] = None,
        command: Optional[List[str]] = None,
        platform: Optional[str] = None,
        volumes: Optional[Dict[str, str]] = None,
        environment: Optional[Dict[str, str]] = None,
        detach: bool = False,
        remove: bool = True,
    ) -> subprocess.CompletedProcess:
        """
        Run a container.

        Args:
            image: Image name
            name: Container name
            command: Command to run in container
            platform: Platform identifier
            volumes: Volume mounts {host_path: container_path}
            environment: Environment variables
            detach: Run in background
            remove: Auto-remove container on exit

        Returns:
            CompletedProcess instance

        Raises:
            PodmanError: If container fails to start
        """
        cmd = ["podman", "run"]

        if detach:
            cmd.append("-d")
        if remove:
            cmd.append("--rm")
        if name:
            cmd.extend(["--name", name])
        if platform:
            cmd.extend(["--platform", platform])

        if volumes:
            for host_path, container_path in volumes.items():
                cmd.extend(["-v", f"{host_path}:{container_path}"])

        if environment:
            for key, value in environment.items():
                cmd.extend(["-e", f"{key}={value}"])

        cmd.append(image)

        if command:
            cmd.extend(command)

        return self._run_command(cmd, check=True)

    def exec_in_container(
        self, container_name: str, command: List[str]
    ) -> subprocess.CompletedProcess:
        """
        Execute a command in a running container.

        Args:
            container_name: Container name
            command: Command to execute

        Returns:
            CompletedProcess instance

        Raises:
            PodmanError: If exec fails
        """
        cmd = ["podman", "exec", container_name] + command
        return self._run_command(cmd, check=True)

    def exec_in_container_stream(
        self, container_name: str, command: List[str], verbose: bool = False
    ):
        """
        Execute a command in a running container and stream output line-by-line.

        Args:
            container_name: Container name
            command: Command to execute
            verbose: If True, log the command being executed

        Yields:
            Output lines as they are produced

        Raises:
            PodmanError: If exec fails
        """
        cmd = ["podman", "exec", container_name] + command

        if verbose:
            from gdsentry.cli import sanitize_command_for_logging
            sanitized_cmd = sanitize_command_for_logging(cmd)
            yield f"[Verbose] Command: {sanitized_cmd}"
        
        try:
            process = subprocess.Popen(
                cmd,
                stdout=subprocess.PIPE,
                stderr=subprocess.STDOUT,
                text=True,
                bufsize=1,  # Line buffered
            )
            
            # Stream output line by line
            for line in iter(process.stdout.readline, ''):
                if line:
                    yield line.rstrip()
            
            # Wait for process to complete
            returncode = process.wait()
            
            # Yield exit code for caller
            if verbose:
                yield f"[Verbose] Exit code: {returncode}"
            
            # Store exit code as instance attribute for caller to check
            self._last_exit_code = returncode
                
        except subprocess.TimeoutExpired as e:
            raise PodmanError(
                f"Command timed out: {' '.join(cmd)}"
            ) from e
        except Exception as e:
            if not isinstance(e, PodmanError):
                raise PodmanError(
                    f"Command execution failed: {' '.join(cmd)}\nError: {e}"
                ) from e
            raise

    def stop_container(self, container_name: str, timeout: int = 10) -> None:
        """
        Stop a running container.

        Args:
            container_name: Container name
            timeout: Timeout before force kill

        Raises:
            PodmanError: If stop fails
        """
        cmd = ["podman", "stop", "-t", str(timeout), container_name]
        self._run_command(cmd, check=True)

    def remove_container(self, container_name: str, force: bool = False) -> None:
        """
        Remove a container.

        Args:
            container_name: Container name
            force: Force removal even if running

        Raises:
            PodmanError: If removal fails
        """
        cmd = ["podman", "rm"]
        if force:
            cmd.append("-f")
        cmd.append(container_name)

        self._run_command(cmd, check=True)

    def container_exists(self, container_name: str) -> bool:
        """
        Check if a container exists.

        Args:
            container_name: Container name

        Returns:
            True if container exists, False otherwise
        """
        result = self._run_command(["podman", "ps", "-a", "-q", "-f", f"name={container_name}"])
        return bool(result.stdout.strip())

    def copy_to_container(
        self, container_name: str, source: Path, destination: str
    ) -> None:
        """
        Copy files to a container.

        Args:
            container_name: Container name
            source: Source path on host
            destination: Destination path in container

        Raises:
            PodmanError: If copy fails
        """
        cmd = ["podman", "cp", str(source), f"{container_name}:{destination}"]
        self._run_command(cmd, check=True)

    # Machine operations

    def is_machine_running(self, machine_name: str = "podman-machine-default") -> bool:
        """
        Check if Podman machine is running.

        Args:
            machine_name: Machine name

        Returns:
            True if running, False otherwise
        """
        result = self._run_command(["podman", "machine", "list", "--format", "{{.Name}},{{.Running}}"])
        
        for line in result.stdout.splitlines():
            if not line.strip():
                continue
            parts = line.split(",")
            if len(parts) == 2:
                name, running = parts
                if name.strip() == machine_name and running.strip().lower() in ("true", "running"):
                    return True
        return False

    def ensure_machine_running(self, machine_name: str = "podman-machine-default") -> None:
        """
        Ensure Podman machine is running, start if not.

        Args:
            machine_name: Machine name

        Raises:
            PodmanError: If machine cannot be started
        """
        if not self.is_machine_running(machine_name):
            cmd = ["podman", "machine", "start", machine_name]
            self._run_command(cmd, check=True)

