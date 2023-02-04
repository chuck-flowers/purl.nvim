local HttpUrl = require 'purl.models.http-url'

-- 'https://www.reddit.com/r/ender3v2/comments/ub6mip/help_with_cr_touch_with_sprite_extruder_pro_kit/?utm_source=share&utm_medium=web2x&context=3'
local M = {}

---Enables the purl plugin
function M.setup()
	vim.api.nvim_create_user_command('Purl', function(context)
		local line1 = context.line1
		local line2 = context.line2

		---@type string[]
		local lines = vim.api.nvim_buf_get_lines(0, line1 - 1, line2, true)
		local first_line = lines[1]
		local url_start = first_line:find('http')
		local url = HttpUrl.parse(first_line:sub(url_start))
		if not url then
			print('Failed to parse URL!')
			return
		end

		-- Populate a buffer with the formatted output
		local bufnr = vim.api.nvim_create_buf(false, true)
		vim.api.nvim_buf_set_lines(bufnr, 0, -1, true, url:format_for_buffer())

		-- Show the buffer in a floating window
		local root_width = vim.fn.winwidth(0)
		local root_height = vim.fn.winheight(0)
		local float_width = root_width - 2
		local float_height = root_height - 2
		local float_x = (root_width - float_width) / 2
		local float_y = (root_height - float_height) / 2
		vim.api.nvim_open_win(bufnr, true, {
			relative = 'win',
			row = float_y,
			col = float_x,
			width = float_width,
			height = float_height
		})

		vim.keymap.set('n', 'q', ':bdelete<CR>', {
			buffer = bufnr
		})
	end, {
		range = true
	})
end

return M
