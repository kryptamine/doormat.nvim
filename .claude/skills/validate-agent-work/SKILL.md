---
name: validate-agent-work
description: Use when finishing any change to this repository, or when the user says "validate", "check my work", "run checks", or "verify changes". Also use automatically after adding or changing a menu key, a highlight group, the logo, the startup logic, or documentation here.
---

# Validate Agent Work

The rules live in [AGENTS.md](../../../AGENTS.md); this is the order to check
them in before handing work back.

## Steps

1. **See what changed** — the branch against `main`, and whatever is not
   committed yet:

   ```bash
   git diff --name-only main...HEAD
   git status --short
   ```

   Stage nothing: the index is the user's to decide.

2. **Run the gate:**

   ```bash
   make check
   ```

   `fmt` runs first and rewrites files, so re-read one before editing it again.

3. **Check what the doormat shows** — for a change to the menu, the logo or
   the colors, open it headless (`nvim --clean --headless --cmd "set rtp^=."`)
   and dump the buffer text, and the touched groups with
   `nvim_get_hl(0, { name = ..., link = false })`, before and after. For a
   key, try it with and without what it needs (a picker, a recent file under
   cwd): it must show up only when it can work. For the startup logic, check
   that `nvim file` and `nvim -` still leave the doormat closed.

4. **Comment pass** — the `## Comment pass` in
   [`.claude/rules/comments.md`](../../rules/comments.md), over the comments
   this change added or touched.

5. **Read the diff against the mandatory rules in AGENTS.md** — the language,
   commit, design and comment rules, and the "Working here" list. Two need a
   search rather than a read: an option added beyond `items` without a reason in
   the pull request, and a key, option,
   group or requirement added without README following it.

6. **Before opening a pull request**, write its body with the `pr` skill and
   check it against
   [.github/pull_request_template.md](../../../.github/pull_request_template.md):
   every section filled, no HTML comment left, no attribution line.

7. **Fix and re-run** — fix what a step found, then run that step again to
   confirm it. If a failure is not yours to fix, say so rather than working
   around it.

8. **Report** — always say what happened:

   - Clean: a brief confirmation.
   - Found and fixed, one line each:

     ```
     Validation found and fixed 2 issues:
     - stylua: reformatted lua/doormat/init.lua
     - README: added the new key to the table
     ```

   - Still broken: what is wrong and why you could not fix it.
