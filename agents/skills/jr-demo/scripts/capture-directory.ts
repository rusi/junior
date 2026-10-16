// tests/demo/capture-directory.ts
import fs from "node:fs/promises";
import path from "node:path";
import { createHash, randomUUID } from "node:crypto";

export function slug(caption: string): string {
  return caption
    .toLowerCase()
    .replace(/[^a-z0-9]+/g, "-")
    .replace(/^-+|-+$/g, "")
    .slice(0, 60);
}

export function capturePath(root: string, title: string, identity: string): string {
  if (!root.trim() || !identity.trim()) throw new Error("Capture root and identity must be nonempty.");
  const hash = createHash("sha256").update(identity).digest("hex");
  return path.join(path.resolve(root), `${slug(title) || "walkthrough"}-${hash}`);
}

export class CaptureDirectory {
  private readonly token = randomUUID();

  readonly directory: string;
  private readonly root: string;
  private readonly identity: string;
  private constructor(directory: string, root: string, identity: string) {
    this.directory = directory;
    this.root = root;
    this.identity = identity;
  }

  private get marker(): string { return path.join(this.directory, ".capture-owner.json"); }

  static async open(root: string, directory: string, identity: string): Promise<CaptureDirectory> {
    if (!root.trim() || !directory.trim() || !identity.trim()) {
      throw new Error("Capture root, directory, and identity must be nonempty.");
    }
    const parent = path.resolve(root);
    const target = path.resolve(directory);
    if (target === parent || path.dirname(target) !== parent) {
      throw new Error("Capture directory must be a direct child of the output root.");
    }
    await fs.mkdir(parent, { recursive: true });
    const canonicalRoot = await fs.realpath(parent);
    const owned = new CaptureDirectory(path.join(canonicalRoot, path.basename(target)), canonicalRoot, identity);
    const existing = await fs.lstat(owned.directory).catch((error: NodeJS.ErrnoException) => {
      if (error.code === "ENOENT") return null;
      throw error;
    });
    if (existing) await owned.remove(false);
    await fs.mkdir(owned.directory);
    await fs.writeFile(owned.marker, JSON.stringify({ identity, token: owned.token }), { flag: "wx" });
    return owned;
  }

  async remove(currentRun = true): Promise<void> {
    // Recheck canonical containment and ownership immediately before every recursive removal.
    if (path.dirname(this.directory) !== this.root ||
        await fs.realpath(this.root) !== this.root ||
        !(await fs.lstat(this.directory)).isDirectory() ||
        await fs.realpath(this.directory) !== this.directory) {
      throw new Error("Capture directory escaped its output root or is not a real directory.");
    }
    if (!(await fs.lstat(this.marker)).isFile()) throw new Error("Capture ownership marker must be a regular file.");
    const owner = JSON.parse(await fs.readFile(this.marker, "utf8"));
    if (owner?.identity !== this.identity || typeof owner.token !== "string" || !owner.token ||
        (currentRun && owner.token !== this.token)) {
      throw new Error("Capture directory ownership does not match this walkthrough or run.");
    }
    await fs.rm(this.directory, { recursive: true });
  }
}
