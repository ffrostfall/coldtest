local result = require("@utils/result")

local function append_result_err(failed_result: result.Identity<any>, prefix: string)
	assert(failed_result.success == false, "can't append err to a succeeded result")

	failed_result.err = `{prefix}{failed_result.err}`
end

return append_result_err
