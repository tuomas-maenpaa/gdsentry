# Tier 1 - Prompt 2: Design Intent Extraction

## Context Loading

**Load the following into context:**
- Framework: @[trail-artifacts/02-framework.md] (~2k tokens)
- TRAIL: @[trail-artifacts/PROCESS.md] (~3k tokens)
- Documentation:
  - @[README.md] (~1k tokens)
  - @[docs/source/internal/] architecture documentation (select key files, ~4k tokens)
  - @[CONTRIBUTING.md] (if contains architecture guidance, ~1k tokens)
  - @[docs/source/internal/architecture.rst] (if exists)
  - @[docs/source/internal/implementation/] (overview files)

**Total Estimated Context**: ~11k tokens (within <15k target)

## Objective

Extract documented architectural intent, design decisions, and stated principles from GDSentry's documentation. Identify what the architecture is supposed to be, how components should work, and what design rationale exists. This provides the "intent baseline" for comparing against actual implementation in Tier 2.

## Instructions

1. **Extract Architectural Principles**
   - Review documentation for stated architectural principles or design philosophy
   - Identify guiding patterns (e.g., "plugin-based", "layered", "modular")
   - Note any explicit design goals or non-goals
   - Capture architectural constraints or requirements

2. **Document Component Responsibilities**
   - For each component mentioned in documentation, extract its stated purpose
   - Identify documented interfaces and contracts
   - Note documented interaction patterns between components
   - Capture any component-level design decisions

3. **Identify Documented Patterns**
   - Extract mentioned design patterns (e.g., "Command pattern for CLI", "Strategy pattern for reporters")
   - Document stated architectural layers or boundaries
   - Note documented extension points or plugin mechanisms
   - Identify documented data flow or processing pipelines

4. **Extract Design Rationale**
   - Capture explanations for why certain decisions were made
   - Note any documented trade-offs or alternatives considered
   - Identify documented technical debt or known issues
   - Extract any "lessons learned" or architectural evolution notes

5. **Identify Documentation Gaps**
   - Note which architectural aspects lack documentation
   - Identify components mentioned in code but not in docs
   - Flag inconsistencies within documentation itself
   - Note outdated or incomplete documentation sections

6. **Cross-Reference with Component Topology**
   - Compare documented components with components discovered in P1
   - Note any discrepancies (documented but not implemented, or vice versa)
   - Identify alignment or misalignment early

## Output Format

Produce a structured design intent document:

### 1. Architectural Principles

**Stated Principles**:
- [Principle 1]: [Description]
  - Source: [doc reference]
- [Principle 2]: [Description]
  - Source: [doc reference]

**Design Philosophy**:
[Summary of overall design approach]

**Architectural Style**:
[Documented architectural patterns: layered, plugin-based, event-driven, etc.]

### 2. Component Responsibilities (Documented)

| Component | Documented Purpose | Key Responsibilities | Documentation Source |
|-----------|-------------------|----------------------|---------------------|
| [Component] | [Purpose] | [Responsibilities] | [doc:section] |

### 3. Documented Patterns & Interfaces

**Design Patterns**:
- **[Pattern Name]**: [Where used, purpose]
  - Source: [doc reference]

**Architectural Boundaries**:
- [Boundary description]
- Components involved: [list]
- Source: [doc reference]

**Extension Points**:
- [Extension mechanism]: [Description]
  - Source: [doc reference]

**Key Interfaces**:
- [Interface name]: [Purpose, contract]
  - Source: [doc reference]

### 4. Design Decisions & Rationale

| Decision | Rationale | Trade-offs | Source |
|----------|-----------|------------|--------|
| [Decision] | [Why it was made] | [Alternatives, costs] | [doc:section] |

### 5. Known Issues & Technical Debt

**Documented Issues**:
- [Issue description]
  - Impact: [stated impact]
  - Source: [doc reference]

**Planned Improvements**:
- [Improvement]: [Description]
  - Source: [doc reference]

### 6. Documentation Gaps

**Missing Documentation**:
- [Aspect lacking documentation]
- Expected location: [where it should be]
- Impact: [why this matters]

**Inconsistencies**:
- [Inconsistency description]
- Locations: [doc references]

**Outdated Sections**:
- [Section]: [Why it appears outdated]
- Source: [doc reference]

### 7. Documentation-Topology Alignment

**Documented but Not Found in Code**:
- [Component/Feature]: [Doc reference]

**In Code but Not Documented**:
- [Component/Feature]: [Code location from P1]

**Aligned Components**:
- [Component]: [Both documented and implemented]

## Template Filling

**Target Template**: None (creates foundation data for Tier 2)

**Output Location**: `trail-artifacts/05-completed-artifacts/tier1-output/design-intent.md`

## Generate Next-Tier Prompts

**Does NOT generate Tier 2 prompts** - P4 will generate those after P3 completes.

## Success Criteria

- [ ] All relevant architecture documentation reviewed
- [ ] Architectural principles and philosophy extracted
- [ ] Component responsibilities documented (where available)
- [ ] Design patterns and interfaces captured
- [ ] Design rationale and decisions documented
- [ ] Documentation gaps explicitly identified
- [ ] Alignment with P1 topology assessed
- [ ] Output provides clear "intent baseline" for Tier 2 comparison

## Evidence Requirements

- **Documentation citations**: Specific document and section (e.g., `docs/source/internal/architecture.rst - Section 3.2`)
- **Direct quotes**: Use quotes for key architectural statements
- **Explicit absences**: State `[No documentation found for X]` when gaps exist
- **Cross-references**: Link to P1 topology findings when comparing

## Notes

- Focus on architectural documentation, not user guides or tutorials
- Be explicit about what's stated vs. implied
- Note confidence level (explicit, implied, inferred, missing)
- This is "what should be" - Tier 2 will assess "what is"
- Flag any documentation that contradicts itself
