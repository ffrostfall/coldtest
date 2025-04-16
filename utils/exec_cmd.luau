local process = require("@lune/process")

local function exec_cmd(command: string, from_cwd: string?)
	process.spawn("cmd", { "/c", `{command}` }, { stdio = "forward", cwd = from_cwd })
end

return exec_cmd
