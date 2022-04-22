--[[
@module bot.lua

@author wizard

@description
creates a new instance of a bot which will automatically configure itself based on the settings.lua file setup by the user.
]]

local major = 0
local minor = 0
local patch = 2

local base = _G

local listener = require("../core/listener")

local settings = require("../config/settings.lua")
local events = require("../core/events.lua")
local commands = require("../core/commands.lua")

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
    self:initGameGui()
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
    if not dcsBat then
        logger:error("bot:initDCSBat() | in: %s", err)
        return self
    end
    local commandLines = '@echo off\nSTART '..self.settings.pathToDCS..'\\'..self.settings.dcsName..'\\bin\\DCS.exe -server --norender -w '..self.settings.savedGamesName
    dcsBat:write(commandLines)
    dcsBat:close()
    logger:debug("bot:initDCSBat() | dcs.bat has been created")
    return self
end

function bot:initGameGui()
    --[[ create game gui ]]--
    logger:info("copying ScriptingBotGameGui.lua into Saved Games folder...")
    local botGuiPath = self.settings.botPath.."\\Scripts\\Hooks\\ScriptingBotGameGui.lua"
    local savedGameGuiPath = self.settings.pathToSavedGames.."\\"..self.settings.savedGamesName.."\\Scripts\\Hooks\\ScriptingBotGameGui.lua"
    local success, error = os.execute(string.format('copy "%s" "%s" > nul', botGuiPath, savedGameGuiPath)) --os.rename(botGuiPath, savedGameGuiPath)
    if not success then
        logger:error("bot:initGameGui() | in: %s", error)
    else
        logger:debug("bot:initGameGui() | a copy of ScriptingBotGameGui.lua was created in:")
        logger:debug("%s", savedGameGuiPath)
    end
    return self
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