"""Test commands - test discovery and execution."""

import re
import shutil
import subprocess
from pathlib import Path
from typing import Dict, List, Optional

import typer

from gdsentry.ci.local import LocalCIRunner
from gdsentry.cli.ui.console import console, error, info, success
from gdsentry.core.config import load_config
from gdsentry.core.discovery import TestDiscovery
from gdsentry.core.exceptions import TestExecutionError
from gdsentry.core.reporter import TestReporter
from gdsentry.core.runner import TestRunner
from gdsentry.platform.detection import detect_architecture

app = typer.Typer(help="Test discovery and execution (local vs containerized)")


def _check_godot_available() -> bool:
    """Check if Godot executable is available in PATH.
    
    Returns:
        True if godot command is available, False otherwise
    """
    return shutil.which("godot") is not None


@app.command("discover")
def discover_tests(
    scope: str = typer.Option("project", "--scope", "-s", help="Test scope (project, framework, both)"),
    category: Optional[str] = typer.Option(None, "--category", "-c", help="Filter by category"),
    filter_pattern: str = typer.Option("*", "--filter", "-f", help="Filter pattern (glob)"),
) -> None:
    """Discover test files in the project."""
    # Validate inputs to prevent command injection
    if category and not re.match(r'^[a-zA-Z0-9._-]+$', category):
        error(f"Invalid category format: {category}")
        raise typer.Exit(1)

    if filter_pattern and not re.match(r'^[a-zA-Z0-9._*?/-]+$', filter_pattern):
        error(f"Invalid filter pattern format: {filter_pattern}")
        raise typer.Exit(1)

    try:
        config = load_config()
        gdsentry_root = config.project.gdsentry_root
        game_project_root = config.project.game_project_root

        discovery = TestDiscovery(gdsentry_root, game_project_root)

        # Discover tests based on parameters
        if category:
            tests = discovery.discover_by_category(category)
            info(f"Discovering tests in category: {category}")
        elif scope != "project":
            tests = discovery.discover_by_scope(scope)
            info(f"Discovering tests with scope: {scope}")
        else:
            tests = discovery.discover_by_filter(filter_pattern)
            if filter_pattern != "*":
                info(f"Discovering tests matching: {filter_pattern}")

        if not tests:
            console.print("[yellow]No tests discovered[/yellow]")
            return

        # Get category counts
        category_counts: Dict[str, int] = {}
        for test in tests:
            category_counts[test.category] = category_counts.get(test.category, 0) + 1

        # Report discovery with category descriptions from config
        reporter = TestReporter()
        reporter.report_discovery(len(tests), category_counts, config.test.category_descriptions)

        # List test files
        console.print("\n[bold]Test Files:[/bold]\n")
        for test in tests:
            console.print(f"  [cyan]{test.relative_path}[/cyan]")

    except Exception as e:
        error(f"Discovery failed: {e}")
        raise typer.Exit(1)


@app.command("run")
def run_tests_local(
    scope: str = typer.Option("project", "--scope", "-s", help="Test scope (framework, project)"),
    category: Optional[str] = typer.Option(None, "--category", "-c", help="Filter by category"),
    filter_pattern: str = typer.Option("*", "--filter", "-f", help="Filter pattern (glob)"),
    timeout: int = typer.Option(300, "--timeout", "-t", help="Test timeout in seconds [default: 300]"),
    verbose: bool = typer.Option(False, "--verbose", "-v", help="Verbose output"),
) -> None:
    """
    Run tests locally on your development machine.

    Best for: Development iteration, quick feedback, native architecture testing.
    Uses your local Godot installation and runs tests directly on your machine.
    Fastest option but limited to your system's architecture.

    For cross-platform testing or CI/CD, use 'run-container' instead.
    """
    try:
        # Validate inputs
        _validate_local_test_params(category, filter_pattern)

        # Detect and display architecture
        from gdsentry.platform.detection import detect_architecture
        native_arch = detect_architecture()

        console.print(f"[bold cyan]Running tests locally...[/bold cyan]")
        console.print(f"[dim]Scope: {scope}, Arch: {native_arch.value}[/dim]\n")

        # Execute tests based on scope
        if scope == "framework":
            _run_local_framework_tests(verbose)
        else:
            _run_local_project_tests()

    except Exception as e:
        error(f"Unexpected error: {e}")
        raise typer.Exit(3)


def _validate_container_test_params(
    category: Optional[str],
    filter_pattern: str,
    godot_version: Optional[str],
    arch: str,
) -> None:
    """Validate parameters for container test execution."""
    if category and not re.match(r'^[a-zA-Z0-9._-]+$', category):
        error(f"Invalid category format: {category}")
        raise typer.Exit(1)

    if filter_pattern and not re.match(r'^[a-zA-Z0-9._*?/-]+$', filter_pattern):
        error(f"Invalid filter pattern format: {filter_pattern}")
        raise typer.Exit(1)

    if godot_version and not re.match(r'^[a-zA-Z0-9._-]+$', godot_version):
        error(f"Invalid Godot version format: {godot_version}")
        raise typer.Exit(1)

    if arch != "auto" and not re.match(r'^[a-zA-Z0-9_-]+$', arch):
        error(f"Invalid architecture format: {arch}")
        raise typer.Exit(1)


def _setup_container_test_config(
    scope: Optional[str],
    godot_version: Optional[str],
    arch: str,
) -> tuple[str, str, str]:
    """Setup and return validated configuration for container tests."""
    config = load_config()

    # Determine parameters
    if scope is None:
        scope = config.test.scope.value if hasattr(config.test.scope, 'value') else str(config.test.scope)

    if godot_version is None:
        godot_version = config.project.godot_version

    if arch == "auto":
        detected = detect_architecture()
        arch = detected.value

    return scope, godot_version, arch


def _discover_container_tests(
    gdsentry_root: Path,
    game_project_root: Optional[Path],
    scope: str,
    category: Optional[str],
    filter_pattern: str,
) -> List[str]:
    """Discover test files for container execution."""
    discovery = TestDiscovery(gdsentry_root, game_project_root)

    if category:
        test_files = discovery.discover_by_category(category)
    elif filter_pattern:
        test_files = discovery.discover_by_filter(filter_pattern)
    else:
        test_files = discovery.discover_by_scope(scope)

    return test_files


def _execute_container_tests(
    test_files: List[str],
    gdsentry_root: Path,
    game_project_root: Optional[Path],
    scope: str,
    godot_version: str,
    arch: str,
    timeout: int,
    verbose: bool,
) -> None:
    """Execute tests in containers and handle results."""
    console.print(f"\n[bold cyan]Running {len(test_files)} tests...[/bold cyan]")
    console.print(f"[dim]Scope: {scope}, Godot: {godot_version}, Arch: {arch}[/dim]\n")
    
    # Show project info for project tests
    if scope == "project":
        if game_project_root:
            console.print(f"[dim]Game project: {game_project_root}[/dim]")
        else:
            console.print("[yellow]Warning: No game project attached, project tests may not work[/yellow]")
    
    console.print()

    # Create test runner with both roots
    runner = TestRunner(gdsentry_root, godot_version, arch, game_project_root)

    # Stream test execution output in real-time
    try:
        for line in runner.run_tests_streaming(test_files, scope, timeout, verbose):
            # Print each line as it arrives
            console.print(line)
    except TestExecutionError as e:
        error(f"\nTest execution failed: {e}")
        raise typer.Exit(2)  # Infrastructure failure
    except Exception as e:
        error(f"\nUnexpected error: {e}")
        raise typer.Exit(3)  # Configuration/setup failure

    # Check exit code from test execution
    console.print()
    if hasattr(runner, 'exit_code') and runner.exit_code != 0:
        error("Tests failed")
        raise typer.Exit(1)  # Test failure
    else:
        success("Tests completed successfully")


def _run_quick_framework_tests() -> None:
    """Run quick framework self-tests (subset: core + meta categories).
    
    Runs approximately 19 tests from core and meta categories instead of all 55+ tests
    for rapid development feedback. For full test coverage, use 'gdsentry test run'.
    """
    from gdsentry.cli import run_subprocess_safely

    script_path = "tests/framework/gdsentry-self-test.sh"

    console.print("[dim]Running core + meta test categories (quick subset)...[/dim]\n")

    # Use standardized subprocess error handling with category filter
    run_subprocess_safely(
        [script_path, "--quiet", "--category", "core,meta"],  # Run only core+meta for speed
        error_prefix="Quick framework test failed",
        cwd=".",
        env=None,  # Don't inherit environment for security
        capture_output=False,
        text=True,
        timeout=60  # 1 minute timeout (reduced from 2 min)
    )

    console.print()
    success("Quick framework tests completed (core + meta categories)")


def _run_quick_project_tests() -> None:
    """Run quick project tests (first 3 discovered tests) using local Godot.
    
    Discovers project tests and runs the first 3 with local Godot for rapid feedback.
    Requires Godot to be installed and available in PATH. For full coverage or
    consistent environment, use 'gdsentry test run' or 'gdsentry test run-container'.
    """
    # Check if Godot is available
    if not _check_godot_available():
        error("Godot not found in PATH")
        console.print("[dim]Quick tests require local Godot installation.[/dim]")
        console.print("[dim]Install Godot or use 'gdsentry test run-container' for containerized testing.[/dim]")
        console.print()
        console.print("[bold]Installation:[/bold]")
        console.print("  • macOS: brew install godot")
        console.print("  • Linux: apt install godot or download from godotengine.org")
        console.print("  • Windows: download from godotengine.org")
        raise typer.Exit(1)
    
    config = load_config()
    gdsentry_root = config.project.gdsentry_root
    game_project_root = config.project.game_project_root
    
    # Check if we're in a game project
    if not game_project_root:
        console.print("[yellow]Not attached to a Godot game project[/yellow]")
        console.print("[dim]Project quick tests require a game project with tests.[/dim]")
        console.print("[dim]For GDSentry framework testing, use: gdsentry test quick --scope framework[/dim]")
        return

    # Discover tests
    discovery = TestDiscovery(gdsentry_root, game_project_root)
    all_tests = discovery.discover_by_scope("project")

    # Take first 3 tests for quick run
    quick_tests = all_tests[:3] if len(all_tests) > 3 else all_tests

    if not quick_tests:
        console.print("[yellow]No project tests found[/yellow]")
        console.print(f"[dim]Looked in: {game_project_root}/tests/ or {game_project_root}/src/tests/[/dim]")
        return

    console.print(f"[dim]Running {len(quick_tests)} of {len(all_tests)} project tests (quick subset)...[/dim]\n")

    # Run each test with local Godot
    passed = 0
    failed = 0
    
    for test_file in quick_tests:
        test_name = test_file.name
        console.print(f"[cyan]• {test_name}[/cyan]", end=" ")
        
        try:
            # Run Godot headless with the test file
            result = subprocess.run(
                ["godot", "--headless", "--script", str(test_file.path)],
                cwd=str(gdsentry_root),
                capture_output=True,
                text=True,
                timeout=30
            )
            
            if result.returncode == 0:
                console.print("[green]✓[/green]")
                passed += 1
            else:
                console.print("[red]✗[/red]")
                failed += 1
                if result.stderr:
                    console.print(f"  [dim]{result.stderr.strip()[:200]}[/dim]")
                    
        except subprocess.TimeoutExpired:
            console.print("[red]✗ (timeout)[/red]")
            failed += 1
        except Exception as e:
            console.print(f"[red]✗ (error: {e})[/red]")
            failed += 1
    
    # Summary
    console.print()
    if failed == 0:
        success(f"Quick project tests completed: {passed}/{len(quick_tests)} passed")
    else:
        error(f"Quick project tests failed: {passed} passed, {failed} failed")
        raise typer.Exit(1)


def _validate_local_test_params(category: Optional[str], filter_pattern: str) -> None:
    """Validate parameters for local test execution."""
    if category and not re.match(r'^[a-zA-Z0-9._-]+$', category):
        error(f"Invalid category format: {category}")
        raise typer.Exit(1)

    if filter_pattern and not re.match(r'^[a-zA-Z0-9._*?/-]+$', filter_pattern):
        error(f"Invalid filter pattern format: {filter_pattern}")
        raise typer.Exit(1)


def _run_local_framework_tests(verbose: bool) -> None:
    """Run framework tests locally using the test script."""
    from gdsentry.cli import run_subprocess_safely

    script_path = "tests/framework/gdsentry-self-test.sh"

    if verbose:
        console.print(f"[dim]Executing: {script_path}[/dim]\n")

    # Use standardized subprocess error handling
    run_subprocess_safely(
        [script_path],
        error_prefix="Framework test failed",
        cwd=".",
        env=None,  # Don't inherit environment for security
        capture_output=False,  # Let output stream directly
        text=True
    )

    console.print()
    success("Local framework tests completed successfully")


def _run_local_project_tests() -> None:
    """Run project tests locally using installed Godot."""
    # Check if Godot is available
    if not _check_godot_available():
        error("Godot not found in PATH")
        console.print("[dim]Local project testing requires Godot installation.[/dim]")
        console.print("[dim]Install Godot or use 'gdsentry test run-container' for containerized testing.[/dim]")
        console.print()
        console.print("[bold]Installation:[/bold]")
        console.print("  • macOS: brew install godot")
        console.print("  • Linux: apt install godot or download from godotengine.org")
        console.print("  • Windows: download from godotengine.org")
        raise typer.Exit(1)
    
    config = load_config()
    gdsentry_root = config.project.gdsentry_root
    game_project_root = config.project.game_project_root
    
    # Check if we're in a game project
    if not game_project_root:
        console.print("[yellow]Not attached to a Godot game project[/yellow]")
        console.print("[dim]Local project testing requires a game project with tests.[/dim]")
        console.print("[dim]For GDSentry framework testing, use: gdsentry test run --scope framework[/dim]")
        raise typer.Exit(1)

    # Discover all project tests
    discovery = TestDiscovery(gdsentry_root, game_project_root)
    all_tests = discovery.discover_by_scope("project")

    if not all_tests:
        console.print("[yellow]No project tests found[/yellow]")
        console.print(f"[dim]Looked in: {game_project_root}/tests/ or {game_project_root}/src/tests/[/dim]")
        return

    console.print(f"[bold cyan]Running {len(all_tests)} project tests locally...[/bold cyan]\n")

    # Run each test with local Godot
    passed = 0
    failed = 0
    failed_tests = []
    
    for i, test_file in enumerate(all_tests, 1):
        test_name = test_file.name
        progress = f"[{i}/{len(all_tests)}]"
        console.print(f"{progress} [cyan]{test_file.category}/{test_name}[/cyan]", end=" ")
        
        try:
            # Run Godot headless with the test file
            result = subprocess.run(
                ["godot", "--headless", "--script", str(test_file.path)],
                cwd=str(game_project_root),
                capture_output=True,
                text=True,
                timeout=60  # 1 minute per test
            )
            
            if result.returncode == 0:
                console.print("[green]✓[/green]")
                passed += 1
            else:
                console.print("[red]✗[/red]")
                failed += 1
                failed_tests.append(test_name)
                # Show error output for failed tests
                if result.stderr:
                    console.print(f"    [dim red]{result.stderr.strip()[:300]}[/dim red]")
                    
        except subprocess.TimeoutExpired:
            console.print("[red]✗ (timeout)[/red]")
            failed += 1
            failed_tests.append(f"{test_name} (timeout)")
        except Exception as e:
            console.print(f"[red]✗ (error: {e})[/red]")
            failed += 1
            failed_tests.append(f"{test_name} (error)")
    
    # Summary
    console.print()
    console.print(f"[bold]Results:[/bold] {passed} passed, {failed} failed out of {len(all_tests)} tests")
    
    if failed > 0:
        console.print("\n[bold red]Failed tests:[/bold red]")
        for test in failed_tests:
            console.print(f"  • {test}")
        error(f"Local project tests failed: {failed} test(s)")
        raise typer.Exit(1)
    else:
        success(f"All {passed} project tests passed!")


@app.command("run-container")
def run_tests(
    scope: str = typer.Option("project", "--scope", "-s", help="Test scope (project, framework)"),
    category: Optional[str] = typer.Option(None, "--category", "-c", help="Filter by category"),
    filter_pattern: str = typer.Option("*", "--filter", "-f", help="Filter pattern (glob)"),
    godot_version: Optional[str] = typer.Option(None, "--godot", "-g", help="Godot version"),
    arch: str = typer.Option("auto", "--arch", "-a", help="Target architecture [default: auto]"),
    timeout: int = typer.Option(300, "--timeout", "-t", help="Test timeout in seconds [default: 300]"),
    verbose: bool = typer.Option(False, "--verbose", "-v", help="Verbose output"),
) -> None:
    """
    Run tests in isolated containers with cross-architecture support.

    Best for: CI/CD pipelines, cross-platform testing, reproducible environments.
    Uses Podman containers to test against different architectures (x86_64, arm64)
    and Godot versions. Requires podman environment setup.

    For quick development iteration, use 'run' (local execution) instead.

    Exit codes:
        0 - All tests passed
        1 - Tests ran but some failed
        2 - Infrastructure failure (containers, etc.)
        3 - Configuration/setup failure
    """
    try:
        # Validate inputs
        _validate_container_test_params(category, filter_pattern, godot_version, arch)

        # Setup configuration
        scope, godot_version, arch = _setup_container_test_config(scope, godot_version, arch)

        # Load configuration
        config = load_config()
        gdsentry_root = config.project.gdsentry_root
        game_project_root = config.project.game_project_root

        # Discover tests
        test_files = _discover_container_tests(gdsentry_root, game_project_root, scope, category, filter_pattern)

        if not test_files:
            console.print("[yellow]No tests to run[/yellow]")
            return

        # Execute tests
        _execute_container_tests(test_files, gdsentry_root, game_project_root, scope, godot_version, arch, timeout, verbose)

    except TestExecutionError as e:
        error(f"Test execution failed: {e}")
        raise typer.Exit(2)  # Infrastructure failure
    except Exception as e:
        error(f"Unexpected error: {e}")
        raise typer.Exit(3)  # Configuration/setup failure


@app.command("quick")
def quick_test(
    scope: str = typer.Option("project", "--scope", "-s", help="Test scope (project or framework)"),
) -> None:
    """Run a quick subset of tests for rapid development feedback.

    Framework scope: Runs core + meta categories (~19 tests, <1 minute).
    Project scope: Runs first 3 discovered tests with local Godot (<1 minute).
    
    This is NOT a replacement for full test runs. Use 'gdsentry test run' 
    for complete test coverage before committing code.
    
    Requirements:
    - Framework: Works anywhere (uses bash test script)
    - Project: Requires Godot installed and in PATH
    """
    try:
        # Use local testing for speed
        console.print(f"[bold cyan]Quick local test...[/bold cyan]")
        console.print(f"[dim]Scope: {scope}[/dim]\n")

        if scope == "framework":
            _run_quick_framework_tests()
        else:
            _run_quick_project_tests()

    except Exception as e:
        error(f"Quick test failed: {e}")
        raise typer.Exit(1)


@app.command("ci-local")
def ci_local() -> None:
    """Simulate CI workflow locally."""
    try:
        runner = LocalCIRunner()
        success_result = runner.run()
        
        if not success_result:
            raise typer.Exit(1)

    except Exception as e:
        error(f"Local CI simulation failed: {e}")
        raise typer.Exit(1)

