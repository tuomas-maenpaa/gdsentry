# Changelog

## 2025-10-28

CLI tool for test orchestration. Container-based execution with Podman for isolation 
and reproducibility. Cross-architecture testing support (x86_64 and ARM64) without 
manual configuration.

Python package structure under src/gdsentry/. TOML-based configuration with automatic 
platform detection. Architecture documentation covering design decisions and 
implementation details.

## 2025-09-22

Initial working version. Basic GDScript testing framework with support for different 
test types (unit, integration, performance, visual). Included assertion libraries, 
performance monitoring, and visual regression testing with screenshot comparison. 
Documentation built with Sphinx.

Supported Godot 4.x fully and Godot 3.5+ with limited features.
