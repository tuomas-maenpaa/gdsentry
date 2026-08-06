# Visual Regression Testing Examples

This directory contains working examples demonstrating GDSentry's visual regression testing capabilities.

## Examples

### 1. Basic Visual Comparison (`basic_visual_test.gd`)
Demonstrates fundamental visual regression testing with baseline comparison.

**Features**:
- Baseline screenshot capture
- Visual comparison with tolerance
- Difference detection
- Basic reporting

**Use Case**: Simple UI validation and screenshot comparison

### 2. Comparison Algorithms (`algorithm_comparison_test.gd`)
Shows all 4 comparison algorithms and when to use each.

**Features**:
- Pixel-by-pixel comparison
- Perceptual hash comparison
- Structural similarity (SSIM)
- Feature-based comparison
- Algorithm selection guide

**Use Case**: Understanding and selecting appropriate comparison algorithms

### 3. Approval Workflow (`approval_workflow_test.gd`)
Demonstrates visual change approval workflow for baseline updates.

**Features**:
- Pending approval management
- Baseline approval/rejection
- Auto-approval for minor changes
- Approval state tracking

**Use Case**: Managing intentional visual changes in CI/CD

## Running Examples

### From Command Line

```bash
# Run all visual regression examples
python -m gdsentry.cli test examples/visual_regression/

# Run specific example
python -m gdsentry.cli test examples/visual_regression/basic_visual_test.gd
```

### From Godot Editor

1. Open project in Godot
2. Navigate to `examples/visual_regression/`
3. Open example scene
4. Run scene (F6)

## Example Output

```
🎯 Visual Regression Test initialized
📸 Capturing baseline: main_menu
  Screenshot saved: .runtime/test-reports/visual/baselines/main_menu.png

🔍 Comparing with baseline: main_menu
  Algorithm: PIXEL_BY_PIXEL
  Similarity: 98.5%
  Tolerance: 2.0%

✅ Visual comparison PASSED
```

## Configuration

Examples use default configuration but can be customized:

```gdscript
# Select comparison algorithm
comparison_algorithm = ComparisonAlgorithm.PIXEL_BY_PIXEL
# or PERCEPTUAL_HASH, STRUCTURAL_SIMILARITY, FEATURE_BASED

# Set tolerance
visual_tolerance = 0.02  # 2% difference allowed

# Enable diff image generation
generate_diff_images = true

# Configure auto-approval
auto_approve_similar = true
perceptual_threshold = 0.98  # 98% similarity auto-approves
```

## Comparison Algorithm Guide

### Pixel-by-Pixel
**When to use**: Exact UI validation, pixel-perfect comparison
**Tolerance**: 1-2% for UI, 5-10% for 3D scenes
**Speed**: Slow (compares every pixel)

```gdscript
comparison_algorithm = ComparisonAlgorithm.PIXEL_BY_PIXEL
visual_tolerance = 0.01  # 1% for strict UI validation
```

### Perceptual Hash
**When to use**: General screenshot comparison, smoke tests
**Tolerance**: 95%+ similarity threshold
**Speed**: Fast (hash-based comparison)

```gdscript
comparison_algorithm = ComparisonAlgorithm.PERCEPTUAL_HASH
perceptual_threshold = 0.95  # 95% similarity required
```

### Structural Similarity (SSIM)
**When to use**: Quality assessment, perceptual validation
**Tolerance**: 3-5% for quality testing
**Speed**: Medium (statistical comparison)

```gdscript
comparison_algorithm = ComparisonAlgorithm.STRUCTURAL_SIMILARITY
visual_tolerance = 0.05  # 5% SSIM difference allowed
```

### Feature-Based
**When to use**: 3D scenes with camera variations
**Tolerance**: 10-15% for transformations
**Speed**: Medium-Slow (feature extraction)
**Note**: Currently falls back to pixel-by-pixel

```gdscript
comparison_algorithm = ComparisonAlgorithm.FEATURE_BASED
visual_tolerance = 0.10  # 10% for 3D scene variations
```

## Best Practices

1. **Baseline Management**
   - Create baselines on stable, known-good builds
   - Version baselines with releases
   - Store baselines in version control (small PNGs)
   - Review and approve changes explicitly

2. **Algorithm Selection**
   - Use pixel-by-pixel for exact UI validation
   - Use perceptual hash for general comparison
   - Use SSIM for quality assessment
   - Adjust tolerance based on content type

3. **Tolerance Configuration**
   - UI elements: 1-2% (strict)
   - 3D scenes: 5-10% (loose)
   - Platform variations: 3-5% (medium)
   - Test and adjust based on false positives

4. **CI/CD Integration**
   - Capture screenshots in consistent environment
   - Compare against approved baselines
   - Fail builds on unapproved changes
   - Generate visual diff reports
   - Store diff images as artifacts

5. **Approval Workflow**
   - Review visual changes before approval
   - Document reason for baseline updates
   - Track approval history
   - Use auto-approval for minor changes

## Directory Structure

```
examples/visual_regression/
├── README.md                      # This file
├── basic_visual_test.gd           # Basic visual comparison
├── algorithm_comparison_test.gd   # Algorithm comparison
└── approval_workflow_test.gd      # Approval workflow
```

## Generated Files

Visual regression tests generate files in `.runtime/test-reports/visual/`:

```
.runtime/test-reports/visual/
├── baselines/          # Baseline screenshots
│   └── main_menu.png
├── current/            # Current test screenshots
│   └── main_menu.png
├── diff/               # Difference images
│   └── main_menu_diff.png
└── approvals/          # Pending approvals
    └── main_menu_approval.json
```

## Related Documentation

- [Advanced Test Types](../../docs/source/architecture/advanced-test-types.rst)
- [Visual Regression Test Implementation](../../src/test_types/visual_regression_test.gd)

## Troubleshooting

**False Positives**:
- Increase tolerance threshold
- Use perceptual hash instead of pixel-by-pixel
- Check for platform-specific rendering differences
- Ensure consistent test environment

**Baseline Mismatches**:
- Verify baseline exists
- Check baseline version compatibility
- Ensure same resolution and viewport size
- Validate rendering settings match

**Diff Images Not Generated**:
- Enable `generate_diff_images = true`
- Check write permissions for output directory
- Verify `.runtime/test-reports/visual/diff/` exists

**Approval Workflow Issues**:
- Check approval state in pending_approvals
- Verify approval file permissions
- Ensure approval directory exists
- Review approval threshold settings
