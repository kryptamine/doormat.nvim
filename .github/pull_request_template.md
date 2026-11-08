## Summary

<!--
The smallest view that makes the point: the doormat as drawn before and
after, a diff of the menu or the highlights, a file tree, each beside one or
two lines of why.
-->

Closes #

## Evidence

<!--
A before and an after: screenshots of the doormat, or its buffer text, keys
and resolved highlights. `make check` is the gate; show what you looked at
beyond it.
-->

- **Before:**
  **After:**

## Merge Danger

<!--
A two-way door is cheap to walk back; a one-way door is not — a menu key
remapped or removed, a highlight group users override, the :Doormat command,
the filetype or module name.
-->

**Door:** <!-- one-way or two-way -->

**Blast Radius:** <!-- one word: what could break, and for whom -->

## Before merging

- [ ] `make check` is green locally.
- [ ] One logical change per commit, Conventional Commits, no co-author
      trailer. **PRs are rebased, never squashed or merged**, so the commit
      messages are what lands in the history.
- [ ] No option or `setup()` added; a key shows up only when it can work.
- [ ] README's keys, colors and requirements match the code.
- [ ] This pull request is one thing.
