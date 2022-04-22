local settings = {
    --[[ bot configuration ]]--
    -- note the format for pathToDCS and dcsName, it is important they are correct so a dcs.bat can be created to start dcs on discord command
    ["commandPrefix"] = "~",
    ["botToken"] = "", -- DONT FORGET TO REMOVE BEFORE PUSH!
    ["botPort"] = 10081,
    ["botHost"] = "0.0.0.0",
    ["dcsPort"] = 6666,
    ["dcsHost"] = "127.0.0.1",
    ["botPath"] = "C:\\_gitMaster\\DCSScriptingBot",
    -- the folder path to your main dcs world installation
    -- eg; "C:\\Program Files\\Eagle Dynamics\\"
    -- note: the following format must be followed for folder names with spaces in them
    ["pathToDCS"] = 'C:\\"Program Files"\\"Eagle Dynamics"', -- note the format of the string
    -- the name of your main dcs world installation folder
    -- eg; "DCS World OpenBeta Server"
    -- note: the following format must be followed for folder names with spaces in them
    ["dcsName"] = '"DCS World OpenBeta Server"',  -- note the format of the string
    -- the name of your saved games dcs world folder
    -- eg; "DCS.openbeta"
    ["savedGamesName"] = "DCS.openbeta",
    -- the name of your main dcs world installation folder
    -- note: you must use \\ to traverse the folders
    -- eg; "C:\\Program Files\\Eagle Dynamics\\<DCS World OpenBeta>"
    ["pathToSavedGames"] = "C:\\Users\\nicks\\Saved Games",

    -- automatically launch dcs if it is not already open when the bot starts up
    ["autoLaunchDCS"] = true,
    -- boolean for the output of logging information
    ["logging"] = true,

    -- levels in order: error, warning, info, debug. in order, the one you select will not output the remaining options
    -- eg; if logLevel = "error" then only error messages will be logged. no warning, info, or debug messages will be output.
    -- eg; if loglEvel = "info" then error, warning, and info messages will be logged. no debug messages will be logged.
    -- eg; if loglEvel = "debug" then error, warning, info and debug messages will all be logged.
    ["logLevel"] = "debug", --recommended

    -- how large the bot.log will get before creating a new .log
    -- this size is in Bytes, keep in mind discords bot attachment limit is 8MB
    ["logSize"] = "8000000",
    -- how many log files will be generated before overwriting from the beginning
    -- think of how much you want to store
    -- eg; logSize* loglimit = XXMB worth of log files
    -- logSize * logLimit = 80MB
    ["logLimit"] = 10,

    -- -- [roles] --
    ["adminRole"] = "daimyo",
    ["userRole"] = "user",


    -- -- [channels] --
    ["adminChannel"] = "964670713745252362",

}

return settings