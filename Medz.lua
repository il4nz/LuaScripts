-----------------------------------------------------------------------------------------------
-------------------------------------------- #Medz --------------------------------------------
local tag = "[{ff0000}Medz{ffffff}] | {ffffff}"
local colorslist = {
	["464646"] = "Hitman",
	["FFFFFF"] = "Civilian",
	["0080FF"] = "Police",
	["808080"] = "Dead",
	["00FFFF"] = "S.W.A.T",
	["FFA500"] = "Wanted",
	["8B4513"] = "Pagati",
	["FF0000"] = "Wanted",
	["BF1111"] = "Wanted",
	["FFFF00"] = "Wanted",
	["066501"] = "Admin",
	["800080"] = "Army",
	["FF00FF"] = "Event",
	["FFC0CB"] = "Medic",
	["33AA33"] = "Taxi",
	["556B2F"] = "Trucker"
	}

local errorcolorhex = "0xff0000"
local successcolorhex = "0x00ff00"
local errorcolor = "ff0000"
local successcolor = "00ff00"
local pgcolor = "8B4513"
local pgcolorhex = "0x8B4513"
local swatcolor = "00ffff"
local white = "ffffff"


-- SWAT Variables --
swatitems = 0
----------------------
-- General Variables --
selectlocation = 0
----------------------



-----------------------------------------------------------------------------------------------
script_author("#Medz")
-------------------------------------------- Requires ------------------------------
require 'moonloader'
require('lib.moonloader')
local imgui = require 'mimgui'
local ffi = require 'ffi'
local bNotf, notf = pcall(import, "imgui_notf.lua")
local sampev = require "lib.samp.events"

local menu = imgui.new.bool(false)
local window = imgui.new.bool(true)
local font = {}
local new = imgui.new
local ad = require "ADDONS"
local key = require "vkeys"
local fa = require('fAwesome6_solid')



medzcfg = require("inicfg").load(nil, "moonloader\\config\\Medz\\medz.ini")
-------------------------------------------- Main --------------------------------------------
function main()
	while not isSampAvailable() do wait(0) end
	while not sampIsLocalPlayerSpawned() do wait(0) end
	intro()
end


function sampev.onShowDialog(id, style, title, btn1, btn2, text)
    --sampAddChatMessage(id, -1)
    if id == 311 then -- dweap
        if title:find('V.I.P Packet') then-- change yourId on the id u received
            sampSendDialogResponse(311, 1, 1, nil) -- and this one too
            return false
        end
    end

	if id == 283 then -- Skill Menu
        if title:find('Skill List') then-- change yourId on the id u received
            sampSendDialogResponse(283, 1, 3, nil) -- and this one too
            return false
        end
    end
	-- if id == 281 then -- location
	-- 	if selectlocation == 0 then
	-- 	sampSendDialogResponse(281, 1, 0, nil) -- and this one too
	-- 	selectlocation = 1
	-- 	end

    --     return false
    -- end
	if id == 306 then -- Hitman help menu
		sampSendDialogResponse(306, 1, 0, nil) -- and this one too
        return false
    end
	------------ SWAT Class ----------------------------------------
if id == 70 then -- SWAT Items
	local money = getPlayerMoney()
        if money < 105 then
			lua_thread.create(
				function()
					wait(100)
					
					sampAddChatMessage(string.format("{%s}Error: {%s}No Money In Packet", errorcolor, white), errorcolorhex)
					
				end
			)
			return false
		end
		if swatitems == 0 and money >= 105 then
		sampSendDialogResponse(70, 1, 0, nil) -- wallet
		sampSendDialogResponse(70, 1, 1, nil) -- cork
		if money >= 250 then
		sampSendDialogResponse(70, 1, 4, nil) -- injections
		end
		lua_thread.create(
			function()
				wait(100)
				sampAddChatMessage(string.format("{%s}Success: {%s}SWAT{%s} Items{%s} Loaded", successcolor, swatcolor, white, successcolor), successcolorhex)
			end
		)
		swatitems = 1
		end
		lua_thread.create(
			function()
				wait(100)
				swatitemstaken = 1
			end
		)
		if swatitemstaken == 1 then
			
			sampAddChatMessage(string.format("{%s}Error: {%s}SWAT{%s} Items{%s} Already Loaded", errorcolor, swatcolor, white, errorcolor), errorcolorhex)
			
		end
		return false
        end
	return true
end


function sampev.onSetPlayerPos(position)
	local positionx = string.format("%.02f",position.x)
	local positiony = string.format("%.02f",position.y)
	local positionz = string.format("%.02f",position.z)
	if positionx == "2445.54" and positiony == "-2111.49" and positionz == "13.56" then -- SWAT
		swatitems = 0
		swatitemstaken = 0
		lua_thread.create(
			function()
				wait(100)
				sampAddChatMessage("--------------------------------------------------------------------------------", 0x00ffff)
				sampAddChatMessage("Spawned as S.W.A.T. Press F2 to open up the SWAT menu!", 0x00ffff)
				sampAddChatMessage("--------------------------------------------------------------------------------", 0x00ffff)
			end
		)
	end
	if positionx == "252.47" and positiony == "-1286.43" and positionz == "973.30" then -- TGOLS
		lua_thread.create(
			function()
				wait(100)
				sampAddChatMessage("-------------------------------------------------------------", 0x464646)
				sampAddChatMessage("Welcome to The Gang Of Lsrcr Streets HQ", 0x464646)
				sampAddChatMessage("-------------------------------------------------------------", 0x464646)
			end
		)
	end
	--sampAddChatMessage(string.format("Player: %.02f, %.02f, %.02f", positionx, positiony, positionz), 0xff0000)
end



	function sampev.onServerMessage(color, text)
--capo
if text:find("The Don") then
	text2 = text:sub(3)
	local mynick, myid = text2:match("(%S+)%((%d+)%)")
	local _, playerID = sampGetPlayerIdByCharHandle(playerPed)
	local name = sampGetPlayerNickname(playerID)
	if name == mynick then
		sampAddChatMessage("The Don+", 0xffffff)
	end
		
end
end



	function msg(text, color)
			sampAddChatMessage("{00ff00} --- Medz's Scripts ---", 0x00ff00)
			sampAddChatMessage(text, color)
	
		print('[Medz]: '..text)
	end
	function intro()
		wait(1100)
		sampAddChatMessage("{00ff00} --- Medz Scripts ---", 0x00ff00)
		print('***MEDZ LOADED***')
end

function sampev.onSendCommand(text)
	if text:find('/kill') then
    selectlocation = 0
	end
	if text:find('/status') then
		totalplayers = 0
		totalpagati = 0
		totalcops = 0
		totalwanted = 0
		totalswat = 0
		totalarmy = 0
		for idd = 0, sampGetMaxPlayerId(false) do
			if sampIsPlayerConnected(idd) and not sampIsPlayerNpc(idd) then
				totalplayers = totalplayers + 1
				colormeow = ("%X"):format(sampGetPlayerColor(idd)):gsub(".*(......)", "%1")--sampGetPlayerColor(id)
				if colorslist[colormeow] == "Police" then
					totalcops = totalcops + 1
				end
				if colorslist[colormeow] == "Pagati" then
					totalpagati = totalpagati + 1
				end
				if colorslist[colormeow] == "Wanted" then
					totalwanted = totalwanted + 1
				end
				if colorslist[colormeow] == "S.W.A.T" then
					totalswat = totalswat + 1
				end
				if colorslist[colormeow] == "Army" then
					totalarmy = totalarmy + 1
				end

				
			end
		end
		sampAddChatMessage("--------------------------------------------------------------------------------------------------------------", 0x976767)
		sampAddChatMessage(string.format("{0080FF}Cops: %s | {ff0000}Wanted: %s", totalcops, totalwanted), 0x976767)
		sampAddChatMessage(string.format("{00FFFF}SWAT: %s | {800080}Army: %s | {8B4513}Pagati: %s", totalswat, totalarmy, totalpagati), 0x976767)
		sampAddChatMessage("--------------------------------------------------------------------------------------------------------------", 0x976767)
		return false
		end
end

addEventHandler('onReceivePacket', function(id, bs)
    if id == 34 then --[[ ID_CONNECTION_REQUEST_ACCEPTED ]]
       sampAddChatMessage("Connection Accepted", 0xffffff)
    end
end) 



