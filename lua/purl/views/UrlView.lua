---@class UrlView
---@field buffer integer
---@field window integer
---@field url? HttpUrl
local UrlView = {
	HORIZONTAL_MARGIN = 2,
	VERTICAL_MARGIN = 2
}
UrlView.__index = UrlView

---comment
---@param url? HttpUrl
---@return UrlView
function UrlView:new(url)
	---@type UrlView
	local instance = {}
	setmetatable(instance, self)

	instance:_create_buffer()
	instance:_create_window()

	-- If an initial URL was provided, then use it
	if url then
		instance:set_url(url)
	end

	return instance
end

---@param url HttpUrl The URL to now display
function UrlView:set_url(url)
	self.url = url

	---@type string[]
	local lines = {}

	table.insert(lines, ('protocol: %s'):format(url.protocol))
	table.insert(lines, ('host: %s'):format(url.host))
	if url.port then
		table.insert(lines, ('port: %s'):format(url.port))
	end
	if url.path then
		table.insert(lines, ('path: %s'):format(url.path))
	end
	if url.query then
		table.insert(lines, 'query:')
		for key, value in pairs(url.query) do
			table.insert(lines, ('  %s: %s'):format(key, value))
		end
	end
	if url.hash then
		table.insert(lines, ('hash: %s'):format(url.hash))
	end

	vim.api.nvim_buf_set_lines(self.buffer, 0, -1, true, lines)
end

---@private
function UrlView:_create_buffer()
	self.buffer = vim.api.nvim_create_buf(false, true)
	vim.keymap.set('n', 'q', ':bdelete<CR>', {
		buffer = self.buffer
	})
end

---@private
function UrlView:_create_window()
	-- Calculate the available space
	local root_width = vim.fn.winwidth(0)
	local root_height = vim.fn.winheight(0)

	-- Calculate desired size
	local float_width = root_width - self.HORIZONTAL_MARGIN
	local float_height = root_height - self.VERTICAL_MARGIN

	-- Caclulate the position
	local float_x = (root_width - float_width) / 2
	local float_y = (root_height - float_height) / 2

	self.window = vim.api.nvim_open_win(self.buffer, true, {
			relative = 'win',
			row = float_y,
			col = float_x,
			width = float_width,
			height = float_height
		})
end

return UrlView
