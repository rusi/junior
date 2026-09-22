// <frontend>/playwright.demo.config.ts
import path from "node:path";
import { defineConfig, devices } from "@playwright/test";

import base from "./playwright.config";

export default defineConfig({
  ...base,
  testDir: "./tests/demo",
  // Walkthroughs are named `<name>.demo.ts` so the e2e run's own file pattern cannot pick
  // them up. Nothing then matches the runner's default pattern either, and a project that
  // followed this profile exactly would be told it has no tests — so the demo run names its
  // own pattern rather than inheriting one written to exclude it.
  testMatch: "**/*.demo.ts",
  // A separate results directory, so a demo run never clears the e2e run's output.
  outputDir: path.join("<the project's gitignored output root>", "demo-results"),
  // The e2e config's HTML reporter writes to a fixed folder; sharing it would overwrite
  // the last e2e report with a demo run nobody was looking for.
  // Keep the completion reporter last: it seals captures after the full run succeeds.
  reporter: [["list"], ["./tests/demo/capture-reporter.ts"]],
  projects: [
    {
      name: "demo",
      use: {
        ...devices["Desktop Chrome"],
        // Fixed, and small enough that committed panels stay affordable. Every panel in
        // every storyboard is this size, which is also what makes them diff across runs.
        viewport: { width: 1280, height: 800 },
        // Off, so the medium can only ever come from a walkthrough's own declaration. An
        // e2e config that keeps video for failures — a common default — is inherited here
        // along with everything else, and a demo run that took a recorder running for the
        // runner's reasons as a walkthrough asking for motion would deliver a recording
        // where the panels should be, on every stills walkthrough, while passing.
        video: "off",
      },
    },
  ],
});
