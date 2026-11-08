# doormat.nvim

_The very opinionated Neovim dashboard: a logo, four keys and your startup time._

```
                 ▄█               ▄█
               ▄████▄           ▄███
            ▄▄███████▄        ▄█████
                     ...
                 ▀           █▀   ▀█

                    ╭╮╷╭─╴╭─╮╷ ╷╷╭┬╮
                    │╰┤├╴ │ ││╭╯││││
                    ╵ ╵╰─╴╰─╯╰╯ ╵╵ ╵

            s restore   f find   g grep   q quit

                     v0.12.6  ·  43 ms
```

Start `nvim` with no arguments and the doormat is there. Open anything and it
is gone. There is nothing to configure.

| key | does                                                                 |
| --- | -------------------------------------------------------------------- |
| `s` | restore: reopen the last file you edited under the current directory |
| `f` | find a file                                                          |
| `g` | grep                                                                 |
| `q` | quit                                                                 |

A key only shows up when it can work: `s` needs a recent file under the
current directory, and `f` and `g` need a picker, the first of
[fff.nvim](https://github.com/dmtrKovalenko/fff.nvim),
[fzf-lua](https://github.com/ibhagwan/fzf-lua) and
[telescope.nvim](https://github.com/nvim-telescope/telescope.nvim) that is
installed. The startup time comes from
[lazy.nvim](https://github.com/folke/lazy.nvim) and is left out without it.

Needs Neovim 0.10 or newer.

## Installation

### [lazy.nvim](https://github.com/folke/lazy.nvim)

```lua
{ "kryptamine/doormat.nvim", lazy = false }
```

It has to load at startup: it opens on `VimEnter`.

### Without a plugin manager

```lua
vim.pack.add({ "https://github.com/kryptamine/doormat.nvim" })
```

`vim.pack` needs Neovim 0.12; on older versions clone the repository into a
`pack/*/start/` directory on your `packpath`.

## Usage

`:Doormat` opens it again in a new buffer.

## Colors

The mark follows your terminal colors. When the colorscheme sets the
`:terminal` palette (`g:terminal_color_N`), the mark takes its blue (4) and
bright green (10, or 2); the dark green is that green mixed half way into the
`Normal` background, since many palettes make green and bright green one
color. Without that palette the mark keeps the official Neovim colors below,
and without `termguicolors` it uses the terminal's own ANSI colors. Every
group is set with `default`, so a colorscheme or your config can override any
of them:

| group                   | used for                     | default                          |
| ----------------------- | ---------------------------- | -------------------------------- |
| `DoormatLogoBlue`       | the mark's left bar, "neo"   | `#9fb2d6`, ANSI 4                |
| `DoormatLogoLightGreen` | the mark's diagonal          | `#8ac568`, ANSI 10               |
| `DoormatLogoGreen`      | the mark's right bar, "vim"  | `#476834`, ANSI 2                |
| `DoormatKey`            | the keys                     | links to `DoormatLogoLightGreen` |
| `DoormatHint`           | the key labels               | links to `Comment`               |
| `DoormatFooter`         | the version and startup time | links to `Comment`               |

## License

[MIT](LICENSE)
