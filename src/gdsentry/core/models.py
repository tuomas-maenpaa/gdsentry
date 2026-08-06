"""Pydantic models for GDSentry configuration and data structures."""

from enum import Enum
from pathlib import Path
from typing import Dict, Optional, Union

from pydantic import BaseModel, ConfigDict, Field, field_validator


class Architecture(str, Enum):
    """Supported architectures."""

    X86_64 = "x86_64"
    ARM64 = "arm64"
    AUTO = "auto"


class ScopeType(str, Enum):
    """Test execution scope."""

    PROJECT = "project"
    FRAMEWORK = "framework"
    BOTH = "both"


class DocFormat(str, Enum):
    """Documentation output formats."""

    HTML = "html"
    PDF = "pdf"
    LINKCHECK = "linkcheck"


class ProjectConfig(BaseModel):
    """Project-level configuration."""

    name: str = Field(default="gdsentry-project", description="Project name")
    godot_version: str = Field(default="4.2.2-stable", description="Godot version")
    
    # New architecture: explicit separation of GDSentry framework and game project
    gdsentry_root: Path = Field(default=Path.cwd(), description="GDSentry framework root directory")
    game_project_root: Optional[Path] = Field(default=None, description="Godot game project root directory (optional)")
    
    # Legacy field for backward compatibility
    project_root: Optional[Path] = Field(default=None, description="DEPRECATED: Use gdsentry_root instead")

    @field_validator("gdsentry_root", "game_project_root", "project_root", mode="before")
    @classmethod
    def resolve_path(cls, v: Union[str, Path, None]) -> Optional[Path]:
        """Resolve path to absolute."""
        if v is None:
            return None
        return Path(v).resolve()


class TestConfig(BaseModel):
    """Test execution configuration."""

    model_config = ConfigDict(validate_assignment=True)

    scope: ScopeType = Field(default=ScopeType.PROJECT, description="Test scope")
    filter: str = Field(default="*", description="Test filter pattern (glob)")
    parallel: bool = Field(default=False, description="Enable parallel execution")
    timeout: int = Field(default=300, description="Test timeout in seconds")
    watch: bool = Field(default=False, description="Watch mode for TDD")
    verbose: bool = Field(default=False, description="Verbose output")
    category_descriptions: Dict[str, str] = Field(
        default_factory=dict, description="Category name to description mapping"
    )

    @field_validator("timeout")
    @classmethod
    def validate_timeout(cls, v: int) -> int:
        """Ensure timeout is positive."""
        if v <= 0:
            raise ValueError("Timeout must be positive")
        return v


class PlatformConfig(BaseModel):
    """Platform and architecture configuration."""

    default_arch: Architecture = Field(
        default=Architecture.AUTO, description="Default target architecture"
    )
    supported_archs: list[Architecture] = Field(
        default=[Architecture.X86_64, Architecture.ARM64],
        description="Supported architectures",
    )
    enable_qemu: bool = Field(default=True, description="Enable QEMU emulation")


class ContainerConfig(BaseModel):
    """Container runtime configuration."""

    registry: str = Field(default="localhost", description="Container registry")
    base_image: str = Field(default="gdsentry-base:latest", description="Base image name")
    auto_build: bool = Field(
        default=True, description="Automatically build missing images"
    )
    cleanup_on_exit: bool = Field(
        default=True, description="Cleanup containers on exit"
    )

    @field_validator("registry")
    @classmethod
    def validate_registry(cls, v: str) -> str:
        """Ensure only localhost registry is used."""
        if v != "localhost":
            raise ValueError("Only 'localhost' registry is supported (no external dependencies)")
        return v


class ValidationConfig(BaseModel):
    """Code validation configuration."""

    check_licenses: bool = Field(default=True, description="Check license headers")
    check_imports: bool = Field(default=True, description="Validate Python imports")
    gdscript_strict: bool = Field(default=False, description="Strict GDScript validation")
    check_rst_links: bool = Field(default=True, description="Check RST documentation links")


class DocsConfig(BaseModel):
    """Documentation configuration."""

    format: DocFormat = Field(default=DocFormat.HTML, description="Documentation format")
    source_dir: Path = Field(default=Path("docs/source"), description="Sphinx source directory")
    build_dir: Path = Field(default=Path("docs/build"), description="Build output directory")
    port: int = Field(default=8000, description="Preview server port")
    auto_build: bool = Field(default=False, description="Auto-rebuild on changes")

    @field_validator("source_dir", "build_dir", mode="before")
    @classmethod
    def resolve_path(cls, v: Union[str, Path]) -> Path:
        """Resolve path to absolute."""
        return Path(v).resolve()

    @field_validator("port")
    @classmethod
    def validate_port(cls, v: int) -> int:
        """Ensure port is valid."""
        if not 1024 <= v <= 65535:
            raise ValueError("Port must be between 1024 and 65535")
        return v


class CIConfig(BaseModel):
    """CI/CD pipeline configuration."""

    full_pipeline: bool = Field(default=True, description="Run full CI pipeline")
    quick_checks: list[str] = Field(
        default=["gdscript", "imports"], description="Quick validation checks"
    )
    fail_fast: bool = Field(default=False, description="Stop on first failure")


class GDSentryConfig(BaseModel):
    """Complete GDSentry configuration."""

    model_config = ConfigDict(use_enum_values=False, validate_assignment=True, frozen=False)

    project: ProjectConfig = Field(default_factory=ProjectConfig)
    test: TestConfig = Field(default_factory=TestConfig)
    platform: PlatformConfig = Field(default_factory=PlatformConfig)
    container: ContainerConfig = Field(default_factory=ContainerConfig)
    validation: ValidationConfig = Field(default_factory=ValidationConfig)
    docs: DocsConfig = Field(default_factory=DocsConfig)
    ci: CIConfig = Field(default_factory=CIConfig)

