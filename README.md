# GDSentry - Advanced Godot Testing Framework

> **⚠️ Hobby Project** - This is a hobby project. Not actively maintained. Use at your own risk. No support provided.
>
> **📄 License Note**: MIT License with commercial attribution requirements. See LICENSE file for details.

## Overview

GDSentry represents a fundamental shift in how developers approach testing within the Godot ecosystem. Traditional testing frameworks focus narrowly on unit testing, but GDSentry recognizes that game development demands comprehensive validation across multiple dimensions. Through its project-agnostic design, GDSentry enables developers to validate not just code logic, but also visual presentation, user interaction, physics behavior, and system performance.

This comprehensive approach transforms testing from a compliance activity into an integral part of the development workflow. Developers gain confidence in their code changes while maintaining the creative freedom that makes game development compelling.

## Core Capabilities

GDSentry provides a complete testing solution that addresses the unique challenges of game development:

### Unit Testing Foundation

Traditional logic testing forms the foundation of GDSentry's capabilities. Developers can validate game mechanics, state management, and algorithmic correctness using familiar patterns adapted for Godot's scene-based architecture.

### Visual Testing Integration

Visual elements represent a critical aspect of game quality that traditional testing frameworks often ignore. GDSentry enables verification of UI layouts, rendering consistency, and visual component positioning, ensuring that what players see matches design intentions.

### Event Simulation and Interaction

Games exist through player interaction, yet testing this interaction proves challenging without proper tools. GDSentry provides comprehensive event simulation capabilities, enabling developers to test input handling, button interactions, and user interface responses under controlled conditions.

### Physics Validation

Physics behavior drives much of the gameplay experience in action-oriented games. GDSentry supports collision detection testing, force application validation, and physics state verification, ensuring consistent and predictable game physics across different scenarios.

### Performance Monitoring

Performance directly impacts player experience and technical requirements. GDSentry enables continuous monitoring of frame rates, memory usage, and object counts, helping developers identify performance bottlenecks before they affect players.

### Integration Testing

Complex systems emerge from the interaction of multiple components. GDSentry supports integration testing that validates cross-system interactions, ensuring that individual components work together as intended within the larger game architecture.

### Accessibility Validation

Inclusive game design requires attention to accessibility considerations. GDSentry includes validation tools for UI element accessibility, helping developers create games that work well for players with diverse needs and abilities.

## Design Philosophy

GDSentry's design philosophy emerges from recognizing that game development testing requires fundamentally different approaches than traditional software testing. The framework embraces five core principles that guide its development and usage:

### Project Independence

GDSentry operates without dependencies on specific game mechanics or project structures. This independence ensures that the framework remains useful across diverse Godot projects, from simple prototypes to complex commercial games.

### Comprehensive Validation

Rather than focusing narrowly on code correctness, GDSentry validates the complete player experience. This includes visual presentation, interactive behavior, performance characteristics, and system integration, ensuring that all aspects of gameplay work as intended.

### Developer Experience

The framework prioritizes practical usability through clean APIs, comprehensive documentation, and real-world examples. Developers should find GDSentry intuitive to adopt and powerful to use, minimizing the learning curve while maximizing testing effectiveness.

### Performance Consciousness

Game development demands attention to performance constraints that traditional software often ignores. GDSentry maintains minimal overhead while supporting headless execution, ensuring that testing doesn't interfere with development workflow or runtime performance.

### Extensibility Foundation

GDSentry's plugin architecture enables customization for specific project needs. Teams can extend the framework with custom test types, specialized assertions, and project-specific validation logic, adapting GDSentry to their unique requirements.

## Getting Started

### Basic Testing Patterns

GDSentry provides familiar testing patterns adapted for Godot's unique architecture. The framework supports multiple testing approaches, each suited to different aspects of game validation.

Traditional unit testing validates core game logic and calculations. Developers create test instances of game objects, set up specific scenarios, and verify that calculations and state changes occur as expected.

```c++
# Basic unit test
extends GDSentry.SceneTreeTest

func run_test_suite() -> void:
    run_test("test_calculator_addition", func(): return test_calculator_addition())

func test_calculator_addition() -> bool:
    var calc = Calculator.new()
    var result = calc.add(2, 3)
    return assert_equals(result, 5)
```

### Visual Validation

Visual testing ensures that what players see matches design intentions. GDSentry enables verification of UI element positioning, visibility states, and layout consistency across different screen configurations.

```c++
# Visual test
extends GDSentry.Node2DTest

func run_test_suite() -> void:
    run_test("test_ui_layout", func(): return test_ui_layout())

func test_ui_layout() -> bool:
    var menu = load_test_scene("res://scenes/ui/main_menu.tscn")
    var button = find_node_by_type(menu, Button)

    return assert_visible(button) and assert_position(button, Vector2(100, 100), 5.0)
```

### Interactive Testing

Event simulation enables testing of user interactions and system responses. Developers can simulate mouse clicks, keyboard input, and other user actions to validate that the game responds appropriately.

```c++
# Interactive test
extends GDSentry.Node2DTest

func run_test_suite() -> void:
    run_test("test_button_interaction", func(): return test_button_interaction())
```

### Performance and Load Testing

GDSentry provides comprehensive performance testing capabilities including stress simulation for load testing scenarios.

```gdscript
# Performance test with load testing
extends GDSentry.PerformanceTest

func run_test_suite() -> void:
    run_test("test_game_performance_under_load", func(): return await test_game_performance_under_load())

func test_game_performance_under_load() -> bool:
    var success = true

    # Create memory stress to simulate heavy data processing
    await simulate_performance_scenario("memory_stress")

    # Create CPU stress to simulate complex calculations
    await simulate_performance_scenario("cpu_stress")

    # Test that performance remains acceptable under load
    success = success and await assert_fps_above(30, 1.0)
    success = success and await assert_memory_usage_less_than(200.0)

    # Clean up and verify recovery
    await simulate_performance_scenario("frame_stress")  # Additional frame stress
    success = success and await assert_fps_stable(60, 5.0, 0.5)

    return success
```

## Quick Start Guide

### Installation

```bash
# Copy GDSentry to your Godot project
cp -r gdsentry/ your-project/

# Run tests
./gdsentry/run_examples.sh

# Run with advanced options
godot --script gdsentry/core/test_runner.gd --discover --verbose

# Run GDSentry self-tests
./gdsentry/gdsentry-self-test/gdsentry-self-test.sh
```

### Test Organization

```zsh
your_project/
├── gdsentry/           # GDSentry framework
├── tests/
│   ├── unit/         # SceneTreeTest classes
│   ├── visual/       # Node2DTest classes
│   ├── integration/  # Integration tests
│   └── performance/  # Performance tests
└── scripts/          # Your game scripts
```

## Technical Architecture

GDSentry's architecture reflects its comprehensive approach to game testing. The framework organizes functionality into logical modules that work together to provide complete testing coverage.

### Core Framework Components

The core module contains fundamental testing infrastructure that other modules build upon. This includes base test execution, result collection, and framework initialization logic.

### Base Test Classes

Abstract base classes define common testing patterns and interfaces. These classes establish the foundation for different test types while ensuring consistent behavior across the framework.

### Assertion Libraries

Custom assertion methods extend beyond basic equality checks to support game-specific validation needs. These assertions handle visual comparisons, physics validation, and performance verification.

### Result Reporting

Comprehensive reporting capabilities provide detailed test results in multiple formats. Developers can integrate results with CI/CD pipelines, generate documentation, or analyze test trends over time.

### Utility Functions

Helper utilities simplify common testing tasks and reduce boilerplate code. These utilities handle scene loading, node finding, and other repetitive testing operations.

### Specialized Test Types

Domain-specific test classes address particular testing needs within game development. Each test type provides specialized methods and assertions for its target domain.

### Example Projects

Practical examples demonstrate GDSentry usage across different scenarios. These examples serve as starting points for developers learning the framework and reference implementations for common testing patterns.

### Documentation Resources

Comprehensive documentation supports effective framework usage. Guides, API references, and best practices help developers maximize GDSentry's capabilities within their projects.

```zsh
gdsentry/
├── core/                    # Core framework components
├── base_classes/           # Abstract test base classes
├── assertions/            # Custom assertion libraries
├── reporters/             # Test result reporting
├── utilities/             # Helper utilities
├── test_types/            # Specialized test types
├── examples/              # Example tests and projects
└── docs/                  # Documentation
```

---

*Effective testing frameworks don't just validate code - they validate the experience. GDSentry transforms testing from a technical necessity into a creative enabler, ensuring that every code change serves the player's journey.*
