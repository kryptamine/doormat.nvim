# AGENTS.md

doormat.nvim — a very opinionated Neovim dashboard, written in Lua. No
dependencies, no build step and no options: Neovim loads it straight from the
runtime path.

## Repository layout

```
plugin/doormat.lua     opens the doormat on a bare `nvim`, defines :Doormat
lua/doormat/
  init.lua             open(): the menu, rendering and highlights
  logo.lua             the mark and wordmark, and their color masks
scripts/smoke.lua      the headless check `make smoke` runs
```

## Language rule (mandatory)

**Everything written into this repository is in English**: code comments,
commit messages, documentation. Only the conversation with the user follows
the user's language.

## Commits (mandatory)

[Conventional Commits](https://www.conventionalcommits.org): `<type>(<scope>):
<subject>`, types `feat`, `fix`, `docs`, `test`, `refactor`, `perf`, `chore`.
Subject imperative, lowercase, no trailing period, ≤72 characters; the body
says why. One logical change per commit.

## Branches and pull requests (mandatory)

**Never commit to `main`.** Branch from it as `<type>/<kebab-summary>`
(`feat/recent-files`, `fix/resize`). Pull requests are merged by rebase and
keep to one thing.

## Design rule (mandatory)

**No options.** The plugin is opinionated on purpose: a change that needs a
`setup()` table is the wrong change. Colors are the one way in, through
`default` highlight groups. A menu key shows up only when it can work.

## Comment rule (mandatory)

**A comment is at most three lines**, and it says what is surprising rather
than what is visible.

## Commands

```sh
make            # list every target
make check      # fmt + lint + smoke   ← the gate before any commit
make fmt        # stylua
make smoke      # start a bare nvim headless, fail unless the doormat opens
```
