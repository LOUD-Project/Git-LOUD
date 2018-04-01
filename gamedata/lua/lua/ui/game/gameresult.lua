--* File: lua/modules/ui/game/gameresult.lua
--* Summary: Victory and Defeat behavior
--* Copyright © 2006 Gas Powered Games, Inc.  All rights reserved.

local OtherArmyResultStrings = {
    victory = '<LOC usersync_0001>%s wins!',
    defeat = '<LOC usersync_0002>%s has been defeated!',
    draw = '<LOC usersync_0003>%s receives a draw.',
    gameOver = '<LOC usersync_0004>Game Over.',
}

local MyArmyResultStrings = {
    victory = "<LOC GAMERESULT_0000>Victory!",
    defeat = "<LOC GAMERESULT_0001>You have been defeated!",
    draw = "<LOC GAMERESULT_0002>It's a draw.",
    replay = "<LOC GAMERESULT_0003>Replay Finished.",
}

function OnReplayEnd()
    import('/lua/ui/game/tabs.lua').TabAnnouncement('main', LOC(MyArmyResultStrings.replay))
    import('/lua/ui/game/tabs.lua').AddModeText("<LOC _Score>", function() import('/lua/ui/dialogs/score.lua').CreateDialog(true) end)
end

local announced = {}

function DoGameResult(armyIndex, result)

    if not announced[armyIndex] then
	
        announced[armyIndex] = true
		
        if armyIndex == GetFocusArmy() then
		
            if SessionIsObservingAllowed() then
                SetFocusArmy(-1)
            end
            
            if result == 'victory' then
			
                PlaySound(Sound({Bank = 'Interface', Cue = 'UI_END_Game_Victory'}))
				
            else
			
                PlaySound(Sound({Bank = 'Interface', Cue = 'UI_END_Game_Fail'}))
				
            end
            
            local victory = true
			
            if result == 'defeat' then
			
                victory = false
				
            end
            
            import('/lua/ui/game/tabs.lua').OnGameOver()
			
            import('/lua/ui/game/tabs.lua').TabAnnouncement('main', LOC(MyArmyResultStrings[result]))
            import('/lua/ui/game/tabs.lua').AddModeText("<LOC _Score>", function() import('/lua/ui/dialogs/score.lua').CreateDialog(victory) end)
			
        else
		
            local armies = GetArmiesTable().armiesTable
			
            import('/lua/ui/game/score.lua').ArmyAnnounce(armyIndex, LOCF(OtherArmyResultStrings[result], armies[armyIndex].nickname))
			
        end
		
    end
	
end
