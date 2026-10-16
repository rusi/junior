# Profile — XCTest / XCUITest

Use this profile for native app UI walkthroughs run by XCTest/XCUITest. The initial verified
boundary is iOS Simulator on macOS with Xcode 27. This profile produces stills; it does not
record native motion or establish physical-device behavior.

## Runner configuration

Read the existing UI tests before authoring a walkthrough. Reuse their app launch, selectors,
production UI, data provisioning and external-boundary fixture seams. Require a separate opt-in
UI test target and scheme/test plan, so the ordinary regression command never collects demos.
Do not add silent-return or skipped tests to keep walkthroughs out of the default run.

Use an isolated simulator/app test container with synthetic data. Never uninstall, reset or erase
an existing owner container merely to prepare a demo. Where isolation or an outbound fixture seam
is missing, report it; do not capture live private data or invent a replacement application.
An existing UI host rendering production views is valid when the brief identifies its substituted
external boundaries. Such panels cannot establish real account authentication, remote transfer,
notification delivery or source-app handoff.

Host export requires Node 22.12 or later with `--experimental-strip-types` and `xcrun xcresulttool`.
The shared TypeScript modules contain erasable types only; export needs no browser dependency.

## Where walkthroughs live

Place the walkthrough and [NativeStoryboard.swift](../templates/NativeStoryboard.swift) in the
opt-in UI target. Copy the helper unchanged. Keep the existing default test plan unchanged.
Give each walkthrough one XCTest method; feature/diff composition calls each selected story
segment from that method, resetting the application context between segments.

The helper requires a title and brief at initialization. Call `step(caption, element)` after
navigating through the app. It waits for a meaningful hittable element, verifies its frame,
captures the visible app viewport and binds the PNG bytes to the claim. `finish()` attaches the
ordered receipt and closes capture; further steps or a second finish are refused. Missing/offscreen/covered claims throw before capture; let that fail the test.
Do not catch a failing step to continue a walkthrough.

```swift
@MainActor func testSavedPlan() throws {
  let app = launchIsolatedApp() // Reuse the project's existing UI-test setup.
  let demo = try NativeStoryboard(testCase: self, app: app,
    title: "Saved plan", brief: "A saved revision appears in the plan. Judge the updated rows.")
  app.buttons["Plan"].tap()
  try demo.step("The saved activity appears in the plan", app.staticTexts["Synthetic activity"])
  try demo.finish()
}
```

Capture is the app viewport, not a browser full page. Scroll deliberately to demonstrate
additional content, then assert and capture that state separately. A native panel cannot show
content outside its captured viewport. The helper maps the asserted frame into the shared
viewer's thumbnail focus; opening a panel shows the whole captured image.

The helper is the only permitted screenshot path in a walkthrough. Swift cannot disable every
XCTest screenshot method; avoiding those methods and forged attachments is a norm. The exporter
accepts only matching helper receipts with checked image hashes and does not import arbitrary PNGs.
Choosing an element that proves the caption's claim remains judgment, as in other profiles.

## Starting the isolated stack

Use the project's isolated native run command. Select exactly one walkthrough method with
`-only-testing`, retain attachments, disable failure-diagnostic collection, and use a fresh
ignored result-bundle path. Ensure the resulting run includes that method and no extra tests.

```sh
xcodebuild -project App.xcodeproj -scheme AppDemo \
  -destination 'platform=iOS Simulator,name=SIMULATOR_NAME' \
  -resultBundlePath build/Walkthrough-UNIQUE.xcresult \
  -only-testing:AppDemoUITests/Walkthrough/testSavedPlan \
  -collect-test-diagnostics never test CODE_SIGNING_ALLOWED=NO
node --experimental-strip-types scripts/demo/scripts/native-export.cjs \
  build/Walkthrough-UNIQUE.xcresult OUTPUT_ROOT
```

Where the project already wraps its isolated UI run, use that wrapper with its demo target
and selected test arguments, preserving its existing fixture configuration:

```sh
bash scripts/test-demo.sh -only-testing:AppDemoUITests/Walkthrough/testSavedPlan
```

Use this form only if that wrapper exists and forwards arguments; otherwise use the direct
Xcode command above. Do not create a new stack launcher merely to match this example.

Adapt project/scheme/test/device arguments to the existing native project; do not change the
helper. Copy [native-export.cjs](../scripts/native-export.cjs),
[capture-directory.ts](../scripts/capture-directory.ts) and [viewer.ts](../scripts/viewer.ts)
into `scripts/` within the host demo-tool directory, and the shared completion reporter into its sibling `templates/` directory, preserving the shipped relative layout unchanged. These are the same directory and viewer
modules used by the Playwright profile.

The exporter reads the actual result using `xcresulttool`, rejects failed/skipped/expected-failure
or empty/multiple-test runs, exports attachments into its own temporary directory, then checks
the single helper receipt, ordered claims, regular contained input files and exact PNG hashes.
Only then does it create the owned capture directory and seal its complete byte inventory.
Export failure returns nonzero; never hand over an earlier bundle as the failed run's result.

## Output paths

`OUTPUT_ROOT` is an input, normally an ignored exploratory directory or the selected story's
own directory for retention. Output contains numbered captioned PNGs, `index.html` and the
neutral `.capture-owner.json` completion marker. The returned JSON names `index` and `identity`.
Open that exact index locally and inspect every panel and previous/next navigation.

Identity includes the runner’s full project/target/test URL, keeping same-named tests in different targets distinct. Reruns replace only the bundle with matching owned identity. Unowned or mismatched output is
refused. A failed runner/invalid receipt leaves any prior completed bundle intact; it produces
no new storyboard. Do not edit captions, images or receipts after capture to repair evidence. Do not run concurrent exporters against the same owned destination.

## Retention and promotion

Apply the shared [product-isolation workflow](../../_shared/references/product-isolation.md) to
copied tooling and any product delivery. Retain review output beside its specification. For
selected product promotion, use the existing [promotion tool](../scripts/promote.py) and the
Playwright profile's [selective-promotion procedure](playwright.md#selective-promotion), carrying
the native exporter's returned identity unchanged. The completed inventory format is shared;
do not create a second promotion path or publish private ownership metadata.

## Motion and unavailable states

This profile does not answer timing, gesture animation, transient stale content, or floating
control motion questions. State those gaps in the brief and story evidence. Capture reachable
states honestly and leave unpinned/unreachable states out; stills do not verify those transitions.
Device-only assertions remain separate system evidence. Extend the native profile only after a
real consuming project establishes the new capture boundary.

## Demo data and outbound integrations

Use the existing UI-test provisioning helpers and production reader/coordinator. Pin only the
external API/engine/platform seams the existing suite already substitutes, before launching.
Name substitutions and unreachable states in the brief. Do not add fake production routes,
SQL seeding or live-account screenshots to fill a missing state.

## Capture helper — copy verbatim

[NativeStoryboard.swift](../templates/NativeStoryboard.swift)

## Host export adapter — copy verbatim

[native-export.cjs](../scripts/native-export.cjs)

## Shared capture directory — copy verbatim

[capture-directory.ts](../scripts/capture-directory.ts)

## Shared viewer — copy verbatim

[viewer.ts](../scripts/viewer.ts)

## Shared completion receipt — copy verbatim

[capture-reporter.ts](../templates/capture-reporter.ts)
