// <frontend>/tests/demo/capture-reporter.ts
import fs from "node:fs/promises";
import path from "node:path";
import { createHash } from "node:crypto";
import type { FullResult, Reporter, TestCase, TestResult } from "@playwright/test/reporter";

const OWNER = ".capture-owner.json";

async function contents(directory: string, prefix = ""): Promise<Record<string, string | null>> {
  const entries: Record<string, string | null> = {};
  for (const entry of await fs.readdir(path.join(directory, prefix), { withFileTypes: true })) {
    const name = prefix + entry.name;
    if (entry.name === OWNER && !prefix && entry.isFile()) continue;
    if (entry.name.toLowerCase() === OWNER || entry.isSymbolicLink()) throw new Error("Unsafe capture entry: " + name);
    if (entry.isDirectory()) {
      entries[name + "/"] = null;
      Object.assign(entries, await contents(directory, name + "/"));
    } else if (entry.isFile()) {
      entries[name] = createHash("sha256").update(await fs.readFile(path.join(directory, name))).digest("hex");
    } else {
      throw new Error("Unsupported capture entry: " + name);
    }
  }
  return Object.fromEntries(Object.keys(entries).sort().map(name => [name, entries[name]]));
}

/** Attach a byte inventory; only the final runner reporter can seal it as complete. */
export async function captureReceipt(index: string): Promise<Buffer> {
  const directory = path.resolve(path.dirname(index));
  if (await fs.realpath(directory) !== directory || !(await fs.lstat(directory)).isDirectory()) {
    throw new Error("Capture directory must be canonical and real");
  }
  const marker = path.join(directory, OWNER);
  if (!(await fs.lstat(marker)).isFile()) throw new Error("Capture marker must be a regular file");
  const owner = JSON.parse(await fs.readFile(marker, "utf8"));
  if (!owner || typeof owner.identity !== "string" || !owner.identity.trim() ||
      typeof owner.token !== "string" || !owner.token) throw new Error("Invalid capture ownership");
  const files = await contents(directory);
  if (!files["index.html"]) throw new Error("Capture index is missing");
  return Buffer.from(JSON.stringify({ directory, identity: owner.identity, token: owner.token, files }));
}

export default class CaptureReporter implements Reporter {
  private readonly receipts: Buffer[] = [];

  onTestEnd(_test: TestCase, result: TestResult): void {
    if (result.status !== "passed") return;
    for (const attachment of result.attachments) {
      if (attachment.name === "capture-bundle" && attachment.body) this.receipts.push(attachment.body);
    }
  }

  async onEnd(result: FullResult): Promise<{ status: "failed" } | void> {
    if (result.status !== "passed") return;
    try {
      await this.seal();
    } catch (error) {
      // Playwright logs thrown reporter errors without failing the run.
      console.error("Capture completion failed:", error);
      return { status: "failed" };
    }
  }

  private async seal(): Promise<void> {
    const originals = new Map<string, string>();
    for (const receipt of this.receipts) {
      const { directory } = JSON.parse(receipt.toString());
      const current = await captureReceipt(path.join(directory, "index.html"));
      if (!current.equals(receipt)) throw new Error("Capture changed after fixture completion");
      const marker = path.join(directory, OWNER);
      originals.set(marker, await fs.readFile(marker, "utf8"));
    }
    try {
      for (const receipt of this.receipts) {
        const { directory, identity, token, files } = JSON.parse(receipt.toString());
        await fs.writeFile(path.join(directory, OWNER), JSON.stringify({ identity, token, complete: files }));
      }
    } catch (error) {
      for (const [marker, original] of originals) await fs.writeFile(marker, original);
      throw error;
    }
  }
}
