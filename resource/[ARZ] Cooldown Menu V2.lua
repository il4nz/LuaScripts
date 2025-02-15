script_properties('work-in-pause')

local imgui = require('imgui')
local encoding = require 'encoding'
encoding.default = 'CP1251'
u8 = encoding.UTF8
local fa = require 'faIcons'
local fa_font = require 'faIcons'
local sampev = require 'lib.samp.events'
local inicfg = require 'inicfg'

local window = imgui.ImBool(false)
local fa_font = nil
local fa_glyph_ranges = imgui.ImGlyphRanges({ fa.min_range, fa.max_range })

local shown = false

local directIni = 'cooldownmenu.ini'
local ini = inicfg.load(inicfg.load({
    pos = {
        x = 5,
        y = select(2, getScreenResolution()) / 2 - 20 / 2,
    },
    settings = {
        masktime = 600,
        showNotify = true,
        notifyTime = 1000,
    }
}, directIni))
inicfg.save(ini, directIni)

local currentPos = {ini.pos.x, ini.pos.y}

local notf = imgui.ImBool(false)

local time_armour = 0
local time_report = 0
local time_mask = 0
local time_use = 0
local time_drugs = 0
local time_cartools = 10 

local progressTime = 0.0
local notfText = ''
local notifyTime = ini.settings.notifyTime

--время (в секундах)
local totime_armour =   60
local totime_mask =     ini.settings.masktime
local totime_report =   180
local totime_drugs =    7
local totime_cartools = 10

local tag = '{ff004d}Cooldown menu: {ffffff}'

function main()
    while not isSampAvailable() do wait(200) end
    imgui.Process = false
    window.v = false  --show window
    notf.v = false
    sampRegisterChatCommand('cd.notf', showNotf)
    sampRegisterChatCommand('cd.mintosec', function(arg)
        if #arg ~= 0 then
            sampAddChatMessage(tag..arg..' минут = '..tostring(tonumber(arg) * 60)..' секунд', -1)
        else
            sampAddChatMessage(tag..'используй "/cd.mintosec [минуты]"', -1)
        end
    end)
    sampRegisterChatCommand('cd.help', function()
        sampAddChatMessage(tag, -1)
        sampAddChatMessage(' {ff004d}/cd.masktime [секунды]{ffffff} - установить время действия маски', -1)
        sampAddChatMessage(' {ff004d}/cd.test{ffffff} - открыть меню для теста скрипта', -1)
        sampAddChatMessage(' {ff004d}/cd.notf [текст]{ffffff} - показать тестовое уведомление с заданным текстом', -1)
        sampAddChatMessage(' {ff004d}/cd.mintosec [минуты]{ffffff} - перевести минуты в секунды', -1)
        
    end)

    

    sampRegisterChatCommand('cd.masktime', function(arg) 
        if #arg ~= 0 then
            
            sampAddChatMessage(tag..'время действия маски изменено с {ff004d}'..totime_mask..'{ffffff} на {ff004d}'..tostring(arg)..'{ffffff} секунд', -1)
            totime_mask = tonumber(arg)
            save()
        else
            sampAddChatMessage(tag..'используй "/cd.masktime [секунды]"', -1)
            
        end
        
    end)
    sampRegisterChatCommand('cd.test', function()
        sampShowDialog(8, 'Cooldown menu test (FOR HMS)', 'Armour +\nArmour-\nMask+\nMask-\nReport\nDrugs', 'ok', 'close', 2)
    end)
    while true do
        wait(0)
        if window.v or notf.v then imgui.Process = true else imgui.Process = false end
        if time_armour ~= 0 or time_report ~= 0 or time_mask ~= 0 or time_drugs ~= 0 then window.v = true else window.v = false end

        --TEST DIALOG
        result, button, list, input = sampHasDialogRespond(8)
        if result then
            if button == 1 then
                if list == 0 then
                    sampSendChat('/c Вы надели бронежилет. Используйте /armour чтобы снять его или надеть ещё раз.')
                elseif list == 1 then
                    time_armour = 0
                    sampSendChat('/c Вы сняли бронежилет!')
                elseif list == 2 then
                    sampSendChat('/c Вы успешно надели маску.')
                elseif list == 3 then
                    time_mask = 0
                    sampSendChat('/c Вы успешно выкинули маску.')
                elseif list == 4 then
                    time_report = 0
                    sampSendChat('/c Вы отправили жалобу:')
                elseif list == 5 then
                    time_drugs = 0
                    sampSendChat('/usedrugs 1')
                end
            end
        end
    end
    window.v = true
end

function imgui.BeforeDrawFrame()
    if fa_font == nil then
      local font_config = imgui.ImFontConfig() -- to use 'imgui.ImFontConfig.new()' on error
      font_config.MergeMode = true
  
      fa_font = imgui.GetIO().Fonts:AddFontFromFileTTF('moonloader/resource/fonts/fontawesome-webfont.ttf', 14.0, font_config, fa_glyph_ranges)
    end
end

function imgui.OnDrawFrame()
    resX, resY = getScreenResolution()
    if window.v then
        yperone = 25 --высота одной строки  
        
        sizeX, sizeY = 110, 20
        --govnocode
        if time_armour ~= 0 then 
            sizeY = sizeY + yperone
        end
        if time_report ~= 0 then 
            sizeY = sizeY + yperone
        end
        if time_mask ~= 0 then 
            sizeY = sizeY + yperone
        end
        if time_drugs ~= 0 then
            sizeY = sizeY + yperone
        end
        --print(sizeY)
        imgui.SetNextWindowPos(imgui.ImVec2(ini.pos.x, ini.pos.y), imgui.Cond.FirstUseEver)
        imgui.SetNextWindowSize(imgui.ImVec2(sizeX, sizeY), imgui.Cond.Always)
        imgui.Begin('Window Title', window, imgui.WindowFlags.NoTitleBar + imgui.WindowFlags.NoResize)

        curpos = imgui.GetWindowPos()
        currentPos[1], currentPos[2] = curpos.x, curpos.y

        imgui.ShowCursor = false

        imgui.CenterTextColoredRGB('{ff004d}Cooldowns')

        imgui.Separator()

        if time_armour ~= 0 then
            imgui.SetCursorPosX(5)
            imgui.Text(fa.ICON_USER)

            imgui.SameLine()
            
            imgui.SetCursorPosX(25)
            imgui.Text('Armour:')

            imgui.SameLine()
            
            imgui.SetCursorPosX(75)
            imgui.Text(tostring(time_armour))

            if time_armour == 1 then
                showNotf('Ты снова можешь юзать армор')
            end           
        end

        if time_drugs ~= 0 then
            imgui.SetCursorPosX(5)
            imgui.Text(fa.ICON_SNOWFLAKE_O)

            imgui.SameLine()
            
            imgui.SetCursorPosX(25)
            imgui.Text('Drugs:')

            imgui.SameLine()
            
            imgui.SetCursorPosX(75)
            imgui.Text(tostring(time_drugs))

            if time_drugs == 1 then
                showNotf('Ты снова можешь юзать нарко')
            end           
        end

        

        if time_report ~= 0 then
            imgui.SetCursorPosX(5)
            imgui.Text(fa.ICON_WEIXIN)

            imgui.SameLine()
            
            imgui.SetCursorPosX(25)
            imgui.Text('Report:')

            imgui.SameLine()
            
            imgui.SetCursorPosX(75)
            imgui.Text(tostring(time_report))

            if time_report == 1 then
                --print('rep == 1')
                showNotf('Ты снова можешь писать в репорт')
            end
        end

        if time_mask ~= 0 then
            imgui.SetCursorPosX(5)
            imgui.Text(fa.ICON_USER_SECRET)

            imgui.SameLine()
            
            imgui.SetCursorPosX(25)
            imgui.Text('Mask:')

            imgui.SameLine()
            
            imgui.SetCursorPosX(75)
            imgui.Text(tostring(time_mask))

            if time_mask == 1 then
                showNotf('Маска снята')
            end
        end


        
        imgui.End()
    end

    if notf.v then
        notfSizeX, notfSizeY = 250, 75
        notfOffsetX, notfOffsetY = 0, 300
        imgui.SetNextWindowPos(imgui.ImVec2(resX / 2 - notfSizeX / 2 + notfOffsetX, resY / 2 - notfSizeY / 2 + notfOffsetY), imgui.Cond.FirstUseEver)
        imgui.SetNextWindowSize(imgui.ImVec2(notfSizeX, notfSizeY), imgui.Cond.Always)
        imgui.Begin('Window Tiasdtle', notf, imgui.WindowFlags.NoTitleBar + imgui.WindowFlags.NoResize)

        imgui.SetCursorPosY(20)
        imgui.CenterTextColoredRGB(notfText)
        imgui.SetCursorPos(imgui.ImVec2(5, notfSizeY - 20))

        imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(0, 0, 0, 1))
        imgui.PushStyleColor(imgui.Col.FrameBg, imgui.ImVec4(0, 0, 0, 1))
        imgui.PushStyleColor(imgui.Col.PlotHistogram, imgui.ImVec4(1, 0, 0.3, 1))
        imgui.ProgressBar(progressTime, imgui.ImVec2(notfSizeX - 10, 15))
        imgui.PopStyleColor(3)

        imgui.End()
    end   
end

function showNotf(text)
    notifyTime = notifyTime + 1
    notf.v = true
    notfText = text
    
    lua_thread.create(function()
        if not shown then
            shown = true
            for i = 0, 1, 0.01 do
                if progressTime < 0.98 then 
                    progressTime = i 
                    --print(progressTime..'dsfas')
                    wait(10)
                else
                    shown = false
                    progressTime = 0
                    notf.v = false
                    print(tag..'notify hidden!')
                    break
                end
            end
        end
    end)
end

function sampev.onServerMessage(color, text)

        
        --ARMOUR
        if text:find('Вы надели бронежилет. Используйте /armour чтобы снять его или надеть ещё раз.') then
            time_armour = 0
        elseif text:find('Вы сняли бронежилет!') then
            time_armour = totime_armour 
            lua_thread.create(function()
                for i = totime_armour, 0, -1 do
                    if i ~= 0 then
                        time_armour = i
                        wait(1000)
                    else
                        
                        time_armour = 0
                        break
                        --showNotf('Ты снова можешь юзать армор')
                    end
                end
            end)
           
        end

        --MASK
        if text:find('Вы успешно надели маску.') then
            --sampAddChatMessage('cooldown debug mask on', -1)
            time_mask = totime_mask
            lua_thread.create(function()
                for i = totime_mask, 0, -1 do
                    if time_mask ~= 0 then
                        time_mask = i
                        wait(1000)
                    else
                        time_mask = 0
                        break
                       
                        
                    end
                end
            end)
            
        elseif text:find('Вы успешно выкинули маску.') then
            time_mask = 0
            showNotf('Маска снята')
        end
        
        --REPORT
        if text:find('You have sent a complaint:') then
            time_report = totime_report
            lua_thread.create(function()
                for i = totime_report, 0, -1 do
                    if i ~= 0 then
                        time_report = i
                        wait(1000)
                        --sampAddChatMessage('rep = '..i, -1)
                    else
                        time_report = 0 
                        break
                        
                        
                        --showNotf('Ты снова можешь писать в репорт!')
                        
                    end
                end
            end)
            
        end
    
end

function sampev.onSendCommand(text)
        if text:find('/usedrugs') then
            time_drugs = totime_drugs
            lua_thread.create(function()
                for i = totime_drugs, 0, -1 do
                    if time_drugs ~= 0 then
                        time_drugs = i
                        wait(1000)
                    else
                        break
                        time_drugs = 0
                    end
                end
            end)
            
        end
    
end

function save()
    ini.pos.x = currentPos[1]
    ini.pos.y = currentPos[2]
    ini.settings.masktime = tonumber(totime_mask)
    inicfg.save(ini, directIni)
end

function onScriptTerminate(s, q)
    if s == thisScript() then
        save()
    end
end

function imgui.CenterTextColoredRGB(text)
    local width = imgui.GetWindowWidth()
    local style = imgui.GetStyle()
    local colors = style.Colors
    local ImVec4 = imgui.ImVec4

    local explode_argb = function(argb)
        local a = bit.band(bit.rshift(argb, 24), 0xFF)
        local r = bit.band(bit.rshift(argb, 16), 0xFF)
        local g = bit.band(bit.rshift(argb, 8), 0xFF)
        local b = bit.band(argb, 0xFF)
        return a, r, g, b
    end

    local getcolor = function(color)
        if color:sub(1, 6):upper() == 'SSSSSS' then
            local r, g, b = colors[1].x, colors[1].y, colors[1].z
            local a = tonumber(color:sub(7, 8), 16) or colors[1].w * 255
            return ImVec4(r, g, b, a / 255)
        end
        local color = type(color) == 'string' and tonumber(color, 16) or color
        if type(color) ~= 'number' then return end
        local r, g, b, a = explode_argb(color)
        return imgui.ImColor(r, g, b, a):GetVec4()
    end

    local render_text = function(text_)
        for w in text_:gmatch('[^\r\n]+') do
            local textsize = w:gsub('{.-}', '')
            local text_width = imgui.CalcTextSize(u8(textsize))
            imgui.SetCursorPosX( width / 2 - text_width .x / 2 )
            local text, colors_, m = {}, {}, 1
            w = w:gsub('{(......)}', '{%1FF}')
            while w:find('{........}') do
                local n, k = w:find('{........}')
                local color = getcolor(w:sub(n + 1, k - 1))
                if color then
                    text[#text], text[#text + 1] = w:sub(m, n - 1), w:sub(k + 1, #w)
                    colors_[#colors_ + 1] = color
                    m = n
                end
                w = w:sub(1, n - 1) .. w:sub(k + 1, #w)
            end
            if text[0] then
                for i = 0, #text do
                    imgui.TextColored(colors_[i] or colors[1], u8(text[i]))
                    imgui.SameLine(nil, 0)
                end
                imgui.NewLine()
            else
                imgui.Text(u8(w))
            end
        end
    end
    render_text(text)
end