"""Test template generation."""

from pathlib import Path
from typing import Literal, Optional

from gdsentry.core.exceptions import GDSentryError


class TemplateError(GDSentryError):
    """Raised when template generation fails."""

    pass


class TemplateGenerator:
    """
    Generates GDScript test files from templates.

    Supports:
    - Unit tests
    - Integration tests
    - Performance tests
    - Scene tests
    """

    def __init__(self, base_root: Path):
        """
        Initialize template generator.

        Args:
            base_root: Base directory for template generation directory
        """
        self.base_root = base_root

    def generate_test(
        self,
        name: str,
        test_type: Literal["unit", "integration", "performance", "scene"] = "unit",
        base_class: str = "GDTest",
        output_dir: Optional[Path] = None,
    ) -> Path:
        """
        Generate a test file from template.

        Args:
            name: Test name (e.g., "player_movement")
            test_type: Type of test
            base_class: Base test class to extend
            output_dir: Output directory (defaults to tests/{test_type}/)

        Returns:
            Path to generated test file

        Raises:
            TemplateError: If generation fails
        """
        # Determine output directory
        if output_dir is None:
            output_dir = self.base_root / "tests" / test_type

        output_dir.mkdir(parents=True, exist_ok=True)

        # Create test file name
        test_file = output_dir / f"{name}_test.gd"

        if test_file.exists():
            raise TemplateError(f"Test file already exists: {test_file}")

        # Generate content
        content = self._get_template_content(name, test_type, base_class)

        # Write file
        test_file.write_text(content)

        return test_file

    def _get_template_content(
        self, name: str, test_type: str, base_class: str
    ) -> str:
        """Get template content for test type."""
        # Convert snake_case to PascalCase for class name
        class_name = "".join(word.capitalize() for word in name.split("_"))

        if test_type == "unit":
            return self._unit_test_template(name, class_name, base_class)
        elif test_type == "integration":
            return self._integration_test_template(name, class_name, base_class)
        elif test_type == "performance":
            return self._performance_test_template(name, class_name, base_class)
        elif test_type == "scene":
            return self._scene_test_template(name, class_name, base_class)
        else:
            raise TemplateError(f"Unknown test type: {test_type}")

    def _unit_test_template(
        self, name: str, class_name: str, base_class: str
    ) -> str:
        """Generate unit test template."""
        return f"""# {class_name} Unit Test
# Unit tests for {name} functionality

extends {base_class}

class_name {class_name}Test

# ------------------------------------------------------------------------------
# TEST METADATA
# ------------------------------------------------------------------------------
func _ready() -> void:
\ttest_description = "Unit tests for {name}"
\ttest_tags = ["unit", "{name}"]
\ttest_priority = "high"
\ttest_category = "unit"

# ------------------------------------------------------------------------------
# SETUP / TEARDOWN
# ------------------------------------------------------------------------------
func setup() -> void:
\t\"\"\"Setup before each test\"\"\"
\tpass

func teardown() -> void:
\t\"\"\"Cleanup after each test\"\"\"
\tpass

# ------------------------------------------------------------------------------
# TEST SUITE
# ------------------------------------------------------------------------------
func run_test_suite() -> void:
\t\"\"\"Run all unit tests\"\"\"
\trun_test("test_initialization", func(): return test_initialization())
\trun_test("test_basic_functionality", func(): return test_basic_functionality())
\trun_test("test_edge_cases", func(): return test_edge_cases())

# ------------------------------------------------------------------------------
# INDIVIDUAL TESTS
# ------------------------------------------------------------------------------
func test_initialization() -> bool:
\t\"\"\"Test initialization and setup\"\"\"
\t# TODO: Add your test implementation
\treturn true

func test_basic_functionality() -> bool:
\t\"\"\"Test basic functionality\"\"\"
\t# TODO: Add your test implementation
\treturn true

func test_edge_cases() -> bool:
\t\"\"\"Test edge cases and error handling\"\"\"
\t# TODO: Add your test implementation
\treturn true
"""

    def _integration_test_template(
        self, name: str, class_name: str, base_class: str
    ) -> str:
        """Generate integration test template."""
        return f"""# {class_name} Integration Test
# Integration tests for {name} system integration

extends {base_class}

class_name {class_name}IntegrationTest

# ------------------------------------------------------------------------------
# TEST METADATA
# ------------------------------------------------------------------------------
func _ready() -> void:
\ttest_description = "Integration tests for {name}"
\ttest_tags = ["integration", "{name}", "system"]
\ttest_priority = "medium"
\ttest_category = "integration"

# ------------------------------------------------------------------------------
# SETUP / TEARDOWN
# ------------------------------------------------------------------------------
func setup() -> void:
\t\"\"\"Setup integration test environment\"\"\"
\tpass

func teardown() -> void:
\t\"\"\"Cleanup integration test environment\"\"\"
\tpass

# ------------------------------------------------------------------------------
# TEST SUITE
# ------------------------------------------------------------------------------
func run_test_suite() -> void:
\t\"\"\"Run all integration tests\"\"\"
\trun_test("test_component_integration", func(): return test_component_integration())
\trun_test("test_data_flow", func(): return test_data_flow())
\trun_test("test_system_interaction", func(): return test_system_interaction())

# ------------------------------------------------------------------------------
# INDIVIDUAL TESTS
# ------------------------------------------------------------------------------
func test_component_integration() -> bool:
\t\"\"\"Test component integration\"\"\"
\t# TODO: Add your integration test
\treturn true

func test_data_flow() -> bool:
\t\"\"\"Test data flow between components\"\"\"
\t# TODO: Add your integration test
\treturn true

func test_system_interaction() -> bool:
\t\"\"\"Test system-level interactions\"\"\"
\t# TODO: Add your integration test
\treturn true
"""

    def _performance_test_template(
        self, name: str, class_name: str, base_class: str
    ) -> str:
        """Generate performance test template."""
        return f"""# {class_name} Performance Test
# Performance and benchmark tests for {name}

extends {base_class}

class_name {class_name}PerformanceTest

# ------------------------------------------------------------------------------
# TEST METADATA
# ------------------------------------------------------------------------------
func _ready() -> void:
\ttest_description = "Performance tests for {name}"
\ttest_tags = ["performance", "{name}", "benchmark"]
\ttest_priority = "low"
\ttest_category = "performance"

# ------------------------------------------------------------------------------
# TEST SUITE
# ------------------------------------------------------------------------------
func run_test_suite() -> void:
\t\"\"\"Run all performance tests\"\"\"
\trun_test("test_execution_time", func(): return test_execution_time())
\trun_test("test_memory_usage", func(): return test_memory_usage())
\trun_test("test_scalability", func(): return test_scalability())

# ------------------------------------------------------------------------------
# INDIVIDUAL TESTS
# ------------------------------------------------------------------------------
func test_execution_time() -> bool:
\t\"\"\"Test execution time performance\"\"\"
\tvar start_time = Time.get_ticks_msec()
\t
\t# TODO: Add your performance test code
\t
\tvar end_time = Time.get_ticks_msec()
\tvar duration = end_time - start_time
\t
\tprint("Execution time: ", duration, "ms")
\treturn duration < 1000  # Example threshold

func test_memory_usage() -> bool:
\t\"\"\"Test memory usage\"\"\"
\t# TODO: Add memory profiling
\treturn true

func test_scalability() -> bool:
\t\"\"\"Test scalability under load\"\"\"
\t# TODO: Add scalability test
\treturn true
"""

    def _scene_test_template(
        self, name: str, class_name: str, base_class: str
    ) -> str:
        """Generate scene test template."""
        return f"""# {class_name} Scene Test
# Scene-based tests for {name}

extends SceneTreeTest

class_name {class_name}SceneTest

# ------------------------------------------------------------------------------
# TEST METADATA
# ------------------------------------------------------------------------------
func _ready() -> void:
\ttest_description = "Scene tests for {name}"
\ttest_tags = ["scene", "{name}", "ui"]
\ttest_priority = "medium"
\ttest_category = "scene"

# ------------------------------------------------------------------------------
# SETUP / TEARDOWN
# ------------------------------------------------------------------------------
func setup() -> void:
\t\"\"\"Setup scene test environment\"\"\"
\t# Load and instantiate scene
\tpass

func teardown() -> void:
\t\"\"\"Cleanup scene test environment\"\"\"
\t# Free scene nodes
\tpass

# ------------------------------------------------------------------------------
# TEST SUITE
# ------------------------------------------------------------------------------
func run_test_suite() -> void:
\t\"\"\"Run all scene tests\"\"\"
\trun_test("test_scene_loading", func(): return test_scene_loading())
\trun_test("test_node_hierarchy", func(): return test_node_hierarchy())
\trun_test("test_scene_interactions", func(): return test_scene_interactions())

# ------------------------------------------------------------------------------
# INDIVIDUAL TESTS
# ------------------------------------------------------------------------------
func test_scene_loading() -> bool:
\t\"\"\"Test scene loading and instantiation\"\"\"
\t# TODO: Add scene loading test
\treturn true

func test_node_hierarchy() -> bool:
\t\"\"\"Test node hierarchy and structure\"\"\"
\t# TODO: Add hierarchy test
\treturn true

func test_scene_interactions() -> bool:
\t\"\"\"Test scene interactions and signals\"\"\"
\t# TODO: Add interaction test
\treturn true
"""

