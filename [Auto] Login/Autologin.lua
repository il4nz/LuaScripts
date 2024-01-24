-----------------------------------------------------------------------------------------------
-------------------------------------------- #Medz --------------------------------------------
local tag = "[{ff0000}Medz{ffffff}] | {ffffff}"

password = "changeme"

-----------------------------------------------------------------------------------------------
script_author("#Medz")
-------------------------------------------- Requires ------------------------------
require 'moonloader'
require('lib.moonloader')
local sampev = require "lib.samp.events"
-------------------------------------------- Main --------------------------------------------
function main()
	while not isSampAvailable() do wait(0) end
	while not sampIsLocalPlayerSpawned() do wait(0) end
	intro()
end

function sampev.onShowDialog(id, style, title, btn1, btn2, text)
	if id == 330 then -- Login
		lua_thread.create(function ()
			wait(1000)
			sampSendDialogResponse(330, 1, -1, password)
			-------------- add these lines if you want to disable pms after auto-login -----------------------\
			-- wait(1000)
			-- sampSendChat("/pmoff")
			--------------------------------------------------------------------------------------------------\

		end)
        return false
    end
end
function intro()
		wait(1100)
		sampAddChatMessage("{00ff00} --- Auto Login Loaded ---", 0x00ff00)
end
