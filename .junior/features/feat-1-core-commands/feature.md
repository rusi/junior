# Complete Junior's Core Command Set

> Created: 2025-11-10
> Status: In Progress
> Contract Locked: ✅

## Feature Contract

**Feature:** Complete Junior's Core Command Set

**User Value:** Transform Junior from planner into full development partner with complete development lifecycle: plan → research → validate → build → track → commit → deploy

**Hardest Constraint:** Maintaining Junior's expert persona and 15 core principles across all commands while adapting Code Captain's reference implementations

**Success Criteria:** 
- User can execute complete feature workflows end-to-end
- All commands follow TDD, vertical slices, and simplicity principles
- Every feature automatically captures future work as actionable stories
- Easy migration path from Code Captain to Junior

**Scope:**

✅ **Included:**
- Update `/feature` to generate future work story automatically
- Core execution: `/implement`, `/status`
- Investigation: `/research`, `/experiment`, `/prototype`
- Project management: `/init`, `/migrate`, `/idea`
- Maintenance: `/bugfix`, `/enhancement`, `/update-feature`
- Installation script for easy deployment

❌ **Excluded:**
- Feature/story editing commands (`/edit-feature`, `/update-story`)
- Specialized commands (`/explain-code`, `/create-adr`, `/review`)
- Multi-language initialize variants (`/initialize-python`, etc.)
- Advanced product planning features

**Integration Points:**
- Extends existing `.cursor/commands/` structure
- Uses existing `.junior/` working memory
- Integrates with current `/commit` workflow
- Leverages existing rule system (`00-junior.mdc`, `01-structure.mdc`, `02-current-date.mdc`)

**⚠️ Technical Concerns:**
- Large scope (11 commands + installation) - must maintain quality across all
- Reference commands use `.code-captain/` and `spec-N` naming - requires careful adaptation
- Each command needs thorough testing to ensure it follows Junior's principles

**💡 Recommendations:**
- Build commands in priority order (core workflow first)
- Test each command immediately after implementation
- Use `/new-command` as template for consistency
- Keep each story focused on single command (vertical slice)

## Detailed Requirements

### Functional Requirements

**Command Development:**
- Each command must follow the structure established by `/feature`, `/commit`, and `/new-command`
- All commands must support Junior's contract-first approach (clarification → contract → approval → generation)
- Commands must include comprehensive tool usage patterns
- Commands must enforce Junior's 15 core principles
- All commands must use `todo_write` for progress tracking

**Future Work Integration:**
- `/feature` command must automatically generate a final story for future enhancements
- Future work story must capture out-of-scope items from contract phase
- Future work items must be actionable (not just documented)
- Story template must include sections for technical debt, follow-up work, and enhancement opportunities

**User Review Phase:**
- `/feature` command must include review/refinement phase after initial generation
- Allow user to update stories, specs, or contract based on review
- Support iterative refinement until user confirms "ready"
- Final consistency review only runs after user confirms readiness
- Track review iterations and changes

**Workflow Commands:**
- `/implement` - Execute feature stories with TDD workflow (test-first, implement, verify)
- `/status` - Display git state, active work, all features, next actions with smart suggestions
- Commands must maintain vertical slice approach throughout execution

**Investigation Commands:**
- `/research` - Generate research documents with findings in `.junior/research/`
- `/experiment` - Create throwaway validation experiments in `.junior/experiments/`
- `/prototype` - Build user-facing MVPs in actual codebase that can evolve to production
- Clear distinction between throwaway (experiment) and evolutionary (prototype) code

**Project Management Commands:**
- `/init` - Bootstrap projects combining initialize + product planning workflows
- `/migrate` - Convert Code Captain projects to Junior structure (`.code-captain/` → `.junior/`, `spec-N` → `feat-N`)
- `/idea` - Capture product ideas in `.junior/ideas/` without disrupting current workflow

**Maintenance Commands:**
- `/bugfix` - Bug-specific workflow with reproduction steps and verification
- `/enhancement` - Lighter-weight than features for small improvements

**Installation Infrastructure:**
- Adapt `install-cursor.sh` for Junior naming conventions
- Update `install-config.json` for Junior directory structure
- Support macOS, Linux, and Windows (PowerShell) platforms
- Detect and preserve existing Junior installations

### Non-Functional Requirements

**Performance:** 
- Commands should complete clarification phase in <2 minutes
- File generation should complete in <30 seconds
- Status command should display results in <5 seconds

**Security:**
- No hardcoded paths or credentials
- Respect `.gitignore` patterns
- Validate user input before file operations

**Scalability:**
- Support projects with 100+ features
- Handle large codebases (10k+ files)
- Efficient codebase scanning and search

**Accessibility:**
- Clear, scannable output format
- Progress indicators for long operations
- Helpful error messages with recovery suggestions
- Consistent command structure and patterns

## User Stories

See [user-stories/README.md](./user-stories/README.md) for implementation breakdown.

## Technical Approach

See [specs/01-Technical.md](./specs/01-Technical.md) for detailed technical approach.

**High-level strategy:**
- Adapt Code Captain reference commands to Junior's structure and persona
- Maintain contract-first approach across all commands
- Use TDD throughout: write command logic, test with actual usage, verify output
- Follow vertical slices: each story delivers one complete, working command
- Build in priority order: execution → tracking → investigation → management → infrastructure

**Key integration points:**
- All commands integrate with `.junior/` working memory structure
- Commands respect existing rule system (00-junior.mdc, 01-structure.mdc, 02-current-date.mdc)
- Installation script creates proper directory structure and copies files
- Migration command preserves existing work while converting structure

**Testing approach:**
- Unit testing: Command logic and file generation
- Integration testing: Commands working with actual `.junior/` structure
- End-to-end testing: Complete workflows (plan → implement → commit)
- Manual validation: Each command tested immediately after implementation

## Dependencies

**External Tools:**
- Cursor editor with command support
- Git for version control
- `jq` for JSON parsing in installation scripts
- `date` command for timestamp generation

**Internal Dependencies:**
- Existing commands: `/feature`, `/commit`, `/new-command`
- Rule system: `00-junior.mdc`, `01-structure.mdc`, `02-current-date.mdc`
- `.junior/` directory structure

**Reference Implementation:**
- Code Captain commands in `reference-impl/cursor/commands/`
- Installation scripts in `reference-impl/scripts/`
- Migration guide in `reference-impl/cursor/docs/migration-guide.md`

## Risks & Mitigations

**Risk: Scope Creep**
- Mitigation: Strict adherence to contract scope, exclude refinement commands for later
- Focus on core workflow first (Stories 1-6), then expand

**Risk: Inconsistent Command Quality**
- Mitigation: Use `/new-command` template, test each immediately after creation
- Follow established patterns from existing commands

**Risk: Reference Commands Don't Map Cleanly**
- Mitigation: Adapt rather than copy, maintain Junior's principles over Code Captain structure
- Challenge complexity, simplify where possible

**Risk: Installation Script Breaks Existing Projects**
- Mitigation: Detect existing installations, preserve user customizations
- Thorough testing across platforms before deployment

**Risk: Migration Command Data Loss**
- Mitigation: Backup detection, dry-run mode, clear rollback instructions
- Comprehensive testing with sample Code Captain projects

## Success Metrics

**Completeness:**
- All 12 stories implemented and working
- Installation script tested on macOS, Linux, Windows
- Migration script successfully converts Code Captain project

**Quality:**
- Each command follows Junior's 15 principles
- All commands use contract-first approach
- TDD workflow maintained throughout
- Vertical slices deliver working output after each story

**Usability:**
- User can complete feature workflow: `/feature` → `/implement` → `/commit`
- User can complete research workflow: `/research` → `/experiment` → findings
- User can bootstrap new project with `/init`
- User can capture ideas without disrupting flow with `/idea`

**Documentation:**
- Every command has clear purpose, process, and examples
- Installation instructions are clear and tested
- Migration guide is comprehensive and safe

## Future Enhancements

**Feature/Story Editing:**
- `/edit-feature` - Modify existing feature specifications
- `/update-story` - Reorganize and refine user stories
- `/split-story` - Break large stories into smaller vertical slices

**Specialized Commands:**
- `/review` - Code review workflow with quality checks
- `/explain-code` - Generate code explanations and documentation
- `/adr` - Architecture Decision Record creation

**Advanced Features:**
- Multi-language initialization presets (`/init-python`, `/init-node`, etc.)
- Team collaboration features (shared `.junior/` conventions)
- Metrics and analytics on feature completion rates
- AI-suggested optimizations based on project patterns

**Quality of Life:**
- Command aliases (`/impl` for `/implement`, `/exp` for `/experiment`)
- Interactive mode for all commands
- Better progress visualization during long operations
- Undo/rollback capabilities for command operations

