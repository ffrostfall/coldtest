local exec_cmd = require("@utils/exec_cmd")
local fs_utils = require("@utils/fs_utils")
local append_result_err = require("@utils/append_result_err")
local serde = require("@lune/serde")
local process = require("@lune/process")
local logging = require("@utils/logging")
local cast_pcall = require("@utils/cast_pcall")
local result = require("@utils/result")

local target_architectures = { "x86_64", "aarch64" }
local target_operating_systems = { "windows", "macos", "linux" }

export type BuildType = | "release" | "debug"

export type ProjectConfig = {
	version: string,
}

export type BuildTarget = {
	os: "windows" | "linux" | "macos",
	arch: "x86_64" | "aarch64",
}

local function concat_target(build_target: BuildTarget)
	return `{build_target.os}-{build_target.arch}`
end

local function build_executable(file_name: string, target: BuildTarget)
	local appended = ""
	local target_str = concat_target(target)

	if target.os == "windows" then
		appended = ".exe"
	end

	local bundled_file = `build/tmp/{file_name}_{target_str}.luau`
	local executable_target_file = `build/{file_name}_{target_str}{appended}`

	exec_cmd(`lune build {bundled_file} --target={concat_target(target)} --output={executable_target_file}`)
end

local function get_project_conf(): ProjectConfig
	local read_file_call = fs_utils.read_file("project.toml")
	if not read_file_call.success then
		append_result_err(read_file_call, "failed to read project.toml; ")
		logging.err_from_result(read_file_call)
		process.exit(1)

		error("unreachable")
	end

	local decode_call = result(cast_pcall(pcall(serde.decode, "toml", read_file_call.value)))
	if not decode_call.success then
		append_result_err(decode_call, "failed to deser project.toml; ")
		logging.err_from_result(decode_call)
		process.exit(1)

		error("unreachable")
	end

	return {
		version = decode_call.value.version,
	}
end

local function build(build_type: BuildType)
	local project_conf = get_project_conf()

	fs_utils.remove_dir("build")
	fs_utils.write_dir("build")
	fs_utils.write_dir("build/tmp")

	process.env["BUILD_TYPE"] = build_type
	process.env["BUILD_VERSION"] = project_conf.version

	for _, target_arch in target_architectures do
		for _, target_os in target_operating_systems do
			-- lune doesn't support building to windows aarch64
			if target_os == "windows" and target_arch == "aarch64" then
				continue
			end

			local target = {
				os = target_os,
				arch = target_arch,
			} :: BuildTarget

			process.env["BUILD_ARCH"] = target_arch
			process.env["BUILD_OS"] = target_os

			local output_file_name = "coldtest"

			if build_type == "debug" then
				output_file_name ..= "-debug"
			end

			exec_cmd(
				`darklua process src/init.luau build/tmp/{output_file_name}_{concat_target(target)}.luau --config=tools/.darklua.json`
			)
			build_executable(output_file_name, target)
		end
	end

	if build_type == "release" then
		fs_utils.remove_dir("build/tmp")
	end

	if table.find(process.args, "--bundle") then
		exec_cmd(`tar acvf release.zip build`)
	end
end

return build
