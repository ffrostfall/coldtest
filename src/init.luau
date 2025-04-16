local user_files = require("./user_files")
local logging = require("@utils/logging")
local bench = require("./commands/bench")

local setup_call = user_files.setup()

if not setup_call.success then
	logging.err_from_result(setup_call)
	return
end

bench()
