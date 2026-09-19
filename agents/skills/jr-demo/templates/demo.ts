// <frontend>/tests/demo/demo.ts
import path from "node:path";
import { fileURLToPath } from "node:url";

import type {
  Locator,
  PlaywrightTestArgs,
  PlaywrightTestOptions,
  PlaywrightWorkerArgs,
  PlaywrightWorkerOptions,
  TestType,
} from "@playwright/test";

import { capturePath, PRESS_FEEDBACK_MS, Storyboard } from "./storyboard";
// Project-specific: the e2e fixture that provisions an isolated session per worker. Where a
// project has none, import `test as projectTest` from "@playwright/test" instead.
import { test as projectTest } from "../e2e/fixtures";

// A project fixture declaring its test-scoped fixtures as `Record<string, never>` — the
// Playwright idiom for "this adds none" — intersects with a new fixture to resolve every key
// to `never`, and `demo` becomes unusable inside a walkthrough. Widening to the built-in
// arguments before extending keeps the project's worker-scoped isolation while leaving room
// for a fixture of our own. Harmless where the project fixture declares real ones.
const base = projectTest as unknown as TestType<
  PlaywrightTestArgs & PlaywrightTestOptions,
  PlaywrightWorkerArgs & PlaywrightWorkerOptions
>;

// Where a run writes. The default suits an exploratory run: a gitignored path, so
// regenerating an artifact never dirties the working tree. A run whose artifact is meant to
// be kept points this at the directory it belongs in — beside the story or feature it is
// evidence for — and the artifact lands there directly.
//
// Directly, rather than being copied afterwards, because a copy step has to enumerate what
// it moves, and an enumeration is a list that goes stale the moment a run learns to produce
// something new. The artifact then exists, the run reports success, and the thing nobody
// listed is silently left behind in a directory git was told to ignore.
const OUTPUT_ROOT = process.env.DEMO_OUTPUT !== undefined
  ? process.env.DEMO_OUTPUT
  : path.resolve(
      path.dirname(fileURLToPath(import.meta.url)),
      // Project-specific: the gitignored output root, relative to this file.
      "..", "..", "..", "output", "playwright", "demo",
    );

/**
 * Hands a walkthrough its storyboard, and decides afterwards whether it earned one.
 *
 * Teardown runs whether the body passed or threw, which is the only place the
 * no-artifact-on-failure rule can be enforced without a walkthrough author remembering it.
 */
export const test = base.extend<{ demo: Storyboard }>({
  demo: async ({ page, video }, use, testInfo) => {
    // What the walkthrough declared, not what the runner happens to be doing. Every other
    // recording mode — kept for failures, kept on a retry — is the runner's business, and
    // reading one of those as a request for motion delivers a recording in place of the
    // panels while the run reports success.
    const motion = video === "on" || (typeof video === "object" && video.mode === "on");

    const identity = JSON.stringify([
      path.relative(testInfo.config.rootDir, testInfo.file),
      testInfo.project.name, testInfo.titlePath, testInfo.repeatEachIndex,
    ]);
    const storyboard = await Storyboard.open(
      page,
      testInfo.title,
      capturePath(OUTPUT_ROOT, testInfo.title, identity),
      motion,
      OUTPUT_ROOT,
      identity,
    );

    await use(storyboard);

    if (testInfo.status !== "passed") {
      await storyboard.discard();
      return;
    }

    // Writing can still refuse a storyboard with no brief, or fail on a filesystem error.
    // Discard on the way out, or a refused run leaves panels with no sheet: a partial
    // artifact, which is the one thing this contract does not allow.
    try {
      // Saved before the sheet is written, because the sheet points at it.
      const weight = await storyboard.record();
      const index = await storyboard.write();
      console.log(`\n  Storyboard: ${index}${weight ? `  (recording ${weight})` : ""}\n`);
    } catch (error) {
      await storyboard.discard();
      throw error;
    }
  },
});

/**
 * Press deliberately, so a recording shows the press before whatever it causes.
 *
 * A synthetic click is instantaneous: the button goes down and up within a millisecond, and
 * whatever it triggers — a navigation, a panel opening — starts while the press indicator is
 * still animating. The recording then reads as though the consequence came first, which is
 * backwards and looks like a glitch.
 *
 * Holding the button is not a simulation of a press; it is one. The click event still fires
 * on release, so the ordering on screen is the real ordering.
 */
export async function press(locator: Locator): Promise<void> {
  const page = locator.page();
  const box = await locator.boundingBox();
  if (!box) {
    throw new Error("Nothing to press: the element has no box, so it is not laid out.");
  }
  await page.mouse.move(box.x + box.width / 2, box.y + box.height / 2);
  await page.mouse.down();
  // Derived, not chosen: the hold has to outlast the press indicator, and the margin is what
  // makes the release visible as a separate moment rather than the animation's last frame.
  await page.waitForTimeout(PRESS_FEEDBACK_MS + 100);
  await page.mouse.up();
}

export { expect } from "@playwright/test";
