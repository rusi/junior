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

**Easy installation in any project:**

**macOS / Linux:**
```bash
# Clone Junior repository
git clone https://github.com/rusi/junior.git

# Run installation script
./junior/scripts/install-junior.sh /path/to/your/project
```

**Windows (PowerShell):**
```powershell
# Clone Junior repository
git clone https://github.com/rusi/junior.git

# Run installation script
.\junior\scripts\install-junior.ps1 -TargetPath "C:\path\to\your\project"
```

The installation script will:
- ✅ Create `.cursor/` and `.junior/` directory structure
- ✅ Copy all commands and rules to your project
- ✅ Generate version tracking metadata
- ✅ Preserve any existing customizations during upgrades

**Manual installation:**
```bash
# Copy Junior files to your project
cp -r /path/to/junior/.cursor /path/to/your/project/
cp /path/to/junior/README.md /path/to/your/project/JUNIOR.md

# Create Junior working memory structure
mkdir -p /path/to/your/project/.junior/{features,experiments,research,decisions,docs,ideas,bugs,enhancements}
```

### Upgrading

To upgrade an existing Junior installation, simply run the installation script again:

```bash
# macOS / Linux
./junior/scripts/install-junior.sh /path/to/your/project

# Windows (PowerShell)
.\junior\scripts\install-junior.ps1 -TargetPath "C:\path\to\your\project"
```

The script will:
- Detect user-modified files and preserve them automatically
- Update only unmodified Junior files
- Update version tracking metadata
- Maintain all your customizations

**Sync your customizations back to Junior source:**
```bash
# macOS / Linux
./junior/scripts/install-junior.sh --sync-back /path/to/your/project

# Windows (PowerShell)
.\junior\scripts\install-junior.ps1 -SyncBack -TargetPath "C:\path\to\your\project"
```

**Advanced options:**
- `--ignore-dirty` / `-IgnoreDirty`: Skip git clean check (testing only)
- `--force` / `-Force`: Override safety checks (special cases only)
- `--sync-back` / `-SyncBack`: Copy modified files back to Junior source

**Open your project in Cursor and start using commands immediately** - try `/feature` to get started!

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

### 🔄 Development Workflow

Junior follows a **plan → implement → commit** cycle. Each feature is broken into small, testable stories that deliver value incrementally.

```
┌─────────────────────────────────────────────────────────────────┐
│                     JUNIOR WORKFLOW                             │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  1. PLAN          /feature add user auth                        │
│     ↓             → Junior asks questions, creates spec         │
│                   → Creates feat-1-auth/ with 3 stories         │
│                                                                 │
│  2. COMMIT        /commit                                       │
│     ↓             → Commits feature specification               │
│                                                                 │
│  3. IMPLEMENT     /implement feat-1-story-1                     │
│     ↓             → TDD: tests first, then implementation       │
│                   → End-to-end working slice                    │
│                                                                 │
│  4. COMMIT        /commit                                       │
│     ↓             → Commits story implementation                │
│                                                                 │
│  5. REPEAT        /implement feat-1-story-2                     │
│     ↓             → Next story...                               │
│     ↓             /commit                                       │
│     ↓             → Continue until feature complete             │
│                                                                 │
│  6. NEXT FEATURE  /feature add payment processing               │
│                   → Start cycle again                           │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

**Key principles:**
- **Plan before code** — Never jump into implementation without a spec
- **Small commits** — Commit after each story, not at the end
- **Vertical slices** — Each story is end-to-end testable by users
- **TDD workflow** — Tests first, then implementation

### Example Session

**Step 1: Plan a feature**

```text
User: /feature add user authentication

Junior: 🚀 Junior online. Let's think, then code.
        [Scans codebase and existing features]
        What authentication methods do you want to support?

User: Email/password and Google OAuth

Junior: [Asks focused questions until 95% clear...]
        
        ## Feature Contract
        
        **Feature:** User authentication with email/password and Google OAuth
        **User Value:** Secure account creation and login
        **Success Criteria:** Users can register, login, and access protected routes
        
        [Shows complete contract with concerns and recommendations]
        
        Options: [yes/edit/risks/simpler]

User: yes

Junior: ✅ Feature specification created!
        📁 .junior/features/feat-1-auth/
           ├── feat-1-overview.md
           └── user-stories/
               ├── feat-1-stories.md
               ├── feat-1-story-1-registration.md
               ├── feat-1-story-2-login.md
               └── feat-1-story-3-oauth.md
```

**Step 2: Commit the spec**

```text
User: /commit

Junior: 📁 Files to stage (from this session):
          A  .junior/features/feat-1-auth/feat-1-overview.md
          A  .junior/features/feat-1-auth/user-stories/feat-1-stories.md
          A  .junior/features/feat-1-auth/user-stories/feat-1-story-1-registration.md
          A  .junior/features/feat-1-auth/user-stories/feat-1-story-2-login.md
          A  .junior/features/feat-1-auth/user-stories/feat-1-story-3-oauth.md
        
        💬 Commit Message:
        ┌─────────────────────────────────
        │ docs(feat-1): add user auth specification
        │ 
        │ - Feature overview with acceptance criteria
        │ - 3 user stories for incremental delivery
        └─────────────────────────────────

User: yes
```

**Step 3: Implement first story**

```text
User: /implement feat-1-story-1

Junior: 🎯 Implementing: feat-1-story-1-registration
        
        [Reads story spec, plans implementation]
        [Writes tests first (TDD)]
        [Implements until tests pass]
        [Updates story progress]
        
        ✅ Story complete!
        
        Files created/modified:
          A  src/auth/register.ts
          A  src/auth/register.test.ts
          A  src/db/users.ts
          M  .junior/features/feat-1-auth/user-stories/feat-1-story-1-registration.md
```

**Step 4: Commit the implementation**

```text
User: /commit

Junior: 📁 Files to stage:
          A  src/auth/register.ts
          A  src/auth/register.test.ts
          A  src/db/users.ts
          M  .junior/features/feat-1-auth/user-stories/feat-1-story-1-registration.md
        
        💬 Commit Message:
        ┌─────────────────────────────────
        │ feat(feat-1-story-1): ✅ user registration
        │ 
        │ - Email/password registration endpoint
        │ - Password hashing with bcrypt
        │ - User storage in database
        │ - Comprehensive test coverage
        └─────────────────────────────────

User: yes
```

**Step 5: Continue with remaining stories**

```text
User: /implement feat-1-story-2
      ... [implement login] ...
User: /commit

User: /implement feat-1-story-3
      ... [implement OAuth] ...
User: /commit

✅ Feature complete! Ready for next feature.
```

**Step 6: Start next feature**

```text
User: /feature add payment processing
      ... [cycle repeats] ...
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

## 🤝 Contributing

Contributions welcome! By submitting a PR, you agree to license your contribution under the same dual MIT/CC BY 4.0 license.

**Ways to contribute:**
- Improve prompts and rules
- Add new commands
- Fix bugs or improve documentation
- Share your customizations

## 📜 License

This project is dual-licensed under your choice of:

- **[MIT License](https://github.com/rusi/junior/blob/main/LICENSE-MIT)**
- **[Creative Commons Attribution 4.0 (CC BY 4.0)](https://github.com/rusi/junior/blob/main/LICENSE-CC-BY)**

See [LICENSE](https://github.com/rusi/junior/blob/main/LICENSE) for details.

**Attribution:**

If using Junior in your project:
```
Powered by Junior (https://github.com/rusi/junior) by Ruslan Hristov
```

If extending or forking:
```
Based on Junior (https://github.com/rusi/junior) by Ruslan Hristov
```

## 🙏 Acknowledgment

Junior was inspired by the original *Code Captain* concept by [@devobsessed](https://github.com/devobsessed).  
It shares the same vision of helping AI agents become effective software collaborators.
