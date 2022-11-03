local ticksPerSecond = 10					-- sim ticks per second
local ownArmyBrain = nil
local ownArmyIndex = -1

--[[
TODO:
- team overflow into new panel or eco panel
- lobby toggle option, whether obs may see stuff
--]]


function syncStats()

	LOG("*XDEBUG: " .. " starting collectSharedScore... "  )
	
	--WaitSeconds(1)
	--initSharedScore()
	collectSharedScore()
	WaitSeconds(1)
end

function collectSharedScore()
	while(true) do
		
		local putInfoToUser = {}
		local removeInfoFromUser = {}
		
		-- Initialize shared score data structure
		local sharedScore = {}

		for i, brain in ArmyBrains do

		   sharedScore[i] = {}
		   sharedScore[i].visible = true
		   
		   sharedScore[i].eco = {}
		   sharedScore[i].eco.reclaim = {}
		   sharedScore[i].eco.reclaim.mass = 0
		   sharedScore[i].eco.reclaim.energy = 0
		   sharedScore[i].eco.massin = {}
		   sharedScore[i].eco.massin.total = 0
		   sharedScore[i].eco.massin.rate = 0
		   sharedScore[i].eco.massout = {}
		   sharedScore[i].eco.massout.total = 0
		   sharedScore[i].eco.massout.rate = 0
		   sharedScore[i].eco.massover = 0
		   sharedScore[i].eco.energyin = {}
		   sharedScore[i].eco.energyin.total = 0
		   sharedScore[i].eco.energyin.rate = 0
		   sharedScore[i].eco.energyout = {}
		   sharedScore[i].eco.energyout.total = 0
		   sharedScore[i].eco.energyout.rate = 0
		   sharedScore[i].eco.energyover = 0
		   
		end

		-- get current army, if changed
		if not (ownArmyIndex == GetFocusArmy()) then

			if(GetFocusArmy() == -1) then
				ownArmyIndex = -1
				ownArmyBrain = nil
			else		
				for army, brain in ArmyBrains do
					if( army == GetFocusArmy()) then
						ownArmyIndex = army
						ownArmyBrain = brain
						Sync.removeAllEcoInfoPanels = true
					end
				end
			end
		end
	
		-- collect info
		for army, brain in ArmyBrains do	
		
			--if ((ArmyIsCivilian(army)) or (army == ownArmyIndex) ) then
			--	continue
            --end
			local massReclaim = 0
			
			if ((ArmyIsCivilian(army)) or (army == ownArmyIndex) ) then
				
				--sharedScore[army].visible = false
				-- nothing
				
			elseif ( (ArmyIsOutOfGame(army)) or 
					 ((brain:GetEconomyIncome('MASS') * ticksPerSecond) < 1) ) then
				-- dead player
				sharedScore[army].visible = false
				table.insert(removeInfoFromUser, {info = brain.Nickname})

			elseif( (ownArmyIndex < 0) -- add lobby condition
					or ((ownArmyIndex >= 0) and (IsAlly(army, ownArmyIndex)))
					) then
				
				-- teammate, or allowed observers
				massReclaim   = brain:GetArmyStat("Economy_Reclaimed_Mass", 0.0).Value or 0

				massStore = brain:GetEconomyStored('MASS')
				massIncome = brain:GetEconomyIncome('MASS') * ticksPerSecond
				massRequested = brain:GetEconomyRequested('MASS') * ticksPerSecond
				energyIncome = brain:GetEconomyIncome('ENERGY') * ticksPerSecond
				energyRequested = brain:GetEconomyRequested('ENERGY') * ticksPerSecond
				energyStore = brain:GetEconomyStored('ENERGY')
								
				sharedScore[army].visible = true
				
				local infoForBrain = {
					[1] = brain.Nickname,
					[2] = massIncome,
					[3] = energyIncome,
					[4] = massRequested - massIncome,
					[5] = massRequested - energyIncome,
					[6] = massStore,
					[7] = massReclaim
				}
				table.insert(putInfoToUser, infoForBrain)
			else
				-- opponent
				sharedScore[army].visible = false
				
				table.insert(removeInfoFromUser, {info = brain.Nickname})
			end
			
			sharedScore[army].eco.reclaim.mass = massReclaim

		end
		
		-- send everything to the user
		Sync.SharedScore = sharedScore
		Sync.removeEcoInfoPanels = removeInfoFromUser
		
		WaitSeconds(5)
	end
end