# Story 5: Implement /experiment Command

> **Status:** Not Started
> **Priority:** Medium
> **Dependencies:** Story 4 (references research patterns)
> **Deliverable:** Working /experiment command for throwaway validation and "Can we?" investigations

## User Story

**As a** developer validating technical assumptions
**I want** to create structured experiments with throwaway code
**So that** I can answer "Can we?" questions and document findings without cluttering the codebase

## Scope

**In Scope:**
- Create `.cursor/commands/experiment.md` command specification
- Contract-first approach: clarify learning objective → contract → experiment package generation
- Generate experiment specs in `.junior/experiments/exp-N-name/`
- Experiment structure: experiment.md, user-stories/, findings/
- Clear distinction: throwaway code for learning (vs prototype for building)
- User stories for experiment implementation steps
- Findings documentation capturing what was learned

**Out of Scope:**
- Automatic experiment code generation
- Production-quality code expectations
- Long-term maintenance of experiment code
- Experiment-to-feature migration (covered by /prototype)

## Acceptance Criteria

- [ ] Given an experiment idea, when user runs `/experiment`, then clarification questions focus on learning objectives and validation approach
- [ ] Given experiment contract is approved, when package is generated, then it's created in `.junior/experiments/exp-N-name/` with proper structure
- [ ] Given experiment package is created, when user opens it, then it includes experiment.md, user-stories/, and findings/ directories
- [ ] Given experiment has implementation steps, when user stories are generated, then they are action-oriented and focused on learning
- [ ] Given experiment is complete, when findings are documented, then they include what was learned and recommendations
- [ ] Given experiment exists, when user runs `/status`, then it appears in experiments summary

## Implementation Tasks

- [ ] 5.1 Research `reference-impl/cursor/commands/create-experiment.md` for throwaway validation patterns
- [ ] 5.2 Run `/new-command` with prompt: "Create experiment command using contract-first approach for throwaway technical validation. Clarification loop asks about 'Can we?' question, learning objectives, success criteria, and throwaway vs keep decision. Generates experiment package in `.junior/experiments/exp-N-name/` with experiment.md, user-stories/, and findings/ for capturing learnings. Emphasizes that experiments are for learning (often deleted after). Implements feat-1-story-5."
- [ ] 5.3 User review: Run `/experiment` with sample validation question, verify package generation
- [ ] 5.4 Refine template to emphasize throwaway nature and learning focus
- [ ] 5.5 Test findings capture workflow
- [ ] 5.6 Finalize: Verify numbering (exp-1, exp-2) and integration with `/status`

## Technical Notes

**Command Structure:**

```markdown
# Experiment Command

## Purpose
Create structured experiments for throwaway validation and technical learning with contract-first approach.

## Process

### Step 1: Clarification Loop
Ask focused questions:
- "What 'Can we?' question are you trying to answer?"
- "What would success look like - how will you know the experiment worked?"
- "Is this throwaway code for learning, or should it evolve into production?"
- "What's the fastest way to validate this assumption?"
- "Should this experiment integrate with existing codebase or remain separate?"

### Step 2: Experiment Contract
Present contract:
```
## Experiment Contract

**Experiment Name:** [validated-experiment-name]
**Primary Learning Objective:** [What you want to learn/validate]
**Success Criteria:** [How you'll know experiment succeeded or failed]
**Implementation Approach:** [Throwaway/proof-of-concept strategy]

**Scope Boundaries:**
- Will Build: [2-3 key experimental components]
- Will Learn: [2-3 specific questions to answer]
- Won't Build: [2-3 things outside scope]

**Evolution Path:** [How this might inform future work]
**Related Work:** [Research/features this connects to]

Options: yes | edit: [changes] | risks
```

### Step 3: Package Generation
Create directory structure:
```
.junior/experiments/exp-{N}-{name}/
├── experiment.md          # Main experiment doc
├── user-stories/
│   ├── README.md          # Stories for implementation steps
│   └── exp-{N}-story-{M}-{name}.md
└── findings/              # Learning capture
    └── README.md
```

**Experiment.md Template:**
```markdown
# Experiment: {Name}

> **Created:** {Date}
> **Status:** Planning / In Progress / Complete
> **Type:** Throwaway / Proof-of-Concept

## Learning Objective

[What you want to learn]

## Success Criteria

[How you'll validate]

## Hypothesis

[What you expect to find]

## Implementation Approach

[How you'll build the experiment]

## User Stories

See [user-stories/README.md](./user-stories/README.md)

## Findings

See [findings/README.md](./findings/README.md)
```

**Findings Template:**
```markdown
# Experiment Findings

> **Experiment:** {Name}
> **Completed:** {Date}
> **Result:** Success / Failed / Partial

## Summary

[What you learned in 2-3 sentences]

## Detailed Findings

### What Worked
- [Finding 1]

### What Didn't Work
- [Challenge 1]

### Unexpected Insights
- [Surprise 1]

## Recommendations

[What to do next based on learnings]

## Related Work

[Features or research this informs]
```
```

**Reference Implementation:**
- Adapt from `reference-impl/cursor/commands/create-experiment.md`
- Emphasize throwaway nature and learning focus
- Keep user stories focused on experimentation steps

**Numbering:**
- Scan `.junior/experiments/` for existing exp-N-* directories
- Determine next number (exp-1, exp-2, etc.)
- Follow 01-structure.mdc conventions

**Testing Strategy:**

**TDD Approach:**
- Write experiment.md specification
- Test clarification loop with sample "Can we?" questions
- Implement contract presentation and package generation
- Verify structure matches exp-N-name pattern

**Manual Testing:**
- Run `/experiment` with technical validation question
- Answer clarification questions
- Approve contract
- Verify package is created with proper structure
- Check that `/status` shows the experiment
- Test findings documentation workflow

## Definition of Done

- [ ] All tasks completed
- [ ] All acceptance criteria met
- [ ] `/experiment` command file created at `.cursor/commands/experiment.md`
- [ ] Clarification loop focuses on learning objectives
- [ ] Experiment contract emphasizes "Can we?" questions
- [ ] Package generation creates proper exp-N-name structure
- [ ] User stories are action-oriented for experimentation
- [ ] Findings template captures learnings effectively
- [ ] Number detection works correctly
- [ ] No regressions in `.junior/` structure
- [ ] Code follows Junior's principles
- [ ] Documentation complete in experiment.md
- [ ] **User can run /experiment and generate complete experiment package**
- [ ] Tested with at least 2 different experiment types

