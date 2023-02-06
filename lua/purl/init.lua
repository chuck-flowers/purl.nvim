local HttpUrl = require 'purl.models.HttpUrl'
local UrlView = require 'purl.views.UrlView'
local extraction = require 'purl.utils.extraction'

-- 'https://www.reddit.com/r/ender3v2/comments/ub6mip/help_with_cr_touch_with_sprite_extruder_pro_kit/?utm_source=share&utm_medium=web2x&context=3'
local M = {}

---Enables the purl plugin
function M.setup()
	vim.api.nvim_create_user_command('Purl', function()
		-- Parse the selected URL
		local url_text = extraction.extract_url_text()
		local url = HttpUrl.parse(url_text)

		-- Report the error
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
