script_name('RadarID by chapo')
--------------------------------------------------------------------------
-->>         _____           _          _____ _____                   <<--
-->>        |  __ \         | |        |_   _|  __ \                  <<--
-->>        | |__) |__ _  __| | __ _ _ __| | | |  | |                 <<--
-->>        |  _  // _` |/ _` |/ _` | '__| | | |  | |                 <<--
-->>        | | \ \ (_| | (_| | (_| | | _| |_| |__| |                 <<--
-->>        |_|  \_\__,_|\__,_|\__,_|_||_____|_____/                  <<--
-->>              | |                | |                              <<--
-->>              | |__  _   _    ___| |__   __ _ _ __   ___          <<--
-->>              | '_ \| | | |  / __| '_ \ / _` | '_ \ / _ \         <<--
-->>              | |_) | |_| | | (__| | | | (_| | |_) | (_) |        <<--
-->>              |_.__/ \__, |  \___|_| |_|\__,_| .__/ \___/         <<--
-->>                      __/ |                  | |                  <<--
-->>                     |___/                   |_|                  <<--
-->>                                                                  <<--
-->>    BlastHack: blast.hk/members/112329/                           <<--
-->>    VK: vk.com/chaposcripts                                       <<--
--------------------------------------------------------------------------
local ffi = require('ffi')
local imgui = require('mimgui')
local inicfg = require('inicfg')
local ini = inicfg.load(inicfg.load({ main = { adminmode = false }, }, 'RadarIdsByChapo.ini'))
inicfg.save(ini, 'RadarIdsByChapo.ini')
local AdminMode, AdminCommands = ini.main.adminmode, {}
local PlayerPopup = { id = 'none', name = 'none', lvl = 'none', ping = 'none' }

ffi.cdef('struct CVector2D {float x, y;}')
local CRadar_TransformRealWorldPointToRadarSpace = ffi.cast('void (__cdecl*)(struct CVector2D*, struct CVector2D*)', 0x583530)
local CRadar_TransformRadarPointToScreenSpace = ffi.cast('void (__cdecl*)(struct CVector2D*, struct CVector2D*)', 0x583480)
local CRadar_IsPointInsideRadar = ffi.cast('bool (__cdecl*)(struct CVector2D*)', 0x584D40)

function TransformRealWorldPointToRadarSpace(x, y)
    local RetVal = ffi.new('struct CVector2D', {0, 0})
    CRadar_TransformRealWorldPointToRadarSpace(RetVal, ffi.new('struct CVector2D', {x, y}))
    return RetVal.x, RetVal.y
end

function TransformRadarPointToScreenSpace(x, y)
    local RetVal = ffi.new('struct CVector2D', {0, 0})
    CRadar_TransformRadarPointToScreenSpace(RetVal, ffi.new('struct CVector2D', {x, y}))
    return RetVal.x, RetVal.y
end

function IsPointInsideRadar(x, y)
    return CRadar_IsPointInsideRadar(ffi.new('struct CVector2D', {x, y}))
end

imgui.OnInitialize(function()
    imgui.GetStyle().FrameRounding = 5
    imgui.GetStyle().WindowRounding = 5
    imgui.GetStyle().ChildRounding = 5
    imgui.GetStyle().WindowTitleAlign = imgui.ImVec2(0.5, 0.5)
end)

local Frame = imgui.OnFrame(
    function() return isSampAvailable() and not sampIsScoreboardOpen() and sampGetChatDisplayMode() == 2 and not isPauseMenuActive() end,
    function(self)
        self.HideCursor = not imgui.IsPopupOpen(('%s ( %s )'):format(PlayerPopup.name, PlayerPopup.id))
        local DL = imgui.GetBackgroundDrawList()
        for _, ped in ipairs(getAllChars()) do
            if ped ~= PLAYER_PED then
                local result, id = sampGetPlayerIdByCharHandle(ped)
                if result then
                    local x, y, z = getCharCoordinates(ped)
                    local radarSpace = imgui.ImVec2(TransformRealWorldPointToRadarSpace(x, y))
                    if IsPointInsideRadar(radarSpace.x, radarSpace.y) then
                        local screenSpace = imgui.ImVec2(TransformRadarPointToScreenSpace(radarSpace.x, radarSpace.y))
                        local textSize = imgui.CalcTextSize(tostring(id))
                        local pos = imgui.ImVec2(screenSpace.x - textSize.x / 2, screenSpace.y)
                        local a, r, g, b = explode_argb(sampGetPlayerColor(id))
                        local PlayerColorVec4 = imgui.ImVec4(r / 255, g / 255, b / 255, 1)
                        DL:AddText(imgui.ImVec2(pos.x - 1, pos.y - 1), 0xCC000000, tostring(id))
                        DL:AddText(imgui.ImVec2(pos.x + 1, pos.y + 1), 0xCC000000, tostring(id))
                        DL:AddText(imgui.ImVec2(pos.x - 1, pos.y + 1), 0xCC000000, tostring(id))
                        DL:AddText(imgui.ImVec2(pos.x + 1, pos.y - 1), 0xCC000000, tostring(id))
                        DL:AddText(pos, imgui.GetColorU32Vec4(PlayerColorVec4), tostring(id))
                        if sampIsCursorActive() then
                            local cur = imgui.ImVec2(getCursorPos())
                            if cur.x >= pos.x and cur.x <= pos.x + textSize.x then
                                if cur.y >= pos.y and cur.y <= pos.y + textSize.y then
                                    DL:AddRect(imgui.ImVec2(pos.x - 2, pos.y - 1), imgui.ImVec2(pos.x + textSize.x, pos.y + textSize.y + 1), 0xFFffffff, 5)--, int rounding_corners_flags = ~0, float thickness = 1.0f)
                                    imgui.PushStyleColor(imgui.Col.Border, PlayerColorVec4)
                                    imgui.BeginTooltip()
                                    imgui.TextColored(PlayerColorVec4, 'ID: ')      imgui.SameLine(50) imgui.Text(tostring(id))
                                    imgui.TextColored(PlayerColorVec4, 'NAME: ')    imgui.SameLine(50) imgui.Text(sampGetPlayerNickname(id) or 'none')
                                    imgui.TextColored(PlayerColorVec4, 'LVL: ')     imgui.SameLine(50) imgui.Text(tostring(sampGetPlayerScore(id)) or 'none')
                                    imgui.TextColored(PlayerColorVec4, 'PING: ')    imgui.SameLine(50) imgui.Text(tostring(sampGetPlayerPing(id)) or 'none')
                                    imgui.EndTooltip()
                                    
                                    imgui.PopStyleColor()
                                    if AdminMode and wasKeyPressed(1) then
                                        PlayerPopup = { 
                                            id = tostring(id), 
                                            name = sampGetPlayerNickname(id) or 'none', 
                                            lvl = tostring(sampGetPlayerScore(id)), 
                                            ping = tostring(sampGetPlayerPing(id)),
                                        }
                                        imgui.OpenPopup(('%s ( %s )'):format(PlayerPopup.name, PlayerPopup.id))
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
        if imgui.BeginPopupModal(('%s ( %s )'):format(PlayerPopup.name, PlayerPopup.id), nil, imgui.WindowFlags.NoResize) then 
            local size = imgui.ImVec2(200, 250)
            imgui.SetWindowSizeVec2(size)
            imgui.SetCursorPos(imgui.ImVec2(5, 25))
            if imgui.BeginChild('commands', imgui.ImVec2(size.x - 10, size.y - 25 - 29 - 5), true) then
                for _, command in ipairs(AdminCommands) do
                    imgui.SetCursorPosX(5)
                    local cmd = select(1, command:gsub('{id}', PlayerPopup.id))
                    if imgui.Button(cmd, imgui.ImVec2(size.x - 20)) then
                        sampSendChat(cmd)
                        imgui.CloseCurrentPopup()
                    end
                end
                imgui.EndChild()
            end
            
            imgui.SetCursorPos(imgui.ImVec2(5, size.y - 29))
            if imgui.Button('Close', imgui.ImVec2(size.x - 10, 20)) then
                imgui.CloseCurrentPopup()
            end
            imgui.EndPopup() 
        end
    end
)

function main()
    while not isSampAvailable() do wait(0) end
    if doesFileExist(getWorkingDirectory()..'\\config\\RadarIdsByChapo_commands.txt') then
        for line in io.lines(getWorkingDirectory()..'\\config\\RadarIdsByChapo_commands.txt') do
            table.insert(AdminCommands, line)
        end
    else
        local F = io.open(getWorkingDirectory()..'\\config\\RadarIdsByChapo_commands.txt', 'w')
        F:write('/re {id}\n/goto {id}\n/check {id}\n/gethere {id}\n/stats {id}')
        F:close()
    end
    
    sampRegisterChatCommand('radarid.admin', function()
        if doesFileExist(getWorkingDirectory()..'\\config\\RadarIdsByChapo_commands.txt') then
            AdminMode = not AdminMode
            sampAddChatMessage('RadarIDS >> режим администратора '..(AdminMode and 'включен' or 'выключен'), -1)
            ini.main.adminmode = AdminMode
            inicfg.save(ini, 'RadarIdsByChapo.ini')
        else
            sampAddChatMessage('RadarIDS >> ошибка, файл "RadarIdsByChapo_commands.txt" не найден в папке "moonloader\\config"', -1)
        end
    end)
    wait(-1)
end


function argb_to_abgr(argb)
    local a, r, g, b = explode_argb(argb)
    return join_argb(255, b, g, r)
end

function explode_argb(argb)
    local a = bit.band(bit.rshift(argb, 24), 0xFF)
    local r = bit.band(bit.rshift(argb, 16), 0xFF)
    local g = bit.band(bit.rshift(argb, 8), 0xFF)
    local b = bit.band(argb, 0xFF)
    return a, r, g, b
end

function join_argb(a, r, g, b)
    local argb = b  -- b
    argb = bit.bor(argb, bit.lshift(g, 8))  -- g
    argb = bit.bor(argb, bit.lshift(r, 16)) -- r
    argb = bit.bor(argb, bit.lshift(a, 24)) -- a
    return argb
end