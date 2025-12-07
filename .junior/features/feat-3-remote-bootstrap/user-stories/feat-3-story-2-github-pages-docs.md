# Story 2: GitHub Pages + Documentation

> **Status:** Not Started
> **Priority:** High
> **Dependencies:** Story 1 (need bash script to publish)
> **Deliverable:** Live GitHub Pages serving bootstrap script + clear README documentation

## User Story

**As a** developer discovering Junior
**I want** clear installation instructions with copy-paste commands
**So that** I can quickly install Junior without confusion

## Scope

**In Scope:**
- Enable GitHub Pages for Junior repository (serve from `/docs`)
- Verify `docs/install.sh` is accessible via github.io URL
- Update README with installation section
- Document fresh install vs update scenarios
- Document when to use bootstrap vs `.junior/update.sh`
- Include troubleshooting tips

**Out of Scope:**
- Custom domain setup (Story 4)
- PowerShell documentation (Story 3)
- Landing page / fancy docs site

## Acceptance Criteria

- [ ] Given GitHub Pages enabled, when user visits github.io URL, then install.sh is accessible
- [ ] Given user reads README, when looking for installation, then clear instructions are present
- [ ] Given fresh install scenario, when user follows README, then they successfully install Junior
- [ ] Given update scenario (old version), when user follows README, then they successfully update
- [ ] Given user has feat-2 update.sh, when reading docs, then they understand to use that instead
- [ ] Given user encounters error, when checking README, then troubleshooting tips help resolve issue

## Implementation Tasks

- [ ] 2.1 Enable GitHub Pages in repository settings (serve from `/docs`)
- [ ] 2.2 Verify docs/install.sh is accessible via github.io URL
- [ ] 2.3 Create README installation section with clear examples
- [ ] 2.4 Document fresh install, update (old), and update (new) scenarios
- [ ] 2.5 Add troubleshooting section with common issues

## Technical Notes

**GitHub Pages Setup:**
1. Repository Settings → Pages
2. Source: Deploy from branch
3. Branch: main, Folder: /docs
4. URL: `https://USER.github.io/junior/install.sh`

**README Structure:**
```markdown
## Installation

### Fresh Install

cd /path/to/your/project
curl -LsSf https://USER.github.io/junior/install.sh | sh

### Updating Junior

If you have an older version (no .junior/update.sh):
cd /path/to/your/project
curl -LsSf https://USER.github.io/junior/install.sh | sh

If you have .junior/update.sh:
cd /path/to/your/project
./.junior/update.sh

### Troubleshooting

- Error: "curl: command not found" → Install curl or use wget
- Error: "tar: command not found" → Install tar
- ...
```

**Documentation Checklist:**
- Clear, copy-paste commands
- Explain current directory behavior (user must cd first)
- Show expected output/success message
- Link to GitHub issues for problems
- Note about using `.junior/update.sh` when available

See [specs/01-Technical.md](../specs/01-Technical.md) for detailed technical approach.

## Testing Strategy

**Manual Testing:**
- [ ] Verify GitHub Pages URL works in browser
- [ ] `curl https://USER.github.io/junior/install.sh` returns script
- [ ] Test installation commands from README (fresh user perspective)
- [ ] Check all links in documentation work
- [ ] Verify troubleshooting tips are accurate

**User Testing:**
- Have someone unfamiliar with Junior follow README instructions
- Gather feedback on clarity, completeness
- Iterate on confusing sections

## Definition of Done

- [ ] All tasks completed
- [ ] All acceptance criteria met
- [ ] GitHub Pages serving docs/install.sh successfully
- [ ] README has clear installation section
- [ ] Fresh install scenario documented and tested
- [ ] Update scenarios documented (old vs new)
- [ ] Troubleshooting section helps resolve common issues
- [ ] **Public can access script and successfully install Junior following README**
- [ ] No broken links in documentation
- [ ] Documentation reviewed for clarity

