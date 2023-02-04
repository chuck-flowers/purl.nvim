local M = {}

---@param input string
---@param pattern string
---@return string?, string
function M.parse_pattern(input, pattern)
	local original_input = input

	---@type string?
	local match = input:match('^' .. pattern)
	if match then
		return match, input:sub(match:len() + 1)
	else
		return nil, original_input
	end
end

---@param input string
---@param ... fun(input: string): string?, string
---@return string?, string
function M.parse_choices(input, ...)
	local original_input = input
	for _, parser in ipairs({ ... }) do
		local result
		result, input = parser(input)
		if result then
			return result, input
		end
	end

	return nil, original_input
end

---@param input any
---@param ... string
function M.parse_pattern_choices(input, ...)
	local original_input = input
	for _, pattern in ipairs({ ... }) do
		local result
		result, input = M.parse_pattern(input, pattern)
		if result then
			return result, input
		end
	end

	return nil, original_input
end

---@param input string
---@param element_pattern string
---@param delimiter_pattern string
---@return string[]?, string
function M.parse_delimited_pattern(input, element_pattern, delimiter_pattern)
	local original_input = input

	local to_return, element, delimiter = {}, nil, nil

	element, input = M.parse_pattern(input, element_pattern)
	if not element then
		return to_return, original_input
	end

	table.insert(to_return, element)

	delimiter, input = M.parse_pattern(input, delimiter_pattern)
	while delimiter do

		-- Parse the implied next element
		element, input = M.parse_pattern(input, element_pattern)
		if not element then
			return nil, original_input
		end

		-- Add the parsed element
		table.insert(to_return, element)

		-- Check for the next delimiter
		delimiter, input = M.parse_pattern(input, delimiter_pattern)
	end

	return to_return, input
end

---@generic T, U
---@param input string
---@param element_pattern fun(input: string): T?, string
---@param delimiter_pattern fun(input: string): U?, string
---@return T[]?
---@return string
function M.parse_delimited(input, element_pattern, delimiter_pattern)
	local original_input = input

	local to_return, element, delimiter = {}, nil, nil

	element, input = element_pattern(input)
	if not element then
		return to_return, original_input
	end

	table.insert(to_return, element)

	delimiter, input = delimiter_pattern(input)
	while delimiter do

		-- Parse the implied next element
		element, input = element_pattern(input)
		if not element then
			return nil, original_input
		end

		-- Add the parsed element
		table.insert(to_return, element)

		-- Check for the next delimiter
		delimiter, input = delimiter_pattern(input)
	end

	return to_return, input
end

return M
