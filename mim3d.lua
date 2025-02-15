local sampev = require 'lib.samp.events'
local imgui = require 'mimgui'
local encoding = require 'encoding'
encoding.default = 'CP1251'
u8 = encoding.UTF8

local inicfg = require 'inicfg'
local directIni = 'mim3d_by_chapo.ini'
local ini = inicfg.load(inicfg.load({
    main = {
        enabled = true,
        list = '[]',
        fontsize = 17,
        lineinterval = 5,
        fontname = 'trebucbd.ttf'
    },
}, directIni))
inicfg.save(ini, directIni)
local ffi = require('ffi')
local Window = imgui.new.bool(false)
local FontSearch = imgui.new.char[64]('')

local Font = {}
local s = {
    enabled = imgui.new.bool(ini.main.enabled),
    fontsize = imgui.new.int(ini.main.fontsize),
    lineinterval = imgui.new.int(ini.main.lineinterval),
    fontname = ini.main.fontname,
}

imgui.OnInitialize(function()
    imgui.DarkTheme()
    imgui.GetIO().IniFilename = nil
    local glyph_ranges = imgui.GetIO().Fonts:GetGlyphRangesCyrillic()
    for size = 10, 20 do
        Font[size] = imgui.GetIO().Fonts:AddFontFromFileTTF(getFolderPath(0x14) .. '\\' .. s.fontname, size, nil, glyph_ranges)
    end
end)

function json(filePath)
    local filePath = getWorkingDirectory()..'\\config\\'..(filePath:find('(.+).json') and filePath or filePath..'.json')
    local class = {}
    if not doesDirectoryExist(getWorkingDirectory()..'\\config') then
        createDirectory(getWorkingDirectory()..'\\config')
    end
    
    function class:Save(tbl)
        if tbl then
            local F = io.open(filePath, 'w')
            F:write(encodeJson(tbl) or {})
            F:close()
            return true, 'ok'
        end
        return false, 'table = nil'
    end

    function class:Load(defaultTable)
        if not doesFileExist(filePath) then
            class:Save(defaultTable or {})
        end
        local F = io.open(filePath, 'r+')
        local TABLE = decodeJson(F:read() or {})
        F:close()
        for def_k, def_v in next, defaultTable do
            if TABLE[def_k] == nil then
                TABLE[def_k] = def_v
            end
        end
        return TABLE
    end

    return class
end
local List = json('mim3d_saved_texts.json'):Load({})

function sampev.onCreate3DText(idObject, color, position, distance, ignoreWalls, attachedPlayerId, attachedVehicleId, textObject)
    List[tostring(idObject)] = { textObject, color, position.x, position.y, position.z, distance, ignoreWalls, attachedPlayerId, attachedVehicleId }
    if s.enabled[0] then
        if attachedPlayerId > 1000 and attachedVehicleId > 2000 then
            return false
        else
            return {idObject, color, position, distance, ignoreWalls, attachedPlayerId, attachedVehicleId, textObject}
        end
    end
end

function sampev.onRemove3DTextLabel(id)
    if List[id] then
        List[id] = nil
    end
end

function save()
    --ini.main.list = encodeJson(List) or '[]'
    ini.main.enabled = s.enabled[0]
    ini.main.fontsize = s.fontsize[0]
    ini.main.lineinterval = s.lineinterval[0]
    ini.main.fontname = s.fontname
    json('mim3d_saved_texts'):Save(List)
    inicfg.save(ini, directIni)
end

function onScriptTerminate(s, q)
    save()
end

function getFilesInPath(path, ftype)
    local Files, SearchHandle, File = {}, findFirstFile(path.."\\"..ftype)
    table.insert(Files, File)
    while File do File = findNextFile(SearchHandle) table.insert(Files, File) end
    return Files
end

-->> IMGUI <<--
local DrawListFrame = imgui.OnFrame(
    function() return isSampAvailable() end,
    function(self)
        self.HideCursor = true
        local DL = imgui.GetBackgroundDrawList()
        for id, data in pairs(List) do
            local text, color, posX, posY, posZ, distance, ignoreWalls, playerId, vehicleId = table.unpack(data)--sampGet3dTextInfoById(id)
            local selfX, selfY, selfZ = getCharCoordinates(PLAYER_PED)
            local x, y = convert3DCoordsToScreen(posX, posY, posZ)
            if (playerId < 0 or playerId > 999) or (vehicleId < 0 or vehicleId > 2000) then
                -->> ATTACHED <<--
                --[[
                if playerId >= 0 and playerId <= 999 then
                    if sampIsPlayerConnected(playerId) then
                        local result, ped = sampGetCharHandleBySampPlayerId(playerId)
                        if result then
                            local newpedX, newpedY, newpedZ = getCharCoordinates(ped)
                            posX, posY, posZ = newpedX + posX, newpedY + posY, newpedZ + posZ
                        else
                            return
                        end
                    end
                end

                if vehicleId >= 0 and vehicleId <= 2000 then
                    local result, car = sampGetCarHandleBySampVehicleId(vehicleId)
                    if result then
                        local vehX, vehY, vehZ = getCarCoordinates(car)
                        posX, posY, posZ = vehX + posX, vehY + posY, vehZ + posZ
                    else
                        return
                    end
                end
                ]]
                
                -->> DRAW <<--
                if Font[s.fontsize[0]] then
                    imgui.PushFont(Font[s.fontsize[0]])
                    if isPointBehindWall(posX, posY, posZ, 0.1) and isPointOnScreen(posX, posY, posZ, 0.1) and getDistanceBetweenCoords3d(selfX, selfY, selfZ, posX, posY, posZ) <= distance then
                        for line in text:gmatch('[^\n]+') do
                            local linenohex = line:gsub('{......}', '')
                            imgui.AddTextColoredHex(DL, imgui.ImVec2(x - imgui.CalcTextSize(u8(linenohex)).x / 2, y), 0xFFffffff, line, 1, imgui.ImVec4(0, 0, 0, 0.5), s.fontsize[0], Font[s.fontsize[0]])
                            y = y + imgui.CalcTextSize(line).y + s.lineinterval[0]
                        end
                    end
                    imgui.PopFont()
                else
                    error('font was not loaded')
                end
            else
                print(text, playerId, vehicleId)
            end
        end
    end
)

local SettingsWindowFrame = imgui.OnFrame(
    function() return Window[0] end,
    function(self)
        local resX, resY = getScreenResolution()
        imgui.SetNextWindowPos(imgui.ImVec2(resX / 2, resY / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
        imgui.SetNextWindowSize(imgui.ImVec2(320, 150), imgui.Cond.FirstUseEver)
        if imgui.Begin('mim3d by chapo', Window, imgui.WindowFlags.NoResize + imgui.WindowFlags.NoCollapse) then
            imgui.PushItemWidth(150)
            if imgui.SliderInt(u8'Размер шрифта', s.fontsize, 10, 20) then save() end
            if imgui.SliderInt(u8'Межстрочный интервал', s.lineinterval, -10, 30) then save() end
            imgui.PopItemWidth()
            imgui.Text(u8'Шрифт:')
            imgui.SameLine()
            imgui.TextColored(imgui.ImVec4(0.79, 0.79, 0.79, 1), s.fontname)
            
            if imgui.IsItemClicked(0) then
                imgui.OpenPopup(u8'Выберите шрифт')
            end
            if imgui.BeginPopupModal(u8'Выберите шрифт', _, imgui.WindowFlags.NoResize) then
                imgui.SetWindowSizeVec2(imgui.ImVec2(200, 380))
                imgui.InputTextWithHint('##search', u8'Поиск', FontSearch, ffi.sizeof(FontSearch))
                imgui.SetCursorPos(imgui.ImVec2(5, 30 + 25))
                if imgui.BeginChild('list', imgui.ImVec2(190, 380 - 30 - 29 - 5 - 25), true) then
                    for _, name in ipairs(getFilesInPath(getFolderPath(0x14), '*.ttf')) do
                        if #ffi.string(FontSearch) == 0 or name:lower():find(ffi.string(FontSearch):lower()) then
                            if imgui.RadioButtonBool(name, s.fontname == name) then 
                                s.fontname = name 
                                sampAddChatMessage('[mim3d]: {ffffff}Что бы настройки шрифта вступили в силу необходимо перезагрузить скрипт!', 0xFF7738ff)
                                save()
                            end
                        end
                    end
                    imgui.EndChild()
                end
                imgui.SetCursorPos(imgui.ImVec2(5, 380 - 29))
                if imgui.Button(u8'Закрыть', imgui.ImVec2(190, 20)) then
                    save()
                    imgui.CloseCurrentPopup()
                end
                imgui.EndPopup()
            end
            imgui.SameLine()
            imgui.TextDisabled(u8'(нажмите что бы изменить)')
            imgui.SetCursorPos(imgui.ImVec2(5, 150 - 30 - 5))
            if imgui.Button(u8'Перезагрузить', imgui.ImVec2(310, 30)) then save(); thisScript():reload() end
            imgui.End()
        end
    end
)

function imgui.AddTextColoredHex(DL, pos, color, text, out, outcol, fontsize, font)
    local function explode_argb(argb)
        local a = bit.band(bit.rshift(argb, 24), 0xFF)
        local r = bit.band(bit.rshift(argb, 16), 0xFF)
        local g = bit.band(bit.rshift(argb, 8), 0xFF)
        local b = bit.band(argb, 0xFF)
        return a, r, g, b
    end
    local text = tostring(text)
    local DL = DL or imgui.GetWindowDrawList()
    local fontsize, out, outcol = fontsize or 14, out or 0, outcol or imgui.ImVec4(0, 0, 0, 0.5)
    local charIndex, lastColorCharIndex, lastColor = 0, -100, color
    if font then
        imgui.PushFont(font)
    end
    for Char in text:gmatch('.') do
        charIndex = charIndex + 1
        if Char == '{' and text:sub(charIndex + 7, charIndex + 7) == '}' then
            lastColorCharIndex, lastColor = charIndex, text:sub(charIndex + 1, charIndex + 6)
        end
        if charIndex < lastColorCharIndex or charIndex > lastColorCharIndex+7 then
            local a,r,g,b = explode_argb(type(lastColor) == 'string' and '0xFF'..lastColor or color)
            if out > 0 then
                DL:AddTextFontPtr(font, fontsize, imgui.ImVec2(pos.x + out, pos.y + out), imgui.GetColorU32Vec4(outcol), u8(Char))
                DL:AddTextFontPtr(font, fontsize, imgui.ImVec2(pos.x - out, pos.y - out), imgui.GetColorU32Vec4(outcol), u8(Char))
                DL:AddTextFontPtr(font, fontsize, imgui.ImVec2(pos.x + out, pos.y - out), imgui.GetColorU32Vec4(outcol), u8(Char))
                DL:AddTextFontPtr(font, fontsize, imgui.ImVec2(pos.x - out, pos.y + out), imgui.GetColorU32Vec4(outcol), u8(Char))
            end
            DL:AddTextFontPtr(font, fontsize, pos, imgui.GetColorU32Vec4(imgui.ImVec4(r / 255, g / 255, b / 255, 1)), u8(Char))            
            pos.x = pos.x + imgui.CalcTextSize(u8(Char)).x + (Char == ' ' and 2 or 0)
        end
    end
    if font then
        imgui.PopFont()
    end
end


function isPointBehindWall(x, y, z, rad)
    local res = false
    if isPointOnScreen(x, y, z, rad) then
        if v == PLAYER_PED then res = true end
        local xi, yi, zi = getActiveCameraCoordinates()
        local result = isLineOfSightClear(x, y, z, xi, yi, zi, true, false, false, true, false)
        res = result
    end
    return res
end

function main()
    while not isSampAvailable() do wait(0) end
    if os.clock() < 10 then
        List = {}
        print('list was reset')
    end
    sampRegisterChatCommand('mim3d', function()
        Window[0] = not Window[0]
    end)
    wait(-1)
end 

function imgui.DarkTheme()
    imgui.SwitchContext()
    --==[ STYLE ]==--
    imgui.GetStyle().WindowPadding = imgui.ImVec2(5, 5)
    imgui.GetStyle().FramePadding = imgui.ImVec2(5, 5)
    imgui.GetStyle().ItemSpacing = imgui.ImVec2(5, 5)
    imgui.GetStyle().ItemInnerSpacing = imgui.ImVec2(2, 2)
    imgui.GetStyle().TouchExtraPadding = imgui.ImVec2(0, 0)
    imgui.GetStyle().IndentSpacing = 0
    imgui.GetStyle().ScrollbarSize = 10
    imgui.GetStyle().GrabMinSize = 10

    --==[ BORDER ]==--
    imgui.GetStyle().WindowBorderSize = 0
    imgui.GetStyle().ChildBorderSize = 0
    imgui.GetStyle().PopupBorderSize = 0
    imgui.GetStyle().FrameBorderSize = 0
    imgui.GetStyle().TabBorderSize = 0

    --==[ ROUNDING ]==--
    imgui.GetStyle().WindowRounding = 5
    imgui.GetStyle().ChildRounding = 5
    imgui.GetStyle().FrameRounding = 5
    imgui.GetStyle().PopupRounding = 5
    imgui.GetStyle().ScrollbarRounding = 5
    imgui.GetStyle().GrabRounding = 5
    imgui.GetStyle().TabRounding = 5

    --==[ ALIGN ]==--
    imgui.GetStyle().WindowTitleAlign = imgui.ImVec2(0.5, 0.5)
    imgui.GetStyle().ButtonTextAlign = imgui.ImVec2(0.5, 0.5)
    imgui.GetStyle().SelectableTextAlign = imgui.ImVec2(0.5, 0.5)
    
    --==[ COLORS ]==--
    imgui.GetStyle().Colors[imgui.Col.Text]                   = imgui.ImVec4(1.00, 1.00, 1.00, 1.00)
    imgui.GetStyle().Colors[imgui.Col.TextDisabled]           = imgui.ImVec4(0.50, 0.50, 0.50, 1.00)
    imgui.GetStyle().Colors[imgui.Col.WindowBg]               = imgui.ImVec4(0.07, 0.07, 0.07, 1.00)
    imgui.GetStyle().Colors[imgui.Col.ChildBg]                = imgui.ImVec4(0.07, 0.07, 0.07, 1.00)
    imgui.GetStyle().Colors[imgui.Col.PopupBg]                = imgui.ImVec4(0.07, 0.07, 0.07, 1.00)
    imgui.GetStyle().Colors[imgui.Col.Border]                 = imgui.ImVec4(0.25, 0.25, 0.26, 0.54)
    imgui.GetStyle().Colors[imgui.Col.BorderShadow]           = imgui.ImVec4(0.00, 0.00, 0.00, 0.00)
    imgui.GetStyle().Colors[imgui.Col.FrameBg]                = imgui.ImVec4(0.12, 0.12, 0.12, 1.00)
    imgui.GetStyle().Colors[imgui.Col.FrameBgHovered]         = imgui.ImVec4(0.25, 0.25, 0.26, 1.00)
    imgui.GetStyle().Colors[imgui.Col.FrameBgActive]          = imgui.ImVec4(0.25, 0.25, 0.26, 1.00)
    imgui.GetStyle().Colors[imgui.Col.TitleBg]                = imgui.ImVec4(0.12, 0.12, 0.12, 1.00)
    imgui.GetStyle().Colors[imgui.Col.TitleBgActive]          = imgui.ImVec4(0.12, 0.12, 0.12, 1.00)
    imgui.GetStyle().Colors[imgui.Col.TitleBgCollapsed]       = imgui.ImVec4(0.12, 0.12, 0.12, 1.00)
    imgui.GetStyle().Colors[imgui.Col.MenuBarBg]              = imgui.ImVec4(0.12, 0.12, 0.12, 1.00)
    imgui.GetStyle().Colors[imgui.Col.ScrollbarBg]            = imgui.ImVec4(0.12, 0.12, 0.12, 1.00)
    imgui.GetStyle().Colors[imgui.Col.ScrollbarGrab]          = imgui.ImVec4(0.00, 0.00, 0.00, 1.00)
    imgui.GetStyle().Colors[imgui.Col.ScrollbarGrabHovered]   = imgui.ImVec4(0.41, 0.41, 0.41, 1.00)
    imgui.GetStyle().Colors[imgui.Col.ScrollbarGrabActive]    = imgui.ImVec4(0.51, 0.51, 0.51, 1.00)
    imgui.GetStyle().Colors[imgui.Col.CheckMark]              = imgui.ImVec4(1.00, 1.00, 1.00, 1.00)
    imgui.GetStyle().Colors[imgui.Col.SliderGrab]             = imgui.ImVec4(0.21, 0.20, 0.20, 1.00)
    imgui.GetStyle().Colors[imgui.Col.SliderGrabActive]       = imgui.ImVec4(0.21, 0.20, 0.20, 1.00)
    imgui.GetStyle().Colors[imgui.Col.Button]                 = imgui.ImVec4(0.12, 0.12, 0.12, 1.00)
    imgui.GetStyle().Colors[imgui.Col.ButtonHovered]          = imgui.ImVec4(0.21, 0.20, 0.20, 1.00)
    imgui.GetStyle().Colors[imgui.Col.ButtonActive]           = imgui.ImVec4(0.41, 0.41, 0.41, 1.00)
    imgui.GetStyle().Colors[imgui.Col.Header]                 = imgui.ImVec4(0.12, 0.12, 0.12, 1.00)
    imgui.GetStyle().Colors[imgui.Col.HeaderHovered]          = imgui.ImVec4(0.20, 0.20, 0.20, 1.00)
    imgui.GetStyle().Colors[imgui.Col.HeaderActive]           = imgui.ImVec4(0.47, 0.47, 0.47, 1.00)
    imgui.GetStyle().Colors[imgui.Col.Separator]              = imgui.ImVec4(0.12, 0.12, 0.12, 1.00)
    imgui.GetStyle().Colors[imgui.Col.SeparatorHovered]       = imgui.ImVec4(0.12, 0.12, 0.12, 1.00)
    imgui.GetStyle().Colors[imgui.Col.SeparatorActive]        = imgui.ImVec4(0.12, 0.12, 0.12, 1.00)
    imgui.GetStyle().Colors[imgui.Col.ResizeGrip]             = imgui.ImVec4(1.00, 1.00, 1.00, 0.25)
    imgui.GetStyle().Colors[imgui.Col.ResizeGripHovered]      = imgui.ImVec4(1.00, 1.00, 1.00, 0.67)
    imgui.GetStyle().Colors[imgui.Col.ResizeGripActive]       = imgui.ImVec4(1.00, 1.00, 1.00, 0.95)
    imgui.GetStyle().Colors[imgui.Col.Tab]                    = imgui.ImVec4(0.12, 0.12, 0.12, 1.00)
    imgui.GetStyle().Colors[imgui.Col.TabHovered]             = imgui.ImVec4(0.28, 0.28, 0.28, 1.00)
    imgui.GetStyle().Colors[imgui.Col.TabActive]              = imgui.ImVec4(0.30, 0.30, 0.30, 1.00)
    imgui.GetStyle().Colors[imgui.Col.TabUnfocused]           = imgui.ImVec4(0.07, 0.10, 0.15, 0.97)
    imgui.GetStyle().Colors[imgui.Col.TabUnfocusedActive]     = imgui.ImVec4(0.14, 0.26, 0.42, 1.00)
    imgui.GetStyle().Colors[imgui.Col.PlotLines]              = imgui.ImVec4(0.61, 0.61, 0.61, 1.00)
    imgui.GetStyle().Colors[imgui.Col.PlotLinesHovered]       = imgui.ImVec4(1.00, 0.43, 0.35, 1.00)
    imgui.GetStyle().Colors[imgui.Col.PlotHistogram]          = imgui.ImVec4(0.90, 0.70, 0.00, 1.00)
    imgui.GetStyle().Colors[imgui.Col.PlotHistogramHovered]   = imgui.ImVec4(1.00, 0.60, 0.00, 1.00)
    imgui.GetStyle().Colors[imgui.Col.TextSelectedBg]         = imgui.ImVec4(1.00, 0.00, 0.00, 0.35)
    imgui.GetStyle().Colors[imgui.Col.DragDropTarget]         = imgui.ImVec4(1.00, 1.00, 0.00, 0.90)
    imgui.GetStyle().Colors[imgui.Col.NavHighlight]           = imgui.ImVec4(0.26, 0.59, 0.98, 1.00)
    imgui.GetStyle().Colors[imgui.Col.NavWindowingHighlight]  = imgui.ImVec4(1.00, 1.00, 1.00, 0.70)
    imgui.GetStyle().Colors[imgui.Col.NavWindowingDimBg]      = imgui.ImVec4(0.80, 0.80, 0.80, 0.20)
    imgui.GetStyle().Colors[imgui.Col.ModalWindowDimBg]       = imgui.ImVec4(0.00, 0.00, 0.00, 0.70)
end