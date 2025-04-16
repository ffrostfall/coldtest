local stdio = require("@lune/stdio")
local result = require("@utils/result")
local ansi_styling = require("@utils/ansi_styling")

local err_style = ansi_styling.combine_styles(ansi_styling.color.red, ansi_styling.modifier.bold)
local warn_style = ansi_styling.combine_styles(ansi_styling.color.yellow, ansi_styling.modifier.bold)
local trace_style = ansi_styling.color.blue_bright
local info_style = ansi_styling.color.white

local logging = {}

function logging.fatal(err: string)
	print(`{err_style}[fatal]{stdio.style("reset")} {err}`)
end

function logging.err(err: string, traceback: string, internal: boolean?)
	traceback = string.gsub(traceback, "\n", "\n\t")

	print(`{err_style("[err]")} {err}`)

	logging.log_traceback(traceback)

	if internal then
		print(info_style("this is probably an internal bug"))
		print(info_style("please report this on github"))
	end
end

function logging.warn(text: string)
	print(`{warn_style("[warn]")} {text}`)
end

function logging.info(text: string)
	print(`{info_style("[info]")} {text}`)
end

function logging.log_traceback(traceback: string)
	print(`\t{trace_style(traceback)}`)
end

function logging.warn_from_result(failed_result: result.Identity<any>)
	assert(failed_result.success == false, "can't error on a succeeded result")

	logging.warn(failed_result.err)

	logging.log_traceback(failed_result.trace)
end

function logging.err_from_result(failed_result: result.Identity<any>)
	assert(failed_result.success == false, "can't error on a succeeded result")

	logging.err(failed_result.err, failed_result.trace)
end

return logging
