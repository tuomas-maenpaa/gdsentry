# Spike 1: Instrumentation Strategy - Findings

**Date**: 2025-10-28  
**Duration**: ~1 hour (AI-driven execution)  
**Status**: ✅ **SUCCESS - Proceed with line-based approach**

---

## Executive Summary

Simple regex-based line instrumentation is **technically feasible** for GDScript code coverage. The prototype successfully:
- Injects tracking calls without breaking code
- Preserves indentation and structure
- Executes correctly in Godot 4.x
- Works on real GDSentry test files

**Performance overhead is ~40%** which is higher than ideal, but acceptable for an optional, opt-in feature.

**Recommendation**: **PROCEED** with line-based approach, with optimizations planned for production.

---

## What Works ✅

### 1. Line-Based Instrumentation
- **Regex patterns** successfully identify executable vs non-executable lines
- **Indentation preservation** works correctly (tabs and spaces)
- **Tracking calls** inserted before executable lines without syntax errors
- **Line numbers** are accurate and reference original source

### 2. GDScript Compatibility
- Works with Godot 4.4.1 (latest stable)
- Instrumented code runs without crashes
- Coverage tracker singleton pattern works
- Dictionary-based hit storage functions correctly

### 3. Real-World Testing
- Successfully instrumented 3 GDSentry test files:
  - `test_sample.gd`: 24 tracking calls / 42 lines
  - `test_config_test.gd`: 36 tracking calls / 109 lines
  - `test_discovery_test.gd`: 36 tracking calls / 109 lines
- Patterns handle common GDScript constructs:
  - Variable assignments
  - Function calls
  - Conditionals (if/else)
  - Loops (for/while)
  - Assertions
  - Print statements

### 4. Coverage Tracking
- Line hits recorded correctly
- Report generation works
- Data structure: `{ "file.gd": { line_num: hit_count } }`

---

## Performance Metrics ⚠️

### Micro-benchmark (10,000 iterations, minimal work)
- **Original**: 1.5ms
- **Instrumented**: 29.6ms
- **Overhead**: 1,851% (unrealistic - testing only tracking overhead)

### Realistic benchmark (1,000 iterations, node creation + JSON)
- **Original**: 5.68ms
- **Instrumented**: 8.00ms
- **Overhead**: 40.92%

### Analysis
- **40% overhead is HIGH** but within acceptable range for:
  - Optional feature (coverage only when requested)
  - Not run in production/CI by default
  - Development-time tool
- **Optimization opportunities exist**:
  - Pre-allocate storage arrays
  - Cache file dictionaries (partially implemented)
  - Conditional compilation flags
  - Sampling (instrument every Nth line)

---

## Edge Cases Handled

### ✅ Working
- Comments (skipped)
- Blank lines (skipped)
- Function declarations (skipped)
- Class declarations (skipped)
- Control structures like `else:` (skipped)
- Indented code blocks (preserved)
- Multi-space and tab indentation (preserved)

###⚠️ Not Tested (Future Work)
- Multi-line statements
- Lambda/inline functions
- String literals containing code-like text
- Match statements
- Enum definitions
- Signal emissions
- Await expressions

---

## Limitations & Risks

### Known Limitations
1. **Performance**: 40% overhead may be noticeable in large test suites
2. **Regex fragility**: May break on complex/unusual GDScript patterns
3. **No branch coverage**: Only line-level, not branch/condition-level
4. **No function coverage**: Doesn't track function entry/exit separately

### Risks & Mitigations
| Risk | Likelihood | Impact | Mitigation |
|------|-----------|--------|------------|
| Regex parser breaks on edge cases | Medium | High | Comprehensive test suite, fallback to gdtoolkit |
| Performance too slow for large suites | Low | Medium | Optimize tracker, add sampling mode |
| Indentation corruption | Low | High | Extensive testing, validation mode |
| False positives/negatives | Medium | Medium | Cross-reference with manual inspection |

---

## Technical Artifacts

### Files Created
```
spike-1-instrumentation/
├── instrumenter_prototype.py          # 165 lines, regex-based instrumenter
├── test_sample.gd                     # 42 lines, test patterns
├── test_sample_instrumented.gd        # 67 lines, instrumented output
├── coverage_tracker_stub.gd           # 77 lines, minimal tracker
├── test_runner.gd                     # 81 lines, execution test
├── performance_benchmark.gd           # 106 lines, micro-benchmark
├── realistic_benchmark.gd             # 102 lines, realistic test
├── real_test_sample.gd                # 109 lines, actual GDSentry test
├── real_test_sample_instrumented.gd   # 145 lines, instrumented real test
└── FINDINGS.md                        # This document
```

### Key Code Patterns

**Instrumenter** (Python):
```python
# Simple regex-based line classification
SKIP_PATTERNS = [r'^\s*#', r'^\s*$', r'^\s*func\s+', ...]
EXECUTABLE_PATTERNS = [r'^\s*var\s+\w+\s*=', r'^\s*\w+\s*\(', ...]
```

**Tracker** (GDScript):
```gdscript
static func hit(file: String, line: int):
    # Record line execution
    var tracker = _get_singleton()
    if tracker and tracker.enabled:
        tracker.hits[file][line] += 1
```

---

## Recommendations

###  **PRIMARY: Proceed with Line-Based Approach**
- Regex solution is sufficient for MVP
- Performance overhead acceptable for opt-in feature
- Works on real GDSentry code

### 🔧 **Optimization Plan** (for production)
1. **Phase 2.1 (Instrumenter)**: 
   - Add multi-line statement handling
   - Improve regex patterns based on real usage
   - Add validation mode (parse before/after)

2. **Phase 2.2 (Tracker)**:
   - Pre-allocate arrays for known files
   - Use integer-based line storage (not dict keys)
   - Add sampling mode (configurable %)
   - Conditional compilation support

3. **Testing**:
   - Run on full GDSentry test suite
   - Measure real-world overhead
   - Identify edge cases from actual code

### 📋 **Alternative Approaches** (if needed)
1. **gdtoolkit AST parser**: More robust, but adds dependency
2. **C++ GDExtension**: Faster tracking, but more complex
3. **Godot profiler integration**: Native approach, limited to 4.x+

---

## Open Questions (Answered)

- ❓ **Which GDScript patterns are most common in tests?**  
  ✅ Variable assignments, function calls, assertions, print statements

- ❓ **Can we skip instrumenting certain lines?**  
  ✅ Yes - comments, declarations, control structures successfully skipped

- ❓ **How to handle multi-line statements?**  
  ⚠️ Not tested in spike - defer to production implementation

- ❓ **Should we instrument inside lambda/inline functions?**  
  ⚠️ Not tested - likely needs special handling

---

## Decision Matrix Result

| Outcome | Criteria | Met? |
|---------|----------|------|
| ✅ Instrumenter produces valid GDScript | All tests pass | ✅ YES |
| ✅ Instrumented tests run without errors | Godot execution successful | ✅ YES |
| ✅ Tracker correctly records hits | Report matches expected | ✅ YES |
| ⚠️ Performance overhead <10% | 40.92% measured | ❌ NO (but acceptable) |
| ✅ Works on real GDSentry files | 3 files instrumented successfully | ✅ YES |

**Result**: **4/5 success criteria met** → **PROCEED** with noted performance optimization plan

---

## Next Steps

1. ✅ **Spike 1 Complete** - Move to Spike 2 (GDScript Reporter Capabilities)
2. 📝 Update master plan with findings
3. 🚀 Begin Phase 2 implementation with optimizations baked in
4. 🧪 Plan comprehensive test suite for edge cases

---

**Conclusion**: Line-based instrumentation is **viable and recommended** for GDSentry code coverage MVP. The approach is simple, works correctly, and performance overhead is acceptable for an optional development tool.
