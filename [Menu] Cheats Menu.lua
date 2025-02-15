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
local getBonePosition = ffi.cast("int (__thiscall*)(void*, float*, int, bool)", 0x5E4280)
local inicfg = require 'inicfg'
local directIni = 'Medz\\Cheats.ini'
local close = imgui.new.bool(false)

local ini = inicfg.load(inicfg.load({
    pl = {
        nicks = false,
        bones = false,
        tracers = false,
        tracers_mode = 0,
        tracers_thickness = 1,
        bones_thickness = 1,
        bones_distance = 300,
        tracers_distance = 300,

    },
    cr = {
        info = false,
        info_dist = 100,
        info_srvid = true,
        info_model = true,
        info_hp = true,
        info_driver = true,
    },
}, directIni))
inicfg.save(ini, directIni)
local pl = {
    nicks = imgui.new.bool(ini.pl.nicks),
    bones = imgui.new.bool(ini.pl.bones),
    tracers = imgui.new.bool(ini.pl.tracers),
    tracers_mode = imgui.new.int(ini.pl.tracers_mode),
    tracers_thickness = imgui.new.int(ini.pl.tracers_thickness),
    bones_thickness = imgui.new.int(ini.pl.bones_thickness),

    nicks_distance = imgui.new.float(ini.pl.bones_distance),
    bones_distance = imgui.new.float(ini.pl.bones_distance),
    tracers_distance = imgui.new.float(ini.pl.tracers_distance),
}

local cr = {
    info = imgui.new.bool(ini.cr.info),
    info_dist = imgui.new.float(ini.cr.info_dist),

    info_srvid = imgui.new.bool(ini.cr.info_srvid),
    info_model = imgui.new.bool(ini.cr.info_model),
    info_hp = imgui.new.bool(ini.cr.info_hp),
    info_driver = imgui.new.bool(ini.cr.info_driver),
}

local StartTime = -1
local toggle = imgui.new.bool(false)
local autohitmantoggle = imgui.new.bool(false)

local car_font = renderCreateFont('Tahoma', 8, 5)
local font_nick = renderCreateFont('Tahoma', 10, 4)

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


local Menu = {
	Wallhack = imgui.new.bool(false),
    VEH = imgui.new.bool(false),
    State = imgui.new.bool(false),
    State2 = imgui.new.bool(false),
    Search = imgui.new.char[128](''),
    Times = {
        {name = faicons('sun') .. ' Day', hour = "8" },
        {name = faicons('moon') .. ' Night', hour = "1"},
    },
    Skins = {
        {name = faicons('sun') .. ' SWAT', id = "285" },
        {name = faicons('moon') .. ' Army', id = "287"},
    }
}
imgui.OnInitialize(function() 

    imgui.DarkTheme() 
end)
local Frame = imgui.OnFrame(
    function() return Menu.State[0] end,
    function(self)
        local resX, resY = getScreenResolution()
        local sizeX, sizeY = 300, 245
        imgui.SetNextWindowPos(imgui.ImVec2(resX / 2, resY / 2), imgui.Cond.Appearing, imgui.ImVec2(0.5, 0.5))
        imgui.SetNextWindowSize(imgui.ImVec2(sizeX, sizeY), imgui.Cond.Always)
        if imgui.Begin("##MAIN_MENU",_,imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoResize + imgui.WindowFlags.NoTitleBar) then
            local wsize = imgui.GetWindowSize()
            local size = imgui.GetWindowSize()

            imgui.SetCursorPos(imgui.ImVec2(115, 10))
            local color = imgui.GetStyle().Colors[imgui.Col.Text]
            imgui.TextColored(color, 'Cheats Menu')
            imgui.Separator()
            imgui.SetCursorPos(imgui.ImVec2(wsize.x - 30, 10))
			-- ad.CloseButton('##closemenu', Menu.State, 20, 5)


            imgui.SetCursorPos(imgui.ImVec2(10, 50))
            local pos = imgui.GetCursorPos()
            imgui.BeginChild('Pages', imgui.ImVec2(500, wsize.y - pos.y - 40), false, imgui.WindowFlags.NoBackground + imgui.WindowFlags.NoScrollbar)
            if ad.MaterialButton('Wallhack', imgui.ImVec2(280, 30)) then
                imgui.OpenPopup('Wallhack##pup')
            end
            if ad.MaterialButton('Settings', imgui.ImVec2(280, 30)) then
                imgui.OpenPopup('Settings##pup')
            end
                -->> Popups

                ----> Skin
                if imgui.BeginPopupModal('Skin##pup', _, imgui.WindowFlags.NoResize) then
                    imgui.SetWindowSize(imgui.ImVec2(300, 500))
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
--> Wallhack
                   imgui.SetCursorPos(imgui.ImVec2(500, 10))
                if imgui.BeginPopupModal('Wallhack##pup', _, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoResize + imgui.WindowFlags.NoTitleBar) then

                    imgui.SetWindowSizeVec2(imgui.ImVec2(300, 245))
                    local size = imgui.GetWindowSize()
                    imgui.SetCursorPos(imgui.ImVec2(size.x / 2 - 40, 10))
                    local color = imgui.GetStyle().Colors[imgui.Col.Text]
    
                            imgui.TextColored(color, 'Wallhack Menu')
                            imgui.Separator()
                            imgui.SetCursorPos(imgui.ImVec2(10, 50))
                            if ad.MaterialButton('Players', imgui.ImVec2(size.x - 20, 24), 0.35) then 
                                text = "Wallhack On "
                                Menu.Wallhack[0] = not Menu.Wallhack[0]
                                pl.nicks[0] = not pl.nicks[0]
                               -- pl.tracers[0] = not pl.tracers[0]
                                pl.bones[0] = not pl.bones[0]
                                imgui.CloseCurrentPopup() 
                            end
                            imgui.SetCursorPosX(10)
                            if ad.MaterialButton('Cars', imgui.ImVec2(size.x - 20, 24), 0.35) then
                                Menu.VEH[0] = not Menu.VEH[0]
                                clicked_hint = true
                                cr.info[0] = not cr.info[0]
                                imgui.CloseCurrentPopup()
                            end
                            --ad.Hint('##hint1', 'This is a button, click on it!', imgui.GetStyle().Colors[imgui.Col.TextDisabled]) 
                        --imgui.SetCursorPos(imgui.ImVec2(10, size.y - 460))
                        imgui.SetCursorPos(imgui.ImVec2(270, 5))
                        if ad.CloseButton('MainClose', close, 25) then 
                            imgui.CloseCurrentPopup()
                
                         end
                    imgui.SetCursorPos(imgui.ImVec2(5, size.y - 40))
                    imgui.EndPopup()
                end

				                ----> weather
								if imgui.BeginPopupModal('Weather##pup', _, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoResize + imgui.WindowFlags.NoTitleBar) then
									imgui.SetWindowSizeVec2(imgui.ImVec2(300, 500))
									local size = imgui.GetWindowSize()
									imgui.SetCursorPos(imgui.ImVec2(5, 30))
									if imgui.BeginChild('Weather List', imgui.ImVec2(size.x - 10, size.y - 5 - 30 - 30), true) then
										imgui.SetCursorPos(imgui.ImVec2(5, 5))
										imgui.SetCursorPos(imgui.ImVec2(5, 5))
										imgui.PushItemWidth(size.x - 30)
										imgui.InputTextWithHint('##Menu.Search', 'Message', Menu.Search, ffi.sizeof(Menu.Search))
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
                                if imgui.BeginPopupModal('Settings##pup', _, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoResize + imgui.WindowFlags.NoTitleBar) then

                                    imgui.SetWindowSizeVec2(imgui.ImVec2(300, 245))
                                    local size = imgui.GetWindowSize()
                                    imgui.SetCursorPos(imgui.ImVec2(size.x / 2 - 40, 10))
                                    local color = imgui.GetStyle().Colors[imgui.Col.Text]
                    
                                            imgui.TextColored(color, 'Settings Menu')
                                            imgui.Separator()
                                            imgui.SetCursorPos(imgui.ImVec2(100, 50))
                                            if ad.ToggleButton('Hitman', autohitmantoggle) then
                                                sampAddChatMessage("On",0x00ff00)
                                                
                                            end
                                        --imgui.SetCursorPos(imgui.ImVec2(10, size.y - 460))
                                        imgui.SetCursorPos(imgui.ImVec2(270, 5))
                                        if ad.CloseButton('MainClose', close, 20) then 
                                            imgui.CloseCurrentPopup()
                                
                                         end
                                    imgui.SetCursorPos(imgui.ImVec2(5, size.y - 40))
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
                imgui.Text('N  - Open Cheat menu')
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
                imgui.Text(text)
                --local tsize = imgui.CalcTextSize('N').y
                --imgui.GetWindowDrawList():AddRect(imgui.ImVec2(p.x - tsize /2 + 3 , p.y), imgui.ImVec2(p.x + tsize - 3, p.y + tsize), 0xFFffffff, 3)--, float rounding = 0.0f, int rounding_corners_flags = ~0, float thickness = 1.0f)
                imgui.EndChild()
            end
            imgui.PopStyleColor()
            imgui.End()
        end
    end
)

local FrameThird = imgui.OnFrame(
    function() return Menu.VEH[0] end,
    function(self)
        self.HideCursor = true
        local resX, resY = getScreenResolution()
        local winsize = imgui.ImVec2(120, 95)
        imgui.SetNextWindowPos(imgui.ImVec2(resX - winsize.x, 950), imgui.Cond.Always, imgui.ImVec2(0, 0))
        imgui.SetNextWindowSize(winsize, imgui.Cond.Always)
        if imgui.Begin('Test', Menu.VEH, imgui.WindowFlags.NoDecoration + imgui.WindowFlags.NoBackground) then
            local size = imgui.GetWindowSize()
            imgui.SetCursorPos(imgui.ImVec2(5, size.y - 45 - 33 - 10))
            imgui.PushStyleColor(imgui.Col.ChildBg, imgui.ImVec4(0.05, 0.05, 0.05, 0.7))
            if imgui.BeginChild('Tooltsip', imgui.ImVec2(size.x - 10, 33)) then
                imgui.SetCursorPos(imgui.ImVec2(10, 10))
                local p = imgui.GetCursorScreenPos()
                imgui.Text('Vehicles: On')
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
		NTdist = mem.getfloat(pStSet + 39) 
		NTwalls = mem.getint8(pStSet + 47) 
		NTshow = mem.getint8(pStSet + 56) 
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
    while not isSampAvailable() do wait(200) end
    --print()
    imgui.Process = false
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
            --PEDS
            for k, v in pairs(getAllChars()) do
                if v ~= PLAYER_PED then 
                    local resX, resY = getScreenResolution()
                    local myX, myY, myZ = getCharCoordinates(PLAYER_PED)
                    local pedX, pedY, pedZ = getCharCoordinates(v)
                    local prX, prY = convert3DCoordsToScreen(pedX, pedY, pedZ)
                    local result, id = sampGetPlayerIdByCharHandle(v)
                    if result and isCharOnScreen(v) then
                        local color = tonumber("0xFF"..(("%X"):format(sampGetPlayerColor(id))):gsub(".*(......)", "%1"))--sampGetPlayerColor(id)
                        -- BONES
                        
                        local dist = getDistanceBetweenCoords3d(myX, myY, myZ, pedX, pedY, pedZ)
                        if pl.bones[0] and pl.bones_distance[0] >= dist then
                            local i = v
                            local thickness = pl.bones_thickness[0]
                            pos1X, pos1Y, pos1Z = getBodyPartCoordinates(6, i)
                            pos2X, pos2Y, pos2Z = getBodyPartCoordinates(7, i)
                            
                            pos1, pos2 = convert3DCoordsToScreen(pos1X, pos1Y, pos1Z)
                            pos3, pos4 = convert3DCoordsToScreen(pos2X, pos2Y, pos2Z)
                            renderDrawLine(pos1, pos2, pos3, pos4, thickness, color)
                            
                            pos1X, pos1Y, pos1Z = getBodyPartCoordinates(7, i)
                            pos2X, pos2Y, pos2Z = getBodyPartCoordinates(8, i)
                            
                            pos1, pos2 = convert3DCoordsToScreen(pos1X, pos1Y, pos1Z)
                            pos3, pos4 = convert3DCoordsToScreen(pos2X, pos2Y, pos2Z)
                            renderDrawLine(pos1, pos2, pos3, pos4, thickness, color)
                            
                            pos1X, pos1Y, pos1Z = getBodyPartCoordinates(8, i)
                            pos2X, pos2Y, pos2Z = getBodyPartCoordinates(6, i)
                            
                            pos1, pos2 = convert3DCoordsToScreen(pos1X, pos1Y, pos1Z)
                            pos3, pos4 = convert3DCoordsToScreen(pos2X, pos2Y, pos2Z)
                            renderDrawLine(pos1, pos2, pos3, pos4, thickness, color)

                            pos1X, pos1Y, pos1Z = getBodyPartCoordinates(1, i)
                            pos2X, pos2Y, pos2Z = getBodyPartCoordinates(4, i)
                            
                            pos1, pos2 = convert3DCoordsToScreen(pos1X, pos1Y, pos1Z)
                            pos3, pos4 = convert3DCoordsToScreen(pos2X, pos2Y, pos2Z)
                            renderDrawLine(pos1, pos2, pos3, pos4, thickness, color)
                            
                            pos1X, pos1Y, pos1Z = getBodyPartCoordinates(4, i)
                            pos2X, pos2Y, pos2Z = getBodyPartCoordinates(8, i)
                            
                            pos1, pos2 = convert3DCoordsToScreen(pos1X, pos1Y, pos1Z)
                            pos3, pos4 = convert3DCoordsToScreen(pos2X, pos2Y, pos2Z)
                            renderDrawLine(pos1, pos2, pos3, pos4, thickness, color)

                            pos1X, pos1Y, pos1Z = getBodyPartCoordinates(21, i)
                            pos2X, pos2Y, pos2Z = getBodyPartCoordinates(22, i)
                            
                            pos1, pos2 = convert3DCoordsToScreen(pos1X, pos1Y, pos1Z)
                            pos3, pos4 = convert3DCoordsToScreen(pos2X, pos2Y, pos2Z)
                            renderDrawLine(pos1, pos2, pos3, pos4, thickness, color)
                            
                            pos1X, pos1Y, pos1Z = getBodyPartCoordinates(22, i)
                            pos2X, pos2Y, pos2Z = getBodyPartCoordinates(23, i)
                            
                            pos1, pos2 = convert3DCoordsToScreen(pos1X, pos1Y, pos1Z)
                            pos3, pos4 = convert3DCoordsToScreen(pos2X, pos2Y, pos2Z)
                            renderDrawLine(pos1, pos2, pos3, pos4, thickness, color)
                            
                            pos1X, pos1Y, pos1Z = getBodyPartCoordinates(23, i)
                            pos2X, pos2Y, pos2Z = getBodyPartCoordinates(24, i)
                            
                            pos1, pos2 = convert3DCoordsToScreen(pos1X, pos1Y, pos1Z)
                            pos3, pos4 = convert3DCoordsToScreen(pos2X, pos2Y, pos2Z)
                            renderDrawLine(pos1, pos2, pos3, pos4, thickness, color)
                            
                            pos1X, pos1Y, pos1Z = getBodyPartCoordinates(24, i)
                            pos2X, pos2Y, pos2Z = getBodyPartCoordinates(25, i)
                            
                            pos1, pos2 = convert3DCoordsToScreen(pos1X, pos1Y, pos1Z)
                            pos3, pos4 = convert3DCoordsToScreen(pos2X, pos2Y, pos2Z)
                            renderDrawLine(pos1, pos2, pos3, pos4, thickness, color)

                            pos1X, pos1Y, pos1Z = getBodyPartCoordinates(31, i)
                            pos2X, pos2Y, pos2Z = getBodyPartCoordinates(32, i)
                            
                            pos1, pos2 = convert3DCoordsToScreen(pos1X, pos1Y, pos1Z)
                            pos3, pos4 = convert3DCoordsToScreen(pos2X, pos2Y, pos2Z)
                            renderDrawLine(pos1, pos2, pos3, pos4, thickness, color)
                            
                            pos1X, pos1Y, pos1Z = getBodyPartCoordinates(32, i)
                            pos2X, pos2Y, pos2Z = getBodyPartCoordinates(33, i)
                            
                            pos1, pos2 = convert3DCoordsToScreen(pos1X, pos1Y, pos1Z)
                            pos3, pos4 = convert3DCoordsToScreen(pos2X, pos2Y, pos2Z)
                            renderDrawLine(pos1, pos2, pos3, pos4, thickness, color)
                            
                            pos1X, pos1Y, pos1Z = getBodyPartCoordinates(33, i)
                            pos2X, pos2Y, pos2Z = getBodyPartCoordinates(34, i)
                            
                            pos1, pos2 = convert3DCoordsToScreen(pos1X, pos1Y, pos1Z)
                            pos3, pos4 = convert3DCoordsToScreen(pos2X, pos2Y, pos2Z)
                            renderDrawLine(pos1, pos2, pos3, pos4, thickness, color)
                            
                            pos1X, pos1Y, pos1Z = getBodyPartCoordinates(34, i)
                            pos2X, pos2Y, pos2Z = getBodyPartCoordinates(35, i)
                            
                            pos1, pos2 = convert3DCoordsToScreen(pos1X, pos1Y, pos1Z)
                            pos3, pos4 = convert3DCoordsToScreen(pos2X, pos2Y, pos2Z)
                            renderDrawLine(pos1, pos2, pos3, pos4, thickness, color)

                            pos1X, pos1Y, pos1Z = getBodyPartCoordinates(1, i)
                            pos2X, pos2Y, pos2Z = getBodyPartCoordinates(51, i)
                            
                            pos1, pos2 = convert3DCoordsToScreen(pos1X, pos1Y, pos1Z)
                            pos3, pos4 = convert3DCoordsToScreen(pos2X, pos2Y, pos2Z)
                            renderDrawLine(pos1, pos2, pos3, pos4, thickness, color)
                            pos1X, pos1Y, pos1Z = getBodyPartCoordinates(51, i)
                            pos2X, pos2Y, pos2Z = getBodyPartCoordinates(52, i)
                            
                            pos1, pos2 = convert3DCoordsToScreen(pos1X, pos1Y, pos1Z)
                            pos3, pos4 = convert3DCoordsToScreen(pos2X, pos2Y, pos2Z)
                            renderDrawLine(pos1, pos2, pos3, pos4, thickness, color)
                            
                            pos1X, pos1Y, pos1Z = getBodyPartCoordinates(52, i)
                            pos2X, pos2Y, pos2Z = getBodyPartCoordinates(53, i)
                            
                            pos1, pos2 = convert3DCoordsToScreen(pos1X, pos1Y, pos1Z)
                            pos3, pos4 = convert3DCoordsToScreen(pos2X, pos2Y, pos2Z)
                            renderDrawLine(pos1, pos2, pos3, pos4, thickness, color)
                            
                            pos1X, pos1Y, pos1Z = getBodyPartCoordinates(53, i)
                            pos2X, pos2Y, pos2Z = getBodyPartCoordinates(54, i)
                            
                            pos1, pos2 = convert3DCoordsToScreen(pos1X, pos1Y, pos1Z)
                            pos3, pos4 = convert3DCoordsToScreen(pos2X, pos2Y, pos2Z)
                            renderDrawLine(pos1, pos2, pos3, pos4, thickness, color)

                            pos1X, pos1Y, pos1Z = getBodyPartCoordinates(1, i)
                            pos2X, pos2Y, pos2Z = getBodyPartCoordinates(41, i)
                            
                            pos1, pos2 = convert3DCoordsToScreen(pos1X, pos1Y, pos1Z)
                            pos3, pos4 = convert3DCoordsToScreen(pos2X, pos2Y, pos2Z)
                            renderDrawLine(pos1, pos2, pos3, pos4, thickness, color)
                            
                            pos1X, pos1Y, pos1Z = getBodyPartCoordinates(41, i)
                            pos2X, pos2Y, pos2Z = getBodyPartCoordinates(42, i)
                            
                            pos1, pos2 = convert3DCoordsToScreen(pos1X, pos1Y, pos1Z)
                            pos3, pos4 = convert3DCoordsToScreen(pos2X, pos2Y, pos2Z)
                            renderDrawLine(pos1, pos2, pos3, pos4, thickness, color)
                            
                            pos1X, pos1Y, pos1Z = getBodyPartCoordinates(42, i)
                            pos2X, pos2Y, pos2Z = getBodyPartCoordinates(43, i)
                            
                            pos1, pos2 = convert3DCoordsToScreen(pos1X, pos1Y, pos1Z)
                            pos3, pos4 = convert3DCoordsToScreen(pos2X, pos2Y, pos2Z)
                            renderDrawLine(pos1, pos2, pos3, pos4, thickness, color)
                            
                            pos1X, pos1Y, pos1Z = getBodyPartCoordinates(43, i)
                            pos2X, pos2Y, pos2Z = getBodyPartCoordinates(44, i)
                            
                            pos1, pos2 = convert3DCoordsToScreen(pos1X, pos1Y, pos1Z)
                            pos3, pos4 = convert3DCoordsToScreen(pos2X, pos2Y, pos2Z)
                            renderDrawLine(pos1, pos2, pos3, pos4, thickness, color)
                        end
                        --TRACERS 
                        if pl.tracers[0] and pl.tracers_distance[0] >= dist then
                            local tracer_pointFrom = {x = 0, y = 0} 
                            if pl.tracers_mode[0] == 0 then
                                tracer_pointFrom.x, tracer_pointFrom.y = convert3DCoordsToScreen(myX, myY, myZ)
                            elseif pl.tracers_mode[0] == 1 then
                                tracer_pointFrom.x, tracer_pointFrom.y = resX / 2, 0
                            elseif pl.tracers_mode[0] == 2 then
                                tracer_pointFrom.x, tracer_pointFrom.y = resX / 2, resY
                            end
                            if isPointOnScreen(pedX, pedY, pedZ, 1) then
                                renderDrawLine(tracer_pointFrom.x, tracer_pointFrom.y, prX, prY, pl.tracers_thickness[0], color)
                            end
                        end
                        -- NAMES
                        if pl.nicks[0] and pl.nicks_distance[0] >= dist then
                            headX, headY, headZ = getBodyPartCoordinates(1, v)
                            nrX, nrY = convert3DCoordsToScreen(headX, headY, headZ - 1)
                            --local nicktext = sampGetPlayerNickname(id)..' {ffffff}['..id..']'
                            local nicktext = sampGetPlayerNickname(id)
                            renderFontDrawText(font_nick, nicktext, nrX - renderGetFontDrawTextLength(font_nick, nicktext) / 2, nrY, color, 0x90000000)

                            
                            local size = {x = 50, y = 10}
                            -- renderFontDrawText(font_nick_stats, '{ff004d}HP: {ffffff}'.. sampGetPlayerHealth(id), nrX - renderGetFontDrawTextLength(font_nick_stats, 'HP: '.. getCharHealth(v)) / 2, nrY + 20, 0xFFFFFFFF, 0x90000000)
                            --renderDrawBar(nrX - size.x / 2, nrY + 20, size.x, size.y, getCharHealth(v), true, 0xFFff004d)

                            -- local armour = sampGetPlayerArmor(id)
                            -- if armour > 0 then
                            --     renderFontDrawText(font_nick_stats, '{00a2ff}AR:{ffffff} '.. armour, nrX - renderGetFontDrawTextLength(font_nick_stats, 'AR: '.. armour) / 2, nrY + 20, 0xFFFFFFFF, 0x90000000)
                            
                            --     --renderDrawBar(nrX - size.x / 2, nrY + 50, size.x, size.y, armour, true, 0xFF00a2ff)
                            -- end

                        end
                    end
                end
            end 

            -- VEHS
            for k, v in pairs(getAllVehicles()) do
                if v ~= getSelfVeh() then 
                    if isCarOnScreen(v) then
                        
                        local x, y, z = getCarCoordinates(v)
                        local rx, ry = convert3DCoordsToScreen(x, y, z)
                        local driver = getDriverOfCar(v)
                         
                        if driver == -1 or driver == nil then
                            color = -1
                            driverId = 0
                        else
                            driverId = select(2, sampGetPlayerIdByCharHandle(v))
                            color = tonumber("0xFF"..(("%X"):format(sampGetPlayerColor(driverId))):gsub(".*(......)", "%1"))
                        end
                        local myX, myY, myZ = getCharCoordinates(PLAYER_PED)
                        if cr.info[0] and getDistanceBetweenCoords3d(myX, myY, myZ, x, y, z) < cr.info_dist[0] and select(1, sampGetVehicleIdByCarHandle(v)) then

                            local text = (cr.info_srvid[0] and 'ID: '..select(2, sampGetVehicleIdByCarHandle(v))..'\n' or '')..(cr.info_model[0] and 'Model: '..getNameOfVehicleModel(getCarModel(v))..' ('..getCarModel(v)..')\n' or '')..(cr.info_hp[0] and 'HP: '..getCarHealth(v)..'\n' or '')..(cr.info_driver[0] and 'Driver: '..' ('..driverId..')'..'\n' or '')

                            
                            renderFontDrawText(car_font, text, rx, ry, color, 0x90000000)
                        end
                    end
                end
            end
    end
end


function getSelfVeh()
    if isCharInAnyCar(PLAYER_PED) then
        return storeCarCharIsInNoSave(PLAYER_PED)
    else
        return -2281337
    end
end


function imgui.DarkTheme()
    local style = imgui.GetStyle()
    local colors = style.Colors
    local clr = imgui.Col
    local ImVec4 = imgui.ImVec4
    local ImVec2 = imgui.ImVec2
 
     style.WindowPadding = ImVec2(15, 15)
     style.WindowRounding = 15.0
     style.FramePadding = ImVec2(5, 5)
     style.ItemSpacing = ImVec2(12, 8)
     style.ItemInnerSpacing = ImVec2(8, 6)
     style.IndentSpacing = 25.0
     style.ScrollbarSize = 15.0
     style.ScrollbarRounding = 15.0
     style.GrabMinSize = 15.0
     style.GrabRounding = 7.0
     style.ChildRounding = 0.0
     style.FrameRounding = 6.0
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
        imgui.GetStyle().Colors[imgui.Col.ButtonActive]           = imgui.ImVec4(1, 1, 1, 1.00)
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

function getBodyPartCoordinates(id, handle)
    if doesCharExist(handle) then
        local pedptr = getCharPointer(handle)
        local vec = ffi.new("float[3]")
        getBonePosition(ffi.cast("void*", pedptr), vec, id, true)
        return vec[0], vec[1], vec[2]
    end
end

function save()
    ini.pl.bones_distance = pl.nicks_distance[0]
    ini.pl.bones_distance = pl.bones_distance[0]
    ini.pl.tracers_distance = pl.tracers_distance[0]

    ini.cr.info_srvid = cr.info_srvid[0]
    ini.cr.info_model = cr.info_model[0]
    ini.cr.info_hp = cr.info_hp[0]
    ini.cr.info_driver = cr.info_driver[0]

    ini.pl.nicks = pl.nicks[0]
    ini.pl.bones = pl.bones[0]
    ini.pl.tracers = pl.tracers[0]
    ini.pl.tracers_mode = pl.tracers_mode[0]
    ini.pl.tracers_thickness = pl.tracers_thickness[0]
    ini.pl.bones_thickness = pl.bones_thickness[0]

    ini.cr.info = cr.info[0]
    ini.cr.info_dist = cr.info_dist[0]

    inicfg.save(ini, directIni)
end

function imgui.CenterText(text)
    local width = imgui.GetWindowWidth()
    local calc = imgui.CalcTextSize(text)
    imgui.SetCursorPosX( width / 2 - calc.x / 2 )
    imgui.Text(text)
end