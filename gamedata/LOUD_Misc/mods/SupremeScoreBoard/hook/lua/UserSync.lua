local baseOnSync = OnSync
function OnSync()
    baseOnSync()

    --if Sync.TeamEco then
     --   import('/lua/ui/game/economy.lua').TeamEco = Sync.TeamEco
    --end
	--LOG(">>>> HUSAR: " .. " OnSync... "  )
								
	if Sync.SharedScore then
		LOG(">>>> HUSAR: " .. " UserSync syncing SharedScore... "  )
	
	    --import('/lua/ui/game/score.lua').sharedScores = Sync.Score
		--import('/lua/ui/game/score.lua').SharedScore = Sync.SharedScore
		--import('/mods/SupremeScoreBoard/lua/ui/game/score.lua').sharedScores = Sync.SharedScore
		import('/lua/ui/game/score.lua').sharedScores = Sync.SharedScore
		--import('/mods/ecoInfo/modules/ecoinfoUi.lua').updateMultipleUIs(Sync.updateEcoInfoPanels)
	end
	--if Sync.updateEcoInfoPanels then
	--	import('/mods/ecoInfo/modules/ecoinfoUi.lua').updateMultipleUIs(Sync.updateEcoInfoPanels)
	--end
	--
	--if Sync.removeEcoInfoPanels then
	--	import('/mods/ecoInfo/modules/ecoinfoUi.lua').removeMultipleUIs(Sync.removeEcoInfoPanels)
	--end
	
end
