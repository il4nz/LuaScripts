---@diagnostic disable: missing-parameter, lowercase-global, assign-type-mismatch, redundant-parameter
script_name('Medz Menu')
script_author('Medz')
script_description('Medz menu')

local key = require 'vkeys'
local imgui = require('mimgui', 'https://www.blast.hk/threads/66959/')
local mem = require "memory"
local ad = require "ADDONS"
local ffi = require('ffi')
local faicons = require('fAwesome6')
local isConnected = function() return isSampAvailable() and sampGetCurrentServerName() ~= 'SA-MP' end-- and (sampGetGamestate() == 3 or sampGetGamestate() == 5) end

ffi.cdef([[
    typedef struct { float x, y, z; } CVector;
    int MessageBoxA(
        void* hWnd,
        const char* lpText,
        const char* lpCaption,
        unsigned int uType
    );
]])

local StartTime = -1
local toggle = imgui.new.bool(false)


function getLocalPlayerId()
	local _, id = sampGetPlayerIdByCharHandle(playerPed)
	return id
end

function set_player_skin(skin)
	local _, playerid = sampGetPlayerIdByCharHandle(playerPed)
	local BS = raknetNewBitStream()
	raknetBitStreamWriteInt32(BS, playerid)
	raknetBitStreamWriteInt32(BS, skin)
	raknetEmulRpcReceiveBitStream(153, BS)
	raknetDeleteBitStream(BS)
   end

function set_weather_id(param)
	local weather = tonumber(param)
	if weather ~= nil and weather >= 0 and weather <= 45 then
	  forceWeatherNow(weather)
	end
  end

  function patch_samp_time_set(enable)
	if enable and default == nil then
		default = readMemory(sampGetBase() + 0x9C0A0, 4, true)
		writeMemory(sampGetBase() + 0x9C0A0, 4, 0x000008C2, true)
	elseif enable == false and default ~= nil then
		writeMemory(sampGetBase() + 0x9C0A0, 4, default, true)
		default = nil
	end
end

--- Callbacks
function set_time(param)
	local hour = tonumber(param)
	if hour ~= nil and hour >= 0 and hour <= 23 then
	  time = hour
	  patch_samp_time_set(true)
	else
	  patch_samp_time_set(false)
	  time = nil
	end
  end

local Menu = {
	Wallhack = imgui.new.bool(false),
    State = imgui.new.bool(false),
    State2 = imgui.new.bool(false),
    Search = imgui.new.char[128](''),
    BotSkinId = imgui.new.int(0),
    Citizens = imgui.new.bool(true),
    Buttons = {
        -- {Label = 'Spawn vehicle', Callback = function() imgui.OpenPopup('Spawn vehicle##pup') end},
        --{Label = faicons('person') .. ' Change-Skin', Callback = function() imgui.OpenPopup('Skin##pup') end},
		{Label = faicons('cloud') .. ' Weather', Callback = function() imgui.OpenPopup('Weather##pup') end},
		{Label = faicons('clock') .. ' Time', Callback = function() imgui.OpenPopup('ChangeTime##pup') end},
        {Label = faicons('ghost') .. ' Cheats', Callback = function() imgui.OpenPopup('Cheats##pup') end},
        --{Label = 'Teleport', Callback = function() imgui.OpenPopup('Teleport##pup') end},
    },
    MeowButtons = {
        -- {Label = 'Spawn vehicle', Callback = function() imgui.OpenPopup('Spawn vehicle##pup') end},
        --{Label = 'Teleport', Callback = function() imgui.OpenPopup('Teleport##pup') end},
    },
    Times = {
        {name = faicons('sun') .. ' Day', hour = "8" },
        {name = faicons('moon') .. ' Night', hour = "1"},
    },
    Skins = {
        {name = faicons('sun') .. ' SWAT', id = "285" },
        {name = faicons('moon') .. ' Army', id = "287"},
    },
	Cheatsnames = {
		{name = faicons('eye') .. ' Wallhack'},
    }
}
imgui.OnInitialize(function() 
    imgui.DarkTheme() 
    imgui.GetIO().IniFilename = nil
    local config = imgui.ImFontConfig()
    config.MergeMode = true
    config.PixelSnapH = true
    iconRanges = imgui.new.ImWchar[3](faicons.min_range, faicons.max_range, 0)
    imgui.GetIO().Fonts:AddFontFromMemoryCompressedBase85TTF(faicons.get_font_data_base85('solid'), 14, config, iconRanges)
end)
local Frame = imgui.OnFrame(
    function() return Menu.State[0] end,
    function(self)
        local resX, resY = getScreenResolution()
        local sizeX, sizeY = 300, 245
        imgui.SetNextWindowPos(imgui.ImVec2(resX / 2, resY / 2), imgui.Cond.Appearing, imgui.ImVec2(0.5, 0.5))
        imgui.SetNextWindowSize(imgui.ImVec2(sizeX, sizeY), imgui.Cond.Always)
        if imgui.Begin('Medz', Menu.State, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoResize) then
            local size = imgui.GetWindowSize()
            imgui.SetCursorPos(imgui.ImVec2(5, 30))
            if imgui.BeginChild('pages', imgui.ImVec2(size.x - 10, size.y - 5 - 30), true) then
                for k, v in ipairs(Menu.Buttons) do
                    imgui.SetCursorPos(imgui.ImVec2(5, 5 + (24 * (k - 1)) + (5 * (k - 1))))
                    if imgui.Button(v.Label, imgui.ImVec2(size.x - 10 - 10, 24)) then
                        v.Callback()
                        imgui.StrCopy(Menu.Search, '')
                        --save()
                    end 
                end
                --name2 = sampGetPlayerNickname(getLocalPlayerId)
            --if name2 == "Meow" then
                for k, v in ipairs(Menu.MeowButtons) do
                    imgui.SetCursorPos(imgui.ImVec2(5, 5 + (24 * 3) + (5 * 3)))
                    if imgui.Button(v.Label, imgui.ImVec2(size.x - 10 - 10, 24)) then
                        v.Callback()
                        imgui.StrCopy(Menu.Search, '')
                        --save()
                    end 
                end
            --end
                -->> Popups

                ----> Skin
                if imgui.BeginPopupModal('Skin##pup', _, imgui.WindowFlags.NoResize) then
                    imgui.SetWindowSizeVec2(imgui.ImVec2(300, 500))
                    local size = imgui.GetWindowSize()
                    imgui.SetCursorPos(imgui.ImVec2(5, 30))
                    if imgui.BeginChild('SkinsList', imgui.ImVec2(size.x - 10, size.y - 5 - 30 - 30), true) then
                        -- imgui.SetCursorPos(imgui.ImVec2(5, 5))
                        -- imgui.SetCursorPos(imgui.ImVec2(5, 5))
                        -- imgui.PushItemWidth(size.x - 30)
                        -- imgui.InputTextWithHint('##Menu.Search', 'Search', Menu.Search, ffi.sizeof(Menu.Search))
                        -- imgui.PopItemWidth()
                        -- imgui.Separator()
                        -- for id = 0, 311 do
                        --     if #ffi.string(Menu.Search) == 0 or tostring(id):find(ffi.string(Menu.Search)) then
                        --         imgui.SetCursorPosX(5)
                        --         if imgui.Button(('%s'):format(tostring(id)), imgui.ImVec2(size.x - 30, 24)) then
                        --             set_player_skin(id)
                        --             imgui.CloseCurrentPopup()
                        --         end
                        --     end
                        -- end
                        for index, data in ipairs(Menu.Skins) do
                            imgui.SetCursorPosX(5)
                            if imgui.Button(data.name, imgui.ImVec2(size.x - 20, 24)) then
                                set_player_skin(data.id)
							 end
                        end
                        imgui.EndChild()
                    end
                    imgui.SetCursorPos(imgui.ImVec2(5, size.y - 30))
                    if imgui.Button('Close##Skin##pup', imgui.ImVec2(size.x - 10, 24)) then imgui.CloseCurrentPopup() end
                    imgui.EndPopup()
                end
--> cheats
                if imgui.BeginPopupModal('Cheats##pup', _, imgui.WindowFlags.NoResize) then
                    imgui.SetWindowSizeVec2(imgui.ImVec2(300, 500))
                    local size = imgui.GetWindowSize()
                    imgui.SetCursorPos(imgui.ImVec2(5, 30))
                    if imgui.BeginChild('Cheats', imgui.ImVec2(size.x - 10, size.y - 5 - 30 - 30), true) then
                        for index, data in ipairs(Menu.Cheatsnames) do
                            imgui.SetCursorPosX(5)
                            if imgui.Button(data.name, imgui.ImVec2(size.x - 20, 24)) then
                                							Menu.Wallhack[0] = not Menu.Wallhack[0]
                             if Menu.Wallhack[0] then
								nameTagOn()
							 else 
								nameTagOff()
							 end
                                imgui.CloseCurrentPopup()
                            end
                        end
                        --imgui.SetCursorPos(imgui.ImVec2(10, size.y - 460))
                        imgui.EndChild()
                    end
                    imgui.SetCursorPos(imgui.ImVec2(5, size.y - 30))
                    if imgui.Button('Close##Teleport##pup', imgui.ImVec2(size.x - 10, 24)) then imgui.CloseCurrentPopup() end
                    imgui.EndPopup()
                end

				                ----> weather
								if imgui.BeginPopupModal('Weather##pup', _, imgui.WindowFlags.NoResize) then
									imgui.SetWindowSizeVec2(imgui.ImVec2(300, 500))
									local size = imgui.GetWindowSize()
									imgui.SetCursorPos(imgui.ImVec2(5, 30))
									if imgui.BeginChild('Weather List', imgui.ImVec2(size.x - 10, size.y - 5 - 30 - 30), true) then
										imgui.SetCursorPos(imgui.ImVec2(5, 5))
										imgui.SetCursorPos(imgui.ImVec2(5, 5))
										imgui.PushItemWidth(size.x - 30)
										imgui.InputTextWithHint('##Menu.Search', 'Search', Menu.Search, ffi.sizeof(Menu.Search))
										imgui.PopItemWidth()
										imgui.Separator()
										for id = 0, 17 do
											if #ffi.string(Menu.Search) == 0 or tostring(id):find(ffi.string(Menu.Search)) then
												imgui.SetCursorPosX(5)
												if imgui.Button(('%s'):format(tostring(id)), imgui.ImVec2(size.x - 30, 24)) then
													set_weather_id(id)
													imgui.CloseCurrentPopup()
												end
											end
										end
										imgui.EndChild()
									end
									imgui.SetCursorPos(imgui.ImVec2(5, size.y - 30))
									if imgui.Button('Close##Weather##pup', imgui.ImVec2(size.x - 10, 24)) then imgui.CloseCurrentPopup() end
									imgui.EndPopup()
								end

                ----> Time
                if imgui.BeginPopupModal('ChangeTime##pup', _, imgui.WindowFlags.NoResize) then
                    imgui.SetWindowSizeVec2(imgui.ImVec2(300, 500))
                    local size = imgui.GetWindowSize()
                    imgui.SetCursorPos(imgui.ImVec2(5, 30))
                    if imgui.BeginChild('Time', imgui.ImVec2(size.x - 10, size.y - 5 - 30 - 30), true) then
                        for index, data in ipairs(Menu.Times) do
                            imgui.SetCursorPosX(5)
                            if imgui.Button(data.name, imgui.ImVec2(size.x - 20, 24)) then
								set_time(data.hour)
                                -- setCharCoordinates(PLAYER_PED, data.x, data.y, data.z)
                                imgui.CloseCurrentPopup()
                            end
                        end
                        imgui.EndChild()
                    end
                    imgui.SetCursorPos(imgui.ImVec2(5, size.y - 30))
                    if imgui.Button('Close##Teleport##pup', imgui.ImVec2(size.x - 10, 24)) then imgui.CloseCurrentPopup() end
                    imgui.EndPopup()
                end
                imgui.EndChild()
            end
            imgui.End()
        end
    end
)

local FrameTwo = imgui.OnFrame(
    function() return not isConnected() end,
    -- function() return isConnected() end,
    function(self)
        self.HideCursor = true
        local resX, resY = getScreenResolution()
        local winsize = imgui.ImVec2(220, 95)
        imgui.SetNextWindowPos(imgui.ImVec2(resX - winsize.x, resY - winsize.y), imgui.Cond.Always, imgui.ImVec2(0, 0))
        imgui.SetNextWindowSize(winsize, imgui.Cond.Always)
        if imgui.Begin('ConnectSandbox::TOOLTIP', Menu.State2, imgui.WindowFlags.NoDecoration + imgui.WindowFlags.NoBackground) then
            local size = imgui.GetWindowSize()
            imgui.SetCursorPos(imgui.ImVec2(5, size.y - 45 - 33 - 10))
            imgui.PushStyleColor(imgui.Col.ChildBg, imgui.ImVec4(0.05, 0.05, 0.05, 0.7))
            if imgui.BeginChild('Tooltsip', imgui.ImVec2(size.x - 10, 33)) then
                imgui.SetCursorPos(imgui.ImVec2(10, 10))
                local p = imgui.GetCursorScreenPos()
                imgui.Text('N  - Open Medz menu')
                local tsize = imgui.CalcTextSize('N').y
                imgui.GetWindowDrawList():AddRect(imgui.ImVec2(p.x - tsize /2 + 3 , p.y), imgui.ImVec2(p.x + tsize - 3, p.y + tsize), 0xFFffffff, 3)--, float rounding = 0.0f, int rounding_corners_flags = ~0, float thickness = 1.0f)
                imgui.EndChild()
            end

            -->> Spinner and time
            imgui.SetCursorPos(imgui.ImVec2(5, size.y - 45))
            if imgui.BeginChild('back', imgui.ImVec2(size.x - 10, 40)) then
                local text = ('Connecting... (%s sec.)'):format(tostring(math.floor(os.clock() - StartTime)))
                imgui.SetCursorPos(imgui.ImVec2(20 - imgui.CalcTextSize(text).y / 2, 20 - imgui.CalcTextSize(text).y / 2))
                imgui.Text(text)
                imgui.SetCursorPos(imgui.ImVec2(size.x - 10 - 30, 5))
                Spinner('Connecting to', 10, 3, 0xFFffffff)     
                imgui.EndChild()
            end
            imgui.PopStyleColor()
            imgui.End()
        end
    end
)

local FrameTwo = imgui.OnFrame(
    function() return Menu.Wallhack[0] end,
    function(self)
        self.HideCursor = true
        local resX, resY = getScreenResolution()
        local winsize = imgui.ImVec2(120, 95)
        imgui.SetNextWindowPos(imgui.ImVec2(resX - winsize.x, resY - winsize.y), imgui.Cond.Always, imgui.ImVec2(0, 0))
        imgui.SetNextWindowSize(winsize, imgui.Cond.Always)
        if imgui.Begin('ConnectSandbox::TOOLTIP', Menu.State2, imgui.WindowFlags.NoDecoration + imgui.WindowFlags.NoBackground) then
            local size = imgui.GetWindowSize()
            imgui.SetCursorPos(imgui.ImVec2(5, size.y - 45 - 33 - 10))
            imgui.PushStyleColor(imgui.Col.ChildBg, imgui.ImVec4(0.05, 0.05, 0.05, 0.7))
            if imgui.BeginChild('Tooltsip', imgui.ImVec2(size.x - 10, 33)) then
                imgui.SetCursorPos(imgui.ImVec2(10, 10))
                local p = imgui.GetCursorScreenPos()
                imgui.Text('Wallhack On')
                --local tsize = imgui.CalcTextSize('N').y
                --imgui.GetWindowDrawList():AddRect(imgui.ImVec2(p.x - tsize /2 + 3 , p.y), imgui.ImVec2(p.x + tsize - 3, p.y + tsize), 0xFFffffff, 3)--, float rounding = 0.0f, int rounding_corners_flags = ~0, float thickness = 1.0f)
                imgui.EndChild()
            end
            imgui.PopStyleColor()
            imgui.End()
        end
    end
)
	function nameTagOn()
		local pStSet = sampGetServerSettingsPtr()
		NTdist = mem.getfloat(pStSet + 39) -- дальность
		NTwalls = mem.getint8(pStSet + 47) -- видимость через стены
		NTshow = mem.getint8(pStSet + 56) -- видимость тегов
		mem.setfloat(pStSet + 39, 1488.0)
		mem.setint8(pStSet + 47, 0)
		mem.setint8(pStSet + 56, 1)
	end


function nameTagOff()
	local pStSet = sampGetServerSettingsPtr()
	mem.setfloat(pStSet + 39, NTdist)
	mem.setint8(pStSet + 47, NTwalls)
	mem.setint8(pStSet + 56, NTshow)
end

function onExitScript()
	if NTdist then
		nameTagOff()
	end
end

function main()
    if not isConnected() then
        StartTime = os.clock()
    end
	while true do
		wait(0)
		if wasKeyPressed(key.VK_N) and not sampIsCursorActive()  then
			Menu.State[0] = not Menu.State[0]
		end
		if time then
			setTimeOfDay(time, 0)
		  end
	end
end


function imgui.DarkTheme()
    imgui.SwitchContext()
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


Spinner = function(label, radius, thickness, color) -- Author: AnWu ( from https://www.blast.hk/threads/27544/ )
    local style = imgui.GetStyle()
    local pos = imgui.GetCursorScreenPos()
    local size = imgui.ImVec2(radius * 2, (radius + style.FramePadding.y) * 2)
    
    imgui.Dummy(imgui.ImVec2(size.x + style.ItemSpacing.x, size.y))

    local DrawList = imgui.GetWindowDrawList()
    DrawList:PathClear()
    
    local num_segments = 30
    local start = math.abs(math.sin(imgui.GetTime() * 1.8) * (num_segments - 5))
    
    local a_min = 3.14 * 2.0 * start / num_segments
    local a_max = 3.14 * 2.0 * (num_segments - 3) / num_segments

    local centre = imgui.ImVec2(pos.x + radius, pos.y + radius + style.FramePadding.y)
    
    for i = 0, num_segments do
        local a = a_min + (i / num_segments) * (a_max - a_min)
        DrawList:PathLineTo(imgui.ImVec2(centre.x + math.cos(a + imgui.GetTime() * 8) * radius, centre.y + math.sin(a + imgui.GetTime() * 8) * radius))
    end

    DrawList:PathStroke(color, false, thickness)
    return true
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