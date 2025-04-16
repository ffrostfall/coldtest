local build = require("@tools/build")
local process = require("@lune/process")
local logging = require("@utils/logging")

local build_type = process.args[1]
if not build_type then
	logging.err("No build type specified. Use 'release' or 'debug'.", "")
	process.exit(1)
	return
end

if typeof(build_type) ~= "string" then
	logging.err("Invalid build type. Use 'release' or 'debug'.", "")
	process.exit(1)
	return
end

if build_type ~= "release" and build_type ~= "debug" then
	logging.err("Invalid build type. Use 'release' or 'debug'.", "")
	process.exit(1)
	return
end

build(build_type :: any)
