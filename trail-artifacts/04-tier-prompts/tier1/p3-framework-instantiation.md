# Tier 1 - Prompt 3: Framework Instantiation & Component Template Creation

## Context Loading

**Load the following into context:**
- Framework: @[trail-artifacts/02-framework.md] (~2k tokens)
- TRAIL: @[trail-artifacts/PROCESS.md] (~3k tokens)
- Templates:
  - @[trail-artifacts/03-templates/component-analysis.md] (~800 tokens)
- Tier 1 Outputs:
  - @[trail-artifacts/05-completed-artifacts/tier1-output/component-topology.md] (~3k tokens)
  - @[trail-artifacts/05-completed-artifacts/tier1-output/design-intent.md] (~3k tokens)

**Total Estimated Context**: ~11.8k tokens (within <15k target)

## Objective

Create initial component analysis files for each component discovered in P1, filling in metadata sections with information from P1 and P2. This instantiates the assessment framework with GDSentry-specific context and prepares templates for Tier 2 detailed analysis.

## Instructions

1. **Load Foundation Data**
   - Review component topology from P1 output
   - Review design intent from P2 output
   - Load component analysis template
   - Load assessment framework

2. **Identify Components for Analysis**
   - Use component inventory from P1
   - Filter to major architectural components (aim for 6-12)
   - Exclude trivial utilities or single-purpose helpers unless architecturally significant
   - Prioritize components with clear architectural roles

3. **Create Component Analysis Files**
   - For each identified component, create a new file using the template
   - File naming: `[component-name]-analysis.md` (e.g., `cli-analysis.md`, `core-analysis.md`)
   - Location: `trail-artifacts/05-completed-artifacts/tier1-output/components/`

4. **Fill Metadata Sections**
   - **Component Name**: From P1 topology
   - **Location**: Source path from P1
   - **Primary Purpose**: From P1 inferred purpose + P2 documented purpose (if available)
   - **Analysis Tier**: "Tier 1 - Metadata initialization"
   - **Last Updated**: Current date

5. **Leave Assessment Sections as [TBD]**
   - Architecture Assessment table rows remain [TBD] for Tier 2
   - Dependencies section marked [TBD: Filled by Tier 2]
   - All findings sections remain [TBD] for Tier 2
   - This prompt only fills metadata, not analysis

6. **Add Preliminary Notes (Optional)**
   - If P1 or P2 revealed component-specific concerns, add brief note
   - If documentation-topology misalignment exists, note it
   - These help guide Tier 2 prompt generation

## Output Format

For each component, produce a file structured as:

### Filename: `trail-artifacts/05-completed-artifacts/tier1-output/components/[component-name]-analysis.md`

**Content**:
```markdown
# Component Analysis: [Component Name]

## Metadata
| Field | Value |
|-------|-------|
| Component Name | [From P1] |
| Location | src/[path from P1] |
| Primary Purpose | [From P1 + P2 if available] |
| Analysis Tier | Tier 1 - Metadata initialization |
| Last Updated | [Current date] |

## Architecture Assessment

| Dimension | Rating | Evidence | Filled By |
|-----------|--------|----------|----------|
| Boundary Definition | [TBD] | [TBD] | Tier 2 |
| Responsibility Clarity | [TBD] | [TBD] | Tier 2 |
| Pattern Consistency | [TBD] | [TBD] | Tier 2 |
| Documentation Alignment | [TBD] | [TBD] | Tier 2 |
| Interface Design | [TBD] | [TBD] | Tier 2 |
| Coupling & Dependencies | [TBD] | [TBD] | Tier 2 |

## Dependencies
[TBD: List dependencies with references - Filled by Tier 2]

## Key Interfaces
[TBD: Document primary interfaces - Filled by Tier 2]

## Findings
### Strengths
[TBD: Architectural strengths - Filled by Tier 2]

### Concerns
[TBD: Architectural concerns - Filled by Tier 2]

### Documentation Gaps
[TBD: Missing or misaligned documentation - Filled by Tier 2]

## Questions for Tier 3
[TBD: Questions requiring cross-component analysis - Filled by Tier 2]

## Notes from Tier 1
[Optional: Any preliminary observations from P1/P2 that should guide Tier 2 analysis]
```

### Summary Output

Also create: `trail-artifacts/05-completed-artifacts/tier1-output/component-instantiation-summary.md`

**Content**:
- List of all component files created
- Component names and locations
- Brief note on any components excluded and why
- Count: [N] components ready for Tier 2 analysis

## Template Filling

**Target Templates**: Multiple instances of `component-analysis.md` (one per component)

**Sections Filled**: Metadata only (all analysis sections remain [TBD])

**Output Location**: `trail-artifacts/05-completed-artifacts/tier1-output/components/`

## Generate Next-Tier Prompts

**Does NOT generate Tier 2 prompts** - P4 will do that after this completes.

## Success Criteria

- [ ] All major components from P1 have analysis files created
- [ ] 6-12 component analysis files generated
- [ ] All metadata sections filled with P1/P2 data
- [ ] Analysis sections properly marked [TBD] for Tier 2
- [ ] File naming is consistent and clear
- [ ] Summary document created listing all components
- [ ] Ready for P4 to generate Tier 2 prompts

## Evidence Requirements

- **Component names**: Use clear, consistent names from P1
- **Locations**: Full source paths (e.g., `src/gdsentry/cli.py`)
- **Purpose descriptions**: Combine P1 inference with P2 documentation when available
- **Notes**: Include P1/P2 references if adding preliminary observations

## Notes

- This is infrastructure setup, not analysis
- Focus on creating clean, consistent template instances
- Purpose is to prepare for Tier 2, not to analyze
- All analysis content filled by Tier 2 prompts
- If uncertain about component inclusion, include it (can be skipped in Tier 2 if trivial)
