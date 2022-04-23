local base  	= _G

local require	= base.require
local loadfile	= base.loadfile

local json = loadfile(lfs.currentdir() .. "Scripts\\json.lua")()

package.path  = package.path..";.\\LuaSocket\\?.lua;"
package.cpath = package.cpath..";.\\LuaSocket\\?.dll;"
local socket = require("socket")
local bot = {}
bot.UDPSendSocket = socket.udp()
bot.UDPSendSocket:settimeout(0)

local function basicSerialize(s)
	if s == nil then
		return "\"\""
	else
		if ((type(s) == 'number') or (type(s) == 'boolean') or (type(s) == 'function') or (type(s) == 'table') or (type(s) == 'userdata') ) then
			return tostring(s)
		elseif type(s) == 'string' then
			return string.format('%q', s)
		end
  	end
end

function bot.onSimulationFrame()
	if not bot.UDPRecvSocket then
		local host = "127.0.0.1"
		local port = 6666
		local ip = socket.dns.toip(host)
		bot.UDPRecvSocket = socket.udp()
		bot.UDPRecvSocket:setsockname(ip, port)
		bot.UDPRecvSocket:settimeout(0.0001)
	end
	local msg, err
	repeat
		msg, err = bot.UDPRecvSocket:receive()
		if not err then
			local json_table = json:decode(msg)
			if bot[json_table.command] ~= nil then
				bot[json_table.command](json_table)
			end
		end
	until err
end

function bot.sendBotMessage(msg)
	local messageTable = {}
	messageTable.message = msg
	messageTable.command = "sendMessage"
	bot.sendBotTable(messageTable)
end

function bot.sendBotTable(tbl)
	log.write("DCSScriptingBot", log.DEBUG, "sendBotTable()")
	local tbl_json_txt = json:encode(tbl)
	socket.try(bot.UDPSendSocket:sendto(tbl_json_txt, "127.0.0.1", 10081))
end

function bot.onPlayerConnect(id)
	local message = {}
	message.playerName = net.get_player_info(id, "name")
	message.playerUcid = net.get_player_info(id, "ucid")
	log.write('DCSScriptingBot', log.DEBUG, message.playerName.." has connected to the server, callback onPlayerConnect()")
	bot.sendBotMessage(message)
end

function bot.doscript(json_table)
    log.write('DCSScriptingBot', log.DEBUG, 'do_script()')
    net.dostring_in('mission', 'a_do_script(' .. basicSerialize(json_table.script) .. ')')
end

if DCS.isServer() then
	DCS.setUserCallbacks(bot)
    log.write('DCSScriptingBot', log.DEBUG, 'Loaded DCSScriptingBot Callbacks')
end

return bot