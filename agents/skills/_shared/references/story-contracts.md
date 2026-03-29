# Story Contracts

Use this reference when presenting contracts for story-level changes. Keep structure intact and fill with project-specific details.

## Add Story Contract

```markdown
## Story Contract

**Feature:** feat-X - [Feature Name]
**New Story:** feat-X-story-{M+1} - [Story Title]

**Purpose:** [What this story adds to the feature]
**User Value:** [What user can now do after this story]
**Deliverable:** [User-visible, working, end-to-end output]

**Scope:**
- ✅ Included: [Specific capabilities this story delivers]
- ❌ Excluded: [Out of scope for this story]

**Vertical Slice Validation:**
- **DB:** [Database changes, if any - e.g., "Add field X to table Y"]
- **Backend:** [API/logic changes - e.g., "Endpoint Z returns new data"]
- **Frontend:** [UI changes - e.g., "Display shows new field"]
- **Tests:** [Test coverage approach - e.g., "Unit + integration + manual validation"]
- **User sees:** [Specific working output - e.g., "Working dashboard with filter controls"]

**Integration with Existing Stories:**
- **Depends on:** feat-X-story-Y for [reason]
- **Extends:** [existing capability] with [new capability]
- **Changes:** [any modifications to existing stories, if needed]

**Implementation Tasks (5-7 tasks):**
- [ ] {M+1}.1 [Task - TDD approach]
- [ ] {M+1}.2 [Task]
- [ ] {M+1}.3 [Task]
- [ ] {M+1}.4 [Integration with existing stories]
- [ ] {M+1}.5 [Verify acceptance criteria]

**⚠️ Impact Analysis:**
- Affects existing stories: [list any that need updates, or "None"]
- Breaks nothing: [confirmation]
- Integration points: [how this connects]

**Testing Strategy:**
- **Unit tests:** [What to test]
- **Integration tests:** [What to test]
- **Manual validation:** [What user tests]

---
Options: yes | edit: [changes] | discuss
```

## Update Existing Feature/Story Contract

```markdown
## Update Contract

**Target:** [feat-X or feat-X-story-Y]
**Current State:** [brief description of what exists]
**Requested Changes:** [what user wants to change]

**Proposed Updates:**
- Change 1: [specific modification]
- Change 2: [specific modification]

**Impact Analysis:**
- **Dependent Stories:** [which stories are affected]
- **Breaking Changes:** [what breaks, if anything]
- **Required Updates:** [other files/stories that need updates]
- **Regression Risk:** [low/medium/high with explanation]

**Contradiction Resolution:**
[If this update was needed to resolve contradictions, explain how]

**Updated Scope:**
- ✅ Still Included: [capabilities that remain]
- ✅ Now Included: [new capabilities]
- ❌ Now Excluded: [things being removed/descoped]

---
Options: yes | edit: [changes] | discuss
```
