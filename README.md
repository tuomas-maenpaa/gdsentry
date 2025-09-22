# GDSentry - Advanced Godot Testing Framework

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Godot 4.x](https://img.shields.io/badge/Godot-4.x-blue.svg)](https://godotengine.org/)
[![Godot 3.5+](https://img.shields.io/badge/Godot-3.5+-blue.svg)](https://godotengine.org/)
[![Project Status](https://img.shields.io/badge/Status-Hobby%20Project-orange.svg)](https://github.com/tuomas-maenpaa/gdsentry)
[![Documentation](https://img.shields.io/badge/docs-ready-green.svg)](#documentation--resources)

> **⚠️ Hobby Project** - This is a hobby project. Not actively maintained. Use at your own risk. No support provided at tbe moment.
>
> **📄 License Note**: MIT License with commercial attribution requirements. See LICENSE file for details.

GDSentry is comprehensive testing framework for Godot game development, enabling developers to validate game logic, visual presentation, user interactions, physics behavior, and performance characteristics through a unified, extensible platform. Built specifically for Godot's scene-based architecture, it supports headless testing for CI/CD pipelines while providing intuitive APIs for development workflows.

## Overview

GDSentry represents a fundamental shift in how developers approach testing within the Godot ecosystem. Traditional testing frameworks focus narrowly on unit testing, but GDSentry recognizes that game development demands comprehensive validation across multiple dimensions. Through its project-agnostic design, GDSentry enables developers to validate not just code logic, but also visual presentation, user interaction, physics behavior, and system performance.

This comprehensive approach transforms testing from a compliance activity into an integral part of the development workflow. Developers gain confidence in their code changes while maintaining the creative freedom that makes game development compelling.

## Why Choose GDSentry?

**Comprehensive Game Testing**: Unlike traditional unit testing frameworks that focus solely on code logic, GDSentry validates the complete player experience including visuals, interactions, physics, and performance.

**Godot-Native Integration**: Built specifically for Godot's scene-based architecture, GDSentry understands game objects, signals, and the Godot development workflow - no adaptation layer needed.

**Multi-Paradigm Testing**: Supports unit testing, visual regression testing, performance benchmarking, integration testing, and UI validation all within a single framework.

**CI/CD Ready**: Full headless testing support makes GDSentry perfect for automated testing pipelines, with detailed reporting and artifact generation.

**Extensible Architecture**: Plugin system allows teams to add custom test types, assertions, and validation logic tailored to their specific game requirements.

**Rich Developer Experience**: Intuitive APIs, comprehensive documentation, and practical examples reduce the learning curve while maximizing testing effectiveness.

## Documentation & Resources

- **[📖 Full Documentation](docs/build/html/index.html)** - Complete guides, API reference, and tutorials
- **[🔧 API Reference](docs/build/html/api-reference.html)** - Detailed API documentation
- **[💡 Examples](docs/build/html/examples.html)** - Practical examples and use cases
- **[🚀 Getting Started](docs/build/html/getting-started.html)** - Step-by-step setup guide

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

```gdscript
# Basic unit test
extends SceneTreeTest

func run_test_suite() -> void:
    run_test("test_calculator_addition", func(): return test_calculator_addition())

func test_calculator_addition() -> bool:
    var calc = Calculator.new()
    var result = calc.add(2, 3)
    return assert_equals(result, 5)
```

### Visual Validation

Visual testing ensures that what players see matches design intentions. GDSentry enables verification of UI element positioning, visibility states, and layout consistency across different screen configurations.

```gdscript
# Visual test
extends Node2DTest

func run_test_suite() -> void:
    run_test("test_ui_layout", func(): return test_ui_layout())

func test_ui_layout() -> bool:
    var menu = load_test_scene("res://scenes/ui/main_menu.tscn")
    var button = find_node_by_type(menu, Button)

    return assert_visible(button) and assert_position(button, Vector2(100, 100), 5.0)
```

### Interactive Testing

Event simulation enables testing of user interactions and system responses. Developers can simulate mouse clicks, keyboard input, and other user actions to validate that the game responds appropriately.

```gdscript
# Interactive test
extends Node2DTest

func run_test_suite() -> void:
    run_test("test_button_interaction", func(): return test_button_interaction())

func test_button_interaction() -> bool:
    var button = Button.new()
    button.text = "Click me"
    add_child(button)

    # Simulate a button click
    simulate_click(button)

    # Verify button responded to interaction
    return assert_equals(button.text, "Clicked!")
```

### Performance and Load Testing

GDSentry provides comprehensive performance testing capabilities including stress simulation for load testing scenarios.

```gdscript
# Performance test with load testing
extends PerformanceTest

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
godot --headless --script gdsentry/core/test_runner.gd --discover --verbose

# Run GDSentry self-tests
./gdsentry-self-test/gdsentry-self-test.sh
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

## Compatibility

### Godot Engine Support

| Godot Version | Support Level | Notes |
|---------------|---------------|-------|
| 4.2.x         | ✅ Full       | Complete support for all features |
| 4.1.x         | ✅ Full       | Complete support for all features |
| 4.0.x         | ⚠️ Limited   | Basic testing works, some features may have issues |
| 3.5.x         | ⚠️ Limited   | Basic testing works, visual/UI tests limited |
| 3.4.x and earlier | ❌ Unsupported | Not compatible |

### Platform Support

- **Desktop**: Windows, macOS, Linux ✅
- **Mobile**: Android, iOS ✅
- **Web**: HTML5 ✅
- **Console**: Export testing only ⚠️

### Testing Environment

- **Headless Mode**: ✅ Fully supported (recommended for CI/CD)
- **Editor Mode**: ✅ Supported (for development)
- **Runtime Mode**: ⚠️ Limited (exported games)

### Requirements

- **Godot 4.x** (recommended) or **Godot 3.5+** (limited support)
- **Memory**: 256MB minimum available RAM
- **Storage**: 50MB for framework files

## Features

- **🎯 Comprehensive Testing**: Unit, integration, performance, visual, and UI testing in one framework
- **🔧 Godot Native**: Built specifically for Godot's scene-based architecture
- **⚡ Headless Support**: Perfect for CI/CD pipelines and automated testing
- **📊 Rich Reporting**: Multiple output formats (HTML, JUnit, JSON) with detailed results
- **🔌 Extensible**: Plugin system for custom test types and assertions
- **📖 Well Documented**: Complete documentation with examples and tutorials
- **🚀 Performance**: Minimal overhead, supports performance benchmarking
- **🎮 Multi-Platform**: Works across desktop, mobile, and web platforms

## Contributing

We welcome contributions to GDSentry! Please see our [Contributing Guide](CONTRIBUTING.md) for details on how to get started.

## Community and Support

- **[Code of Conduct](CODE_OF_CONDUCT.md)** - Our community guidelines
- **[Security Policy](SECURITY.md)** - How to report security vulnerabilities
- **[License](LICENSE)** - MIT License with attribution requirements
- **[Changelog](CHANGELOG.md)** - Version history and changes

## Links

- **Documentation**: [Full Documentation](docs/build/html/index.html) (when built)
- **Repository**: <https://github.com/tuomas-maenpaa/gdsentry>
- **Issues**: <https://github.com/tuomas-maenpaa/gdsentry/issues>
- **Discussions**: <https://github.com/tuomas-maenpaa/gdsentry/discussions>

---

*Effective testing frameworks don't just validate code - they validate the experience. GDSentry transforms testing from a technical necessity into a creative enabler, ensuring that every code change serves the player's journey.*
