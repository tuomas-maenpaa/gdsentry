# Tier 2 - Prompt 14: Tier 3 Prompt Generation

## Context Loading

**Load the following into context:**
- Framework: @[trail-artifacts/02-framework.md] (~2k tokens)
- TRAIL Structure: @[trail-artifacts/01-TRAIL.md] (~1k tokens)
- Tier 2 Checkpoint Reports:
  - @[trail-artifacts/05-completed-artifacts/tier2-output/p03a-checkpoint-report.md] (if exists, ~1k tokens)
  - @[trail-artifacts/05-completed-artifacts/tier2-output/p13a-final-checkpoint.md] (~3k tokens)
- Tier 1 Context (for reference):
  - @[trail-artifacts/05-completed-artifacts/tier1-output/component-topology.md] (topology, ~2k tokens)
  - @[trail-artifacts/05-completed-artifacts/tier1-output/design-intent.md] (intent, ~2k tokens)
- Summary of All Component Analyses (synthesize from checkpoint reports, ~3k tokens)

**Total Estimated Context**: ~14k tokens (within <15k target)

## Objective

Generate all Tier 3 prompts based on patterns, concerns, and cross-cutting questions discovered during Tier 2 component analyses. Following the meta-pattern established by Tier 1 P4, this prompt creates the synthesis machinery for Tier 3.

## Meta-Pattern Note

**This prompt implements the Tier Cascading Meta-Pattern:**
- Tier 1 P4 generated Tier 2 prompts → This prompt (Tier 2 P14) generates Tier 3 prompts
- Each tier's final prompt generates the next tier's prompts based on discoveries from current tier
- Ensures gravity-driven cascading where each tier informs the next

## Instructions

### 1. Review Tier 2 Findings

Load and analyze the p13a final checkpoint report to extract:
- **Cross-cutting questions** identified across 13 component analyses
- **Systemic patterns** (positive and concerning) found across components
- **Top architectural concerns** ranked by severity and frequency
- **Documentation gaps** that need synthesis
- **Integration points** that need analysis
- **Critical boundaries** that need detailed investigation

### 2. Synthesize Tier 3 Themes

Based on Tier 2 findings, identify 2-4 major synthesis themes:
- Integration patterns (e.g., Python-GDScript boundary, reporter coordination)
- Systemic architectural patterns (e.g., consistency across layers, design pattern application)
- Documentation alignment (e.g., documented vs. actual architecture)
- Architectural debt (e.g., systemic issues, missing components)

### 3. Generate Tier 3 Prompts

Create 3 Tier 3 prompts following the structure defined in TRAIL.md:

#### Tier 3 Prompt 1: Integration Analysis

**File**: `04-tier-prompts/tier3/p1-integration-analysis.md`

**Purpose**: Analyze cross-cutting integration patterns discovered in Tier 2

**Key Focus Areas** (customize based on Tier 2 findings):
- Python-GDScript boundary communication (if flagged in Tier 2)
- Reporter coordination (if dual system identified in Tier 2)
- Configuration propagation (if raised in multiple components)
- Plugin system integration (if architectural concern in Tier 2)
- Test discovery consistency (if cross-layer coordination unclear)

**Context to Load**:
- Framework, TRAIL
- All 13 component analyses (focus on Dependencies, Interfaces, Questions for Tier 3)
- Integration analysis template
- Specific files for critical boundaries (based on Tier 2 citations)

**Output**: Completed integration analysis template
- Data flow diagrams (text/markdown)
- Integration point documentation
- Boundary analysis
- Cross-cutting concerns

#### Tier 3 Prompt 2: Systemic Patterns Analysis

**File**: `04-tier-prompts/tier3/p2-systemic-patterns.md`

**Purpose**: Identify and document systemic architectural patterns across all components

**Key Focus Areas** (customize based on Tier 2 findings):
- Documentation vs. reality (where documented architecture diverges from implementation)
- Pattern consistency (where design patterns are consistently applied or violated)
- Component organization (whether components are appropriately organized)
- Architectural debt (systemic issues affecting multiple components)
- Layer cohesion (Python layer vs. GDScript layer consistency)

**Context to Load**:
- Framework, TRAIL
- All 13 component analyses (focus on Findings, Patterns)
- Synthesis template (systemic patterns section)
- Checkpoint reports (pattern summaries)

**Output**: Systemic patterns document
- Documentation alignment analysis
- Pattern consistency assessment
- Architectural debt matrix
- Systemic strengths and weaknesses

#### Tier 3 Prompt 3: Executive Summary

**File**: `04-tier-prompts/tier3/p3-executive-summary.md`

**Purpose**: Synthesize all findings into actionable executive summary with recommendations

**Key Focus Areas** (customize based on Tier 2 priorities):
- Top 5-10 architectural findings (from Tier 2 concerns)
- Critical recommendations (based on systemic issues)
- Architecture maturity assessment (based on dimension ratings)
- Implementation roadmap (based on architectural debt)

**Context to Load**:
- Framework, TRAIL
- All Tier 2 outputs (component analyses)
- Integration analysis (P1 output)
- Systemic patterns (P2 output)
- Synthesis template (executive summary sections)

**Output**: Completed executive summary
- Overview of findings
- Key architectural insights
- Prioritized recommendations
- Architecture health scorecard

### 4. Customize Based on Tier 2 Discoveries

For each Tier 3 prompt, ensure:
- **Context sections** reference actual Tier 2 findings
- **Focus areas** target real concerns discovered (not hypothetical)
- **Questions** from Tier 2 are mapped to appropriate Tier 3 prompts
- **Evidence** requirements specify files/functions from Tier 2 citations
- **Success criteria** reflect actual synthesis goals

### 5. Generate Tier 3 Execution Summary

Create `04-tier-prompts/tier3/generation-summary.md` documenting:
- All 3 Tier 3 prompts created
- Mapping of Tier 2 concerns to Tier 3 prompts
- Execution order (P1 → P2 → P3 sequential)
- Dependencies (P2 requires P1, P3 requires P1+P2)
- Expected synthesis outcomes
- Estimated effort per prompt

## Output Format

Create the following files in `trail-artifacts/04-tier-prompts/tier3/`:

1. `p1-integration-analysis.md` - Integration patterns prompt
2. `p2-systemic-patterns.md` - Systemic analysis prompt
3. `p3-executive-summary.md` - Executive synthesis prompt
4. `generation-summary.md` - Tier 3 execution guide

Each prompt should follow this structure:

```markdown
# Tier 3 - Prompt [N]: [Title]

## Context Loading
[Specific files and artifacts to load]

## Objective
[Clear synthesis objective based on Tier 2 findings]

## Instructions
[Detailed analysis instructions]

### 1. [Major Analysis Task]
[Instructions]

### 2. [Major Analysis Task]
[Instructions]

[Continue...]

## Output Format
[Template to fill and output format]

## Success Criteria
- [ ] [Specific success criterion]
- [ ] [Specific success criterion]
[...]

## Notes from Tier 2
[Key findings from Tier 2 that inform this prompt]
```

## Success Criteria

- [ ] All 3 Tier 3 prompts created
- [ ] Each prompt customized based on actual Tier 2 findings (not generic)
- [ ] Context loading specifications are realistic (~14k tokens per prompt)
- [ ] Critical concerns from Tier 2 are mapped to appropriate Tier 3 prompts
- [ ] Cross-cutting questions from Tier 2 are addressed in Tier 3 prompts
- [ ] Generation summary provides clear execution guidance
- [ ] Prompts follow established structure and quality standards
- [ ] Integration points identified in Tier 2 are targeted for analysis
- [ ] Systemic patterns from checkpoint reports are incorporated

## Notes

- This prompt implements the **Tier Cascading Meta-Pattern**: Last prompt of tier N generates tier N+1 prompts
- Tier 3 is **convergence phase** - prompts should synthesize, not diverge
- Each Tier 3 prompt should reference specific Tier 2 findings (use checkpoint reports)
- P1 and P2 should be analytical, P3 should be narrative/synthesis
- No Tier 4 prompts needed - P3 is terminal (final outcomes)

---

**Execute this prompt after p13a-final-checkpoint confirms Tier 2 is complete and GO for Tier 3.**
