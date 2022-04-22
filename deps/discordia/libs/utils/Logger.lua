--[[
this module has been modified by me Wizard, to incorperate rxi's log.lua into SinisterRectus's Logger.lua.
credits goes to the authors that have created this fantastic modules.
i've modified SinisterRectus's due to being lazy and not wanting to directly declare which log level for the :log method.
]]

local fs = require('fs')

local format = string.format
local stdout = _G.process.stdout.handle
local openSync, writeSync = fs.openSync, fs.writeSync

-- local BLACK   = 30
local RED     = 31
local GREEN   = 32
local YELLOW  = 33
-- local BLUE    = 34
-- local MAGENTA = 35
local CYAN    = 36
-- local WHITE   = 37

local config = {
	{ name = "error", color = 31, levelStr = "[ERROR]   "},
	{ name = "warn",  color = 33, levelStr = "[WARN]    "},
	{ name = "info",  color = 32, levelStr = "[INFO]    "},
	{ name = "debug", color = 36, levelStr = "[DEBUG]   "},
	--{ name = "trace", color = 34, levelStr = "[TRACE]   "},
	--{ name = "fatal", color = 35, levelStr = "[FATAL]   "},
  }

do
	local bold = 1
	for _, v in ipairs(config) do
		v.colorStr = format('\27[%i;%im%s\27[0m', bold, v.color, v.levelStr)
	end
end

local Logger = require('class')('Logger')

function Logger:__init(level, dateTime, file)
	self._level = level
	self._dateTime = dateTime
	self._file = file and openSync(file, 'a')
end

local modes = {
	{ name = "error", color = 31, levelStr = "[ERROR]   "},
	{ name = "warn",  color = 33, levelStr = "[WARN]    "},
	{ name = "info",  color = 32, levelStr = "[INFO]    "},
	{ name = "debug", color = 36, levelStr = "[DEBUG]   "},
	--{ name = "trace", color = 34, levelStr = "[TRACE]   "},
	--{ name = "fatal", color = 35, levelStr = "[FATAL]   "},
  }

for i, x in ipairs(config) do
	Logger[x.name] = function(self, text, ...)
		--print(self._file)
		-- Return early if we're below the log level
		if self._level < i then
			return
		end
		local msg = string.format(text, ...)
		-- Output to console
		print(string.format("%s %s | %s | %s", os.date("%Y-%m-%d"), os.date("%H:%M:%S"), x.colorStr, msg))
		--print(string.format("[%-6s%s]%s %s: %s", log.usecolor and x.color or "", os.date("%Y-%m-%d"), nameupper, log.usecolor and "\27[0m" or "", lineinfo, msg ))

		-- Output to log file
		local fp = io.open(self._file, "a")
		local str = string.format("%s %s | %s | %s\n", os.date("%Y-%m-%d"), os.date("%H:%M:%S"), x.levelStr, msg)
		--local str = string.format("%s: [%-6s%s] %s\n", os.date("%Y-%m-%d"), nameupper, lineinfo, msg)
		fp:write(str)
		fp:close()
	end
end

--[=[
@m log
@p level number
@p msg string
@p ... *
@r string
@d If the provided level is less than or equal to the log level set on
initialization, this logs a message to stdout as defined by Luvit's `process`
module and to a file if one was provided on initialization. The `msg, ...` pair
is formatted according to `string.format` and returned if the message is logged.
]=]

function Logger:log(level, msg, ...)
	if self._level and self._level < level then return end

	local tag = config[level]
	if not tag then return end

	msg = format(msg, ...)

	local d,t = os.date("%Y-%m-%d"), os.date("%H:%M:%S")
	if self._file then
		writeSync(self._file, -1, format('%s %s | %s | %s\n', d, t, tag.levelStr, msg))
	end
	--stdout:write(format('%s | %s  | %s\n', d, tag[2], msg))
	stdout:write(format('%s %s | %s | %s\n', d, t, tag.colorStr, msg))

	return msg

end

return Logger
