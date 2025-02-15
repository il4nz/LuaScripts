script_name('Medz - OpenAI Auto Answer (v2)')
script_author('chapo')
script_url('https://blast.hk/threads/164336/')

local ffi = require('ffi')
local effil = require('effil')
local imgui = require('mimgui')
local faicons = require('fAwesome6')
local encoding = require('encoding')
encoding.default = 'CP1251'
u8 = encoding.UTF8
local inicfg = require('inicfg')
local sampev = require "lib.samp.events"
local directIni = 'Medztest.ini'
local ini = inicfg.load(inicfg.load({
    main = {
        model = 1,
        token = '',
        enabled = true,
        react_b = true,
        top_p = 1,
        temperature = 0.5,
        frequency_penalty = 0.5,
        presence_penalty = 0,
        max_tokens = 80,
        delayBeforeAnswer_min = 150,
        delayBeforeAnswer_max = 500,
        telegram_token = '',
        telegram_enabled = false,
        telegram_chatid = '',
        telegram_send_on_question = true,
        telegram_send_on_answer = true,
    },
    
    chat = {
        [1] = 'Test',
        [2] = 'Test2',
        [3] = 'Test3'
    }
}, directIni))
inicfg.save(ini, directIni)

local renderWindow = imgui.new.bool(false)

imgui.OnInitialize(function()
    imgx = imgui.CreateTextureFromFile(getWorkingDirectory() .. "/config/Medz/Medzlogo2.png")
    imgui.DarkTheme()
    imgui.GetIO().IniFilename = nil
    local config = imgui.ImFontConfig()
    config.MergeMode = true
    config.PixelSnapH = true
    iconRanges = imgui.new.ImWchar[3](faicons.min_range, faicons.max_range, 0)
    imgui.GetIO().Fonts:AddFontFromMemoryCompressedBase85TTF(faicons.get_font_data_base85('solid'), 14, config, iconRanges) -- solid - тип иконок, так же есть thin, regular, light и duotone
end)
local navigation = {
    current = 1,
    list = { faicons('sliders')..u8' Basic', faicons('gear')..u8' Other'}
}
log = function(...) print('[ANSAI - OpenAI Auto Answer by chapo]', table.concat({...}, '\t')) end
local patterns = { chat = {}, dialog = {} }
for section, items in pairs(patterns) do
    if ini[section] then
        for index, value in pairs(ini[section]) do
            table.insert(patterns[section], imgui.new.char[128](u8(value)))
        end
    end
end


local S = {
    model = imgui.new.int(ini.main.model),
    token = imgui.new.char[256](ini.main.token),
    enabled = imgui.new.bool(ini.main.enabled),
    react_b = imgui.new.bool(ini.main.react_b),
    top_p = imgui.new.float(ini.main.top_p),
    temperature = imgui.new.float(ini.main.temperature),
    frequency_penalty = imgui.new.float(ini.main.frequency_penalty),
    presence_penalty = imgui.new.float(ini.main.presence_penalty),
    max_tokens = imgui.new.int(ini.main.max_tokens),
    delayBeforeAnswer_min = imgui.new.int(ini.main.delayBeforeAnswer_min),
    delayBeforeAnswer_max = imgui.new.int(ini.main.delayBeforeAnswer_max),
    telegram_token = imgui.new.char[256](ini.main.telegram_token),
    telegram_enabled = imgui.new.bool(ini.main.telegram_enabled),
    telegram_chatid = imgui.new.char[256](tostring(ini.main.telegram_chatid)),
    telegram_send_on_question = imgui.new.bool(ini.main.telegram_send_on_question),
    telegram_send_on_answer = imgui.new.bool(ini.main.telegram_send_on_answer),
}
local showToken = false
function encodeUrl(str)
    str = str:gsub(' ', '%+')
    str = str:gsub('\n', '%%0A')
    return u8:encode(str, 'CP1251')
end


-- function sendTelegramNotification(msg)
--     if S.telegram_enabled[0] and #ffi.string(S.telegram_token) > 0 and #ffi.string(S.telegram_chatid) > 0 then
--         --local msg = msg:gsub('{......}', '')
--         --local msg = msg:gsub(' ', '%+')
--         --local msg = msg:gsub('\n', '%%0A')
--         --local msg = msg:gsub('\\x', '%')
--         local msg = encodeUrl(msg)
--         asyncHttpRequest('POST', 'https://api.telegram.org/bot' .. ffi.string(S.telegram_token) .. '/sendMessage?chat_id=' .. ffi.string(S.telegram_chatid) .. '&text=' .. msg, 
--             nil, 
--             function(result) 
--                 log(result.status_code == 200 and '[TELEGRAM] Message sended!' or '[TELEGRAM] Error sending notification, code:', result.status_code)
--             end, 
--             function(err) 
--                 log('[TELEGRAM] Error sending notification:', err)
--             end
--         )
--         log('[TELEGRAM] Sending "'..msg..'"')
        
--     else
--         log('not cond')
--     end
-- end


function save()
    ini.main.password = ffi.string(S.token)
    inicfg.save(ini, directIni)
end

local newFrame = imgui.OnFrame(
    function() return renderWindow[0] end,
    function(self)
        local res, size = imgui.ImVec2(getScreenResolution()), imgui.ImVec2(600, 400)
        imgui.SetNextWindowPos(imgui.ImVec2(res.x / 2, res.y / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
        imgui.SetNextWindowSize(size, imgui.Cond.FirstUseEver)
        if imgui.Begin('ANSAI v2', renderWindow, imgui.WindowFlags.NoResize + imgui.WindowFlags.NoTitleBar) then

            imgui.Image(imgx, imgui.ImVec2(120, 40))
            imgui.SameLine()
            imgui.SetCursorPosY(imgui.GetCursorPosY() + 10)
            for i, title in ipairs(navigation.list) do
                if HeaderButton(navigation.current == i, title) then navigation.current = i end
                if i ~= #navigation.list then imgui.SameLine(nil, 20) end
            end

            imgui.SetCursorPos(imgui.ImVec2(size.x - 40, 10))
            if imgui.Button(faicons('XMARK'), imgui.ImVec2(30, 30)) then
                save()
                renderWindow[0] = false
            end
            imgui.SetCursorPos(imgui.ImVec2(size.x - 40 - 30 - 10, 10))
            if imgui.Button(faicons('floppy_disk'), imgui.ImVec2(30, 30)) then
                save()
                sampAddChatMessage('ANSAI >> {ffffff}All settings saved!!', 0xFF623bff)
            end
            imgui.Hint('save', u8'Save all settings')

            imgui.SetCursorPos(imgui.ImVec2(10, 50))
            if imgui.BeginChild('main', imgui.ImVec2(size.x - 20, size.y - 50 - 10), true) then
                local csize = imgui.GetWindowSize()
                if navigation.current == 1 then
                    imgui.Separator()
                    imgui.Spacing()
                    if imgui.ToggleButton(u8' Wallhack Off', u8' WallHack On ', S.enabled, 0.25) then
                            sampAddChatMessage('Test!', -1)

                    end
                    
                    imgui.SameLine(320)
                    imgui.PushItemWidth(150)
                    imgui.SliderInt(faicons('text_width')..u8' Max. length', S.max_tokens, 10, 128)
                    imgui.Hint('hint_max_tokens', u8'Max. number of characters')
                    imgui.PopItemWidth()

                    imgui.BetterInput('s_token', faicons('key')..u8' Password', showToken and 0 or imgui.InputTextFlags.Password, S.token, nil, nil, size.x - 50)
                    imgui.SameLine()
                    if imgui.Button(faicons(showToken and 'eye_slash' or 'eye'), imgui.ImVec2(24, 24)) then showToken = not showToken end
                    
                    
                    

                    imgui.Text(u8'Generation model:')

                    imgui.NewLine()

                    imgui.PushItemWidth(150)
                    imgui.SliderFloat(faicons('cubes')..u8' Diversity', S.top_p, 0, 1)
                    imgui.Hint('hint_top_p', u8'controls for diversity using 0.5 me kernel sampling and considers half of all variants, weighted by degree of similarity')
                    imgui.SameLine(320)
                    imgui.SliderFloat(faicons('shuffle')..u8' Accident', S.temperature, 0, 1)
                    imgui.Hint('hint_temperature', u8'контролирует случайность: снижение приводит к менее случайным завершениям.\nПо мере приближения температуры к нулю модель становится детерминированной и повторяющейся;')
                
                    imgui.SliderFloat(faicons('repeat')..u8' Повтор строк', S.frequency_penalty, 0, 2)
                    imgui.Hint('hint_frequency_penalty', u8'сколько штрафовать за новые токены, основываясь на их существующей частоте в tet на данный момент.\nУменьшает вероятность того, что модели будут повторять одну и ту же строку дословно')
                    imgui.SameLine(320)
                    imgui.SliderFloat(faicons('sparkles')..u8' Новые темы', S.presence_penalty, 0, 2)
                    imgui.Hint('hint_presence_penalty', u8'сколько штрафовать за новые токены, исходя из того, появляются ли они в тексте до сих пор.\nУвеличивает вероятность того, что модель расскажет о новых темах')

                    imgui.PopItemWidth()
                elseif navigation.current == 2 then
                    
                   
                    
                    imgui.NewLine()
                    imgui.Text(faicons('bell')..u8' Notifications in Telegram:')
                    
                    imgui.ToggleButton(u8'Отправлять уведомления в Telegram', u8'Отправлять уведомления в Telegram', S.telegram_enabled, 0.25)
                    imgui.BetterInput('telegram_token', faicons('robot')..u8' Токен Telegram бота', 0, S.telegram_token, nil, nil, 260)
                    imgui.BetterInput('telegram_chatid', faicons('user')..u8' Ваш ChatID', 0, S.telegram_chatid, nil, nil, 260)
                    imgui.Spacing()
                    imgui.Text(faicons('bell')..u8' Отправлять уведомления при:')
                    imgui.ToggleButton(u8'Срабатывании триггера', u8'Срабатывании триггера', S.telegram_send_on_question, 0.25)
                    imgui.ToggleButton(u8'Отправке ответа от ИИ', u8'Отправке ответа от ИИ', S.telegram_send_on_answer, 0.25)
                    imgui.PopItemWidth()
                    if imgui.Button(u8'Отправить тестовое уведомление') then
                        sampAddChatMessage('send', -1)
                    end
                    
                    imgui.NewLine()
                    imgui.Text(u8'Шаблоны сообщений:')
                    imgui.TextWrapped(u8'Здесь вы можете написать свой паттерн для сообщения от администраторов. Для написания необходимо вписать регулярное выражение. ВНИМАНИЕ: в тексте не должно быть цветовых кодов ( например: {ffffff}, {ff004d}, {000000} и тд )')
                    --imgui.Link('https://www.blast.hk/threads/62661/', u8'Гайд по регулярным выражениям')
                    if imgui.Button(u8'Set up patterns (message templates)', imgui.ImVec2(size.x - 10, 24)) then
                        imgui.OpenPopup(u8'ANSAI by chapo - setting up patterns')
                    end

                    imgui.SetCursorPos(imgui.ImVec2(320, 0))
                    if imgui.BeginChild('freezezone', imgui.ImVec2(300, 65), true) then
                        imgui.Text(faicons('hand')..u8' Задержка перед заморозкой:')
                        imgui.PushItemWidth(150)
                        imgui.SliderInt(u8'минимальная (мс)', S.delayBeforeAnswer_min, 0, 10000)
                        imgui.SliderInt(u8'максимальная (мс)', S.delayBeforeAnswer_max, 0, 10000)
                        imgui.EndChild()
                    end

                    imgui.PushStyleColor(imgui.Col.PopupBg, imgui.ImVec4(0.09, 0.09, 0.09, 1))
                    imgui.PushStyleColor(imgui.Col.ChildBg, imgui.ImVec4(0.11, 0.11, 0.11, 0.5))
                    
                    if imgui.BeginPopupModal(u8'ANSAI by chapo - настройка паттернов', nil, imgui.WindowFlags.NoResize) then
                        local source = patternsTab == 0 and 'dialog' or 'chat'
                            
                        local size = imgui.ImVec2(600, 600)
                        imgui.SetWindowSizeVec2(size)
                        imgui.SetCursorPosX(5)
                        if imgui.Button(u8'Диалоги', imgui.ImVec2((size.x - 15) / 2, 30)) then patternsTab = 0 end
                        imgui.SameLine()
                        imgui.SetCursorPosX(5 + (size.x - 15) / 2 + 5)
                        if imgui.Button(u8'Чат', imgui.ImVec2((size.x - 15) / 2, 30)) then patternsTab = 1 end
                        
                        
                        imgui.SetCursorPosX(5)
                        if imgui.Button(u8'Добавить новый паттерн', imgui.ImVec2(size.x - 10, 24)) then
                            table.insert(patterns[source], imgui.new.char[128](u8'Сообщение от администратора: (.+)'))
                        end
                        
                        imgui.SetCursorPosX(5)--imgui.ImVec2(5, ))
                        if imgui.BeginChild('aeoruijhgnb', imgui.ImVec2(size.x - 10, size.y - imgui.GetCursorPosY() - 10 - 30), true) then
                            for index, value in ipairs(patterns[source]) do
                                imgui.Button(tostring(index)..'##itemindexbtn', imgui.ImVec2(24, 24))
                                imgui.SameLine()
                                imgui.PushItemWidth(size.x - 10 - 24 - 10 - 24)
                                imgui.InputText('##custom_pattern_item_'..tostring(index), value, ffi.sizeof(value))
                                imgui.PopItemWidth()
                                imgui.SameLine()
                                if imgui.Button('X##removepatternbutton'..tostring(index), imgui.ImVec2(24, 24)) then
                                    table.remove(patterns[source], index)
                                end
                            end
                            imgui.EndChild() 
                        end
                        imgui.SetCursorPos(imgui.ImVec2(5, size.y - 33))
                        if imgui.Button(u8'Закрыть', imgui.ImVec2(size.x - 10, 25)) then
                            imgui.CloseCurrentPopup()
                        end
                        imgui.EndPopup()
                    end
                    imgui.PopStyleColor(2)
                end
            
                end
            imgui.End()
        end
    end
)

-->> MAIN


addEventHandler('onSendRpc', function(id, bs)
    if id == 25 then
        sampAddChatMessage('Medz >> {ffffff}OpenAI Auto Answer Loaded!', 0xFF623bff)
    elseif id == 50 then
        local cmd_len = raknetBitStreamReadInt32(bs)
        local cmd_text = raknetBitStreamReadString(bs, cmd_len)
        if cmd_text == '/medz' then
            save()
            renderWindow[0] = not renderWindow[0]
            return false
        end
    end
end)

addEventHandler('onReceiveRpc', function(id, bs) 
    if S.enabled[0] then
        if id == 93 then
            local color = raknetBitStreamReadInt32(bs)
            local len = raknetBitStreamReadInt32(bs)
            local text = raknetBitStreamReadString(bs, len)
            processText(text, patterns.chat)
        elseif id == 61 then
            local dialog = {
                id = raknetBitStreamReadInt16(bs),
                style = raknetBitStreamReadInt8(bs),
                title = raknetBitStreamReadString(bs, raknetBitStreamReadInt8(bs)),
                button1 = raknetBitStreamReadString(bs, raknetBitStreamReadInt8(bs)),
                button2 = raknetBitStreamReadString(bs, raknetBitStreamReadInt8(bs)),
                text = raknetBitStreamDecodeString(bs, 4096)
            }
            processText(dialog.text, patterns.dialog)
        end
    end
end)

addEventHandler('onScriptTerminate', function(scr, quit)
    if scr == thisScript() then
        setPlayerControl(Player, true)
    end
end)

function all_trim(s)
    return s:match( "^%s*(.-)%s*$" )
end

function str_find(STR, REGEX, REGEXINDEX)
    local status, result = pcall(string.find, STR, REGEX)
    if not status then
        sampAddChatMessage('ANSAI >> {ffffff}Ошибка, паттерн #'..REGEXINDEX..' составлен неверно!', 0xFF623bff)
        log('PATTERN ERROR:', result, 'PATTERN='..REGEX)
        return false
    end
    return result
end

function processText(text, patternsList)
    -- да я ебал этот ваш асинк реквест и эти ваши потоки
    for i, regex in ipairs(patternsList) do
        local regex = u8:decode(ffi.string(regex) or '')
        local text = text:gsub('{......}', '')
        local regex = regex:gsub('{......}', '')
        if str_find(text, regex, i) then
            local prompt = text:match(regex)
            if prompt then
                lua_thread.create(function()
                    if not dontFreeze then 
                        math.randomseed(os.time() * math.random(99, 9999))
                        local rand = math.random(S.delayBeforeAnswer_min[0] or 0, S.delayBeforeAnswer_max[0] or 0)
                        log('wait = ', rand, 'ms.')
                        wait(rand)
                        setPlayerControl(Player, false)
                        log('frozen')
                    end
                end)
                OpenAI_Generate(prompt)
            else
                log('pattern found, but prompt is nil', -1)
            end
        end
    end
end

-- function OpenAI_Generate(prompt, dontFreeze, customCallback)
--     log('sending request to OpenAI, prompt:', prompt)
--     asyncHttpRequest('POST', 'https://api.openai.com/v1/completions', {
--             headers = {
--                 ['Authorization'] = 'Bearer '..ffi.string(S.token), 
--                 ['Content-Type'] = 'application/json'
--             }, 
--             data = encodeJson({
--                 ["model"] = models[S.model[0]][1],
--                 ["prompt"] = prompt,
--                 ["temperature"] = S.temperature[0],
--                 ["max_tokens"] = S.max_tokens[0],
--                 ["top_p"] = S.top_p[0],
--                 ["frequency_penalty"] = S.frequency_penalty[0],
--                 ["presence_penalty"] = S.presence_penalty[0],
--                 ["stop"] = {"You:"}
--             })
--         },
--         function(response) 
--             if response.status_code == 200 then
--                 local RESULT = decodeJson(response.text)
--                 if RESULT.choices and #RESULT.choices > 0 then
--                     log(RESULT.choices[1].text)
--                     local text = all_trim(u8:decode(RESULT.choices[1].text))
--                     if customCallback then
--                         customCallback(text)
--                     else
--                         sampSendChat(text)
--                     end
--                 else
--                     log('[ERROR(200)]: no "choices" in result.')
--                     sampAddChatMessage('ANSAI >> {ffffff}ошибка, сервер не вернул ни одного варианта ответа', 0xFF623bff)
--                 end
--             else
--                 log('[ERROR(!200)]: code '..response.status_code)
--                 sampAddChatMessage('ANSAI >> {ffffff}error, http code: '..response.status_code, 0xFF623bff)
--             end
--             wait(100)
--             --столицей какой страны является Москва?
--             setPlayerControl(Player, true)
--         end,
--         function(err) 
--             log('[ERROR]:', err) 
--             wait(100)
--             sampAddChatMessage('ANSAI >> ошибка: '..err, -1)
--             setPlayerControl(Player, true)
--         end
--     )
    
-- end

-- function asyncHttpRequest(method, url, args, resolve, reject)
--     local request_thread = effil.thread(function (method, url, args)
--         local requests = require 'requests'
--         local result, response = pcall(requests.request, method, url, args)
--         if result then
--             response.json, response.xml = nil, nil
--             return true, response
--         else
--             return false, response
--         end
--     end)(method, url, args)
--     -- Если запрос без функций обработки ответа и ошибок.
--     if not resolve then resolve = function() end end
--     if not reject then reject = function() end end
--     -- Проверка выполнения потока
--     lua_thread.create(function()
--         local runner = request_thread
--         while true do
--             local status, err = runner:status()
--             if not err then
--                 if status == 'completed' then
--                     local result, response = runner:get()
--                     if result then
--                         resolve(response)
--                     else
--                         reject(response)
--                     end
--                     return
--                 elseif status == 'canceled' then
--                     return reject(status)
--                 end
--             else
--                 return reject(err)
--             end
--             wait(0)
--         end
--     end)
-- end

function main()
    while not isSampAvailable() do wait(0) end
    wait(-1)
end

--// utils
HeaderButton = function(bool, str_id)
    local DL = imgui.GetWindowDrawList()
    local ToU32 = imgui.ColorConvertFloat4ToU32
    local result = false
    local label = string.gsub(str_id, "##.*$", "")
    local duration = { 0.5, 0.3 }
    local cols = {
        idle = imgui.GetStyle().Colors[imgui.Col.Text],--TextDisabled],
        hovr = imgui.GetStyle().Colors[imgui.Col.Text],
        slct = imgui.GetStyle().Colors[imgui.Col.ButtonActive]
    }

    if not AI_HEADERBUT then AI_HEADERBUT = {} end
     if not AI_HEADERBUT[str_id] then
        AI_HEADERBUT[str_id] = {
            color = bool and cols.slct or cols.idle,
            clock = os.clock() + duration[1],
            h = {
                state = bool,
                alpha = bool and 1.00 or 0.00,
                clock = os.clock() + duration[2],
            }
        }
    end
    local pool = AI_HEADERBUT[str_id]

    local degrade = function(before, after, start_time, duration)
        local result = before
        local timer = os.clock() - start_time
        if timer >= 0.00 then
            local offs = {
                x = after.x - before.x,
                y = after.y - before.y,
                z = after.z - before.z,
                w = after.w - before.w
            }

            result.x = result.x + ( (offs.x / duration) * timer )
            result.y = result.y + ( (offs.y / duration) * timer )
            result.z = result.z + ( (offs.z / duration) * timer )
            result.w = result.w + ( (offs.w / duration) * timer )
        end
        return result
    end

    local pushFloatTo = function(p1, p2, clock, duration)
        local result = p1
        local timer = os.clock() - clock
        if timer >= 0.00 then
            local offs = p2 - p1
            result = result + ((offs / duration) * timer)
        end
        return result
    end

    local set_alpha = function(color, alpha)
        return imgui.ImVec4(color.x, color.y, color.z, alpha or 1.00)
    end

    imgui.BeginGroup()
        local pos = imgui.GetCursorPos()
        local p = imgui.GetCursorScreenPos()
      
        imgui.TextColored(pool.color, label)
        local s = imgui.GetItemRectSize()
        local hovered = imgui.IsItemHovered()
        local clicked = imgui.IsItemClicked()
      
        if pool.h.state ~= hovered and not bool then
            pool.h.state = hovered
            pool.h.clock = os.clock()
        end
      
        if clicked then
            pool.clock = os.clock()
            result = true
        end

        if os.clock() - pool.clock <= duration[1] then
            pool.color = degrade(
                imgui.ImVec4(pool.color),
                bool and cols.slct or (hovered and cols.hovr or cols.idle),
                pool.clock,
                duration[1]
            )
        else
            pool.color = bool and cols.slct or (hovered and cols.hovr or cols.idle)
        end

        if pool.h.clock ~= nil then
            if os.clock() - pool.h.clock <= duration[2] then
                pool.h.alpha = pushFloatTo(
                    pool.h.alpha,
                    pool.h.state and 1.00 or 0.00,
                    pool.h.clock,
                    duration[2]
                )
            else
                pool.h.alpha = pool.h.state and 1.00 or 0.00
                if not pool.h.state then
                    pool.h.clock = nil
                end
            end

            local max = s.x / 2
            local Y = p.y + s.y + 3
            local mid = p.x + max

            DL:AddLine(imgui.ImVec2(mid, Y), imgui.ImVec2(mid + (max * pool.h.alpha), Y), ToU32(set_alpha(pool.color, pool.h.alpha)), 3)
            DL:AddLine(imgui.ImVec2(mid, Y), imgui.ImVec2(mid - (max * pool.h.alpha), Y), ToU32(set_alpha(pool.color, pool.h.alpha)), 3)
        end

    imgui.EndGroup()
    return result
end
function imgui.BetterInput(name, hint_text, flags, buffer, color, text_color, width)

    ----==| Локальные фунцкии, использованные в этой функции. |==----

    local function bringVec4To(from, to, start_time, duration)
        local timer = os.clock() - start_time
        if timer >= 0.00 and timer <= duration then
            local count = timer / (duration / 100)
            return imgui.ImVec4(
                from.x + (count * (to.x - from.x) / 100),
                from.y + (count * (to.y - from.y) / 100),
                from.z + (count * (to.z - from.z) / 100),
                from.w + (count * (to.w - from.w) / 100)
            ), true
        end
        return (timer > duration) and to or from, false
    end

    local function bringFloatTo(from, to, start_time, duration)
        local timer = os.clock() - start_time
        if timer >= 0.00 and timer <= duration then
            local count = timer / (duration / 100)
            return from + (count * (to - from) / 100), true
        end
        return (timer > duration) and to or from, false
    end


    ----==| Изменение местоположения Imgui курсора, чтобы подсказка при анимации отображалась корректно. |==----

    imgui.SetCursorPosY(imgui.GetCursorPos().y + (imgui.CalcTextSize(hint_text).y * 0.7))


    ----==| Создание шаблона, для корректной работы нескольких таких виджетов. |==----

    if UI_BETTERINPUT == nil then
        UI_BETTERINPUT = {}
    end
    if not UI_BETTERINPUT[name] then
        UI_BETTERINPUT[name] = {buffer = buffer or imgui.new.char[256](''), width = nil,
        hint = {
            pos = nil,
            old_pos = nil,
            scale = nil
        },
        color = imgui.GetStyle().Colors[imgui.Col.TextDisabled],
        old_color = imgui.GetStyle().Colors[imgui.Col.TextDisabled],
        active = {false, nil}, inactive = {true, nil}
    }
    end

    local pool = UI_BETTERINPUT[name] -- локальный список переменных для одного виджета


    ----==| Проверка и присваивание значений нужных переменных и аргументов. |==----
    
    if color == nil then
        color = imgui.GetStyle().Colors[imgui.Col.ButtonActive]
    end

    if width == nil then
        pool["width"] = imgui.CalcTextSize(hint_text).x + 50
        if pool["width"] < 150 then
            pool["width"] = 150
        end
    else
        pool["width"] = width
    end

    if pool["hint"]["scale"] == nil then
        pool["hint"]["scale"] = 1.0
    end

    if pool["hint"]["pos"] == nil then
        pool["hint"]["pos"] = imgui.ImVec2(imgui.GetCursorPos().x, imgui.GetCursorPos().y)
    end

    if pool["hint"]["old_pos"] == nil then
        pool["hint"]["old_pos"] = imgui.GetCursorPos().y
    end


    ----==| Изменение стилей под параметры виджета. |==----

    imgui.PushStyleColor(imgui.Col.FrameBg, imgui.ImVec4(1, 1, 1, 0))
    imgui.PushStyleColor(imgui.Col.Text, text_color or imgui.ImVec4(1, 1, 1, 1))
    imgui.PushStyleColor(imgui.Col.TextSelectedBg, color)
    imgui.PushStyleVarVec2(imgui.StyleVar.FramePadding, imgui.ImVec2(0, imgui.GetStyle().FramePadding.y))
    imgui.PushItemWidth(pool["width"])


    ----==| Получение Imgui Draw List текущего окна. |==----

    local draw_list = imgui.GetWindowDrawList()


    ----==| Добавление декоративной линии под виджет. |==----

    draw_list:AddLine(imgui.ImVec2(imgui.GetCursorPos().x + imgui.GetWindowPos().x,
    imgui.GetCursorPos().y + imgui.GetWindowPos().y + (2 * imgui.GetStyle().FramePadding.y) + imgui.CalcTextSize(hint_text).y),
    imgui.ImVec2(imgui.GetCursorPos().x + imgui.GetWindowPos().x + pool["width"],
    imgui.GetCursorPos().y + imgui.GetWindowPos().y + (2 * imgui.GetStyle().FramePadding.y) + imgui.CalcTextSize(hint_text).y),
    imgui.GetColorU32Vec4(pool["color"]), 2.0)


    ----==| Само поле ввода. |==----

    imgui.InputText("##" .. name, pool["buffer"], ffi.sizeof(pool["buffer"]), flags or 0)


    ----==| Переключатель состояний виджета. |==----

    if not imgui.IsItemActive() then
        if pool["inactive"][2] == nil then pool["inactive"][2] = os.clock() end
        pool["inactive"][1] = true
        pool["active"][1] = false
        pool["active"][2] = nil

    elseif imgui.IsItemActive() or imgui.IsItemClicked() then
        pool["inactive"][1] = false
        pool["inactive"][2] = nil
        if pool["active"][2] == nil then pool["active"][2] = os.clock() end
        pool["active"][1] = true
    end
    
    ----==| Изменение цвета; размера и позиции подсказки по состоянию. |==----

    if pool["inactive"][1] and #ffi.string(pool["buffer"]) == 0 then
        pool["color"] = bringVec4To(pool["color"], pool["old_color"], pool["inactive"][2], 0.75)
        pool["hint"]["scale"] = bringFloatTo(pool["hint"]["scale"], 1.0, pool["inactive"][2], 0.25)
        pool["hint"]["pos"].y = bringFloatTo(pool["hint"]["pos"].y, pool["hint"]["old_pos"], pool["inactive"][2], 0.25)
        
    elseif pool["inactive"][1] and #ffi.string(pool["buffer"]) > 0 then
        pool["color"] = bringVec4To(pool["color"], pool["old_color"], pool["inactive"][2], 0.75)
        pool["hint"]["scale"] = bringFloatTo(pool["hint"]["scale"], 0.7, pool["inactive"][2], 0.25)
        pool["hint"]["pos"].y = bringFloatTo(pool["hint"]["pos"].y, pool["hint"]["old_pos"] - (imgui.GetFontSize() * 0.7) - 2,
        pool["inactive"][2], 0.25)

    elseif pool["active"][1] and #ffi.string(pool["buffer"]) == 0 then
        pool["color"] = bringVec4To(pool["color"], color, pool["active"][2], 0.75)
        pool["hint"]["scale"] = bringFloatTo(pool["hint"]["scale"], 0.7, pool["active"][2], 0.25)
        pool["hint"]["pos"].y = bringFloatTo(pool["hint"]["pos"].y, pool["hint"]["old_pos"] - (imgui.GetFontSize() * 0.7) - 2,
        pool["active"][2], 0.25)

    elseif pool["active"][1] and #ffi.string(pool["buffer"]) > 0 then
        pool["color"] = bringVec4To(pool["color"], color, pool["active"][2], 0.75)
        pool["hint"]["scale"] = bringFloatTo(pool["hint"]["scale"], 0.7, pool["active"][2], 0.25)
        pool["hint"]["pos"].y = bringFloatTo(pool["hint"]["pos"].y, pool["hint"]["old_pos"] - (imgui.GetFontSize() * 0.7) - 2,
        pool["active"][2], 0.25)
    end   
    imgui.SetWindowFontScale(pool["hint"]["scale"])
    
    
    ----==| Сама подсказка с анимацией. |==----

    draw_list:AddText(imgui.ImVec2(pool["hint"]["pos"].x + imgui.GetWindowPos().x + imgui.GetStyle().FramePadding.x,
    pool["hint"]["pos"].y + imgui.GetWindowPos().y + imgui.GetStyle().FramePadding.y),
    imgui.GetColorU32Vec4(pool["color"]),
    hint_text)


    ----==| Возвращение стилей в свой первоначальный вид. |==----

    imgui.SetWindowFontScale(1.0)
    imgui.PopItemWidth()
    imgui.PopStyleColor(3)
    imgui.PopStyleVar()
end

function imgui.Hint(str_id, hint_text, color, no_center) -- by cosmo
    color = color or imgui.GetStyle().Colors[imgui.Col.PopupBg]
    local p_orig = imgui.GetCursorPos()
    local hovered = imgui.IsItemHovered()
    imgui.SameLine(nil, 0)

    local animTime = 0.2
    local show = true

    if not POOL_HINTS then POOL_HINTS = {} end
    if not POOL_HINTS[str_id] then
        POOL_HINTS[str_id] = {
            status = false,
            timer = 0
        }
    end

    if hovered then
        for k, v in pairs(POOL_HINTS) do
            if k ~= str_id and os.clock() - v.timer <= animTime  then
                show = false
            end
        end
    end

    if show and POOL_HINTS[str_id].status ~= hovered then
        POOL_HINTS[str_id].status = hovered
        POOL_HINTS[str_id].timer = os.clock()
    end

    local getContrastColor = function(col)
        local luminance = 1 - (0.299 * col.x + 0.587 * col.y + 0.114 * col.z)
        return luminance < 0.5 and imgui.ImVec4(0, 0, 0, 1) or imgui.ImVec4(1, 1, 1, 1)
    end

    local rend_window = function(alpha)
        local size = imgui.GetItemRectSize()
        local scrPos = imgui.GetCursorScreenPos()
        local DL = imgui.GetWindowDrawList()
        local center = imgui.ImVec2( scrPos.x - (size.x / 2), scrPos.y + (size.y / 2) - (alpha * 4) + 10 )
        local a = imgui.ImVec2( center.x - 7, center.y - size.y - 3 )
        local b = imgui.ImVec2( center.x + 7, center.y - size.y - 3)
        local c = imgui.ImVec2( center.x, center.y - size.y + 3 )
        local col = imgui.ColorConvertFloat4ToU32(imgui.ImVec4(color.x, color.y, color.z, alpha))

        DL:AddTriangleFilled(a, b, c, col)
        imgui.SetNextWindowPos(imgui.ImVec2(center.x, center.y - size.y - 3), imgui.Cond.Always, imgui.ImVec2(0.5, 1.0))
        imgui.PushStyleColor(imgui.Col.PopupBg, color)
        imgui.PushStyleColor(imgui.Col.Border, color)
        imgui.PushStyleColor(imgui.Col.Text, getContrastColor(color))
        imgui.PushStyleVarVec2(imgui.StyleVar.WindowPadding, imgui.ImVec2(8, 8))
        imgui.PushStyleVarFloat(imgui.StyleVar.WindowRounding, 6)
        imgui.PushStyleVarFloat(imgui.StyleVar.Alpha, alpha)

        local max_width = function(text)
            local result = 0
            for line in text:gmatch('[^\n]+') do
                local len = imgui.CalcTextSize(line).x
                if len > result then
                    result = len
                end
            end
            return result
        end

        local hint_width = max_width(hint_text) + (imgui.GetStyle().WindowPadding.x * 2)
        imgui.SetNextWindowSize(imgui.ImVec2(hint_width, -1), imgui.Cond.Always)
        imgui.Begin('##' .. str_id, _, imgui.WindowFlags.Tooltip + imgui.WindowFlags.NoResize + imgui.WindowFlags.NoScrollbar + imgui.WindowFlags.NoTitleBar)
            for line in hint_text:gmatch('[^\n]+') do
                if no_center then
                    imgui.Text(line)
                else
                    imgui.SetCursorPosX((hint_width - imgui.CalcTextSize(line).x) / 2)
                    imgui.Text(line)
                end
            end
        imgui.End()

        imgui.PopStyleVar(3)
        imgui.PopStyleColor(3)
    end

    if show then
        local between = os.clock() - POOL_HINTS[str_id].timer
        if between <= animTime then
            local s = function(f)
                return f < 0.0 and 0.0 or (f > 1.0 and 1.0 or f)
            end
            local alpha = hovered and s(between / animTime) or s(1.00 - between / animTime)
            rend_window(alpha)
        elseif hovered then
            rend_window(1.00)
        end
    end

    imgui.SetCursorPos(p_orig)
end

function imgui.ToggleButton(label, label_true, bool, a_speed)
    local p  = imgui.GetCursorScreenPos()
    local dl = imgui.GetWindowDrawList()
 
    local bebrochka = false

    local label      = label or ""                          -- Текст false
    local label_true = label_true or ""                     -- Текст true
    local h          = imgui.GetTextLineHeightWithSpacing() -- Высота кнопки
    local w          = h * 1.7                              -- Ширина кнопки
    local r          = h / 2                                -- Радиус кружка
    local s          = a_speed or 0.2                       -- Скорость анимации
 
    local function ImSaturate(f)
        return f < 0.0 and 0.0 or (f > 1.0 and 1.0 or f)
    end
 
    local x_begin = bool[0] and 1.0 or 0.0
    local t_begin = bool[0] and 0.0 or 1.0
 
    if LastTime == nil then
        LastTime = {}
    end
    if LastActive == nil then
        LastActive = {}
    end
 
    if imgui.InvisibleButton(label, imgui.ImVec2(w, h)) then
        bool[0] = not bool[0]
        LastTime[label] = os.clock()
        LastActive[label] = true
        bebrochka = true
    end

    if LastActive[label] then
        local time = os.clock() - LastTime[label]
        if time <= s then
            local anim = ImSaturate(time / s)
            x_begin = bool[0] and anim or 1.0 - anim
            t_begin = bool[0] and 1.0 - anim or anim
        else
            LastActive[label] = false
        end
    end
 
    local bg_color = imgui.ImVec4(x_begin * 0.13, x_begin * 0.9, x_begin * 0.13, imgui.IsItemHovered(0) and 0.7 or 0.9) -- Цвет прямоугольника
    local t_color  = imgui.ImVec4(1, 1, 1, x_begin) -- Цвет текста при false
    local t2_color = imgui.ImVec4(1, 1, 1, t_begin) -- Цвет текста при true
 
    dl:AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + w, p.y + h), imgui.GetColorU32Vec4(bg_color), r)
    dl:AddCircleFilled(imgui.ImVec2(p.x + r + x_begin * (w - r * 2), p.y + r), t_begin < 0.5 and x_begin * r or t_begin * r, imgui.GetColorU32Vec4(imgui.ImVec4(0.9, 0.9, 0.9, 1.0)), r + 5)
    dl:AddText(imgui.ImVec2(p.x + w + r, p.y + r - (r / 2) - (imgui.CalcTextSize(label).y / 4)), imgui.GetColorU32Vec4(t_color), label_true)
    dl:AddText(imgui.ImVec2(p.x + w + r, p.y + r - (r / 2) - (imgui.CalcTextSize(label).y / 4)), imgui.GetColorU32Vec4(t2_color), label)
    return bebrochka
end

function imgui.DarkTheme()
    imgui.SwitchContext()
    --==[ STYLE ]==--
    --imgui.GetStyle().WindowPadding = imgui.ImVec2(10, 10)
    --imgui.GetStyle().FramePadding = imgui.ImVec2(5, 5)
    --imgui.GetStyle().ItemSpacing = imgui.ImVec2(5, 5)
    --imgui.GetStyle().ItemInnerSpacing = imgui.ImVec2(2, 2)
    --imgui.GetStyle().TouchExtraPadding = imgui.ImVec2(0, 0)
    --imgui.GetStyle().IndentSpacing = 20
    --imgui.GetStyle().ScrollbarSize = 10
    --imgui.GetStyle().GrabMinSize = 10

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
    imgui.GetStyle().Colors[imgui.Col.PopupBg]                = imgui.ImVec4(0.12, 0.12, 0.12, 1.00)
    imgui.GetStyle().Colors[imgui.Col.Border]                 = imgui.ImVec4(1, 1, 1, 1)
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

