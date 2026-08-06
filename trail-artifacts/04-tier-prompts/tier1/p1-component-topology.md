# Tier 1 - Prompt 1: Component Topology Discovery

## Context Loading

**Load the following into context:**
- Framework: @[trail-artifacts/02-framework.md] (~2k tokens)
- TRAIL: @[trail-artifacts/PROCESS.md] (~3k tokens)
- Codebase:
  - Directory structure: @[src/] (recursive listing with file counts)
  - Key files: @[src/gdsentry/__init__.py], @[src/core/__init__.py], @[src/base_classes/__init__.py]
  - Entry point: @[src/gdsentry/cli.py] or main CLI entry (~2k tokens)
- Documentation:
  - @[README.md] (~1k tokens)
  - @[docs/source/internal/architecture.rst] (if exists, ~2k tokens)

**Total Estimated Context**: ~10k tokens (within <15k target)

## Objective

Discover and map GDSentry's major architectural components by analyzing the source directory structure, identifying component boundaries, purposes, and high-level relationships. Create a topology map that will serve as the foundation for Tier 2 component analysis.

## Instructions

1. **Analyze Source Structure**
   - Examine the `/src` directory structure and subdirectories
   - Identify major components based on directory organization
   - Note file counts and relative sizes of each component
   - Identify component purposes from directory names, file names, and brief code inspection

2. **Identify Entry Points**
   - Locate CLI entry points and main execution paths
   - Identify orchestration layers (components that coordinate others)
   - Map the primary user-facing interfaces

3. **Map Component Purposes**
   - For each major component/directory, infer its primary purpose
   - Use package structure, naming conventions, and `__init__.py` files
   - Cross-reference with README and architecture docs when available

4. **Identify High-Level Dependencies**
   - Note which components likely depend on others (based on imports in `__init__.py`)
   - Identify core/foundational components vs. higher-level components
   - Map the general dependency flow (what depends on what)

5. **Identify Extension Mechanisms**
   - Look for plugin systems, plugin directories, or extensibility patterns
   - Note template systems or configuration-driven behaviors
   - Identify hook or callback mechanisms

6. **Create Topology Map**
   - Organize findings into a structured component map
   - Include: component name, location, estimated purpose, key files
   - Visualize or describe dependency relationships

## Output Format

Produce a structured component topology document with the following sections:

### 1. Component Inventory

| Component Name | Location | Est. Size | Primary Purpose (Inferred) | Key Entry Points |
|----------------|----------|-----------|---------------------------|------------------|
| [Name] | src/[path] | [N files] | [Purpose] | [file:function] |

### 2. Component Descriptions

For each component:

**[Component Name]**
- **Location**: `src/[path]`
- **Size**: [N files, estimated LoC if visible]
- **Primary Purpose**: [Detailed purpose description]
- **Key Files**: 
  - `file1.py` - [purpose]
  - `file2.py` - [purpose]
- **Likely Dependencies**: [Other components this depends on]
- **Notes**: [Any architectural observations]

### 3. Entry Points & Orchestration

- **Primary Entry Points**: [CLI commands, main functions]
- **Orchestration Layers**: [Components that coordinate others]
- **User-Facing Interfaces**: [How users interact with the system]

### 4. Dependency Topology

```
[Visualize or describe dependency hierarchy]

Example:
CLI Layer (gdsentry.cli)
  ↓
Orchestration (core)
  ↓
Test Execution (test_types, base_classes)
  ↓
Integration (integration)
  ↓
Reporting (reporters)
```

### 5. Extension Mechanisms

- **Plugin System**: [Description if found]
- **Template System**: [Description if found]
- **Configuration**: [How extensibility is supported]

### 6. Preliminary Observations

- Total components identified: [N]
- Architectural style: [Layered, plugin-based, etc.]
- Key architectural concerns to investigate: [List]

## Template Filling

**Target Template**: None (this creates foundation data for Tier 2)

**Output Location**: `trail-artifacts/05-completed-artifacts/tier1-output/component-topology.md`

## Generate Next-Tier Prompts

**Does NOT generate Tier 2 prompts** - waits for P2 (design intent) and P3 (framework instantiation) to complete first.

## Success Criteria

- [ ] All major source directories analyzed and categorized
- [ ] Component purposes clearly inferred from structure and naming
- [ ] Entry points and orchestration layers identified
- [ ] High-level dependency relationships mapped
- [ ] 6-12 distinct components identified for Tier 2 analysis
- [ ] Extension mechanisms documented if present
- [ ] Output is structured and ready to inform Tier 2

## Evidence Requirements

- **File references**: Use full paths like `src/gdsentry/cli.py` or `src/core/orchestrator.py`
- **Function references**: Use `file:function` format for entry points
- **Directory structure**: Provide actual directory names and file counts
- **Concrete observations**: Base inferences on actual file/directory names, not speculation

## Notes

- Focus on architectural organization, not implementation details
- Aim for 6-12 major components (not every subdirectory is a "component")
- Group related functionality under single component when appropriate
- Be explicit about what's inferred vs. what's documented
- Flag any unclear or ambiguous architectural elements for further investigation
