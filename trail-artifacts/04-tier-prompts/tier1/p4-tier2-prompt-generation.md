# Tier 1 - Prompt 4: Tier 2 Prompt Generation

## Context Loading

**Load the following into context:**
- Framework: @[trail-artifacts/02-framework.md] (~2k tokens)
- TRAIL: @[trail-artifacts/PROCESS.md] (~3k tokens)
- Meta-initiation: @[trail-artifacts/00-meta-initiation.md] (for prompt template structure, ~2k tokens)
- Tier 1 Outputs:
  - @[trail-artifacts/05-completed-artifacts/tier1-output/component-topology.md] (~3k tokens)
  - @[trail-artifacts/05-completed-artifacts/tier1-output/design-intent.md] (~3k tokens)
  - @[trail-artifacts/05-completed-artifacts/tier1-output/component-instantiation-summary.md] (~500 tokens)
  - Component files list (metadata only, ~500 tokens)

**Total Estimated Context**: ~14k tokens (within <15k target)

## Objective

Generate comprehensive Tier 2 analysis prompts for each component discovered and instantiated in Tier 1. Each prompt will guide deep architectural analysis of one component, filling its analysis template with assessments across all framework dimensions.

## Instructions

1. **Load Component List**
   - Review component instantiation summary from P3
   - Get list of all component analysis files created
   - Load component metadata from each file

2. **For Each Component, Generate a Tier 2 Prompt**
   - Use the prompt template structure from meta-initiation
   - Customize for the specific component
   - Specify exact codebase files to load
   - Map to all six framework dimensions
   - Target the component's analysis template

3. **Determine Codebase Context for Each Component**
   - Based on P1 topology, specify which source files to load
   - Include the component's main files (~4-6k tokens worth)
   - Include key related files for dependencies
   - Stay within context budget

4. **Customize Instructions for Component Type**
   - CLI components: Focus on command structure, user interaction
   - Core/orchestration: Focus on coordination patterns, state management
   - Integration: Focus on external interfaces, adaptation layers
   - Utilities: Assess if architecturally significant enough for full analysis

5. **Structure Each Prompt**
   - Follow template structure from meta-initiation
   - Include all six framework dimensions
   - Specify evidence requirements
   - Define success criteria
   - Target component's analysis template file

6. **Generate Prompts Efficiently**
   - One prompt per component
   - File naming: `p[N]-[component-name]-analysis.md`
   - Location: `trail-artifacts/04-tier-prompts/tier2/`
   - Number sequence starting from p1

## Output Format

Generate multiple prompt files following this structure:

### Filename Pattern: `trail-artifacts/04-tier-prompts/tier2/p[N]-[component-name]-analysis.md`

**Each file contains**:

```markdown
# Tier 2 - Prompt [N]: [Component Name] Analysis

## Context Loading
**Load the following into context:**
- Framework: `trail-artifacts/02-framework.md` (~2k tokens)
- TRAIL: `trail-artifacts/PROCESS.md` (~3k tokens)
- Component Template: `trail-artifacts/05-completed-artifacts/tier1-output/components/[component-name]-analysis.md` (~1k tokens)
- Tier 1 Context:
  - Component topology: `trail-artifacts/05-completed-artifacts/tier1-output/component-topology.md` (relevant sections, ~1k tokens)
  - Design intent: `trail-artifacts/05-completed-artifacts/tier1-output/design-intent.md` (relevant sections, ~1k tokens)
- Codebase:
  - [Specific files for this component, ~4-6k tokens]
  - [Related dependency files if needed, ~1-2k tokens]
- Documentation:
  - [Relevant doc sections for this component, ~1k tokens]

**Total Estimated Context**: ~14k tokens (target: <15k)

## Objective

Comprehensively analyze the [Component Name] component against all six framework dimensions. Fill the component's analysis template with evidence-based assessments, identifying architectural strengths, concerns, and documentation gaps.

## Instructions

1. **Review Framework & Context**
   - Load assessment framework and understand dimensions
   - Review component metadata from Tier 1
   - Load documented intent for this component (if available)

2. **Analyze Against Each Dimension**
   
   **Boundary Definition**:
   - Examine component boundaries and separation from others
   - Assess explicit vs. implicit boundaries
   - Check for boundary violations or leakage
   - Evaluate dependency explicitness
   
   **Responsibility Clarity**:
   - Identify component's actual responsibilities from code
   - Compare with documented purpose (if available)
   - Assess scope appropriateness
   - Check for responsibility drift or overlap
   
   **Pattern Consistency**:
   - Identify design patterns used
   - Compare with patterns in other components
   - Assess pattern appropriateness
   - Check for pattern misapplication
   
   **Documentation Alignment**:
   - Compare implementation with documented intent
   - Check interface documentation
   - Assess design decision documentation
   - Identify undocumented behaviors
   
   **Interface Design**:
   - Identify public interfaces and contracts
   - Assess API surface appropriateness
   - Check interface stability considerations
   - Evaluate abstraction quality
   
   **Coupling & Dependencies**:
   - Map component dependencies (imports, calls)
   - Assess coupling level and appropriateness
   - Check for circular dependencies
   - Evaluate dependency direction

3. **Document Dependencies**
   - List all outbound dependencies (what this depends on)
   - List inbound dependencies (what depends on this)
   - Categorize: Import, Inheritance, Composition, etc.
   - Provide evidence with file:function references

4. **Document Key Interfaces**
   - Identify primary public interfaces
   - Document purpose and contracts
   - Assess stability and versioning
   - Provide evidence with file:class.method references

5. **Synthesize Findings**
   - Identify 2-4 key architectural strengths
   - Identify 2-4 key architectural concerns
   - Note documentation gaps
   - Raise questions for Tier 3 cross-component analysis

## Output Format

Fill the component analysis template at:
`trail-artifacts/05-completed-artifacts/tier1-output/components/[component-name]-analysis.md`

Update these sections:

### Architecture Assessment Table
| Dimension | Rating | Evidence | Filled By |
|-----------|--------|----------|----------|
| Boundary Definition | [Rating] | [file:function citations] | Tier 2 - P[N] |
| Responsibility Clarity | [Rating] | [file:function citations] | Tier 2 - P[N] |
| Pattern Consistency | [Rating] | [file:function citations] | Tier 2 - P[N] |
| Documentation Alignment | [Rating] | [doc references] | Tier 2 - P[N] |
| Interface Design | [Rating] | [file:class.method citations] | Tier 2 - P[N] |
| Coupling & Dependencies | [Rating] | [file:function citations] | Tier 2 - P[N] |

### Dependencies Section
- List with file:function references
- Categorize by type
- Note direction (inbound/outbound)

### Key Interfaces Section
- Interface name and purpose
- Contract description
- Stability assessment
- Evidence: file:class.method

### Findings Sections
- **Strengths**: 2-4 items with evidence
- **Concerns**: 2-4 items with evidence and severity
- **Documentation Gaps**: Specific gaps with impact

### Questions for Tier 3
- Cross-component questions
- Integration concerns
- Patterns needing system-wide investigation

Also update Metadata:
- Analysis Tier: "Tier 2 - Detailed Analysis"
- Last Updated: [Current date]

## Template Filling

**Target Template**: `trail-artifacts/05-completed-artifacts/tier1-output/components/[component-name]-analysis.md`

**Sections to Fill**:
- Architecture Assessment (all six dimensions)
- Dependencies
- Key Interfaces
- Findings > Strengths
- Findings > Concerns
- Findings > Documentation Gaps
- Questions for Tier 3
- Metadata update

## Generate Next-Tier Prompts

**Does NOT generate Tier 3 prompts** - Tier 3 prompts will be generated after all Tier 2 analyses complete, based on cross-cutting concerns discovered.

## Success Criteria

- [ ] All six framework dimensions assessed with ratings
- [ ] Each rating supported by concrete evidence (file:function references)
- [ ] Dependencies mapped with references
- [ ] Key interfaces documented with contracts
- [ ] 2-4 strengths identified with evidence
- [ ] 2-4 concerns identified with evidence and severity
- [ ] Documentation gaps explicitly noted
- [ ] Questions for Tier 3 raised if applicable
- [ ] Component template fully populated (no [TBD] in analysis sections)
- [ ] Analysis stays at architectural level (not code-quality nitpicks)

## Evidence Requirements

- **Code citations**: `file:function` or `file:class.method` format
- **Documentation citations**: Specific doc sections or `[No documentation found]`
- **Concrete examples**: Specific instances, not generalizations
- **Multiple references**: Support patterns with multiple citations

## Notes

[Add component-specific notes based on P1/P2 findings]
- [Any special considerations for this component]
- [Known concerns from Tier 1 to investigate]
- [Alignment issues to explore]
```

### Generation Summary

Also create: `trail-artifacts/04-tier-prompts/tier2/generation-summary.md`

**Content**:
- List of all Tier 2 prompts generated
- Prompt ID, component name, and file name
- Total count
- Execution order recommendation (if any dependencies between components)

## Template Filling

**Target Template**: None (generates prompts, not analysis)

**Output Location**: `trail-artifacts/04-tier-prompts/tier2/`

## Generate Next-Tier Prompts

**YES - This prompt generates ALL Tier 2 prompts**

**Number of Prompts**: One per component (likely 6-12 prompts based on P3 output)

**Naming Convention**: `tier2/p[N]-[component-name]-analysis.md`

## Success Criteria

- [ ] One Tier 2 prompt generated per component from P3
- [ ] Each prompt follows template structure from meta-initiation
- [ ] Context specifications are specific and within budget
- [ ] All six framework dimensions included in each prompt
- [ ] Evidence requirements consistent across prompts
- [ ] Component-specific customization where appropriate
- [ ] Generation summary created with execution guidance
- [ ] Ready for Tier 2 execution phase

## Evidence Requirements

- **Component names**: Consistent with P1/P3
- **File paths**: Accurate source paths for codebase loading
- **Context budgets**: Realistic token estimates
- **Template references**: Correct paths to component analysis files

## Notes

- This is the key transition from discovery (Tier 1) to analysis (Tier 2)
- Each Tier 2 prompt should be independently executable
- Prompts can be executed in parallel or sequence
- Customize instructions based on component type and P1/P2 findings
- Ensure context budgets are realistic (test with sample files if needed)
