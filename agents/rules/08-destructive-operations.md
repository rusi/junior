# Junior Rule 08: Destructive Operations - ASK FIRST, ZERO TOLERANCE

## Core Rule

**NEVER run an operation that destroys history, state, or data the user did not ask you
to destroy - not even in service of a task the user DID approve.**

Approval of a **goal** is never approval of a destructive **method**.
"Fix the leak" is not "rewrite history". "Clean it up" is not "delete the safety net".

## Never without an explicit, per-instance yes

**Git - history and recovery (the user's undo, and often their only copy):**
- `git reflog expire` / `git reflog delete`
- `git gc --prune=now` (or any form that prunes immediately)
- `git reset` across existing commits - `--hard`, `--soft`, `--mixed` alike
- `git commit --amend`, `git rebase`, `git filter-branch`, `git filter-repo`
- `git push --force` / `--force-with-lease`
- `git clean` (any `-f` form), `git checkout` / `git restore` over uncommitted changes
- `git branch -D`, deleting tags or remote refs, `git stash drop` / `git stash clear`

**Filesystem and data:**
- `rm -rf`, and deleting or truncating any file you did not create this session
- Dropping/truncating database tables, destructive migrations
- Overwriting a file whose current contents you have not read

## Blast radius is part of the ask

Even when a destructive step IS approved, scope it to the target and nothing else:

- ✅ `git reflog delete HEAD@{1} HEAD@{2}` - the two entries actually at fault
- ❌ `git reflog expire --expire=now --all` - the entire repository's undo history

**If you cannot name exactly what will be destroyed, you are not ready to run it.**

## When a destructive step is genuinely required

1. **STOP before running it.**
2. State three things: what will be destroyed, what is **unrecoverable** afterwards, and
   why the goal cannot be reached without it.
3. Offer the least-destructive alternative you found.
4. **Wait for an explicit yes.** Silence is not consent. A prior approval is not consent.
   A "yes" to a different question is not consent.

## Why

Every other class of mistake costs time and can be fixed by another turn of work. These
cost the user data they may have needed and cannot get back. A slow ask is always
cheaper than a lost reflog.

**A destructive command you were not asked to run is a bug, however correct the intent
behind it.**
