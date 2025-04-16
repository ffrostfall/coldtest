local fs_utils = require("@utils/fs_utils")
local result = require("@utils/result")
local append_result_err = require("@utils/append_result_err")
local base_path = require("./base_path")
local bench_typedef = require("./typedef/bench_typedef")

local user_files = {}

function user_files.setup(): result.Identity
	local results: { [string]: result.Identity } = {
		[`{base_path}.coldtest/`] = fs_utils.write_dir(`{base_path}.coldtest/`),
		[`{base_path}.coldtest/bytecode_cache`] = fs_utils.write_dir(`{base_path}.coldtest/bytecode_cache`),
		[`{base_path}.coldtest/typedefs`] = fs_utils.write_dir(`{base_path}.coldtest/typedefs`),
	}

	for file_name, write_result in results do
		if not write_result then
			append_result_err(write_result, `failed to create {file_name}; `)
			return write_result
		end
	end

	local typedefs_exists_call = fs_utils.is_dir(`{base_path}.coldtest/typedefs/{_G.__BUILD_VERSION}/`)
	if not typedefs_exists_call.success then
		append_result_err(typedefs_exists_call, "failed to check if typedefs exist; ")
		return typedefs_exists_call
	end

	if not typedefs_exists_call.value then
		local write_result = fs_utils.write_dir(`{base_path}.coldtest/typedefs/{_G.__BUILD_VERSION}/`)
		if not write_result.success then
			append_result_err(write_result, "failed to create typedefs dir; ")
			return write_result
		end
	end

	fs_utils.write_file(`{base_path}.coldtest/typedefs/{_G.__BUILD_VERSION}/bench.luau`, bench_typedef)

	return result(true :: true)
end

function user_files.check_setup(): result.Identity<boolean>
	local coldtest_files_exist_call = fs_utils.is_dir(`{base_path}.coldtest/`)
	if not coldtest_files_exist_call.success then
		return coldtest_files_exist_call
	end

	return result(true :: true, coldtest_files_exist_call.value)
end

type BytecodeHashResult = {
	found: true,
	bytecode: string,
} | {
	found: false,
}

function user_files.find_bytecode_hash(hash: string): result.Identity<BytecodeHashResult>
	local bytecode_hash_exists_call = fs_utils.is_file(`{base_path}.coldtest/bytecode_cache/{hash}`)
	if not bytecode_hash_exists_call.success then
		return bytecode_hash_exists_call
	end

	if bytecode_hash_exists_call.value then
		local compiled_bytecode_from_hash = fs_utils.read_file(`{base_path}.coldtest/bytecode_cache/{hash}`)
		if not compiled_bytecode_from_hash.success then
			return compiled_bytecode_from_hash
		end

		return result(
			true :: true,
			{
				found = true,
				bytecode = compiled_bytecode_from_hash.value,
			} :: BytecodeHashResult
		)
	end

	return result(
		true :: true,
		{
			found = false,
		} :: BytecodeHashResult
	)
end

function user_files.write_bytecode_hash(hash: string, bytecode: string): result.Identity
	local write_result = fs_utils.write_file(`{base_path}.coldtest/bytecode_cache/{hash}`, bytecode)
	if not write_result.success then
		append_result_err(write_result, "failed to write bytecode hash; ")
		return write_result
	end

	return result(true :: true)
end

return user_files
