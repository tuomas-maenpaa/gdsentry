# GDSentry - Advanced Godot Testing Framework

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Godot 4.x](https://img.shields.io/badge/Godot-4.x-blue.svg)](https://godotengine.org/)
[![Godot 3.5+](https://img.shields.io/badge/Godot-3.5+-blue.svg)](https://godotengine.org/)
[![Project Status](https://img.shields.io/badge/Status-Hobby%20Project-orange.svg)](https://github.com/tuomas-maenpaa/gdsentry)

> **⚠️ Hobby Project** - This is a hobby project. Not actively maintained. Use at your own risk. No support provided at the moment.
>
> **📄 License Note**: MIT License with commercial attribution requirements. See LICENSE file for details.

GDSentry is a comprehensive testing framework for Godot game development, enabling developers to validate game logic, visual presentation, user interactions, physics behavior, and performance characteristics through a unified, extensible platform.

## 🚀 Quick Start (5 minutes)

**For Godot developers:** Get started testing your games in under 5 minutes!

1. **[Install GDSentry CLI](docs/installation.rst)** - Set up the testing framework
2. **[Write your first test](docs/user-guide.rst#writing-tests)** - Create test files in your Godot project
3. **[Run tests](docs/quick-reference.rst)** - Execute tests with simple commands

```bash
# Install CLI (one-time setup - recommended for development)
git clone https://github.com/your-org/gdsentry.git
cd gdsentry
conda env create -f environment.yml
conda activate gdsentry
pip install -e .  # Creates 'gdsentry' command

# In your Godot project directory
gdsentry test run     # Run all tests
gdsentry test discover # See available tests
```

## ✨ Why GDSentry?

**🎮 Game-Focused Testing**: Beyond unit tests - validate visuals, physics, UI, and performance
**🔧 Godot-Native**: Built for Godot's scene system, signals, and development workflow
**⚡ Multi-Platform**: Test across architectures (x86_64, ARM64) with container orchestration
**🚀 CI/CD Ready**: Headless testing with detailed reporting for automated pipelines
**🔌 Extensible**: Plugin system for custom test types and game-specific validations
**📚 Well-Documented**: Comprehensive guides and practical examples

## 📚 Documentation & Guides

### For Godot Developers

- **[🔧 Installation](docs/installation.rst)** - Complete installation and setup guide
- **[🚀 Getting Started](docs/getting-started.rst)** - Your first test in 5 minutes
- **[📖 User Guide](docs/user-guide.rst)** - Writing tests, project integration, and workflows
- **[⚡ Quick Reference](docs/quick-reference.rst)** - Common commands and CLI reference
- **[🔧 Advanced Testing](docs/advanced/)** - Visual testing, performance testing, CI/CD integration
- **[⬆️ Migration Guide](docs/migration-guide.rst)** - Upgrading from v1.x to v2.0

### For Contributors

- **[🏗️ Architecture](docs/source/internal/architecture.rst)** - System design and internal structure
- **[🔨 Development Setup](docs/source/internal/implementation/slice-03-cli-framework.rst)** - Contributing to GDSentry
- **[📋 Implementation Details](docs/source/internal/)** - Technical specifications and decisions

### Resources

- **[🧪 Test Types](docs/api/test-classes.rst)** - Available test classes and when to use them
- **[🔍 Assertions](docs/api/assertions.rst)** - Complete assertion reference
- **[⚙️ Configuration](docs/configuration.rst)** - Project configuration options
- **[⚡ Performance](docs/performance.rst)** - CLI performance and optimization
- **[🔧 Troubleshooting](docs/troubleshooting.rst)** - Common issues and solutions

## 🤝 Contributing & Community

We welcome contributions to GDSentry! Please see our [Contributing Guide](CONTRIBUTING.md) for details on how to get started.

### Community Resources

- **[📖 Code of Conduct](CODE_OF_CONDUCT.md)** - Our community guidelines
- **[🔒 Security Policy](SECURITY.md)** - How to report security vulnerabilities
- **[📄 License](LICENSE)** - MIT License with commercial attribution requirements

### Links

- **[🏠 Repository](https://github.com/tuomas-maenpaa/gdsentry)**
- **[🐛 Issues](https://github.com/tuomas-maenpaa/gdsentry/issues)**
- **[💬 Discussions](https://github.com/tuomas-maenpaa/gdsentry/discussions)**

---

*Transforming game testing from an afterthought into a cornerstone of development.*
