---
name: jr-feedback
description: Run `/jr-feedback` to save and verify a submission-ready Junior improvement proposal.
---

# Junior Feedback

## Purpose

Deliver useful feedback about Junior's rules, skills, installer, or workflows as a
verified file. The user chooses whether and where to submit it. Application-specific
work stays in its existing project tracking.

## Process

1. Identify the Junior behavior and desired outcome. Read relevant source and evidence;
   resolve installed files to their authoring paths. Ask only when the improvement is
   unclear. For application-only work, explain the boundary and use its existing tracking
   rather than inventing a Junior proposal.
2. Prepare a concise, sanitized UTF-8 Markdown proposal using the artifact contract
   below. Distinguish verified evidence from proposed changes and unverified claims.
   Retain this complete prepared content until delivery is verified.
3. Select an authoring checkout already identified by the user or session, when known.
   Verify its repository identity from contributor guidance and Git remotes when available,
   and its source layout (`agents/rules/00-junior.md`, `scripts/junior.py`, and shipped
   `agents/skills/`). Installed runtime trees and publish targets are not authoring checkouts.
   Do not search the machine, infer identity from a directory name, or use discovered
   feedback paths to choose a checkout. An invalid or inaccessible selected checkout is
   a visible delivery failure; do not silently reroute it.
4. For a verified checkout, select its `.junior/docs/` directory. With no known checkout,
   select the user's `~/.junior/inbox/`. This fallback is created only for explicitly
   requested feedback; it is not general project memory or installer-owned storage.
5. For creation, invoke the shipped `scripts/write_feedback.py` from this skill's actual
   loaded directory. Pass `--directory` with the absolute selected directory and
   `--subject` with a lowercase ASCII slug (letters/digits separated by hyphens, at most
   80 characters). Supply the complete prepared UTF-8 content through stdin. Use a structured
   subprocess input or a safely quoted input file; never interpolate proposal text as shell
   code. The writer creates parents, exclusively chooses `feedback-<subject>.md` or a
   distinct numbered filename, and verifies the exact saved bytes. Do not replace it with
   a freehand write. It runs with Python 3.10+ and no source-checkout imports.
6. Inspect the process exit and structured JSON. Claim delivery only for exit zero with
   `ok: true`, the actual absolute `path`, and the verified byte count. A nonzero exit,
   `ok: false`, invalid output, or missing tool result is a failure. Report the error and
   any partial path, retain the prepared draft for retry, and make no saved-file claim.
   If access is blocked, request only the missing access or an explicitly chosen alternate
   destination. Do not delete partial files, automatically retry, or fall back elsewhere.
7. For a revision explicitly selecting an existing proposal, read that file first, apply
   only the requested edit, preserve unrelated content, and compare the complete readback
   with the intended bytes. The creation writer never overwrites. Apply the same truthful
   failure contract; revision is not permission to change neighboring proposals.
8. On success, state that feedback is saved and ready for the user to submit. Include the
   actual absolute clickable path and one next action: review that file and submit through
   the user's chosen contribution channel. Leave it uncommitted. Preparation and local
   delivery authorize no implementation, staging, commit, submission, messaging, session
   creation, status stamp, move, or archival. An explicit external submission request uses
   an available authorized tool; report its verified result or the missing capability.

`/jr sync` discovers and assesses delivered proposals through its bounded
[feedback assessment workflow](../jr/references/subcommands/sync.md#step-3-discover-feedback-and-inspect-installation-state),
including the known global inbox even when installed assets have no changes. Assessment
does not authorize implementation or submission. Whole-home discovery is not part of
delivery. No startup reader, automatic collection, or required lifecycle is introduced;
existing handoff documents and archives remain untouched.

## Output Spec

**Artifact — the improvement proposal.** For maintainers deciding what should change
and how to verify it without reconstructing the originating conversation.

- **Objective:** the Junior behavior to improve, desired outcome, and bounded scope.
- **Evidence:** expected and observed behavior, runtime/version when known, a sanitized
  reproduction, relevant source paths, and actual checks/results. Label unverified claims.
- **Proposal:** the correction or decision needed, dependencies, and verification requirements.
  Keep proposal status distinct from authorization to implement.
- **Continuation:** one entry point for the receiving maintainer or the user's submission.

Exclude transcripts, credentials, private application details, personal paths, machine-specific
delivery locations, invented results, speculative diagnoses presented as facts, unrelated
backlog, lifecycle paperwork, and release approval claims. Delivery paths belong in the
response, not proposal content. Baseline: [artifact output](../_shared/references/artifact-output-spec.md).
Headings are noun labels; prose states facts.
