local imgui = require("imgui")
local x2, y2 = getScreenResolution()
local checkbox = imgui.ImBool(false)
local encoding = require ("encoding")
local checkbox222 = imgui.ImBool(false)
local checkbox333 = imgui.ImBool(false)
local traser = imgui.ImBool(false)
local enab = imgui.ImBool(false)
local intbuffer = imgui.ImInt(0)
local inicfg = require("inicfg")
encoding.default = "CP1251"
u8 = encoding.UTF8
local inputs11 = {
	{false},
	{228, "", false},
	{1337, "", false}
}
tabl = {}
local style = imgui.GetStyle()

local colors = style.Colors
local clr = imgui.Col
local ImVec4 = imgui.ImVec4
style.WindowRounding = 0
style.ChildWindowRounding = 1.5
colors[clr.TitleBg]                = ImVec4(255, 0, 0, 1)
colors[clr.TitleBgActive]          = ImVec4(255, 0, 0, 1)
colors[clr.TitleBgCollapsed]       = ImVec4(255, 0, 0, 0.1)

function main()
	while not isSampAvailable() do wait(100) end
	if not doesDirectoryExist("moonloader//config") then
    	createDirectory("moonloader//config")
    	inicfg.save(inputs11, "objwallhack")
  	end
 	inputs = inicfg.load(nil, "objwallhack")
  	if not inputs then
    	inicfg.save(inputs11, "objwallhack")
    	inputs = inicfg.load(nil, "objwallhack")
  	end
  	for i, val in ipairs(inputs) do
  		if #val == 3 then
    		table.insert(tabl,{imgui.ImInt(val[1]), imgui.ImBuffer((tostring(u8:decode(u8(val[2])))), 20), imgui.ImBool(val[3])})
   		else
    		checkbox123 = imgui.ImBool(val[1])
    	end
    end
	local font = renderCreateFont("Arial", 7, 4)
	sampRegisterChatCommand("text", function() enab.v = not enab.v end)
  	while true do
		wait(0)
		imgui.Process = enab.v
		if checkbox.v or checkbox123.v then
			for _, v in pairs(getAllObjects()) do
				local asd
				if sampGetObjectSampIdByHandle(v) ~= -1 then
					asd = sampGetObjectSampIdByHandle(v)
				end
				if isObjectOnScreen(v) then
					local _, x, y, z = getObjectCoordinates(v)
					local x1, y1 = convert3DCoordsToScreen(x,y,z)
					local model = getObjectModel(v)
					local x2,y2,z2 = getCharCoordinates(PLAYER_PED)
					local x10, y10 = convert3DCoordsToScreen(x2,y2,z2)
					local distance = string.format("%.1f", getDistanceBetweenCoords3d(x, y, z, x2, y2, z2))
					if checkbox.v then
						renderFontDrawText(font, (checkbox222.v and asd and "model = "..model.."; id = "..asd or "model = "..model).."; distance: "..distance, x1, y1, -1)
						if traser.v then
							renderDrawLine(x10, y10, x1, y1, 1.0, -1)
						end
					elseif checkbox123.v then
						for _, v2 in ipairs(tabl) do
							if v2[1].v == model and v2[3].v then
								 --map = addBlipForCoord(x,y,z)
								--changeBlipColour(map, 15421599)
								renderFontDrawText(font, (v2[2].v:find(".+") and u8:decode(v2[2].v) or checkbox333.v and asd and "model = "..model.."; id = "..asd or "model = "..model).."; distance: "..distance	, x1, y1, -1)
								if traser.v then
									renderDrawLine(x10, y10, x1, y1, 1.0, -1)
								end
							end
						end
					end
				end
			end
		end
	end
end

function ShowHelpMarker(param)
  imgui.TextDisabled('(?)')
  if imgui.IsItemHovered() then
    imgui.BeginTooltip()
    imgui.PushTextWrapPos(imgui.GetFontSize() * 35.0)
    imgui.TextUnformatted(param)
    imgui.PopTextWrapPos()
    imgui.EndTooltip()
  end
end

function imgui.OnDrawFrame()
  imgui.SetNextWindowPos(imgui.ImVec2(x2 / 2, y2 / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
  imgui.SetNextWindowSize(imgui.ImVec2(500, 400), imgui.Cond.FirstUseEver)
  imgui.Begin("Render objects", enab,imgui.WindowFlags.AlwaysAutoResize + imgui.WindowFlags.AlwaysUseWindowPadding + imgui.WindowFlags.NoResize + imgui.WindowFlags.AlwaysUseWindowPadding)
		imgui.Checkbox(u8("Find all objects"), checkbox)
		if checkbox.v then
			imgui.SameLine()
			imgui.Checkbox(u8("Write id next to the model"), checkbox222)
		end
		if imgui.Checkbox(u8("Find objects by conditions"), checkbox123) then
			inputs[1][1] = checkbox123.v
			--inicfg.save(inputs, "objwallhack")
		end
		if checkbox123.v then
			imgui.SameLine()
			imgui.Checkbox(u8("Write id next to the model"), checkbox333)
		end
    imgui.Checkbox(u8("enable tracer"), traser)
		imgui.InputInt(u8("Delete an object (visually)"), intbuffer, 0)
		if intbuffer.v ~= 0 then
			imgui.SameLine()
			if (imgui.Button(u8("Delete")) and sampGetObjectHandleBySampId(intbuffer.v) ~= -1) then
				deleteObject(sampGetObjectHandleBySampId(intbuffer.v))
				intbuffer.v = 0
			end
		end
    if imgui.Button(u8("Add new condition")) then
			table.insert(tabl, {imgui.ImInt(#tabl + 1), imgui.ImBuffer("", 20), imgui.ImBool(false)})
      table.insert(inputs, {#inputs, "", false})
      inicfg.save(inputs, "objwallhack")
    end
    if #inputs > 0 then
      if imgui.Button(u8("Remove last condition")) then
				table.remove(tabl, #tabl)
				table.remove(inputs, #inputs)
				inicfg.save(inputs, "objwallhack")
      end
    end
    imgui.BeginChild("inputs", imgui.ImVec2(700, 240), true)
			for i, val in ipairs(tabl) do
				if imgui.InputInt("##input"..i, val[1], 0, -1) then
					inputs[i + 1][1] = val[1].v
					inicfg.save(inputs, "objwallhack")
				end
				imgui.SameLine()
				ShowHelpMarker(u8("Object model"))
				imgui.SameLine()
				imgui.PushItemWidth(140)
					if imgui.InputText("##name: "..i, val[2]) then
						inputs[i + 1][2] = val[2].v
						inicfg.save(inputs, "objwallhack")
					end
				imgui.PopItemWidth()
				imgui.SameLine()
				ShowHelpMarker(u8("Name for the object (optional)"))
				imgui.SameLine()
				if imgui.Checkbox("##isfind"..i, val[3]) then
					inputs[i + 1][3] = val[3].v
					inicfg.save(inputs, "objwallhack")
				end
			end
    imgui.EndChild()
  imgui.End()
end