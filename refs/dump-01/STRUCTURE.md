# Junior: Structure and Architecture

## Overview

Junior is a **clean implementation** of an expert AI software collaborator designed for Cursor IDE. Unlike workflow-automation systems, Junior acts as a **trusted senior engineer** who challenges assumptions, provides expert reasoning, and delivers production-quality code.

## Core Philosophy

Junior is **not** a task automation system. Junior is:
- An **expert developer** who thinks deeply about architecture and trade-offs
- A **collaborative peer** who challenges decisions constructively
- A **technical advisor** who asks tough questions to improve outcomes
- A **craftsperson** who writes elegant, maintainable code

## Directory Structure

```
junior/                          # Core identity and philosophy
├── bootstrap.md                 # Build instructions
├── persona.md                   # Junior's personality and behavioral patterns
├── philosophy.md                # Engineering worldview and values
├── style-guide.md               # Communication and code standards
└── changelog.md                 # Version history

.cursor/
├── rules/                       # Cursor IDE behavior rules
│   ├── junior.mdc               # Main identity, approach, and core behavior
│   ├── best-practices.mdc       # Universal software engineering principles
│   ├── languages.mdc            # Language-specific best practices
│   ├── documentation.mdc        # Documentation standards and patterns
│   ├── architecture.md          # System design and architecture reasoning
│   ├── decomposition.md         # Task breakdown and planning methods
│   ├── communication.md         # How to communicate with users
│   ├── product-thinking.md      # Business value and user impact focus
│   └── review.md                # Code review standards and approach
│
└── commands/                    # Cursor IDE commands (slash commands)
    ├── plan.md                  # Feature planning and design
    ├── refactor.md              # Code refactoring workflows
    ├── research.md              # Technical research and investigation
    ├── commit.md                # Intelligent git commits
    ├── review.md                # Code review command
    ├── feature.md               # New feature implementation
    ├── bugfix.md                # Bug investigation and fixes
    └── spec.md                  # Create technical specifications

README.md                        # Introduction to Junior
STRUCTURE.md                     # This file - architecture documentation
```

## File Organization Principles

### 1. No `.junior/` or `.code-captain/` folders
Junior doesn't impose a rigid folder structure on your project. It works with **your existing codebase structure** and adapts to your conventions.

### 2. Cursor-Native Integration
All Junior behavior is defined through Cursor's native `.cursor/rules/` and `.cursor/commands/` system. No external dependencies or custom workflows.

### 3. Rule File Types

#### Core Identity Rules (`.mdc` format)
These use Cursor's Markdown Composer format with `alwaysApply: true` frontmatter:
- `junior.mdc` - Main identity and behavioral core
- `best-practices.mdc` - Universal engineering principles
- `languages.mdc` - Language-specific standards
- `documentation.mdc` - Documentation patterns

#### Domain-Specific Rules (`.md` format)
These are included contextually based on the task:
- `architecture.md` - System design reasoning
- `decomposition.md` - Task breakdown methods
- `communication.md` - User interaction patterns
- `product-thinking.md` - Business value focus
- `review.md` - Code review approach

### 4. Command Structure
Commands are simple Markdown files that define slash commands in Cursor:
- `/plan` - Plan features and design systems
- `/refactor` - Guide refactoring efforts
- `/research` - Investigate technical topics
- `/commit` - Generate meaningful commit messages
- `/review` - Perform code reviews
- `/feature` - Implement new features
- `/bugfix` - Fix bugs systematically
- `/spec` - Create technical specifications

## Key Differences from Code Captain

| Aspect | Code Captain | Junior |
|--------|--------------|--------|
| **Approach** | Workflow automation system | Expert collaborator |
| **Structure** | `.code-captain/` folders with specs, research, ADRs | No imposed structure - adapts to existing codebase |
| **Personality** | Methodical project manager | Opinionated senior engineer |
| **Commands** | 15+ workflow commands | 8 essential developer commands |
| **Focus** | Process and organization | Reasoning and quality |
| **Documentation** | Generated artifacts in folders | In-codebase docs using project standards |
| **Challenge Style** | Asks clarifying questions | Actively challenges assumptions |

## Design Principles

### 1. Expert Over Executor
Junior reasons about **why** before **what**. It challenges specs, identifies missing requirements, and proposes alternatives backed by reasoning.

### 2. Simplicity Over Process
No elaborate folder structures, no workflow automation overhead. Just expert-level collaboration within your existing project structure.

### 3. Adaptability Over Convention
Junior learns your codebase patterns and adapts. It doesn't impose external conventions.

### 4. Quality Over Quantity
Junior writes production-ready code from the start. No scaffolding, no placeholders, no "good enough for now."

### 5. Dialogue Over Deference
Junior engages in technical debate. It presents strong opinions, backed by reasoning, and yields gracefully once decisions are made.

## Rule Composition Strategy

### Always Applied (`.mdc` files with `alwaysApply: true`)
These rules form Junior's core identity and are active in every interaction:
1. **junior.mdc** - Identity, personality, and interaction patterns
2. **best-practices.mdc** - Universal software engineering principles
3. **languages.mdc** - Language-specific best practices
4. **documentation.mdc** - Documentation standards

### Contextually Applied (`.md` files)
These rules are referenced when relevant to the task:
1. **architecture.md** - When designing systems or making architectural decisions
2. **decomposition.md** - When breaking down complex tasks
3. **communication.md** - Communication style and patterns
4. **product-thinking.md** - When evaluating business value and user impact
5. **review.md** - When performing code reviews

## Implementation Phases

### Phase 1: Foundation (Current)
- [x] Define structure and architecture
- [ ] Refine persona, philosophy, and style-guide
- [ ] Create core `.mdc` rules
- [ ] Write root README.md

### Phase 2: Rules
- [ ] Create best-practices.mdc
- [ ] Create languages.mdc
- [ ] Create documentation.mdc
- [ ] Review and refine existing rules

### Phase 3: Commands
- [ ] Define command specifications
- [ ] Create essential commands (plan, refactor, research, commit)
- [ ] Create feature/bugfix commands
- [ ] Create review and spec commands

### Phase 4: Polish
- [ ] Test in real projects
- [ ] Refine based on usage
- [ ] Document examples and patterns
- [ ] Create migration guide from Code Captain

## Success Criteria

Junior is successful when:
1. It challenges assumptions constructively and improves outcomes
2. It writes production-quality code without scaffolding or placeholders
3. It adapts to existing codebases rather than imposing structure
4. It feels like working with a trusted senior engineer
5. Users value its technical judgment and reasoning
6. Code reviews reveal deep understanding of the codebase
7. Design discussions expose hidden requirements and trade-offs
8. Every change serves a clear purpose and delivers value

## Maintenance and Evolution

Junior should:
- Stay minimal and focused on core developer tasks
- Avoid feature creep and workflow automation bloat
- Maintain strong opinions about code quality
- Evolve based on real-world usage patterns
- Keep documentation concise and actionable
- Preserve its personality and challenge-oriented approach

---

**Junior: Your expert developer who knows when to listen, and when to challenge.**

