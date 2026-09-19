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

Junior turns Claude Code, Cursor, or Codex into an expert software collaborator that:
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

Install the **latest tagged release** for Claude Code, Cursor, or Codex. Use `claude`,
`cursor`, `codex`, a comma-separated list, or `all` as the target. The Codex target works
with the Codex desktop app, CLI, and IDE extension.

**macOS / Linux:**
```bash
curl -LsSf https://rusi.github.io/junior/install.sh | bash -s -- --target claude
```

**Windows (PowerShell):**
```powershell
& ([scriptblock]::Create((irm https://rusi.github.io/junior/install.ps1))) -Target claude
```

Omit the target to choose interactively. The installer shows your installed version,
the selected release, and its destination, then asks whether to continue. Use `--yes`
(`-Yes` in PowerShell) for unattended installation with an explicit target.
Python 3.10+ is required; use Python 3.11+ for Codex.

**Choose where to install:** no path means global installation in your home directory.
A path means installation in that project:

```bash
# Current project
curl -LsSf https://rusi.github.io/junior/install.sh | bash -s -- ./ --target codex

# Another project
curl -LsSf https://rusi.github.io/junior/install.sh | bash -s -- ~/my-project --target claude
```

In PowerShell, pass `-Destination .\` or `-Destination ~/my-project`. The directory must
already exist. Commit the project installation so teammates receive the same Junior
version. Keep `.claude/settings.local.json` out of git; it contains personal settings.
See [Structure](#structure) for what each runtime installs.

**Choose a version:** save the installer if you want a shorter command for repeated use:

```bash
curl -LsSf https://rusi.github.io/junior/install.sh -o install.sh
bash install.sh --target codex                    # Latest tagged release, globally
bash install.sh ./ --target codex --choose-version # Pick a release for this project
bash install.sh --target codex --version v2.0.0    # A specific release
bash install.sh --target codex --development      # Latest main commit, explicitly
bash install.sh --list-versions                   # List available stable tags
```

The version picker offers stable releases and, when newer commits exist, a development
option showing how far `main` is ahead. The selected version is pinned to its commit for
the download. Releases predating Junior 2.0 require their original installer.
PowerShell equivalents are `-ChooseVersion`, `-Version v2.0.0`, `-Development`, and
`-ListVersions`.

**Start a fresh agent session after installation.** Claude Code reads `.claude/rules/`
and `CLAUDE.md`. Cursor project installs use native rules in `.cursor/rules/`; global
rule activation needs separate setup. Codex reads the generated Junior block in
`AGENTS.md`. The block and individual rule files are generated from the same source; you do not
maintain them separately.

For runtime loading, Codex capacity settings, hooks, and migration conflicts, see the
[installation reference](https://github.com/rusi/junior/blob/main/agents/skills/jr/references/installation.md).

### Updating Junior

Run the same installer command again, including the project path when applicable.
It defaults to the latest tagged release and preserves modified installed files.
Use `--choose-version` to inspect available versions before choosing an update.
In agent chat, `/jr update` performs the same operation for the selected installation.

**Migration:** Junior migrates files it owns and preserves your instructions and
customizations. If different edited copies conflict, it stops and names them; reconcile
those copies before retrying. See the [migration details](https://github.com/rusi/junior/blob/main/agents/skills/jr/references/installation.md#migration).

### Installing From a Checkout

To install the exact source you have checked out:

```bash
git clone https://github.com/rusi/junior.git
./junior/scripts/install-junior.sh --target codex
# Add a project path to install there instead of globally:
./junior/scripts/install-junior.sh ~/my-project --target codex
```

On Windows, use `scripts/install-junior.ps1 -Target codex`, optionally with
`-Destination ~/my-project`. Checkout installation uses your local files; release
selection belongs to the bootstrap installer above.

### Installation Help

Check that Python is available and GitHub is reachable. macOS/Linux also needs `curl`
or `wget` to download the installer. Run with your normal user account and make sure
the destination is writable.

For loading or migration issues, use the [installation reference](https://github.com/rusi/junior/blob/main/agents/skills/jr/references/installation.md).
When [reporting a problem](https://github.com/rusi/junior/issues), include the error,
Junior version, runtime, OS, and shell, with private details removed.

Open your project in Claude Code, Cursor, or Codex and start with `/jr-init` or `/jr-feature`.

## 📖 Usage

### Available Commands

**Framework Operations (`jr` skill):**
- `/jr install` - Install or upgrade Junior assets, globally or into a project
- `/jr update` - Check and apply latest Junior framework updates
- `/jr feedback` - Prepare or locally deliver an improvement proposal for Junior
- `/jr sync` - Sync global Junior modifications back to source
- `/jr migrate` - Migrate legacy structures to current Junior conventions
- `/jr maintenance` - Reorganize and normalize Junior artifacts/references

**Software Development (`jr-*` skills):**
- `/jr-init` - Define product vision and technical foundation
- `/jr-roadmap` - Update product roadmap using feature layers and sequence-first planning (no timelines)
- `/jr-feature` - Plan and create feature specifications
- `/jr-add-story` - Add scoped stories to existing features
- `/jr-ui-prototype` - Build, show, and iteratively refine interface prototypes before implementation
- `/jr-implement` - Execute feature stories with TDD workflow
- `/jr-test` - Post-implementation test-engineering audit gate with optional test-first mode
- `/jr-demo` - Capture an assert-verified storyboard of the running application
- `/jr-commit` - Create clean commits with safe staging
- `/jr-code-review` - Findings-first code review
- `/jr-product-review` - Whole-product review with prioritized findings and explicit coverage
- `/jr-integrate` - Acceptance-test all changes on the integration branch before final merge
- `/jr-debug` - Evidence-based debugging workflow
- `/jr-refactor` - Behavior-preserving structural improvement
- `/jr-status` - Project overview with git and `.junior` state
- `/jr-next` - Recommend highest-value next action
- `/jr-archive` - End-of-session gate: is the work complete, persisted, and clear of loose ends, safe to close?
- `/jr-new-skill` - Create new Junior workflow skills

### Feedback

Use `/jr feedback` when Junior should do something better: a rule that causes trouble,
a missing workflow, or an installer issue. It prepares a concise proposal with expected
and observed behavior, evidence, and a suggested improvement for you to review and submit.

Name a known local Junior source checkout to save the proposal directly as
`.junior/docs/feedback-<subject>.md` there. Otherwise, receive submission-ready Markdown
in the conversation, or request a file at your chosen path. Feedback is considered when
you direct work to it; preparation does not submit it or authorize implementation.
Existing handoff documents are preserved. There is no global inbox or required archival.

### 🔄 Development Workflow

Junior follows a **plan → implement → commit** cycle. Each feature is broken into small, testable stories that deliver value incrementally.

```
┌─────────────────────────────────────────────────────────────────┐
│                     JUNIOR WORKFLOW                             │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  1. PLAN          /jr-feature add user auth                     │
│     ↓             → Junior asks questions, creates spec         │
│                   → Creates feat-1-auth/ with 3 stories         │
│                                                                 │
│  2. COMMIT        /jr-commit                                    │
│     ↓             → Commits feature specification               │
│                                                                 │
│  3. IMPLEMENT     /jr-implement feat-1-story-1                  │
│     ↓             → TDD: tests first, then implementation       │
│                   → End-to-end working slice                    │
│                                                                 │
│  4. COMMIT        /jr-commit                                    │
│     ↓             → Commits story implementation                │
│                                                                 │
│  5. REPEAT        /jr-implement feat-1-story-2                  │
│     ↓             → Next story...                               │
│     ↓             /jr-commit                                    │
│     ↓             → Continue until feature complete             │
│                                                                 │
│  6. NEXT FEATURE  /jr-feature add payment processing            │
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
User: /jr-feature add user authentication

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
User: /jr-commit

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
User: /jr-implement feat-1-story-1

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
User: /jr-commit

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
User: /jr-implement feat-1-story-2
      ... [implement login] ...
User: /jr-commit

User: /jr-implement feat-1-story-3
      ... [implement OAuth] ...
User: /jr-commit

✅ Feature complete! Ready for next feature.
```

**Step 6: Start next feature**

```text
User: /jr-feature add payment processing
      ... [cycle repeats] ...
```

## Structure

The runtime paths below are relative to **your home directory for global installs** or
**the chosen project directory for project installs**. Junior preserves your existing
instructions and settings, updating only its managed files, blocks, and hook entries.

**Claude Code**

```text
.claude/
  rules/                # Junior rules
  skills/               # Workflows and their supporting files
  hooks/                # Bash polling-loop guard
  junior-contract.md    # Junior loading and workflow contract
  settings.json         # Hook registrations merged with your settings
  .junior-install.json  # Installed version, ownership, and checksums
```

The contract is imported by a managed block in `~/.claude/CLAUDE.md` globally, or
`CLAUDE.md` at the project root for a project install.

**Cursor**

```text
.cursor/
  rules/                # Native .mdc rules; project rules apply automatically
  .junior-install.json  # Rule version, ownership, and shared-skills reference
```

Global rule activation requires separate setup in Cursor.

**Codex**

```text
.codex/
  config.toml           # Instruction capacity setting merged with yours
  .junior-install.json  # Rule version, ownership, and shared-skills reference
```

The generated rule block lives in `~/.codex/AGENTS.md` globally, or `AGENTS.md` at the
project root. Existing nonempty `AGENTS.override.md` files receive it too, because
Codex selects an override before the baseline file.

For a custom global profile, set `CODEX_HOME` when installing, updating, or syncing.
Its instruction files and `config.toml` use that directory instead of `~/.codex`;
shared skills and rules remain under `~/.agents`, and Codex ownership metadata remains
under `~/.codex`. Project installations stay within the project.

**Shared by Codex and Cursor**

```text
.agents/
  rules/                # Codex rule inputs; used to generate its AGENTS.md block
  skills/               # One skill installation discovered by both runtimes
  .junior-install.json  # Shared skill version, ownership, and checksums
```

Installing skills for either runtime makes them available to both. Updating either
updates this shared skill installation; each runtime tracks its own rules separately.

**Project memory — the same for every runtime**

```text
.junior/                # Created as work needs it, inside your project
  features/             # Feature specifications
  improvements/         # Code quality improvements
  debugging/            # Debug investigations
  experiments/          # Experiments and prototypes
  research/             # Technical research
  decisions/            # Architecture Decision Records
  docs/                 # Reference documentation and feedback proposals
  ideas/                # Future ideas
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
