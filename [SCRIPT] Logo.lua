
script_author("#Medz")
-------------------------------------------- Requires ------------------------------
require 'moonloader'
local imgui = require 'mimgui'
local ffi = require 'ffi'
local bNotf, notf = pcall(import, "imgui_notf.lua")
local sampev = require "lib.samp.events"
local menu = imgui.new.bool(false)
local window = imgui.new.bool(true)
local font = {}
local new = imgui.new
local ad = require "ADDONS"
local key = require "vkeys"
local fa = require('fAwesome6_solid')



medzcfg = require("inicfg").load(nil, "moonloader\\config\\Medz\\medz.ini")
-------------------------------------------- Main --------------------------------------------
function main()
	while not isSampAvailable() do wait(0) end
	autologo()
end

function autologo()
	menu[0] = not menu[0]
	wait(2000)
	menu[0] = not menu[0]
end
imgui.OnInitialize(function()
	imgui.GetIO().IniFilename = nil
    fa.Init(20)

	local STYLE = imgui.GetStyle()
	local COLOR = STYLE.Colors
	local VEC4, c = imgui.ImVec4, imgui.Col
    img = imgui.CreateTextureFromFile(getWorkingDirectory() .. '/config/Medz/Medz.png')
	-- STYLE
	imgui.SwitchContext()
	STYLE.WindowPadding		= imgui.ImVec2(4, 4)
	STYLE.ItemSpacing		= imgui.ImVec2(10, 10)
	STYLE.WindowBorderSize	= 5.0
	STYLE.WindowRounding	= 10.0
	STYLE.ChildRounding		= 10.0
	STYLE.FrameRounding		= 5.0

	COLOR[c.Text]					= VEC4(1.00, 1.00, 1.00, 1.00)
	COLOR[c.TextDisabled]			= VEC4(1.00, 1.00, 1.00, 0.20)
	COLOR[c.WindowBg]				= VEC4(0.0, 0.0, 0.0, 1.00)
	COLOR[c.ChildBg]				= VEC4(0.07, 0.07, 0.09, 1.00)
	COLOR[c.PopupBg]				= VEC4(0.90, 0.90, 0.90, 1.00)
	COLOR[c.Border]					= VEC4(0.1, 0.1, 0.1, 0.5)
	COLOR[c.Separator]				= VEC4(0.50, 0.50, 0.50, 0.90)
	COLOR[c.FrameBg]				= VEC4(0.20, 0.20, 0.20, 1.00)
	COLOR[c.FrameBgHovered]			= VEC4(0.20, 0.20, 0.20, 0.80)
	COLOR[c.FrameBgActive]			= VEC4(0.20, 0.20, 0.20, 0.60)
	COLOR[c.SliderGrab]				= VEC4(1.00, 1.00, 1.00, 0.50)
	COLOR[c.SliderGrabActive]		= VEC4(1.00, 1.00, 1.00, 1.00)
	COLOR[c.CheckMark]				= VEC4(1.00, 1.00, 1.00, 1.00)
	COLOR[c.Button]					= VEC4(0.90, 0.90, 0.90, 0.2)
	COLOR[c.ButtonHovered]			= VEC4(0.80, 0.80, 0.80, 1.00)
	COLOR[c.ButtonActive]			= VEC4(0.20, 0.20, 0.20, 0.60)
	COLOR[c.ScrollbarBg]			= VEC4(0.60, 0.60, 0.60, 0.90)
	COLOR[c.ScrollbarGrab]			= VEC4(0.90, 0.90, 0.90, 1.00)
	COLOR[c.ScrollbarGrabHovered]	= VEC4(0.80, 0.80, 0.80, 1.00)
	COLOR[c.ScrollbarGrabActive]	= VEC4(0.70, 0.70, 0.70, 1.00)
	COLOR[c.TextSelectedBg]         = VEC4(0.80, 0.80, 0.80, 0.80)
	COLOR[c.ModalWindowDimBg]   	= VEC4(0.00, 0.00, 0.00, 0.60)
	local but_orig = imgui.Button
    imgui.Btnx = function(...)
        imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(0.07, 0.07, 0.09, 1.00))
        imgui.PushStyleColor(imgui.Col.Button, imgui.ImVec4(0.90, 0.90, 0.90, 1.00))
        imgui.PushStyleColor(imgui.Col.ButtonHovered, imgui.ImVec4(0.80, 0.80, 0.80, 1.00))
        imgui.PushStyleColor(imgui.Col.ButtonActive, imgui.ImVec4(0.70, 0.70, 0.70, 1.00))
        local result = but_orig(...)
        imgui.PopStyleColor(4)
        return result
    end
end)

local menu_frame2 = imgui.OnFrame(
	function() return menu[0] and not isPauseMenuActive() end,
	function(self)
		self.HideCursor = true
		local resX, resY = getScreenResolution()
        local sizeX, sizeY = 160, 160
		
        imgui.SetNextWindowPos(imgui.ImVec2(resX / 2, resY / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
        imgui.SetNextWindowSize(imgui.ImVec2(sizeX, sizeY), imgui.Cond.FirstUseEver)

		local wsize = imgui.GetWindowSize()
        imgui.Begin("  ", menu, imgui.WindowFlags.NoResize + imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoTitleBar + imgui.WindowFlags.NoScrollbar )
		imgui.Image(img, imgui.ImVec2(160, 160))

		imgui.End()
		
	end
	
)
