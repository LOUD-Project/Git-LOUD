local ParentBeginSession = BeginSession
function BeginSession()
	ParentBeginSession()
	LOG(">>>> HUSAR: " .. " simInit forking thread scoreStats.lua - syncStats... "  )
	
	--ForkThread(import('/mods/SupremeScoreBoard/modules/scoreStats.lua').syncStats)
end