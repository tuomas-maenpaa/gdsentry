"""Podman environment validation."""

import re
import subprocess
from dataclasses import dataclass
from typing import Optional

from gdsentry.container.podman import PodmanClient


@dataclass
class PodmanValidationResult:
    """Result of Podman validation."""

    podman_installed: bool
    podman_version: Optional[str]
    machine_exists: bool
    machine_running: bool
    machine_rootful: Optional[bool]
    can_execute_containers: bool
    error_messages: list[str]
    warning_messages: list[str]

    @property
    def is_valid(self) -> bool:
        """Check if Podman environment is valid."""
        return (
            self.podman_installed
            and self.machine_exists
            and self.machine_running
            and self.can_execute_containers
            and len(self.error_messages) == 0
        )


class PodmanValidator:
    """Validates Podman installation and configuration."""

    def __init__(self, podman_client: Optional[PodmanClient] = None):
        """
        Initialize validator.

        Args:
            podman_client: PodmanClient instance (creates new if None)
        """
        self.podman = podman_client or PodmanClient()
        self.machine_name = "podman-machine-default"

    def validate(self) -> PodmanValidationResult:
        """
        Validate Podman environment.

        Returns:
            PodmanValidationResult with validation status and messages
        """
        errors = []
        warnings = []

        # Check Podman installation
        podman_installed, podman_version = self._check_podman_installation()
        if not podman_installed:
            errors.append("Podman is not installed or not in PATH")
            return PodmanValidationResult(
                podman_installed=False,
                podman_version=None,
                machine_exists=False,
                machine_running=False,
                machine_rootful=None,
                can_execute_containers=False,
                error_messages=errors,
                warning_messages=warnings,
            )

        # Check machine existence and status
        machine_exists = self._check_machine_exists()
        if not machine_exists:
            errors.append(
                f"Podman machine '{self.machine_name}' does not exist. "
                f"Run: podman machine init {self.machine_name}"
            )

        machine_running = self._check_machine_running() if machine_exists else False
        if machine_exists and not machine_running:
            errors.append(
                f"Podman machine '{self.machine_name}' is not running. "
                f"Run: podman machine start {self.machine_name}"
            )

        # Check rootful mode
        machine_rootful = self._check_rootful_mode() if machine_running else None
        if machine_rootful is False:
            warnings.append(
                "Podman machine is not in rootful mode. "
                "This may cause networking issues with some containers."
            )
        elif machine_rootful is None and machine_running:
            warnings.append("Could not determine Podman machine rootful status")

        # Test container execution
        can_execute = self._test_container_execution() if machine_running else False
        if machine_running and not can_execute:
            errors.append("Podman cannot execute containers. Check machine configuration.")

        return PodmanValidationResult(
            podman_installed=podman_installed,
            podman_version=podman_version,
            machine_exists=machine_exists,
            machine_running=machine_running,
            machine_rootful=machine_rootful,
            can_execute_containers=can_execute,
            error_messages=errors,
            warning_messages=warnings,
        )

    def _check_podman_installation(self) -> tuple[bool, Optional[str]]:
        """Check if Podman is installed and get version."""
        try:
            result = subprocess.run(
                ["podman", "--version"],
                capture_output=True,
                text=True,
                timeout=5,
            )
            if result.returncode == 0:
                # Extract version from output like "podman version 4.5.0"
                match = re.search(r"version\s+([\d.]+)", result.stdout)
                version = match.group(1) if match else result.stdout.strip()
                return True, version
            return False, None
        except (FileNotFoundError, subprocess.TimeoutExpired):
            return False, None

    def _check_machine_exists(self) -> bool:
        """Check if Podman machine exists."""
        try:
            result = subprocess.run(
                ["podman", "machine", "list"],
                capture_output=True,
                text=True,
                timeout=10,
            )
            return self.machine_name in result.stdout
        except (FileNotFoundError, subprocess.TimeoutExpired):
            return False

    def _check_machine_running(self) -> bool:
        """Check if Podman machine is running."""
        try:
            result = subprocess.run(
                ["podman", "machine", "list"],
                capture_output=True,
                text=True,
                timeout=10,
            )
            # Look for machine name with "Currently running" status
            for line in result.stdout.splitlines():
                if self.machine_name in line and "Currently running" in line:
                    return True
            return False
        except (FileNotFoundError, subprocess.TimeoutExpired):
            return False

    def _check_rootful_mode(self) -> Optional[bool]:
        """Check if Podman machine is in rootful mode."""
        try:
            result = subprocess.run(
                ["podman", "machine", "inspect", self.machine_name],
                capture_output=True,
                text=True,
                timeout=10,
            )
            if result.returncode == 0:
                # Look for "Rootful": true/false in JSON output
                match = re.search(r'"Rootful":\s*(true|false)', result.stdout)
                if match:
                    return match.group(1) == "true"
            return None
        except (FileNotFoundError, subprocess.TimeoutExpired):
            return None

    def _test_container_execution(self) -> bool:
        """Test if Podman can execute containers."""
        try:
            result = subprocess.run(
                ["podman", "run", "--rm", "hello-world"],
                capture_output=True,
                text=True,
                timeout=30,
            )
            return result.returncode == 0
        except (FileNotFoundError, subprocess.TimeoutExpired):
            return False

