# GDSentry Architecture Assessment Framework

## Purpose

This framework provides structured dimensions and criteria for evaluating GDSentry's architectural quality. It ensures consistent, evidence-based assessments across all components, focusing on system-level design concerns rather than code-quality details.

The framework supports the Trail of Reasoning assessment process by defining what to evaluate, how to rate findings, and what evidence is required.

---

## Assessment Dimensions

### 1. Boundary Definition

**Definition**: Evaluates whether component boundaries are clear, well-defined, and appropriately separated from other components.

**Key Questions**:
- Are the component's boundaries explicit and enforceable?
- Is there clear separation of concerns between this and other components?
- Are dependencies across boundaries explicit and intentional?
- Does the component avoid leaking implementation details?

**Indicators of Quality**:
- Clear package/module structure with minimal cross-boundary access
- Explicit interfaces for inter-component communication
- Well-defined public API surface with clear internal/external distinction
- Minimal or no circular dependencies

**Common Issues**:
- Blurred boundaries with overlapping responsibilities
- Implicit coupling through shared mutable state
- Leaky abstractions exposing internal details
- Tight coupling disguised as loose coupling

---

### 2. Responsibility Clarity

**Definition**: Evaluates whether the component's role and responsibilities are explicit, well-scoped, and consistently implemented.

**Key Questions**:
- Is the component's primary purpose clear and singular?
- Is the scope appropriate (not too broad, not too narrow)?
- Are responsibilities documented and understood?
- Does implementation align with stated responsibilities?

**Indicators of Quality**:
- Single, clear purpose stated in documentation
- Cohesive functionality within the component
- Reasonable size and complexity for stated purpose
- Consistent implementation of responsibility

**Common Issues**:
- God objects or components doing too much
- Fragmented responsibilities across multiple components
- Undocumented or implicit responsibilities
- Scope creep beyond original intent

---

### 3. Pattern Consistency

**Definition**: Evaluates whether the component follows consistent architectural patterns and design approaches.

**Key Questions**:
- Does it follow established patterns in the codebase?
- Are design patterns appropriate for the problem?
- Is there consistency in how similar problems are solved?
- Are patterns applied correctly and completely?

**Indicators of Quality**:
- Consistent use of architectural patterns across similar components
- Appropriate pattern selection for the problem domain
- Complete and correct pattern implementation
- Recognizable structure that matches established conventions

**Common Issues**:
- Pattern misapplication or incomplete implementation
- Mixing incompatible patterns
- Inconsistency with rest of codebase
- Anti-patterns or pattern abuse

---

### 4. Documentation Alignment

**Definition**: Evaluates how well the implementation matches documented intent, and whether interfaces and decisions are adequately documented.

**Key Questions**:
- Does implementation match what's documented?
- Are interfaces and contracts documented?
- Are architectural decisions explained?
- Are there significant undocumented behaviors?

**Indicators of Quality**:
- Implementation matches documented design
- Public interfaces are documented
- Design rationale is captured
- Deviations from documentation are intentional and noted

**Common Issues**:
- Documentation drift (docs don't match reality)
- Missing interface documentation
- Undocumented design decisions
- Significant behaviors not captured in documentation

---

### 5. Interface Design

**Definition**: Evaluates whether component interfaces are well-defined, stable, and appropriate for their purpose.

**Key Questions**:
- Are interfaces well-defined with clear contracts?
- Is the API surface appropriate (not too large, not too limited)?
- Are interfaces stable and versioned appropriately?
- Do interfaces hide implementation details effectively?

**Indicators of Quality**:
- Clear, minimal, and sufficient public API
- Strong contracts with defined inputs/outputs
- Stable interfaces with backward compatibility consideration
- Effective abstraction hiding implementation

**Common Issues**:
- Overly complex or bloated interfaces
- Insufficient or missing interface definitions
- Unstable APIs that frequently change
- Leaky abstractions exposing implementation

---

### 6. Coupling & Dependencies

**Definition**: Evaluates whether component dependencies are appropriate, manageable, and follow good coupling principles.

**Key Questions**:
- Are dependencies appropriate and necessary?
- Is coupling level appropriate (loose where beneficial)?
- Are circular dependencies avoided?
- Is dependency direction sensible and consistent?

**Indicators of Quality**:
- Minimal necessary dependencies
- Loose coupling through interfaces/abstractions
- No circular dependencies
- Clear dependency hierarchy
- Dependencies on stable abstractions

**Common Issues**:
- Excessive dependencies creating fragile components
- Tight coupling making changes difficult
- Circular dependencies
- Dependency on unstable or concrete implementations

---

## Rating Scale

| Rating | Definition | When to Use |
|--------|------------|-------------|
| **Well-Defined** | Clear, explicit, documented, and consistently implemented | Component fully satisfies dimension criteria with concrete evidence of good practice |
| **Partially-Defined** | Present but incomplete, inconsistent, or unclear in some aspects | Component meets some criteria but has gaps, inconsistencies, or areas of concern |
| **Unclear** | Implicit, poorly defined, or difficult to determine | Component's status on this dimension is ambiguous or hard to assess from available evidence |
| **Missing** | Expected but not present in implementation or documentation | Dimension is relevant but component lacks necessary structure, documentation, or implementation |
| **Not Applicable** | Dimension doesn't apply to this component | Component's nature makes this dimension irrelevant (use sparingly and justify) |

---

## Evidence Requirements

All assessments must be evidence-based with concrete references. Each rating must be supported by:

### Code References

**Format**: `file:function` or `file:class.method`

**Examples**:
- `src/gdsentry/cli.py:main`
- `src/core/orchestrator.py:TestOrchestrator.execute`
- `src/reporters/json_reporter.py:JsonReporter.generate_report`

**Guidelines**:
- Reference specific functions, classes, or methods (not just files)
- Include multiple examples for systemic patterns
- Reference both positive examples and concerns

### Documentation References

**Format**: Specific document and section

**Examples**:
- `docs/source/internal/architecture.rst - CLI Design section`
- `README.md - Architecture Overview`
- `[No documentation found for X]` (explicit absence)

**Guidelines**:
- Reference specific sections, not entire documents
- Note when documentation is missing or unclear
- Compare documented intent with implementation

### Concrete Examples

**Requirements**:
- Specific instances of patterns or deviations
- Description of what was observed
- Impact or significance of the finding

**Example**:
"Circular dependency between CLI and Orchestrator: `cli.py` imports `orchestrator.py` which imports `cli_config.py` which imports back to `cli.py`. Impact: Makes testing difficult and creates fragile coupling."

---

## Application Guidance

### How to Apply This Framework

1. **Load Context**: Review framework, component code, and relevant documentation
2. **Evaluate Each Dimension**: Assess component against all six dimensions
3. **Gather Evidence**: Collect code references and documentation citations
4. **Assign Ratings**: Use rating scale based on evidence
5. **Document Findings**: Record assessments in component template
6. **Identify Patterns**: Note systemic issues for Tier 3 synthesis

### Consistency Across Components

- Apply all six dimensions uniformly
- Use consistent evidence standards
- Compare similar components for relative assessment
- Note where components diverge from norms

### Focus on Architecture

**DO**:
- Focus on system-level design
- Evaluate component interactions
- Assess structural patterns
- Consider maintainability and evolvability

**DON'T**:
- Nitpick variable names or formatting
- Focus on micro-optimizations
- Comment on single-function implementations
- Get distracted by code style issues

---

## Component Assessment Template Structure

This framework maps to component template sections as follows:

| Framework Dimension | Template Section | Filled By |
|---------------------|------------------|-----------|
| All dimensions | Architecture Assessment table | Tier 2 prompts |
| Coupling & Dependencies | Dependencies section | Tier 2 prompts |
| Interface Design | Key Interfaces section | Tier 2 prompts |
| All dimensions (synthesis) | Findings > Strengths | Tier 2 prompts |
| All dimensions (synthesis) | Findings > Concerns | Tier 2 prompts |
| Documentation Alignment | Documentation Gaps | Tier 2 prompts |

Cross-cutting patterns discovered through multiple component assessments feed into Tier 3 integration analysis.

---

## Framework Token Budget

**Estimated size**: ~1,800 tokens

This framework is designed to be loaded with every tier prompt while staying within context budget constraints.
