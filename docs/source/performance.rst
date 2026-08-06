Performance Guide
=================

GDSentry CLI is optimized for fast development iteration. This guide covers performance characteristics and optimization tips.

Performance Benchmarks
======================

Based on benchmarks with a typical Godot project containing 6 tests:

**CLI Startup Time**
- **Target**: < 0.5 seconds
- **Actual**: ~0.36 seconds ✅
- **Impact**: Fast enough for interactive development

**Test Discovery**
- **Target**: < 1.0 second
- **Actual**: ~0.31 seconds ✅
- **Impact**: Near-instant feedback on test availability

**Configuration Loading**
- **Target**: < 0.1 seconds
- **Actual**: ~0.27 seconds ⚠️
- **Impact**: Acceptable for development workflow

Performance Targets
===================

**For Development Workflow:**
- CLI commands should respond within 0.5 seconds
- Test discovery should complete within 1 second
- No operation should take more than 5 seconds

**For CI/CD Pipelines:**
- Container builds may take 30-60 minutes (acceptable)
- Test execution should scale linearly with test count
- Parallel execution should reduce total time

Optimizing Performance
======================

**Project Structure:**
- Keep test files in ``tests/`` directory (not deeply nested)
- Use descriptive test names for better organization
- Group related tests in the same file when appropriate

**Configuration:**
- Use ``gdsentry.toml`` for project-specific settings
- Minimize complex configuration that slows startup
- Cache container images for repeated testing

**Test Organization:**
- Write focused, fast unit tests for rapid feedback
- Separate slow integration tests from quick unit tests
- Use ``gdsentry test quick`` for fast validation

**Development Workflow:**
.. code-block:: bash

    # Fast feedback loop (recommended)
    gdsentry test quick          # < 5 seconds
    gdsentry test run --category unit  # < 30 seconds
    gdsentry test discover       # < 1 second

    # Full validation (when needed)
    gdsentry test run            # Complete test suite

Container Performance
=====================

**Native Architecture:**
- Fast execution (~5 minutes for builds)
- Direct hardware access
- Recommended for development

**Cross-Architecture (QEMU):**
- Slower execution (30-60 minutes for builds)
- Emulated environment
- Use for compatibility validation

**Performance Tips:**
- Build containers once, reuse for multiple test runs
- Use ``--architecture`` flags only when needed
- Cache container layers for faster rebuilds

Troubleshooting Slow Performance
=================================

**Slow CLI Startup:**
- Check Python environment and imports
- Ensure ``gdsentry`` is properly installed
- Verify system has sufficient RAM

**Slow Test Discovery:**
- Reduce number of test files or directory depth
- Use ``--filter`` to limit discovery scope
- Check for filesystem issues

**Slow Test Execution:**
- Review test code for performance bottlenecks
- Use ``--verbose`` to identify slow tests
- Consider splitting large test suites

**Container Issues:**
- Ensure Docker/Podman daemon is running
- Check available disk space
- Clean old container images periodically

Monitoring Performance
======================

**Built-in Metrics:**
.. code-block:: bash

    # See timing information
    gdsentry test run --verbose

    # Get execution summary
    gdsentry test run

**External Monitoring:**
- Use system tools (``time``, ``top``) to measure performance
- Monitor container resource usage
- Track performance trends over time

**CI/CD Performance:**
- Set appropriate timeouts for different operations
- Use parallel execution for large test suites
- Cache dependencies between runs

Next Steps
==========

- **For optimal performance**: Keep test suites focused and fast
- **For large projects**: Use selective test execution and parallelization
- **For CI/CD**: Leverage container caching and appropriate timeouts

See :doc:`troubleshooting` for additional performance-related issues.
