# Story 13: Add Cross-References to Remaining Rules

> **Status:** Not Started
> **Priority:** Low
> **Dependencies:** None
> **Deliverable:** Cross-references added to remaining 2 rules

## Developer Story

**As a** maintainer of Junior rules
**I want** remaining rules to have cross-references
**So that** all rules are consistently cross-referenced

## Current State

**What's wrong:**
- 2 remaining rules lack cross-references

**Remaining rules:**
- `02-current-date.mdc` - Date handling
- `architecture-document-template.md` - Template file

## Target State

**What improved code looks like:**
- Both files have dependencies if applicable
- Cross-references to related rules
- Complete cross-reference network

## Scope

**In Scope:**
- Add dependencies to 2 remaining rules
- Complete cross-reference network

**Out of Scope:**
- Changing content

## Acceptance Criteria

- [ ] Given 2 rules, when updated, then dependencies added if applicable
- [ ] Given all 9 rules, when reviewed, then complete cross-reference network exists

## Implementation Tasks

- [ ] 13.1 Update `02-current-date.mdc` - add dependencies if applicable
- [ ] 13.2 Update `architecture-document-template.md` - add dependencies (references `12-software-architecture-document-guide.mdc`)
- [ ] 13.3 User review

## Verification Checklist

- [ ] 2 rules updated
- [ ] Complete network verified
- [ ] User reviewed

## Definition of Done

- [ ] All tasks completed
- [ ] 2 remaining rules updated
- [ ] Complete cross-reference network
- [ ] User reviewed
- [ ] **All 9 rules cross-referenced**

