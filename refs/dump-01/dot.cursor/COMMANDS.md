# Junior Commands Specification

This document defines the structure and behavior of Junior's Cursor commands.

---

## Command Philosophy

Junior's commands are **minimal and essential** — focused on core development activities where expert reasoning adds value:

- **Plan** — Design features with architecture reasoning
- **Refactor** — Systematic code improvement
- **Research** — Technical investigation and analysis
- **Commit** — Generate meaningful commit messages
- **Review** — Code review with expert feedback
- **Feature** — Implement new features
- **Bugfix** — Systematic bug investigation and fixing
- **Spec** — Create technical specifications

**No elaborate workflows.** Just expert collaboration on common development tasks.

---

## Command Structure

Each command file follows this structure:

```markdown
# Command: [Name]

## Purpose
Brief description of what this command does

## When to Use
Situations where this command is appropriate

## Process
1. Step-by-step process
2. Junior follows to execute the command
3. With clear reasoning at each step

## Output
What the user should expect as output

## Examples
Example invocations and results
```

---

## Commands

### `/plan` — Feature Planning

**Purpose:** Plan features with architecture reasoning, requirements clarification, and design proposals.

**When to Use:**
- Starting a new feature or significant change
- Need to design system architecture
- Complex features requiring decomposition
- Need to evaluate multiple approaches

**Process:**
1. **Clarify requirements** — Ask questions to expose ambiguity
2. **Define success criteria** — What does "done" look like?
3. **Identify constraints** — Performance, scale, security, time
4. **Propose architecture** — With rationale and trade-offs
5. **Break down into phases** — Incremental, testable steps
6. **Present plan** — For validation before implementation

**Example:**
```
/plan user authentication system
```

Junior will:
- Ask about auth methods (OAuth, email/password, etc.)
- Clarify session management requirements
- Propose architecture (JWT, session tokens, etc.)
- Break down into implementation phases
- Present plan with trade-offs

---

### `/refactor` — Code Refactoring

**Purpose:** Systematic code improvement to enhance maintainability, clarity, or performance.

**When to Use:**
- Code is hard to understand or modify
- Duplicated logic across multiple locations
- Functions doing too many things
- Poor naming or structure
- Technical debt accumulation

**Process:**
1. **Analyze current code** — Identify issues
2. **Explain problems** — Why refactoring is needed
3. **Propose improvements** — Specific changes with rationale
4. **Ensure behavior preservation** — Tests should still pass
5. **Execute refactoring** — Incremental, safe changes
6. **Verify improvements** — Confirm better structure/performance

**Example:**
```
/refactor src/api/users.ts
```

Junior will:
- Analyze the file for issues (coupling, complexity, duplication)
- Explain what's problematic and why
- Propose specific refactorings
- Execute improvements while preserving behavior
- Verify tests still pass

---

### `/research` — Technical Investigation

**Purpose:** Investigate technical topics, evaluate approaches, and provide analysis.

**When to Use:**
- Choosing between technologies or approaches
- Need to understand a new library or framework
- Investigating performance issues
- Evaluating security implications
- Need expert analysis of options

**Process:**
1. **Define research question** — What are we trying to learn?
2. **Identify evaluation criteria** — What matters for this decision?
3. **Research alternatives** — Investigate options
4. **Compare trade-offs** — Pros, cons, use cases
5. **Provide recommendation** — With reasoning
6. **Document findings** — For future reference

**Example:**
```
/research WebSocket vs Server-Sent Events for real-time features
```

Junior will:
- Define comparison criteria (latency, browser support, scalability)
- Research both technologies
- Compare trade-offs
- Recommend based on requirements
- Document findings

---

### `/commit` — Intelligent Git Commits

**Purpose:** Generate meaningful commit messages that explain changes clearly.

**When to Use:**
- Ready to commit changes
- Need help describing changes clearly
- Want conventional commit format
- Complex changes needing good explanation

**Process:**
1. **Analyze changes** — Review diff
2. **Identify commit type** — feat, fix, refactor, etc.
3. **Write clear summary** — What changed (50 chars)
4. **Add detailed explanation** — Why changed (if needed)
5. **Include breaking changes** — If any
6. **Format conventionally** — Follow standards

**Example:**
```
/commit
```

Junior will:
- Review staged changes
- Determine commit type (feat, fix, refactor, etc.)
- Generate clear, conventional commit message
- Include detailed explanation if needed

**Output format:**
```
feat: add user authentication with JWT

Implements JWT-based authentication with refresh tokens.
Uses bcrypt for password hashing. Tokens expire after 1 hour.

Closes #123
```

---

### `/review` — Code Review

**Purpose:** Perform thorough code review with expert feedback on correctness, design, and maintainability.

**When to Use:**
- Reviewing your own code before committing
- Reviewing pull requests
- Need expert feedback on implementation
- Want to catch issues early

**Process:**
1. **Read for understanding** — What is this trying to do?
2. **Check correctness** — Does it work? Edge cases handled?
3. **Assess design** — Well-structured? Follows patterns?
4. **Evaluate clarity** — Can others understand it?
5. **Verify safety** — Security risks? Data integrity?
6. **Consider performance** — Obvious inefficiencies?
7. **Check tests** — Critical paths tested?
8. **Provide feedback** — Clear, actionable, balanced

**Example:**
```
/review src/payment/processor.ts
```

Junior will:
- Review the file thoroughly
- Check correctness, design, security, performance
- Provide specific, actionable feedback
- Distinguish blocking vs nice-to-have issues
- Acknowledge good code as well as issues

---

### `/feature` — Feature Implementation

**Purpose:** Implement new features with expert reasoning, proper architecture, and production quality.

**When to Use:**
- Implementing a planned feature
- Need expert guidance on implementation
- Want production-quality code from the start
- Complex feature requiring careful execution

**Process:**
1. **Understand requirements** — Clarify if needed
2. **Design approach** — Architecture and components
3. **Implement incrementally** — Testable steps
4. **Write production code** — No placeholders or TODOs
5. **Add tests** — For critical paths
6. **Verify correctness** — Tests pass, requirements met
7. **Document** — If needed for complex features

**Example:**
```
/feature implement password reset flow
```

Junior will:
- Clarify requirements (email-based? Security tokens?)
- Design the flow (token generation, expiration, validation)
- Implement components (API endpoints, email service, UI)
- Add tests for critical paths
- Verify complete functionality

---

### `/bugfix` — Bug Investigation and Fixing

**Purpose:** Systematically investigate and fix bugs with root cause analysis.

**When to Use:**
- Bug reported by users or found in testing
- Need to understand why something is broken
- Want to prevent similar bugs in the future
- Complex bug requiring investigation

**Process:**
1. **Reproduce the bug** — Understand exact failure
2. **Investigate root cause** — Why is this happening?
3. **Identify fix** — Address cause, not symptom
4. **Implement fix** — Proper solution, not workaround
5. **Add tests** — Prevent regression
6. **Verify fix** — Bug no longer occurs
7. **Consider related issues** — Is this a pattern?

**Example:**
```
/bugfix user login fails with special characters in password
```

Junior will:
- Reproduce the bug
- Investigate root cause (encoding issue? Validation bug?)
- Identify proper fix
- Implement solution
- Add test to prevent regression
- Check for similar issues elsewhere

---

### `/spec` — Technical Specification

**Purpose:** Create detailed technical specifications for features or systems.

**When to Use:**
- Complex feature needing detailed planning
- Need to communicate design to team
- Architecture documentation required
- Reference for implementation

**Process:**
1. **Define objective** — What are we building?
2. **Gather requirements** — Functional and non-functional
3. **Design architecture** — Components and interactions
4. **Detail implementation** — APIs, data models, flows
5. **Identify risks** — Trade-offs and challenges
6. **Document clearly** — Structured, comprehensive spec

**Example:**
```
/spec real-time notification system
```

Junior will:
- Clarify requirements (notification types, volume, delivery guarantees)
- Design architecture (WebSocket vs polling, infrastructure needs)
- Detail components (API, service, storage)
- Document data models and flows
- Identify risks and trade-offs
- Create comprehensive, actionable spec

---

## Command Guidelines

### When Commands Execute

Commands execute immediately unless:
- Requirements are ambiguous → Junior asks clarifying questions first
- Approach needs validation → Junior presents plan for approval
- Multiple valid approaches exist → Junior proposes options for selection

### Command Output

All commands produce:
- **Clear reasoning** — Why decisions were made
- **Actionable results** — Code, specs, or analysis
- **Traceability** — Decisions are documented and justified

### Command Composition

Commands can be chained:
```
/research GraphQL vs REST for our API
/plan API design based on research findings
/feature implement API endpoints
/commit
```

---

## Future Commands (Potential)

Commands that might be added later based on needs:
- `/deploy` — Deployment guidance and checks
- `/performance` — Performance profiling and optimization
- `/security` — Security audit and recommendations
- `/migrate` — Data migration planning and execution

**Principle:** Add commands only when they provide clear value beyond normal Junior collaboration.

---

## Implementation Notes

Each command should:
1. **Be clearly scoped** — One primary purpose
2. **Add value** — Beyond what normal Junior interaction provides
3. **Be self-contained** — Can execute independently
4. **Follow patterns** — Consistent structure and behavior
5. **Respect Junior's voice** — Expert, confident, constructive

Commands are tools for common tasks, not elaborate workflows. They enhance Junior's expert collaboration without imposing rigid processes.

---

**Junior commands: Essential tools for expert collaboration.**

