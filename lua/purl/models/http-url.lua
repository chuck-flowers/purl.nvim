local parsing = require 'purl.utils.parsing'

---@class HttpUrl
---@field protocol string
---@field host string
---@field port? integer
---@field path? string
---@field query? table<string, string>
---@field hash? string
local HttpUrl = {}
HttpUrl.__index = HttpUrl

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
	local proto_sep
	proto_sep, input = parsing.parse_pattern(input, '%:%/%/')
	if not proto_sep then
		return nil
	end

	---@type string[]?
	local host_components
	host_components, input = parsing.parse_delimited_pattern(input, '%w+', '%.')
	if not host_components then
		return nil
	end
	local host = table.concat(host_components, '.')

	---@type integer?, string?
	local port, port_str
	port_str, input = parsing.parse_pattern(input, '%:%d+')
	if port_str then
		port = tonumber(port_str:sub(2))
		if not port then
			return nil
		end
	end

	---@type string?
	local path
	path, input = parsing.parse_pattern(input, '[^%?%#]+')

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

---@return string[]
function HttpUrl:format_for_buffer()
	---@type string[]
	local to_return = {}

	table.insert(to_return, ('protocol: %s'):format(self.protocol))
	table.insert(to_return, ('host: %s'):format(self.host))
	if self.port then
		table.insert(to_return, ('port: %s'):format(self.port))
	end
	if self.path then
		table.insert(to_return, ('path: %s'):format(self.path))
	end
	if self.query then
		table.insert(to_return, 'query:')
		for key, value in pairs(self.query) do
			table.insert(to_return, ('  %s: %s'):format(key, value))
		end
	end
	if self.hash then
		table.insert(to_return, ('hash: %s'):format(self.hash))
	end

	return to_return
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

	local kv_pairs
	kv_pairs, input = parsing.parse_delimited(input, utils.parse_query_kv_pair, function(i)
		return parsing.parse_pattern(i, '%&')
	end)

	if not kv_pairs then
		return nil, original_input
	end

	for _, kv in ipairs(kv_pairs) do
		to_return[kv.key] = kv.value
	end

	return to_return, input
end

---@param input string
---@return { key: string, value: string }?, string
function utils.parse_query_kv_pair(input)
	local original_input = input

	local key
	key, input = parsing.parse_pattern(input, '[%w%_]+')
	if not key then
		return nil, original_input
	end

	local eq
	eq, input = parsing.parse_pattern(input, '%=')
	if not eq then
		return nil, original_input
	end

	local value
	value, input = parsing.parse_pattern(input, '[%w%+%_]+')
	if not key then
		return nil, original_input
	end

	return { key = key, value = value }, input
end

return HttpUrl
