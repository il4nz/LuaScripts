

-- script_name("Short Command")
-- script_author("Medz")
-- require "lib.sampfuncs"

-- -- local inicfg = require 'inicfg'

-- -- local mainIni = inicfg.load({
-- --     Pagati =
-- --     {
-- --       text1 = "Meow",
-- --       text2 = "Meowz"
-- --     },
-- --     Hitman =
-- --     {
-- --         text1 = "Meow",
-- --         text2 = "Meowz",
-- --         text3 = "Meow",
-- --         text4 = "Meowz"
-- --     }
    
-- --   }) 
-- --   inicfg.save(mainIni)

-- function main()
--     if not isSampfuncsLoaded() or not isSampLoaded() then
--         return
--     end
--     while not isSampAvailable() do
--         wait(100)
--     end
--         sampAddChatMessage("[LOADED] {ffffff} Commands by Medz", 0xf607e1)
--         sampAddChatMessage(string.format("%s",  mainIni.Hitman.text4), 0xFFFFFFFF)
--         sampRegisterChatCommand('mcmds', cmdhelp1)
--         sampRegisterChatCommand('h1', h1)
--         sampRegisterChatCommand('p1', p1)
--         -- sampRegisterChatCommand('rad', rad)
--         -- sampRegisterChatCommand('al', armylist)
--         -- sampRegisterChatCommand('sl', swatlist)
--         -- sampRegisterChatCommand('pl', pglist)
--         -- sampRegisterChatCommand('rep', rep)
--         -- --donators
--         -- sampRegisterChatCommand('gjc', givejailcards)
--         -- --animations
--         -- sampRegisterChatCommand('asit', asit)
--         --testing
--     wait(-1)
-- end



-- function cmdhelp1(params)
--     if params ~= nil then 
--         sampAddChatMessage("------------------------------------------------", 0xFFFFFF)
--         sampAddChatMessage("-------- > Medzz's Regular CMDs < --------", 0xf607e1)
--         sampAddChatMessage('-------- /h1 -> hitman text --------', 0x07f636)
--         sampAddChatMessage('-------- /p1 -> Pagati Text --------', 0x07f636)
--         -- sampAddChatMessage('-------- /rad -> /radio --------', 0x07f636)
--         -- sampAddChatMessage('-------- /al -> /armylist --------', 0x07f636)
--         -- sampAddChatMessage('-------- /sl -> /swatlist --------', 0x07f636)
--         -- sampAddChatMessage('-------- /pl -> /pglist --------', 0x07f636)
--         -- sampAddChatMessage('-------- /rep -> /report [id] [msg] --------', 0x07f636)
--         -- sampAddChatMessage("------------------------------------------------", 0xFFFFFF)
--         -- sampAddChatMessage("-------- > Donators CMDs < --------", 0xf607e1)
--         -- sampAddChatMessage('-------- /gjc [ID] [Amount] -> /givejailcards [ID] [Amount] --------', 0x07f636)
--         -- sampAddChatMessage("------------------------------------------------", 0xFFFFFF)
--         -- sampAddChatMessage("-------- > Animation CMDs < --------", 0xf607e1)
--         -- sampAddChatMessage('-------- /asit -> /chairsit2: --------', 0x07f636)
--         -- sampAddChatMessage("------------------------------------------------", 0xFFFFFF)
        
--     end
-- end

-- --CMDs

-- function h1(params)
--      if params ~= nil then
--         sampSendChat("/news -------- > Professional Hitman < --------", params)
--          sampSendChat("/news Taking on hit contracts for a low cost, order your hit contracts right now!", params)
--          sampSendChat("/news [HELP] Command: /hit [ID] [Amount] [Reason]", params)
--      end
--  end

--  function p1(params)
--      if params ~= nil then
--         sampSendChat("/news -------- [ La Famiglia Assassini Pagati ] --------", params)
--          sampSendChat("/news Chris John (( Meow )) is now carrying out hit contracts, place yours today!", params)
--          sampSendChat("/news Command: /hit [ID] [Amount] [Reason]", params)
--      end
--  end
-- -- function rad(params)
-- --     if params ~= nil then
-- --         sampSendChat("/radio", params)
-- --     end
-- -- end

-- -- function asit(params)
-- --     if params ~= nil then
-- --         sampSendChat("/chairsit2", params)
-- --     end
-- -- end

-- -- function armylist(params)
-- --     if params ~= nil then
-- --         sampSendChat("/armylist", params)
-- --     end
-- -- end

-- -- function swatlist(params)
-- --     if params ~= nil then
-- --         sampSendChat("/swatlist", params)
-- --     end
-- -- end

-- -- function pglist(params)
-- --     if params ~= nil then
-- --         sampSendChat("/pglist", params)
-- --     end
-- -- end

-- -- function test(params)
-- --     	id = tonumber(params)
-- -- 		if params and id ~= nil then
-- -- 			sampSendChat("/w " .. id )
-- -- 		else
-- -- 			sampAddChatMessage("{00ff32}[MCMD]: {ffffff} /test [ID]", -1)
-- -- 		end
-- -- end
-- -- --
-- -- function givejailcards(params)
-- -- 		local a, b = params:match("(.+)%s+(.+)")
-- --         d = tonumber(a)
-- --         c = tonumber(b)
-- --         if c and d then
-- -- 		if a and b ~= nil then
-- -- 			sampSendChat("/givejailcard " .. a .. " " .. b)
-- -- 		else sampAddChatMessage("{00ff32}[MCMD]: {ff0000} /givejailcard [id] [amount]", -1) 
-- --         end
-- --         else sampAddChatMessage("{00ff32}[MCMD]: {ff0000} /givejailcard [id] [amount]", -1)
-- --     end
-- -- end


-- -- function rep(params)
-- --     local a, b = params:match("(.+)%s+(.+)")
-- --     d = tonumber(a)
-- --     if d then
-- --     if a and b ~= nil then
-- --         sampSendChat("/report " .. a .. " " .. b)
-- --     else sampAddChatMessage("{00ff32}[MCMD]: {ff0000} /report [id] [reason]", -1) 
-- --     end
-- --     else sampAddChatMessage("{00ff32}[MCMD]: {ff0000} /report [id] [reason]", -1)
-- -- end
-- -- end
-- --TESTING


-- --function test(params)
-- --    local a, b = params:match("(.+)%s+(.+)")
-- --    if a and b ~= nil then
-- --        sampSendChat("/w " .. a .. " " .. b)
-- --    end
-- --end
