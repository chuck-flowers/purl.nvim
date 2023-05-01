local parsing = require 'purl.utils.parsing'

local ESCAPE_CODE_LOOKUP = {
	['26'] = '&',
	['2F'] = '/',
	['3A'] = ':',
	['3D'] = '=',
	['3F'] = '?'
}

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
	---@type string?
	local protocol
	protocol, input = parsing.parse_pattern_choices(input, 'https', 'http')
	if not protocol then
		return nil
	end

	---@type string?
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

	---@type string?, table<string, string>?
	local query_prefix, query
	query_prefix, input = parsing.parse_pattern(input, '%?')
	if query_prefix then
		query, input = utils.parse_query(input)
		if not query then
			return nil
		end
	end

	---@type string?
	local hash
	hash, input = parsing.parse_pattern(input, '%#[%w%%]+$')

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

	-- Parse key
	local key
	key, input = parsing.parse_pattern(input, '[%w%_%.]+')
	if not key then
		return nil, original_input
	end

	-- Parse equal sign
	local eq
	eq, input = parsing.parse_pattern(input, '%=')
	if not eq then
		return nil, original_input
	end

	-- Parse value
	local value
	value, input = parsing.parse_pattern(input, '[%w%+%_%%%.%-]+')
	if not value then
		return nil, original_input
	end

	-- Cleanup the value
	for escape_code, escape_value in pairs(ESCAPE_CODE_LOOKUP) do
		value = value:gsub('%%' .. escape_code, escape_value)
	end

	return { key = key, value = value }, input
end

return HttpUrl
