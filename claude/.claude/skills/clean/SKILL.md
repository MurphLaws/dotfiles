---
name: clean
description: Leave the current git repo with a clean working tree - commit every pending change (modified, deleted and untracked files) and push to the remote. Use when the user says "/clean", "clean tree", "leave me a clean tree", "commit and push everything" or similar.
---

# Clean tree

Goal: `git status` shows nothing to commit and the branch is in sync with its remote.

## Steps

1. **Look first.** Run `git status -sb` and `git diff --stat` in the current repo. If the tree is already clean and not ahead of the remote, say so and stop.
2. **Check what would be added** before staging:
   - Secrets or credentials (`.env`, keys, tokens, `credentials*`): never commit them. Add them to `.gitignore` and tell the user.
   - Nested git repos (untracked folders with their own `.git`) or build/cache artifacts: add them to `.gitignore` instead of committing them.
   - Unusually large binaries: ask before committing.
3. **Stage everything:** `git add -A`.
4. **Commit** with a message that describes the actual changes. Follow the style of the repo's recent commits (`git log --oneline -10`): language, prefixes like `nvim:`, tone. Use one commit; split only if the changes are clearly unrelated.
5. **Push:**
   - No upstream: `git push -u origin <branch>`.
   - Rejected because the remote is ahead: `git pull --rebase`, then push again. If the rebase conflicts, stop and show the conflicts to the user.
   - Never force push.
6. **Verify:** run `git status -sb` again and report the commit hash, what went in, and anything that was ignored instead of committed.
