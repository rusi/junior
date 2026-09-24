---
name: jr-demo
description: Run `/jr-demo` to turn a prose walkthrough into an assert-verified storyboard of captioned screenshots of the running application.
---

# Demo — see the feature actually working

## Purpose

Developing by hand, a developer keeps the site open and clicks through workflows to watch
features work. Agentic development removed that loop. Tests already answer *is it correct*; the
questions left unanswered are **does it look right, is the data right, does the flow feel right**.

This restores that loop as an artifact: a directory of captioned screenshots of the real
application, reviewable in about fifteen seconds by opening one file.

## Type

Direct execution — invoked with a target, and a profile naming the stack.

## The one guarantee, and which half is yours to keep

**A walkthrough that does not assert will happily photograph a broken application.** It produces
a confident-looking artifact of a page that never rendered, which is worse than no demo at all:
it converts an unverified claim into apparent evidence.

So the half of it that can be made structural does not live in this file at all. It lives in the
capture helper the profile ships, which you copy into the project **unchanged**:

```
step(caption, locator)
  → assert the locator is visible      (fails the run if it is not)
  → capture
  → append caption + image to the contact sheet
```

`step` is the only operation the storyboard exposes, and the contact sheet accepts panels from
nowhere else. **Every panel in a finished storyboard therefore had its element asserted** — that
much is structural, and it is what the artifact rests on.

That sentence is about panels. A walkthrough recorded as motion has none, and what it guarantees
is both real and weaker; step 4 says which half is which rather than letting this paragraph be
read as covering it.

**Know which half is which.** The helper also takes the page's own screenshot method away, so
the obvious bypass fails the run loudly. It cannot take away every capture the runner offers: an
element screenshot, a second page, the browser context's own APIs all stay reachable, and a
walkthrough using one would write an image nothing asserted. No code stops that. You do.

You are the party the guarantee constrains, so your compliance cannot be what enforces it — which
is why as much of it as could be made structural was. Where the line falls to a rule instead, it
is named as a rule here rather than dressed up as containment, because a guarantee claiming more
than it enforces is this skill's own failure mode turned on itself.

**Three things the rule forbids, without exception:**

- ❌ Editing the helper to add a capture path, an unasserted variant, or a soft-fail mode
- ❌ Calling the runner's screenshot API from a walkthrough, directly or through a wrapper
- ❌ Loosening an assertion — a `visible` weakened to `attached`, a locator widened until it
  matches something — to get a run to complete

If a step cannot assert something meaningful, the panel is not worth capturing. Cut the panel.

## When a demo is worth producing

**Produce one when the change is visible to a person:** a new or altered screen, a state a user
lands in, data whose shape or emptiness matters, a flow whose steps a reviewer should recognize.

**Do not produce one when there is nothing to look at:** a refactor with no rendered difference,
a backend-only change, tooling, documentation, a build script. A storyboard of eight identical
pages costs review attention and teaches the reader to stop opening them.

**Say so rather than producing a thin one.** "No storyboard — this change renders nothing
different" is a complete answer, and a better one than four panels of the same screen.

## Step 1 — Resolve the profile

The profile names the stack: the runner, where walkthroughs live, how the isolated stack starts,
how demo data is provisioned, how outbound integrations are pinned, where artifacts are written,
how motion is recorded, and the verbatim capture helper.

**Four ways to arrive at it, attempted in this order.** The order is the design, not a
convenience: an authoritative answer is available almost every time, and anything that guesses
ahead of it is a guess that can silently be wrong for the life of the project.

1. **Caller-supplied** — a host skill names the profile. It has been running this project's
   commands and knows the stack, so take it and move on. Nothing is inferred and nothing is
   asked. This is how nearly every run resolves.

2. **Persisted declaration** — `.junior/docs/demo-profile.md` names the profile. Read it and
   move on. A project answers this question once; a run that re-derives an answer already
   written down can reach a different one as the repository moves, which is a wrong profile
   arriving quietly rather than as a question.

3. **Infer, confirm once, persist** — genuine first contact, standalone, with nothing above to
   go on. Read the project for its test runner and match it against `references/`. Then **state
   the evidence and the conclusion, and ask** — one question, naming what was found and which
   profile it points to. On confirmation, write `.junior/docs/demo-profile.md`: the profile, the
   evidence, and the date. It is asked exactly once because the answer is recorded.

4. **No profile matches** — nothing in `references/` covers this stack. **Report and stop.**
   Name the runner found, say what no shipped profile covers, and offer to author a new profile
   from the observed stack. Do not improvise a capture path from a profile that nearly fits: a
   mechanism nobody has verified against this stack produces exactly the unverified artifact
   this skill exists to prevent, and it produces it looking identical to a real one.

Read the profile in full before continuing. Everything stack-specific comes from there, and
nothing stack-specific belongs in this file.

## Step 2 — Compose the scope

**Three granularities, one authored unit.** The `## Demo Script` section in a story file is the
only thing anyone writes. The other two scopes are derived from it, and derivation is the whole
design: a feature-level narrative authored separately would be a second document to keep in sync,
and it would drift.

- **Story** — one story's script. The default, and what `/jr-implement` asks for.
- **feature-level** — every story script in one feature, in story order, as one storyboard.
  What `/jr-integrate` asks for, per feature that landed.
- **diff-level** — only the story scripts a branch's changes can be seen in. What
  `/jr-code-review` asks for, and the answer is often none.

**Composition re-runs the scripts; it never staples finished storyboards together.** Panels
captured in separate runs were asserted at different times against different code, so a sheet
built from them can be individually true and collectively false — a storyboard of a state the
application was never in at any single moment. That is this skill's failure mode wearing the
costume of an optimisation. One scope, one run, one output directory.

### Feature-level

Take the feature's stories in numeric order and each story's script in the order its steps are
written. Panels number continuously across the whole sequence, so a reviewer quoting panel
eleven is naming one thing.

**Where a story has no script, author one before composing**, exactly as for a story-scoped run.
A feature specified before this section existed has none of them, which is the normal case rather
than an error; read the spec, the implementation, and the existing e2e specs, and leave each
script behind in its own story's section. The next composition then costs nothing.

**Where a story says its work renders nothing to look at, skip it and keep going.** That is the
section answering, not a gap. A backend story inside a feature is not a reason to stop composing
the rest of it.

**The brief comes from the feature, not from any one story.** Two sentences saying what the
feature does across its stories and what a reviewer should judge. Concatenating the story briefs
produces a wall of framing nobody reads.

**Restore the session between segments.** Each story script was written assuming it began signed
in as itself, so a script ending as a different user breaks every script after it. Whatever a
segment changed about who is signed in or what is selected, put it back before the next one
starts. Nothing warns you: the following steps simply fail on elements that user cannot see, and
they read as bad locators.

**Show each claim once, not once per story.** Scripts open by establishing where they are, and in
composition that has already happened — so a naive concatenation repeats screens. Two panels of
the same screen with different captions is a caption doing work the screenshot is not, and at
feature scale it is most of the sheet. Where a later story's script restates a screen an earlier
one already showed, drop the repeat and keep the claim that is genuinely its own. A story with
nothing visually new to add contributes no panels, and saying so is a finding worth reporting.

*Identical panels are occasionally the evidence* — a state proven unchanged across a reload is
exactly two identical images — but the caption has to say that is the point, or a reviewer reads
a duplicate and skips it.

**The composed storyboard commits beside the feature overview**, not beside any one story. It
belongs to none of them.

### Diff-level

**The diff names files; scripts name screens. Establishing that correspondence is the work.**

1. **List what changed.** With a base branch, `git diff --name-only <base>...HEAD`. Without one —
   a caller reviewing a dirty working tree has no base to name, and that is the common case, not
   an edge — the change *is* the working tree: `git diff --name-only HEAD` together with
   `git ls-files --others --exclude-standard`. Either way, keep only files that render something.
   Where nothing rendering changed, say so and produce nothing. "No storyboard — this branch
   changes no UI" is the correct output, not a failure to find one.
2. **Turn changed files into routes.** A route file is its own route. A shared component is a
   route only through whatever renders it, so follow its importers until they reach routes.
3. **Turn routes into scripts — on the panels, not on the path.** Select the story scripts that
   capture a **panel** on a route from step 2. A walkthrough passes through routes it never
   photographs: a shared session fixture that lands on the home route puts every script in the
   suite through it, so "reaches the route" makes the whole suite the answer the moment the
   landing page changes, and diff-level stops distinguishing anything. The route a panel was
   captured on is the route that panel is evidence about; a route merely traversed during setup
   is evidence about nothing.
4. **Run the selected scripts as one storyboard**, in story order, as for a feature.

**When tracing a component to its routes is inconclusive, include the script.** The two errors
are not symmetric: an excluded script hides a regression behind an artifact that looks complete,
and nobody is told anything was left out. An extra script costs a reviewer some seconds. Choose
the seconds.

**Say what was selected and what was left out**, and on what basis. A storyboard whose scope
nobody can see reads as the whole diff, and a reviewer will take it as one.

## Step 3 — Get the demo script

A **demo script** is plain prose: an ordered description of what a reviewer should be shown.
It is the authored unit, and it is authored in the spec while intent is freshest.

**Where it lives is fixed: a `## Demo Script` section in the story file.** A caller names that
file when it invokes this skill; standalone against a story, read it there. One place, so the
script the developer wrote is the script that runs.

**When the section carries a script, use it.** Do not rewrite it into your own words — it
records what the person who designed the feature wanted seen. Read the implementation before
converting it: prose written at spec time names screens by intent, and the locators are in the
code.

**When the section says the story renders nothing to look at, stop.** "Not applicable, and
why" is an answer, not a gap — it is the section doing its job. Report that no storyboard was
produced and what the story said, and produce nothing.

**When the story renders something the run cannot honestly reach, name it and capture the rest.**
A state that only exists once a dependency fails, or once data arrived by a path the run has no
way to travel, is not a scripting problem to be solved. The solution that suggests itself —
intercepting the application's own responses until the state appears — photographs a state the
application never entered, which is this skill's failure mode with better manners. Write the
panels that are reachable, say in the script which state is not and why, and leave it to the
tests. A gap written down is one somebody can close; a gap papered over is one nobody knows is
there.

**When the section is absent or empty, author one.** Read, in this order:

1. **The spec** — the story or feature file. What was this for, and what would prove it works?
2. **The implementation** — the routes, screens, and states that actually exist. A script
   written from the spec alone will name a screen the implementation never built.
3. **The existing e2e specs** — the highest-value read, and the one most often skipped. They
   already encode the working selectors, the login path, the setup sequence, and the names of
   the things on screen. A walkthrough authored without reading them re-derives all of it, badly.

Then write the script as prose — six to ten steps, each one thing a reviewer should see — and
**show it before running anything.** A script is cheap to correct and expensive to re-shoot.

**Then put it in the story's `## Demo Script` section.** A script that lives only inside one run
is re-derived, differently, by the next one, and there is nothing for a feature-level demo to
compose. Authoring it is the expensive part; leaving it behind costs nothing.

## Step 4 — Choose the medium

**Stills are the default, and they answer state questions**: what the data looks like, how the
layout holds, what an empty state shows, whether a flow reaches the screen it should. Roughly
eight captioned panels scan in fifteen seconds, zoom freely, and diff panel-by-panel across runs.

**A narrow set of questions is about motion, and stills cannot answer them at all**: whether a
hover menu survives crossing into its submenu, whether stale data flashes before a context switch
lands, whether a loading state looks right rather than merely existing. What these have in common
is that the answer is in the *passage between* two states, and a still can only ever be one state.

Recognize a candidate when the demo script describes a *transition* rather than a *state* — the
words are usually *while*, *during*, *before it settles*, *as it opens*.

### Argue it back to stills first

**Most questions that feel like motion questions are state questions with a panel missing.** The
demo script says "while the menu is open" and what it wants is a panel of the menu open, which
stills do better: it zooms, it diffs across runs, and a reviewer reaches it in a second rather
than in however long the recording runs. Reach the state and photograph it.

Motion earns its keep only where **no single frame is the answer** — where a reviewer has to see
one state give way to another to judge it. Two states, both reachable, both photographable, is
two panels.

The bias is deliberate and it points one way. A recording costs its full runtime to review every
time anyone opens it, cannot be skimmed, cannot be diffed, and commits into permanent history at
a weight that never compresses. Stills wrongly chosen cost a panel that answers nothing. Motion
wrongly chosen costs every future reviewer.

### Record the choice where the script lives

The `## Demo Script` section carries a `**Medium:**` line, and it names the choice **and the
question that decides it**:

- ✅ `**Medium:** stills — the question is whether a failed login explains how to retry`
- ✅ `**Medium:** motion — whether the submenu is reachable without the menu closing under the
  pointer, which no single frame shows`
- ❌ `**Medium:** motion` — the choice with the reasoning removed, which is the choice
  unreviewable
- ❌ `**Medium:** stills — simpler` — true of stills always, so it decides nothing

Naming the question is what makes a wrong medium visible. A motion question answered with stills
has to be written down as a state question to pass, and that sentence is false on its face to
anyone who reads it — which is the only point at which the mistake is catchable, because the
storyboard it produces looks exactly like a correct one.

**Where the section carries no marking, it is stills.** A script written before this line existed
is not a script that chose motion and forgot to say so.

### What a recording guarantees, and what it does not

**Every step still asserts before the run may continue, and a failed assertion still delivers
nothing.** A recording is the trace of a run that reached every state its script claims — not a
camera left running next to one.

Say the rest of it plainly, because it is weaker than the stills guarantee and reads identical:
**the footage between two asserted moments is not evidence of anything.** A panel is an image of
a state something asserted; a frame two seconds into a transition was asserted by nobody. What a
recording carries is the ordered list of claims that *were* asserted, and continuous footage of
the run that satisfied them. Judge the transition; do not read a frame as a panel.

### Motion composition

**Frame the cause and the result.** Decide which views must remain visible before scripting.
When the question concerns interaction across views, show the acting view and the receiving view
simultaneously, with stable placement and readable controls. A caption naming an offscreen action
cannot substitute for seeing it. If the profile cannot capture the required composition, report
the capability gap before recording; do not deliver one view as proof of the whole interaction.

**Use a reference as direction, not as source material.** When a user supplies a recording,
inspect its sequence, framing, pointer movement, pacing, and visible results before adapting the
walkthrough. Keep its project names, paths, media, domain vocabulary, and identifiers out of
shared skill instructions and examples. Carry over the presentation principles only.

**Keep the walkthrough focused.** Show an established starting state, a visible action, and its
result. Move deliberately, pause briefly where the reviewer needs to read, and preserve real
transition timing. Related actions may form one coherent sequence; do not turn the recording into
a tour of the test suite. Provision unrelated setup before visible interaction and leave cleanup,
expiry waits, and reconnect checks to tests or separate artifacts unless their timing is the
question. Do not speed up, splice, or manufacture a transition to conceal a wait. The shipped
profile decides what recording boundaries it supports.

**Where the profile does not produce motion, say so plainly.** Name the question stills cannot
answer and let it stand as a known gap. Capturing stills of a motion question and presenting them
as the answer is the failure mode of this whole skill, one level up.

## Step 5 — Convert prose into a walkthrough

Apply [product isolation](../_shared/references/product-isolation.md) before copying any
helper, fixture, or config outside working material. Run the complete-tree check on copied
tooling; verbatim copying is not an exception. If the shipped helper leaks ownership
metadata, stop that product-copy path and report it. Keep retained review artifacts in
working material; do not weaken capture checks to silence an isolation finding. Inspect
captions and rendered content semantically before any product delivery.

Each prose step becomes exactly one `step(caption, locator)` call, in order, in a walkthrough
file at the location the profile names.

**Open with a brief.** `brief(text)` sets a short paragraph above the panels: what this
walkthrough shows, and what the reviewer is being asked to judge. A reviewer arriving at eight
screenshots with no framing has to infer the question from the pictures, and infers a different
one than you meant. It is prose, not a panel — it appends nothing to the sheet and leaves the
assert guarantee exactly where it was. **The run refuses to write a sheet without one**, because
a brief that can be skipped is a brief that gets skipped.

Two sentences: what happens across the panels, and what to judge. **Do not restate the title** —
it sits directly above, and a brief that paraphrases it reads as decoration and teaches the
reviewer to skip it.

- ✅ "A failed login shows an error, then a successful retry opens the account page.
  Judge whether the error explains how to recover."
- ❌ "Logging in to an account" — the title again
- ❌ "This storyboard shows login working correctly" — a verdict the reviewer is
  supposed to reach, handed to them instead

**The locator is the assertion, so choose it as one.** It must name the thing the caption
claims is on screen — the row that should have appeared, the heading of the screen just reached.
A locator on the page chrome, the body element, or a wrapper that is present on every screen
asserts nothing and will photograph any failure without complaint.

**Provision demo data through the application's own interface**, using the helpers the profile
names. Never by direct database writes: a seed that reimplements what the services own —
identifier generation, derived snapshots, defaulting — gets it subtly wrong and produces a
demo depicting a state the application itself would refuse. That is this skill's failure mode
relocated into the setup.

**Use data suitable for visual judgment.** Reuse provisioning helpers, but inspect their data:
minimal test fixtures can obscure the very interaction a demo should explain. Choose synthetic
or explicitly approved, sanitized examples with representative content, scale, and density.
Keep contrast and detail sufficient to see the result. Never substitute live private data merely
to make the recording look realistic; provision suitable data inside the isolated stack.

**Pin what the screen reads from outside the stack, before the first step is written.**
Isolating where the application *writes* says nothing about where it *reads*: a stack can own its
datastore completely and still fetch every widget on the screen from a connected account. Walk
the screens the script will capture and name the source of each thing they render. A source the
isolated stack does not own is either pinned to a fixture — the profile says how — or it is
live, and a live source is an unasserted panel in other clothes: the caption claims the data is
what the feature produces, when it is what the outside world happened to return that day.

**Where a source cannot be pinned, decide out loud and put the decision in the artifact.**
Either capture the screen with that region deliberately empty and say so in its caption, or
leave the screen out and say why. What is not available is capturing it and hoping — an account
returning nothing today returns somebody's real data tomorrow, and the two runs look identical.
Both halves of this stay quiet: a run reaching a live service reads exactly like one that does
not, and a panel holding real personal data looks exactly like one that does not, because the
whole artifact is a picture of a real application working correctly. It surfaces when a reviewer
opens a committed panel and finds a name in it, which is after the commit.

**Navigate the way a user does.** Where a step is reachable by clicking, click. Deep-linking
straight to a URL skips the flow the reviewer is being shown and hides a broken path into it.

**Settle before acting again.** Where an action's effect is what the next action depends on,
wait for that effect. A form reopened while its previous save is still in flight is reset
underneath the values just typed into it, and the damage surfaces steps later as an element
that never appears — reading as a bad locator rather than as the race it is. A panel is one way
to wait; an ordinary assertion is the other, and it is the right one where the intermediate
state is not worth showing.

**Wait for the settled state to appear, never for the loading state to disappear.** An absence
is already true before the thing has rendered at all, so a wait for one returns immediately and
the capture lands mid-load regardless — and it does it silently, because the wait passed. Name
what the screen says once it is ready, and wait for that.

### Captions

The caption is what a reviewer reads *instead of* the application, so it carries the claim the
panel is evidence for.

- ✅ "Account page shows the signed-in user's display name"
- ✅ "Failed login leaves the email available for retry"
- ❌ "Login page" — names the location, claims nothing
- ❌ "Click the button" — narrates the walkthrough rather than the finding
- ❌ "Everything works correctly" — a verdict the panel cannot support

### Panel sequence

Around eight panels. The sequence is a narrative a stranger can follow: where we are, what we
did, what changed. Show the before-state when a change is only legible against it. One panel per
claim — two panels of the same screen with different captions means the caption is doing work
the screenshot is not.

**Same screen and same subject is a repeat. Same screen in a different state is a panel.** A page
where several separately-built claims ended up together — a settings screen, a card that
accumulated features one story at a time — invites both mistakes at once: photograph it twice and
the second caption carries its claim alone, or drop the second claim and the storyboard quietly
stops covering it. Neither is the answer. Reach the state the claim is actually about — switch the
control, change the mode, empty the list — and capture that. Where a claim has no state of its own
to reach, it has nothing to show, and the honest panel count is the lower one.

**A panel is the whole page, so the locator chooses the thumbnail rather than the crop.** The
capture is full-page: nothing a caption describes can fall outside it, and a locator no longer
has to be picked to keep the subject in shot. What the locator still decides is where the grid
thumbnail centres, since the sheet crops each thumbnail around the asserted element. Name the
thing the caption is about and the thumbnail shows it; name a wrapper spanning the page and the
thumbnail centres on nothing in particular.

## Step 6 — Run it

Start the isolated stack and run the walkthrough exactly as the profile specifies. Demo runs
inherit the project's isolation rules without exception: never against a shared development
instance, never against a database anyone else is using, and never with an outbound integration
still pointed at a live account.

A run either produces the full artifact or produces nothing. There is no partial storyboard.

## Step 7 — When an assertion fails

**Nothing is delivered.** A failing assertion means the application did not reach the state the
script claims, and a "failure storyboard" would render a defect as a deliverable.

Then run the mechanical check on the element the failed assertion names:

```bash
git diff --stat            # what this change actually touched
git diff -- <path>         # what it did to the element the assertion names
```

**"The diff touched it" does not mean stale.** A change most often breaks the very code it is
building, so the file the assertion lands in is usually the file the work edited. Touching it
is where a regression *hides*, not where one is ruled out. Three cases, not two:

1. **The diff does not touch it** → regression. The tests missed something. Stop, write the
   failing test, red → green → fix, then demo.
2. **The diff touches it and shows what took its place** — a renamed heading, a moved control,
   a relabelled field the walkthrough can now point at — and that replacement is on the page →
   the script is stale against an intentional change. Update the caption and locator, re-run.
3. **The diff touches it and nothing took its place** — the element is absent outright, or
   present in a state the caption denies → regression, and the most common kind. The work
   broke what it was building.

**Only case 2 is stale, and it has to be shown rather than assumed.** Name the replacement the
diff introduced, out loud, before editing the walkthrough. If you cannot point at one, you are
in case 3, and editing the script there rewrites the claim to fit the defect — a confident
artifact of a broken application, which is the single outcome this skill exists to prevent.

"It's probably just stale" is the sentence that dissolves the guarantee, and it will always be
available. The check is cheap; run it.

## Step 8 — Deliver the artifact

**For:** the developer or reviewer asking whether the feature looks right, holds the right data, and
flows the way it should — the questions tests do not answer. It is read instead of running the
application.

The artifact contract is fixed by this skill and identical across every profile:

- One output directory per demo, at a destination the run is given rather than one it fixes —
  so review captures remain beside their specification under `.junior/`. Promotion uses the
  profile's complete-bundle mechanism after explicit selection and review
- Numbered full-page PNG panels — separate files, so each diffs and zooms independently
- A generated `index.html` grid referencing them relatively, opening over `file://` with no
  server running
- Every panel carries its caption and a number, laid out as a grid so eight panels scan at a
  glance; opening one steps through the sequence with next, previous and escape
- The numbers are how a reviewer refers to a panel, so they stay stable: they are capture
  order, and they appear in both the grid and the opened view

**Review the actual artifact before delivery.** For motion, watch the full recording at normal
speed and intended display size; inspect frames more closely where timing or detail is unclear.
Check that the action, its target, and its result are legible without consulting the script,
that essential views stay in shot, and that unrelated setup or idle time does not dominate.
For stills, inspect every panel in sequence. Passing assertions establish reached states, not
presentation quality. Rework and recapture an unclear demo; do not approve it solely because the
run passed. This visual review is an agent norm, not a guarantee enforced by the helper.

**Hand the artifact to the developer at the end of the run.** Name the file to open. An artifact
left in an output directory for someone to discover is an artifact nobody looks at.

**What never goes in the storyboard:** a panel of a state the story does not claim · a caption
naming what the walkthrough did rather than what the screen shows · the assertion text, locator, or
selector behind a panel · a panel retained from an earlier run · anything about how the demo was
built. The storyboard is evidence a reviewer reads instead of the application; the run's own working
belongs in the walkthrough source, not on the sheet. Baseline:
`../_shared/references/artifact-output-spec.md`.

**The Demo Script written into the story file** carries the medium, the question that decided it,
and the ordered prose of what to show. Not the profile resolution, not the stack the run
discovered, not which alternatives were argued down — the reasoning that picked stills over motion
is worth one clause, and no more.

**Register**, for captions and for anything written into a story file: noun labels for headings —
never sentences, questions or conversational phrases. Prose states facts. No editorial lead, no
anthropomorphising, no dramatic adjective.

## Selective product promotion

Retaining a capture does not select it for product use. Promote only the explicitly selected,
reviewed, successfully completed bundles through the profile's prepare/review/accept flow.
Choose readable product destinations without identity hashes or planning identifiers. Keep
originals and unselected captures intact; never point runner capture or cleanup at product output.

Apply [product isolation](../_shared/references/product-isolation.md) to the whole proposed
product tree, copied tooling, filenames, metadata, captions, rendered media, and viewing docs.
Fix unsuitable content and recapture before promotion. Do not rewrite captured evidence in the copy.
The profile checks byte completeness and replacement ownership; semantic review is a norm.

Open the candidate without private working material and verify all local assets, full-panel
navigation, and recording playback/seeking before acceptance. Use the profile's separate viewing
instructions for product readers; keep run instructions and promotion receipts in `.junior/`.
Product and tracking commits use separate groups and the shared checks. Promotion does not publish.

## Definition of Done

- ✅ A profile was resolved, read, and its helper copied verbatim
- ✅ Every panel was captured through `step`, with a locator that names what its caption claims
- ✅ Demo data was provisioned through the application's own interface
- ✅ Every source a panel renders is owned by the isolated stack or pinned to a fixture; any
  that could not be was named, and its screen dropped or deliberately emptied
- ✅ The run completed fully, or nothing was delivered
- ✅ `index.html` opens over `file://` and every panel renders with its caption
- ✅ The actual artifact was visually reviewed for legible actions, results, framing, and pacing
- ✅ The developer was handed the path, not left to find it
