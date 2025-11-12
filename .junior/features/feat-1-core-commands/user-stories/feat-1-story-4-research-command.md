# Story 4: Implement /research Command

> **Status:** Not Started
> **Priority:** Medium
> **Dependencies:** None
> **Deliverable:** Working /research command for capturing technical investigations and findings

## User Story

**As a** developer investigating technical questions
**I want** to document research findings systematically
**So that** knowledge is captured and accessible for future decisions

## Scope

**In Scope:**
- Create `.cursor/commands/research.md` command specification
- Contract-first approach: clarify research question → contract → document generation
- Generate research documents in `.junior/research/`
- Filename format: `{date}-{topic}-research.md`
- Template includes: question, context, findings, recommendations, references
- Integration with feature and experiment workflows

**Out of Scope:**
- Automatic web searching or data gathering
- AI-generated research content
- Research versioning or comparison
- Integration with external knowledge bases

## Acceptance Criteria

- [ ] Given a research topic, when user runs `/research`, then clarification questions are asked to understand the investigation
- [ ] Given research contract is approved, when document is generated, then it's created in `.junior/research/` with proper naming
- [ ] Given research document is created, when user opens it, then template includes: research question, context, methodology, findings, recommendations, references
- [ ] Given research is related to a feature, when creating document, then cross-references are included
- [ ] Given research document exists, when user runs `/status`, then it appears in research summary

## Implementation Tasks

- [ ] 4.1 Research `reference-impl/cursor/commands/research.md` for research documentation patterns
- [ ] 4.2 Run `/new-command` with prompt: "Create research command using contract-first approach to capture technical investigations. Clarification loop asks about research question, scope, methodology, and context. Generates comprehensive research document in `.junior/research/` with sections for: question, context, methodology, findings, recommendations, and references. Includes cross-references to related features. Implements feat-1-story-4."
- [ ] 4.3 User review: Run `/research` with sample technical question, verify document generation
- [ ] 4.4 Refine template sections and clarification questions based on usability
- [ ] 4.5 Finalize: Test cross-referencing and integration with `/status`

## Technical Notes

**Command Structure:**

```markdown
# Research Command

## Purpose
Capture technical investigations and findings systematically with contract-first approach.

## Process

### Step 1: Clarification Loop
Ask focused questions:
- "What technical question are you investigating?"
- "What context or constraints should I know about?"
- "How will this research inform decisions (feature planning, architecture, tool selection)?"
- "Are there specific aspects you want to focus on?"

### Step 2: Research Contract
Present contract:
```
## Research Contract

**Research Question:** [Clear, specific question]
**Context:** [Why this matters now]
**Scope:** What's included vs excluded
**Methodology:** [How you'll investigate - testing, reading docs, prototyping]
**Expected Output:** [Findings, recommendations, decision support]

Options: yes | edit: [changes]
```

### Step 3: Document Generation
Create research document at `.junior/research/{date}-{topic}-research.md`

**Template:**
```markdown
# Research: {Topic}

> **Date:** {YYYY-MM-DD}
> **Status:** In Progress / Complete
> **Related:** [Links to features/experiments]

## Research Question

[Clear statement of what you're investigating]

## Context

[Why this research is needed, what decisions it will inform]

## Methodology

[How you approached the investigation]

## Findings

### Key Insights
- [Finding 1]
- [Finding 2]

### Supporting Evidence
[Data, examples, test results]

### Limitations
[What this research doesn't cover]

## Recommendations

[Actionable recommendations based on findings]

## References

- [Documentation links]
- [Related research]
- [Code examples]

## Next Steps

[Follow-up research needed, experiments to run, features to implement]
```
```

**Reference Implementation:**
- Adapt from `reference-impl/cursor/commands/research.md`
- Maintain contract-first approach
- Simplify template while keeping it comprehensive

**Date Handling:**
- Use `02-current-date.mdc` rule
- Run `date +"%Y-%m-%d"` to get current date
- Never hardcode dates

**Testing Strategy:**

**TDD Approach:**
- Write research.md specification
- Test clarification loop with sample questions
- Implement contract presentation and document generation
- Verify cross-references work

**Manual Testing:**
- Run `/research` with technical question
- Answer clarification questions
- Approve contract
- Verify document is created with proper name and structure
- Check that `/status` shows the research

## Definition of Done

- [ ] All tasks completed
- [ ] All acceptance criteria met
- [ ] `/research` command file created at `.cursor/commands/research.md`
- [ ] Clarification loop asks focused questions
- [ ] Research contract is clear and comprehensive
- [ ] Document generation works with proper naming
- [ ] Template includes all necessary sections
- [ ] Cross-references to features/experiments work
- [ ] Date handling follows 02-current-date.mdc rule
- [ ] No regressions in `.junior/` structure
- [ ] Code follows Junior's principles
- [ ] Documentation complete in research.md
- [ ] **User can run /research and generate complete research document**
- [ ] Tested with at least 2 different research topics

