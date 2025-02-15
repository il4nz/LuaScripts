local k = 0
local p,h = playerPed, playerHandle
function main()
repeat wait(0) until isSampAvailable()
 while true do wait(0)
  	if isCharOnFoot(p) then
	     k = true
	 end
	if isCharInAnyCar(p) and k then
		local car = sampGetVehicleIdByCarHandle(storeCarCharIsInNoSave(p))
		local b = car
		if car == b then
		  k = false
		    setPlayerEnterCarButton(h, false)
		      wait(1000)
		    setPlayerEnterCarButton(h, true)
		  b = 666.666
	           end
	end
         end
end