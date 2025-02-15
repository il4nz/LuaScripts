script_name("sskin")
script_version_number("1")
script_version("1.0")
script_authors("forget. ") -- https://blast.hk/members/87483/
--[[
kogo zaebal:
 1. roma.caddy
]]

require "lib.sampfuncs"
local hook = require "lib.samp.events"
local MODEL

function main()
    if not isSampfuncsLoaded() or not isSampLoaded() then
        return
    end
    while not isSampAvailable() do
        wait(0)
    end


    sampRegisterChatCommand("fskin", cmd)

    wait(-1)
end

function cmd(par)
	local id = tonumber(par)
	if id ~= nil then
		MODEL = id
	else
		sampAddChatMessage(string.format("{FF0000}[FSKIN] {ffffff}Specify skin ID"), 0xFFFFFFFF)
		return false
	end
	if id >= 0  and id <= 311 then
		local _, id = sampGetPlayerIdByCharHandle(PLAYER_PED)
		set_player_skin(id, MODEL)
		sampAddChatMessage(string.format("{FFF08B}[FSKIN] {ffffff}You have chosen skin ID: {FFF08B}(%d)", MODEL), 0xFFFFFFFF)
	else
	sampAddChatMessage("{FFF08B}[FSKIN]: {ff0000} /fskin [0-311]", -1)
	end
end

function set_player_skin(id, skin)
 local BS = raknetNewBitStream()
 raknetBitStreamWriteInt32(BS, id)
 raknetBitStreamWriteInt32(BS, skin)
 raknetEmulRpcReceiveBitStream(153, BS)
 raknetDeleteBitStream(BS)
end
