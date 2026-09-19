# Junior Rule 04: Meta-Rules - Writing Documentation for Junior

## Three Modes of Documentation

### Mode A: Junior → Junior (Internal Rules)
**Audience:** AI (me)
**Purpose:** Triggers, reminders, context

**Include:** triggers, concise checklists, relevant decisions, and references to working
implementations. Keep portable rules independent of a particular repository.

**Exclude:** code examples, implementation listings, textbook explanations, and copied source.
Code examples belong in Mode C documentation; Mode A links to them when needed. Exact
validation commands are operational instructions, not illustrative code examples, and may
appear when the rule needs them. This distinction also applies to the portability checklist below.

### Mode B: Junior → Junior + User (Specs/Decisions)
**Audience:** AI + Human review
**Purpose:** Technical decisions with context

**What to include:**
- ✅ Triggers and reminders for Junior
- ✅ Enough context for user to understand
- ✅ Rationale for decisions
- ✅ Trade-offs considered

**What to exclude:**
- ❌ Over-explaining to Junior (you know it)
- ❌ Over-explaining to expert user (they know it)
- ❌ Patterns the user already understands

**Example:**
```markdown
## Decision: Context Manager for Stream Exchange

**Problem:** Manual buffer management repeated in 3 protocols
**Solution:** extract_context() context manager
**Why:** Guarantees cleanup, exception-safe, reduces duplication
**Result:** 45 lines → 3 lines per usage
```

### Mode C: Junior → User (Documentation)
**Audience:** End users, developers using the code
**Purpose:** Teach and explain

**What to include:**
- ✅ What patterns are (they may not know)
- ✅ How things work (step by step)
- ✅ Examples with explanation
- ✅ Why we chose this approach
- ✅ How to use the code

**What to exclude:**
- ❌ Implementation details (unless needed)
- ❌ Junior-specific triggers

**Example:**
````markdown
## Stream Exchange Pattern

The library uses context managers for stream operations:

```python
async with stream.exchange_context():
    data = await stream.wait_for_data(size=100)
```

This pattern ensures:
- Buffer is prepared before receiving
- Cleanup happens automatically
- Exception-safe operation
````

## Documentation Test

**Before writing NEW docs or editing EXISTING docs, ask:**

1. **"Who is the primary audience?"**
   - Me only → Mode A (triggers)
   - Me + User review → Mode B (context)
   - End user → Mode C (teach)

2. **"What does the audience already know?"**
   - Me → Everything technical
   - Expert user → Domain patterns
   - End user → May need explanations

3. **"What's the purpose?"**
   - Trigger behavior → Mode A
   - Document decision → Mode B
   - Teach usage → Mode C

## What Junior Already Knows

**Universal knowledge (don't document for Junior):**
- Design patterns (Strategy, Factory, Observer, RAII, Context Manager, etc.)
- Programming concepts (DRY, SOLID, coupling, cohesion, etc.)
- Language syntax and standard libraries
- Common algorithms and data structures
- Industry best practices and conventions

**If Wikipedia or a textbook has it, Junior doesn't need it.**

## What Junior Learns

**Project-specific knowledge (DO document for Junior):**
- When to apply patterns in THIS codebase
- "We tried X, didn't work, use Y instead"
- User's specific preferences and decisions
- Codebase-specific architectural choices
- Real examples where patterns helped HERE

## CRITICAL: No Project Leakage into Generic "Junior" Documents

**Documents with "Junior" in the title must remain portable across projects.**

**Project-specific documents (no "Junior" in title) CAN and SHOULD include project details:**
- Feature/improvement/debugging docs in `.junior/`
- Project-specific architectural decisions
- Code examples from current codebase
- "In this project we..." language is APPROPRIATE

**Project-specific rules numbering:**
- **Generic Junior rules:** 00-99 (portable across all projects)
- **Project-specific rules:** 100+ (conventions, tools, domain-specific patterns for THIS project)
- Example: `100-project-conventions.md` for project-specific tools (uv, arrow, etc.)

**⚠️ WHEN WRITING/UPDATING JUNIOR RULES:**
1. **Use generic placeholders:** "Story X", "Task N", "Feature Y" - NOT concrete numbered references
2. **Use abstract examples:** "add authentication" NOT "add specific domain feature"
3. **Check before saving:** Would this make sense in ANY project?
4. **Grep check:** Search for specific story/task numbers in the rule file itself
5. Apply the Mode A code-example boundary above; do not duplicate implementation examples in rules.

**Test:** If Junior moved to a completely different project tomorrow, would this "Junior" document still be useful without modification?
- YES → Good generic Junior document
- NO → Contains project leakage, needs cleanup or isn't a Junior document

**Before saving ANY rule file, check:**
- [ ] No code examples in Mode A docs (triggers only)
- [ ] No project-specific terminology
- [ ] No domain-specific examples
- [ ] Principles are universal across ALL projects

**Portability review (agent norm):** Before modifying a shared Junior rule, verify it works for any project type (web, embedded, CLI, desktop, etc.). Keep source-authoring paths and policies in that repository's contributor guidance.

## Summary

**Mode A (Junior only):** Triggers, decisions, real examples. No explanations of what I know.

**Mode B (Junior + User):** Decisions with enough context. Balance between triggering Junior and informing user.

**Mode C (User only):** Full explanations, examples, how-to. Assume user may not know patterns.

**Golden rule:** Match detail level to audience knowledge.
