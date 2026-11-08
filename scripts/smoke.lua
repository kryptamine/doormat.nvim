-- Run by `make smoke` after startup: plugin/doormat.lua must have opened the
-- doormat in the empty first buffer.
local function fail(msg)
	io.stderr:write("smoke: " .. msg .. "\n")
	vim.cmd("cquit 1")
end

local buf = vim.api.nvim_get_current_buf()
if vim.bo[buf].filetype ~= "doormat" then
	fail("doormat did not open on a bare nvim, filetype is " .. vim.bo[buf].filetype)
end

local text = table.concat(vim.api.nvim_buf_get_lines(buf, 0, -1, false), "\n")
for _, want in ipairs({ "q quit", ("v%d.%d.%d"):format(vim.version().major, vim.version().minor, vim.version().patch) }) do
	if not text:find(want, 1, true) then
		fail("missing " .. vim.inspect(want))
	end
end

-- Every highlight group a mark uses resolves to something
for _, mark in ipairs(vim.api.nvim_buf_get_extmarks(buf, -1, 0, -1, { details = true })) do
	local group = mark[4].hl_group
	if vim.tbl_isempty(vim.api.nvim_get_hl(0, { name = group, link = false })) then
		fail("highlight group " .. group .. " is empty")
	end
end

-- A custom menu replaces the default one, and an item whose cond fails is
-- left out
require("doormat").setup({
	items = {
		{ key = "n", label = "new", action = "<Cmd>enew<CR>" },
		{
			key = "x",
			label = "never",
			action = "<Cmd>enew<CR>",
			cond = function()
				return false
			end,
		},
		"quit",
	},
})
vim.cmd.enew()
require("doormat").open()
buf = vim.api.nvim_get_current_buf()
local custom = table.concat(vim.api.nvim_buf_get_lines(buf, 0, -1, false), "\n")
if not custom:find("n new", 1, true) or custom:find("never", 1, true) then
	fail("custom items not drawn as set")
end
if pcall(require("doormat").setup, { items = { "nope" } }) then
	fail("setup accepted an unknown built-in item")
end

-- The doormat steps aside for a real buffer
vim.cmd.enew()
if vim.api.nvim_buf_is_valid(buf) then
	fail("doormat buffer was not wiped")
end

io.stdout:write("smoke: ok\n")
vim.cmd("qall!")
