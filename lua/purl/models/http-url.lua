local parsing = require 'purl.utils.parsing'

---@class HttpUrl
---@field protocol string
---@field host string
---@field port? integer
---@field path? string
---@field query? table<string, string>
---@field hash? string
local HttpUrl = {}

local utils = {}

---comment
---@param input string
---@return HttpUrl?
function HttpUrl.parse(input)

	local protocol
	protocol, input = parsing.parse_pattern_choices(input, 'https', 'http')
	if not protocol then
		return nil
	end

	-- Parse the '://'
	if not parsing.parse_pattern(input, '%:%/%/') then
		return nil
	end

	---@type string[]?
	local host_components
	host_components, input = parsing.parse_delimited(input, '%w', '%.')
	if not host_components then
		return nil
	end
	local host = table.concat(host_components, '.')

	---@type integer?, string?
	local port, port_str
	port_str, input = parsing.parse_pattern(input, '%:%d+')
	if port_str then
		port = tonumber(port_str:sub(2))
	end

	---@type string?
	local path, path_root
	path_root, input = parsing.parse_pattern(input, '%/')
	if path_root then
		local path_components
		path_components, input = parsing.parse_delimited(input, '[^%/%?]+', '%/')
		if path_components then
			path = '/' .. table.concat(path_components, '/')
		else
			return nil
		end
	end

	local query
	query, input = utils.parse_query(input)

	---@type string?
	local hash
	hash, input = parsing.parse_pattern(input, '%#[^%#]+$')

	local http_url = HttpUrl._new()
	http_url.protocol = protocol
	http_url.host = host
	http_url.port = port
	http_url.path = path
	http_url.query = query
	http_url.hash = hash

	return http_url
end

---@private
---@return HttpUrl
function HttpUrl._new()
	---@type HttpUrl
	local http_url = {}
	setmetatable(http_url, HttpUrl)

	return http_url
end


---@param input string
---@return table<string, string>?, string
function utils.parse_query(input)
	local original_input = input

	---@type table<string, string>
	local to_return = {}

	-- Ensure question mark prefix is present
	local q
	q, input = parsing.parse_pattern(input, '%?')
	if not q then
		return nil, original_input
	end

	return to_return, input
end

---@param input string
---@return { key: string, value: string }?, string
function utils.parse_query_kv_pair(input)
	local original_input = input

	local key
	key, input = parsing.parse_pattern(input, '[%w]+')
	if not key then
		return nil, original_input
	end

	local value
	value, input = parsing.parse_pattern(input, '[%w]+')
	if not key then
		return nil, original_input
	end

	return { key = key, value = value }, input
end

return HttpUrl
