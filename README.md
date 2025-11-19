# Junior 👩‍💻

> **Your first AI developer hire — they do all the work, so you don't have to; now sit, and relax.**

**Junior** is an expert AI software engineer, architect, and product development engineer.

Junior isn't just a code generator — it's a trusted senior engineer who thinks deeply about architecture, challenges assumptions constructively, and writes production-quality code. Junior ensures every feature delivers business value and solves a real user problem.

Junior builds end-to-end **products**, not just software.

> _"Simplicity is the ultimate sophistication."_ — This is Junior's core.

## 🧩 Philosophy

Junior believes great engineering starts with _why_. It doesn't write code to fill commits — it builds systems that deliver business value, enhance user experience, and move metrics that matter.

**Core principles:**
1. **Build with purpose.** Every change should serve a real goal.  
2. **Challenge to improve.** Healthy friction produces better design.  
3. **Mentorship at scale.** Learn continuously. Share reasoning.  
4. **Craftsmanship.** Write code that ages well.  
5. **Business impact first.** Technical elegance is only valuable when it drives outcomes.

**Expertise:**
- Expert software engineer - production-ready code, clean architecture
- Expert architect - system-level thinking, scalable design
- Expert product engineer - simple, minimalist, user-friendly solutions
- Focus on end-to-end fully integrated systems, not isolated features

## 💡 What Junior Does

Junior turns Cursor into an expert software collaborator that:
- Thinks like an **expert software engineer**, acts like a **collaborative peer**
- Asks questions that expose unclear goals or flawed specs
- Challenges specs that don't align with product goals
- Ensures every feature aligns with user and business value
- Plans complex projects using decomposition and architecture reasoning
- Refactors legacy codebases to improve maintainability
- Writes elegant, maintainable, production-grade code
- Reviews code with empathy and rigor

> **Junior — Your expert developer who knows when to listen, and when to challenge.**

## 🚀 Getting Started

### Installation

1. Copy Junior files to your project:
```bash
cp -r /path/to/junior/.cursor .
```

2. Start using Junior with `/` commands

## 📖 Usage

### Available Commands

**Core Commands:**
- `/feature` - Plan and create feature specifications (contract-style)
- `/implement` - Execute feature stories with TDD workflow
- `/commit` - Intelligent git commits with session-based staging
- `/new-command` - Create new Junior commands

**Coming Soon:**
- `/research` - Technical investigation
- `/refactor` - Code improvement
- `/review` - Code review

### Example Sessions

**Planning a feature:**

```text
User: /feature add user authentication
Junior: 🚀 Junior online. Let's think, then code.

[Scans codebase and existing features]

What authentication methods do you want to support?

User: Email/password and Google OAuth

Junior: [Asks focused questions about requirements...]

## Feature Contract

**Feature:** User authentication with email/password and Google OAuth
**User Value:** Secure account creation and login
**Success Criteria:** Users can register, login, and access protected routes

[Shows complete contract with concerns and recommendations]

Options: [yes/edit/risks/simpler]

User: yes

Junior: ✅ Feature specification created!
📁 .junior/features/feat-1-auth/

[3 user stories, each end-to-end integrated and user-testable]
```

**Committing changes:**

```text
User: /commit
Junior: 🎯 Junior here. Let's build something great.

[Analyzes changes, identifies session files]

📁 Files to stage (from this session):
  M  src/auth.ts
  M  src/auth.test.ts

Stage these session files? [yes/no/all]

User: yes

💬 Generated Commit Message:
┌─────────────────────────────────
│ feat: add JWT authentication
│ 
│ - Implement token generation
│ - Add login endpoint
│ - Include tests
└─────────────────────────────────

Proceed with commit? [yes/no/edit]
```

## ⚙️ Structure

```text
.cursor/
  rules/
    00-junior.mdc       # Core identity and 15 principles
    01-structure.mdc    # Working memory organization
    02-current-date.mdc # Current date determination
  commands/
    feature.md          # Feature planning (contract-style)
    implement.md        # Execute stories with TDD workflow
    commit.md           # Git commits with session staging
    new-command.md      # Create new commands

.junior/                # Junior's working memory (created as needed)
  features/             # Feature specifications
  experiments/          # Experiments and prototypes
  research/             # Technical research
  decisions/            # Architecture Decision Records
  docs/                 # Reference documentation
```

## 🤝 Acknowledgment

Junior was inspired by the original *Code Captain* concept by [@devobsessed](https://github.com/devobsessed).  
It shares the same vision of helping AI agents become effective software collaborators.
