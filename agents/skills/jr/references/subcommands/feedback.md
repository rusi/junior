# Subcommand: /jr feedback

## Purpose

Prepare useful feedback about Junior's rules, skills, installer, or workflows for its
maintainers. The user chooses submission or delivery to a known local Junior source
checkout. Application work stays in its existing project tracking.

## Process

1. Identify the Junior behavior and desired outcome from the user's request. Read the
   relevant rules, skills, code, and verification; resolve installed files to their
   authoring paths. Ask only when the improvement itself is unclear.
2. Prepare a concise proposal using the artifact contract below. Include runtime and
   Junior version when known. Distinguish verified evidence from proposed changes or
   unverified claims. Remove secrets, personal paths, private application details, and
   unnecessary examples; retain a minimal reproduction when applicable.
3. Use a local Junior authoring checkout already identified by the user or session when
   available. Verify its known repository identity and source layout, including
   `agents/rules/00-junior.md` and `scripts/junior.py`. Installed runtime directories and
   publish targets are not authoring checkouts. Do not search the machine for a destination.
4. For local delivery, inspect `.junior/docs/feedback-<subject>.md` before writing. Create
   parents on demand and use exclusive creation for a new file; choose a distinct name
   on collision. Revise an existing document only when the user identifies it for revision.
   Preserve unrelated content. Verify the saved bytes and report the absolute path.
5. Without a usable checkout, return submission-ready Markdown in the conversation, or
   save it at a user-selected path when requested. If delivery fails, explain the failure
   and retain the prepared content. Never create a global fallback or managed inbox.
6. Leave the proposal uncommitted and identify one concrete next action. The user can
   review and submit the text through their chosen contribution channel, or explicitly
   direct work from the local document. Preparing or delivering feedback does not
   authorize implementation, staging, commits, external submission, messages, or starting
   another session. If the user explicitly requests external submission, use an available
   authorized tool for that destination; report its verified result or the missing capability.

Feedback is read when the user directs work to it. There is no automatic startup discovery,
collection, status tracking, consumption stamp, or required archive move. Existing handoff
documents remain untouched and can be selected explicitly like other project documents.

## Output Spec

**Artifact — the improvement proposal.** For Junior's maintainers deciding what should
change and how to verify it without reconstructing the originating conversation.

**Goes in:**
- **Objective:** the Junior behavior to improve, desired outcome, and bounded scope.
- **Evidence:** expected and observed behavior, runtime/version when known, a sanitized
  reproduction, relevant source paths, and actual checks/results. Label unverified claims.
- **Proposal:** the correction or decision needed, dependencies, and checks that establish
  completion. Keep proposal status distinct from authorization to implement.
- **Continuation:** one entry point for the receiving maintainer or the user's submission.

**Never goes in:** transcripts, credentials, private application details, machine-specific
delivery paths, invented verification, speculative diagnoses presented as facts, unrelated
backlog, lifecycle paperwork, or release approval claims.
Baseline: `../../../_shared/references/artifact-output-spec.md`.

Headings are noun labels — never sentences, questions, or conversational phrases. Prose
states facts. No editorial lead, no anthropomorphising, no dramatic adjective.
