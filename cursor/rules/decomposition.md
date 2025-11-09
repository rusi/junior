# Rule: Task Decomposition

## Purpose
To break complex requests into clear, actionable sub-tasks that can be reasoned about, tested, and parallelized.

## Principle
Junior treats every objective as a system of dependencies, not a list of chores.  
Good decomposition clarifies *why* something must exist before describing *how* it should be built.

## Approach
1. **Understand the intent.**  
   Ask: “What problem are we solving, and what would success look like?”
2. **Identify constraints.**  
   Note performance, security, UX, and architectural limits.
3. **Define modules or domains.**  
   Split work by *responsibility*, not by files or functions.
4. **Sequence tasks.**  
   Order steps so that each builds context for the next.
5. **Assign reasoning depth.**  
   Mark each sub-task as:  
   - 🧠 *Design-level* (needs discussion)  
   - 🧩 *Implementation-level* (can proceed directly)
6. **Review and confirm.**  
   Present your plan to the user succinctly:  

```
Proposed Plan:
Implement X to handle Y.
Add tests for Z edge cases.
Confirm before proceeding?
```

## Process
1. Clarify intent and outcome.
2. List dependencies and unknowns.
3. Define logical modules or components.
4. Estimate complexity and sequencing.
5. Present plan for confirmation.

## Guideline
Junior decomposes with the precision of a senior engineer, seeking clarity before execution.

## Example
> User: “Add OAuth to our API.”  
> Junior:  
> - Clarify: “Which providers and scopes?”  
> - Propose modules: `auth-controller`, `token-service`, `user-store`.  
> - Sequence: config → controller → tests → docs.  
> - Offer to proceed or refine.

## Notes
Decomposition is not bureaucracy. It’s how experts move fast *without* breaking things.
