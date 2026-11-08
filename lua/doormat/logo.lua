-- The Neovim mark and wordmark, drawn in block and box-drawing characters.
local M = {}

M.logo = [[
     ▄█               ▄█
   ▄████▄           ▄███
▄▄███████▄        ▄█████
███████████       ██████
████████████▄     ██████
██████▀██████▄    ██████
██████ ▀███████   ██████
██████   ███████▄ ██████
██████    ▀██████▄██████
██████     ▀████████████
██████       ███████████
▀█████        ▀█████████
   ▀██         ▀████▀███
     ▀           █▀   ▀█]]

-- One letter per cell of `logo`, naming the part of the mark it belongs to:
-- (l)eft bar, (d)iagonal, (r)ight bar.
M.logo_mask = [[
.....dd...............rr
...dddddd...........rrrr
lldddddddd........rrrrrr
llldddddddd.......rrrrrr
llllldddddddd.....rrrrrr
lllllldddddddd....rrrrrr
llllll.dddddddd...rrrrrr
llllll...dddddddd.rrrrrr
llllll....ddddddddrrrrrr
llllll.....ddddddddrrrrr
llllll.......ddddddddrrr
llllll........ddddddddrr
...lll.........ddddddrrr
.....l...........dd...rr]]

M.wordmark = [[
╭╮╷╭─╴╭─╮╷ ╷╷╭┬╮
│╰┤├╴ │ ││╭╯││││
╵ ╵╰─╴╰─╯╰╯ ╵╵ ╵]]

M.wordmark_mask = [[
rrrrrrrrrlllllll
rrrrrrrrrlllllll
rrrrrrrrrlllllll]]

return M
