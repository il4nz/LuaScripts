script_name("Infinite Run")
script_description("Infinite run with automatic activation")
script_author("checkdasound")

local mem = require "memory"

function main()
	while true do
	wait(0)
		if isSampAvailable() then
			--mem.setint8(0xB7CEE4, 1)
			mem.setint8(0xB7CEE4, 0)
		end
	end
end