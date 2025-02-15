-----------------------------------------------------------------------------------------------
-------------------------------------------- #Medz Logs --------------------------------------------
local weapons = {
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
local colorslist = {
    ["464646"] = "Hitman",
    ["FFFFFF"] = "Civilian",
    ["0080FF"] = "Police",
    ["808080"] = "Dead",
    ["00FFFF"] = "S.W.A.T",
    ["FFA500"] = "Wanted",
    ["8B4513"] = "Pagati",
    ["FF0000"] = "Highly Wanted (RED)",
    ["BF1111"] = "Most Wanted (DARK RED)",
    ["FFFF00"] = "Low Wanted (YELLOW)",
    ["066501"] = "Admin"
}

local errorcolorhex = "0xff0000"
local successcolorhex = "0x00ff00"
local errorcolor = "ff0000"
local successcolor = "00ff00"

-----------------------------------------------------------------------------------------------
script_author("#Medz")
-------------------------------------------- Requires ------------------------------
require "moonloader"
require("lib.moonloader")
local sampev = require "lib.samp.events"
--------------------------------------------- C O N F I G ---------------------------------------------

local inicfg = require("inicfg")
local directIni = "Logs\\Logscfg.ini"
local cfg = inicfg.load(inicfg.load({ 
    weapons =
{
  0 = "Fist",
  4 = "Knife",
  5 = "Baseball Bat",
  6 = "Shovel",
  8 = "Katana",
9 = "Chainsaw",
   10 = "Purple Dildo",
    11 = "Dildo",
    16 = "Grenade",
    22 = "9mm",
    23 = "Silenced 9mm",
    24 = "Desert Eagle",
    25 = "Shotgun",
    26 = "Sawnoff Shotgun",
    27 = "Combat Shotgun",
    28 = "Micro SMG/Uzi",
    29 = "MP5",
    30 = "AK-47",
    31 = "M4",
    32 = "Tec-9",
    33 = "Country Rifle",
    34 = "Sniper Rifle",
    35 = "RPG",
    37 = "Flamethrower",
    38 = "Minigun",
    39 = "Satchel Charge",
    40 = "Detonator",
    41 = "Spraycan",
    53 = "Suicidal"
},
colors =
{
  transparent_bg = false
}
}), directIni)
inicfg.save(cfg, directIni)
-------------------------------------------- Main --------------------------------------------
function main()
    while not isSampAvailable() do
        wait(0)
    end
    while not sampIsLocalPlayerSpawned() do
        wait(0)
    end
    intro()
    sampRegisterChatCommand("clearlogs", clearlogs)
    ---------------- Logs ----------------
    ---> CMDs
    rape_path = getWorkingDirectory() .. "\\.medzlogs\\Actions\\" .. "Rape" .. ".log"
    rob_path = getWorkingDirectory() .. "\\.medzlogs\\Actions\\" .. "Rob" .. ".log"
    cuff_path = getWorkingDirectory() .. "\\.medzlogs\\Actions\\" .. "Cuff" .. ".log"
    ---> Actions
    death_path = getWorkingDirectory() .. "\\.medzlogs\\Actions\\" .. "Deaths" .. ".log"
    kills_path = getWorkingDirectory() .. "\\.medzlogs\\Actions\\" .. "Kills" .. ".log"
    arrest_path = getWorkingDirectory() .. "\\.medzlogs\\Actions\\" .. "Jailed" .. ".log"
    pm_path = getWorkingDirectory() .. "\\.medzlogs\\PMs\\" .. "text" .. ".log"
    ---------------- CMDs ----------------
end

function sampev.onPlayerDeathNotification(killerid, killedid, reason)
    local _, id = sampGetPlayerIdByCharHandle(playerPed)
    if killedid == id and killerid ~= 65535 then
        local colorx = ("%X"):format(sampGetPlayerColor(killerid)):gsub(".*(......)", "%1")

        createDeathLog(
            string.format(
                "[DEATH] - Killed By: %s(%s) | Enemy Class: %s | Weapon: %s | Time: %s | Date: %s",
                sampGetPlayerNickname(killerid),
                killerid,
                colorslist[colorx],
                names[reason],
                os.date("%X"),
                os.date("%x")
            )
        )
    end
    if killerid == id and killedid ~= 65535 then
        local colorx = ("%X"):format(sampGetPlayerColor(killerid)):gsub(".*(......)", "%1")
        createKillLog(
            string.format(
                "[KILL] - Killed: %s(%s) | My Class: %s | Weapon: %s | Time: %s | Date: %s",
                sampGetPlayerNickname(killedid),
                killedid,
                colorslist[colorx],
                names[reason],
                os.date("%X"),
                os.date("%x")
            )
        )
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
    file8 = io.open(pm_path, "w")
    file8:close()
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
    --PM
    file10 = io.open(pm_path, "a")
    file10:write(
        string.format(
            [[
-- Medz's PMs Informer --
Time: %s
Date: %s
----------------------------------

]],
            os.date("%X"),
            os.date("%x")
        )
    )
    file10:close()
end

function sampev.onServerMessage(color, text)
    --jailed
    if text:find("The most wanted suspect (%S+)%((%d+)%) has been sent to Alcatraz by officer (%S+)%((%d+)%)") then
        --sampAddChatMessage('Testst', -1)
        local mynick, myid, enemy, enemyid =
            text:match("The most wanted suspect (%S+)%((%d+)%) has been sent to Alcatraz by officer (%S+)%((%d+)%)")
        if mynick == "Meow" then
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
        if mynick == "Meow" then
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
    end
    if text:find("Wanted suspect (%S+)%((%d+)%) has been arrested by officer (%S+)%((%d+)%).") then
        local mynick, myid, enemy, enemyid =
            text:match("Wanted suspect (%S+)%((%d+)%) has been arrested by officer (%S+)%((%d+)%).")
        --msg(mynick, 0xffffff)
        if mynick == "Meow" then
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
    end

    if text:find("Wanted suspect (%S+)%((%d+)%) has been arrested by officer (%S+)%((%d+)%) and (%S+)%((%d+)%).") then
        local mynick, myid, enemy, enemyid, enemy2, enemyid2 =
            text:match("Wanted suspect (%S+)%((%d+)%) has been arrested by officer (%S+)%((%d+)%) and (%S+)%((%d+)%).")
        local _, playerID = sampGetPlayerIdByCharHandle(playerPed)
        if mynick == "Meow" then
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
        --sampAddChatMessage(wallet)
        local colorx = sampGetPlayerColor(id)
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
    --Whisper
    if text:find("from (%S+)%((%d+)%): (.*)") then
        --sampAddChatMessage('Received PM', -1)
        local nick, id, message = text:match("from (%S+)%((%d+)%): (.*)")
        createPMLog(
            string.format(
                "[PM] From: %s(%s) - Message: %s [Time: %s | Date: %s]",
                nick,
                id,
                message,
                os.date("%X"),
                os.date("%x")
            )
        )
    end
end

function intro()
    wait(1100)
    sampAddChatMessage("{00ff00} --- Medz Logs Loaded ---", 0x00ff00)
    print("***Medz LOGS LOADED***")
end

function clearlogs(params)
    if params ~= nil then
        CleanLogs()
        LoadLogs()
        sampAddChatMessage("Cleared logs", 0xffffff)
    end
end
