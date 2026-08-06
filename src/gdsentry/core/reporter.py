"""Test result reporting."""

from typing import Dict, Optional

from rich.console import Console
from rich.table import Table

from gdsentry.core.runner import TestResult, TestSummary


class TestReporter:
    """
    Reports test results with Rich formatting.

    Provides:
    - Test summary tables
    - Individual test results
    - Error details
    """

    def __init__(self, console_instance: Optional[Console] = None):
        """
        Initialize reporter.

        Args:
            console_instance: Rich console instance (creates new if None)
        """
        self.console = console_instance or Console()

    def report_summary(self, summary: TestSummary) -> None:
        """
        Report test summary.

        Args:
            summary: Test execution summary
        """
        table = Table(title="Test Execution Summary", show_header=True, header_style="bold cyan")

        table.add_column("Metric", style="cyan")
        table.add_column("Result", justify="right")

        # Test Suites
        if summary.total_suites > 0:
            suite_text = f"✓ {summary.passed_suites} passed, {summary.total_suites} total"
            suite_style = "green" if summary.passed_suites == summary.total_suites else "yellow"
            table.add_row("Test Suites", f"[{suite_style}]{suite_text}[/{suite_style}]")

        # Test Cases
        if summary.total_tests > 0:
            test_text = f"✓ {summary.passed_tests} passed, {summary.total_tests} total"
            test_style = "green" if summary.passed_tests == summary.total_tests else "yellow"
            table.add_row("Test Cases", f"[{test_style}]{test_text}[/{test_style}]")

        # Assertions
        if summary.total_assertions > 0:
            assert_text = (
                f"✓ {summary.passed_assertions} passed, {summary.total_assertions} total"
            )
            assert_style = (
                "green" if summary.passed_assertions == summary.total_assertions else "yellow"
            )
            table.add_row("Assertions", f"[{assert_style}]{assert_text}[/{assert_style}]")

        # Duration
        duration_text = f"{summary.duration:.2f}s"
        table.add_row("Duration", f"[blue]{duration_text}[/blue]")

        # Status
        if summary.all_passed:
            table.add_row("Status", "[bold green]ALL TESTS PASSED[/bold green]")
        else:
            failed_count = summary.failed_tests
            table.add_row(
                "Status", f"[bold red]{failed_count} FAILED[/bold red]"
            )

        self.console.print(table)

    def report_results(self, results: list[TestResult]) -> None:
        """
        Report individual test results.

        Args:
            results: List of test results
        """
        if not results:
            return

        table = Table(title="Test Results", show_header=True, header_style="bold cyan")

        table.add_column("Test", style="cyan")
        table.add_column("Status", justify="center")
        table.add_column("Duration", justify="right")

        for result in results:
            status_icon = "✓" if result.passed else "✗"
            status_style = "green" if result.passed else "red"
            status_text = f"[{status_style}]{status_icon}[/{status_style}]"

            duration_text = f"{result.duration:.2f}s"

            table.add_row(
                result.test_file,
                status_text,
                f"[blue]{duration_text}[/blue]",
            )

        self.console.print(table)

    def report_errors(self, results: list[TestResult]) -> None:
        """
        Report errors from failed tests.

        Args:
            results: List of test results
        """
        failed = [r for r in results if not r.passed]

        if not failed:
            return

        self.console.print("\n[bold red]Failed Tests:[/bold red]\n")

        for result in failed:
            self.console.print(f"[red]✗[/red] {result.test_file}")

            if result.error:
                self.console.print(f"  [yellow]Error:[/yellow] {result.error}")

            if result.output:
                # Show last 10 lines of output
                lines = result.output.strip().split("\n")
                if len(lines) > 10:
                    lines = lines[-10:]
                for line in lines:
                    self.console.print(f"  [dim]{line}[/dim]")

            self.console.print()

    def report_discovery(
        self, test_count: int, category_counts: Dict[str, int], category_descriptions: Optional[Dict[str, str]] = None
    ) -> None:
        """
        Report test discovery results.

        Args:
            test_count: Total number of tests discovered
            category_counts: Dictionary of category -> count
            category_descriptions: Optional dictionary of category -> description
        """
        table = Table(title="Discovered Tests", show_header=True, header_style="bold cyan")

        table.add_column("Category", style="cyan")
        table.add_column("Count", justify="right", style="green")
        table.add_column("Description", style="dim")

        descriptions = category_descriptions or {}
        
        for category, count in sorted(category_counts.items()):
            description = descriptions.get(category, "")
            table.add_row(category, str(count), description)

        table.add_row("[bold]Total[/bold]", f"[bold]{test_count}[/bold]", "")

        self.console.print(table)

    def report_quick_summary(self, summary: TestSummary) -> None:
        """
        Report quick one-line summary.

        Args:
            summary: Test execution summary
        """
        if summary.all_passed:
            self.console.print(
                f"[green]✓[/green] {summary.passed_tests} tests passed in {summary.duration:.2f}s"
            )
        else:
            self.console.print(
                f"[red]✗[/red] {summary.failed_tests} of {summary.total_tests} tests failed "
                f"in {summary.duration:.2f}s"
            )

