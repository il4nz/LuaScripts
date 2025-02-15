script_name('MonserKillerAutoScreenshot')
script_moonloader(026)
script_properties('forced-reloading-only')
-- сохраняет скриншот с тем, кто убил тебя, сортируя все скриншоты по сессиям
-- работает только на Monser-е

require "moonloader"
require("lib.moonloader")

local screenshot = require 'lib.screenshot'
local sampev = require 'lib.samp.events'

function main()
	if not isSampLoaded() or not isSampfuncsLoaded() then return end
	while not isSampAvailable() do wait(100) end
	local result, localPlayerId = sampGetPlayerIdByCharHandle(PLAYER_PED)
	if result then
		sampAddChatMessage('Testst', -1)
		outSessionPath = string.format('Lsrcr\\Kills')
	end

		
	wait(-1)
end

local screenshotIndex = 0
function sampev.onPlayerDeathNotification(killer, killed, reason)
		local result, localPlayerId = sampGetPlayerIdByCharHandle(PLAYER_PED)	
		if result then
			if killer ~= localPlayerId and killed == localPlayerId then
				local killerPlayerName = sampGetPlayerNickname(killer)
				lua_thread.create(function()
					wait(150)
					screenshotIndex = screenshotIndex + 1
					screenshot.requestEx(outSessionPath, string.format('%s [%d]', killerPlayerName, screenshotIndex))
				end)
			end
		end
end
