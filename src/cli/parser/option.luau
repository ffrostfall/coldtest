export type Identity = {
	kind: "char",
	char: string,
} | {
	kind: "flag",
	flag_name: string,
} | {
	kind: "key_value",
	key: string,
	value: string,
}

local function option(raw: string): Identity
	local char_match = string.match(raw, "^%-(%w)$")
	local flag_match = string.match(raw, "^%-%-(%w+)$")
	local key_match, value_match = string.match(raw, "^%-%-(%w+)=(.+)$")

	if char_match then
		return {
			kind = "char",
			char = char_match,
		}
	elseif flag_match then
		return {
			kind = "flag",
			flag_name = flag_match,
		}
	elseif key_match and value_match then
		return {
			kind = "key_value",
			key = key_match,
			value = value_match,
		}
	else
		error("Invalid option format: " .. raw)
	end
end

return option
