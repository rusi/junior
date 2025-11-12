# Story 6: Implement /prototype Command

> **Status:** Not Started
> **Priority:** Medium
> **Dependencies:** None (but conceptually follows experiments)
> **Deliverable:** Working /prototype command for building user-facing MVPs that can evolve into production

## User Story

**As a** developer validating product concepts
**I want** to build user-facing prototypes that might become production code
**So that** I can demo features and iterate toward production quality

## Scope

**In Scope:**
- Create `.cursor/commands/prototype.md` command specification
- Contract-first approach: clarify prototype goals → contract → planning
- Generate prototype plan in `.junior/prototypes/proto-N-name/`
- Prototype code lives in actual codebase (not `.junior/`)
- Clear distinction: production-bound code (vs experiment throwaway)
- User stories for iterative prototype development
- Documentation for demo and evaluation

**Out of Scope:**
- Automatic UI generation
- Production-ready code requirements
- Deployment automation
- A/B testing or analytics integration

## Acceptance Criteria

- [ ] Given a prototype idea, when user runs `/prototype`, then clarification questions focus on user-facing value and demo goals
- [ ] Given prototype contract is approved, when plan is generated, then it's created in `.junior/prototypes/proto-N-name/` with documentation
- [ ] Given prototype plan exists, when user implements it, then code lives in actual codebase (e.g., `src/prototypes/`)
- [ ] Given prototype is complete, when user demos it, then there's clear documentation for evaluation and next steps
- [ ] Given prototype evolves to production, when user transitions it, then path from prototype to feature is clear
- [ ] Given prototype exists, when user runs `/status`, then it appears in prototypes summary

## Implementation Tasks

- [ ] 6.1 Research prototype patterns (no direct reference-impl, design from experiment + feature patterns)
- [ ] 6.2 Run `/new-command` with prompt: "Create prototype command using contract-first approach for user-facing MVP/demo builds. Clarification loop asks about user goals, demo scenarios, and evolution path to production. Generates prototype spec in actual codebase (not `.junior/`) with plan.md, user-stories/, and evaluation/ for demo feedback. Code lives in codebase and often becomes production. Emphasizes user-facing and demo quality. Implements feat-1-story-6."
- [ ] 6.3 User review: Run `/prototype` with sample MVP idea, verify spec generation
- [ ] 6.4 Refine to distinguish from experiment (kept not thrown away)
- [ ] 6.5 Test evaluation template for production transition planning
- [ ] 6.6 Finalize: Verify prototype code goes in codebase, not `.junior/`

## Technical Notes

**Command Structure:**

```markdown
# Prototype Command

## Purpose
Build user-facing prototypes and MVPs that can evolve into production with contract-first approach.

## Process

### Step 1: Clarification Loop
Ask focused questions:
- "What user-facing concept are you validating?"
- "Who will use/see this prototype (internal team, customers, stakeholders)?"
- "What's the goal - demo, user testing, proof-of-concept?"
- "How likely is this to become production code?"
- "What's the simplest version that demonstrates the value?"
- "Where in your codebase should prototype code live?"

### Step 2: Prototype Contract
Present contract:
```
## Prototype Contract

**Prototype Name:** [validated-prototype-name]
**User Value:** [What users will experience]
**Demo Scenario:** [How you'll demonstrate this]
**MVP Scope:** [Minimum features for validation]

**Implementation Approach:**
- Code Location: [Where prototype lives in codebase]
- Quality Level: [Demo-quality vs near-production]
- Timeline: [How long to build initial version]

**Evolution Path:**
- If successful: [How it becomes production feature]
- If unsuccessful: [What you'll learn and pivot to]

**Related Work:** [Research/experiments this builds on]

Options: yes | edit: [changes] | simpler
```

### Step 3: Plan Generation
Create directory structure:
```
.junior/prototypes/proto-{N}-{name}/
├── plan.md                # Main prototype plan
├── user-stories/
│   ├── README.md          # Stories for iterative development
│   └── proto-{N}-story-{M}-{name}.md
└── evaluation/            # Demo and feedback
    └── README.md
```

**Plan.md Template:**
```markdown
# Prototype: {Name}

> **Created:** {Date}
> **Status:** Planning / Building / Demo / Production
> **Code Location:** [Path in codebase]

## User Value

[What users will experience]

## Demo Scenario

[Step-by-step demo flow]

## MVP Scope

[Minimum features for validation]

## User Stories

See [user-stories/README.md](./user-stories/README.md)

## Implementation Notes

[Code location, key components, dependencies]

## Evaluation

See [evaluation/README.md](./evaluation/README.md)

## Production Transition

[If successful, steps to productionize this prototype]
```

**Evaluation Template:**
```markdown
# Prototype Evaluation

> **Prototype:** {Name}
> **Demo Date:** {Date}
> **Status:** Pending / Successful / Needs Iteration

## Demo Feedback

[User reactions, questions, concerns]

## What Worked

[Features that resonated]

## What Needs Improvement

[Areas for iteration]

## Decision

- [ ] Evolve to production (create feature with /feature)
- [ ] Iterate on prototype (continue refining)
- [ ] Archive and pivot (learn and move on)

## Next Steps

[Concrete actions based on feedback]
```
```

**Key Distinction from Experiment:**
- **Experiment:** Throwaway code, answer "Can we?", lives in `.junior/experiments/`
- **Prototype:** Production-bound code, answer "Should we?", lives in codebase

**Reference Implementation:**
- Create new command (no direct Code Captain equivalent)
- Follow contract-first patterns from existing commands
- Emphasize user-facing value and evolution path

**Numbering:**
- Scan `.junior/prototypes/` for existing proto-N-* directories
- Determine next number (proto-1, proto-2, etc.)
- Follow 01-structure.mdc conventions

**Testing Strategy:**

**TDD Approach:**
- Write prototype.md specification
- Test clarification loop with user-facing concepts
- Implement contract presentation and plan generation
- Verify structure matches proto-N-name pattern

**Manual Testing:**
- Run `/prototype` with product idea
- Answer clarification questions about user value
- Approve contract
- Verify plan is created with proper structure
- Check that code location guidance is clear
- Test evaluation workflow
- Verify `/status` shows the prototype

## Definition of Done

- [ ] All tasks completed
- [ ] All acceptance criteria met
- [ ] `/prototype` command file created at `.cursor/commands/prototype.md`
- [ ] Clarification loop focuses on user-facing value
- [ ] Prototype contract emphasizes demo and evolution
- [ ] Plan generation creates proper proto-N-name structure
- [ ] Clear distinction from experiment documented
- [ ] Evaluation template supports decision-making
- [ ] Code location guidance is clear
- [ ] Number detection works correctly
- [ ] No regressions in `.junior/` structure
- [ ] Code follows Junior's principles
- [ ] Documentation complete in prototype.md
- [ ] **User can run /prototype and generate complete prototype plan**
- [ ] Tested with at least 2 different prototype concepts

