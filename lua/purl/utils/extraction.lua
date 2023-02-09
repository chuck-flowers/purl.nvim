local M = {}

---@return string
function M.extract_url_text()
	return M.get_visual_selection()
end

---@return string
function M.get_visual_selection()
	---@type unknown, integer, integer, unknown
	local _, start_line, start_col, _ = unpack(vim.fn.getpos("'<"))
	---@type unknown, integer, integer, unknown
	local _, end_line, end_col, _ = unpack(vim.fn.getpos("'>"))


	---@type string[]
	local lines = vim.api.nvim_buf_get_lines(0, start_line - 1, end_line, true)
	if #lines > 1 then
		lines[1] = lines[1]:sub(start_col, end_col)
		lines[#lines] = lines[#lines]:sub(1, end_col)
	else
		lines[1] = lines[1]:sub(start_col, end_col)
	end

	return table.concat(lines, '\n')
end

return M
