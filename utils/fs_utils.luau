local result = require("@utils/result")
local fs = require("@lune/fs")
local cast_pcall = require("@utils/cast_pcall")

local function is_dir(path: string): result.Identity<boolean>
	return result(cast_pcall(pcall(fs.isDir, path))) :: result.Identity<boolean>
end

local function is_file(path: string): result.Identity<boolean>
	return result(cast_pcall(pcall(fs.isFile, path))) :: result.Identity<boolean>
end

local function read_dir(path: string): result.Identity<{ string }>
	return result(cast_pcall(pcall(fs.readDir, path))) :: result.Identity<{ string }>
end

local function read_file(path: string): result.Identity<string>
	return result(cast_pcall(pcall(fs.readFile, path))) :: result.Identity<string>
end

local function write_dir(path: string): result.Identity
	return result(cast_pcall(pcall(fs.writeDir, path))) :: result.Identity
end

local function write_file(path: string, content: buffer | string): result.Identity
	return result(cast_pcall(pcall(fs.writeFile, path, content))) :: result.Identity
end

local function remove_dir(path: string): result.Identity
	return result(cast_pcall(pcall(fs.removeDir, path))) :: result.Identity
end

return {
	is_dir = is_dir,
	is_file = is_file,
	read_dir = read_dir,
	read_file = read_file,
	write_dir = write_dir,
	write_file = write_file,
	remove_dir = remove_dir,
}
