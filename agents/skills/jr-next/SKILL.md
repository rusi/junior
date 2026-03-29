---
name: jr-next
description: Analyze full project state and recommend the highest-value next action from the end-user perspective.
---

# Next Command

## Purpose

Strategic planning assistant that analyzes entire project state and recommends the highest-value next action from the end user's perspective.

## Type

Direct execution - Immediate action with no parameters

## When to Use

- Need guidance on what to work on next
- Multiple options available and need strategic direction
- Want to ensure focus on highest user value
- Completing current work and deciding next step
- Project review to align with product vision

## Process

### Step 1: Initialize Progress Tracking

Create todos using `todo_write` or `functions.update_plan`:

```json
{
  "todos": [
    {"id": "discover-commands", "content": "Discover available commands", "status": "in_progress"},
    {"id": "scan-project", "content": "Scan entire .junior/ structure", "status": "pending"},
    {"id": "read-product-docs", "content": "Read product documentation", "status": "pending"},
    {"id": "analyze-status", "content": "Analyze features/stories/tasks status", "status": "pending"},
    {"id": "assess-value", "content": "Assess user value of options", "status": "pending"},
    {"id": "recommend", "content": "Generate strategic recommendation", "status": "pending"}
  ]
}
```

**Discover available commands:**
- Use `list_dir ~/.codex/skills/` to see all available commands
- Only recommend commands that actually exist
- Don't invent command syntax

### Step 2: Comprehensive Project Scan

**Scan entire `.junior/` structure:**

```bash
# Detect stage
ls .junior/features/comp-* 2>/dev/null && echo "Stage 2+" || echo "Stage 1"

# Scan all work types
find .junior/features -name "feat-*" -type d
find .junior/features -name "bug-*" -type d
find .junior/features -name "enh-*" -type d
find .junior/improvements -name "imp-*" -type d
find .junior/debugging -name "dbg-*" -type d
find .junior/experiments -name "exp-*" -type d
find .junior/research -name "*.md"
find .junior/ideas -name "*.md"
```

**Collect comprehensive inventory:**
- All features (status, progress, stories)
- Bugs (nested in features)
- Enhancements (nested in features)
- Improvements (top-level)
- Debugging investigations
- Experiments
- Research documents
- Ideas

### Step 3: Read Product Documentation

**Load strategic context:**

Read files in `.junior/product/`:
- `01-mission.md` - Product purpose and target users
- `02-roadmap.md` - Planned features and priorities
- `03-tech-stack.md` - Technical foundation
- `04-dev-env.md` - Development context
- Other architecture docs - Architectural vision and patterns
- Prefer roadmap `## Execution Tracking` block for real progress/mapping data when present (see `../_shared/references/roadmap-progress-sync.md`)

**Extract key insights (laser-focused product thinking):**
- Who is the target user? What do they desperately need?
- What's the ONE core problem we're solving? (Not three, ONE)
- What's essential to ship? What's just noise?
- What can users DO after this? (Outcomes, not features)
- What would make this insanely great for users?
- Are we building what users need, or what's technically interesting?

### Step 4: Analyze All Work Status

**For each feature:**

Read `feat-N-overview.md` and `user-stories/feat-N-stories.md`:
- Status: Completed / In Progress / Planning
- Task completion: Count done vs total tasks
- Current story: Which story is active?
- Future stories: Check for `feat-N-story-future.md`

**For each story:**

Read story files to check:
- Task completion (checkboxes `- [ ]` vs `- ✅`)
- Definition of Done status
- Implementation details and blockers

**For other work types:**
- Bugs: Priority and status
- Improvements: Status and scope
- Experiments: Active vs completed
- Research: Recent vs archived
- Ideas: Captured but not yet planned

### Step 5: User Value Assessment

**Think from user perspective:**

Based on product docs (mission, roadmap), ask:
- **"What does the user need most right now?"**
- **"What capability would provide highest value?"**
- **"What blockers prevent user from accomplishing their goals?"**
- **"Is this work required for core user journey completion, or is it optional depth?"**

**Value heuristics:**

1. **Critical bugs** → Highest priority (product is broken)
2. **Core journey gaps** → Missing must-have capabilities users need to get value
3. **Core capabilities incomplete** → Complete what's started only when it materially advances core journey
4. **Essential missing features** → From roadmap, what's foundational?
5. **Enhancement work** → Polish and optimize existing
6. **Future expansion** → New capabilities from `feat-N-story-future.md` or roadmap

**NOT valued:**
- Foundational work with no user-facing benefit (yet)
- Refactoring without clear user impact
- Technical debt without visible user pain
- Recency of work (what was worked on recently)
- Optional add-ons that do not unblock core user value (example: MFA when major core workflows are missing)

**Mandatory value gate (before selecting recommendation):**
- Identify the product's core user journey from mission + roadmap.
- If any core journey step is missing/broken, prioritize that over optional depth work.
- Only recommend optional/security-depth add-ons early when:
  - There is a documented compliance/security requirement, or
  - There is evidence of active user pain/risk caused by missing add-on.

### Step 6: Priority Logic (User Value over Local Completion)

**Decision tree:**

**Priority 1: Fix Critical Issues**
- Critical bugs blocking user workflows
- Data corruption or security issues
- Highest user pain points

**Priority 2: Complete In-Progress Work (if actionable)**
- Stories at >50% completion (finish what's started)
- Features with multiple complete stories (maintain momentum)
- Last story in feature (close it out)
- Gate: only if this completion improves core user journey now

**Priority 3: Fill Core Journey Gaps**
- Start missing must-have feature/story even if not the next sequence item
- Prefer capabilities that unlock activation, primary workflow completion, or repeat use

**Priority 4: Start Next Pending Story**
- Next story in current feature only when it clears value gate
- Story sequence that builds user value progressively

**Priority 5: Define New Stories from Future Docs**
- Check `feat-N-story-future.md` for next logical stories
- Expand current feature before jumping to new one

**Priority 6: Start Next Feature from Roadmap**
- Parse `02-roadmap.md` for next planned feature
- Consider feature that enables other features
- If roadmap execution tracking drifts from feature-story reality, prioritize syncing via `/jr-roadmap` before starting net-new feature work

**Priority 7: Improvements/Refactoring**
- Technical debt impacting development velocity
- Code quality issues making changes difficult
- Performance optimizations with measurable user impact

**Priority 8: Roadmap Evolution**
- Product vision needs refinement based on learnings
- Roadmap outdated or missing critical user needs
- New insights from implementation suggest direction change
- Action: Suggest running `/jr-init` to evolve product definition

**Anti-pattern to avoid:**
- Do NOT auto-recommend "next story in sequence" when it is optional depth (MFA/add-on/polish) and major core capabilities remain missing.

### Step 7: Generate & Present Recommendation

Select ONE highest-value action, provide 2-3 alternatives, include context summary.

**Requirements:**
- **Commands:** Use exact Junior commands and provide complete runnable actions (`/jr-implement feat-N-story-M`, `/jr-feature <clear feature brief>`, `/jr-roadmap`, not invented syntax)
- **No incomplete commands:** Never output a command that requires additional missing input after execution. If a command needs arguments or text, include them in the same `ACTION:` line.
- **USER VALUE:** 2 sentences - outcome-focused, what user can DO
- **Alternatives:** Option + 1 sentence reasoning + exact command
- **Context:** Bullet format (Analyzed, In Progress, Product Focus)

**Format:** See Output Template below (present as clean text, NOT in code blocks)

## Special Cases

### No Active Work (Clean State)

**Priority order:**
1. Check `feat-N-story-future.md` → Suggest defining those stories
2. Next roadmap feature → Suggest specific feature from roadmap
3. Ideas → Suggest promoting idea to feature

### Multiple Equal-Priority Options

**Tie-breakers:**
1. Core journey impact (unblocks core workflow > optional enhancement)
2. Dependency enabling (foundational > dependent)
3. Completion proximity (80% done > 20% done, only if value impact is similar)
4. Feature sequence (Story 2 after Story 1 in same feature)
5. Roadmap order (earlier > later)

**In USER VALUE:** Brief reason why Option A over B (one sentence using tie-breaker).

### Missing Product Documentation

**Fallback logic:**
- Use feature sequence (feat-1 before feat-2)
- Completion over expansion still applies
- Add note: "⚠️ Product docs missing - add mission.md and roadmap.md for better guidance"

## Command Recommendations

**CRITICAL: Only suggest commands that exist in `~/.codex/skills/`**
- Discovered in Step 1 via `list_dir ~/.codex/skills/`
- DON'T invent command names or syntax
- Use exact command patterns and include required arguments/text in-line (e.g., `/jr-implement feat-N-story-M`, `/jr-feature Build room rates and charge model for reservation pricing`, `/jr-roadmap`)

## Tool Integration

**Primary tools:**

- `todo_write` or `functions.update_plan` - Progress tracking
- `list_dir` or `functions.shell_command` - Scan `.junior/` directories
- `glob_file_search` or `functions.shell_command` - Find features, improvements, bugs, etc.
- `read_file` or `functions.shell_command` - Read product docs, feature specs, story files
- `grep` (via `functions.shell_command`) - Parse task completion, status fields
- `codebase_search` or `functions.shell_command` - Search for patterns in large projects

**Parallel execution opportunities:**

- Directory scans (features, improvements, experiments, research)
- File reads (product docs, multiple feature specs)
- Status checks (multiple story files)

## Output Formatting

- Clean text (NOT code blocks)
- Separators: `━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━` between sections
- Icons: 🎯💡✅🚧⚠️
- Hierarchy: Primary → Alternatives → Context
- **Commands: Exact Junior commands with complete inputs** (`/jr-implement feat-N-story-M`, `/jr-feature Build room rates and charge model for reservation pricing`, `/jr-roadmap`, etc.)
- **USER VALUE: 2 sentences** (outcome-focused, what user can DO)
- **Alternatives: Brief description + reasoning** (1 sentence each explaining why/when)

## Key Principles

**User-centric:** Frame from "What can user DO?" - avoid engineering-speak
**Completion first:** Finish >50% work before new work
**Evidence-based:** Parse checkboxes, read story files, verify status
**Clear action:** ONE recommendation + 2-3 alternatives with reasoning
**Exact commands:** Use real Junior commands with complete inputs (`/jr-implement feat-N-story-M`, `/jr-feature <feature brief>`, `/jr-roadmap`; not invented syntax)
**Executable actions only:** Every `ACTION:` line (primary and alternatives) must be runnable as-is with no follow-up parameter request.
**Balanced output:** 2 sentences USER VALUE, alternatives with brief reasoning, bullet context

## Output Template

```
🎯 NEXT: [Action: Complete/Start story, define feature, fix bug]

USER VALUE: [2 sentences - what user can DO after this, outcome-focused]

ACTION: [Exact complete command - /jr-implement feat-N-story-M, /jr-feature <feature brief>, /jr-roadmap, /jr-debug <problem statement>, etc.]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

ALTERNATIVES:

1. [Option description]
   Why: [1 sentence reasoning]
   ACTION: [Exact complete command]

2. [Option description]
   Why: [1 sentence reasoning]
   ACTION: [Exact complete command]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

CONTEXT:
• Analyzed: X features, Y stories, Z tasks
• In Progress: [Feature/story details or "No active work"]
• Product Focus: [Brief mission from product docs]
```

---

**Think like the user. Build what matters most. Deliver value continuously.**
