--[[
@module listener.lua

@author wizard

@description
listens for discord events and socket received messages that callback to handler module functions.
]]

local base = _G

local handler = require("../core/handler")

local dgram = require('dgram')
local json = require("../core/json")

local bot = nil

local socket = dgram.createSocket("udp4")

local listener = {}
setmetatable(listener, {__index = socket})

function listener.initSocket()
    bot.logger:info("initailizing listening socket...")
    listener:bind(bot.settings.botPort, bot.settings.botHost)
    listener:on("message", function(message)
        bot.logger:debug("listener:on() | message received from dcs")
        local messageTable = json.decode(message)
        bot.logger:debug("listener:on() | callback: handler.%s", messageTable.command)
        local callback = coroutine.wrap(handler[messageTable.command])
        callback(messageTable)
    end)
    bot.logger:debug("listener.initSocket() | initialization successful")
end

function listener.onReady()
    bot = base.ScripingBot
    listener.initSocket()
    handler.onReady()
    bot.logger:debug("listening on port: %d | host: %s...", bot.settings.botPort, bot.settings.botHost)
    bot.logger:info("DCSSriptingBot is now ready as %s!", bot.client.user.tag)
    --log[bot.settings.logLevel]("DCSSriptingBot is now ready as %s", bot.client.user.tag)
    --log[bot.settings.logLevel]("%s listening on port: %d | host: %s", bot.client.user.tag, botPort, botHost)
end

function listener.onMessageSend(message)
    local found = false
    local content = message.content
    if content:sub(1,1) == bot.settings.commandPrefix then
        bot.logger:debug("listener.onMessageSend() | has prefix, looking for command")
        for command, callback in pairs(handler) do
            if content:find(command) and type(callback) == "function" then
                bot.logger:debug("listener.onMessageSend() | callback command: %s found", command)
                callback(message)
                found = true
                break
            end
        end
        if not found then bot.logger:debug("listener.onMessageSend() | no callback command was found") end
    end
end

return listener

