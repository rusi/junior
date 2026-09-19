---
name: jr-new-skill
description: Run `/jr-new-skill` to author a new Junior skill against the established structure and conventions.
---

# New Skill

## Purpose

Create new Junior skills following established patterns and conventions.

## Scope Guard (Non-Negotiable)

- Create and update skills only inside this repository: under `agents/skills/` for a skill
  that installs with the skill set, or under the repository's own `.agents/skills/` for a workflow
  bound to this repository that must neither install nor ship.
- Update rule files only inside this repository under `agents/rules/`.
- Never read from or write to global skill/rule locations (for example `~/.claude/skills/` or `~/.claude/rules/`) when creating or editing skills for this project.

## Type

Contract-style - Clarification loop, then contract approval, then generation

## When to Use

- Need to add a new skill to Junior
- Want to extend Junior's capabilities
- Creating custom workflow skill

## Process

### Step 1: Initialize Progress Tracking

Create todos using `todo_write` or `functions.update_plan` with JSON list:

```json
{
  "todos": [
    {"id": "clarify-skill", "content": "Clarify skill purpose and requirements", "status": "in_progress"},
    {"id": "validate-fit", "content": "Validate skill fits Junior ecosystem", "status": "pending"},
    {"id": "create-contract", "content": "Create skill contract", "status": "pending"},
    {"id": "generate-skill", "content": "Generate skill file", "status": "pending"}
  ]
}
```

This creates structured progress tracking for the skill creation process.

### Step 2: Clarification & Analysis

**Scan existing skills:**

Inspect both `agents/skills/` and `.agents/skills/` for existing names and overlapping
workflows. Select **portable** (installed and publicly distributable) or **repository-only**
(private to this checkout) from the user's intent and repository governance; ask if unclear.
Carry this distribution scope through the contract, write location, discovery, and validation.
Do not register a private workflow as portable merely to make it discoverable.

**Ask clarifying questions (one at a time):**

- What specific workflow does this skill solve?
- Should this be contract-style (clarification loop) or direct execution?
- What inputs does it need?
- What outputs does it create?
- Where should outputs be stored (`.junior/specs/`, `.junior/research/`, etc.)?
- What agent tools will it need?

**Critical analysis - Challenge if:**
- Skill duplicates existing functionality
- Scope is too broad or unclear
- Complexity doesn't justify the value
- Doesn't fit Junior's principles

**Continue until 95% clear on requirements**

### Step 3: Present Skill Contract

**When confident, present contract:**

```
## Skill Contract

**Name:** [skill-name]

**Purpose:** [One sentence what it does]

**Type:** [Contract-style OR Direct execution]

**Distribution:** [Portable OR Repository-only]

**Skill path:** [Exact repository-relative SKILL.md path for the selected distribution]

**Discovery:** [Portable command listings OR repository-local runtime discovery]

**Workflow:**
1. [Step one]
2. [Step two]
3. [Step three]

**Inputs:** [What user provides]

**Outputs:** [Files/folders created]

**Tools:** [agent tools needed]

**⚠️ Concerns (if any):**
- [Any implementation concerns]

**💡 Recommendations:**
- [Suggestions to improve]

---
Lock contract and create skill? [yes/no/edit]
```

**Options:**
- **yes** - Create the skill
- **no** - Cancel
- **edit** - Modify contract

### Step 4: Documentation Mode & Leak Prevention

**CRITICAL: Skills are Mode A documentation (Junior → Junior)**

Skills are written FOR Junior (the AI), not for end users. This means:

**Mode A Principles:**
- ✅ High-level workflow steps (what to do)
- ✅ Tool names to use (codebase_search, grep, etc.)
- ✅ Decision points (when to ask user)
- ✅ Generic examples (feat-N-name, user-X, etc.)
- ❌ Detailed implementation (grep patterns, regex)
- ❌ Language-specific syntax (unless skill is language-specific)
- ❌ Project-specific references in portable skills (file names, class names, domain terms)

**Distribution boundary:** Portable skills must pass the generic-content checks below.
Repository-only skills may name this repository's paths and workflows; keep those details and
private supporting files under its private skill root. Verify local references resolve from the
selected location; do not copy private support material into portable assets.

**ZERO TOLERANCE for Project Leakage in Portable Skills:**

Before writing skill, verify:
- [ ] No project-specific file/module/class names in examples
- [ ] No domain-specific business terms
- [ ] Examples use generic placeholders only
- [ ] Skill works for ANY project type (web/CLI/embedded/mobile)
- [ ] High-level instructions only - Junior knows how to implement

**Test:** "Would this skill work in a completely different codebase tomorrow?"

### Step 5: Generate Skill File

**For:** the new `SKILL.md` is read by Junior at invocation, not by an end user. It answers *what to
do, in what order, and what to produce.* The `README.md` describes portable skills for
users. Distribution and discovery follow Step 6 below.

**Create skill file structure (Mode A - high-level only):**

```markdown
# [Skill Name]

## Purpose
[From contract]

## When to Use
[Scenarios]

## Process

### Step 1: Initialize Progress Tracking
[todo_write structure]

### Step 2: [Main workflow steps]
[From contract]

## Output Spec
[What the skill's artifact is for, what goes in, what never does, register]

## Tool Integration
[Tools and commands]

## Examples
[Usage examples]
```

**The Output Spec section is required for any skill that writes something a human reads** — a
`.junior/` document, a file in the repository, or a report printed at the user. A skill that
specifies how to think and never what to print makes the thinking become the artifact: with no
stated contents, the run fills the document with whatever it was holding, which is its own
reasoning and provenance.

Three parts, in this order, per artifact the skill writes:

1. **What this artifact is for** — who reads it and what question it answers for them. First and
   separate: separating reasoning from artifact is a different question from whether the content
   belongs in this artifact at all, and getting only the first produces a cleaner document that is
   still about the wrong things.
2. **Goes in** — the sections, and what each holds.
3. **Never goes in** — stated explicitly. An exclusion nobody wrote down is not a constraint.

Plus the register, in the same section: **headings are noun labels — never sentences, questions or
conversational phrases. Prose states facts. No editorial lead, no anthropomorphising, no dramatic
adjective.**

Write the exclusions into the skill itself rather than citing a rule elsewhere. A rule the run
must recall loses to a spec in the skill that produces the artifact. The common exclusions and
the reasoning behind them are in `../_shared/references/artifact-output-spec.md`; cite it as the
baseline, and state in the skill whatever else its own artifact attracts. Resolve the citation
from the generated skill's location: portable skills use the sibling reference; repository-only
skills can use `agents/skills/_shared/references/artifact-output-spec.md` as an explicit
repository-root path when present. Never assume `.agents/skills/_shared/` exists. Reuse the
shared source instead of copying it into the private skill root.

**Skill types determine structure:**

**Contract-style skills** (plan, research):
- Phase 1: Clarification loop
- Phase 2: Contract proposal
- Phase 3: File generation after approval

**Direct execution skills** (commit, refactor):
- todo_write initialization
- Step-by-step execution
- User confirmation at key points

**Language & Shell Agnostic** - Use `codebase_search` or `functions.shell_command`, `list_dir` or `functions.shell_command`, `grep` (via `functions.shell_command`) rather than language-specific commands. No assumptions about tech stack.

**Keep it high-level** - Junior knows how to use tools. Focus on WHAT to do, not detailed HOW.

**Write location (required):**
- Portable: `agents/skills/jr-[skill-name]/SKILL.md`.
- Repository-only: `.agents/skills/jr-[skill-name]/SKILL.md`.
- Use the approved contract's path; supporting files stay beside the skill. Do not create
  global copies or duplicate the skill across roots for discovery.

### Step 5.1: Frontmatter Description Convention (Required)

A skill body loads on invocation. Its description does not — it is resident in every
session whether the skill runs or not. That makes the description both a fixed context
cost and the only thing telling a runtime whether to invoke a workflow unprompted.

**Required form — exactly one sentence:**

```yaml
description: Run `/jr-[skill-name]` to [what the workflow does, as a verb phrase].
```

**The one-sentence rule is the whole control.** Situation phrasing — "use when...",
"helpful for...", "invoke at the end of a session", a list of utterances a user might
say — needs a second clause to put the situation in. Refusing the second sentence rules
out the class. A list of forbidden wordings only ever holds the phrasings whoever wrote
the list thought of, and the next author invents new ones.

**Required:**
- ✅ Exactly one sentence, ending in a single full stop
- ✅ Opens ``Run `/jr-[skill-name]` to ...``, naming its own invocation verbatim
- ✅ States what the workflow **does**, as a verb phrase
- ✅ Single-line plain scalar — never a folded (`>-`) or literal (`|`) block

**Forbidden:**
- ❌ A second sentence — that is where a trigger situation goes
- ❌ Saying *when* to run it inside the sentence (" when ", "whenever", "if the ...")
- ❌ Quoted user utterances — a runtime reads them as phrases to match what was typed
- ❌ A colon followed by a space — YAML truncates an unquoted scalar there, silently
- ❌ Restating the workflow's steps; the body already holds them

**Bounds:** 200 characters per description, and the set's mean must stay under 130. The
mean is what detects drift: it does not move when a conforming skill is added, and it
rises as soon as descriptions start growing back into prose.

**Where disambiguation belongs:** the body, not the description. A skill resolves by
the name the operator typed, so naming a sibling skill in a description spends
always-resident budget repeating what the body says in more detail.

**Why any of this:** a description naming a *situation* rather than a workflow reads to
a runtime as a standing instruction to self-invoke. Junior skills run when the operator
asks for them, not when a conversation drifts near their subject.

The test suite enforces all of the above, including against a real install of both
runtimes. Run it after authoring.

### Step 6: Distribution & Discovery Checks

**Portable:** Update `README.md` "Available Commands". Installation listings derive from
shipped `agents/skills/*/SKILL.md`; runtime installation mappings remain explicit. Keep descriptions
concise and grouping consistent. Verify the skill and its support files arrive in disposable
installs and are included by the public packaging manifest.

**Repository-only:** Do not add the skill to those portable command lists or installer assets.
Verify the repository's local runtime discovery points to `.agents/skills/` (including any
existing adapters or symlinks) without creating a second skill copy. Check the actual installer
inputs and public export manifest: neither the private skill nor its supporting files may be
included, directly or through an exported link. Inspect the diff for private-path leakage into
public documentation. If discovery is unavailable, report that limitation rather than moving
the skill to the portable root.

These scope checks are an authoring norm; the packaging and installation checks verify only
the concrete files tested. Do not claim that prose guarantees future author behavior.

### Step 7: Verify Project Leakage

**Portable skills:** Scan skill file for project-specific content.
**Repository-only skills:** Check project references are intentional, resolve locally, and
remain within the distribution boundary from Step 6; generic portability is not required.

For portable skills, check the generated skill file for:
- Project-specific file/module/class names
- Domain-specific business terms
- Specific feature names beyond generic patterns
- Project-specific file structures

**If leaks found:**
- Remove project-specific terminology
- Replace with generic placeholders
- Use abstract examples (feat-N, feature X, etc.)

**Allowed generic terms:**
- ✅ "feature", "story", "task", "bug", "improvement"
- ✅ "feat-N-name", "feat-1-overview.md"
- ✅ "user", "system", "product", "workflow"
- ✅ Abstract patterns (validation, processing, configuration)

### Step 8: Validate & Complete

**Validate skill:**
- Follows Junior patterns
- Uses `.junior/` structure correctly (if applicable)
- Clear tool integration (high-level, not detailed patterns)
- Examples match the approved distribution scope
- Language & shell agnostic
- **Mode A appropriate** - triggers and workflow, not implementation manual
- Distribution and discovery checks pass; portable content has no project leakage
- **Output Spec present** for every artifact the skill writes, with all three parts and the
  register. A skill that writes nothing a human reads says so; a skill that writes something
  and has no Output Spec is not finished.

**Present result:** Name the created skill's actual path, distribution scope, and invocation.
For portable skills, report command-list and disposable-install checks. For repository-only
skills, report local discovery and installer/public-export exclusion checks. State any
unverified runtime discovery explicitly. Do not imply README or installer registration was
performed for a private skill.

## Skill Naming Rules

**Format:**
- Lowercase letters, numbers, hyphens only
- No spaces or special characters
- Maximum 20 characters
- Cannot start with number or hyphen
- Must not conflict with existing skills

**Examples:**
- ✅ `plan`, `research`, `refactor`
- ❌ `Plan`, `do_research`, `CreatePlan`

## Tool Integration

**Primary tools:**
- `todo_write` or `functions.update_plan` - Progress tracking
- `list_dir` or `functions.shell_command` - Scan existing skills
- `write` or `functions.apply_patch` - Create skill file
- `read_file` or `functions.shell_command` - Reference existing skills

**agent tools for generated skills:**
- `codebase_search` or `functions.shell_command` - Search codebase
- `run_terminal_cmd` or `functions.shell_command` - Execute commands
- `grep` (via `functions.shell_command`) - Search files
- `read_file` or `functions.shell_command` - Read files
- `search_replace` or `functions.apply_patch` - Edit files
- `write` or `functions.apply_patch` - Create files

## Examples

**Create deployment skill:**
```
User: /jr-new-skill
Junior: What skill would you like to create?
User: deploy skill for production deployment
Junior: [Asks clarifying questions...]
Junior: What deployment steps are needed?
User: Build, run tests, push to registry, deploy to k8s
Junior: [Presents contract...]
User: yes
Junior: ✅ Skill created at agents/skills/jr-deploy/SKILL.md
```

**Create database migration skill:**
```
User: /jr-new-skill
Junior: What skill would you like to create?
User: migrate skill to handle database migrations
Junior: [Clarification loop...]
Junior: Should this handle both up and down migrations?
User: Yes, and show migration status
Junior: [Contract with recommendations...]
User: yes
Junior: ✅ Subcommand contract created for /jr migrate and saved to agents/skills/jr/references/subcommands/migrate.md
```

---

Build skills that follow Junior principles: simple, clear, purposeful.
