
function CheckVictory(ScenarioInfo)

    local categoryCheck = false
	local victoryTime = false
	
	LOG("*AI DEBUG Launching CheckVictory for "..repr(ScenarioInfo.Options.Victory))
	
    if ScenarioInfo.Options.Victory == 'demoralization' then
        -- Assassination - dead commander
        categoryCheck = categories.COMMAND
		
	elseif ScenarioInfo.Options.Victory == 'decapitation' then
		-- Advanced Assassination - dead commander and no subcommanders
		categoryCheck = categories.COMMAND+categories.SUBCOMMANDER
		
    elseif ScenarioInfo.Options.Victory == 'domination' then
        -- You're dead if all structures and engineers are destroyed
        categoryCheck = categories.STRUCTURE+categories.ENGINEER - categories.WALL
		
    elseif ScenarioInfo.Options.Victory == 'eradication' then
        -- You're dead if you have no units
        categoryCheck = categories.ALLUNITS-categories.WALL
	
    else
        -- sandbox -- no victory condition
        categoryCheck = false
    end
	
	-- if not sandbox check for time limit --
	if categoryCheck and ScenarioInfo.Options.TimeLimitSetting != "0" then
		
		victoryTime = tonumber(ScenarioInfo.Options.TimeLimitSetting) * 60
		
		ScenarioInfo.VictoryTime = victoryTime
		
		LOG("*AI DEBUG Launching CheckVictory for "..repr(ScenarioInfo.Options.Victory).." and "..repr(victoryTime).." Seconds Time Limit")
		
	else
	
		ScenarioInfo.VictoryTime = false

	end
	

    local potentialWinners = {}
	
    local WaitTicks = coroutine.yield
	local IsAlly = IsAlly
	
	--local GetCurrentUnits = moho.aibrain_methods.GetCurrentUnits
	local GetListOfUnits = moho.aibrain_methods.GetListOfUnits
	
    while categoryCheck do
	
        WaitTicks(200)	-- loop every 20 seconds (was 6.5)
	
        -- Look for newly defeated brains and tell them they're dead
        local stillAlive = {}
		local counter = 0
		
        for index,brain in ArmyBrains do
		
            if not ArmyIsOutOfGame( brain.ArmyIndex ) and not ArmyIsCivilian( brain.ArmyIndex ) then
			
				local validunits = GetListOfUnits( brain, categoryCheck, false )
				
                if not validunits or table.getn(validunits) < 1 then

					-- kill all units
					local killacu = brain:GetListOfUnits(categories.ALLUNITS, false)
			
					for index,unit in killacu do
						unit:Kill()
					end
					
                    brain:OnDefeat()
					
                    CallEndGame(false, true)
					
					ArmyBrains[index] = nil
					
                else
                    stillAlive[counter+1] = brain
					counter = counter + 1
                end
            end
        end

        -- uh-oh, there is nobody alive... It's a draw.
        if table.empty(stillAlive) then
            CallEndGame(true, false)
            return
        end

        -- check to see if everyone still alive is allied and is requesting an allied victory.
        local win = true
        local draw = true

		-- win will only be true if everyone alive is allied
        for index,brain in stillAlive do
		
            for index2,other in stillAlive do
			
                if index != index2 then
				
                    if not brain.RequestingAlliedVictory or not IsAlly( brain.ArmyIndex, other.ArmyIndex ) then
                        win = false
						break
                    end
                end
            end
            if not brain.OfferingDraw then
                draw = false
            end
			if not win then
				break
			end
        end

        if win then
			-- this can never execute the first time thru as
			-- potentialWinners will be blank
            if table.equal(stillAlive, potentialWinners) then
			
                if GetGameTimeSeconds() > victoryTime then
                    #-- It's a win!
                    for index,brain in stillAlive do
                        brain:OnVictory()
                    end
					
                    CallEndGame(true, true)
					
                    return
					
                end
			
			-- so the first time thru here we set up a victoryTime and
			-- we set the potentialWinners list to be the same as those
			-- who are left alive
            else
			
                victoryTime = GetGameTimeSeconds() + 15
				
                potentialWinners = stillAlive
				
            end
			
        elseif draw or (victoryTime and GetGameTimeSeconds() > victoryTime) then
		
            for index,brain in stillAlive do
                brain:OnDraw()
            end
			
            CallEndGame(true, true)
            return
			
        else
            potentialWinners = {}
			
			if victoryTime and (GetGameTimeSeconds()+300) >victoryTime then
				PrintText( 'The game will end in '..repr(math.floor(victoryTime - GetGameTimeSeconds()))..' seconds', 18, 'ffffffff', 4, 'center')
			end
        end
    end
	
	LOG("*AI DEBUG Exiting CheckVictory for sandbox")
	
end

function CallEndGame(callEndGame, submitXMLStats)
    if submitXMLStats then
        SubmitXMLArmyStats()
    end
    if callEndGame then
        gameOver = true
        ForkThread(function()
            WaitSeconds(3)
            EndGame()
        end)
    end
end

gameOver = false