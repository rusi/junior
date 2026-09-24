# Profile — Playwright

The runner determines this profile, not the frontend framework. Any project whose end-to-end
tests run on Playwright uses this file, whatever it renders with.

## What this profile needs from a project

Check these six before relying on anything below. Where one is missing, say so rather than
building it — a demo stack assembled from scratch re-earns badly what the test suite already has.

| Requirement | Why it matters |
|---|---|
| Playwright 1.30 or later | Per-project `testDir`/`outputDir` and `expect(locator, message)` |
| An isolated-stack run target | Demos never run against a shared instance or a live database |
| API-level provisioning helpers used by the existing e2e specs | Demo data goes through the application, never through SQL |
| A seam for pinning outbound integrations | An isolated datastore says where the app writes, not where it reads; a live account renders straight into a committed panel |
| A gitignored artifact output path | Panels are regenerated, so they do not belong in a working tree by accident |
| Per-worker session isolation, where the app holds per-user context | Two workers sharing a login overwrite each other's context mid-run |

The existing e2e specs answer all six faster than the configuration does. Read them first.

## Runner configuration

**Add a second config that extends the existing one. Do not edit the existing one.**

A demo project added to the e2e config joins the default run set, so the ordinary test command
starts capturing storyboards. Extending instead keeps the demo run explicit and leaves the e2e
config untouched, while inheriting its `webServer`, `globalSetup`, and `baseURL` rather than
restating them.

[playwright.demo.config.ts](../templates/playwright.demo.config.ts)

## Where walkthroughs live

A `demo/` directory of their own, next to the e2e specs — `<frontend>/tests/demo/` where the
specs sit in `tests/`, `<frontend>/e2e/demo/` where they sit in `e2e/`. One walkthrough file per
demo, named `<name>.demo.ts` for what it shows.

**What keeps demos out of the e2e run is the filename, not the directory.** A project whose e2e
`testDir` is the parent of `demo/` is the normal case rather than a mistake: the e2e run matches
`*.spec.ts` / `*.test.ts` and a walkthrough is neither, so it is never collected there, while the
demo config's own `testMatch` collects nothing else. Check that both halves hold — list each run
and confirm the demo files appear in exactly one of them — rather than trying to place the
directory somewhere the e2e config cannot see.

Before copying into product paths, apply [product isolation](../../_shared/references/product-isolation.md).
Copy the linked `storyboard.ts` and `multiview.ts` helpers, `capture-reporter.ts`, and `demo.ts` fixture into
that directory. Keep the helper and reporter unchanged; adapt only the fixture's two
marked project-specific lines. Include the completion reporter last in the demo config.
A bundle is eligible for promotion only when that reporter seals its complete byte inventory
at successful run completion; writing an index or migrating an old marker does not qualify.

## Starting the stack

**Find out first what actually starts this project's stack**, because the answer decides the
invocation and the two answers look nothing alike.

**Where a script wraps the run**, go through it, pointing it at the demo config:

```bash
<the project's isolated e2e script> --config=playwright.demo.config.ts --project=demo
```

Where the script forwards arguments to `playwright test`, this is the whole invocation. Where it
does not, add pass-through rather than starting the stack by hand: a demo run that skips the
script skips the database reset and seeding the walkthrough is written against.

**Where there is no such script** — the config's own `webServer` starts the application, which the
demo config inherits along with everything else — the runner is the whole invocation:

```bash
npx playwright test --config=playwright.demo.config.ts --project=demo
```

Do not write a script to satisfy the shape of the first case. The stack the e2e suite starts is
the stack the demo needs, and it is already configured.

**Whatever the walkthrough needs the stack's own processes to know, export on that command.**
The demo config inherits `webServer` rather than restating it — which is the point — so its
commands are fixed, and their environment is the only part still open. A fixture the application
reads from an environment variable is set here:

```bash
<VAR>=<fixture path> npx playwright test --config=playwright.demo.config.ts --project=demo
```

An already-running server is reused rather than restarted where the config says so, and a reused
server keeps the environment it was started with. A variable that arrives after the fact changes
nothing, and the run reads as though the fixture were ignored — so make sure no stack is up from
an earlier run before a walkthrough that depends on one.

## Demo data

Provision through the same API helpers the e2e specs use, from the walkthrough's own setup.
Never by direct database writes.

The seeded database a demo starts against is usually close to empty — enough to sign in, and
little else. A walkthrough that assumes populated data captures empty screens, and an empty
screen with a confident caption is exactly the artifact this skill exists to prevent.

Where the project provisions a scope per worker, create the demo's own scope and fill it. Inside
a scope nobody else touches, deterministic names are safe, and deterministic names are what keep
panels diffable across runs.

## Outbound integrations

An isolated stack contains what the application writes. It says nothing about what the
application reads, and a screen aggregating remote widgets renders whatever a connected account
returns during the run — into a full-page panel, which is then copied beside a story spec and
committed.

**Enumerate before scripting.** The list is the clients the application calls out through; find
them where they are constructed rather than where they are used. The e2e suite has usually
pinned some of them already, which answers both how this project does it and which ones it has
not done it to.

**Pin through the seam the application already has** — normally a fixture file or a fake
provider, selected by configuration the server process reads at startup. Export it on the run
command, which is where a walkthrough's environment reaches the stack's own processes:

```bash
<FIXTURE_VAR>=<fixture path> npx playwright test --config=playwright.demo.config.ts --project=demo
```

A reused server keeps the environment it was started with, so a fixture variable arriving after
the fact changes nothing and the run reads as though the provider had simply ignored it. See
*Starting the stack*.

**Where the application offers no such seam, the runner cannot supply one.** Request
interception in the browser does not reach a fetch the server makes, and where it does reach one
it fabricates a response the application never received — a panel of a state that never existed.
The honest options are to add the seam in the application, which is the same seam its own tests
need, or to leave that screen out of the storyboard.

## Output paths

One directory per demo, named with a readable title prefix and a stable identity hash,
regenerated wholesale each run:

```
<destination>/<walkthrough-name>-<identity-hash>/
├── 01-first-caption.png
├── 02-second-caption.png
├── index.html
└── .capture-owner.json
```

Empty or non-Latin titles use `walkthrough` as the prefix. The hash includes the runner's
test identity and repeat index, separating files, projects, and repeated tests while keeping
reruns stable. Keep the ownership marker with the artifact. Setup and discard refuse the
output root, symlinks, and unmarked or mismatched directories. Legacy unmarked captures
remain untouched; review and remove them manually if no longer needed.

**The destination is an input to the run, not a fixed location.** Unset, it is the project's
gitignored output root, which is what an exploratory run wants — regenerate as often as you
like and the working tree stays clean. A run whose artifact is meant to be kept names the
directory it belongs in:

```bash
DEMO_OUTPUT=<the story's own directory> <the run command>
```

The retained artifact lands there and keeps its ownership marker. Retain review captures
under `.junior/` beside their specification. Reruns replace only the capture they own;
they never write directly into promoted product directories.

A walkthrough recorded as motion writes to the same place, with a recording where the panels
would be. See *Motion capture*.

## Selective promotion

Promotion has two commands with a review between them: prepare a standalone copy, then
accept that exact copy into the product destination. The agent runs the commands and carries
their returned paths forward; the user selects the capture and reviews the result.

After reviewing a completed capture, use [promote.py](../scripts/promote.py) from its installed
skill location; do not copy this internal migration/promotion tool into product source.
It imports the existing shared isolation validator. Supply the exact identity from the retained
marker and a readable destination such as `demos/notebook/editing`. Set `--repo` to the
Git root; promotion refuses repository subdirectories before creating private state.

```sh
python3 <skill>/scripts/promote.py --repo <repository> prepare --root <capture-root> --source <capture-directory> --identity '<runner-identity>' --destination demos/notebook/editing --reviewed
```

The result returns `index` (the copy to review) and `ticket` (the generated `ticket.json`
path to pass unchanged to `accept`). The ticket records the source, destination, and file
hashes so acceptance can refuse anything changed since preparation. It is private tool state;
do not author or edit it. Preparing leaves the product destination untouched.

Open the returned index locally, inspect captions and
all assets, and exercise full-panel previous/next navigation or video playback and seeking.
Review it in a disposable copy without private files. The candidate preserves every source file,
empty directory, and nested asset byte-for-byte, omitting only the root ownership marker.
No media-extension allowlist exists. Symlinks and nested ownership markers are refused.

Correct unwanted content in the walkthrough and recapture; never edit evidence during promotion.
Author standalone viewing instructions outside the copied bundle using
[viewing.md](../templates/viewing.md), with a real relative link to its index. Capture/run
instructions and review decisions stay in `.junior/`. Apply the shared product checks to the
complete proposed tree, including copied helpers, names, and viewing documentation. The optional
`--review` accepts the shared validator's exact review decisions; semantic media review remains
required.

After candidate review, pass the returned ticket path:

```sh
python3 <skill>/scripts/promote.py --repo <repository> accept --ticket <ticket-path> --reviewed
```

Acceptance rechecks source, candidate, destination, and isolation before replacing anything.
Only destinations previously accepted by this tool and still byte-identical may be replaced.
Unowned content and changed published bundles are refused. A failed replacement restores the
previous bundle; its backup and ownership receipts remain recoverable in `.junior/demo-promotion/`.
Do not run concurrent capture or promotion writers against the same paths. Process termination
or machine failure can leave a recovery directory: inspect the saved `previous` bundle before
retrying; no crash-atomic multi-directory transaction is claimed. Product commits and tracking
commits remain separate under the [shared commit checks](../../_shared/references/product-isolation.md).

## Legacy ownership migration

For an explicitly selected retained legacy capture, use the same internal tool:

```sh
python3 <skill>/scripts/promote.py migrate --root <capture-root> --source <capture-directory> --identity '<runner-identity>'
```

Migration validates direct-child containment, metadata type, identity, and token before renaming
ownership metadata to `.capture-owner.json`, preserving its bytes and every capture file.
Missing, malformed, symlinked, or conflicting markers refuse without adopting ownership.
Migration supplies no completion proof: recapture through the current runner before promotion.

## Motion capture

**Capture boundary:** single-view motion retains the fixture page's `page.video()`, from page
creation until close. Use *Two-view motion* below when the cause and result occupy different
pages. Apply the skill's *Motion composition* review before recording; a receiver-only recording
cannot show an essential off-screen action.

Stills are what a walkthrough produces unless it says otherwise, and saying otherwise is one
declaration at the top of the file. Nothing else changes: the same fixture, the same
`demo.step`, the same refusal to deliver anything when a step's assertion fails.

```ts
// <frontend>/tests/demo/<name>.demo.ts
test.use({
  // The medium, declared once. The helper reads this option rather than whether a recorder
  // happens to be running, so a recording kept for some other reason is not mistaken for a
  // walkthrough asking for motion.
  video: { mode: "on", size: { width: 1280, height: 800 } },
  // Slowed, because this artifact is watched by a person rather than diffed by a machine. A
  // menu that opens across two frames is a menu nobody can judge.
  launchOptions: { slowMo: 250 },
});
```

**At file scope, not inside the test.** Both are worker-level options, so the runner gives the
file a worker of its own rather than reconfiguring one mid-run. It is also why the opt-in is per
walkthrough: a file is one walkthrough.

**The declaration is what routes the artifact, not the recorder.** Most e2e configs keep
video for failures, and the demo config inherits that along with everything else — so the demo
project pins `video: "off"` and a walkthrough turns it back on for itself. Taking a running
recorder as a request for motion would put a recording where the panels belong, on every stills
walkthrough, in a run that reports success from end to end.

**The recording size is pinned rather than left to default.** Unset, the recorder scales the
viewport down to fit a box of its own, so recordings would differ in size from the panels and
from each other, and the diff across runs that makes an artifact reviewable goes with it. It
matches `VIEWPORT` in `storyboard.ts`.

**What a motion run delivers:**

```
<destination>/<walkthrough-name>-<identity-hash>/
├── walkthrough.webm
├── index.html
└── .capture-owner.json
```

`index.html` carries the brief, the player, and the ordered list of claims the run asserted.
There are no panels: `demo.step` still asserts and still halts the run when it cannot, and what
it appends is the claim rather than an image.

**The pointer is drawn into the page, because the recorder does not draw it.** A screencast
composites the page, not the operating system's cursor — so without this, a recording of a hover
or a click shows everything except the thing the walkthrough is about, and a reviewer is left
inferring where the mouse is from whatever the page happens to highlight.

`storyboard.ts` draws an arrow whose tip is the exact event coordinate, in motion mode only,
with a small mouse device beside it that appears while something is being pressed or turned:
the pressed button lights up — left, right and wheel each distinct, because a right-click
otherwise looks identical to a left-click — and a chevron steps once per wheel event. The tip rather than the centre of a shape, because a pointer's whole
job is to say precisely where — and because an arrow's body hangs away from its own tip, it
never covers the thing the caption is about. It takes no pointer events, so nothing the
walkthrough clicks can land on it, and stills never carry it.

**Weight is reported, not enforced.** The run prints what the recording weighs alongside the
path, and the person committing it decides. A limit that refused would throw away a complete,
correct artifact over a number — and what a recording should weigh depends entirely on what it
is evidence for.

Choose duration and resolution for the visible question. Follow the skill's motion composition
and playback review; file size alone says nothing about clarity. Preserve readable content and
real transition timing rather than shrinking an essential view or accelerating the interaction
to meet an arbitrary size target.

**Playback.** The sheet plays the recording inline over `file://` in the browsers this profile
records for. A viewer whose browser will not play the format opens the file directly with
anything that will — it sits beside `index.html` under its own name.

## Two-view motion

Two-view capture requires Chromium and `ffmpeg` on `PATH` with `drawtext`, `hstack`, and
`libvpx` support. The two viewports are fixed at 1280 × 800; the output is a single
2560 × 848 WebM at 25 fps, with permanent labels above the views. Use a wide player or
full-screen playback and verify that both views remain readable. More than two views,
audio, pause, and trimming are unsupported.

Declare two distinct labels and disable Playwright video at file scope:

```ts
test.use({ demoViews: ["Editor", "Observer"], video: "off" });
```

The fixture page takes the first label. Open and initialize the second page through the
project's normal isolated-session helpers, then call
`await demo.registerView("Observer", observer)` and `await demo.startRecording()`.
Both pages must have video disabled. Separate browser contexts are supported. Keep both pages
and contexts open until fixture teardown; the helper closes the pages after composition,
and the runner owns their contexts. Setup happens before the explicit start, so the recording
begins with both intended starting states visible.

Use `demo.step(caption, locator)` for each claimed state in either page. The helper prefixes
claims with the registered label and refuses locators from other pages. Interact with the
actual application; never script the receiving view's contents to imitate propagation.
Both views receive pointer feedback, including after navigation. Two-view feedback uses
immediate cursor/button changes: overlay transitions can stall Chromium screencast delivery.

Frames carry Chromium's shared wall-clock timestamps. Composition samples both streams at
the nearest frame on one common 25 fps timeline, advancing a future change by at most
half an output frame; it does not align action and result events
or reset each stream's start independently. Missing/invalid/non-monotonic timestamps, startup
timeouts, wall-clock changes, lost sessions, or encoder errors fail the run and discard its
owned output. Temporary frame files are removed before the completion receipt is emitted.
The existing reporter and promotion procedure apply unchanged.

Verify synchronization on the target runner using independent visible clocks in both pages,
with staggered page creation and samples across the full recording. Relative error must stay
within one output frame (40 ms). Repeat verification after browser/capture changes; capture
load and compositor behavior can affect delivery. A failed timing check blocks delivery.
Then review the real application's interaction, pointer placement, labels, and readable size,
and exercise playback and seeking on the standalone promoted copy. Assertions prove claimed
states; they do not certify intervening frames or application propagation latency.

## The capture helper — copy verbatim

This is the guarantee. Copy it unchanged; do not adapt it, and do not add a capture path to it.

[storyboard.ts](../scripts/storyboard.ts)

## The multi-view capture backend — copy verbatim

This module travels alongside the helper and is loaded only for two-view recording.

[multiview.ts](../scripts/multiview.ts)

## The completion reporter — copy verbatim

No project-specific edits. This file travels alongside the helper and fixture.

[capture-reporter.ts](../templates/capture-reporter.ts)

## The fixture — copy verbatim

Two lines are project-specific and marked. Extend the project's own e2e fixture rather than
`@playwright/test`, so a demo inherits the session isolation the e2e suite already established.

[demo.ts](../templates/demo.ts)

## What a walkthrough looks like

```ts
// <frontend>/tests/demo/<name>.demo.ts
import { expect, test } from "./demo";

test("Login opens the account page", async ({ page, demo }) => {
  demo.brief("Sign in with an isolated demo account. Judge whether the destination identifies the signed-in user.");
  // Provision this synthetic account through the project's existing API helpers.
  await page.goto("/login");
  await demo.step("Login form asks for email and password", page.getByLabel("Email"));
  await page.getByLabel("Email").fill("demo@example.com");
  await page.getByLabel("Password").fill("demo-only-password");
  await page.getByRole("button", { name: "Sign in" }).click();
  await expect(page.getByRole("heading", { name: "Account" })).toBeVisible();
  await demo.step("Account page identifies the signed-in user", page.getByText("Demo User"));
});
```

Call `demo.brief` once to state what the reviewer should judge, then `demo.step` for each
asserted caption. Everything else is ordinary Playwright — navigate and interact the way
a user would.

### Driving the pointer, in a motion walkthrough

A recording shows what the pointer does. Anything the walkthrough does *without* the pointer
happens on screen by itself, and a reviewer watching a value change with no visible cause
cannot tell whether a user could have caused it.

**Click with `press`, not `click`.** `demo.ts` exports it. A synthetic click is instantaneous,
so the navigation it triggers begins while the press indicator is still animating and the
recording reads as though the page changed first.

**Reach controls by moving to them.** `selectOption`, `fill` and `check` set a control's value
without touching the mouse, so the pointer never appears and the control changes on its own.
Move to the control and press it first, then set the value: the reviewer sees a pointer arrive,
press, and a result follow.

**Scroll with the wheel, not with an assertion.** `scrollIntoViewIfNeeded` — which `step`
calls before capturing — moves the page programmatically, so a recording shows the view sliding
with nothing accounting for it. Where a walkthrough needs to scroll, turn the wheel:
`page.mouse.wheel(0, 300)`. The device beside the pointer steps once per event, so a reviewer
sees how far and in which direction rather than watching the page drift.

**A native `select` records with a hole in it.** Its list is drawn by the operating system and
appears in no recording, and arrow keys on a focused select do not change it in this runner —
so the one step a viewer most wants to see is the one step unavailable.

What *is* real is the rest: press the control as a user would, and let `selectOption` make the
choice. It fires the same input and change events a user's pick fires, so the application
cannot tell the difference and the state it lands in is genuinely the state a user would reach.
Say in the brief that the list is missing and why. A viewer told where the hole is reads the
recording correctly; one left to notice it themselves reads a value changing by itself and
distrusts the whole artifact.

**Say what the recorder cannot capture.** A screencast composites the page. A native select
popup, a file dialog, an autofill menu and the operating system's own cursor are drawn outside
it and appear in no recording — which is why the pointer is drawn back in. Where a walkthrough
depends on one of those, put it in the brief rather than leaving a reviewer to wonder what
happened in the gap. A missing thing nobody was told about reads as a defect in the
application.

### Settle between actions

`demo.ts` re-exports `expect` for this, and a walkthrough needs it more often than it needs a
panel.

An action whose effect the next action depends on must be waited for before acting again.
A form reopened while its previous save is still in flight resets the fields underneath the
values just typed into them, and the failure surfaces several steps later as a missing element
that looks like a bad locator. Assert the effect — the row that should have appeared, the
message that should have shown — and only then act again.

A panel is one way to wait, and the better one where the intermediate state is worth showing.
Where it is not, assert without capturing rather than padding the storyboard.
