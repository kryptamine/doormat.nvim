if vim.g.loaded_doormat then
	return
end
vim.g.loaded_doormat = true

local group = vim.api.nvim_create_augroup("doormat", { clear = true })

vim.api.nvim_create_autocmd("StdinReadPre", {
	group = group,
	callback = function()
		vim.g.doormat_stdin = true
	end,
})

-- Only for a bare `nvim`: no file arguments, nothing piped in, and nothing
-- already loaded into the first buffer.
vim.api.nvim_create_autocmd("VimEnter", {
	group = group,
	callback = function()
		local buf = vim.api.nvim_get_current_buf()
		if
			vim.fn.argc(-1) == 0
			and not vim.g.doormat_stdin
			and vim.api.nvim_buf_get_name(buf) == ""
			and vim.bo[buf].filetype == ""
			and not vim.bo[buf].modified
			and vim.api.nvim_buf_line_count(buf) == 1
			and vim.api.nvim_buf_get_lines(buf, 0, 1, false)[1] == ""
		then
			require("doormat").open()
		end
	end,
})

vim.api.nvim_create_user_command("Doormat", function()
	vim.cmd.enew()
	require("doormat").open()
end, { desc = "Open the doormat in a new buffer" })
