script_name("Mimgui Scoreboard")
script_author("MTG, Edited: Medz")
script_version("1.32")

require "lib.moonloader"
local ad = require 'ADDONS'
local bitex = require('bitex')
local memory = require "memory"
local ffi = require 'ffi'
local fa = require('fAwesome6_solid')
local imgui = require('mimgui')
local new = imgui.new
local inputField = new.char[256]()
local sizeX, sizeY = getScreenResolution()
local renderTAB = new.bool()

local key = require 'vkeys'

local close = imgui.new.bool(false)
local status = {
	["464646"] = "Hitman",
	["FFFFFF"] = "Civilian",
	["0080FF"] = "Police",
	["808080"] = "Dead",
	["00FFFF"] = "S.W.A.T",
	["FFA500"] = "Wanted",
	["8B4513"] = "Pagati",
	["FF0000"] = "Wanted",
	["BF1111"] = "Wanted",
	["FFFF00"] = "Wanted",
	["066501"] = "Admin",
	["800080"] = "Army",
	["FF00FF"] = "Event",
	["FFC0CB"] = "Medic",
	["33AA33"] = "Taxi",
	["556B2F"] = "Trucker"
	}

	local Menu = {
		Search = imgui.new.char[256](''),
	}
function main()

    if not isSampLoaded() or not isSampfuncsLoaded() then return end
    while not isSampAvailable() do wait(0) end
	IPaddress = sampGetCurrentServerAddress()
	if IPaddress == "37.187.77.206" then
		sampAddChatMessage("------------------------------------------------------------------------------------", 0xffffff) 
		sampAddChatMessage("{00ff00}Ls-rcr {00ff00}Scoreboard {00ff00}Loaded{ffffff} -  Version: 1.32", 0xffffff)
		sampAddChatMessage("------------------------------------------------------------------------------------", 0xffffff) 
	else
	sampAddChatMessage("------------------------------------------------------------------------------------", 0xffffff) 
	sampAddChatMessage("{ff0000}Ls-rcr {ff0000}Scoreboard {ff0000}Unloaded{ffffff} [Wrong IP]", 0xffffff)
	sampAddChatMessage("------------------------------------------------------------------------------------", 0xffffff) 
	lua_thread.create(function()
		wait(1000)
		thisScript():unload()
	end)
	end
	while true do
		wait(0)
		if sampIsScoreboardOpen() then sampToggleScoreboard(false) end
	end
end
imgui.OnInitialize(function()
    imgui.GetIO().IniFilename = nil
	fa.Init()
	
	imgui.DarkTheme()
	
	
end)
local Scoreboard = imgui.OnFrame(
    function() return renderTAB[0] end,
    function(player)
	
		imgui.GetStyle().ScrollbarSize = 10
		imgui.GetStyle().FrameRounding = 20.0
		imgui.SetNextWindowPos(imgui.ImVec2(sizeX / 2, sizeY / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
		imgui.SetNextWindowSize(imgui.ImVec2(870, 613), imgui.Cond.FirstUseEver)
		imgui.Begin("##Begin", renderTAB, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoResize + imgui.WindowFlags.NoTitleBar + imgui.WindowFlags.NoMove )
		
		imgui.Text('Players: '..(sampGetPlayerCount(false) - 5)) 
		imgui.SameLine()
		imgui.CenterText((sampGetCurrentServerName()))	
		imgui.SameLine()
		imgui.SetCursorPosX( imgui.GetWindowWidth() - 151)
		imgui.PushItemWidth(110)
		imgui.GetStyle().FrameRounding = 3.0
		imgui.SameLine()
		imgui.SetCursorPosX( imgui.GetWindowWidth() - 40)
		imgui.GetStyle().FrameRounding = 5.0
		if imgui.Button(fa.XMARK) then	
			renderTAB[0] = false
		end
		imgui.GetStyle().FrameRounding = 20.0
		imgui.Columns(6)
		imgui.Separator()
		imgui.SetColumnWidth(-1, 55) imgui.CenterColumnText('ID') imgui.NextColumn()
		imgui.SetColumnWidth(-1, 450) imgui.CenterColumnText('Nickname') imgui.NextColumn()
		imgui.SetColumnWidth(-1, 100) imgui.CenterColumnText('Class') imgui.NextColumn()
		imgui.SetColumnWidth(-1, 65	) imgui.CenterColumnText('Score') imgui.NextColumn()
		imgui.SetColumnWidth(-1, 65) imgui.CenterColumnText('Ping') imgui.NextColumn()
		imgui.SetColumnWidth(-1, 100) imgui.CenterColumnText('Action') imgui.NextColumn()
		imgui.Separator()
		local my_id = select(2,sampGetPlayerIdByCharHandle(playerPed))
		drawScoreboardPlayer(my_id)
			for idd = 0, sampGetMaxPlayerId(false) do
				if sampIsPlayerConnected(idd) and not sampIsPlayerNpc(idd) then
					if tostring(idd):find(ffi.string(inputField)) or string.rlower(sampGetPlayerNickname(idd)):find(string.rlower(decode(ffi.string(inputField)))) then
						--imgui.Separator()
						drawScoreboardPlayer(idd)
					end
				end
			end
		
		imgui.NextColumn()
		imgui.Columns(1)
		imgui.Separator()
		imgui.End()

		
    end
)

function drawScoreboardPlayer(id)

	local nickname = sampGetPlayerNickname(id)
	local score = sampGetPlayerScore(id)
	local ping = sampGetPlayerPing(id)
	local color = sampGetPlayerColor(id)
	local r, g, b = bitex.bextract(color, 16, 8), bitex.bextract(color, 8, 8), bitex.bextract(color, 0, 8)
	local imgui_RGBA = imgui.ImVec4(r / 255.0, g / 255.0, b / 255.0, 1)
	colormeow = ("%X"):format(sampGetPlayerColor(id)):gsub(".*(......)", "%1")--sampGetPlayerColor(id)
	
	imgui.SetCursorPosX((imgui.GetColumnOffset() + (imgui.GetColumnWidth() / 2)) - imgui.CalcTextSize(tostring(id)).x / 2)
	if status[colormeow] == "Hitman" then
		imgui.TextColored(imgui.ImVec4(0.2, 0.2, 0.2, 1), ' '..id)
		else 
		imgui.TextColored(imgui_RGBA, ' '..id)
		end
	imgui.NextColumn()
	
	
    if status[colormeow] == "Hitman" then
	imgui.TextColored(imgui.ImVec4(0.2, 0.2, 0.2, 1), ' '..nickname)
	else 
	imgui.TextColored(imgui_RGBA, ' '..nickname)
	end
	imgui.NextColumn()	
	-- Class
	
	if status[colormeow] == "Hitman" then
		imgui.TextColored(imgui.ImVec4(0.2, 0.2, 0.2, 1), string.format("%s", status[colormeow]))
		else 
		imgui.TextColored(imgui_RGBA, string.format("%s", status[colormeow]))
		end
	imgui.NextColumn()	
	
	
	imgui.SetCursorPosX((imgui.GetColumnOffset() + (imgui.GetColumnWidth() / 2)) - imgui.CalcTextSize(tostring(score)).x / 2)
	if status[colormeow] == "Hitman" then
		imgui.TextColored(imgui.ImVec4(0.2, 0.2, 0.2, 1), ' '..score)
		else 
		imgui.TextColored(imgui_RGBA, ' '..score)
	end
	imgui.NextColumn()
	
	

	imgui.SetCursorPosX((imgui.GetColumnOffset() + (imgui.GetColumnWidth() / 2)) - imgui.CalcTextSize(tostring(ping)).x / 2)
	if status[colormeow] == "Hitman" then
		imgui.TextColored(imgui.ImVec4(0.2, 0.2, 0.2, 1), ' '..ping)
		else 
		imgui.TextColored(imgui_RGBA, ' '..ping)
		end
		
	imgui.NextColumn()
	if imgui.Button(fa.INFO.."##"..id, imgui.ImVec2(22, 22.5)) then
		lua_thread.create(
			function()
				wait(100)
				os.execute('explorer "https://ls-rcr.com/user/"' .. nickname)
			end
		)
	end
	if imgui.IsItemHovered() then
		imgui.SetTooltip(nickname .. "'s Stats")
	end
	
	imgui.SameLine()
	if imgui.Button(fa.MESSAGE.."##"..id, imgui.ImVec2(22, 22.5)) then
		newid = ""
		newid = id
		imgui.OpenPopup('Search##pup')

		-- lua_thread.create(
		-- 	function()
		-- 		wait(100)
		-- 		sampSendChat("/pm " .. id .. " " .. "Hi")
		-- 	end
		-- )
	end
	if imgui.BeginPopupModal('Search##pup', _, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoResize + imgui.WindowFlags.NoTitleBar ) then
		imgui.SetNextWindowSize(imgui.ImVec2(300, 125))
		local size = imgui.GetWindowSize()
		imgui.SetCursorPos(imgui.ImVec2(100, 10))
		imgui.Text("Private Message")
		imgui.SetCursorPos(imgui.ImVec2(50, 40))
		imgui.PushItemWidth(200)
        if imgui.InputTextWithHint('##Menu.Search', 'Type here', Menu.Search, ffi.sizeof(Menu.Search)) then
			
			msg = ffi.string(Menu.Search)
		end
        imgui.PopItemWidth()
		--imgui.Separator()
		imgui.SetCursorPos(imgui.ImVec2(125, 85))
		if imgui.Button('Send', imgui.ImVec2(50, 24)) then 
			sampSendChat("/pm " .. newid .. " " .. msg)
			Menu.Search = imgui.new.char[256]('')
		 end
		 imgui.SetCursorPos(imgui.ImVec2(270, 5))
		if ad.CloseButton('MainClose', close, 25) then 
			imgui.CloseCurrentPopup()
			renderTAB[0] = false
			Menu.Search = imgui.new.char[256]('')

		 end
		imgui.EndPopup()
	end
	if imgui.IsItemHovered() then
		imgui.SetTooltip("Message " ..nickname)
	end
	imgui.SameLine()
	if imgui.Button(fa.COPY.."##"..id, imgui.ImVec2(22, 22.5)) then
		colormeow = ("%X"):format(sampGetPlayerColor(id)):gsub(".*(......)", "%1")--sampGetPlayerColor(id)
		--setClipboardText(colormeow)
		setClipboardText(nickname)
		sampAddChatMessage(sampGetCurrentServerAddress())
	end
	if imgui.IsItemHovered() then
		imgui.SetTooltip("Copy " ..nickname)
	end
	imgui.NextColumn()
	
end
function imgui.CenterColumnText(text)
    imgui.SetCursorPosX((imgui.GetColumnOffset() + (imgui.GetColumnWidth() / 2)) - imgui.CalcTextSize(text).x / 2)
    imgui.Text(text)
end
function imgui.CenterText(text)
    local width = imgui.GetWindowWidth()
    local calc = imgui.CalcTextSize(text)
    imgui.SetCursorPosX( width / 2 - calc.x / 2 )
    imgui.Text(text)
end


function imgui.DarkTheme()
    local FONTS = imgui.GetIO().Fonts
    local STYLE = imgui.GetStyle()
    local COLOR = STYLE.Colors
    local VEC4, c = imgui.ImVec4, imgui.Col
    imgui.SwitchContext()
    --==[ STYLE ]==--
    -- STYLE
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
	 imgui.GetStyle().Colors[imgui.Col.WindowBg]               = imgui.ImVec4(0.07, 0.07, 0.07, 0.95)
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
	 imgui.GetStyle().Colors[imgui.Col.Separator]              = imgui.ImVec4(0.3, 0.3, 0.3, 1)
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
function string.rlower(s)
	s = s:lower()
	local strlen = s:len()
	if strlen == 0 then return s end
	s = s:lower()
	local output = ''
	for i = 1, strlen do
		 local ch = s:byte(i)
			  output = output .. string.char(ch)
	end
	return output
end
function onWindowMessage(msg, wparam, lparam)
	if(msg == 0x100 or msg == 0x101) then
		if (wparam == VK_ESCAPE and renderTAB[0]) and not isPauseMenuActive() then
			consumeWindowMessage(true, false)
			if (msg == 0x101) then
				renderTAB[0] = false
			end
		elseif wparam == VK_TAB and not isKeyDown(VK_TAB) and not isPauseMenuActive() then
			if not renderTAB[0] then
				if not sampIsChatInputActive() then
					renderTAB[0] = true
				end
			else
				renderTAB[0] = false
			end
			consumeWindowMessage(true, false)
		end
	end
end
