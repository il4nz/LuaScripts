-----------------------------------------------------------------------------------------------
-------------------------------------------- #Medz --------------------------------------------
local tag = "[{ff0000}Medz{ffffff}] | {ffffff}"

local names = {
	[0] = "Fist",
	[1] = "Brass Knuckles",
	[2] = "Golf Club",
	[3] = "Nightstick",
	[4] = "Knife",
	[5] = "Baseball Bat",
	[6] = "Shovel",
	[7] = "Pool Cue",
	[8] = "Katana",
	[9] = "Chainsaw",
	[10] = "Purple Dildo",
	[11] = "Dildo",
	[12] = "Vibrator",
	[13] = "Silver Vibrator",
	[14] = "Flowers",
	[15] = "Cane",
	[16] = "Grenade",
	[17] = "Tear Gas",
	[18] = "Molotov Cocktail",
	[22] = "9mm",
	[23] = "Silenced 9mm",
	[24] = "Desert Eagle",
	[25] = "Shotgun",
	[26] = "Sawnoff Shotgun",
	[27] = "Combat Shotgun",
	[28] = "Micro SMG/Uzi",
	[29] = "MP5",
	[30] = "AK-47",
	[31] = "M4",
	[32] = "Tec-9",
	[33] = "Country Rifle",
	[34] = "Sniper Rifle",
	[35] = "RPG",
	[36] = "HS Rocket",
	[37] = "Flamethrower",
	[38] = "Minigun",
	[39] = "Satchel Charge",
	[40] = "Detonator",
	[41] = "Spraycan",
	[42] = "Fire Extinguisher",
	[43] = "Camera",
	[44] = "Night Vis Goggles",
	[45] = "Thermal Goggles",
	[46] = "Parachute",
	[53] = "Suicidal"
     }

	 local status = {
		[2852159743] = "Police Officer",
		[3712370246] = "Hitman",
		[2868880640] = "Wanted",
		[2868838400] = "Highly Wanted",
		[2864648465] = "Most Wanted",
		[2868903935] = "Civilian",
		[2860548224] = "Dead",
		[2868903680] = "Low Wanted",
		[2852192255] = "SWAT",
		[4287317267] = "Pagati",
		[2860515456] = "Army",
		[4278609153] = "Game Administrator"
		}

		local colorslist = {
			[2852159743] = "0x0080FF",
			[3712370246] = "0x464646",
			[2868880640] = "0xFFA500",
			[2868838400] = "0xFF0000",
			[2864648465] = "0xBF1111",
			[2868903935] = "0xFFFFFF",
			[2860548224] = "0x808080",
			[2868903680] = "0xFFFF00",
			[2852192255] = "0x00FFFF",
			[4287317267] = "0x8B4513",
			[2860515456] = "0x800080",

			[4278609153] = "0x066501"
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
swatitemstaken = 0
----------------------

-- Pagati Variables --
pgweapons = 0
pgitems = 0
pgdrugs = 0
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
---------------- Logs ----------------
---> DMG
	log_path = getWorkingDirectory() .. "\\7logs\\DMG\\" .. "Given" .. ".log"
	log2_path = getWorkingDirectory() .. "\\7logs\\DMG\\" .. "Taken" .. ".log"
	log3_path = getWorkingDirectory() .. "\\7logs\\DMG\\" .. "Fist" .. ".log"
---> CMDs
	rape_path = getWorkingDirectory() .. "\\7logs\\CMDs\\" .. "Rape" .. ".log"
	rob_path = getWorkingDirectory() .. "\\7logs\\CMDs\\" .. "Rob" .. ".log"
	cuff_path = getWorkingDirectory() .. "\\7logs\\CMDs\\" .. "Cuff" .. ".log"
---> Actions
    death_path = getWorkingDirectory() .. "\\7logs\\Actions\\" .. "Deaths" .. ".log"
	kills_path = getWorkingDirectory() .. "\\7logs\\Actions\\" .. "Kills" .. ".log"
	arrest_path = getWorkingDirectory() .. "\\7logs\\Actions\\" .. "Arrest" .. ".log"
	pm_path = getWorkingDirectory() .. "\\7logs\\Actions\\" .. "PMs" .. ".log"
---------------- CMDs ----------------
	sampRegisterChatCommand("csearch", p1)
end

function sampev.onPlayerDeathNotification(killerid, killedid, reason)
	local _, id = sampGetPlayerIdByCharHandle(playerPed)
    if killedid == id and killerid ~= 65535 then
		local colorx = sampGetPlayerColor(killerid)
createDeathLog(string.format("[DEATH] - Killed By: %s(%s) | Status: %s | Weapon: %s | Time: %s | Date: %s", sampGetPlayerNickname(killerid), killerid, status[colorenemy], names[reason], os.date("%X"), os.date("%x")))
   end
   if killerid == id and killedid ~= 65535 then
	local colorx = sampGetPlayerColor(playerID)
	createKillLog(string.format("[KILL] - Killed: %s(%s) | Status: %s | Weapon: %s | Time: %s | Date: %s", sampGetPlayerNickname(killedid), killedid, status[colorx], names[reason], os.date("%X"), os.date("%x")))
	end
end

-- function sampev.onSendChat(message)
--     sampAddChatMessage(message)
--     message = string.gsub(message, "^[A-zÀ-ÿ]", function(s) -- Capitalize the first character
--         for i = 224, 255 do
--             s = string.gsub(s, _G.string.char(i), _G.string.char(i - 32))
--         end
--         s = string.gsub(s, _G.string.char(184), _G.string.char(168))
--         return string.upper(s)
--     end)
--     message = string.gsub(message, "%s*$", "") -- Removing unnecessary spaces at the end of a sentence
--     if not string.find(message, "%p$") then
--         return { message .. "." } -- Put a dot at the end if there is no other symbol
--     end
--     return { message }
-- end

function sampev.onSendGiveDamage(playerid, damage, weapon, bodypart)
	local health = sampGetPlayerHealth(playerid)
	local armor = sampGetPlayerArmor(playerid)
	local colorx = sampGetPlayerColor(playerid)

    if sampIsPlayerConnected(playerid) then --
	 createGivenLog(string.format("[GIVE] > Name: %s(%s) | Class: %s | Weapon: %s | Damage: %.2f | Health: %.2f | Armor: %.2f | Time: %s | Date: %s", sampGetPlayerNickname(playerid), playerid, status[colorx], names[weapon], damage, health, armor, os.date("%X"), os.date("%x")))
    end
end

function sampev.onSendTakeDamage(playerid, damage, weapon, bodypart)
	local _, id = sampGetPlayerIdByCharHandle(playerPed)
	local health = sampGetPlayerHealth(playerid)
	local armor = sampGetPlayerArmor(playerid)
	local colorx = sampGetPlayerColor(playerid)
    enemyidx = playerid
	colorenemy = sampGetPlayerColor(playerid)

    if sampIsPlayerConnected(playerid) then --
	--sampAddChatMessage(string.format("Health: %d", health2), 0xffffff)
	if weapon == 0 then
	createFistLog(string.format("[TAKEN-FIST] > Name: %s(%s) | Class: %s | Damage: %.2f | Health: %.2f | Armor: %.2f | Time: %s | Date: %s", sampGetPlayerNickname(playerid), playerid, status[colorx], damage, health, armor, os.date("%X"), os.date("%x")))
    else
		createTakenLog(string.format("[TAKE] > Name: %s(%s) | Class: %s | Weapon: %s | Damage: %.2f | Health: %.2f | Armor: %.2f | Time: %s | Date: %s", sampGetPlayerNickname(playerid), playerid, status[colorx], names[weapon], damage, health, armor, os.date("%X"), os.date("%x")))
	end
    end
end

function createTakenLog(text)
	file = io.open(log2_path, "a") 
	file:write(text .. "\n")
	file:close()
end

function createFistLog(text)
	file = io.open(log3_path, "a") 
	file:write(text .. "\n")
	file:close()
end


function createGivenLog(text)
	file = io.open(log_path, "a") 
	file:write(text .. "\n")
	file:close()
end

function getLocalPlayerId()
	local _, id = sampGetPlayerIdByCharHandle(playerPed)
	return id
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
	if id == 31071 then -- PG list
            sampSendDialogResponse(31071, 1, 0, nil) -- and this one too
            return false
    end
	if id == 281 then
		if selectlocation == 0 then
		sampSendDialogResponse(281, 1, 0, nil) -- and this one too
		selectlocation = 1
		end

        return false
    end
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

--------------------------------------------------------------
------------ Pagati Class ----------------------------------------
	if id == 98 then -- Pagati Weapons
            if pgweapons == 0 then
			sampSendDialogResponse(98, 1, 0, nil) -- armour
			sampSendDialogResponse(98, 1, 1, nil) -- deagle
			sampSendDialogResponse(98, 1, 1, nil) -- deagle
			sampSendDialogResponse(98, 1, 2, nil) -- m4
			sampSendDialogResponse(98, 1, 4, nil) -- uzi
			sampSendDialogResponse(98, 1, 6, nil) -- sniper
			sampSendDialogResponse(98, 1, 15, nil) -- sawns
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

	if id == 99 then -- Pagati Items
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

	if id == 95 then -- PG Drugs list
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
	--------------------------------------------------------------
	return { id, style, ('[%d] %s'):format(id, title), btn1, btn2, text}
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
	if positionx == "2445.54" and positiony == "-2111.49" and positionz == "13.56" then -- SWAT
		swatitems = 0
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
	sampAddChatMessage(string.format("Player: %.02f, %.02f, %.02f", positionx, positiony, positionz), 0xff0000)

end



	function sampev.onServerMessage(color, text)

--jailed
if text:find("The most wanted suspect (%S+)%((%d+)%) has been sent to Alcatraz by officer (%S+)%((%d+)%)") then
	--sampAddChatMessage('Testst', -1)
	local mynick, myid, enemy, enemyid = text:match("The most wanted suspect (%S+)%((%d+)%) has been sent to Alcatraz by officer (%S+)%((%d+)%)")
	if mynick == "Meow" then
		local colorx = sampGetPlayerColor(enemyid)
		createArrestedLog(string.format("[ARRESTED-ALCA] By: %s(%s) | Status: %s | Time: %s | Date: %s", enemy, enemyid, status[colorx], os.date("%X"), os.date("%x")))
	end
		
end

if text:find("The most wanted suspect (%S+)%((%d+)%) has been sent to Alcatraz by officer (%S+)%((%d+)%) and (%S+)%((%d+)%)") then
	local mynick, myid, enemy, enemyid, enemy2, enemyid2 = text:match("The most wanted suspect (%S+)%((%d+)%) has been sent to Alcatraz by officer (%S+)%((%d+)%) and (%S+)%((%d+)%)")
	local _, playerID = sampGetPlayerIdByCharHandle(playerPed)
	if mynick == "Meow" then
		local colorx = sampGetPlayerColor(enemyid)
		local colorx2 = sampGetPlayerColor(enemyid2)
		createArrestedLog(string.format("[ARRESTED-ALCA] By: %s(%s) & %s(%s) | Status: %s & %s | Time: %s | Date: %s", enemy, enemyid, enemy2, enemyid2, status[colorx], status[colorx2] , os.date("%X"), os.date("%x")))
	end
		
end
if text:find("Wanted suspect (%S+)%((%d+)%) has been arrested by officer (%S+)%((%d+)%).") then
	local mynick, myid, enemy, enemyid = text:match("Wanted suspect (%S+)%((%d+)%) has been arrested by officer (%S+)%((%d+)%).")
	--msg(mynick, 0xffffff)
	if mynick == "Meow" then
		local colorx = sampGetPlayerColor(enemyid)
		local colorx2 = sampGetPlayerColor(enemyid2)
		createArrestedLog(string.format("[ARRESTED-JAIL] By: %s(%s) | Status: %s | Time: %s | Date: %s", enemy, enemyid, status[colorx], os.date("%X"), os.date("%x")))
	end
		
end

if text:find("Wanted suspect (%S+)%((%d+)%) has been arrested by officer (%S+)%((%d+)%) and (%S+)%((%d+)%).") then
	local mynick, myid, enemy, enemyid, enemy2, enemyid2 = text:match("Wanted suspect (%S+)%((%d+)%) has been arrested by officer (%S+)%((%d+)%) and (%S+)%((%d+)%).")
	local _, playerID = sampGetPlayerIdByCharHandle(playerPed)
	if mynick == "Meow" then
		local colorx = sampGetPlayerColor(enemyid)
		local colorx2 = sampGetPlayerColor(enemyid2)

		createArrestedLog(string.format("[ARRESTED-JAIL] By: %s(%s) & %s(%s) | Status: %s & %s| Time: %s | Date: %s", enemy, enemyid, enemy2, enemyid2, status[colorx], status[colorx2], os.date("%X"), os.date("%x")))
	end
		
end
		if text:find("(%S+)%((%d+)%) has attempted to rob you. Your wallet will keep your cash secure for (%d+) more") then
            local nick, id, wallet = text:match("(%S+)%((%d+)%) has attempted to rob you. Your wallet will keep your cash secure for (%d+) more")
			--sampAddChatMessage(wallet)
				createRobLog(string.format("[ATTEMPT-ROB] Name: %s(%s) | Wallet Secure: %s | Time: %s | Date: %s", nick, id, wallet, os.date("%X"), os.date("%x")))
				
		end
		if text:find("(%S+)%((%d+)%) has put handcuffs on you.") then
            local nick, id = text:match("(%S+)%((%d+)%) has put handcuffs on you.")
			--sampAddChatMessage(wallet)
			local colorx = sampGetPlayerColor(id)
			createCuffLog(string.format("[CUFFED] By: %s(%s) | Status: %s | Time: %s | Date: %s", nick, id, status[colorx], os.date("%X"), os.date("%x")))
				
		end
		if text:find("(%S+)%((%d+)%) has attempted to rape you. Your cork will keep his place for (%d+) more") then
            local nick, id, attempts = text:match("(%S+)%((%d+)%) has attempted to rape you. Your cork will keep his place for (%d+) more")
			--sampAddChatMessage(attempts)
				createRapeLog(string.format("[ATTEMPTED-RAPE] Name: %s(%s) | Cork: %s | Time: %s | Date: %s", nick, id, attempts, os.date("%X"), os.date("%x")))

		end
		if text:find("(%S+)%((%d+)%) has raped you.") then
            local nick, id = text:match("(%S+)%((%d+)%) has raped you.")
				createRapeLog(string.format("[SUCCESS-RAPE] Name: %s(%s) | Time: %s | Date: %s", nick, id, os.date("%X"), os.date("%x")))

		end
		if text:find("(%S+)%((%d+)%) has robbed $(%d+) from you") then
            local nick, id, money = text:match("(%S+)%((%d+)%) has robbed $(%d+) from you")
				createRobLog(string.format("[SUCCESS-ROB] Name: %s(%s) | Money: %s$ | Time: %s | Date: %s", nick, id, money, os.date("%X"), os.date("%x")))

		end
--Whisper
		if text:find("from (%S+)%((%d+)%): (.*)") then
			--sampAddChatMessage('Received PM', -1)
            local nick, id, message = text:match("from (%S+)%((%d+)%): (.*)")
				createPMLog(string.format("[PM] From: %s(%s) | Message: %s | Time: %s | Date: %s", nick, id, message, os.date("%X"), os.date("%x")))

		end

	end

	 function p1(params)
		local id = tonumber(params)
		if id ~= nil then
			local color2 = sampGetPlayerColor(id)
			if colorslist[color2] == nil then
				colorslist[color2] = "0xffffff"
			end
			if status[color2] == nil then
				status[color2] = "Unknown"
			end
			sampAddChatMessage(string.format("Player: %s, Status: %s, Color: %s", sampGetPlayerNickname(id), status[color2], color2), colorslist[color2])
			--sampAddChatMessage(string.format("Player: %s, Color: %s", sampGetPlayerNickname(id), color2), 0xffffff)
		else
			sampAddChatMessage("Invalid ID: /csearch [ID]", 0xffffff)
		end

 end

	function createRapeLog(text)
		file = io.open(rape_path, "a") 
		file:write(text .. "\n")
		file:close()
	end

	function createRobLog(text)
		file = io.open(rob_path, "a") 
		file:write(text .. "\n")
		file:close()
	end

	function createPMLog(text)
		file = io.open(pm_path, "a") 
		file:write(text .. "\n")
		file:close()
	end

	function createArrestedLog(text)
		file = io.open(arrest_path, "a") 
		file:write(text .. "\n")
		file:close()
	end

	function createCuffLog(text)
		file = io.open(cuff_path, "a") 
		file:write(text .. "\n")
		file:close()
	end

	function createKillLog(text)
		file = io.open(kills_path, "a") 
		file:write(text .. "\n")
		file:close()
	end

	function createDeathLog(text)
		file = io.open(death_path, "a") 
		file:write(text .. "\n")
		file:close()
	end

	function deleteLogs()
		os.remove(log_path)
	end

	function CleanLogs()
		file = io.open(log_path, "w") 
		file:close()
		file2 = io.open(log2_path, "w") 
		file2:close()
		file3 = io.open(log3_path, "w") 
		file3:close()

		file4 = io.open(rape_path, "w") 
		file4:close()
		file5 = io.open(rob_path, "w") 
		file5:close()

		file6 = io.open(cuff_path, "w") 
		file6:close()
		file6 = io.open(kills_path, "w") 
		file6:close()
		file6 = io.open(death_path, "w") 
		file6:close()
		file7 = io.open(arrest_path, "w") 
		file7:close()
		file8 = io.open(pm_path, "w") 
		file8:close()
	end
	
	function LoadLogs()
		file = io.open(log_path, "a") 
	file:write(string.format([[
-- Medz's Given Hits Informer --
Time: %s
Date: %s
----------------------------------

]], os.date("%X"), os.date("%x")))
file:close()
--
file2 = io.open(log2_path, "a") 
file2:write(string.format([[
-- Medz's Taken Hits Informer --
Time: %s
Date: %s
----------------------------------

]], os.date("%X"), os.date("%x")))
file2:close()
--
file3 = io.open(log3_path, "a") 
file3:write(string.format([[
-- Medz's Fists Hits Informer --
Time: %s
Date: %s
----------------------------------

]], os.date("%X"), os.date("%x")))
file3:close()

--
file4 = io.open(rape_path, "a") 
file4:write(string.format([[
-- Medz's Rapes Informer --
Time: %s
Date: %s
----------------------------------

]], os.date("%X"), os.date("%x")))
file4:close()

--
file5 = io.open(rob_path, "a") 
file5:write(string.format([[
-- Medz's Robberies Informer --
Time: %s
Date: %s
----------------------------------

]], os.date("%X"), os.date("%x")))
file5:close()

--
file6 = io.open(cuff_path, "a") 
file6:write(string.format([[
-- Medz's Cuffing Informer --
Time: %s
Date: %s
----------------------------------

]], os.date("%X"), os.date("%x")))
file6:close()

--
file7 = io.open(death_path, "a") 
file7:write(string.format([[
-- Medz's Deaths Informer --
Time: %s
Date: %s
----------------------------------

]], os.date("%X"), os.date("%x")))
file7:close()

--
file8 = io.open(kills_path, "a") 
file8:write(string.format([[
-- Medz's Kills Informer --
Time: %s
Date: %s
----------------------------------

]], os.date("%X"), os.date("%x")))
file8:close()


--
file9 = io.open(arrest_path, "a") 
file9:write(string.format([[
-- Medz's Arrests Informer --
Time: %s
Date: %s
----------------------------------

]], os.date("%X"), os.date("%x")))
file9:close()
--PM
file10 = io.open(pm_path, "a") 
file10:write(string.format([[
-- Medz's PMs Informer --
Time: %s
Date: %s
----------------------------------

]], os.date("%X"), os.date("%x")))
file10:close()

	end
	
	function msg(text, color)
			sampAddChatMessage("{00ff00} --- Medz's Scripts ---", 0x00ff00)
			sampAddChatMessage(text, color)
	
		print('[Medz]: '..text)
	end
	function intro()
		wait(1100)
		sampAddChatMessage("{00ff00} --- Logs Loaded ---", 0x00ff00)
		print('[LOGS LOADED]:')
end

function sampev.onSendCommand(text)
	if text:find('/kill') then
    selectlocation = 0
	end
end

addEventHandler('onReceivePacket', function(id, bs)
    if id == 34 then --[[ ID_CONNECTION_REQUEST_ACCEPTED ]]
       sampAddChatMessage("Connection Accepted", 0xffffff)
    end
end) 