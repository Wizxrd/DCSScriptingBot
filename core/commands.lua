local commands = {
    {["name"] = "help",        ["desc"] = "list all of the available commands",             ["enabled"] = true},
    {["name"] = "restart",     ["desc"] = "restart the bot",                                ["enabled"] = true},
    {["name"] = "purge",       ["desc"] = "purge x amount of messages",                     ["enabled"] = true},
    {["name"] = "botlog",      ["desc"] = "send the bot.log via direct message",            ["enabled"] = true},
    {["name"] = "doscript",    ["desc"] = "calls a function in the mission envrionment",    ["enabled"] = true},
    {["name"] = "launch",      ["desc"] = "launch a dcs server",                            ["enabled"] = true}
}

return commands