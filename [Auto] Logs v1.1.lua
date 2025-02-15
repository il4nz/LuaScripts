-----------------------------------------------------------------------------------------------
-------------------------------------------- #Medz Logs --------------------------------------------
-----------------------------------------------------------------------------------------------
script_author("#Medz")
-------------------------------------------- Requires ------------------------------
require "moonloader"
require("lib.moonloader")
local sampev = require "lib.samp.events"
-------------------------------------------- Config ------------------------------
local inicfg = require("inicfg")
local directIni = "MedzScripts\\config.ini"
local cfg = inicfg.load({}, directIni)
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
    arrest_path = getWorkingDirectory() .. "\\.medzlogs\\Actions\\" .. "Arrest" .. ".log"

    sendpm_path = getWorkingDirectory() .. "\\.medzlogs\\PMs\\" .. "sent" .. ".log"
    receivepm_path = getWorkingDirectory() .. "\\.medzlogs\\PMs\\" .. "received" .. ".log"

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
                cfg.colors[colorx],
                cfg.weapons[reason],
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
                cfg.colors[colorx],
                cfg.weapons[reason],
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
    --received
    if text:find("from (%S+)%((%d+)%): (.*)") then
        --sampAddChatMessage('Received PM', -1)
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
    --Sent
    --PM{FFFF00} to Exterminator(15): testing..
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

function intro()
    wait(1100)
    if not doesFileExist(getGameDirectory().."\\moonloader\\config\\MedzScripts\\config.ini") then
        sampAddChatMessage("Medz Logs Error: config.ini is missing", 0xff0000)
        thisScript():unload()
    end
    --
    ---Actions
    if not doesFileExist(getGameDirectory().."\\moonloader\\.medzlogs\\Actions\\Arrest.log") then
        sampAddChatMessage("Medz Logs Error: Arrest.log is missing", 0xff0000)
        thisScript():unload()
    end
    if not doesFileExist(getGameDirectory().."\\moonloader\\.medzlogs\\Actions\\Cuff.log") then
        sampAddChatMessage("Medz Logs Error: Cuff.log is missing", 0xff0000)
        thisScript():unload()
    end
    if not doesFileExist(getGameDirectory().."\\moonloader\\.medzlogs\\Actions\\Deaths.log") then
        sampAddChatMessage("Medz Logs Error: Deaths.log is missing", 0xff0000)
        thisScript():unload()
    end
    if not doesFileExist(getGameDirectory().."\\moonloader\\.medzlogs\\Actions\\Kills.log") then
        sampAddChatMessage("Medz Logs Error: Kills.log is missing", 0xff0000)
        thisScript():unload()
    end
    if not doesFileExist(getGameDirectory().."\\moonloader\\.medzlogs\\Actions\\Rob.log") then
        sampAddChatMessage("Medz Logs Error: Rob.log is missing", 0xff0000)
        thisScript():unload()
    end
    if not doesFileExist(getGameDirectory().."\\moonloader\\.medzlogs\\Actions\\Rape.log") then
        sampAddChatMessage("Medz Logs Error: Rape.log is missing", 0xff0000)
        thisScript():unload()
    end

    --PMs
    if not doesFileExist(getGameDirectory().."\\moonloader\\.medzlogs\\PMs\\sent.log") then
        sampAddChatMessage("Medz Logs Error: sent.log is missing", 0xff0000)
        thisScript():unload()
    end
    if not doesFileExist(getGameDirectory().."\\moonloader\\.medzlogs\\PMs\\received.log") then
        sampAddChatMessage("Medz Logs Error: received.log is missing", 0xff0000)
        thisScript():unload()
    end
    

	IPaddress = sampGetCurrentServerAddress()
	if IPaddress ~= "37.187.77.206" then
		sampAddChatMessage("Medz Logs Error: Wrong IP", 0xff0000)
        thisScript():unload()
    end
    wait(1000)
    sampAddChatMessage("--- Medz Logs Loaded - Version: 1.0 - /clearlogs ---", 0x7601f8)
end

function clearlogs(params)
    if params ~= nil then
        CleanLogs()
        LoadLogs()
        sampAddChatMessage("Cleared logs", 0xffffff)
    end
end
