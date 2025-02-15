script_name('Medz Menu')
script_author('Medz')
script_description('Medz menu')

local key = require 'vkeys'
local imgui = require 'imgui'
-- local encoding = require 'encoding'
local mem = require "memory"
-- encoding.default = 'CP1251'
-- u8 = encoding.UTF8

function apply_custom_style()
	imgui.SwitchContext()
	local style = imgui.GetStyle()
	local colors = style.Colors
	local clr = imgui.Col
	local ImVec4 = imgui.ImVec4

        style.WindowRounding = 2
        style.WindowTitleAlign = imgui.ImVec2(0.5, 0.5)
        style.ChildWindowRounding = 4.0
        style.FrameRounding = 3
        style.ItemSpacing = imgui.ImVec2(5.0, 4.0)
        style.ScrollbarSize = 13.0
        style.ScrollbarRounding = 2
        style.GrabMinSize = 8.0
        style.GrabRounding = 1.0
        style.WindowPadding = imgui.ImVec2(4.0, 4.0)
        style.FramePadding = imgui.ImVec2(3.5, 3.5)
        style.ButtonTextAlign = imgui.ImVec2(0.5, 0.5)

	colors[clr.Text] = ImVec4(1, 1, 1, 1.00)
	colors[clr.TextDisabled] = ImVec4(1, 1, 1, 1.00)
	colors[clr.WindowBg] = ImVec4(0.04, 0.04, 0.04, 1.00)
	colors[clr.ChildWindowBg] = ImVec4(0.07, 0.07, 0.09, 1.00)
	colors[clr.PopupBg] = ImVec4(0.07, 0.07, 0.09, 1.00)
	colors[clr.Border] = ImVec4(0.80, 0.80, 0.83, 0.88)
	colors[clr.BorderShadow] = ImVec4(0.92, 0.91, 0.88, 0.00)
	colors[clr.FrameBg] = ImVec4(0.10, 0.09, 0.12, 1.00)
	colors[clr.FrameBgHovered] = ImVec4(0.24, 0.23, 0.29, 1.00)
	colors[clr.FrameBgActive] = ImVec4(0.56, 0.56, 0.58, 1.00)
	colors[clr.TitleBg] = ImVec4(0.10, 0.09, 0.12, 1.00)
	colors[clr.TitleBgCollapsed] = ImVec4(1.00, 0.98, 0.95, 0.75)
	colors[clr.TitleBgActive] = ImVec4(0.07, 0.07, 0.09, 1.00)
	colors[clr.MenuBarBg] = ImVec4(0.10, 0.09, 0.12, 1.00)
	colors[clr.ScrollbarBg] = ImVec4(0.10, 0.09, 0.12, 1.00)
	colors[clr.ScrollbarGrab] = ImVec4(0.80, 0.80, 0.83, 0.31)
	colors[clr.ScrollbarGrabHovered] = ImVec4(0.56, 0.56, 0.58, 1.00)
	colors[clr.ScrollbarGrabActive] = ImVec4(0.06, 0.05, 0.07, 1.00)
	colors[clr.ComboBg] = ImVec4(0.19, 0.18, 0.21, 1.00)
	colors[clr.CheckMark] = ImVec4(0.80, 0.80, 0.83, 0.31)
	colors[clr.SliderGrab] = ImVec4(0.80, 0.80, 0.83, 0.31)
	colors[clr.SliderGrabActive] = ImVec4(0.06, 0.05, 0.07, 1.00)
	colors[clr.Button] = ImVec4(0.9, 0.9, 0.9, 0.2)
	colors[clr.ButtonHovered] = ImVec4(0.24, 0.23, 0.29, 1.00)
	colors[clr.ButtonActive] = ImVec4(0.56, 0.56, 0.58, 1.00)
	colors[clr.Header] = ImVec4(0.10, 0.09, 0.12, 1.00)
	colors[clr.HeaderHovered] = ImVec4(0.56, 0.56, 0.58, 1.00)
	colors[clr.HeaderActive] = ImVec4(0.06, 0.05, 0.07, 1.00)
	colors[clr.ResizeGrip] = ImVec4(0.00, 0.00, 0.00, 0.00)
	colors[clr.ResizeGripHovered] = ImVec4(0.56, 0.56, 0.58, 1.00)
	colors[clr.ResizeGripActive] = ImVec4(0.06, 0.05, 0.07, 1.00)
	colors[clr.CloseButton] = ImVec4(0.40, 0.39, 0.38, 0.16)
	colors[clr.CloseButtonHovered] = ImVec4(0.40, 0.39, 0.38, 0.39)
	colors[clr.CloseButtonActive] = ImVec4(0.40, 0.39, 0.38, 1.00)
	colors[clr.PlotLines] = ImVec4(0.40, 0.39, 0.38, 0.63)
	colors[clr.PlotLinesHovered] = ImVec4(0.25, 1.00, 0.00, 1.00)
	colors[clr.PlotHistogram] = ImVec4(0.40, 0.39, 0.38, 0.63)
	colors[clr.PlotHistogramHovered] = ImVec4(0.25, 1.00, 0.00, 1.00)
	colors[clr.TextSelectedBg] = ImVec4(0.25, 1.00, 0.00, 0.43)
	colors[clr.ModalWindowDarkening] = ImVec4(1.00, 0.98, 0.95, 0.73)
end
apply_custom_style()

do

show_main_window = imgui.ImBool(false)
local show_moon_imgui_tutorial = imgui.ImBool(false)
local swatshow = imgui.ImBool(false)
local nametaghack  = false

function imgui.OnDrawFrame()
	-- Main Window
	if show_main_window.v then
		local sw, sh = getScreenResolution()
		-- center
		imgui.SetNextWindowPos(imgui.ImVec2(sw / 2, sh / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
		imgui.SetNextWindowSize(imgui.ImVec2(300, 300), imgui.Cond.FirstUseEver)
		imgui.Begin("Medz's Menu", show_main_window)
		local btn_size = imgui.ImVec2(-0.5, 0)
		if imgui.Button('WH', btn_size) then
			nametaghack = not nametaghack -- ON / OFF
			if nametaghack then 
				nameTagOn()
			else 
				nameTagOff()

			end		
			printStringNow('WH ' .. (nametaghack and '~g~ON' or '~r~OFF') .. '~n~~y~', 3000) -- Show message 3sec. ON / OFF
		end
		if imgui.Button('TGOLS', btn_size) then
			show_moon_imgui_tutorial.v = not show_moon_imgui_tutorial.v
		end
		if imgui.Button('SWAT', btn_size) then
			swatshow.v = not swatshow.v
		end
			if imgui.Button('Hitman', btn_size) then
				show_moon_imgui_tutorial.v = not show_moon_imgui_tutorial.v
			end
		

		-- if imgui.CollapsingHeader('Options') then
		-- 	if imgui.Checkbox('Render in menu', cb_render_in_menu) then
		-- 		imgui.RenderInMenu = cb_render_in_menu.v
		-- 	end
		-- 	if imgui.Checkbox('Lock player controls', cb_lock_player) then
		-- 		imgui.LockPlayer = cb_lock_player.v
		-- 	end
		-- 	if imgui.Checkbox('Show cursor', cb_show_cursor) then
		-- 		imgui.ShowCursor = cb_show_cursor.v
		-- 	end
		-- end
		imgui.End()
	end


	if show_moon_imgui_tutorial.v then
		imgui.SetNextWindowPos(imgui.ImVec2(990, 850), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
		imgui.SetNextWindowSize(imgui.ImVec2(200, 200), imgui.Cond.FirstUseEver)
		imgui.Begin('TGOLS', show_moon_imgui_tutorial)
		if imgui.Button('Give Rank') then
			sampSendChat("/grank")
		end
		if imgui.Button('Gates') then
			sampSendChat("/ggates")
		end
		imgui.End()
	end

	if swatshow.v then
		imgui.SetNextWindowPos(imgui.ImVec2(990, 850), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
		imgui.SetNextWindowSize(imgui.ImVec2(200, 200), imgui.Cond.FirstUseEver)
		imgui.Begin('SWAT', swatshow)
		if imgui.Button('Policelights') then
			sampSendChat("/policelights 1")
		end
		if imgui.Button('Reset Cars') then
			sampSendChat("/swatreset")
		end
		imgui.End()
	end

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



end

end

function main()
	while true do
		wait(0)
		if wasKeyPressed(key.VK_F3) then
			show_main_window.v = not show_main_window.v
		end
		imgui.Process = show_main_window.v
	end
end
