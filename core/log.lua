--
-- log.lua
--
-- Copyright (c) 2016 rxi
--
-- This library is free software; you can redistribute it and/or modify it
-- under the terms of the MIT license. See LICENSE for details.
--

local log = { _version = "0.1.0" }

log.usecolor = true
log.outfile = nil
log.level = "trace"
log.logging = nil

local modes = {
  { name = "trace", color = "\27[34m", levelStr = "| [TRACE]   |"},
  { name = "debug", color = "\27[36m", levelStr = "| [DEBUG]   |"},
  { name = "info",  color = "\27[32m", levelStr = "| [INFO]    |"},
  { name = "warn",  color = "\27[33m", levelStr = "| [WARN]    |"},
  { name = "error", color = "\27[31m", levelStr = "| [ERROR]   |"},
  { name = "fatal", color = "\27[35m", levelStr = "| [FATAL]   |"},
}


local levels = {}
for i, v in ipairs(modes) do
  levels[v.name] = i
end

for i, x in ipairs(modes) do
    local nameupper = x.name:upper()
    log[x.name] = function(text, ...)
        if log.logging then
            -- Return early if we're below the log level
            if i < levels[log.level] then
                return
            end

            local msg = string.format(text, ...)
            local info = debug.getinfo(2, "Sl")
            local lineinfo = info.short_src .. " line: " .. info.currentline

            -- Output to console
            print(string.format("%s %s | %s[%s]%s    | %s", os.date("%Y-%m-%d"), os.date("%H:%M:%S"), log.usecolor and x.color or "", nameupper, "\27[0m" or "", msg))
            --print(string.format("[%-6s%s]%s %s: %s", log.usecolor and x.color or "", os.date("%Y-%m-%d"), nameupper, log.usecolor and "\27[0m" or "", lineinfo, msg ))

            -- Output to log file
            if log.outfile then
            local fp = io.open(log.outfile, "a")
			local str = string.format("%s %s %s %s\n", os.date("%Y-%m-%d"), os.date("%H:%M:%S"), x.levelStr, msg)
            --local str = string.format("%s: [%-6s%s] %s\n", os.date("%Y-%m-%d"), nameupper, lineinfo, msg)
            fp:write(str)
            fp:close()
            end
        end
    end
end

return log