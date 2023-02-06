local HttpUrl = require 'purl.models.http-url'
local UrlView = require 'purl.views.UrlView'

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

		UrlView:new(url)
	end, {
		range = true
	})
end

return M
