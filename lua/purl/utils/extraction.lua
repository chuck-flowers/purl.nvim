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


	-- Aggregate the selection as a single string variable
	local selected_text = ''
	---@type string[]
	local lines = vim.api.nvim_buf_get_lines(0, start_line - 1, end_line, true)
	for i, line in ipairs(lines) do
		if i == 1 and i == #lines then
			line = line:sub(start_col, end_col)
		elseif i == 1 then
			line = line:sub(start_col)
		elseif i == #lines then
			line = line:sub(1, end_col)
		end

		selected_text = selected_text .. line .. '\n'
	end

	return selected_text
end

return M
