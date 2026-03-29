# Project Initialization Contract

## Product Vision

**Name:** [Project Name]
**Type:** [web app / API / CLI / library / desktop / mobile / docs-only / other]

**The Problem**
[Specific problem that matters to real people]

**Who Has This Problem**
[Specific user persona with context]

**The Solution (One Sentence)**
[Clear value proposition]

**Why This Matters**
[Impact and purpose]

**Core Capabilities (max 3)**
1. [Capability 1] - [Why essential]
2. [Capability 2] - [Why essential]
3. [Capability 3] - [Why essential]

**Success Metric**
[One primary measurable metric]

**Initial Slice Target**
[Smallest first delivery boundary; optional short timebox]

**Long-Term Product Horizon**
[Capabilities expected after initial slice]

**Initial-Slice Non-Goals**
- [Deferred from first slice only]

**Product-Level Exclusions**
- [Truly out of scope for the product]

## Technical Foundation

[For NEW projects]

**Recommended Stack**
- Language: [choice + rationale (Why: product fit + team expertise + simplicity)]
- Framework: [choice + rationale (Why this serves the product needs)]
- Key Tools: [testing/build/dev + rationale (why meeded)]
- Architecture: [pattern + rationale (why appropriate for scope)]

**Alternatives Considered**
- [Alternative] - [Why not chosen]

[For EXISTING projects]

**Current Stack**
- Language: [current + assessment (strengths/weaknesses)]
- Framework: [current + assessment]
- Architecture: [pattern + assessment]

**Assessment**
- Strengths: [preserve what works well]
- Pain Points: [specific issues]
- Technical Debt: [areas needing attention]
- Testing Gaps: [coverage/missing tests]
- Documentation Gaps: [missing/unclear]
- Pattern Consistency: [where architecture/design patterns drift]

**Recommendations**
- [Improvement + rationale + effort + risk]
- [Debt/test/docs follow-up]

## What Will Be Generated

**Product Documentation**

```text
.junior/product/
├── 01-mission.md       # Problem, users, value, capabilities
├── 02-roadmap.md       # Sequence-first stages, milestones, boundaries
├── 03-tech-stack.md    # Stack choices with rationale
└── 04-dev-env.md       # Development setup
```

**Project Documentation and Files**
- `README.md` [create or update]
- practical project files as needed (`Makefile`, `.env.example`, scripts, config)

## Next Steps After Init

1. Review `.junior/product/01-mission.md`
2. Run `/jr-feature "<first core capability>"`
3. Start implementation with `/jr-implement`

---
Options: `yes` | `edit: <changes>` | `simpler` | `challenge`
