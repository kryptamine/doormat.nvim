# AGENTS.md

doormat.nvim — a very opinionated Neovim dashboard, written in Lua. No
dependencies, no build step, and one option: Neovim loads it straight from the
runtime path and it works without `setup()`.

## Repository layout

```
plugin/doormat.lua     opens the doormat on a bare `nvim`, defines :Doormat
lua/doormat/
  init.lua             open(): the menu, rendering and highlights
  logo.lua             the mark and wordmark, and their color masks
scripts/smoke.lua      the headless check `make smoke` runs
```

## Language rule (mandatory)

**Everything written into this repository is in English.** Code comments,
commit messages, documentation, test names, ticket text — all English, with no
exceptions. This holds regardless of the language the request was made in; only
the conversation with the user follows the user's language.

## Commit convention (mandatory)

Commits follow [Conventional Commits](https://www.conventionalcommits.org):

```
<type>(<optional scope>): <subject>

<optional body explaining why, wrapped at 72 columns>
```

Types in use: `feat`, `fix`, `docs`, `test`, `refactor`, `perf`, `chore`.
Scope is an area (`menu`, `logo`, `highlights`, `startup`, `footer`) or a
picker integration (`fff`, `fzf`, `telescope`).

- Subject in the imperative mood, lowercase, no trailing period, ≤72 characters
  ("add recent files key", not "Added recent files key.").
- The body explains why, not what — the diff already says what.
- One logical change per commit.
- **Never add a co-author trailer or any other attribution** — no
  `Co-Authored-By`, no "Generated with" line, in a commit or a pull request.

## Branches and pull requests (mandatory)

**Never commit to `main`.** Branch from it first, named `<type>/<kebab-summary>`
with the types the commits use: `feat/recent-files`, `fix/resize`,
`refactor/render`.

- **Pull requests are merged by rebase**, never squashed or merged, so each
  commit message is what lands in the history.
- Keep a pull request to one thing. A new key, a logo tweak and a formatting
  sweep are three pull requests.
- **A pull request body follows
  [.github/pull_request_template.md](.github/pull_request_template.md)**:
  Summary, Evidence, Merge Danger and the checklist, every section filled and
  no attribution line. How to fill each section is in
  [.claude/skills/pr/SKILL.md](.claude/skills/pr/SKILL.md), for any agent.

## Design rule (mandatory)

**One option, and none needed.** The menu is the only thing `setup()` takes
(`items`); colors go through `default` highlight groups, never an option. With
no `setup()` call the doormat works as it ships. A new option needs a reason a
highlight group or a built-in item cannot cover, and README documents it. A
menu item, built-in or the user's, shows up only when it can work.

## Comment rule (mandatory)

**A comment is at most three lines**, and it says what is surprising rather than
what is visible. The rule in full, with worked examples, is in
[.claude/rules/comments.md](.claude/rules/comments.md).

## Commands

```sh
make            # list every target
make check      # fmt + lint + smoke   ← the gate before any commit
make fmt        # stylua
make smoke      # start a bare nvim headless, fail unless the doormat opens
```

## Working here

- Needs Neovim 0.10 or newer, and CI runs the smoke on v0.10.4 and stable. An
  API newer than 0.10 needs a fallback or waits for README to raise the floor.
- **Check what a group renders as, not what it is set to.** Every group is set
  with `default`, so a colorscheme can win; compare
  `nvim_get_hl(0, { name = ..., link = false })` before and after a change.
- The doormat opens only on a bare `nvim`: no file argument, nothing on stdin,
  an empty unnamed first buffer. A change to `plugin/doormat.lua` must keep
  `nvim file` and `nvim -` out of its way.
- README's key table, option, color table and requirements describe the code;
  a key, option, group or requirement changed takes README with it.
- `setup()` validates its table and fails loudly on a mistake; a check that is
  only a warning hides a broken menu.
