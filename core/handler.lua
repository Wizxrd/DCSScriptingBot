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

local socket = dgram.createSocket("udp4")

local bot = nil

--[[ local functions ]]--

local function sendToDCS(json_table)
    bot.logger:info("sendToDCS() | sending json to - port: %d | host: %s", bot.settings.botPort, bot.settings.dcsHost)
    socket:send(json_table, bot.settings.dcsPort, bot.settings.dcsHost)
end

local handler = {}

function handler.onReady()
    bot = base.ScripingBot
    bot.logger:info("handler is now accepting commands")
    socket:bind(0, bot.settings.dcsHost)

    --for i = 1, 250 do
        --local message = "a"
        --local channel = bot.client:getChannel(bot.settings.adminChannel)
        --channel:send(message)
    --end
end

--[[ discord callbacks ]]--

-- * user commands *

function handler.help(message)
    bot.logger:info("handler.help() | command received")
    local commandsMessage = {}
    for _, commandTable in pairs(bot.commands) do
        commandsMessage[#commandsMessage+1] = "\n."..commandTable.name.." ["..commandTable.desc.."]"
    end
    local helpString = "Commands:\n```"..table.concat(commandsMessage).."\n```"
    bot.logger:info("handler.help() | replied with help commands")
    message.channel:send(helpString)
end

-- * admin commands *

function handler.restart(message)
    bot.logger:info("handler.restart() | command received")
    if not message.guild then return end
    local channel = message.channel
    local member = message.guild:getMember(message.author)
    if member:hasRole(bot.settings.adminRole) and channel.id == bot.settings.adminChannel then
        print"is admin and is in admin channel"
        bot.logger:info("handler.restart() | restarting DCSScriptingBot as %s", bot.client.user.tag)
        os.execute("bot.bat")
    end
end

function handler.purge(message)
    bot.logger:info("handler.purge() | command received")
    if not message.guild then return end
    local channel = message.channel
    local member = message.guild:getMember(message.author)
    if member:hasRole(bot.settings.adminRole) and channel.id == bot.settings.adminChannel then
        local content = message.content
        local deleted = 0
        local toBeDeleted = tonumber(content:sub(8))
        if toBeDeleted > 100 then
            local iterations = math.floor(toBeDeleted/100)
            local remainder = toBeDeleted % 100
            for i = 1, iterations do
                local messages = channel:getMessages(100)
                if messages ~= nil then
                    deleted = deleted + #messages
                    channel:bulkDelete(messages)
                end
            end
            local messages = channel:getMessages(remainder)
            if messages ~= nil then
                deleted = deleted + #messages
                channel:bulkDelete(messages)
            end
        else
            local messages = channel:getMessages(toBeDeleted)
            if messages ~= nil then
                deleted = deleted + #messages
                channel:bulkDelete(messages)
            end
        end
        if deleted == 1 then
            bot.logger:info("handler.purge() | 1 message was deleted")
        else
            bot.logger:info("handler.purge() | %d messages were deleted", deleted)
        end
    end
end

function handler.botlog(message)
    bot.logger:info("handler.botlog() | command received")
    if not message.guild then return end
    local channel = message.channel
    local member = message.guild:getMember(message.author)
    if member:hasRole(bot.settings.adminRole) and channel.id == bot.settings.adminChannel then
        bot.logger:info("handler.botlog() | replied with bot.log")
        channel:send({file = "logs/bot.log"})
    end
end

function handler.doscript(message)
    bot.logger:info("handler.doscript() | command received")
    if not message.guild then return end
    local channel = message.channel
    local member = message.guild:getMember(message.author)
    if member:hasRole(bot.settings.adminRole) and channel.id == bot.settings.adminChannel then
        local content = message.content
        local messageTable = {}
        messageTable.command = "doscript"
        messageTable.script = content:sub(11)
        local json_table = json.encode(messageTable)
        bot.logger:info("handler.doscript() | sending script to dcs")
        sendToDCS(json_table)
    end
end

function handler.launch(message)
    bot.logger:info("handler.launch() | command received")
    if not message.guild then return end
    local channel = message.channel
    local member = message.guild:getMember(message.author)
    if member:hasRole(bot.settings.adminRole) and channel.id == bot.settings.adminChannel then
        bot.logger:info("handler.launch() | launching dcs from %s", bot.settings.pathToDCS.."\\"..bot.settings.dcsName)
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