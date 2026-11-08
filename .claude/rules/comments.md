---
description: How to write comments, and what never to comment
---

# Comments

Lua, and this repository's Lua. Comments here are in English, like everything
else written into the repository, whatever language the request was made in.

## Rules

- These rules cover every kind of comment: LuaLS annotations (`---@class`,
  `---@field`, `---@param`), doc comments above a function, and inline ones.
- Comment only where it is genuinely needed: a declaration or a block whose
  intent is not obvious at a glance. Obvious code gets none.
- **A comment is at most three lines.** A hard cap. Anything longer belongs in
  AGENTS.md or README, with one line here pointing at it.
- A doc comment reads as a sentence. Inline comments (`--`) need not be full
  sentences.
- LuaLS annotations are types, not prose: keep them, and keep them true. A
  `---@field` whose field is gone goes with it.
- Explain the gist of the thing the comment sits on: what it does, plus the why
  when that is not obvious. Never who calls it or when it runs — call sites
  move and the comment then lies. An event ordering the code depends on
  (`VimEnter`, `UIEnter`) is a why, not a call site.
- Never record provenance: which plugin or theme an idea or a color was taken
  from, which issue, which commit. That is what `git log` is for.
- Keep a comment that stops a reader "fixing" the code and breaking it: a
  `default = true` that lets a colorscheme win, an ordering that matters, a
  Neovim quirk the code works around.
- Plain language, plain words. If a sentence needs a second read, rewrite it
  shorter.
- Do not restate a line the code already states (`-- open the doormat` above
  `require("doormat").open()`).
- A function, key or group deleted takes its comment with it.

## Examples

Bad, restates the code:

```lua
-- Set the filetype to doormat
vim.bo[buf].filetype = "doormat"
```

Bad, provenance:

```lua
-- Taken from alpha-nvim, see issue #3, tuned on 2026-11-08
local function center(lines)
```

Good, a why the code cannot state:

```lua
-- lazy.nvim measures startup on UIEnter, after the doormat is first drawn
```

Good, stops a "fix" that would break overriding:

```lua
-- `default`, so a colorscheme that defines these groups wins
local function set_highlights()
```

Good, none at all:

```lua
DoormatHint = { link = "Comment" },
DoormatFooter = { link = "Comment" },
```

## Comment pass

Write the code first. As the last step before reporting, check the comments
this change added or touched against the rules above. Edit comments only, never
code.
