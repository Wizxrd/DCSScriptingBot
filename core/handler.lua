--[[
@module listener.lua

@author wizard

@description
handles discord events and socket received messages as call back functions
]]

local base = _G

local util = require("../core/util")
local json = require("../core/json")
local dgram = require('dgram')

local port = 6666
local host = "127.0.0.1"

local socket = dgram.createSocket("udp4")
socket:bind(0, host)

local bot = nil

local function sendToDCS(json_table)
    --log[bot.settings.logLevel]("sendToDCS() | sending json to - port: %d | host: %s", port, host)
    socket:send(json_table, port, host)
end

local handler = {}

--[[ local functions ]]--

function handler.onReady()
    bot = base.ScripingBot
    bot.logger:info("handler is now accepting commands")
end

--[[ discord callbacks ]]--

-- * user commands *

function handler.help(message)
    --log[bot.settings.logLevel]("handler.help() | command received")
    local commandsMessage = {}
    for _, commandTable in pairs(bot.commands) do
        commandsMessage[#commandsMessage+1] = "\n."..commandTable.name.." ["..commandTable.desc.."]"
    end
    local helpString = "Commands:\n```"..table.concat(commandsMessage).."\n```"
    --log[bot.settings.logLevel]("handler.help() | replied with help commands")
    message.channel:send(helpString)
end

-- * admin commands *

function handler.restart(message)
    --log[bot.settings.logLevel]("handler.restart() | command received")
    if not message.guild then return end
    local channel = message.channel
    local member = message.guild:getMember(message.author)
    if member:hasRole(bot.settings.adminRole) and channel.id == bot.settings.adminChannel then
        print"is admin and is in admin channel"
        --log[bot.settings.logLevel]("handler.restart() | restarting DCSScriptingBot as %s", bot.client.user.tag)
        os.execute("bot.bat")
    end
end

function handler.purge(message)
    --log[bot.settings.logLevel]("handler.purge() | command received")
    if not message.guild then return end
    local channel = message.channel
    local member = message.guild:getMember(message.author)
    if member:hasRole(bot.settings.adminRole) and channel.id == bot.settings.adminChannel then
        local content = message.content
        local deleteCount = tonumber(content:sub(8))
        if deleteCount > 100 then
            for i = 1, 1 do
                local messages = channel:getMessages(100)
                channel:bulkDelete(messages)
            end
            local messages = channel:getMessages(100)
            channel:bulkDelete(messages)
        else
            local messages = channel:getMessages(deleteCount)
            channel:bulkDelete(messages)
        end
        --log[bot.settings.logLevel]("handler.purge() | %d messages were deleted", deleteCount)
    end
end

function handler.botlog(message)
    --log[bot.settings.logLevel]("handler.botlog() | command received")
    if not message.guild then return end
    local channel = message.channel
    local member = message.guild:getMember(message.author)
    if member:hasRole(bot.settings.adminRole) and channel.id == bot.settings.adminChannel then
        --log[bot.settings.logLevel]("handler.botlog() | replied with bot.log")
        channel:send({file = "logs/bot.log"})
    end
end

function handler.doscript(message)
    --log[bot.settings.logLevel]("handler.doscript() | command received")
    if not message.guild then return end
    local channel = message.channel
    local member = message.guild:getMember(message.author)
    if member:hasRole(bot.settings.adminRole) and channel.id == bot.settings.adminChannel then
        local content = message.content
        local messageTable = {}
        messageTable.command = "doscript"
        messageTable.script = content:sub(11)
        local json_table = json.encode(messageTable)
        --log[bot.settings.logLevel]("handler.doscript() | sending script to dcs")
        sendToDCS(json_table)
    end
end

function handler.launch(message)
    --log[bot.settings.logLevel]("handler.launch() | command received")
    if not message.guild then return end
    local channel = message.channel
    local member = message.guild:getMember(message.author)
    if member:hasRole(bot.settings.adminRole) and channel.id == bot.settings.adminChannel then
        --log[bot.settings.logLevel]("handler.launch() | launching dcs from %s", bot.settings.pathToDCS.."\\"..bot.settings.dcsName)
        os.execute("bats/dcs.bat")
    end
end

-- [[ dcs callbacks ]]--

function handler.sendMessage(messageTable)
    local message = messageTable.message.playerName.." has connected to the server"
    local channel = bot.client:getChannel(bot.settings.adminChannel)
    channel:send(message)
end

return handler