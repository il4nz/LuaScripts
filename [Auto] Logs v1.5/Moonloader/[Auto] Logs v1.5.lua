-----------------------------------------------------------------------------------------------
-------------------------------------------- #Medz Logs --------------------------------------------
-----------------------------------------------------------------------------------------------
script_author("#Medz")
script_version("1.5")
-------------------------------------------- Requires ------------------------------
require "moonloader"
require("lib.moonloader")
local sampev = require "lib.samp.events"
-------------------------------------------- Config ------------------------------
local inicfg = require("inicfg")
local directIni = "MedzScripts\\Logs\\weapon.ini"
local weaponcfg = inicfg.load({}, directIni)
-------------------------------------------- Variables --------------------------------------------
local lsrcrIP = "37.187.77.206"
local Errormsg = "Medz Logs Error: "
---> colorslist
local colorslist = {
	["464646"] = "Hitman",
	["FFFFFF"] = "Civilian",
	["0080FF"] = "Police",
	["808080"] = "Dead",
	["00FFFF"] = "S.W.A.T",
	["FFA500"] = "Wanted",
	["8B4513"] = "Pagati",
	["FF0000"] = "Highly Wanted (Red)",
	["BF1111"] = "Most Wanted (Dark Red)",
	["FFFF00"] = "Low Wanted (Yellow)",
	["066501"] = "Admin",
	["800080"] = "SA Army",
	["FF00FF"] = "Event Godmode",
	["FFC0CB"] = "Medic",
	["33AA33"] = "Taxi",
	["556B2F"] = "Trucker"
	}
---------------- Logs ----------------
    --mydirect = 'D:\\Lsrcr\\Logs'
    mydirect = getGameDirectory().."\\Lsrcr\\Logs"
---> CMDs
    rape_path = mydirect .. "\\Commands\\" .. "Rape" .. ".log"
    rob_path = mydirect .. "\\Commands\\" .. "Rob" .. ".log"
    cuff_path = mydirect .. "\\Commands\\" .. "Cuff" .. ".log"
    arrest_path = mydirect .. "\\Commands\\" .. "Arrest" .. ".log"
---> Actions
    death_path = mydirect .. "\\Actions\\" .. "Deaths" .. ".log"
    kills_path = mydirect .. "\\Actions\\" .. "Kills" .. ".log"
    Whisper_path = mydirect .. "\\Actions\\" .. "Whisper" .. ".log"
---> PMs
    sendpm_path = mydirect .. "\\PMs\\" .. "sent" .. ".log"
    receivepm_path = mydirect .. "\\PMs\\" .. "received" .. ".log"
-------------------------------------------- Main --------------------------------------------
function main()
    while not isSampAvailable() do
        wait(0)
    end
    while not sampIsLocalPlayerSpawned() do
        wait(0)
    end
    sampRegisterChatCommand("clearlogs", clearlogs)
    intro()
end


function sampev.onPlayerDeathNotification(killerid, killedid, reason)
    local _, id = sampGetPlayerIdByCharHandle(playerPed)
    local colorx = ("%X"):format(sampGetPlayerColor(killerid)):gsub(".*(......)", "%1")
    --sampAddChatMessage(colorx, 0xff0000)
    --sampAddChatMessage(colorslist[colorx], -1)
    if killedid == id and killerid ~= 65535 then
        createDeathLog(
            string.format(
                "[DEATH] - Killed By: %s(%s) | Class: %s | Weapon: %s | Time: %s | Date: %s",
                sampGetPlayerNickname(killerid),
                killerid,
                colorslist[colorx],
                weaponcfg.weapons[reason],
                os.date("%X"),
                os.date("%x")
            )
        )
    end
    if killerid == id and killedid ~= 65535 then
        createKillLog(
            string.format(
                "[KILL] - Killed: %s(%s) | My Class: %s | Weapon: %s | Time: %s | Date: %s",
                sampGetPlayerNickname(killedid),
                killedid,
                colorslist[colorx],
                weaponcfg.weapons[reason],
                os.date("%X"),
                os.date("%x")
            )
        )
    end
end

function sampev.onServerMessage(color, text)
    --OOC & Whisper messages
    if text:find("(.*) (%S+)%((%d+)%) (.*)") then
        local f = ""
        local text2, nick, id, message = text:match("(.*) (%S+)%((%d+)%) (.*)")
        if string.startsWith(text2, "(WHISPER):") or string.startsWith(text2, "(OOC):") then

        createWhisperLog(
            string.format(
                "[%s | %s] By: %s(%s) | Message: %s",
                os.date("%X"),
                os.date("%x"),
                nick,
                id,
                message
            )
        )
        end
    end
    --jailed
    if text:find("The most wanted suspect (%S+)%((%d+)%) has been sent to Alcatraz by officer (%S+)%((%d+)%)") then
        --sampAddChatMessage('Testst', -1)
        local mynick, myid, enemy, enemyid =
            text:match("The most wanted suspect (%S+)%((%d+)%) has been sent to Alcatraz by officer (%S+)%((%d+)%)")
            createArrestedLog(
                string.format(
                    "[ARRESTED-ALCA] By: %s(%s) | Time: %s | Date: %s",
                    enemy,
                    enemyid,
                    os.date("%X"),
                    os.date("%x")
                )
            )
    end

    if
        text:find(
            "The most wanted suspect (%S+)%((%d+)%) has been sent to Alcatraz by officer (%S+)%((%d+)%) and (%S+)%((%d+)%)"
        )
     then
        local mynick, myid, enemy, enemyid, enemy2, enemyid2 =
            text:match(
            "The most wanted suspect (%S+)%((%d+)%) has been sent to Alcatraz by officer (%S+)%((%d+)%) and (%S+)%((%d+)%)"
        )
        local _, playerID = sampGetPlayerIdByCharHandle(playerPed)
            createArrestedLog(
                string.format(
                    "[ARRESTED-ALCA] By: %s(%s) & %s(%s) | Time: %s | Date: %s",
                    enemy,
                    enemyid,
                    enemy2,
                    enemyid2,
                    os.date("%X"),
                    os.date("%x")
                )
            )
    end
    if text:find("Wanted suspect (%S+)%((%d+)%) has been arrested by officer (%S+)%((%d+)%).") then
        local mynick, myid, enemy, enemyid =
            text:match("Wanted suspect (%S+)%((%d+)%) has been arrested by officer (%S+)%((%d+)%).")
        --msg(mynick, 0xffffff)
            createArrestedLog(
                string.format(
                    "[ARRESTED-JAIL] By: %s(%s) | Time: %s | Date: %s",
                    enemy,
                    enemyid,
                    os.date("%X"),
                    os.date("%x")
                )
            )
    end

    if text:find("Wanted suspect (%S+)%((%d+)%) has been arrested by officer (%S+)%((%d+)%) and (%S+)%((%d+)%).") then
        local mynick, myid, enemy, enemyid, enemy2, enemyid2 =
            text:match("Wanted suspect (%S+)%((%d+)%) has been arrested by officer (%S+)%((%d+)%) and (%S+)%((%d+)%).")
        local _, playerID = sampGetPlayerIdByCharHandle(playerPed)
            createArrestedLog(
                string.format(
                    "[ARRESTED-JAIL] By: %s(%s) & %s(%s) | Time: %s | Date: %s",
                    enemy,
                    enemyid,
                    enemy2,
                    enemyid2,
                    os.date("%X"),
                    os.date("%x")
                )
            )
    end
    if text:find("(%S+)%((%d+)%) has attempted to rob you. Your wallet will keep your cash secure for (%d+) more") then
        local nick, id, wallet =
            text:match("(%S+)%((%d+)%) has attempted to rob you. Your wallet will keep your cash secure for (%d+) more")
        --sampAddChatMessage(wallet)
        createRobLog(
            string.format(
                "[ATTEMPT-ROB] Name: %s(%s) | Wallet Secure: %s | Time: %s | Date: %s",
                nick,
                id,
                wallet,
                os.date("%X"),
                os.date("%x")
            )
        )
    end
    if text:find("(%S+)%((%d+)%) has put handcuffs on you.") then
        local nick, id = text:match("(%S+)%((%d+)%) has put handcuffs on you.")
        createCuffLog(
            string.format("[CUFFED] By: %s(%s) | Time: %s | Date: %s", nick, id, os.date("%X"), os.date("%x"))
        )
    end
    if text:find("(%S+)%((%d+)%) has attempted to rape you. Your cork will keep his place for (%d+) more") then
        local nick, id, attempts =
            text:match("(%S+)%((%d+)%) has attempted to rape you. Your cork will keep his place for (%d+) more")
        --sampAddChatMessage(attempts)
        createRapeLog(
            string.format(
                "[ATTEMPTED-RAPE] Name: %s(%s) | Cork: %s | Time: %s | Date: %s",
                nick,
                id,
                attempts,
                os.date("%X"),
                os.date("%x")
            )
        )
    end
    if text:find("(%S+)%((%d+)%) has raped you.") then
        local nick, id = text:match("(%S+)%((%d+)%) has raped you.")
        createRapeLog(
            string.format(
                "[SUCCESSFUL-RAPE] Name: %s(%s) | Time: %s | Date: %s",
                nick,
                id,
                os.date("%X"),
                os.date("%x")
            )
        )
    end
    if text:find("(%S+)%((%d+)%) has robbed $(%d+) from you") then
        local nick, id, money = text:match("(%S+)%((%d+)%) has robbed $(%d+) from you")
        createRobLog(
            string.format(
                "[SUCCESSFUL-ROB] Name: %s(%s) | Money: %s$ | Time: %s | Date: %s",
                nick,
                id,
                money,
                os.date("%X"),
                os.date("%x")
            )
        )
    end
    --received PM
    if text:find("from (%S+)%((%d+)%): (.*)") then
        local nick, id, message = text:match("from (%S+)%((%d+)%): (.*)")
        createReceivePMLog(
            string.format(
                "[%s | %s] From: %s(%s) - Message: %s",
                os.date("%X"),
                os.date("%x"),
                nick,
                id,
                message
            )
        )
    end
    --Sent PM
    if text:find("{FFFF00} to (%S+)%((%d+)%): (.*)") then
        local nick, id, message = text:match("{FFFF00} to (%S+)%((%d+)%): (.*)")
        createSendPMLog(
            string.format("[%s | %s] To: %s(%s) - Message: %s",
                os.date("%X"),
                os.date("%x"),
                nick,
                id,
                message
            )
        )
    end
end

-- functions
function intro()
    wait(1100)
    if not doesFileExist(getGameDirectory().."\\moonloader\\config\\MedzScripts\\Logs\\weapon.ini") then
        sampAddChatMessage(Errormsg .. "weapon.ini is missing", 0xff0000)
        thisScript():unload()
    end
    if not doesFileExist(arrest_path) then
        sampAddChatMessage(Errormsg .. "Arrest.log is missing", 0xff0000)
        thisScript():unload()
    end
    if not doesFileExist(cuff_path) then
        sampAddChatMessage(Errormsg .. "Cuff.log is missing", 0xff0000)
        thisScript():unload()
    end
    if not doesFileExist(death_path) then
        sampAddChatMessage(Errormsg .. "Deaths.log is missing", 0xff0000)
        thisScript():unload()
    end
    if not doesFileExist(kills_path) then
        sampAddChatMessage(Errormsg .. "Kills.log is missing", 0xff0000)
        thisScript():unload()
    end
    if not doesFileExist(rob_path) then
        sampAddChatMessage(Errormsg .. "Rob.log is missing", 0xff0000)
        thisScript():unload()
    end
    if not doesFileExist(rape_path) then
        sampAddChatMessage(Errormsg .. "Rape.log is missing", 0xff0000)
        thisScript():unload()
    end

    --PMs
    if not doesFileExist(sendpm_path) then
        sampAddChatMessage(Errormsg .. "sent.log is missing", 0xff0000)
        thisScript():unload()
    end
    if not doesFileExist(receivepm_path) then
        sampAddChatMessage(Errormsg .. "received.log is missing", 0xff0000)
        thisScript():unload()
    end
    

	IPaddress = sampGetCurrentServerAddress()
	if IPaddress ~= lsrcrIP then
		sampAddChatMessage(Errormsg .. "Wrong Server IP", 0xff0000)
        thisScript():unload()
    end
    wait(100)
    sampAddChatMessage("--- Medz Logs Loaded - Version: 1.5 - /clearlogs ---", 0x00ff00)
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

function createSendPMLog(text)
    file = io.open(sendpm_path, "a")
    file:write(text .. "\n")
    file:close()
end

function createReceivePMLog(text)
    file = io.open(receivepm_path, "a")
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


function createWhisperLog(text)
    file = io.open(Whisper_path, "a")
    file:write(text .. "\n")
    file:close()
end

function CleanLogs()
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
    file8 = io.open(receivepm_path, "w")
    file8:close()
    file9 = io.open(sendpm_path, "w")
    file9:close()
    file10 = io.open(Whisper_path, "w")
    file10:close()
end

function clearlogs(params)
    if params ~= nil then
        CleanLogs()
        LoadLogs()
        sampAddChatMessage("Cleared logs", 0xffffff)
    end
end

function LoadLogs()
    --
    file4 = io.open(rape_path, "a")
    file4:write(
        string.format(
            [[
-- Medz's Rapes Informer --
Time: %s
Date: %s
----------------------------------
]],
            os.date("%X"),
            os.date("%x")
        )
    )
    file4:close()

    --
    file5 = io.open(rob_path, "a")
    file5:write(
        string.format(
            [[
-- Medz's Robberies Informer --
Time: %s
Date: %s
----------------------------------
]],
            os.date("%X"),
            os.date("%x")
        )
    )
    file5:close()

    --
    file6 = io.open(cuff_path, "a")
    file6:write(
        string.format(
            [[
-- Medz's Cuff Informer --
Time: %s
Date: %s
----------------------------------
]],
            os.date("%X"),
            os.date("%x")
        )
    )
    file6:close()

    --
    file7 = io.open(death_path, "a")
    file7:write(
        string.format(
            [[
-- Medz's Deaths Informer --
Time: %s
Date: %s
----------------------------------
]],
            os.date("%X"),
            os.date("%x")
        )
    )
    file7:close()

    --
    file8 = io.open(kills_path, "a")
    file8:write(
        string.format(
            [[
-- Medz's Kills Informer --
Time: %s
Date: %s
----------------------------------
]],
            os.date("%X"),
            os.date("%x")
        )
    )
    file8:close()

    --
    file9 = io.open(arrest_path, "a")
    file9:write(
        string.format(
            [[
-- Medz's Jail Informer --
Time: %s
Date: %s
----------------------------------
]],
            os.date("%X"),
            os.date("%x")
        )
    )
    file9:close()
    -- ReceivedPM
    file10 = io.open(receivepm_path, "a")
    file10:write(
        string.format(
            [[
-- Medz's Received PMs Informer --
Time: %s
Date: %s
----------------------------------
]],
            os.date("%X"),
            os.date("%x")
        )
    )
    file10:close()
-- SentPM
        file11 = io.open(sendpm_path, "a")
        file11:write(
            string.format(
                [[
-- Medz's Sent PMs Informer --
Time: %s
Date: %s
----------------------------------
]],
                os.date("%X"),
                os.date("%x")
            )
        )
        file11:close()
        file12 = io.open(Whisper_path, "a")
        file12:write(
            string.format(
                [[
-- Medz's Whisper Informer --
Time: %s
Date: %s
----------------------------------
]],
                os.date("%X"),
                os.date("%x")
            )
        )
        file12:close()

end
local mt = getmetatable("String") function mt.__index:insert(implant, pos)     if pos == nil then         return self .. implant     end     return self:sub(1, pos) .. implant .. self:sub(pos + 1) end  function mt.__index:extract(pattern)     self = self:gsub(pattern, "")     return self end  function mt.__index:array()     local array = {}     for s in self:sub(".") do         array[#array + 1] = s     end     return array end  function mt.__index:isEmpty()     return self:find("%S") == nil end  function mt.__index:isDigit()     return self:find("%D") == nil end  function mt.__index:isAlpha()     return self:find("[%d%p]") == nil end  function mt.__index:split(sep, plain)     assert(not sep:isEmpty(), "Empty separator")         result, pos = {}, 1     repeat         local s, f = self:find(sep or " ", pos, plain)         result[#result + 1] = self:sub(pos, s and s - 1)         pos = f and f + 1     until pos == nil     return result end  local orig_lower = string.lower function mt.__index:lower()     for i = 192, 223 do         self = self:gsub(string.char(i), string.char(i + 32))     end     self = self:gsub(string.char(168), string.char(184))     return orig_lower(self) end  local orig_upper = string.upper function mt.__index:upper()     for i = 224, 255 do         self = self:gsub(string.char(i), string.char(i - 32))     end     self = self:gsub(string.char(184), string.char(168))     return orig_upper(self) end  function mt.__index:isSpace()     return self:find("^[%s%c]+$") ~= nil end  function mt.__index:isUpper()     return self:upper() == self end  function mt.__index:isLower()     return self:lower() == self end  function mt.__index:isSimilar(str)     return self == str end  function mt.__index:isTitle()     local p = self:find("[A-z?-???]")     local let = self:sub(p, p)     return let:isSimilar(let:upper()) end  function mt.__index:startsWith(str)     return self:sub(1, #str):isSimilar(str) end  function mt.__index:endsWith(str)     return self:sub(#self - #str + 1, #self):isSimilar(str) end  function mt.__index:capitalize()     local cap = self:sub(1, 1):upper()     self = self:gsub("^.", cap)     return self end  function mt.__index:tabsToSpace(count)     local spaces = (" "):rep(count or 4)     self = self:gsub("\t", spaces)     return self end  function mt.__index:spaceToTabs(count)     local spaces = (" "):rep(count or 4)     self = self:gsub(spaces, "t")     return self end  function mt.__index:center(width, char)     local len = width - #self     local s = string.rep(char or " ", len)      return s:insert(self, math.ceil(len / 2)) end  function mt.__index:count(search, p1, p2)     assert(not search:isEmpty(), "Empty search")     local area = self:sub(p1 or 1, p2 or #self)     local count, pos = 0, p1 or 1     repeat         local s, f = area:find(search, pos, true)         count = s and count + 1 or count         pos = f and f + 1     until pos == nil     return count end  function mt.__index:trimEnd()     self = self:gsub("%s*$", "")     return self end  function mt.__index:trimStart()     self = self:gsub("^%s*", "")     return self end  function mt.__index:trim()     self = self:match("^%s*(.-)%s*$")     return self end  function mt.__index:swapCase()     local result = {}     for s in self:gmatch(".") do         if s:isAlpha() then             s = s:isLower() and s:upper() or s:lower()         end         result[#result + 1] = s     end     return table.concat(result) end  function mt.__index:splitEqually(width)     assert(width > 0, "Width less than zero")     assert(width <= self:len(), "Width is greater than the string length")     local result, i = {}, 1     repeat         if #result == 0 or #result[#result] >= width then             result[#result + 1] = ""         end         result[#result] = result[#result] .. self:sub(i, i)         i = i + 1     until i > #self     return result end  function mt.__index:rFind(pattern, pos, plain)     local i = pos or #self     repeat         local result = { self:find(pattern, i, plain) }         if next(result) ~= nil then             return table.unpack(result)         end         i = i - 1     until i <= 0     return nil end  function mt.__index:wrap(width)     assert(width > 0, "Width less than zero")     assert(width < self:len(), "Width is greater than the string length")     local pos = 1     self = self:gsub("(%s+)()(%S+)()", function(sp, st, word, fi)         if fi - pos > (width or 72) then             pos = st             return "\n" .. word         end     end)        return self end  function mt.__index:levDist(str)     if #self == 0 then         return #str     elseif #str == 0 then         return #self     elseif self == str then         return 0     end          local cost = 0     local matrix = {}     for i = 0, #self do matrix[i] = {}; matrix[i][0] = i end     for i = 0, #str do matrix[0][i] = i end     for i = 1, #self, 1 do         for j = 1, #str, 1 do             cost = self:byte(i) == str:byte(j) and 0 or 1             matrix[i][j] = math.min(                 matrix[i - 1][j] + 1,                 matrix[i][j - 1] + 1,                 matrix[i - 1][j - 1] + cost             )         end     end     return matrix[#self][#str] end  function mt.__index:getSimilarity(str)     local dist = self:levDist(str)     return 1 - dist / math.max(#self, #str) end

