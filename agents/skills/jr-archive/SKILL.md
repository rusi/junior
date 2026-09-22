---
name: jr-archive
description: Run `/jr-archive` to check completeness and persistence, then report readiness for the user to archive the session manually.
---

# Archive — is this session complete + persisted, safe to close?

## Purpose

Chat is session-bound and fragile — a closed tab or a context reset and it's gone. Before the user closes
a work session, this is the **last gate**: verify everything is **(1) COMPLETE**, **(2) PERSISTED to
durable project files**, and **(3–5) CHECKED against the things those two structurally cannot see**, so nothing of value
evaporates when the chat ends — and nothing ships carrying a defect the project has already named.

It answers one question plainly — *"can I archive this session?"* — **yes** (safe to close) or **no, here
are the gaps** (close them, or hand off, first). Keep it **simple and honest**: a quick real check, not a
ritual.

## Type

Direct execution of the readiness review — no parameters. Deliver the verdict with
Done, Next, and Decide (only when needed), then stop and leave the session visible.
Actual archival is manual and belongs to the user. Invoking `/jr-archive`, including
phrases such as “archive this one,” does not authorize archiving, hiding, closing, or
deleting the session through an app tool, API, CLI, or UI action. A safe verdict is
information for the user, not permission for an automatic follow-up action.

## Step 0 — Ground the verdict in the PROJECT STATE first (before any of the five questions)

All five checks below answer to **what is on disk, not what the conversation claimed.** A session can be pure
discussion, and the chat's framing can be stale in both directions: something the user calls *"still to
do"* may already be **done in the repo**; something that *feels* captured may live **only in this chat**.

So before you verdict, **go look**:

```bash
git status --porcelain                # uncommitted / untracked work
git log --oneline -5                  # what actually landed
git diff --stat                       # size and shape of unsaved changes
```

…and read the files this session bears on — the spec/story files it touched, the docs, the code, the
roadmap, any TODO/notes file the project keeps. Then ground ALL the questions in what you **SEE**.

**Question 2 is the exception.** A chat-only artifact leaves no disk trace, so a disk-first sweep cannot
find what was never written. Question 2 alone runs conversation → disk; see `### 2. Persisted?`.

Persist workflow findings in working material under **Product Isolation** in `01-structure.md`.
Do not put session context into product docs merely to make it durable. Reuse applicable
[product isolation](../_shared/references/product-isolation.md) evidence when judging completion.

**A restriction on Git writes still permits read-only inspection.** Use `git status`, `git log`,
and `git diff` to establish what is saved and committed. Do not stage, commit, reset, or otherwise
change Git state unless authorized. If the project explicitly forbids even read-only Git access,
use filesystem checks: list the touched paths, read their contents, and search for the claimed
changes. Report commit status as unverified when that restriction prevents checking it.

**Verify, don't infer.** One or two greps is cheap, and it *is* the gate's whole job. Skipping it makes the
gate grade the conversation instead of the project.

> **The failure mode this step exists to prevent:** a run that graded a session entirely off the chat and
> flagged an item as an open loop when the repo already showed it finished. A single search would have
> caught it. All the questions *require* reading real state; this step makes that non-optional.

## What it does — one pass, five questions

### 1. Complete?

Did the session's work actually FINISH? Walk what it set out to do (its goal + the changes/tasks/stories it
produced) and confirm each is genuinely done:

- No half-built change — nothing left mid-refactor, mid-migration, or behind a broken import.
- No task/story/checkbox that was meant to land this session still open.
- Nothing left in a state the user would not want to walk away from: failing tests introduced by this
  session, a debug/scaffold artifact left in the code, a feature flag flipped for local testing, a
  commented-out block "to restore later".
- No *"I'll just…"* left dangling.

If the project tracks work as specs/stories, check their real status markers rather than trusting the
chat's summary.

### 2. Persisted?

Is everything written to **durable project files**, not stranded in chat (or stranded as an edit the user
did not mean to leave uncommitted)? The test for each thing the session produced — analysis, a flagged
caveat, a decision, a captured follow-up, a new convention, a kickoff prompt — is **one question**:

> **"Who consumes this, and does it live where they actually look?"**

If the consumer is a future session, a teammate, or future-you, and it lives only in this chat → it's a gap.

**Run this one question in the OPPOSITE direction from Step 0.**

Step 0 says ground in disk, not chat. That is right for questions 1, 3, 4 and 5, and wrong
here. A chat-only artifact leaves **no filesystem trace**, so a disk-first sweep can
only find what already exists — it cannot, even in principle, find what is missing.
`git status` clean means nothing is *uncommitted*. It says nothing about what was
never *written*.

So question 2 alone runs **conversation → disk**: enumerate what this session
produced, then check each item for a home. Never disk → conversation.

**Highest-yield trigger: throwaway commands.** Any result computed by an inline
script — `python3 - <<'EOF'`, `node -e`, a one-off pipeline — and then reported to
the user has three strikes: no file, no script, no git trace. It is invisible to
every disk-based check in this gate, and it is disproportionately the *valuable*
output: the table, the metric, the comparison, the diff summary. Scan this session's
commands for inline scripts whose output you reported. For each:

> **Which file holds this result, and which committed command regenerates it?**

If either answer is "none", that is a gap. Save the script, write the output.

**A reported result with no script behind it is not a result, it is a memory.**

**Then run the command back before it is committed, and compare it against the figure it sits
beside.** Writing the command down satisfies the question above while regenerating nothing: a
scope the run applied and the record omits, a glob that expands wider than the paths actually
used, a pipeline reassembled from memory rather than scrollback — each produces a command that
is plausible, adjacent to the truth, and wrong. It then reads as provenance for a figure it
cannot produce, which is worse than no command at all, because the next reader stops looking.
The check is one execution and the failure is loud: a number that does not match.

**Second trigger: reasoning stripped from what it justifies.** When a value, a
coordinate, a threshold or a selection was recorded but the *why* stayed in chat,
the artifact survives in a form nobody can check or revise. Record the rationale
alongside the thing it justifies, not only in the transcript.

The persist family this enforces:

| Produced this session | Durable home |
|---|---|
| Substantive analysis / investigation / synthesis | A file in the project's docs or research location — not chat |
| A number, table, metric or comparison you reported | A file, **plus the committed script that regenerates it** |
| The reasoning behind a recorded value, coordinate or choice | Alongside the value itself, not only in chat |
| A design or architecture decision (and the alternatives rejected) | An ADR / decision record, with the *why* |
| A flagged caveat, gotcha, known limitation, "one thing to note" | Written into the file or doc it applies to |
| A behavioral convention or rule that surfaced ("we always do X here") | The project's rules/conventions file — a durable, versioned file, never an agent's private memory store |
| A captured follow-up / deferred work item | A tracked item (story/issue/backlog entry) that will actually resurface — not a line in chat |
| A kickoff prompt for continuing project work | Continuation instructions in the tracked work item; `/jr feedback` is for Junior improvement proposals |
| Code, spec, and doc edits themselves | Saved on disk; and if the user's workflow is commit-per-session, committed (see `jr-commit`) rather than left dangling |

**A note on the last row:** do not commit on your own initiative if the user hasn't asked — but a large
uncommitted diff at archive time is a *gap worth naming*, because a closed session plus a stale working tree
is how work gets lost or clobbered.

### 3. Follow-up instructions still current?

This covers any runtime: a suggested action in ChatGPT or Codex, a queued task in Claude Code, or a kickoff prompt saved in a project file. Use the tools the runtime provides to inspect it; when no task UI exists, inspect the saved prompt itself.

For every queued task, suggested follow-up, or prepared session prompt this session created that the user has **not started**, re-open the instructions and compare them with the current project state. They remain actionable until used, so later corrections must reach them too. Stale instructions can launch work that is wrong or incomplete.

What goes stale, in the order it happens: a count or closed enumeration ("the three shapes") · a scope line a later round widened · a diagnosis a later round refuted · a "still owed" item since fixed inline · and a whole new finding the follow-up prompt predates, which is the one no formatting discipline prevents.

**A follow-up prompt has two staleness surfaces, and pointing at a record closes only one.** Good practice when writing a follow-up prompt is to state no count and say *"read <the record> and enumerate the items yourself."* That is correct, it works, and it is a trap: it immunises the **enumeration** and does nothing for the **frame** — the title, the summary line, any *"the defect, in one line"* sentence, any *"already done vs. still owed"* split. Those are authored into the prompt and decay with every later round. A run that wrote its follow-up prompt the good way believes it pre-satisfied this obligation at generation time, so the re-diff never fires — and the belief is half true, which is exactly why nothing feels missing.

The test is mechanical and needs no judgment: **does the prompt contain any sentence that would be false if the record grew?** A pointer answers *where to look*; it never says *what this is about*, and the frame does. The worst case is a *"still owed"* half that now includes something already fixed in-session — the session that clicks it can rebuild finished work.

Update the existing prompt through the runtime's supported edit operation. If it cannot be edited, prepare a corrected replacement and mark the old prompt as superseded where the user will see it. Preserve the original until its replacement is available. Creating, dismissing, or archiving a session still requires the authorization the runtime and project require.

> **Why this needs to be its own question:** a stale unstarted follow-up prompt is *complete* (it was spawned) and *persisted* (its record is on disk), so it passes questions 1 and 2 cleanly while being wrong. The gate had no way to catch it, which is why it needed its own question rather than a better-worded existing one.

And the general lesson, because it is why a correct rule fails on its first real test: **a maintenance rule needs an owner; a generation rule does not.** *Don't hardcode a count* fires at the moment of writing, so the act that triggers it is the act that needs it. *Re-diff the follow-up prompt after every later round* has no moment of its own — a follow-up prompt is spawned at the run's **closing** step, so every round that could stale it happens at a point the workflow believes is past its own end, and nothing walks a checklist there. The half that cannot self-trigger has to be assigned to a step that always runs at the close, which is this gate.

### 4. Commission retired?

**What line, on what surface, told the user to run this session — and is it still true now that it has run?** A session is usually summoned by a durable line: a story or task checkbox, an issue, a backlog row, a "start here" note, a roadmap NEXT marker. **That line is a claim that the work is still owed, and running the session falsifies it.** Close it in the same turn the session closes — mark it done with the date, one line of what shipped, and a pointer to the record — and retire any start command it carries, which now boots a session with nothing to do.

The failing state is mechanical: a session that finished the work its commissioning line describes, with that line still open.

**Re-read the record before you strike it.** A commissioning record can grow while the session it launched is running, and the run has already read it. A well-formed follow-up prompt deliberately states no count and points at a durable record, which makes the set re-derivable exactly as fresh as the **one** read the session took at Step 0 — an item appended after that read is invisible by construction, and the session that appended it may be explicitly relying on this one to pick it up. So check whether the record changed since you read it — but **a modification time is a trigger to LOOK, never evidence that anything changed, and it errs toward false positives.** Sync clients, formatters, editors, and checkout tooling all rewrite files without touching a byte of content, so a fresh timestamp routinely means nothing at all. Treating the timestamp itself as the finding sends the gate chasing noise, and — worse — it teaches you to trust the timestamp, which is how a genuine concurrent write hides behind *"the mtime looked normal."*

**The diff is on CONTENT.** Re-read the record's head and compare it against what you actually read at Step 0; a new entry lands at the top, so its first line is the cheapest possible check. Where the working tree is shared — parallel sessions, a teammate, a background job — read-only `git diff` / `git log` is the right instrument, and it stays available even in a project that forbids the agent from *mutating* git.

A new item found there is in scope by construction — it is what the commission asked for — so it is closed here, not queued.

> **Why this needs to be its own question:** a surviving commissioning line is *complete*, *persisted*, and *not a follow-up prompt*, so it passes 1, 2 and 3 cleanly. And the cost is not a stale line, it is a **re-commission**: a surviving line is indistinguishable from an open one, so the next reader cannot tell a finished piece of work from a pending one without re-deriving the whole thing — and the cheapest way to find out is to run it again.

**The direction is the tell, and it is why no other question reaches it:** question 3 walks what this session **spawned**; question 4 walks what **spawned this session**. Every other marking discipline in this gate is scoped to artifacts the session produced.

### 5. Checked against findings recorded ELSEWHERE?

If this session changed a **method** — a convention, a rule, a lint, a check, a shared abstraction, a
review checklist — then before you verdict, read what was recorded elsewhere in the project during the
same period and run those findings against **what this session itself just built**.

A method defect is rarely specific to the place it was found. *A field that names a later step is a
promise with nothing making it a debt* · *a check whose only failing state is "empty"* · *a guard bound
to a pipeline step, so it runs once and is blind to every later edit* — each of those is one component's
finding and every component's defect.

Where to look, in the project's own terms:

```bash
git log --oneline --since="<when this session started>"     # what else landed in parallel
git diff --stat HEAD@{1}                                    # and what it touched
```

…plus any decision record, post-mortem, review finding, or notes file modified since this session began.
Only when read-only Git access is also forbidden, use file timestamps to select records to read:

```bash
find <records dir> -name '<record filename>' -newermt "<when this session started>"
```

**Same discipline as question 4: a timestamp SELECTS CANDIDATES, and the content decides.** A hit list is
where the check begins — open each one and diff its findings against what this session built. A file whose
timestamp moved because a sync client or a formatter touched it is not a finding, and a stale timestamp on
a record someone genuinely edited in place is not an all-clear.

**Why this needs to be its own question:** questions 1–4 all walk *this session's own artifacts* —
its work, its persistence, its follow-ups, its commission. A finding recorded by someone else, about something else, is neither. So a
defect this session **authored** can be described in black and white in a neighbouring record and still
pass both checks cleanly. The timing is what makes it unreachable rather than merely missed: that record
can be written *after* this session did its reading, so no amount of diligence at the start reaches it —
only a check at the close does.

Two things are worth doing while you are there:

- Run the other record's own meta-question on your own work. *"Did it diagnose a failure and then not
  apply it one bullet over?"* is the highest-yield thing to ask about a change you just made, and it
  costs nothing.
- **A hit is closed here, not queued.** It is a defect in what this session is about to ship, so it is
  this session's to fix — however cheaply someone else named it.

## The output — a fixed shape, every time

**For:** the user deciding whether to close this session. It answers *can I archive this?* and, where
the answer is no, *what must be closed first.*

Everything above this line is how you DECIDE. None of it is what you PRINT.

The five questions, the sorting, the filters, the corrections you made along the way — that is
the gate working, and a user reading it is reading a transcript of bookkeeping instead of an
answer. **Print the verdict and the three sections below. Nothing else.**

```markdown
## ✅ Safe to archive
## ❌ Not safe to archive — N gap(s)     ← use exactly one of these two, as the first line

### Done
- What landed, and where it now lives. Outcomes, not activity. 3–6 bullets.

### Next
- **This session / New session in <project> · Agent chat / Terminal:** `exact command or prompt with context path` — purpose and any prerequisite. One action per bullet.

### Decide
- A choice only the user can make, stated so it is answerable without opening anything.
```

**Rules, and they are not negotiable:**

- **The verdict line is first and is one of the two forms above.** Never a paragraph, never hedged.
- **Section names are fixed:** Done · Next · Decide. Always that order.
- **Omit `Decide` entirely when there is nothing to decide.** An empty section invites a decision
  that does not exist, which is the same cost as a bad one.
- **Bullets and tables only.** Under `Next`, a fenced block may hold a copyable command or prompt.
- **Next steps follow `00-junior.md` → Suggest ONE next step.** Resolve every placeholder in the
  template above. Never leave the user to infer the session, project, input surface, or context.
- **Around 200 words.** A long verdict at a closing gate reads as reluctance to close.
- **Register:** headings are noun labels — never sentences, questions or conversational phrases.
  Prose states facts. No editorial lead, no anthropomorphising, no dramatic adjective. A session
  that went well and a session that went badly are reported in the same voice.
  Baseline: `../_shared/references/artifact-output-spec.md`.

**Never print:** the five questions, by name or by shape · the sort into detritus and backlog ·
the ask-boundary filter · what you corrected mid-pass and how you found it · why a task stayed
open (that belongs in the story file, where the next session reads it) · anything the user cannot
act on.

**The test before sending: can the user act on every line without asking you what it means?**
A line that only makes sense to the party that wrote it belongs in the artifact log, not the
verdict.

**Unfinished work does not change the verdict.** The gate asks whether anything is LOST, not
whether the work is DONE. A session closes clean over a story nowhere near finished — that story
is one bullet under `Next` with its resume command, and nothing more.

## Deciding what goes in each section

**Act, don't just flag:**

- **Trivial / quick + in-scope → JUST DO IT NOW.** Do **not** defer it, and do **not** manufacture a tracking
  artifact to "home" the deferral — no TODO block, no status section, no changelog entry, no "do this later"
  line in a doc. Writing the note is slower than doing the work. If you catch yourself adding a status/TODO
  block to track quick work, STOP and do the work instead.
  - **A gap in a different location is still YOUR gap to close.** Another repo, another tool's config directory, a path outside the current working directory — none of these make the work the user's. You can `cd` there. **"It lives somewhere else" is not a hand-back**, and neither is a doc saying a command "runs in" some other repo — you can run it there. (The valid hand-backs are the four under *Separate the two kinds of "open"* below; that list is canonical.)
- **Genuinely substantial work remains → ONE real hook:** a tracked work item with continuation instructions
  in whatever system the project actually uses — never a status block buried inside a reference doc where
  nobody will see it.
- Don't declare "safe to archive" until every gap is either **closed** or hooked to a real resurfacing
  surface. *"Deferred with a home" is for substantial work only — never an excuse to skip trivial work.*

### Separate the two kinds of "open"

**A loose end this session created is not the same object as a queued backlog item**, and reporting them in one list is what makes a verdict read as an abdication. Sort every open thing before writing the verdict, and say which pile it is:

- **(a) Detritus** — something THIS session created, broke, deferred, or left half-done. That is the session's to **close, here, now**. A session does not get to hand its own leftovers to the user as "open items."
- **(b) Backlog** — a queued item that existed before this session and has its own way to begin. Naming it is *orientation*, not a gap.

The tell that the sort was skipped is a closing recap whose "still open" list mixes both: real detritus then hides inside legitimate backlog and reads as parked, while the honest queue reads as unfinished business. And if a "backlog" item turns out to be one this session created, it is detritus wearing a backlog's clothes — close it.

**The sort needs a test it can fail on, and the tell is the START COMMAND.** A genuine backlog item **has a way to begin** — a command, a NEXT marker, an issue with a first step — because it existed long enough for someone to give it one. Detritus never does: it was born an hour ago inside this session's own reasoning, so nothing has ever written down how to start it. So put the start command in the (b) list as a **column**, and **a row you cannot fill is misfiled** — move it to (a) and close it now.

The failure looks like diligence from the inside, because the item is real and honestly described; what is wrong is only *whose it is*. Two shapes to watch for:

- **A question THIS session invented.** When a change creates a new category — a new test, a new property, a new way of classifying — every existing thing becomes newly unclassified against it. Those are not pre-existing open questions, they are this session's own unfinished sorting.
- **The inflation move.** If you already hold most of the answer, **finish it** rather than reporting the remainder as open. An item you could close with one read is not a queue entry; handing it over is manufacturing work for the user out of work you declined to do.

**Then the inverse, which the test above cannot see because it PASSES: the start command sorts *whose* an item is, and nothing sorts *queue vs. do*.** A command cheap enough to write in the column is proof you could have run it — so the very evidence that makes a row look properly filed is the evidence it should never have been filed at all. Every (b) row therefore takes a second cell — **why not now?** — and the answer must name a real blocker. **There are four, and this list is canonical:**

- it needs the **user's** knowledge, judgment, or authorization;
- it touches the **user's** own content rather than the agent's;
- it is materially **out of scope** for what this session was for — meaning a *different concern* the session was never about, not merely a different file. ⚠️ This is the blocker most easily manufactured: a fix inside the change you are already touching is never out of scope, and scope derived from a bundle you assembled yourself is circular (see the scope-inflation move below);
- it is genuinely **multi-session**.

These are **not** blockers, and each one is the excuse actually reached for: *"it's a big change"* about the agent's own tooling or config · *"wide blast radius"* when the tool has verified guards that refuse on failure · *"the sweep is standing practice but somebody should decide to run it"* (standing practice **is** the decision) · *"it lives somewhere else"* (another repo, another config directory, a path outside the working directory — see above; location is never a hand-back).

**The mechanical form, because two better-worded instructions in a row is the tell that wording is not the fix:** *if the start command is a single command this session could execute, this session executes it.* No judgment call, nothing for the party that wants to defer to argue with.

**A queue entry is not free** — it costs the user a decision later, so the bar for CREATING one is higher than the bar for doing the thing. Writing the entry, its criterion and its start command is routinely *more* work than the work itself.

**And a third cell, which every clause above passes cleanly: *why not now?* asks whether the work CAN happen, and nothing asks whether it is WORTH DOING.** Every (b) row takes a **what does this buy?** cell — and **an answer that is a rule citation is an empty cell.** *"The convention says every module needs X"* is the rule that names the gap, not a reason to close it. The cell wants the answer to *"what goes wrong, for the user, while this stays as it is?"*, **specific to this instance** — a rule-shaped answer is identical for every item a sweep found, which is the tell that it was never asked. **If you cannot fill it, the honest row is not a better-worded blocker — it is NO ROW.** This is how a structural sweep becomes a work *generator*: it finds a technically-real gap, the finding is honestly described and correctly sourced, and the row reads as diligence because every other column is properly filled.

Watch the **scope-inflation move**, because it manufactures the blocker that makes a row look legitimate: bundling several findings into one item and then citing the bundle's size as *"genuinely multi-session."* **Scope each item alone before writing its *why not now?*** — the bundle is your choice, so a blocker derived from it is circular.

**Once all three cells are honestly filled, the item is DECIDED by construction** — what remains is only the cost of re-entering the context from cold, and a launcher (a task follow-up prompt, a tracked item carrying its start command) is exactly the instrument for that. Refusing one there is the guard eating its own output: the work is real, sourced and scoped, and now has nothing to launch it. The tell that this over-correction is happening: **a verdict that lists a fully-columned row and then declines to launch it.**

### Run the ask-boundary filter on the verdict itself, before sending it

The recap is a **crossing**, and it is the one no automated check can reach. A gate that has just declared "safe to archive" is **exactly** where a decision belonging to the agent gets handed over, because the framing is helpful rather than interrogative: *"if you'd rather X, that's a one-line change"* · *"want me to also…?"* · *"your call whether…"*. **An offer is a question wearing hospitality's clothes** — it still costs a decision, and the test does not care about the grammar.

Read every sentence of the verdict and ask: **whose knowledge decides this?** If the subject is the agent's own machinery — a skill's rules, a metric's definition, a check, the architecture — **decide it, do it, and report it as DONE.** Deferring there is not caution, it is abdication, and at the gate it is worse than mid-session: the user is trying to CLOSE, and a question in the closing line re-opens the session for something that was never theirs.

**Ownership is only one of five tests.** Each is necessary, none is sufficient, and legwork runs first — a question that is genuinely the user's still has to be answerable:

- **LEGWORK** — at a closing gate the cheapest question is often one the project already answers. Check first; a question the repo settles ships as a **stated premise to correct**, never as an ask.
- **OWNERSHIP** — whose knowledge decides this? The agent's own machinery is the agent's to settle (above).
- **FORK** — two outcomes that lead to different work, not a request for reassurance or a rubber stamp.
- **LEGIBILITY, and this gate is the most exposed to failing it.** An archive verdict's whole subject matter is bookkeeping — surfaces, lines, records, stamps, dispositions — so the vocabulary that fails this test is the vocabulary the gate naturally thinks in. **A verdict is where a question is most likely to be correct, sourced, and unreadable at once.** The mechanical form: **an ask states what the user would DO, never how a record would change.** *"Re-scope this entry or close it"* moves a task between two states; *"the roadmap says the importer is unstarted, but you shipped it last week — should the entry point at the remaining CSV work, or come off?"* is answerable without opening anything.
  - When bookkeeping vocabulary trips this test, **re-run OWNERSHIP before rewording**. The vocabulary is usually diagnostic of *whose* the question is, not merely of how it was phrased — and a beautifully reworded agent-domain question is one the user should never have received.
- **ONE PROPOSITION** — a question that bundles two asks comes back with an answer that does not say which one it answered, and the gate then acts on the wrong half with full confidence. Ask one thing. If the ask rests on a framing the user has not seen, state the framing first or the answer is about a different question.

## Keep it simple

- A **gate, not a project** — a quick honest pass, then a verdict. Don't manufacture work.
- Don't re-do or re-review the session's work; just verify it's **done + saved**. (Quality review is
  `jr-code-review`; a full project state report is `jr-status`.)
- One pass: **Complete? · Persisted?** (*who consumes it / does it live where they look?*) **· Follow-ups current? · Commission retired? · Checked against findings recorded elsewhere?** → verdict. All green → say "safe to archive" and stop.

## Boundaries

- **NOT** a status report — `jr-status` covers overall project state and next actions.
- **NOT** a commit workflow — `jr-commit` stages and writes the commit; this gate only *notices* that
  uncommitted work is a persistence risk.
- **NOT** a code review — `jr-code-review` judges quality; this gate judges completeness + persistence.
- Never delete anything to "clean up" as part of archiving. Removing scratch files, drafts, or iteration
  artifacts requires an explicit, per-instance yes from the user — approval of the *work* is not approval
  to delete.
