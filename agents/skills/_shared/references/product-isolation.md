# Product Isolation Checks

The canonical boundary is **Product Isolation** in `01-structure.md`, resolved in the
selected runtime's rule directory. This reference supplies execution, not a second policy.

## Candidate Review

Read the product output for indirect workflow references, copied helper dependencies,
private links, metadata, and provenance. Open generated media and inspect visible text.
Exercise the product and follow its documentation in a disposable copy without `.junior/`;
never delete the user's working material for this check. Keep findings and review decisions
in the existing working specification, not in the product being checked.

Locate `../scripts/product_isolation.py` relative to this reference. Use the project's
Python runner (Python 3.10+) and pass the repository explicitly. The examples use `python3`;
`<checker>` means the resolved script path, not a script copied into product tooling.

```sh
python3 <checker> --repo <repository> tree
python3 <checker> --repo <repository> tree --ref <candidate-commit>
python3 <checker> --repo <repository> range --base <explicit-base> --head <candidate-commit>
python3 <checker> --repo <repository> staged --message-file <message-file>
```

- `tree` reads every tracked and nonignored new working-tree file, including unchanged
  files. A commit reference instead reads the complete Git tree. Ignored, untracked build
  output must be separately inspected in its release/staging repository before delivery.
- `range` requires an explicit ancestor base; it inspects every pending commit, including
  merge commits, with each complete tree, complete changed-file list, and raw stored message.
  Message review hashes use those bytes without display formatting or encoding conversion. Resolve
  the intended base from user input or repository evidence; never invent one to get a pass.
  Without one, report history unchecked and make no branch-history cleanliness claim.
- `staged` reads actual index blobs and the full proposed message file. It rejects mixed
  product/working-material groups even if they contain only docs or media. Renames inspect
  both paths. A tracking-only group's message may retain identifiers, but its candidate
  product tree is still checked. Empty groups/messages and unmerged indexes refuse.

JSON reports the source, snapshot digest, file inventory, findings, applied reviews, and
binary files requiring manual inspection. Ranges also report resolved endpoints and per-commit
findings. Exit zero means no unresolved literal findings, not semantic or rendered clearance.
Git/input errors return nonzero; unsupported submodules require checking their repositories
separately and remain a gap. Symlink targets are scanned as bytes, never followed as content.

## Resolving Findings

Read each reported `path` and `line` in context. A finding is a literal match, not a verdict:

- Actual private dependencies or workflow leakage: correct the product content or move
  working material out of it. For mixed commits, separate the staged groups.
- Required runtime instructions or legitimate Junior product examples: record the exact
  classification described below in a review JSON file. Do not approve a real dependency.

Rerun the same check with `--review <review.json>` when using those decisions. Continue
only when `ok` is `true` and the semantic and rendered review above is complete. Preserve
historical findings for explicit resolution; a passing current tree does not repair history.

## Exact Review Decisions

The optional `--review <file>` reads JSON authored after content review. Store it under
`.junior/` when durable, or in the runtime scratch directory for one run. It contains
`runtime`, `product`, and `literal` arrays (any may be omitted), with these entry fields:

| List | Required fields | Scope |
| --- | --- | --- |
| `runtime` | `path`, `sha256`, `start`, `end`, `reason` | Exact runtime file and inclusive, one-based instruction lines |
| `product` | `path`, `sha256`, `line`, `rule`, `reason` | One `junior` or `command` finding with a concrete product purpose |
| `literal` | `path`, `sha256`, `line`, `rule`, `reason`, `independent` | One finding describing Junior product functionality or a source/test example; `independent` must be `true` |

`sha256` is the digest of the complete file's candidate bytes; compute it from the same
worktree, index blob, or commit blob being checked. `line: 0` means the filename. For a
product-purpose message decision use `path: "@message"` and the exact message-byte digest.
There are no wildcard paths, directory exemptions, or global brand switches. Changed bytes
require fresh review. Historical revisions may need separate digest-bound entries.

The runtime entry's path must be a supported surface; exact installed rules, skills and
support files are enumerated, not automatically trusted by directory. Mixed contributor
documents cannot be wholly exempted. Read all product guidance outside the identified
instruction section, and verify it has no runtime dependency. A stated reason is review
work product, not proof that the classification is correct.

The `literal` classification also supports `private-path`, `tracking`, and `metadata` rules.
For example, Junior's product documentation may explain that it stores planning files in
`.junior/`. Read the reference and its use before classifying it: the reason must explain
the product purpose, and `independent: true` affirms that it does not require this checkout's
private working material. A link to private setup instructions does not qualify. Move or
correct actual dependencies; do not encode strings or exempt whole repositories.

The checker validates each decision's schema, path, line, rule, and content digest. It cannot
verify the truth of a reason or independence assertion. That semantic classification remains
a review norm, as with runtime classification; a reviewed description grants no permission
to unrelated references or changed content. Accepted decisions appear in the report.

## Workflow Gates

Generation, implementation, refactoring, and test-writing workflows run `tree` after their
product writes and complete semantic review before handoff. Review workflows inspect the
whole candidate tree plus the explicit pending range when known, even if their other checks
focus on changed lines. Release-specific human review gates remain mandatory.

Before a commit, read the group's full file list and diff, write the complete proposed
message to a file, and run `staged`. A nonzero result stops the commit; correct the files,
grouping, message, or supported review decisions, then rerun. Commit using that same file
only after success. Do not change the index or message between validation and commit; if
either changes, revalidate. Inspect the actual resulting commit's files and message and
run the explicit single-commit range when a parent exists. Never rewrite history automatically.

The checker performs no writes or commit operations. Checks are enforced inside its
execution path; skill invocation, unchanged-input handoff to Git, and semantic review are
norms. Arbitrary tool use, concurrent writes, and hooks that alter a commit are not contained.
