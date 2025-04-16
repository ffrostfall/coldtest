local luau = require("@lune/luau")
local user_files = require("../user_files")
local fs_utils = require("@utils/fs_utils")
local result = require("@utils/result")
local append_result_err = require("@utils/append_result_err")
local serde = require("@lune/serde")
local logging = require("@utils/logging")

local function run_file(path: string, globals: { [string]: any }?, codegen: boolean?): result.Identity<() -> ()>
	local read_file_call = fs_utils.read_file(path)
	if not read_file_call.success then
		append_result_err(read_file_call, `failed to read file: {path}; `)
		return read_file_call
	end

	local file_content = read_file_call.value
	local source_hash = serde.hash("sha256", file_content)

	local bytecode_hash_call = user_files.find_bytecode_hash(source_hash)
	if not bytecode_hash_call.success then
		append_result_err(bytecode_hash_call, `failed to find bytecode hash: {source_hash}; `)
		return bytecode_hash_call
	end

	local bytecode
	if bytecode_hash_call.value.found then
		bytecode = bytecode_hash_call.value.bytecode
	else
		bytecode = luau.compile(file_content, {
			optimizationLevel = 2,
			debugLevel = 2,
		})

		local write_call = user_files.write_bytecode_hash(source_hash, bytecode)
		if not write_call.success then
			append_result_err(write_call, `[{path}] `)
			logging.warn_from_result(write_call)
			logging.info("this is not critical, but it will slow down the next run")
		end
	end

	local load_options: luau.LoadOptions = {
		debugName = path,
		codegenEnabled = codegen,

		environment = globals,
	}

	local run_mod = luau.load(bytecode, load_options)

	return result(true :: true, run_mod) :: result.Identity<() -> ()>
end

return run_file
