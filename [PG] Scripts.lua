
-----------------------------------------------------------------------------------------------
-------------------------------------------- #Medz --------------------------------------------
script_author("Medz")
script_version("1.0")

debug = true
debugdialog = false
-----------------------------------------------------------------------------------------------
require "moonloader"
local sampev = require "lib.samp.events"
local key = require "vkeys"
local inicfg = require("inicfg")
local directIni = "PG\\PG2.ini"
local cfg = inicfg.load(inicfg.load({}, directIni))
--------------------------------------------- C O N F I G ---------------------------------------------
--
--------------------------------------------- V A R I A B L E S ---------------------------------------------

-- Pagati Variables --
pgweapons = 0
pgitems = 0
pgdrugs = 0
pgtakenweapons = 0
pgtakenitems = 0

-- Colors --
local errorcolorhex = "0xff0000"
local successcolorhex = "0x00ff00"
local errorcolor = "ff0000"
local successcolor = "00ff00"
local pgcolor = "8B4513"
local pgcolorhex = "0x8B4513"


-------------------------------------------- M A I N   P L A C E --------------------------------------------

function main()
    while not isSampAvailable() do
        wait(0)
    end
    initialize()
    ---------------- CMDs ----------------
    sampRegisterChatCommand("pgtext", pgtext)
    wait(-1)
end

function getLocalPlayerId()
    local _, id = sampGetPlayerIdByCharHandle(playerPed)
    return id
end

function initialize()
    wait(2000)
    sampAddChatMessage(string.format("PG Scripts Loaded - /pgtext", debug), pgcolorhex)

end

-------------------------------------------- S A M P E V E N T S --------------------------------------------

function sampev.onShowDialog(id, style, title, btn1, btn2, text)

    name = sampGetPlayerNickname(getLocalPlayerId())
    ------------------------- D E B U G ----------------------
    if debugdialog == true then
    sampAddChatMessage(id, -1)
    sampAddChatMessage(name, -1)
    end
    ----------------------------------------------------------
    if id == 31071 then -- PG skill menu
        if text:find("Pagati Hitman") then
            sampSendDialogResponse(31071, 1, 0, nil) -- and this one too
            return false
        end
    end
---Pagati Class
    if id == 98 then -- Pagati Weapons
        if pgweapons == 0 then
            sampSendDialogResponse(98, 1, 0, nil) -- armour
            sampSendDialogResponse(98, 1, 1, nil) -- deagle
            sampSendDialogResponse(98, 1, 2, nil) -- m4
            sampSendDialogResponse(98, 1, 4, nil) -- uzi
            sampSendDialogResponse(98, 1, 6, nil) -- sniper
            sampSendDialogResponse(98, 1, 15, nil) -- sawns
            sampSendDialogResponse(98, 1, 1, nil) -- deagle
            lua_thread.create(
                function()
                    wait(100)
                    sampAddChatMessage(string.format("{%s}Pagati: Weapons Loaded", pgcolor), pgcolorhex)
                end
            )
            pgweapons = 1
            return false
        end
        lua_thread.create(
            function()
                wait(100)
                pgtakenweapons = 1
            end
        )
        if pgtakenweapons == 1 then
            sampAddChatMessage(string.format("{%s}Error: Pagati Weapons Already Loaded", errorcolor), errorcolorhex)
        end
        return false
    end

    if id == 99  then -- Pagati Items
        if pgitems == 0 then
            sampSendDialogResponse(99, 1, 0, nil) -- cork
            sampSendDialogResponse(99, 1, 1, nil) -- wallet
            sampSendDialogResponse(99, 1, 2, nil) -- razor
            sampSendDialogResponse(99, 1, 3, nil) -- screwdriver
            sampSendDialogResponse(99, 1, 6, nil) -- shockguns
            sampSendDialogResponse(99, 1, 8, nil) -- cuff picks
            lua_thread.create(
                function()
                    wait(100)
                    sampAddChatMessage(string.format("{%s}Pagati: Items Loaded", pgcolor), pgcolorhex)
                end
            )
            pgitems = 1
        end
        lua_thread.create(
            function()
                wait(100)
                pgtakenitems = 1
            end
        )
        if pgtakenitems == 1 then
            sampAddChatMessage(string.format("{%s}Error: Pagati Items Already Taken", errorcolor), errorcolorhex)
        end
        return false
    end

    if id == 95  then -- PG Drugs list
        if pgdrugs == 0 then
            sampSendDialogResponse(95, 1, 0, "100") -- and this one too
            lua_thread.create(
                function()
                    wait(100)
                    sampAddChatMessage(string.format("{%s}Pagati: Drugs Loaded", pgcolor), pgcolorhex)
                end
            )
            pgdrugs = 1
            return false
        end

        if pgdrugs == 1 then
            sampAddChatMessage(string.format("{%s}Error: Pagati Drugs Already Taken", errorcolor), errorcolorhex)
        end
        return false
    end

return true
end

function sampev.onSetPlayerPos(position)
	local positionx = string.format("%.02f",position.x)
	local positiony = string.format("%.02f",position.y)
	local positionz = string.format("%.02f",position.z)
	if positionx == "54.92" and positiony == "-324.73" and positionz == "91.59" then -- Pagati
		pgweapons = 0
		pgitems = 0
		pgdrugs = 0
		pgtakenweapons = 0
		pgtakenitems = 0
		lua_thread.create(
			function()
				wait(100)
				sampAddChatMessage("--------------------------------------------------------------------------------", 0x8B4513)
				sampAddChatMessage("Spawned as Pagati, Auto-Items Script Loaded!", 0x8B4513)
				sampAddChatMessage("--------------------------------------------------------------------------------", 0x8B4513)
			end
		)
	end
	if positionx == "32.92" and positiony == "-295.33" and positionz == "2.18" then -- PG ELEVATOR
		lua_thread.create(
			function()
				wait(100)
				pgweapons = 0
				pgtakenweapons = 0
                pgitems = 0
                pgtakenitems = 0
                pgdrugs = 0
			end
		)

	end
	--sampAddChatMessage(string.format("Player: %.02f, %.02f, %.02f", positionx, positiony, positionz), 0xff0000)
end

function pgtext(params)
    if params ~= nil then
       lua_thread.create(
           function()
               wait(500)
               sampSendChat("/news -------- [ La Famiglia Assassini Pagati ] --------", params)
               wait(500)
               sampSendChat("/news Chris John (( Meow )) is now carrying out hit contracts!", params)
               wait(500)
               sampSendChat("/news Command: /hit [ID] [Amount] [Reason]", params)

               
           end
       )
    end
end

--------------------------------------------------------------------------------------------------------


