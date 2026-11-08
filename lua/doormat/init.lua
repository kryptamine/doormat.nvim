local logo = require("doormat.logo")

local M = {}

local ns = vim.api.nvim_create_namespace("doormat")

-- The official mark's blue, light green and green. ctermfg is the terminal's
-- own palette; without termguicolors that is what shows.
local highlights = {
	DoormatLogoBlue = { fg = "#9fb2d6", ctermfg = 4 },
	DoormatLogoLightGreen = { fg = "#8ac568", ctermfg = 10 },
	DoormatLogoGreen = { fg = "#476834", ctermfg = 2 },
	DoormatKey = { link = "DoormatLogoLightGreen" },
	DoormatHint = { link = "Comment" },
	DoormatFooter = { link = "Comment" },
	DoormatCursor = { blend = 100 },
}

-- Mask letter to the highlight of that part of the mark: (l)eft bar,
-- (d)iagonal, (r)ight bar.
local part_hl = {
	l = "DoormatLogoBlue",
	d = "DoormatLogoLightGreen",
	r = "DoormatLogoGreen",
}

local function terminal_color(n)
	local color = vim.g["terminal_color_" .. n]
	if type(color) == "string" and color:match("^#%x%x%x%x%x%x$") then
		return tonumber(color:sub(2), 16)
	end
end

-- Half way from `a` to `b`, channel by channel
local function mix(a, b)
	local out = 0
	for shift = 0, 16, 8 do
		local ca, cb = bit.band(bit.rshift(a, shift), 0xff), bit.band(bit.rshift(b, shift), 0xff)
		out = out + bit.lshift(math.floor((ca + cb) / 2), shift)
	end
	return out
end

-- The mark's gui colors from the colorscheme's :terminal palette, or nil. Many
-- palettes make green and bright green one color, so the dark green is the
-- light one mixed into the background instead.
local function terminal_logo()
	local blue, green = terminal_color(4), terminal_color(10) or terminal_color(2)
	if not (blue and green) then
		return nil
	end
	local bg = vim.api.nvim_get_hl(0, { name = "Normal" }).bg or 0
	return { DoormatLogoBlue = blue, DoormatLogoLightGreen = green, DoormatLogoGreen = mix(green, bg) }
end

-- `default`, so a colorscheme that defines these groups wins
local function set_highlights()
	local logo_fg = terminal_logo() or {}
	for name, spec in pairs(highlights) do
		vim.api.nvim_set_hl(0, name, vim.tbl_extend("force", spec, { fg = logo_fg[name], default = true }))
	end
end

-- The most recent file under cwd, or nil
local function last_file()
	local cwd = vim.fn.getcwd() .. "/"
	for _, file in ipairs(vim.v.oldfiles) do
		if vim.startswith(file, cwd) and vim.fn.filereadable(file) == 1 then
			return file
		end
	end
end

-- The first installed picker of fff.nvim, fzf-lua and telescope, as a table of
-- { files, grep } functions, or nil
local function picker()
	local ok, fff = pcall(require, "fff")
	if ok then
		return { files = fff.find_files, grep = fff.live_grep }
	end
	local fzf
	ok, fzf = pcall(require, "fzf-lua")
	if ok then
		return { files = fzf.files, grep = fzf.live_grep }
	end
	local telescope
	ok, telescope = pcall(require, "telescope.builtin")
	if ok then
		return { files = telescope.find_files, grep = telescope.live_grep }
	end
end

-- The built-in items by name. Each returns { key, label, action }, or nil
-- when it cannot work: "restore" needs a file under cwd, "find" and "grep" a
-- picker.
local builtin = {}

function builtin.restore()
	local file = last_file()
	if not file then
		return nil
	end
	return {
		key = "s",
		label = "restore",
		action = function()
			vim.cmd.edit(vim.fn.fnameescape(file))
			-- Back to the last cursor position, like :help last-position-jump
			local mark = vim.api.nvim_buf_get_mark(0, '"')
			if mark[1] > 0 and mark[1] <= vim.api.nvim_buf_line_count(0) then
				pcall(vim.api.nvim_win_set_cursor, 0, mark)
			end
		end,
	}
end

function builtin.find()
	local pick = picker()
	return pick and {
		key = "f",
		label = "find",
		action = function()
			pick.files()
		end,
	}
end

function builtin.grep()
	local pick = picker()
	return pick and {
		key = "g",
		label = "grep",
		action = function()
			pick.grep()
		end,
	}
end

function builtin.quit()
	return { key = "q", label = "quit", action = "<Cmd>qa<CR>" }
end

local default_items = { "restore", "find", "grep", "quit" }

local config = { items = default_items }

-- error() at level 0, so the message is not prefixed with this file's path
local function check(ok, msg)
	if not ok then
		error(msg, 0)
	end
end

local function check_item(item, i)
	local where = "doormat: items[" .. i .. "]"
	if type(item) == "string" then
		check(builtin[item], where .. ": no built-in item " .. vim.inspect(item))
		return
	end
	check(type(item) == "table", where .. ": expected a built-in name or a table")
	check(type(item.key) == "string" and item.key ~= "", where .. ".key: expected a string")
	check(type(item.label) == "string", where .. ".label: expected a string")
	check(
		vim.tbl_contains({ "string", "function" }, type(item.action)),
		where .. ".action: expected a string or function"
	)
	check(item.cond == nil or type(item.cond) == "function", where .. ".cond: expected a function")
end

--- Sets the menu. `items` is a list of built-in names ("restore", "find",
--- "grep", "quit") and { key, label, action, cond? } tables; see README.
---@param opts? { items?: (string|{ key: string, label: string, action: string|function, cond?: fun(): boolean })[] }
function M.setup(opts)
	opts = opts or {}
	if opts.items ~= nil then
		check(type(opts.items) == "table", "doormat: items: expected a list")
		for i, item in ipairs(opts.items) do
			check_item(item, i)
		end
	end
	config.items = opts.items or default_items
end

-- The menu as { key, label, action }, leaving out every item that cannot work
local function items()
	local list = {}
	for _, item in ipairs(config.items) do
		if type(item) == "string" then
			item = builtin[item]()
		elseif item.cond and not item.cond() then
			item = nil
		end
		list[#list + 1] = item
	end
	return list
end

-- Appends `block` to `lines`, centered on what is actually drawn: blank
-- padding around the art would otherwise count towards its width and push
-- the picture off to one side. With a `mask`, also collects into `marks` the
-- highlight of every drawn cell, as { row, col, end_col, hl_group }.
local function append_centered(lines, block, width, mask, marks)
	local rows, left, right = {}, math.huge, 0
	for _, row in ipairs(vim.split(block, "\n")) do
		local cells = vim.fn.split(row, [[\zs]])
		for i, cell in ipairs(cells) do
			if cell ~= " " then
				left = math.min(left, i)
				right = math.max(right, i)
			end
		end
		rows[#rows + 1] = cells
	end
	local pad = string.rep(" ", math.max(0, math.floor((width - (right - left + 1)) / 2)))
	local mask_rows = mask and vim.split(mask, "\n")
	for r, cells in ipairs(rows) do
		lines[#lines + 1] = pad .. table.concat(cells, "", math.min(left, #cells + 1), math.min(right, #cells))
		local col = #pad
		for i = left, mask_rows and #cells or 0 do
			local hl = part_hl[mask_rows[r]:sub(i, i)]
			if hl then
				marks[#marks + 1] = { #lines - 1, col, col + #cells[i], hl }
			end
			col = col + #cells[i]
		end
	end
end

-- Appends the menu to `lines` as one dimmed, centered row of "key label"
-- hints with the keys highlighted.
local function append_menu(lines, list, width, marks)
	local parts = {}
	for _, item in ipairs(list) do
		parts[#parts + 1] = item.key .. " " .. item.label
	end
	local row = table.concat(parts, "   ")
	local pad = string.rep(" ", math.max(0, math.floor((width - vim.fn.strdisplaywidth(row)) / 2)))
	lines[#lines + 1] = pad .. row
	local r, col = #lines - 1, #pad
	for _, part in ipairs(parts) do
		marks[#marks + 1] = { r, col, col + 1, "DoormatKey" }
		marks[#marks + 1] = { r, col + 1, col + #part, "DoormatHint" }
		col = col + #part + 3
	end
end

-- The Neovim version, and the startup time when lazy.nvim has measured it
local function footer()
	local v = vim.version()
	local parts = { ("v%d.%d.%d"):format(v.major, v.minor, v.patch) }
	local ok, lazy = pcall(require, "lazy")
	local ms = ok and lazy.stats().startuptime or 0
	if ms > 0 then
		parts[#parts + 1] = ("%.0f ms"):format(ms)
	end
	return table.concat(parts, "  ·  ")
end

local function render(buf, win, list)
	local width = vim.api.nvim_win_get_width(win)
	local height = vim.api.nvim_win_get_height(win)

	local content, marks = {}, {}
	append_centered(content, logo.logo, width, logo.logo_mask, marks)
	content[#content + 1] = ""
	append_centered(content, logo.wordmark, width, logo.wordmark_mask, marks)
	content[#content + 1] = ""
	append_menu(content, list, width, marks)
	content[#content + 1] = ""
	local footer_row = #content
	append_centered(content, footer(), width)

	local lines = {}
	for _ = 1, math.max(0, math.floor((height - #content) / 2)) do
		lines[#lines + 1] = ""
	end
	local first_row = #lines
	vim.list_extend(lines, content)

	vim.bo[buf].modifiable = true
	vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
	vim.bo[buf].modifiable = false

	vim.api.nvim_buf_clear_namespace(buf, ns, 0, -1)
	for _, mark in ipairs(marks) do
		local row, col, end_col, hl = unpack(mark)
		vim.api.nvim_buf_set_extmark(buf, ns, first_row + row, col, { end_col = end_col, hl_group = hl })
	end
	vim.api.nvim_buf_set_extmark(buf, ns, first_row + footer_row, 0, { end_row = #lines, hl_group = "DoormatFooter" })
end

-- Turns the current buffer into the doormat
function M.open()
	local buf = vim.api.nvim_get_current_buf()
	local win = vim.api.nvim_get_current_win()
	vim.bo[buf].buftype = "nofile"
	vim.bo[buf].bufhidden = "wipe"
	vim.bo[buf].buflisted = false
	vim.bo[buf].swapfile = false
	vim.bo[buf].filetype = "doormat"
	-- Scoped to this buffer in this window, so the next buffer shown here gets
	-- the regular options back.
	for name, value in pairs({
		number = false,
		relativenumber = false,
		signcolumn = "no",
		cursorline = false,
		list = false,
		statuscolumn = "",
	}) do
		vim.wo[win][0][name] = value
	end

	-- No statusline while the doormat is up; the buffer wipes itself as soon
	-- as anything else is shown in its window.
	local laststatus = vim.o.laststatus
	vim.o.laststatus = 0
	vim.api.nvim_create_autocmd("BufWipeout", {
		buffer = buf,
		once = true,
		callback = function()
			vim.o.laststatus = laststatus
		end,
	})

	-- With termguicolors, a cursor highlight with blend = 100 is not drawn.
	-- Normal mode only, so the command line keeps its cursor; any other window
	-- gets it back.
	local guicursor = vim.o.guicursor
	local function hide_cursor()
		vim.o.guicursor = (guicursor == "" and "" or guicursor .. ",") .. "n:block-DoormatCursor"
	end
	local function show_cursor()
		vim.o.guicursor = guicursor
	end
	hide_cursor()
	vim.api.nvim_create_autocmd({ "BufEnter", "WinEnter" }, { buffer = buf, callback = hide_cursor })
	vim.api.nvim_create_autocmd({ "BufLeave", "WinLeave", "BufWipeout" }, { buffer = buf, callback = show_cursor })

	set_highlights()
	local list = items()
	render(buf, win, list)

	local function rerender()
		if not vim.api.nvim_buf_is_valid(buf) then
			return true
		end
		local shown = vim.fn.bufwinid(buf)
		if shown ~= -1 then
			render(buf, shown, list)
		end
	end
	local group = vim.api.nvim_create_augroup("doormat_render", { clear = true })
	vim.api.nvim_create_autocmd({ "VimResized", "WinResized" }, { group = group, callback = rerender })
	-- lazy.nvim measures startup on UIEnter, after the doormat is first drawn
	vim.api.nvim_create_autocmd("User", { group = group, pattern = "LazyVimStarted", once = true, callback = rerender })

	for _, item in ipairs(list) do
		vim.keymap.set("n", item.key, item.action, { buffer = buf, nowait = true, desc = item.label })
	end
end

-- A colorscheme clears every group, so the defaults go back on after it
vim.api.nvim_create_autocmd("ColorScheme", {
	group = vim.api.nvim_create_augroup("doormat_highlights", { clear = true }),
	callback = set_highlights,
})

return M
