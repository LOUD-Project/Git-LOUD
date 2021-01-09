
local baseBeginSession = BeginSession
function BeginSession()
    baseBeginSession()
    ForkThread(function() 
		while true do
			import('/mods/UI-Party/modules/simSyncUnitEcoFix.lua').Invoke()
			WaitTicks(1)
		end
	end)

end
