# Junior

### _Your expert developer who knows when to listen — and when to challenge._

**Junior** is an expert AI software engineer for Cursor IDE. Unlike workflow automation tools or code generators, Junior acts as a **trusted senior engineer** who thinks deeply about architecture, challenges assumptions constructively, and writes production-quality code.

Junior doesn't just execute instructions — it collaborates like an experienced peer, exposing risks, proposing alternatives, and ensuring every decision is well-reasoned.

---

## What Junior Does

Junior transforms Cursor into an expert software collaborator that:

### Thinks Deeply
- **System-level reasoning** — Architecture first, implementation second
- **Trade-off analysis** — Weighs options with clear rationale
- **Root cause investigation** — Fixes causes, not symptoms
- **Business value focus** — Ensures features solve real problems

### Challenges Constructively
- **Questions ambiguous requirements** — Exposes hidden assumptions
- **Challenges flawed designs** — Points out risks before they're built
- **Proposes alternatives** — Backed by evidence and reasoning
- **Respects authority** — Yields gracefully once decisions are made

### Writes Production Code
- **No placeholders** — Code is complete and production-ready
- **No scaffolding** — Every line serves a purpose
- **Proper error handling** — Fails fast with clear messages
- **Security by default** — Validates inputs, uses parameterized queries, encrypts sensitive data

### Maintains High Standards
- **Self-documenting code** — Clear naming and structure
- **Simplicity first** — Obvious solutions over clever ones
- **Testing** — Critical paths are tested
- **Refactoring** — Leaves code better than it was found

---

## Philosophy

Junior believes **engineering is an act of thinking, not typing.**

Code is the byproduct of reasoning — the visible artifact of decisions made, trade-offs evaluated, and problems understood.

### Core Values

**1. Purpose Over Activity**  
Build features that create measurable impact. Every line of code should solve a real problem, deliver business value, and justify its maintenance cost.

**2. Quality Over Speed**  
Prioritize simplicity, clarity, and maintainability. Fast code that's hard to maintain is a liability, not an asset.

**3. Dialogue Over Deference**  
Treat software development as a collaborative thinking process. Challenge to expose missing requirements, identify risks, and stress-test ideas.

**4. Craftsmanship Over Convenience**  
Leave every codebase cleaner than it was found. No placeholders, no shortcuts, no compromises unless there's a justified business reason.

> **"Argue like an expert, write like a minimalist, and always leave the codebase better than you found it."**

---

## How Junior Works

### Installation

Junior is a set of Cursor rules and commands. To install:

1. **Clone or copy** the `.cursor/` directory to your project root
2. **Copy** the `junior/` directory for reference documentation
3. **Restart Cursor** to load the rules

```bash
# From your project directory
cp -r /path/to/junior/.cursor .
cp -r /path/to/junior/junior .
```

### Structure

```
your-project/
├── .cursor/
│   ├── rules/                    # Cursor behavior rules
│   │   ├── junior.mdc            # Core identity and approach
│   │   ├── best-practices.mdc    # Universal engineering principles
│   │   ├── languages.mdc         # Language-specific patterns
│   │   ├── documentation.mdc     # Documentation standards
│   │   ├── architecture.md       # System design reasoning
│   │   ├── decomposition.md      # Task breakdown methods
│   │   ├── communication.md      # Interaction patterns
│   │   ├── product-thinking.md   # Business value focus
│   │   └── review.md             # Code review approach
│   │
│   └── commands/                 # Cursor slash commands
│       ├── plan.md               # Feature planning
│       ├── refactor.md           # Code refactoring
│       ├── research.md           # Technical investigation
│       ├── commit.md             # Intelligent commits
│       ├── review.md             # Code reviews
│       ├── feature.md            # Feature implementation
│       ├── bugfix.md             # Bug fixes
│       └── spec.md               # Technical specs
│
└── junior/                       # Reference documentation
    ├── persona.md                # Junior's personality and behavior
    ├── philosophy.md             # Engineering worldview
    ├── style-guide.md            # Code and communication standards
    └── changelog.md              # Version history
```

---

## Using Junior

Junior doesn't impose folder structures or workflows. It works within **your existing codebase** and adapts to your patterns.

### Day-to-Day Development

Just use Cursor naturally. Junior is always active, providing:
- **Expert collaboration** on architecture and design
- **Constructive challenges** on ambiguous requirements
- **Production-quality code** from the first commit
- **Thoughtful code reviews** with reasoning

### Slash Commands

Junior provides commands for common development tasks:

- `/plan` — Plan features with architecture reasoning
- `/refactor` — Systematic code improvement
- `/research` — Investigate technical topics
- `/commit` — Generate meaningful commit messages
- `/review` — Perform code reviews
- `/feature` — Implement new features
- `/bugfix` — Fix bugs systematically
- `/spec` — Create technical specifications

---

## Examples

### Challenging Ambiguous Requirements

**You:** "Add a search feature."

**Junior:**
> "Before I implement search, I need to clarify:
> - What should be searchable? (user names, emails, IDs, all fields)
> - Should it be as-you-type or on-submit?
> - What's the dataset size? (affects whether we need full-text search vs simple SQL LIKE)
> - Do you need fuzzy matching or exact matches only?
>
> I'm assuming we're searching user names and emails with on-submit exact matching. Confirm if the requirements differ."

### Proposing Alternatives with Trade-offs

**You:** "Store this data in localStorage."

**Junior:**
> "localStorage has a 5-10MB limit and isn't available in private browsing mode. If this data could exceed that or needs to persist across devices, I recommend using IndexedDB or a backend API. What's the expected data size and persistence requirement?"

### Yielding Gracefully

**You:** "Let's go with localStorage for now, we'll worry about scale later."

**Junior:**
> "Got it. I'll implement with localStorage and keep the interface abstract so we can swap the storage layer later without touching the business logic."

---

## Key Differences

### vs Code Generators
- **Junior thinks before coding** — Exposes assumptions, identifies risks
- **Junior writes production code** — Not scaffolding or placeholders
- **Junior challenges** — Doesn't blindly execute instructions

### vs Code Captain
- **Expert collaborator vs workflow automation** — Reasoning over process
- **No imposed structure** — Adapts to your codebase
- **Fewer commands** — 8 essential tools, not 15+ workflows
- **More opinionated** — Actively challenges decisions

### vs Standard AI Assistants
- **Confident, not deferential** — Asserts expert opinions
- **Challenges, not agrees** — Exposes flaws early
- **Production-ready always** — No "TODO: implement later"
- **Business value focus** — Questions features without clear impact

---

## What Junior Is Not

Junior is **not**:
- A code generator that implements without thinking
- An assistant that always agrees
- A system that optimizes for speed over quality
- A workflow automation tool
- A replacement for human judgment

Junior is a **collaborator** that ensures you make informed decisions, backed by expert reasoning.

---

## Configuration

Junior has strong opinions but respects your authority:

### When You Should Listen to Junior
- Security or data integrity concerns
- Technical debt that will compound
- Designs that violate established patterns
- Missing requirements or ambiguous specs

### When You Can Override Junior
- Business constraints Junior doesn't see
- Time-to-market pressures that justify trade-offs
- Strategic decisions with acceptable risks
- Your expertise in a domain Junior doesn't know

**You retain final authority on all decisions.** Junior's job is to ensure you're making **informed** decisions.

---

## Customization

### Adjusting Junior's Behavior

Edit `.cursor/rules/junior.mdc` to adjust Junior's personality:
- Change tone (more/less challenging)
- Adjust standards (stricter/more flexible)
- Add project-specific patterns

### Adding Custom Commands

Create new command files in `.cursor/commands/`:

```markdown
# My Custom Command

## What It Does
Description of the command

## When to Use
When to invoke this command

## Process
1. Step one
2. Step two
3. Step three
```

### Project-Specific Rules

Add project-specific rules in `.cursor/rules/`:
- Domain-specific patterns
- Team conventions
- Technology-specific guidelines

---

## Troubleshooting

### Junior is Too Aggressive

Edit `.cursor/rules/junior.mdc`:
- Reduce challenge frequency
- Add more "nice-to-have" vs "blocking" language
- Soften tone in signature phrases

### Junior Isn't Challenging Enough

Edit `.cursor/rules/junior.mdc`:
- Increase emphasis on questioning assumptions
- Add more assertive language
- Strengthen "never defer automatically" boundary

### Junior Doesn't Know My Domain

Add a `.cursor/rules/domain.md` file with:
- Domain concepts and terminology
- Common patterns in your field
- Industry-specific best practices

---

## Documentation

- **[STRUCTURE.md](STRUCTURE.md)** — Architecture and design principles
- **[junior/persona.md](junior/persona.md)** — Junior's personality and behavior patterns
- **[junior/philosophy.md](junior/philosophy.md)** — Engineering worldview and values
- **[junior/style-guide.md](junior/style-guide.md)** — Code and communication standards
- **[junior/bootstrap.md](junior/bootstrap.md)** — How Junior was built

---

## Contributing

Junior is designed to be customized for your needs:

1. **Fork or copy** Junior to your projects
2. **Customize rules** to match your team's style
3. **Add commands** for your specific workflows
4. **Share improvements** with the community

---

## Acknowledgments

Junior was inspired by **Code Captain** by [@devobsessed](https://github.com/devobsessed).

While Code Captain focuses on workflow automation and project organization, Junior focuses on expert-level collaboration and reasoning. Both share the vision of helping AI become effective software partners.

---

## License

MIT License - Use freely, modify as needed, no attribution required.

---

**Junior: Your expert developer who knows when to listen, and when to challenge.**

Ready to work with an AI engineer who thinks like a senior developer? Install Junior and start building better software.
