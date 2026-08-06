# Performance Testing Examples

This directory contains working examples demonstrating GDSentry's performance benchmark testing capabilities.

## Examples

### 1. Basic Performance Benchmark (`basic_benchmark_test.gd`)
Demonstrates fundamental performance benchmarking with statistical analysis.

**Features**:
- Simple benchmark execution
- Statistical analysis (mean, median, std dev)
- Outlier detection
- Basic reporting

**Use Case**: Quick performance validation of game systems

### 2. Baseline Comparison (`baseline_comparison_test.gd`)
Shows how to create, store, and compare against performance baselines.

**Features**:
- Baseline creation and storage
- Baseline comparison
- Regression detection
- Historical tracking

**Use Case**: Detecting performance regressions across releases

### 3. CI/CD Integration (`ci_gate_test.gd`)
Demonstrates CI/CD performance gate checking for automated builds.

**Features**:
- Configurable performance gates
- Pass/fail determination
- Detailed failure reports
- Build pipeline integration

**Use Case**: Automated performance validation in CI/CD

## Running Examples

### From Command Line

```bash
# Run all performance examples
python -m gdsentry.cli test examples/performance_testing/

# Run specific example
python -m gdsentry.cli test examples/performance_testing/basic_benchmark_test.gd
```

### From Godot Editor

1. Open project in Godot
2. Navigate to `examples/performance_testing/`
3. Open example scene
4. Run scene (F6)

## Example Output

```
🎯 Performance Benchmark Test initialized
📊 Running benchmark: array_operations
  Iteration 1/10: 0.0234s
  Iteration 2/10: 0.0231s
  ...
  Iteration 10/10: 0.0235s

📈 Statistical Analysis:
  Mean: 0.0233s
  Median: 0.0234s
  Std Dev: 0.0002s
  P95: 0.0236s
  P99: 0.0237s
  Outliers: 0 (0.0%)

✅ Benchmark completed successfully
```

## Configuration

Examples use default configuration but can be customized:

```gdscript
# Adjust statistical parameters
statistical_analyzer.confidence_level = 0.99  # 99% confidence

# Configure regression detection
regression_detector.regression_threshold = 0.05  # 5% threshold

# Set CI gate thresholds
ci_gate_checker.gate_thresholds = {
    "performance_regression": 0.03,  # 3% regression fails
    "memory_regression": 5.0,        # 5MB increase fails
    "fps_drop": 3.0                  # 3 FPS drop fails
}
```

## Best Practices

1. **Run Multiple Iterations**: Use at least 10 iterations for statistical validity
2. **Warm-up Runs**: Discard first few iterations to avoid cold-start effects
3. **Consistent Environment**: Run benchmarks in consistent conditions
4. **Baseline Management**: Update baselines when intentional changes occur
5. **Monitor Trends**: Track performance over time, not just point-in-time

## Related Documentation

- [Advanced Test Types](../../docs/source/architecture/advanced-test-types.rst)
- [Performance Benchmark Test Implementation](../../src/test_types/performance_benchmark_test.gd)

## Troubleshooting

**High Variance in Results**:
- Increase iteration count
- Close background applications
- Run on dedicated test hardware

**False Positive Regressions**:
- Adjust regression threshold
- Use confidence intervals
- Filter outliers

**Baseline Comparison Failures**:
- Ensure baseline exists
- Check baseline version compatibility
- Verify baseline file permissions
