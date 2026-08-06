#!/usr/bin/env python3
"""Benchmark CLI performance for development workflow validation."""

import os
import subprocess
import sys
import time
from pathlib import Path
from statistics import mean, stdev

import click


def run_command(cmd, cwd=None, env=None):
    """Run command and return result."""
    start_time = time.time()
    result = subprocess.run(
        cmd,
        shell=True,
        cwd=cwd,
        env=env,
        capture_output=True,
        text=True
    )
    end_time = time.time()
    return result, end_time - start_time


def benchmark_operation(name, cmd, cwd=None, iterations=5):
    """Benchmark an operation multiple times."""
    times = []

    click.echo(f"🔬 Benchmarking: {name}")
    click.echo(f"   Command: {cmd}")

    for i in range(iterations):
        click.echo(f"   Run {i+1}/{iterations}...", nl=False)
        result, duration = run_command(cmd, cwd)

        if result.returncode == 0:
            times.append(duration)
            click.echo(f" ✓ ({duration:.3f}s)")
        else:
            click.echo(f" ✗ Failed: {result.stderr.strip()}")

    if times:
        avg_time = mean(times)
        std_dev = stdev(times) if len(times) > 1 else 0
        click.echo(".3f")
        click.echo()

        return avg_time
    else:
        click.echo("   ❌ All runs failed")
        return None


@click.group()
def cli():
    """Benchmark GDSentry CLI performance."""
    pass


@cli.command()
@click.option('--project-dir', default='.',
              help='Path to test project')
@click.option('--iterations', default=5, help='Number of benchmark iterations')
def full_benchmark(project_dir, iterations):
    """Run full CLI performance benchmark."""
    project_path = Path(project_dir)
    if not project_path.exists():
        click.echo(f"❌ Project directory not found: {project_path}")
        return

    click.echo("🚀 GDSentry CLI Performance Benchmark")
    click.echo("=" * 50)
    click.echo(f"Project: {project_path.absolute()}")
    click.echo(f"Iterations: {iterations}")
    click.echo()

    # Set up environment
    env = dict(os.environ)
    env['PYTHONPATH'] = str(Path.cwd() / 'src')

    results = {}

    # Benchmark CLI help (startup time)
    results['cli_help'] = benchmark_operation(
        "CLI Help (--help)",
        f"{sys.executable} -m gdsentry --help",
        cwd=project_path,
        iterations=iterations
    )

    # Benchmark test discovery
    results['test_discovery'] = benchmark_operation(
        "Test Discovery",
        f"{sys.executable} -m gdsentry test discover",
        cwd=project_path,
        iterations=iterations
    )

    # Benchmark config loading
    results['config_load'] = benchmark_operation(
        "Configuration Loading",
        f"{sys.executable} -c \"from gdsentry.core.config import load_config; load_config()\"",
        cwd=project_path,
        iterations=iterations
    )

    # Summary
    click.echo("📊 Performance Summary")
    click.echo("=" * 30)

    targets = {
        'cli_help': 0.5,      # Should start in under 0.5 seconds
        'test_discovery': 1.0, # Should discover tests in under 1 second
        'config_load': 0.1,   # Should load config in under 0.1 seconds
    }

    all_passed = True
    for operation, target in targets.items():
        if operation in results and results[operation] is not None:
            time_taken = results[operation]
            status = "✅ PASS" if time_taken <= target else "❌ FAIL"
            click.echo(".3f")
            if time_taken > target:
                all_passed = False

    click.echo()
    if all_passed:
        click.echo("🎉 All performance targets met! CLI is ready for development use.")
    else:
        click.echo("⚠️  Some operations are slower than recommended for development workflow.")

    click.echo()
    click.echo("💡 Performance Tips:")
    click.echo("   • Keep test discovery under 1 second for responsive development")
    click.echo("   • CLI startup should be under 0.5 seconds")
    click.echo("   • Config loading should be instant")


@cli.command()
@click.option('--operation', required=True,
              type=click.Choice(['help', 'discover', 'config']),
              help='Operation to benchmark')
@click.option('--project-dir', default='.',
              help='Path to test project')
@click.option('--iterations', default=10, help='Number of iterations')
def single_benchmark(operation, project_dir, iterations):
    """Benchmark a single operation."""
    project_path = Path(project_dir)
    env = dict(os.environ)
    env['PYTHONPATH'] = str(Path.cwd() / 'src')

    commands = {
        'help': f"{sys.executable} -m gdsentry --help",
        'discover': f"{sys.executable} -m gdsentry test discover",
        'config': f"{sys.executable} -c \"from gdsentry.core.config import load_config; load_config()\""
    }

    benchmark_operation(
        f"Single: {operation}",
        commands[operation],
        cwd=project_path,
        iterations=iterations
    )


if __name__ == '__main__':
    import os
    cli()
