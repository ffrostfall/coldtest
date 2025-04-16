local BENCH_SUFFIX = "bench.luau"

local fs_utils = require("@utils/fs_utils")
local bench_env = require("@src/environments/bench_env")
local run_file = require("@src/environments/run_file")
local logging = require("@utils/logging")

local function bench()
	local env = bench_env.new()

	local file_names_call = fs_utils.read_dir("./")
	if not file_names_call.success then
		print("Failed to read directory: " .. file_names_call.err)
		return
	end

	local bench_names: { string } = {}

	for _, name in file_names_call.value do
		if string.sub(name, -#BENCH_SUFFIX) == BENCH_SUFFIX then
			table.insert(bench_names, name)
		end
	end

	for _, name in bench_names do
		local no_codegen_run = run_file(name, env:create_globals(false) :: { [string]: any }, false)
		local codegen_run = run_file(name, env:create_globals(true) :: { [string]: any }, true)

		if not no_codegen_run.success then
			logging.warn(`[{name}] ` .. no_codegen_run.err)
			continue
		end

		if not codegen_run.success then
			logging.warn(`[{name}] ` .. codegen_run.err)
			continue
		end

		local no_codegen_func = no_codegen_run.value
		local codegen_func = codegen_run.value

		no_codegen_func()
		codegen_func()
	end

	env:results()
end

return bench
