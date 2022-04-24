--[[
@module bot.lua

@author wizard

@description
creates a new instance of a bot which will automatically configure itself based on the settings.lua file setup by the user.
]]

local major = 0
local minor = 0
local patch = 4

local base = _G

local listener = require("../core/listener")
local settings = require("../config/settings.lua")
local events = require("../core/events.lua")
local commands = require("../core/commands.lua")

local fs = require("fs")
local util = require("../core/util.lua")

local discord = require("discordia")
local logLevel = discord.enums.logLevel
local client = discord.Client{
    logFile = "logs/bot.log",
    cacheAllMembers = true,
    logLevel = logLevel[settings.logLevel]
}

local logger = discord.Logger()
logger._level = logLevel[settings.logLevel]
logger._file = "logs/bot.log"
io.open(logger._file, "w"):close()

local scripts = {
    ["ScriptingBotGameGui"] = {
        origin = settings.botPath.."\\Scripts\\Hooks\\ScriptingBotGameGui.lua",
        dest = settings.pathToSavedGames.."\\"..settings.savedGamesName.."\\Scripts\\Hooks\\ScriptingBotGameGui.lua"
    },
    ["json"] = {
        origin = settings.botPath.."\\core\\json.lua",
        dest = settings.pathToSavedGames.."\\"..settings.savedGamesName.."\\Scripts\\json.lua"
    },
}

local function writeFile(name, origin, destination)
    logger:debug("copying %s.lua into:", name)
    logger:debug("%s", destination)
    local originFile, originError = fs.openSync(origin, "r")
    if not originFile then
        local errorStr = string.format("writeFile() | origin: %s", originError)
        return false, errorStr
    end
    local originContent = fs.readSync(originFile)
    fs.closeSync(originFile)

    local destinationFile, destinationError = fs.openSync(destination, "w")
    if not destinationFile then
        local errorStr = string.format("writeFile() | destination: %s", destinationError)
        return false, errorStr
    end
    fs.writeSync(destinationFile, 0, originContent)
    fs.closeSync(destinationFile)
    logger:debug("%s.lua successfully copied into:", name)
    logger:debug("%s", destination)
    return true
end

local function initCopy(name, origin, destination)
    if fs.existsSync(origin) then
        local newDestination = false
        if not fs.existsSync(destination) then
            local destinationFile = fs.openSync(destination, "w")
            fs.closeSync(destinationFile)
            newDestination = true
        end
        local originEpoch = fs.statSync(origin).mtime.sec
        local destinationEpoch = fs.statSync(destination).mtime.sec

        if not newDestination then
            if originEpoch > destinationEpoch then
                local success, errorString =  writeFile(name, origin, destination)
                if not success then
                    return false, errorString
                end
            end
        else
            local success, errorString =  writeFile(name, origin, destination)
            if not success then
                return false, errorString
            end
        end
        return true
    end
    return false,  string.format("initCopy() | %s.lua could not be found in bot directory!", name)
end

local bot = {
    ["version"] = major.."."..minor.."."..patch
}

function bot:new()
    logger:info("constructing DCSScriptingBot...")
    local self = setmetatable({}, {__index = bot})
    self.settings = settings
    self.events = events
    self.commands = commands
    self.client = client
    self.logger = logger
    self.adminChannel = client:getChannel(settings.adminChannel)
    logger:debug("bot:new() | bot objected has been constructed")
    return self
end

function bot:initailize()
    logger:info("initializing DCSScriptingBot...")
    self:initDiscordEvents()
    self:initDCSBat()
    self:initScripts()
    logger:debug("bot:initailize() | all initializations complete")
    return self
end

function bot:initDiscordEvents()
    logger:info("initializing discord event callbacks...")
    -- initailize the listener for discord events
    for name, callback in pairs(listener) do
        local event = self.events[name]
        if event and type(callback) == "function" then
            client:on(event, function(...)
                callback(...)
            end)
            logger:debug("bot:initDiscordEvents() | initialized event: %s", name)
        end
    end
    -- run the client
    logger:debug("bot:initDiscordEvents() | initialization successful")
    return self
end

function bot:initDCSBat()
    logger:info("initializing dcs.bat launch script...")
    -- [[ create dcs bat ]]--
    local dcsBat, err = io.open(self.settings.botPath.."\\bats\\dcs.bat", "w")
    if not dcsBat then logger:error("bot:initDCSBat() | in: %s", err) return self end
    local commandLines = '@echo off\nSTART '..self.settings.pathToDCS..'\\'..self.settings.dcsName..'\\bin\\DCS.exe -server --norender -w '..self.settings.savedGamesName
    dcsBat:write(commandLines)
    dcsBat:close()
    logger:debug("bot:initDCSBat() | dcs.bat has been initialized")
    return self
end

function bot:initScripts()
    logger:info("copying scripts to saved games...")
    for name, script in pairs(scripts) do
        local success, errorStr = initCopy(name, script.origin, script.dest)
        if not success then
            logger:error("bot:initScripts() | %s", errorStr)
        end
    end
end

function bot:run()
    logger:info("starting up DCSScriptingBot...")
    self.client:run("Bot "..settings.botToken)
    base.ScripingBot = self -- define the new bot in the global scope
    return self
end

--[[ bot initialization ]]--
ScripingBot = bot:new()
ScripingBot:initailize()
ScripingBot:run()