local process = require("@lune/process")

local function base_path()
	if _G.__BUILD_TYPE == "release" then
		if _G.__BUILD_OS == "windows" then
			return `{process.env["USERPROFILE"]}/`
		end

		return "~/"
	elseif _G.__BUILD_TYPE == "debug" then
		return "./"
	end

	return error("unreachable")
end

return base_path()
