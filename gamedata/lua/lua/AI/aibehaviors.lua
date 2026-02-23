--**  File     :  /lua/AIBehaviors.lua

local import = import

local AIAddMustScoutArea                                    = import('/lua/ai/aiutilities.lua').AIAddMustScoutArea
local AIFindTargetInRangeInCategoryWithThreatFromPosition   = import('/lua/ai/aiattackutilities.lua').AIFindTargetInRangeInCategoryWithThreatFromPosition
local AIGetMarkerLocations                                  = import('/lua/ai/aiutilities.lua').AIGetMarkerLocations
local AISortScoutingAreas                                   = import('/lua/loudutilities.lua').AISortScoutingAreas
local CreateUnitDestroyedTrigger                            = import('/lua/scenarioframework.lua').CreateUnitDestroyedTrigger
local GetBasePerimeterPoints                                = import('/lua/loudutilities.lua').GetBasePerimeterPoints
local GetDirectionInDegrees                                 = import('/lua/utilities.lua').GetDirectionInDegrees
local GetEnemyUnitsInRect                                   = import('/lua/loudutilities.lua').GetEnemyUnitsInRect
local GetHiPriTargetList                                    = import('/lua/loudutilities.lua').GetHiPriTargetList
local GetOwnUnitsAroundPoint                                = import('/lua/ai/aiutilities.lua').GetOwnUnitsAroundPoint
local RandomLocation                                        = import('/lua/ai/aiutilities.lua').RandomLocation

local ForkThread            = ForkThread
local ForkTo                = ForkThread
local GetArmyUnitCap        = GetArmyUnitCap
local GetArmyUnitCostTotal  = GetArmyUnitCostTotal
local GetSurfaceHeight      = GetSurfaceHeight
local GetTerrainHeight      = GetTerrainHeight
local LOUDABS               = math.abs
local LOUDCOPY              = table.copy
local LOUDENTITY            = EntityCategoryContains
local LOUDEQUAL             = table.equal
local LOUDFLOOR             = math.floor
local LOUDGETN              = table.getn
local LOUDINSERT            = table.insert
local LOUDLERP              = MATH_Lerp
local LOUDLOG               = math.log10
local LOUDMAX               = math.max
local LOUDMIN               = math.min
local LOUDPOW               = math.pow
local LOUDREMOVE            = table.remove
local LOUDSORT              = table.sort
local LOUDSQUARE            = math.sqrt
local LOUDTIME              = GetGameTimeSeconds
local Random                = Random
local VDist2Sq              = VDist2Sq
local VDist3                = VDist3
local WaitSeconds           = WaitSeconds
local WaitTicks             = coroutine.yield


local GetPosition                   = moho.entity_methods.GetPosition	

local AIBrainMethods = moho.aibrain_methods

local AssignUnitsToPlatoon          = AIBrainMethods.AssignUnitsToPlatoon
local GetEconomyStored              = AIBrainMethods.GetEconomyStored
local GetEconomyStoredRatio         = AIBrainMethods.GetEconomyStoredRatio
local GetEconomyTrend               = AIBrainMethods.GetEconomyTrend
local GetUnitsAroundPoint           = AIBrainMethods.GetUnitsAroundPoint
local GetNumUnitsAroundPoint        = AIBrainMethods.GetNumUnitsAroundPoint
local GetThreatsAroundPosition      = AIBrainMethods.GetThreatsAroundPosition
local GetThreatAtPosition           = AIBrainMethods.GetThreatAtPosition
local MakePlatoon                   = AIBrainMethods.MakePlatoon
local PlatoonExists                 = AIBrainMethods.PlatoonExists

local PlatoonMethods = moho.platoon_methods

local AttackTarget                  = PlatoonMethods.AttackTarget
local CalculatePlatoonThreat        = PlatoonMethods.CalculatePlatoonThreat
local GetBrain                      = PlatoonMethods.GetBrain
local GetPlatoonPosition            = PlatoonMethods.GetPlatoonPosition
local GetPlatoonUnits               = PlatoonMethods.GetPlatoonUnits
local GetSquadUnits                 = PlatoonMethods.GetSquadUnits
local MoveToLocation                = PlatoonMethods.MoveToLocation

local UnitMethods = moho.unit_methods

local GetAIBrain                    = UnitMethods.GetAIBrain
local GetBuildRate                  = UnitMethods.GetBuildRate
local IsIdleState                   = UnitMethods.IsIdleState
local IsUnitState                   = UnitMethods.IsUnitState
local SetCustomName                 = UnitMethods.SetCustomName

PlatoonMethods = nil
UnitMethods = nil

function CommanderThread( platoon, aiBrain )

    local WaitTicks = WaitTicks

	local cdr = GetPlatoonUnits(platoon)[1]

	if platoon.PlatoonData.aggroCDR then

		local size = ScenarioInfo.size[1]
		
		if ScenarioInfo.size[2] > size then
			size = ScenarioInfo.size[2]
		end
		
		cdr.Mult = (size * 0.5) * 0.01
		size = nil
	end
	
	local Mult = cdr.Mult or 1
	
	local NextTaunt = GetGameTimeSeconds() + 660 + Random(1,660)
    
	cdr.CDRHome = LOUDCOPY(GetPosition(cdr))
    
    ForkThread ( LifeThread, aiBrain, cdr )
	
	local moveWait = 0

	-- So - this loop runs on top of everything the commander might otherwise be doing
	-- ie. - this is usually building, or trying to build something
	-- the loop cycles over every 4.5 seconds
    while not cdr.Dead do
		
		Mult = 1
		
        WaitTicks(46)
	
        -- See if Bob needs to fight
        if not cdr.Dead then
		
			CDROverCharge( aiBrain, cdr)
		end
		
		-- Run Away when hurt
        if not cdr.Dead then
		
			CDRRunAway( aiBrain, cdr )
		end
		
		-- if Bob was building something and was distracted
		if not cdr.Dead then
		
			CDRFinishUnit( aiBrain, cdr )
		end
		
        -- Go back to base when outside tether
        if not cdr.Dead then
		
			CDRReturnHome( aiBrain, cdr, Mult ) 
		end
		
		-- Wander around when idle too long
        if not cdr.Dead and moveWait >= 10 then 
		
			CDRHideBehavior( aiBrain, cdr )     -- this will run for 8 seconds
			
			moveWait = 0
			
		else
		
			moveWait = moveWait + 1
		end
		
        -- resume building
        if not cdr.Dead and IsIdleState(cdr) and (not cdr.Fighting) and (not cdr.Upgrading) and (not IsUnitState( cdr, "Building"))
			and (not cdr:IsUnitState("Attacking")) and (not cdr:IsUnitState("Repairing")) and (not cdr.UnitBeingBuiltBehavior) and (not cdr:IsUnitState("Upgrading"))
			and (not cdr:IsUnitState("Enhancing")) then
		
            if not cdr.EngineerBuildQueue or LOUDGETN(cdr.EngineerBuildQueue) == 0 then
				
				cdr.UnitBeingBuiltBehavior = false
            end
        end

		-- if GetGameTimeSeconds() > NextTaunt then
		
			-- SUtils.AIRandomizeTaunt(aiBrain)
			-- NextTaunt = GetGameTimeSeconds() + 660 + Random(1,660)
			
		-- end
		
    end
	
end

-- This is a special 'resource' thread that runs on the ACU
-- It essentially only comes into play when he crashes his eco
-- and then provides upto a certain amount of compensation
-- the effect of this is very very subtle, so we leave it obscured
-- would be really nice it we could tie it to resources that had overflowed
function LifeThread( aiBrain, cdr )

    local mincome, mrequested, mneeded
    local eincome, erequested, eneeded
    
    local GetEconomyIncome      = AIBrainMethods.GetEconomyIncome
    local GetEconomyRequested   = AIBrainMethods.GetEconomyRequested
    local GetEconomyStoredRatio = GetEconomyStoredRatio
    local GiveResource          = AIBrainMethods.GiveResource 
    local TakeResource          = AIBrainMethods.TakeResource
    local WaitTicks             = WaitTicks
    
    local MATHMIN = LOUDMIN
    
    local shortcount = 0
    local mcount = 0
    local mgiven = 0
    local ecount = 0
    local egiven = 0

    while true do
    
        WaitTicks(11)
        
        if GetEconomyStoredRatio( aiBrain, 'MASS') < .01 then
        
            mincome = GetEconomyIncome( aiBrain, 'MASS')
            mrequested = GetEconomyRequested( aiBrain, 'MASS')
            
            if mrequested > mincome then
            
                -- upto 10
                mneeded = MATHMIN(10,((mrequested - mincome ) * 10))
                
                GiveResource( aiBrain, 'Mass', mneeded)
                
                mgiven = mgiven + mneeded
            end
        end
        
        if GetEconomyStoredRatio( aiBrain, 'ENERGY') < .01 then
        
            eincome = GetEconomyIncome( aiBrain, 'ENERGY')
            erequested = GetEconomyRequested( aiBrain, 'ENERGY')
            
            if erequested > eincome then
            
                -- upto 120
                eneeded = MATHMIN(120,((erequested - eincome ) * 10))
                
                GiveResource( aiBrain, 'Energy', eneeded)
                
                egiven = egiven + eneeded
                
            end
        end
        
        if GetEconomyStoredRatio( aiBrain, 'MASS') >= 1 and mgiven > 0 then
        
            TakeResource( aiBrain, 'Mass', math.min( mgiven, 10 ))
            
            mgiven = mgiven - math.min( mgiven, 10 )
        end
        
        if GetEconomyStoredRatio( aiBrain, 'ENERGY') >= 1 and egiven > 0 then
        
            TakeResource( aiBrain, 'Energy', math.min( egiven, 120 ))
            
            egiven = egiven - math.min( egiven, 120 )
        end
        
        if mgiven != mcount or egiven != ecount then
        
            shortcount = shortcount + 1

            LOG("*AI DEBUG "..aiBrain.Nickname.." Lifetime thread M "..string.format("%.1f",mgiven).."  E "..string.format("%.1f",egiven).." Shortage Count "..shortcount )
            
            mcount = mgiven
            ecount = egiven
            
        end
    end
end

-- functions used by Commander Thread
function CDROverCharge( aiBrain, cdr ) 

	-- assume there is nothing to respond to
	local commanderResponse = false
	local distressLoc = false
	local distressType = false
	
	local distressRange = 80
	
	local totalPercent = 0;
	
	-- get status of Bobs Shield (if he has one)
	if cdr:ShieldIsOn() then

		totalPercent = ((cdr:GetHealth() + cdr.MyShield:GetHealth()) / (cdr:GetMaxHealth() + cdr.MyShield:GetMaxHealth()))
	else
		totalPercent = cdr:GetHealthPercent()
	end
	
	-- if Bob is in condition to fight and isn't in distress -- see if there is an alert
	if totalPercent > .74 and not aiBrain.CDRDistress then

		local EM = aiBrain.BuilderManagers.MAIN.EngineerManager
		
		if EM.BaseMonitor.ActiveAlerts > 0 then
	
			-- checks for a Land distress alert at this base
			distressLoc, distressType = EM:BaseMonitorGetDistressLocation( aiBrain, EM.Location, distressRange, 6, 'Land')
			
		end
	
		-- if there is a LAND distress call 
		if (distressLoc and distressType == 'Land')  then
	
			local GetNumUnitsAroundPoint = GetNumUnitsAroundPoint
	
			local distressUnitsNaval = GetNumUnitsAroundPoint( aiBrain, categories.NAVAL, distressLoc, 60, 'Enemy' ) 
			local distressUnitsAir = GetNumUnitsAroundPoint( aiBrain, categories.AIR * (categories.BOMBER + categories.GROUNDATTACK) - categories.ANTINAVY, distressLoc, 60, 'Enemy' ) 
			local distressUnitsexp = GetNumUnitsAroundPoint( aiBrain, categories.EXPERIMENTAL, distressLoc, 150, 'Enemy' )
		
			if distressUnitsNaval > 2  or distressUnitsAir > 5 or distressUnitsexp > 0 then	
			
				return	-- we're not fighting
				
			else
			
				commanderResponse = true
				
			end
		
		else
		
			return
			
		end
	
		-- if the distress location is within allowed range
		if distressLoc and VDist3( distressLoc, cdr.CDRHome ) < distressRange then

			-- store anything he might be building
			cdr.UnitBeingBuiltBehavior = cdr.UnitBeingBuilt or false
			
			-- mark him as fighting so that EM will not give him a job to do
			cdr.Fighting = true
			
			cdr.Upgrading = false
			
			-- disband exsiting platoon directly, bypassing code that would have him seek another job
			if cdr.PlatoonHandle and cdr.PlatoonHandle != aiBrain.ArmyPool then
			
				if PlatoonExists(aiBrain, cdr.PlatoonHandle) then
				
					--LOG("*AI DEBUG "..aiBrain.Nickname.." CDR disbands "..cdr.PlatoonHandle.BuilderName)
					cdr.PlatoonHandle:PlatoonDisband( aiBrain )
					
				end

			end

			-- create a platoon for fighting
			local plat = MakePlatoon( aiBrain,'CDRFights','none')
			
			AssignUnitsToPlatoon( aiBrain, plat, {cdr}, 'Attack', 'None' )
			plat.BuilderName = 'CDR Fights'		
			
			IssueClearCommands( {cdr} )
			
			-- set target priorities
			local priList = { categories.ENGINEER, categories.INDIRECTFIRE, categories.DIRECTFIRE, categories.CONSTRUCTION, categories.STRUCTURE }
			
			plat:SetPrioritizedTargetList( 'Attack', priList )
			cdr:SetTargetPriorities( priList )
			
			local target = false
			local continueFighting = true
			
			-- get the stats on his overcharge weapon
			local weapBPs = cdr:GetBlueprint().Weapon
			local weapon
		
			for _,v in weapBPs do
				if v.Label == 'OverCharge' then
					weapon = v
					break
				end
			end

			local maxRadius = weapon.MaxRadius * 4.55 -- * Mult
			local weapRange = weapon.MaxRadius		
		
			local id = cdr:GetEntityId()
			
			-- set the overcharge delay to RateOfFire / 1 ( ie.  1/0.2 = 5 seconds)
			local overchargedelay = math.ceil(1/weapon.RateOfFire)
			
			-- set the recharge counter to maximum (indicates ready to fire)
			local counter = overchargedelay
			
			local cdrThreat = cdr:GetBlueprint().Defense.SurfaceThreatLevel
			
			local enemyThreat
            local friendlyThreat
		
			local GetThreatAtPosition = GetThreatAtPosition

			-- go and fight now
			while continueFighting and not cdr.Dead do
			
				local overcharging = false
				local cdrCurrentPos = GetPosition(cdr)
				
				-- range check --
				if CDRReturnHome( aiBrain, cdr, .9 ) then
				
					continueFighting = false
					cdr.Fighting = false
					
					return
					
				end
				
				if not target then
				
					FloatingEntityText(id,'Time for something to die..')
				
					IssueClearCommands( {cdr} )
					IssueFormAggressiveMove( GetPlatoonUnits(plat), distressLoc, 'AttackFormation', 0 )
				
				end
				
				WaitTicks(30)
				
				-- if ready to fire and not target, or target is dead, or target is out of range - look for a new target
				if counter >= overchargedelay and ( (not target) or (target.Dead) or (target and (not target.Dead) and  VDist3(GetPosition(cdr), GetPosition(target)) > maxRadius)) then
					
					-- find a priority target in weapon range
					for k,v in priList do
					
						if PlatoonExists( aiBrain, plat ) then
						
							target = plat:FindClosestUnit( 'Attack', 'Enemy', true, v )
					
							if target and VDist3(GetPosition(cdr), GetPosition(target)) < maxRadius then
						
								local cdrLayer = cdr:GetCurrentLayer()
								local targetLayer = target:GetCurrentLayer()
						
								if cdrLayer == 'Land' and (targetLayer == 'Land' or targetLayer == 'Water') then
								
									break
									
								else
								
									target = false
									
								end
								
							else
							
								target = false
								
							end
							
						end
						
					end
					
					-- found a priority target in weapon range --
					if target then
					
						local targetPos = GetPosition(target)
					
						enemyThreat = GetThreatAtPosition( aiBrain, targetPos, 0, true, 'AntiSurface')
						friendlyThreat = GetThreatAtPosition( GetAIBrain(target), targetPos, 0, true, 'AntiSurface')
		
						if target and (GetEconomyStored(aiBrain,'ENERGY') >= weapon.EnergyRequired) and (not target.Dead) and (VDist3(GetPosition(cdr), GetPosition(target)) <= weapRange) then
						
							FloatingEntityText(id,'Eat some of this...')
							
							overcharging = true		# set recharging flag
							IssueClearCommands({cdr})

							IssueOverCharge( {cdr}, target )

							LOG("*AI DEBUG "..aiBrain.Nickname.." Overcharge fired!")
							counter = 0
						
						elseif target and not target.Dead then

							local tarPos = GetPosition(target)

							IssueClearCommands( {cdr} )
							IssueAttack( {cdr}, target )
						end
					
						if enemyThreat > (friendlyThreat * 1.25) + cdrThreat then
						
							--LOG("*AI DEBUG "..aiBrain.Nickname.." Commander target threat too high")
							
							FloatingEntityText(id,'Yikes! Much too hot for me..')
							
							target = false
							continueFighting = false
						end
						
					-- can't find a target in range yet keep moving towards distress --
					elseif distressLoc then

						enemyThreat = GetThreatAtPosition( aiBrain, distressLoc, 0, true, 'AntiSurface')
						friendlyThreat = GetThreatAtPosition( aiBrain, distressLoc, 0, true, 'AntiSurface', aiBrain.ArmyIndex )
					
						if enemyThreat > (friendlyThreat * 1.25) + cdrThreat then
						
							LOG("*AI DEBUG "..aiBrain.Nickname.." Commander ALERT position threat "..enemyThreat.." is too high for my "..((friendlyThreat * 1.25) + cdrThreat))
							
							continueFighting = false
							
						elseif ( VDist3( distressLoc, cdr.CDRHome ) < distressRange ) then
							
							IssueClearCommands( {cdr} )
							IssueMove( {cdr}, distressLoc )
						end
                        
                        if enemyThreat < 10 then
                        
                            continueFighting = false
                        end
					end
				end

				-- increment the overcharge available counter
				if continueFighting then
				
					WaitTicks(10)
					counter = counter + 1
				end
		
				if EM.BaseMonitor.ActiveAlerts > 0 then
					-- rechecks for a Land distress alert at this base
					distressLoc, distressType = EM:BaseMonitorGetDistressLocation( aiBrain, EM.Location, distressRange, 6, 'Land')
				end

				-- did Bob die ?
				if cdr.Dead then
					aiBrain.CDRDistress = nil
					return
				end
				
				totalPercent = 1
				
				-- should Bob keep fighting ?
				if cdr:ShieldIsOn() then
					totalPercent = ((cdr:GetHealth() + cdr.MyShield:GetHealth()) / (cdr:GetMaxHealth() + cdr.MyShield:GetMaxHealth()))
				else
					totalPercent = cdr:GetHealthPercent();
				end
				
				if not distressLoc or ( VDist3( distressLoc, cdr.CDRHome ) > distressRange ) or (totalPercent < .75) then
				
					continueFighting = false
				end
			end
			
			IssueClearCommands( {cdr} )
			
			-- disband the commanders combat platoon so that he looks for another job
			if PlatoonExists( aiBrain, plat) then
			
				ForkThread(cdr.PlatoonHandle.PlatoonDisband, cdr.PlatoonHandle, aiBrain )
			end
			
			cdr.Fighting = false
		end
	end
	
end

function CDRRunAway( aiBrain, cdr )

	local totalPercent = 0

	-- note: ShieldIsOn will return false if the commander doesn't have a shield or it's off
	-- this replaced a whole series of specific checks to see if he actually has a shield upgrade
	if cdr:ShieldIsOn() then
		totalPercent = ((cdr:GetHealth() + cdr.MyShield:GetHealth()) / (cdr:GetMaxHealth() + cdr.MyShield:GetMaxHealth()))
	else 
		totalPercent = cdr:GetHealthPercent()
	end
	
	-- if the CDR is hurt
    if totalPercent < .75  then

		local GetNumUnitsAroundPoint = GetNumUnitsAroundPoint
		
        local nmeAir        = GetNumUnitsAroundPoint( aiBrain, categories.BOMBER + categories.GROUNDATTACK - categories.ANTINAVY, cdr.CDRHome, 75, 'Enemy' )
        local nmeLand       = GetNumUnitsAroundPoint( aiBrain, categories.COMMAND + (categories.LAND - categories.ANTIAIR), cdr.CDRHome, 75, 'Enemy' )
		local nmeHardcore   = GetNumUnitsAroundPoint( aiBrain, categories.EXPERIMENTAL, cdr.CDRHome, 120, 'Enemy' )
		
		-- immediate threats nearby - time to run		
        if nmeAir > 5 or nmeLand > 0 or nmeHardcore > 0 then
		
			local cdrPos = GetPosition(cdr)
		
			if not aiBrain.CDRDistress then
		
				LOG("*AI DEBUG Commander " .. aiBrain.Nickname .. " sounds COMMANDER DISTRESS")
				aiBrain.CDRDistress = cdrPos

				-- mark him as fighting so that EM will not give him a job to do
				cdr.Fighting = true
			
				cdr.Upgrading = false
				
				-- forget about continuing to build
				cdr.UnitBeingBuiltBehavior = false

				-- disband existing platoon directly so he bypasses the code that would have him seek a new job
				if cdr.PlatoonHandle and cdr.PlatoonHandle != aiBrain.ArmyPool then
			
					if PlatoonExists( aiBrain, cdr.PlatoonHandle ) then
				
						cdr.PlatoonHandle:PlatoonDisband( aiBrain )
					end
				end
			end		
			
			-- determine category of what he should run to (default is ground defense)
            local category = categories.DIRECTFIRE
			
			-- see if there are any shields nearby first
			local nmaShield = GetNumUnitsAroundPoint( aiBrain, categories.SHIELD, cdrPos, 60, 'Ally' )

			local runShield = false
			
			if nmaShield > 0 then
			
				category = categories.SHIELD 
				runShield = true
				
			-- head for AA if air units
            elseif nmeAir > 5 then
			
                category = categories.ANTIAIR
            end
			
            local runSpot, prevSpot
			
			-- the commander will stay in this loop while less than 75% health and enemy units are present
            while ( (not cdr.Dead) and (totalPercent < .77) ) and ( nmeAir > 5 or nmeLand > 0 or nmeHardcore > 0 ) do

				FloatingEntityText( cdr:GetEntityId(),'Running for cover...')
				
                runSpot = import('/lua/ai/altaiutilities.lua').AIFindDefensiveAreaSorian( aiBrain, cdr, category, 80, runShield )
				
				if not runSpot or (prevSpot and runSpot[1] == prevSpot[1] and runSpot[3] == prevSpot[3]) then

					runSpot = RandomLocation( aiBrain.StartPosX, aiBrain.StartPosZ )
				end
				
                if not prevSpot or runSpot[1] ~= prevSpot[1] or runSpot[3] ~= prevSpot[3] then

					IssueClearCommands( {cdr} )

                    if VDist2( cdrPos[1], cdrPos[3], runSpot[1], runSpot[3] ) >= 10 then
					
						IssueMove( {cdr}, runSpot )
						prevSpot = LOUDCOPY(runSpot)
                    end
                end

                WaitTicks(200)
				
				-- retest the run away conditions
                if not cdr.Dead then
				
                    cdrPos = GetPosition(cdr)
					
					nmeAir      = GetNumUnitsAroundPoint( aiBrain, categories.BOMBER + categories.GROUNDATTACK - categories.ANTINAVY, cdr.CDRHome, 75, 'Enemy' )
					nmeLand     = GetNumUnitsAroundPoint( aiBrain, categories.COMMAND + (categories.LAND - categories.ANTIAIR), cdr.CDRHome, 75, 'Enemy' )
					nmeHardcore = GetNumUnitsAroundPoint( aiBrain, categories.EXPERIMENTAL, cdr.CDRHome, 120, 'Enemy' )
					
					totalPercent = 1	-- default if no shield upgrade

					if cdr:ShieldIsOn() then
						totalPercent = ((cdr:GetHealth() + cdr.MyShield:GetHealth()) / (cdr:GetMaxHealth() + cdr.MyShield:GetMaxHealth()))
					else 
						totalPercent = cdr:GetHealthPercent()
					end
                end
            end
			
			aiBrain.CDRDistress = nil
			
			LOG("*AI DEBUG "..aiBrain.Nickname.." Commander Distress DEACTIVATED")
			
			IssueClearCommands( {cdr} )
        end
	
		-- since the CDR should be floating around in DelayAssignEngineerTask at this point
		-- setting this to false should allow him to get a new engineer job
		cdr.Fighting = false
    end
	
end

function CDRReturnHome( aiBrain, cdr, Mult )

	local radius = 80
	local distance = VDist3(GetPosition(cdr), cdr.CDRHome)
	
    if (not cdr.Dead) and distance > (radius*Mult) then
		
        local plat = MakePlatoon( aiBrain, 'CDRReturnHome', 'none' )
		
        AssignUnitsToPlatoon( aiBrain, plat, {cdr}, 'Support', 'None' )
		plat.BuilderName = 'CDRReturnHome'
		
		IssueClearCommands( {cdr} )
		IssueMove( {cdr}, cdr.CDRHome )
        
        WaitTicks(75)
		
		plat:SetAIPlan('ReturnToBaseAI',aiBrain)
		
		return true
	end
	
	if cdr.Dead then
	
		aiBrain.CDRDistress = nil
		return true
	end
	
	return false
	
end

function CDRFinishUnit( aiBrain, cdr )
	
    if cdr.UnitBeingBuiltBehavior then

		if not cdr.UnitBeingBuiltBehavior:BeenDestroyed() then
		
			IssueClearCommands( {cdr} )
			
			IssueRepair( {cdr}, cdr.UnitBeingBuiltBehavior )
		
			FloatingEntityText( cdr:GetEntityId(),' Finishing Unit ')
		end
	end

    cdr.UnitBeingBuiltBehavior = false
end

-- When idle, the ACU will exhibit a 'hide' behavior and run for certain defensive positions
-- Modified this so that he doesn't run like this if there's no place to run to - the original
-- Sorian code would have the ACU run to the 'top left' of the base every time in this case
function CDRHideBehavior( aiBrain, cdr )

	if IsIdleState(cdr) then
		
        cdr.Fighting = true
        cdr.Upgrading = false
	    
        local category = false
		
		local nmaShield = GetNumUnitsAroundPoint( aiBrain, categories.SHIELD, cdr.CDRHome, 100, 'Ally' )
		local nmaAA = GetNumUnitsAroundPoint( aiBrain, categories.ANTIAIR * categories.DEFENSE, cdr.CDRHome, 80, 'Ally' )
        local nmaDF = GetNumUnitsAroundPoint( aiBrain, categories.DIRECTFIRE, cdr.CDRHome, 80, 'Ally' )
		
		local runShield = false
		local runSpot = false

		if nmaShield > 0 then
		
			category = categories.SHIELD
			runShield = true
			
		elseif nmaAA > 0 then
		
			category = categories.DEFENSE * categories.ANTIAIR
			
		elseif nmaDF > 0 then
        
     		category = categories.DIRECTFIRE
        end
	
		if category then
	
            local id = cdr:GetEntityId()
		
            FloatingEntityText(id,'Inspection Tour...')
		
            local plat = MakePlatoon( aiBrain, 'CDRWander', 'none' )
		
            plat.BuilderName = 'CDRWander'
		
            AssignUnitsToPlatoon( aiBrain, plat, {cdr}, 'Support', 'None' )
		
            IssueClearCommands( {cdr} )		
		
			runSpot = import('/lua/ai/altaiutilities.lua').AIFindDefensiveAreaSorian( aiBrain, cdr, category, 100, runShield )
			
			IssueClearCommands( {cdr} )
			IssueMove( {cdr}, runSpot )

            WaitTicks(75)
		
            plat:SetAIPlan('ReturnToBaseAI',aiBrain)		
        end
	end

    cdr.Fighting = false
end

-- for enhancements (not upgrades) on the COMMANDER
function CDREnhance( self, aiBrain )

    local units = GetPlatoonUnits(self)
    
    local PlatoonData = self.PlatoonData
	
    local ClearTaskOnComplete = PlatoonData.ClearTaskOnComplete
    
	local finalenhancement = PlatoonData.Enhancement[LOUDGETN(PlatoonData.Enhancement)]
    
    local ACUEnhanceDialog = ScenarioInfo.ACUEnhanceDialog
	
	local unit

    for _,v in units do
	
		if not v.Dead and LOUDENTITY(categories.COMMAND, v) then
		
			unit = v
			
			if unit:HasEnhancement(finalenhancement) then
			
				local EM = aiBrain.BuilderManagers[unit.LocationType].EngineerManager
				
				AssignUnitsToPlatoon( aiBrain, 'ArmyPool', {unit}, 'Support', 'None' )
				
				ForkThread( EM.AssignEngineerTask, EM, unit, aiBrain )
				
				break
			end
		end
	end
	
	if unit then
	
		IssueStop({unit})
		IssueClearCommands({unit})
		
		local IsIdleState = IsIdleState
		local IsUnitState = IsUnitState
		
		for _,v in PlatoonData.Enhancement do
		
			if not unit.Dead and not unit:HasEnhancement(v) then
			
				if not unit:HasEnhancement(v) then
				
                    if ACUEnhanceDialog then
                        LOG("*AI DEBUG "..aiBrain.Nickname.." CDREnhance waiting to start "..repr(v) )
                    end
				
					repeat
						WaitTicks(11)
					until IsIdleState(unit) or unit.Dead
					
					if not unit.Dead then

						IssueScript( {unit}, {TaskName = "EnhanceTask", Enhancement = v} )

                        unit.CurrentBuildOrder = 'Enhance'
                        unit.DesiresAssist = true
                        unit.IssuedBuildCommand = true
                        unit.NumAssistees = 3
					end
				end
				
				local stallcount = 0
				
				repeat
				
					WaitTicks(10)

					stallcount = stallcount + 1
					
				until unit.Dead or IsUnitState(unit,'Enhancing') or stallcount > 10

				if IsUnitState(unit,'Enhancing') then
                
                    -- flag will be used to indicate enhancement as well as upgrading
                    unit.Upgrading = true
                    
                    -- yes - we are building ourselves --
                    unit.UnitBeingBuilt = unit

                    WaitTicks(11)				

					if ACUEnhanceDialog then
						LOG("*AI DEBUG "..aiBrain.Nickname.." CDREnhance enhancing for "..repr(v) )
					end

					repeat
				
						WaitTicks(61)
					
					until not IsUnitState(unit,'Enhancing') or unit.Dead 
				end
                
                unit.CurrentBuildOrder = false
                unit.DesiresAssist = false
                unit.IssuedBuildCommand = false
                unit.NumAssistees = 1    

                unit.Upgrading = false
                unit.UnitBeingBuilt = false
				
				break
			else
			
                WaitTicks(5)
            end
		end
	end
	
	if unit and unit:HasEnhancement(finalenhancement) and ClearTaskOnComplete then
	
		local manager = 'PlatoonFormManager'
		
		if self.BuilderManager == 'EM' then
			manager = 'EngineerManager'
		end
		
		if self.BuilderManager == 'FBM' then
			manager = 'FactoryManager'
		end
		
		local buildertable = aiBrain.BuilderManagers[self.BuilderLocation][manager]['BuilderData'][self.BuilderType]
		
		for a,b in buildertable['Builders'] do
		
			if b.BuilderName == self.BuilderName then
				b:SetPriority(0,false)
				break
			end
		end
	end
	
	return self:SetAIPlan('ReturnToBaseAI',aiBrain)
end

 
function AirScoutingAI( self, aiBrain )

	local GetNumUnitsAroundPoint    = GetNumUnitsAroundPoint
    local GetPlatoonPosition        = GetPlatoonPosition
    local GetPlatoonUnits           = GetPlatoonUnits    
	local GetSquadUnits             = GetSquadUnits
	local GetThreatsAroundPosition  = GetThreatsAroundPosition
	local GetUnitsAroundPoint       = GetUnitsAroundPoint    
 	local PlatoonExists             = PlatoonExists	
    local Random                    = Random    

    local LOUDCOPY      = LOUDCOPY
    local LOUDEQUAL     = LOUDEQUAL
    local LOUDPOW       = LOUDPOW
    local LOUDREMOVE    = LOUDREMOVE
    local VDist2Sq      = VDist2Sq
	local VDist3        = VDist3
    local VDist3Sq      = VDist3Sq
    
    local UNITCHECK     = categories.ALLUNITS - categories.WALL
    local OMNICHECK     = categories.STRUCTURE * categories.INTELLIGENCE * categories.OMNI

    local CreationTime                  = self.CreationTime
    local MapSize                       = ScenarioInfo.size
    local PlatoonGenerateSafePathToLOUD = self.PlatoonGenerateSafePathToLOUD

    local MustScoutList = aiBrain.IL.MustScout

	local scout = false
	local noscoutcount = 0
    local VectorCached = { 0, 0, 0 }    

    self.UsingTransport = true      -- airscouting is never considered for merge operations

    local datalist, dest, dir, IL, length, mustScoutArea, mustScoutIndex, norm, orthogonal, path, reason, targetArea, threatbasis, threatlevel, vec, visradius

	local function AIGetMustScoutArea()
	
		for k,v in MustScoutList do
		
			if not v.TaggedBy or v.TaggedBy.Dead then
				return v, k
			end
            
		end

		return false, nil
	end
	
	local function IsCurrentlyScouted (location)

        if GetNumUnitsAroundPoint( aiBrain, UNITCHECK, location, 45, 'Ally') > 0 or
			-- or an allied OMNI radar within 150
			GetNumUnitsAroundPoint( aiBrain, OMNICHECK, location, 150, 'Ally') > 0 then

			return true
		end
		
		return false
	end	

	-- establish the relative co-ordinates between where the platoon is and where it's going
	-- get the distance to the destination	-- normalize the trip distance	-- Get negative reciprocal vector (either 1 or -1)
	-- establish the relative position the scout must get to to 'see' the target -- flying to the left or right of the target (this is where dir comes in)
	-- calc the final destination by applying the orthogonal to the targetposition

	-- scout platoon uses an inflated threatlevel to assist in pathfinding
	-- find a path using threatlevel to avoid anti-air threats
	-- should that not work scouts will report false and pass on trying to scout this area
	local function DoAirScoutVecs( scout, targetposition )
    
        local LOUDGETN = LOUDGETN
	
		local scoutposition = GetPosition(scout) or false
		
		if scoutposition then
		
			vec = {targetposition[1] - scoutposition[1], 0, targetposition[3] - scoutposition[3]}
            
			length  = VDist3( targetposition, scoutposition )
			norm    = {vec[1]/length, 0, vec[3]/length}
			dir     = LOUDPOW(-1, Random(1,2))

			orthogonal = { norm[3] * visradius * dir, 0, -norm[1] * visradius * dir }

			dest    = {targetposition[1] + orthogonal[1], 0, targetposition[3] + orthogonal[3]}
		
			if dest[1] < 5 then
				dest[1] = 5 
			elseif dest[1] > MapSize[1]-5 then
				dest[1] = MapSize[1]-5
			end
		
			if dest[3] < 5 then
				dest[3] = 5 
			elseif dest[3] > MapSize[2]-5 then
				dest[3] = MapSize[2]-5
			end
		
			-- use an elevated threat level in order to find paths for the air scouts --
			threatlevel = threatbasis + ( LOUDGETN(GetPlatoonUnits(self) )) * LOUDGETN( GetPlatoonUnits(self))
		
			path, reason = PlatoonGenerateSafePathToLOUD( aiBrain, self, 'Air', scoutposition, dest, threatlevel, 256)
		
			if path then
		
				datalist = GetSquadUnits( self,'scout')
		
				-- plot the movements of the platoon --
				if PlatoonExists(aiBrain, self) and datalist[1] then
		
					self:Stop()

					for widx,waypointPath in path do
                        IssueMove( datalist, waypointPath )
					end

					return dest
				end
			end
		end

		return false
	end		

	-- this basically limits all air scout platoons to about 20 minutes of work -- rather should use MISSIONTIMER from platoondata
    while PlatoonExists(aiBrain, self) and (LOUDFLOOR(LOUDTIME()) - CreationTime <= 1200) do

        if not scout or scout.Dead then
		
            for _,v in GetPlatoonUnits(self) do
            
                if not v.Dead then
                    scout = v
                    break
                end
            end

            if not scout then
                return
            end

            visradius = __blueprints[scout.BlueprintID].Intel.VisionRadius or 42            

            -- used for T1 and T2 air scouts
            threatbasis = 10
        
            -- used for T3 air scouts --
            if LOUDENTITY( categories.TECH3, scout ) then
                threatbasis = 24
            end

        end

        targetArea = false
		vec = false

        IL = aiBrain.IL
        
		-- see if we already have a MUSTSCOUT mission underway
		if not IL.LastAirScoutMust then
        
            --LOG("*AI DEBUG "..aiBrain.Nickname.." AirScoutAI "..self.BuilderName.." "..self.BuilderInstance.." seeks MUSTSCOUT " )
			
			datalist = GetThreatsAroundPosition( aiBrain, GetPosition(scout), 2, true, 'Unknown')
			
			-- add all unknown threats over 25 to the MUSTSCOUT list
			if datalist[1] then
				
				for k,v in datalist do
				
					if datalist[k][3] > 25 then
					
						ForkThread( AIAddMustScoutArea, aiBrain, {datalist[k][1], 0, datalist[k][2]} )
					end
				end
			end
			
			mustScoutArea, mustScoutIndex = AIGetMustScoutArea()
            
            if mustScoutArea and not LOUDEQUAL( IL.LastMustScoutPosition or {0,0,0}, mustScoutArea.Position) then

                -- if there is a mustscoutarea then scout it
                if mustScoutArea and (not IL.LastAirScoutMust) then

                    vec = DoAirScoutVecs( scout, mustScoutArea.Position )

                    -- if there is a path to target --
                    if vec then
				
                        if IL.MustScout[mustScoutIndex] then
                            aiBrain.IL.MustScout[mustScoutIndex].TaggedBy = scout
                        end
					
                        targetArea = LOUDCOPY(vec)
					
                        aiBrain.IL.LastAirScoutMust = true	-- flag that we have a MUSTSCOUT mission in progress

                        -- remember where this was so we don't repeat it again too soon
                        aiBrain.IL.LastMustScoutPosition = LOUDCOPY(mustScoutArea.Position)
                    end

				end
			end
		end

        -- 2) Scout a high priority location
        if (not targetArea) and (not IL.LastAirScoutHi) then
		
			datalist = IL.HiPri
            
            --LOG("*AI DEBUG "..aiBrain.Nickname.." AirScoutAI "..self.BuilderName.." "..self.BuilderInstance.." seeks HIPRI " )
			
			for k,v in datalist do

                if IsCurrentlyScouted( v.Position) then
				
					if IL.HiPri[k] then
						aiBrain.IL.HiPri[k].LastScouted = LOUDFLOOR(LOUDTIME())
                        aiBrain.IL.HiPri[k].LastUpdate = LOUDFLOOR(LOUDTIME())
					end
					
                    continue
                end

				vec = DoAirScoutVecs( scout, v.Position )

                -- if there is a path to target --
				if vec then
				
					aiBrain.IL.LastAirScoutHi = true
					
					if IL.HiPri[k] then
						aiBrain.IL.HiPri[k].LastScouted = LOUDFLOOR(LOUDTIME())
					end
					
					ForkThread( AISortScoutingAreas, aiBrain, aiBrain.IL.HiPri )
					
					targetArea = LOUDCOPY(vec)
					break
				end
			end
		end

        -- 3) Scout a low priority location               
        if not targetArea then
			
			aiBrain.IL.LastAirScoutMust = false -- last scout mission was NOT a MUST

			aiBrain.IL.LastAirScoutHiCount = IL.LastAirScoutHiCount + 1

			if IL.LastAirScoutHiCount > aiBrain.AILowHiScoutRatio then
				aiBrain.IL.LastAirScoutHi = false
				aiBrain.IL.LastAirScoutHiCount = 0
			end
            
            IL = aiBrain.IL
            
            --LOG("*AI DEBUG "..aiBrain.Nickname.." AirScoutAI "..self.BuilderName.." "..self.BuilderInstance.." seeks LOPRI " )

			for k,v in IL.LowPri do

                if IsCurrentlyScouted( v.Position ) then
                    aiBrain.IL.LowPri[k].LastScouted = LOUDFLOOR(LOUDTIME())
                    aiBrain.IL.LowPri[k].LastUpdate = LOUDFLOOR(LOUDTIME())
                    continue
                end

				vec = DoAirScoutVecs( scout, v.Position )

                -- if there is a path to target --
				if vec then

					aiBrain.IL.LowPri[k].LastScouted = LOUDFLOOR(LOUDTIME())

					targetArea = LOUDCOPY(vec)
					break
				end
			end
        end

        -- Execute the scouting mission
        -- as we move along we'll try and tag any other HiPri positions
        -- that we might pass along the way.
        if targetArea then
        
            --LOG("*AI DEBUG "..aiBrain.Nickname.." AirScoutAI "..self.BuilderName.." "..self.BuilderInstance.." has targetArea "..repr(targetArea) )

			local reconcomplete = false
			local lastpos = false
			local curPos = false
            
            local cyclecount, distance, loopcount

            while PlatoonExists(aiBrain,self) and not reconcomplete do

				curPos = GetPlatoonPosition(self) or false

				if curPos then
                
                    distance = VDist2Sq( targetArea[1],targetArea[3], curPos[1],curPos[3] )
				
					-- if within 40 of the recon position 
					if distance < (40*40) then
						reconcomplete = true
					end

					-- or not moving
					if (not reconcomplete) and lastpos and VDist3Sq( curPos, lastpos ) < .04 then

                        --LOG("*AI DEBUG "..aiBrain.Nickname.." AirScoutAI "..self.BuilderName.." "..self.BuilderInstance.." appears stalled at "..VDist3( targetArea, curPos ).." to targetArea "..repr(targetArea) )

                        return self:SetAIPlan('ReturnToBaseAI',aiBrain)    

					end

                    -- if we're near another HiPri position - mark it --
                    -- this probably needs to be throttled or interleaved
                    -- so as not to stress on a single tick
                    for k,v in aiBrain.IL.HiPri do
                    
                        if VDist2Sq( curPos[1],curPos[3], v.Position[1],v.Position[3] ) < (40*40) then
                        
                            --LOG("*AI DEBUG "..aiBrain.Nickname.." AirScoutAI "..self.BuilderName.." "..self.BuilderInstance.." updates HIPRI intel position " )
                        
                            aiBrain.IL.HiPri[k].LastScouted = LOUDFLOOR(LOUDTIME())
                            aiBrain.IL.HiPri[k].LastUpdate = LOUDFLOOR(LOUDTIME())
                        end
                    end
                    
                    loopcount = 0
                    cyclecount = 0
                    
                    for k,v in aiBrain.IL.LowPri do
                    
                        if loopcount > 20 then
                            WaitTicks(1)
                            loopcount = 1
                            cyclecount = cyclecount + 1
                        else
                            loopcount = loopcount + 1
                        end
                    
                        if VDist2Sq( curPos[1],curPos[3], v.Position[1],v.Position[3] ) < (40*40) then
                        
                            --LOG("*AI DEBUG "..aiBrain.Nickname.." AirScoutAI "..self.BuilderName.." "..self.BuilderInstance.." updates LOPRI intel position " )

                            aiBrain.IL.LowPri[k].LastScouted = LOUDFLOOR(LOUDTIME())
                            aiBrain.IL.LowPri[k].LastUpdate = LOUDFLOOR(LOUDTIME())
                        end
                    end
                    
                    if PlatoonExists(aiBrain,self) and not reconcomplete then
                    
                        --LOG("*AI DEBUG "..aiBrain.Nickname.." AirScoutAI "..self.BuilderName.." "..self.BuilderInstance.." at "..distance.." to targetArea" )

                        -- store current position
                        if not lastpos then
                            lastpos = VectorCached
                        end
                        
                        lastpos[1] = curPos[1]
                        lastpos[2] = curPos[2]
                        lastpos[3] = curPos[3]

                        if cyclecount < 12 then
                            WaitTicks(21 - cyclecount)
                        end
                    end

				else
                    return self:PlatoonDisband( aiBrain )
                end

            end

			-- if it was a MUSTSCOUT mission, take it off the list
            if mustScoutArea then

				if aiBrain.IL.MustScout[mustScoutIndex] == mustScoutArea then
                
                    --LOG("*AI DEBUG "..aiBrain.Nickname.." AirScoutAI "..self.BuilderName.." "..self.BuilderInstance.." completed MUSTSCOUT position " )

					LOUDREMOVE( aiBrain.IL.MustScout, mustScoutIndex )

				else

					for idx,loc in aiBrain.IL.MustScout do
					
						if loc == mustScoutArea then

                            --LOG("*AI DEBUG "..aiBrain.Nickname.." AirScoutAI "..self.BuilderName.." "..self.BuilderInstance.." completed MUSTSCOUT position (scan) " )

							LOUDREMOVE( aiBrain.IL.MustScout, idx )
							break
						end
					end
				end

				mustScoutArea = false
			end
            
            noscoutcount = 0    -- we got a scoutposition --
            
        else
			noscoutcount = noscoutcount + 1

			if noscoutcount > 2 then
				LOG("*AI DEBUG "..aiBrain.Nickname.." AirScoutAI "..self.BuilderName.." "..self.BuilderInstance.." NoScoutCount break")
				break
			end

			WaitTicks(3)
		end

    end

	return self:SetAIPlan('ReturnToBaseAI',aiBrain)
end

function LandScoutingAI( self, aiBrain )

    local ScoutDialog = false

	local GetNumUnitsAroundPoint    = GetNumUnitsAroundPoint
    local GetPlatoonPosition        = GetPlatoonPosition
    local GetPlatoonUnits           = GetPlatoonUnits
    local GetSurfaceHeight          = GetSurfaceHeight  
    local GetTerrainHeight          = GetTerrainHeight
	local GetUnitsAroundPoint       = GetUnitsAroundPoint
	local PlatoonExists             = PlatoonExists	    
    local VDist3                    = VDist3
    
    local LOUDCOPY = LOUDCOPY
    local UNITCHECK = categories.ALLUNITS - categories.WALL
    local OMNICHECK = categories.STRUCTURE * categories.INTELLIGENCE * categories.OMNI

    local PlatoonGenerateSafePathToLOUD = self.PlatoonGenerateSafePathToLOUD
    local SendPlatoonWithTransportsLOUD = import('/lua/ai/transportutilities.lua').SendPlatoonWithTransportsLOUD

    local MovementLayer = self.MovementLayer
	local PlatoonPatrols = self.PlatoonData.Patrol or false
	
    local dataList = GetPlatoonUnits(self)
	
	for _,v in dataList do
		if not v.Dead and v:TestToggleCaps('RULEUTC_CloakToggle') then
			v:SetScriptBit('RULEUTC_CloakToggle', false)
		end
    end

	local function IsCurrentlyScouted (location)

        if GetNumUnitsAroundPoint( aiBrain, UNITCHECK, location, 40, 'Ally') > 0 or
			GetNumUnitsAroundPoint( aiBrain, OMNICHECK, location, 150, 'Ally') > 0 then

			return true
		end
		
		return false
	end

	local baseradius, curPos, cyclecount, defaultthreat, distance, IL, lastpos, loopcount, path, Position, platooncount, reason, reconcomplete, scout, scoutpriority, targetArea, usedTransports

    defaultthreat = 12
    
    -- Cybran Scouts
    if aiBrain.FactionIndex == 3 then
        defaultthreat = 100
    end
    
    while PlatoonExists(aiBrain, self) do

        platooncount = 0
		scout = false
		
		dataList = GetPlatoonUnits(self)
		
		for _,v in dataList do
		
            if not v.Dead then
            
                if not scout then
                    scout = v
                end
                
                platooncount = platooncount + 1
			end
		end
		
		if not scout then
			break
		end
        
        IssueClearCommands( dataList )
		
		reconcomplete = false
        scoutpriority = false
        targetArea = false

        IL = aiBrain.IL

        curPos = GetPlatoonPosition(self)
        
        -- try and get a Hi Priority target
        if not IL.LastScoutHi and IL.HiPri then
		
			datalist = IL.HiPri
            
            if ScoutDialog then
                LOG("*AI DEBUG "..aiBrain.Nickname.." LandScoutAI "..self.BuilderName.." "..self.BuilderInstance.." seeks Hi Pri position")
            end

			for k,v in datalist do
            
                Position = v.Position

                -- if we (or an Ally) have a unit near the position mark it as scouted and bypass it
                if IsCurrentlyScouted( Position ) then
				
                    aiBrain.IL.HiPri[k].LastScouted = LOUDFLOOR(LOUDTIME())
                    aiBrain.IL.HiPri[k].LastUpdate = LOUDFLOOR(LOUDTIME())
                    continue
                end
				
				-- validate positions for being on the water
				if MovementLayer != 'Amphibious' and GetTerrainHeight( Position[1], Position[3] ) < (GetSurfaceHeight( Position[1], Position[3] ) - 2)  then 
				
					targetArea = false

				else

                    aiBrain.IL.HiPri[k].LastScouted = LOUDFLOOR(LOUDTIME())
                    aiBrain.IL.LastScoutHi = true

                    ForkThread( AISortScoutingAreas, aiBrain, aiBrain.IL.HiPri )

                    scoutpriority = 'Hi'
                    targetArea = LOUDCOPY( Position )
            
                    if ScoutDialog then
                        LOG("*AI DEBUG "..aiBrain.Nickname.." LandScoutAI "..self.BuilderName.." "..self.BuilderInstance.." gets HIGH Pri position "..repr(targetArea).." on tick "..GetGameTick() )
                    end
                    
                    break

                end

			end

		end
        
        -- try and get a Low priority target
		if not targetArea then
		
			aiBrain.IL.LastScoutHiCount = IL.LastScoutHiCount + 1
			
			if aiBrain.IL.LastScoutHiCount > aiBrain.AILowHiScoutRatio then
				aiBrain.IL.LastScoutHi = false
				aiBrain.IL.LastScoutHiCount = 0
			end
			
			datalist = IL.LowPri
            
            if ScoutDialog then
                LOG("*AI DEBUG "..aiBrain.Nickname.." LandScoutAI "..self.BuilderName.." "..self.BuilderInstance.." seeks Low Pri position")
            end

			for k,v in datalist do
            
                Position = v.Position

                -- if we (or an Ally) have a unit within 40 of the position mark it as scouted and bypass it
                if IsCurrentlyScouted( Position ) then
                    aiBrain.IL.LowPri[k].LastScouted = LOUDFLOOR(LOUDTIME())
                    continue
                end

				-- validate positions for being on water
				if MovementLayer != 'Amphibious' and GetTerrainHeight( Position[1], Position[3] ) < (GetSurfaceHeight( Position[1], Position[3] ) - 2)  then

					targetArea = false
				else
                
                    aiBrain.IL.LowPri[k].LastScouted = LOUDFLOOR(LOUDTIME())
                    aiBrain.IL.LowPri[k].LastUpdate = LOUDFLOOR(LOUDTIME())

                    ForkThread( AISortScoutingAreas, aiBrain, aiBrain.IL.LowPri )					

                    scoutpriority = 'Low'
                    targetArea = LOUDCOPY( Position )

                    if ScoutDialog then
                        LOG("*AI DEBUG "..aiBrain.Nickname.." LandScoutAI "..self.BuilderName.." "..self.BuilderInstance.." gets LOW Pri position "..repr(targetArea).." on tick "..GetGameTick() )
                    end
   
                    break

				end

			end

        end

		-- use transport if required
        if PlatoonExists(aiBrain,self) and targetArea then
            
			usedTransports = false

            distance = VDist3( curPos, targetArea )

            if MovementLayer == 'Amphibious' then
                markerseek = 200
            else
                markerseek = 160
            end

            -- with Land Scouting we use an artificial high self-threat so they'll continue scouting later into the game
            path, reason = PlatoonGenerateSafePathToLOUD( aiBrain, self, MovementLayer, curPos, Position, platooncount * defaultthreat, markerseek )
            
            if not path then
                path, reason = PlatoonGenerateSafePathToLOUD( aiBrain, self, MovementLayer, curPos, Position, (platooncount * defaultthreat) * 1.5, markerseek )
            end

			if not path then

				-- try 6 transport calls -- 
				usedTransports = SendPlatoonWithTransportsLOUD( self, aiBrain, targetArea, 5, false )

				if not usedTransports and PlatoonExists(aiBrain, self) then

                    return self:SetAIPlan('ReturnToBaseAI',aiBrain)
                end
			end
			
			if path then
            
                if ScoutDialog then
                    LOG("*AI DEBUG "..aiBrain.Nickname.." LandScoutAI "..self.BuilderName.." "..self.BuilderInstance.." pathing distance is "..distance.." on tick "..GetGameTick() )
                end
   
				-- if the distance is great try to get transports
                -- notice how low air ratio makes this value
				if distance > 1024 * math.min(1, (1/aiBrain.AirRatio)) then

					usedTransports = SendPlatoonWithTransportsLOUD( self, aiBrain, targetArea, 2, false, path )
				end

				-- otherwise start walking -- 
				if path and (distance <= 1024 or (distance > 1024 and not usedTransports) ) and PlatoonExists(aiBrain,self) then
					
					cyclecount = LOUDGETN(path)
                    
                    self:Stop()
					
					if cyclecount > 1 then
						for v = 1, cyclecount-1 do
							MoveToLocation( self, path[v], false )
						end
					end

					MoveToLocation( self, targetArea, false ) 
				end

			else
            
            end

			lastpos = { 0, 0, 0 }

            cyclecount = 0

			-- loop here while we travel to the target			
            while PlatoonExists(aiBrain,self) and targetArea and not reconcomplete do
			
				curPos = GetPlatoonPosition(self) or false
				
				if curPos then

                    distance = VDist3( curPos, targetArea )                

					if distance < 25 then

						reconcomplete = true
            
                        if ScoutDialog then
                            LOG("*AI DEBUG "..aiBrain.Nickname.." LandScoutAI "..self.BuilderName.." "..self.BuilderInstance.." reaches "..scoutpriority.." priority position at "..repr(targetArea).." on tick "..GetGameTick() )
                        end

                        break
					end
                    
					if not reconcomplete and cyclecount > 0 and VDist3( curPos,lastpos ) < 1 then
						reconcomplete = true
                        targetArea = false
                        continue
					end
					
					lastpos[1] = curPos[1]
                    lastpos[2] = curPos[2]
                    lastpos[3] = curPos[3]

                    -- if we're near another HiPri position - mark it --
                    for k,v in aiBrain.IL.HiPri do
                    
                        Position = v.Position
                    
                        if VDist3( curPos, Position ) < 20 then
                            aiBrain.IL.HiPri[k].LastScouted = LOUDFLOOR(LOUDTIME())
                            aiBrain.IL.HiPri[k].LastUpdate = LOUDFLOOR(LOUDTIME())
                        end

                    end

                    loopcount = 0                    

                    for k,v in aiBrain.IL.LowPri do
                        
                        Position = v.Position
                    
                        if VDist3( curPos, Position ) < 20 then
                            aiBrain.IL.LowPri[k].LastScouted = LOUDFLOOR(LOUDTIME())
                            aiBrain.IL.LowPri[k].LastUpdate = LOUDFLOOR(LOUDTIME())
                        end
                    
                        if loopcount > 10 then
                            WaitTicks(1)
                            loopcount = 0
                        else
                            loopcount = loopcount + 1
                        end

                    end                    

				else
                    return      -- platoon dead
                end
                
                if not reconcomplete then
                    WaitTicks( 26 )
                end
                
                cyclecount = cyclecount + 1

            end	

			-- setup the patrol and abandon the platoon
			if PlatoonExists(aiBrain, self) and not scout.Dead then
				
				if not targetArea then
					targetArea = GetPlatoonPosition(self) or false
				end
            
                if ScoutDialog then
                    LOG("*AI DEBUG "..aiBrain.Nickname.." LandScoutAI "..self.BuilderName.." "..self.BuilderInstance.." setting patrol at position "..repr(targetArea).." on tick "..GetGameTick() )
                end

				if PlatoonPatrols and targetArea then
                
                    dataList = GetPlatoonUnits(self)
                
                    baseradius = 22

                    local areaelevation = GetTerrainHeight(targetArea[1],targetArea[3])                    

                    if LocationInWaterCheck(targetArea) then
                        areaelevation = GetSurfaceHeight(targetArea[1],targetArea[3])
                    end
                
                    for _,scout in dataList do
                    
                        IssueClearCommands( {scout} )
                    
                        -- assign upto 2 scouts to this patrol
                        if baseradius > 35 then

                            continue

                        else
					
                            path = GetBasePerimeterPoints( aiBrain, targetArea, baseradius, false, false, MovementLayer, true )
                            
                            local firstmove = true
                            local lastpos = targetArea
					
                            for k,v in path do

                                local TH = GetTerrainHeight(v[1],v[3])
                                local SH = GetSurfaceHeight(v[1],v[3])

                                if (not scout.Dead) and scout:CanPathTo( v ) then
								
                                    if not MovementLayer == 'Amphibious' then

                                        -- if terrain drops off into water
                                        if TH < (SH - 1) then
                                            continue
                                        end
                                    end

                                    if CheckBlockingTerrain( lastpos, v )then
                                        continue
                                    end

                                    lastpos = LOUDCOPY(v)					

                                    if firstmove then

                                        IssueMove( {scout}, v )

                                        firstmove = false
                                        
                                        WaitTicks(6)

                                    else

                                        IssuePatrol( {scout}, v )

                                    end

                                end

                                WaitTicks(2)
                            end
				
                            -- if this is a high priority, abandon 1 or 2 scouts here and move the rest on
                            if scoutpriority and not scout.Dead then
                            
                                if scoutpriority == 'Hi' then

                                    AssignUnitsToPlatoon( aiBrain, aiBrain.StructurePool, {scout}, 'Guard', 'none' )
                                    
                                end

                                baseradius = baseradius + 12

                            end
                            
                        end

                    end
                    
                    if scoutpriority != 'Hi' then

                        if ScoutDialog then
                            LOG("*AI DEBUG "..aiBrain.Nickname.." LandScoutAI "..self.BuilderName.." "..self.BuilderInstance.." will patrol for 30 seconds ")
                        end

                        WaitTicks(301)

                        if not scoutpriority then
                            self:SetAIPlan('ReturnToBaseAI',aiBrain)
                        end

                    end

				end

			end
            
        end
		
		WaitTicks(21)
    end
    
end

function NavalScoutingAI( self, aiBrain )

    local NavalScoutDialog = false

	local GetNumUnitsAroundPoint    = GetNumUnitsAroundPoint
    local GetPlatoonPosition        = GetPlatoonPosition
    local GetPlatoonUnits           = GetPlatoonUnits
    local GetSurfaceHeight          = GetSurfaceHeight    
    local GetTerrainHeight          = GetTerrainHeight
	local GetUnitsAroundPoint       = GetUnitsAroundPoint
	local PlatoonExists             = PlatoonExists	

    local LOUDCOPY  = LOUDCOPY
    local VDist2Sq  = VDist2Sq
    local VDist3    = VDist3

    local UNITCHECK     = categories.ALLUNITS - categories.WALL
    local OMNICHECK     = categories.STRUCTURE * categories.INTELLIGENCE * categories.OMNI
    local SONARCHECK    = categories.STRUCTURE * categories.SONAR

    local PlatoonGenerateSafePathToLOUD = self.PlatoonGenerateSafePathToLOUD

    local CreationTime = self.CreationTime
    local MovementLayer = self.MovementLayer

	local function IsCurrentlyScouted (location)

        local GetNumUnitsAroundPoint = GetNumUnitsAroundPoint

        if GetNumUnitsAroundPoint( aiBrain, UNITCHECK, location, 50, 'Ally') > 0 or
            -- or a SONAR within 90
            GetNumUnitsAroundPoint( aiBrain, SONARCHECK, location, 90, 'Ally') > 0 or
			-- or an OMNI radar within 150
			GetNumUnitsAroundPoint( aiBrain, OMNICHECK, location, 150, 'Ally') > 0 then

			return true
		end
		
		return false
	end	

	local curPos = nil
	local scout = nil
    
	local cyclecount, datalist, distance, IL, lastpos, loopcount, path, reason, reconcomplete, scout, surface, targetArea, terrain

	-- naval scouting is limited to about 20 minutes --
    while PlatoonExists(aiBrain, self) and (LOUDFLOOR(LOUDTIME()) - CreationTime <= 1200) do

        datalist = GetPlatoonUnits(self)
        scout = false

		for _,v in datalist do
		
			if not v.Dead then
				scout = v
				break
			end
		end
        
        if not scout then
            return self:SetAIPlan('ReturnToBaseAI',aiBrain)
        end
		
        targetArea = false
		reconcomplete = false
        
        IL = aiBrain.IL
		
		-- if the last scout mission was NOT a HiPri then look for one
        if not IL.LastScoutHi then
        
            targetArea = false
            
            if NavalScoutDialog then
                LOG("*AI DEBUG "..aiBrain.Nickname.." "..repr(self.BuilderName).." "..repr(self.BuilderInstance).." NavalScoutingAI seeking hipri mission")
            end

			for k,v in IL.HiPri do
            
                local position = v.Position

                -- if we (or an Ally) have a unit within 30 of the position mark it as scouted and bypass it
                if IsCurrentlyScouted(position) then
				
                    aiBrain.IL.HiPri[k].LastScouted = LOUDFLOOR(LOUDTIME())
					continue
                end

				surface = GetSurfaceHeight(position[1], position[3])
				terrain = GetTerrainHeight(position[1], position[3])

				-- validate positions for being out of the water
				if terrain >= surface - 2  then


				else
					aiBrain.IL.LastScoutHi = true
					aiBrain.IL.HiPri[k].LastScouted = LOUDFLOOR(LOUDTIME())

                    targetArea = LOUDCOPY(position)
                    targetArea[2] = surface
					
					ForkThread( AISortScoutingAreas, aiBrain, aiBrain.IL.HiPri )
					break
				end
			end
		end

		-- if we dont have a HiPri scout, try LowPri
		if not targetArea then
			
			aiBrain.IL.LastScoutHiCount = IL.LastScoutHiCount + 1

			if aiBrain.IL.LastScoutHiCount > aiBrain.AILowHiScoutRatio then
			
				aiBrain.IL.LastScoutHi = false
				aiBrain.IL.LastScoutHiCount = 0
			end

            if NavalScoutDialog then
                LOG("*AI DEBUG "..aiBrain.Nickname.." "..repr(self.BuilderName).." "..repr(self.BuilderInstance).." NavalScoutingAI seeking Lowpri mission")			
            end
            
			for k,v in IL.LowPri do
            
                local position = v.Position

                if IsCurrentlyScouted(position) then
				
                    aiBrain.IL.LowPri[k].LastScouted = LOUDFLOOR(LOUDTIME())
                    continue
                end	

				surface = GetSurfaceHeight(position[1], position[3])
				terrain = GetTerrainHeight(position[1], position[3])


				-- validate positions for being out of the water
				if terrain >= surface - 2 then

				else
					aiBrain.IL.LowPri[k].LastScouted = LOUDFLOOR(LOUDTIME())

                    targetArea = LOUDCOPY(position)
                    targetArea[2] = surface

					ForkThread( AISortScoutingAreas, aiBrain, aiBrain.IL.LowPri )
					break
				end
			end
        end

		-- execute the scouting mission
        if targetArea then

            if NavalScoutDialog then
                LOG("*AI DEBUG "..aiBrain.Nickname.." "..repr(self.BuilderName).." "..repr(self.BuilderInstance).." executing scout to "..repr(targetArea) )        
            end
            
            curPos = GetPlatoonPosition(self) or false
            
            if not curPos then
                return self:SetAIPlan('ReturnToBaseAI', aiBrain )
            end
        
            -- Find a path to targetArea --
			distance = VDist3( curPos, targetArea)

			-- like Land Scouting we use an artificially higher threat of 100 to insure path finding
			path, reason = PlatoonGenerateSafePathToLOUD(aiBrain, self, MovementLayer, curPos, targetArea, 150, 250 )

            if NavalScoutDialog then
                LOG("*AI DEBUG "..aiBrain.Nickname.." "..repr(self.BuilderName).." "..repr(self.BuilderInstance).." pathfind is "..repr(path) )
            end
            
            -- move the platoon to the targetArea or abort this targetArea
			if PlatoonExists( aiBrain, self ) then

				if (not path) and not scout.Dead then
				
					if distance <= 120 and scout:CanPathTo(targetArea) then
                        
                        if NavalScoutDialog then
                            LOG("*AI DEBUG "..aiBrain.Nickname.." Naval Scout AI has no path - distance "..repr(distance).." - moving direct to "..repr(targetArea))
                        end
                        
                        path = { targetArea }

					else
						targetArea = false
					end
				end
			
				if path and targetArea then

					self.MoveThread = self:ForkThread( self.MovePlatoon, path, 'GrowthFormation', false, 24 )
                    
                    WaitTicks(31)

                    lastpos = { 0, 0, 0 }
            
                    cyclecount = 0
                    
				else
                    targetArea = false
                end
			end

        end

        while PlatoonExists(aiBrain,self) and targetArea and not reconcomplete do

			curPos = GetPlatoonPosition(self) or false

			if curPos then

                distance = VDist3( curPos, targetArea )                

				if distance < 25 or not self.MoveThread then
					reconcomplete = true
                    break
				end

				if not reconcomplete and cyclecount > 0 and VDist3( curPos,lastpos ) < 2 then
					reconcomplete = true
                    targetArea = false
                    continue
				end

				lastpos[1] = curPos[1]
                lastpos[2] = curPos[2]
                lastpos[3] = curPos[3]

                -- if we're near another HiPri position - mark it --
                for k,v in aiBrain.IL.HiPri do
                    
                    Position = v.Position
                    
                    if VDist3( curPos, Position ) < 20 then
                        aiBrain.IL.HiPri[k].LastScouted = LOUDFLOOR(LOUDTIME())
                        aiBrain.IL.HiPri[k].LastUpdate = LOUDFLOOR(LOUDTIME())
                    end

                end

                loopcount = 0                    

                for k,v in aiBrain.IL.LowPri do

                    Position = v.Position
                    
                    if VDist3( curPos, Position ) < 20 then
                        aiBrain.IL.LowPri[k].LastScouted = LOUDFLOOR(LOUDTIME())
                        aiBrain.IL.LowPri[k].LastUpdate = LOUDFLOOR(LOUDTIME())
                    end
                    
                    if loopcount > 10 then
                        WaitTicks(1)
                        loopcount = 0
                    else
                        loopcount = loopcount + 1
                    end

                end                    

            else
                return      -- platoon dead
			end

            if not reconcomplete and cyclecount < 25 then
                WaitTicks(25 - cyclecount)
            else
                WaitTicks(3)
            end

        end	

        ------------------------------
        -- Arrive at the targetArea --
        ------------------------------
		-- Run a patrol here for 3 minutes
		-- Note how the targetArea is set to the platoon position if empty
		-- This allows scouts that fail in getting to the desired area
		-- to patrol their existing location before trying for another
		if PlatoonExists(aiBrain, self) then
        
            local patroltimer = 180

			if not targetArea then
				targetArea = GetPlatoonPosition(self) or false
                
                if targetArea then
                    patroltimer = 30
                else
                    return self:SetAIPlan('ReturnToBaseAI', aiBrain )
                end
			end

            if self.MoveThread then
                KillThread( self.MoveThread )
            end

			self:Stop()

            -- get the perimeter points around this position
            datalist = GetBasePerimeterPoints( aiBrain, targetArea, 42, false, false, MovementLayer )

            if NavalScoutDialog then
                LOG("*AI DEBUG "..aiBrain.Nickname.." "..repr(self.BuilderName).." "..repr(self.BuilderInstance).." begins patrol at "..repr(targetArea).." for "..patroltimer.." on tick "..GetGameTick() )
            end
            
            local firstmove = true
            local lastpos = targetArea
            
			-- set up a patrol around the position
			for k,v in datalist do
            
                if CheckBlockingTerrain( lastpos, v )then
                    continue
                end

                if firstmove then
					MoveToLocation( self, v, false)
                    firstmove = false
				else

					units = GetPlatoonUnits(self)

					if units[1] and v then
						IssuePatrol( units, v )
					end

				end
                
                WaitTicks(1)

			end

			-- we could introduce variable patrol times with a PlatoonData variable
			WaitSeconds(patroltimer)

        end

        -- if we didn't find a recon mission wait 3 seconds before trying again
        -- otherwise go right back and find another mission
        if PlatoonExists(aiBrain,self) then

            if (not targetArea) and not reconcomplete then

                if NavalScoutDialog then
                    LOG("*AI DEBUG "..aiBrain.Nickname.." "..repr(self.BuilderName).." "..repr(self.BuilderInstance).." NavalScoutingAI finds no recon mission")
                end
                
                WaitTicks(31)
                
                --- shorten the mission timer by 5 seconds 
                CreationTime = CreationTime - 50

            else
                
                if NavalScoutDialog then
                    LOG("*AI DEBUG "..aiBrain.Nickname.." "..repr(self.BuilderName).." "..repr(self.BuilderInstance).." completes recon mission "..repr(reconcomplete).." on tick "..GetGameTick() )            
                end
                
                self:Stop()
            end

        end
        
    end

	return self:SetAIPlan('ReturnToBaseAI',aiBrain)
end

-- this behavior will watch the platoon's overall health and size
-- and RTB it (after checking for a merge) when it falls too low
-- it will end DistressResponseAI on that platoon if it's running
function RetreatAI( self, aiBrain )

    WaitTicks(51)  -- Wait 5 seconds before beginning

	local PlatoonExists = PlatoonExists	

    if not PlatoonExists( aiBrain, self ) then
        return
    end
    
    local DistressResponseDialog = ScenarioInfo.DistressResponseDialog or false
    
    -- note that this platoon is using RetreatAI
    self.RetreatAI = true

    local CalculatePlatoonThreat    = CalculatePlatoonThreat
    local GetPlatoonUnits           = GetPlatoonUnits    
    local UNITCHECK                 = categories.ALLUNITS - categories.WALL
    local WaitTicks                 = WaitTicks
    
    local ThreatCheck = 'Overall'
    local OriginalStrength  = CalculatePlatoonThreat( self, 'Overall', UNITCHECK)
    local SurfaceStrength   = CalculatePlatoonThreat( self, 'Surface', UNITCHECK)
    local AirStrength       = CalculatePlatoonThreat( self, 'Air', UNITCHECK)
    local SubStrength       = CalculatePlatoonThreat( self, 'Sub', UNITCHECK)
    
    if SurfaceStrength > OriginalStrength * .5 then
        OriginalStrength = SurfaceStrength
        ThreatCheck = 'Surface'
    
    elseif AirStrength > OriginalStrength *.5 then
        OriginalStrength = AirStrength
        ThreatCheck = 'Air'
        
    elseif SubStrength > OriginalStrength *.5 then
        OriginalStrength = SubStrength
        ThreatCheck = 'Sub'
    end
    
    local OriginalSize = 0
    local CurrentSize = 0
    
    local function CountPlatoonUnits()
    
        CurrentSize = 0
    
        for _, u in GetPlatoonUnits(self) do
    
            if not u.Dead then
                CurrentSize = CurrentSize + 1
            end
        end
        
        return CurrentSize
    end
    
    OriginalSize = CountPlatoonUnits()
    OriginalPlan = self.PlanName

    while PlatoonExists( aiBrain, self) do
    
        if self.UnderAttack or self.DistressCall then
        
            local mythreat  = CalculatePlatoonThreat( self, ThreatCheck, UNITCHECK)
            local mysize    = CountPlatoonUnits()
            
            OriginalStrength    = LOUDMAX( OriginalStrength, mythreat )
            OriginalSize        = LOUDMAX( OriginalSize, mysize )

            --- check platoon strength
            if (OriginalStrength * .3) >= mythreat or (OriginalSize * .3) >= mysize then

                if PlatoonExists( aiBrain, self) then
                    
                    if self.DistressResponseAIRunning then
                        self.DistressResponseAIRunning = nil
                    end
                  
                    self.UsingTransport = false
             
                    self.MergeIntoNearbyPlatoons( self, aiBrain, OriginalPlan, 90, false)
                
                    if PlatoonExists( aiBrain, self) then

                        if DistressResponseDialog then
                            LOG("*AI DEBUG "..aiBrain.Nickname.." PCAI "..repr(self.BuilderName).." "..repr(self.BuilderInstance).." RETREATS on tick "..GetGameTick() )
                        end
  
                        return self:SetAIPlan('ReturnToBaseAI',aiBrain)
                    end

                end

            else

                --if DistressResponseDialog then
                  --  LOG("*AI DEBUG "..aiBrain.Nickname.." PCAI "..repr(self.BuilderName).." "..repr(self.BuilderInstance).." Org Str "..(OriginalStrength).." vs "..mythreat.."  Org Size "..(OriginalSize).." vs "..mysize )
                --end

            end

        end
        
        WaitTicks(7)

        --if DistressResponseDialog then
          --  LOG("*AI DEBUG "..aiBrain.Nickname.." PCAI "..repr(self.BuilderName).." "..repr(self.BuilderInstance).." RETREATAI cycles on tick "..GetGameTick() )
        --end
        
    end

end

-- This function borrows some good code from Sorian for timed launches
-- Launchers are added to the platoon thru the NukeAIHub
-- When there are missiles to fire, a target is selected and an appropriate
-- number of nukes are fired at the target, based upon intel of anti-nuke systems
-- both near and intervening to the target
function NukeAI( self, aiBrain )

	local AIFindNumberOfUnitsBetweenPoints = import('/lua/ai/aiattackutilities.lua').AIFindNumberOfUnitsBetweenPoints
	local AISendChat = import('/lua/ai/sorianutilities.lua').AISendChat
	local GetHiPriTargetList = GetHiPriTargetList
	local UnitLeadTarget = import('/lua/ai/sorianutilities.lua').UnitLeadTarget
	
    local aiBrain = GetBrain(self)
    
    local GetPlatoonUnits = GetPlatoonUnits    
	local GetUnitsAroundPoint = GetUnitsAroundPoint
	local PlatoonExists = PlatoonExists	
    
    local LOUDEQUAL = table.equal
	local LOUDGETN = LOUDGETN
    
	local AvailableLaunches = {}
	local nukesavailable = 0
    local count = 0
    
    local targettypes = {}

    --targettypes["AntiAir"] = true
    targettypes["Economy"] = true
    targettypes["Commander"] = true
    targettypes["Land"] = true
    targettypes["StructuresNotMex"] = true

	while PlatoonExists( aiBrain, self ) do
	
		AvailableLaunches = {}
        count = 0
        
		nukesavailable = 0
		
		-- make a list of available missiles
		for _, u in GetPlatoonUnits(self) do
		
			if not u.Dead then
			
				if u:GetNukeSiloAmmoCount() > 0 then
				
                    count = count + 1
                    AvailableLaunches[count] = u
					nukesavailable = nukesavailable + 1
					
					if  EntityCategoryContains( categories.xsb2401, u ) then
					
						nukesavailable = nukesavailable + 1
						
					end
					
				end
				
				-- insure that launcher is set to build missiles
				u:SetAutoMode(true)
			end
			
		end

	
		-- now we need to find a target
		while nukesavailable > 0 do
        
            if ScenarioInfo.NukeDialog then
                LOG("*AI DEBUG "..aiBrain.Nickname.." NukeAI searching for targets with "..LOUDGETN(GetPlatoonUnits(self)).." launchers and "..nukesavailable.." missiles")
            end
			
			local minimumvalue = 750
			
			local lasttarget = false
			local lasttargettime = nil
			local target
			local nukePos = false
			local targetunit = nil
			local targetvalue = minimumvalue
			local targetantis = 0
			
			local targetlist = GetHiPriTargetList(aiBrain, GetPlatoonPosition(self),targettypes, 5000, true )
			
			local allthreat, antinukes, value
			
			LOUDSORT(targetlist, function(a,b)  return a.Distance < b.Distance  end )

            if ScenarioInfo.NukeDialog then
                LOG("*AI DEBUG Nuke Targetlist is "..repr(targetlist))
            end
			
			-- evaluate the targetlist
			for _, target in targetlist do
			
				-- check threat levels (used to calculate value of target) - land/naval units worth 35% more - air worth only 50%
				allthreat = target.Threats.Eco + ((target.Threats.Sub + target.Threats.Sur) * 1.35) + (target.Threats.Air * 0.5)
				
                --if ScenarioInfo.NukeDialog then
                  --  LOG("*AI DEBUG "..aiBrain.Nickname.." NukeAI "..target.Type.." target at distance "..repr(target.Distance).." is "..repr(allthreat).."  Needed value is "..repr(minimumvalue))
				--end
                
				-- factor in distance to make near targets worth more
				-- LOG("*AI DEBUG "..aiBrain.Nickname.." NukeAI map size / distance calc is "..repr(aiBrain.dist_comp).." / "..repr(target.Distance))
				
				allthreat = allthreat * LOUDSQUARE(aiBrain.dist_comp/target.Distance)
				
				-- ignore it if less than minimumvalue
				if allthreat < minimumvalue then
					continue
				end
                
                --if ScenarioInfo.NukeDialog then				
                  --  LOG("*AI DEBUG "..aiBrain.Nickname.." NukeAI "..target.Type.." value after distance adjust is "..repr(allthreat))
                --end
			
				-- get any anti-nuke systems in flightpath (-- one weakness here -- because launchers could be anywhere - we use platoon position which could be well off)
				antinukes = AIFindNumberOfUnitsBetweenPoints( aiBrain, GetPlatoonPosition(self), target.Position, categories.ANTIMISSILE * categories.SILO, 96, 'Enemy' )

				-- if too many antinukes versus launchers
				if antinukes >= nukesavailable then
					continue
				end
				
                --if ScenarioInfo.NukeDialog and antinukes > 0 then
					--LOG("*AI DEBUG "..aiBrain.Nickname.." NukeAI "..target.Type.." finds "..antinukes.." antinukes along path to this target")
				--end
	
				-- value of target is divided by number of anti-nukes in area
				value = ( allthreat/ LOUDMAX(antinukes,1) )

				-- if this is a better target then store it
				if value > targetvalue then

                    if ScenarioInfo.NukeDialog then
                        LOG("*AI DEBUG NukeAI says there are "..repr(antinukes).." AntiNukes within range of target - value is now "..repr(value) )
                    end
					
					-- if its not the same as our last shot
					if not LOUDEQUAL(target.Position,lasttarget) then
					
                        if ScenarioInfo.NukeDialog then
                            LOG("*AI DEBUG "..aiBrain.Nickname.." NukeAI "..target.Type.." sees this as a viable target -- "..repr(target.Position).." Antis is "..(antinukes).." Last Scouted "..repr(target.LastScouted))
                        end

						targetvalue = value
						targetantis = antinukes
						nukePos = target.Position

					-- if same as our last target and we've scouted it since then it's ok to fire again
					-- otherwise don't fire nukes at same target twice without scouting it
					elseif LOUDEQUAL(target.Position,lasttarget) and target.LastScouted > lasttargettime then
                    
                        if ScenarioInfo.NukeDialog then
                            LOG("*AI DEBUG "..aiBrain.Nickname.." NukeAI "..target.Type.." sees this as SAME target -- Old "..repr(lasttarget).."  New "..repr(target.Position).." Last Scouted "..repr(target.LastScouted))
                        end

						targetvalue = value
						targetantis = antinukes
						nukePos = target.Position
						
					end

					-- get an actual unit so we can plan for moving targets - do not target units that can fly -
					for _, u in GetUnitsAroundPoint( aiBrain, categories.ALLUNITS - (categories.AIR * categories.MOBILE), nukePos, 40, 'Enemy') do
						targetunit = u
						break
					end
					
		            if ScenarioInfo.NukeDialog and not targetunit then
						LOG("*AI DEBUG All values good but cannot find targetunit within 40 of "..repr(nukePos))
					end
				end
			end

			-- if we selected a target then lets see if we can fire some nukes at it
			if nukePos and targetunit then

				local launches = 0
				local launchers = {}
                local count = 0 

				-- collect all the launchers and their flighttime
				for _,u in AvailableLaunches do
					
					nukePos = UnitLeadTarget( u, targetunit )
					
					local launcherposition = GetPosition(u) or false
					
					if launcherposition and nukePos then

						-- approx flight time to target
                        count = count + 1
						launchers[count] = { unit = u, flighttime = LOUDSQUARE( VDist2Sq( nukePos[1],nukePos[3], launcherposition[1],launcherposition[3] ) ) /40 }

						launches = launches + 1
						
						if EntityCategoryContains( categories.xsb2401, u ) then
						
							launches = launches + 1
							
						end
						
					end
					
				end

				-- if we have enough launches to overcome expected antinukes
				if launches > targetantis then
                
                    if ScenarioInfo.NukeDialog then
                        LOG("*AI DEBUG "..aiBrain.Nickname.." has "..launches.." launchers available for target with "..targetantis.." antinukes")
                    end
					
					-- if nuking same location randomize the target
					if lasttarget and LOUDEQUAL( nukePos, lasttarget ) then
						
						nukePos = { nukePos[1] + Random( -20, 20), nukePos[2], nukePos[3] + Random( -20, 20) }

                        -- store the target and time
                        lasttarget = nukePos
                        lasttargettime = LOUDFLOOR(LOUDTIME())
						
					end						

					-- sort them by longest flighttime to shortest
					LOUDSORT( launchers, function(a,b) return a.flighttime > b.flighttime end )
					
					local lastflighttime = launchers[1].flighttime
					local firednukes = 0
                    
		            if ScenarioInfo.NukeDialog then
                        LOG("*AI DEBUG "..aiBrain.Nickname.." NukeAI says longest flighttime is "..repr( lastflighttime))
                    end

					-- fire them with appropriate delays and only as many as needed
					for _,u in launchers do
					
						if firednukes <= targetantis then

							if ( lastflighttime - u.flighttime ) > 0 then
							
								WaitSeconds( lastflighttime - u.flighttime )
								
							end

                            if ScenarioInfo.NukeDialog then
                                LOG("*AI DEBUG "..aiBrain.Nickname.." launcher "..u.unit.EntityID.." Firing Nuke "..(firednukes + 1).." after "..(lastflighttime - u.flighttime).." seconds - target is "..repr(nukePos).." status "..repr(u.HasTMLTarget) )
							end
 
                            IssueClearCommands( {u.unit} )

							IssueNuke( {u.unit}, nukePos )
						
							lastflighttime = u.flighttime
							firednukes = firednukes + 1
							
							if EntityCategoryContains( categories.xsb2401, u) then
							
								firednukes = firednukes + 1
								
								nukesavailable = nukesavailable - 1
								
							end
							
							nukesavailable = nukesavailable - 1
							
						end
						
					end

					if firednukes > 0 then
					
						local aitarget = targetunit.ArmyIndex
					
						AISendChat('allies', ArmyBrains[aiBrain.ArmyIndex].Nickname, 'nukechat', ArmyBrains[aitarget].Nickname)

						-- send a scout for BDA
						ForkThread( AIAddMustScoutArea, aiBrain, nukePos)
						
					end
					
				end

			else
			
				if not targetunit then
					--LOG("*AI DEBUG "..aiBrain.Nickname.." NukeAI cant find a unit in the target area")
				end
				
				lasttarget = nil
				lasttargettime = nil
				
				--LOG("*AI DEBUG "..aiBrain.Nickname.." NukeAI finds no target to be used on")
				
				nukesavailable = 0
				
			end
			
		end

		WaitTicks(360)	-- every 36 seconds -- HMM -- this would best be synced right after the brain has completed a new HiPri list ? or would it ?
		
	end
	
end

function SetLoiterPosition( self, aiBrain, startposition, searchradius, minthreat, mythreat, threatseek, threatavoid, currentposition )

    local ShowLoiterDialog = false

    local GetSquadUnits             = GetSquadUnits
    local GetThreatsAroundPosition  = GetThreatsAroundPosition
    local GetThreatAtPosition       = GetThreatAtPosition
	local PlatoonExists             = PlatoonExists	    

    local LOUDCOPY  = LOUDCOPY
    local LOUDFLOOR = LOUDFLOOR
    local LOUDMAX   = LOUDMAX
    local LOUDMIN   = LOUDMIN
    local LOUDSORT  = LOUDSORT
    local LOUDLERP  = LOUDLERP
    local VDist3    = VDist3
    
    local VectorCached = { 0, 0, 0 }

    local AirRatiofactor    = aiBrain.AirRatio/1.5
    local IMAPBlocksize     = ScenarioInfo.IMAPSize
    local loiterposition    = startposition
    local ringrange         = searchradius * 12
    local threatrings       = ScenarioInfo.IMAPBlocks
    local currentloiter     = currentposition or false

    -- first - get all the threatseek threats within 12 times the searchradius (ringrange) - why 12 times ?
    -- because that will let us react to air threats within reasonable range of the startposition
    -- without pulling us across the map - if we have a current enemy, we'll add their start, with 5 threat, to insure we have a result
    -- the AirRatio will keep us closer to home if it's not above 1.5
    -- ScenarioInfo.IMAPSize comes in handy as it tells us how big each block will be so we can adjust the blocks value to line up with the searchradius

    local currentthreat, currentvalue, lerpresult, positionthreat, result, test
    
    local threats = GetThreatsAroundPosition( aiBrain, startposition, LOUDFLOOR( ringrange/IMAPBlocksize ), true, threatseek )

    --- if we get no threats -- respond to a map wide ECONOMY scan
    if not threats[1] then
        threats = GetThreatsAroundPosition( aiBrain, startposition, LOUDFLOOR( ringrange/IMAPBlocksize ) * 2, true, 'ECONOMY' )
        threatseek = 'ECONOMY'
    end

    if aiBrain.CurrentEnemyIndex then
   
        local x, z = aiBrain:GetCurrentEnemy():GetArmyStartPos()

        LOUDINSERT( threats, { x, z, 5 } )
    end

    -- filter them down to those above min threat and capture the threatavoid threat at that position
    if threats[1] then

        currentthreat = mythreat    --- filter out threats bigger than me
        currentvalue = minthreat    --- must have value
        result = false

        if ShowLoiterDialog then
            LOG("*AI DEBUG "..aiBrain.Nickname.." LOIT "..self.BuilderName.." "..self.BuilderInstance.." gets "..threatseek.." threats from "..repr(startposition).." threats are "..repr(threats) )
        end
        
        for _,v in threats do
            
            test = VectorCached
            test[1] = v[1]
            test[3] = v[2]
            
            -- get the avoid threat at that position
            positionthreat = LOUDMAX( 0, GetThreatAtPosition( aiBrain, test, threatrings, true, threatavoid ))

            -- we are seeking the most valuable target with the lowest, but acceptable threat
            if  positionthreat < currentthreat and v[3] >= currentvalue then
                
                if ShowLoiterDialog then
                    LOG("*AI DEBUG "..aiBrain.Nickname.." LOIT "..self.BuilderName.." "..self.BuilderInstance.." selects "..repr(test).." with value "..v[3].."   avoidthreat "..positionthreat.." less than my "..mythreat )
                end

                result = LOUDCOPY(test)

                if positionthreat < mythreat then
                    currentthreat = positionthreat
                end

                currentvalue = v[3]
            else
                if ShowLoiterDialog then
                    LOG("*AI DEBUG "..aiBrain.Nickname.." LOIT "..self.BuilderName.." "..self.BuilderInstance.." ignores position "..repr(test).." with value "..v[3].." avoidthreat is "..positionthreat.." mine is "..mythreat )
                end
            end

        end

        -- take the highest threat position
        if result then
         
            lerpresult = LOUDMIN( 1, LOUDMIN( 1, ( ringrange / VDist3(startposition, result) ) ) )
        
            if ShowLoiterDialog then
                LOG("*AI DEBUG "..aiBrain.Nickname.." LOIT "..self.BuilderName.." "..self.BuilderInstance.." will use "..repr(result).." base lerp value "..lerpresult )
            end
   
            -- some forward deployment
            lerpresult = lerpresult * LOUDMIN( 0.66, LOUDMIN( mythreat, mythreat*LOUDMAX(0.28, AirRatiofactor) ) / LOUDMAX(1, currentthreat) )
        
            if ShowLoiterDialog then
                LOG("*AI DEBUG "..aiBrain.Nickname.." LOIT "..self.BuilderName.." "..self.BuilderInstance.." adjusted lerp value "..lerpresult )
            end

            -- build the loiterposition using the threatPos and LERP it against the startposition
            loiterposition = { 0, 0, 0 }
            loiterposition[1] = LOUDFLOOR( LOUDLERP( lerpresult, startposition[1], result[1] ))
            loiterposition[2] = startposition[2]
            loiterposition[3] = LOUDFLOOR( LOUDLERP( lerpresult, startposition[3], result[3] )) 
        end

    else
        if ShowLoiterDialog then
            LOG("*AI DEBUG "..aiBrain.Nickname.." "..self.BuilderName.." Set Loiter reports no threats within ringrange "..LOUDFLOOR(ringrange/IMAPBlocksize) )
        end
    end
   
    if ShowLoiterDialog then
        LOG("*AI DEBUG "..aiBrain.Nickname.." LOIT "..self.BuilderName.." "..self.BuilderInstance.." Sets Loiter position to "..repr(loiterposition).." using lerpresult "..repr(lerpresult).." current loiter was "..repr(currentloiter) )
    end

    --- store the position on the platoon
    self.loiterposition = LOUDCOPY(loiterposition)

    return loiterposition
end

function ProsecuteTarget( unit, aiBrain, target, searchrange, recalldelay, AirForceDialog )

        local dialog = "*AI DEBUG "..aiBrain.Nickname.." AFAI "..unit.PlatoonHandle.BuilderName.." "..repr(unit.PlatoonHandle.BuilderInstance).." unit "..unit.Sync.id 

        unit.IgnoreRefit = true
        
        local GetPosition   = GetPosition
        local VDist3        = VDist3
        
        local u = {unit}

        --- move unit to Attack Squad ---
        AssignUnitsToPlatoon( aiBrain, unit.PlatoonHandle, u, 'Attack','None' )
       
        IssueClearCommands( u )

        if AirForceDialog then
            LOG( dialog.." assigned target "..repr(target.Sync.id).." on tick "..GetGameTick() )
        end
        
        local attackissued, loiterposition, selfpos, targethealth, targetposition, searchdistance

        while unit.target and (not target.Dead ) and (not unit.Dead) do

            selfpos         = GetPosition(unit)
            loiterposition  = unit.PlatoonHandle.loiterposition      
            targetposition  = GetPosition(target)

            --- if we run out of fuel then break off
            if not unit.HasFuel then

                unit.IgnoreRefit = false
                
                target = false

                if AirForceDialog then
                    LOG( dialog.." assigned to target "..repr(target.Sync.id).." LOW ON FUEL on tick "..GetGameTick() )
                end
                
                import('/lua/loudutilities.lua').ProcessAirUnits( unit, aiBrain )
                
                break
                
            end

            --- if we have a valid loiterposition
            if loiterposition and type(targetposition) == 'table' then
                
                searchdistance    = VDist3( loiterposition, targetposition)
                targethealth      = target:GetHealthPercent()

                --- break off if 10% beyond searchrange and still mostly healthy
                if unit.target and searchdistance > (searchrange*1.1) and targethealth > 0.3 then

                    if AirForceDialog then
                        LOG( dialog.. " breaks off target "..repr(target.Sync.id).." on tick "..GetGameTick() )
                    end

                    target = false
                    
                    break

                end

                --- pursue badly damaged units further
                if unit.target and searchdistance > (searchrange*1.3) then

                    if AirForceDialog then
                        LOG( dialog.." breaks off damaged target "..repr(target.Sync.id).." on tick "..GetGameTick() )
                    end

                    target = false
                    
                    break

                end

                if unit.target and (not attackissued) then

                    if not unit.Dead then

                        IssueAttack( u, target )
                    
                        attackissued = true
                        
                    end

                end

            else

                unit.target = false

                if AirForceDialog then
                    LOG( dialog.." assigned to target "..repr(target.Sync.id).." INVALID LOITER on tick "..GetGameTick() )
                end
                
                break

            end
            
            if unit.target and not target.Dead then
            
                WaitTicks(3)
            
            end

        end
    
        if (not unit.Dead) and unit.PlatoonHandle and aiBrain:PlatoonExists( unit.PlatoonHandle ) then

            if AirForceDialog then
                LOG( dialog.." attack complete on tick "..GetGameTick() )
            end
 
            if not unit.Dead then

                --- we do this as a unit may be in refit at this point - and wont have a loiterposition
                --- this allows this behavior to exit gracefully without any intervention 
                if unit.PlatoonHandle.loiterposition then
                
                    IssueClearCommands( u )

                    IssueMove( u, unit.PlatoonHandle.loiterposition )
                    
                    if recalldelay then
                        WaitTicks(recalldelay)
                    end

                    if AirForceDialog then
                        LOG( dialog.." ready for new orders on tick "..GetGameTick() )
                    end
                    
                    if not unit.Dead and aiBrain:PlatoonExists( unit.PlatoonHandle ) then
 
                        AssignUnitsToPlatoon( aiBrain, unit.PlatoonHandle, u, 'Unassigned','None' )
                    
                    end
                    
                end

            end

        end
        
        unit.IgnoreRefit = nil
        unit.target = false
  
    end

function WeaponFired( weapon, unit )

    if (not unit.Dead) and unit.PlatoonHandle.loiterposition then

        unit.target = false

        IssueClearCommands( {unit} )

        IssueGuard( {unit}, unit.PlatoonHandle.loiterposition )

    end

end
 


-- Basic Air attack logic
function AirForceAILOUD( self, aiBrain )

    local AirForceDialog = ScenarioInfo.AirForceDialog or false

    if AirForceDialog then
        LOG("*AI DEBUG "..aiBrain.Nickname.." AFAI "..self.BuilderName.." "..self.BuilderInstance.." starts")
    end
    
    if not GetPlatoonPosition(self) then
        return
    end

    local CalculatePlatoonThreat    = CalculatePlatoonThreat
	local GetUnitsAroundPoint       = GetUnitsAroundPoint
    local GetPlatoonPosition        = GetPlatoonPosition
    local GetPlatoonUnits           = GetPlatoonUnits    
    local GetSquadUnits             = GetSquadUnits    
	local PlatoonExists             = PlatoonExists	
    
    local LOUDCOPY  = LOUDCOPY
    local LOUDFLOOR = LOUDFLOOR
    local LOUDGETN  = LOUDGETN
    local LOUDMAX   = LOUDMAX
    local LOUDMOD   = math.mod
    local LOUDSORT  = LOUDSORT
    local VDist2Sq  = VDist2Sq
    local VDist3    = VDist3
    local WaitTicks = WaitTicks

    local categoryList = {}
    local count = 0
    
    if self.PlatoonData.PrioritizedCategories then
	
        for _,v in self.PlatoonData.PrioritizedCategories do
            count = count + 1
            categoryList[count] = v
        end
    end

    local platoonUnits = LOUDCOPY(GetPlatoonUnits(self))
    local oldNumberOfUnitsInPlatoon = LOUDGETN(platoonUnits)

	for _,v in platoonUnits do 
	
		if not v.Dead then
		
			if v:TestToggleCaps('RULEUTC_StealthToggle') then
				v:SetScriptBit('RULEUTC_StealthToggle', false)
			end
			
			if v:TestToggleCaps('RULEUTC_CloakToggle') then
				v:SetScriptBit('RULEUTC_CloakToggle', false)
			end
		end
	end

    -- setup escorting fighters if any - pulls out any units in the platoon that are coded as 'guard' in the platoon template
	-- and places them into a seperate platoon with its own behavior
    local guardplatoon = false
	local guardunits = GetSquadUnits( self,'guard')

    if guardunits[1] then

        local ident = Random(4000001,9999999)

        guardplatoon = aiBrain:MakePlatoon('GuardPlatoon'..tostring(ident),'none')
        AssignUnitsToPlatoon( aiBrain, guardplatoon, guardunits, 'Attack', 'none')

		guardplatoon.GuardedPlatoon = self      -- store the handle of the platoon to be guarded to the guardplatoon
        guardplatoon:SetPrioritizedTargetList( 'Attack', categories.HIGHALTAIR * categories.ANTIAIR )

		guardplatoon:SetAIPlan( 'GuardPlatoonAI', aiBrain)
    end
    
    guardplatoon = nil
    guardunits = nil


	-- TETHERING --
	-- Select a target using the target priority list and by looping thru range and difficulty multipliers until a target is found
	-- occurs to me we could pass the multipliers and difficulties from the platoondata if we wished
    
    -- this technique I'll call 'tethering' or leashing - and it will grow and contract with other conditions (air ratio, outnumberedratio)
    -- we loop thru each multiplier - which is used on the basic Searchradius - giving us expanding 'rings'
    -- the maximum size of a ring will fluctuate with the air ratio - more restrictive if losing, larger if winning
    -- the maximum size of a ring will fluctuate with the outnumbered ratio - restrictive if outnumbered, neutral otherwise
    -- then we loop thru all 3 difficulty settings within that ring, looking for the easiest targets first 
    -- comparing our platoon threat against the actual threat we see within 75 of the target position
    -- if we have more - we have a target - and we drop out
    -- if no target, we advance the multiplier and do it again for the next ring
    -- notice how the minimum range of the ring is carried forward from the previous iteration 

	-- force the plan name
	self.PlanName = 'AirForceAILOUD'

    local AIFindTargetInRangeInCategoryWithThreatFromPosition   = AIFindTargetInRangeInCategoryWithThreatFromPosition
    local GetEnemyUnitsInRect                                   = GetEnemyUnitsInRect
    local MergeWithNearbyPlatoons                               = self.MergeWithNearbyPlatoons
    local MovePlatoon                                           = self.MovePlatoon
    local PlatoonGenerateSafePathToLOUD                         = self.PlatoonGenerateSafePathToLOUD
    local SetLoiterPosition                                     = import('/lua/ai/aibehaviors.lua').SetLoiterPosition
    local type = type

    local BOMBER        = categories.BOMBER
    local GROUNDATTACK  = categories.GROUNDATTACK
    local HIGHALTAIR    = categories.HIGHALTAIR
    local UNITCHECK     = categories.ALLUNITS - categories.WALL
    
    if not GetPlatoonPosition(self) then
        return
    end

	local anchorposition    = LOUDCOPY( GetPlatoonPosition(self) )
    local IMAPblocks        = LOUDFLOOR( 128/ScenarioInfo.IMAPSize)
	local loiter            = false
	local loiterposition    = false
    local MissionStartTime  = LOUDFLOOR(LOUDTIME())    
    local missiontime       = self.PlatoonData.MissionTime or 600
    local mergelimit        = self.PlatoonData.MergeLimit or 16
    local MovementLayer     = self.MovementLayer
    local PlatoonFormation  = self.PlatoonData.UseFormation or 'None'
    local Searchradius      = self.PlatoonData.SearchRadius or 200
    local strikerange       = LOUDMAX( 128, ScenarioInfo.IMAPSize )
    local target            = false
    local targetdistance    = false
	local targetposition    = false
    local threatavoid       = 'AntiAir'     --- once engaged with targets use this for threat checks  
    local threatcheckradius = 90  
    local threatcompare     = 'Air'         --- used when looking for targets to go after
    local threatrangeadjust = ScenarioInfo.IMAPRadius
    local threatringrange   = LOUDFLOOR(IMAPblocks/2)
    
    local mult          = { 1, 2, 3 }		--- this multiplies the range of the platoon when searching for targets
	local difficulty    = { 1.2, 1, 0.8 }	--- this divides the base threat of the platoon, by deflating it and then increasing it, so that weaker targets are selected first

    local minrange, mythreat, platPos, Rangemult, searchrange, usethreat, Threatmult
    local AACount, SecondaryAATargets, SecondaryShieldTargets, ShieldCount, TertiaryCount, TertiaryTargets
    local attackcount, attackercount, attackers, retreat
	
	local AIGetThreatLevelsAroundPoint = function(unitposition,threattype)
    
        if not unitposition then
            LOG("*AI DEBUG AIGetThreatLevelsAroundPoint reports NO UNITPOSITION")
            return 0
        end
        
        local adjust = threatrangeadjust + ( threatringrange * threatrangeadjust ) 

        local units,counter = GetEnemyUnitsInRect( aiBrain, unitposition[1]-adjust, unitposition[3]-adjust, unitposition[1]+adjust, unitposition[3]+adjust )
   
        if units then
        
            local bp, threat
            
            threat = 0
            counter = 0
        
            if threattype == 'Air' or threattype == 'AntiAir' then
            
                for _,v in units do
                
                    bp = __blueprints[v.BlueprintID].Defense.AirThreatLevel or 0
                    
                    if bp then
                        
                        threat = threat + bp
                        counter = counter + 1
                    end
                end
            
            elseif threattype == 'AntiSurface' then
            
                for _,v in units do
                
                    bp = __blueprints[v.BlueprintID].Defense.SurfaceThreatLevel or 0
                    
                    if bp then
                        
                        threat = threat + bp
                        counter = counter + 1
                    end
                end
            
            elseif threattype == 'AntiSub' then
            
                for _,v in units do
                
                    bp = __blueprints[v.BlueprintID].Defense.SubThreatLevel or 0
                    
                    if bp then
                        
                        threat = threat + bp
                        counter = counter + 1
                    end
                end

            elseif threattype == 'Economy' then
            
                for _,v in units do
                
                    bp = __blueprints[v.BlueprintID].Defense.EconomyThreatLevel or 0
                    
                    if bp then
                        
                        threat = threat + bp
                        counter = counter + 1
                    end
                end
        
            else
            
                for _,v in units do
                
                    bp = __blueprints[v.BlueprintID].Defense
                    
                    bp = bp.AirThreatLevel + bp.SurfaceThreatLevel + bp.SubThreatLevel + bp.EconomyThreatLevel
                    
                    if bp > 0 then
                        
                        threat = threat + bp
                        counter = counter + 1
                    end
                end
                
            end

            if counter > 0 then
                return threat
            end
        end
        
        return 0
    end

	local DestinationBetweenPoints = function( destination, start, finish, stepsize )

        local VDist2 = VDist2
        
		local steps = LOUDFLOOR( VDist2( start[1],start[3], finish[1],finish[3] ) / stepsize ) + 1

		local xstep = (start[1] - finish[1]) / steps
		local ystep = (start[3] - finish[3]) / steps

		for i = 1, steps do

            if VDist2( start[1] - (xstep * i),start[3] - (ystep * i), destination[1],destination[3]) <= stepsize then
				return { start[1] - (xstep * i), destination[2], start[3] - (ystep * i) }
			end
		end	
		
		return false
	end

    attackcount = 1
    
    while PlatoonExists(aiBrain, self) and (LOUDFLOOR(LOUDTIME()) - MissionStartTime) <= missiontime do

        --- merge with other AirForceAILOUD groups with same plan
        if mergelimit and oldNumberOfUnitsInPlatoon < mergelimit then

			if MergeWithNearbyPlatoons( self, aiBrain, 'AirForceAILOUD', 96, true, mergelimit) then

                if PlatoonFormation != 'None' then
                    self:SetPlatoonFormationOverride(PlatoonFormation)
                end
                
				oldNumberOfUnitsInPlatoon = LOUDGETN(GetPlatoonUnits(self))
                
                if ScenarioInfo.PlatoonMergeDialog then
                    LOG("*AI DEBUG "..aiBrain.Nickname.." "..self.BuilderName.." merges to "..oldNumberOfUnitsInPlatoon)
                end
                
                missiontime = missiontime + 180     --- add 3 minutes
                
                loiter = false      --- force a new loiter position
			end
            
        end

        platoonUnits = LOUDCOPY(GetPlatoonUnits(self))

        attackers     = GetSquadUnits( self,'Unassigned' ) or {}
        attackercount = LOUDGETN(attackers)

        --- this block will look for targets if there are any available 'Unassigned' units in the platoon
        if PlatoonExists(aiBrain, self) and attackercount > 0 then

            mythreat = LOUDMAX( 5, CalculatePlatoonThreat( self, 'Air', UNITCHECK))

            --- the searchrange adapts to the current air ratio, the platoon size, and the mergelimit - and is based on the SearchRadius value
            --- this will limit the searchradius to about 1.95x the base value at max, 85% at minimum
            searchrange = (Searchradius *  LOUDMAX( 0.85, LOUDMIN( 1.5,(aiBrain.AirRatio/1.2)) * LOUDMIN(1, LOUDMIN( 1.3, LOUDGETN(platoonUnits)/(mergelimit/3))) ) )

            usethreat = 0
            minrange = 0

            platPos = self:GetSquadPosition( 'Unassigned' ) or false

            self.UsingTransport = false     --- re-enable merge and DR

			--- the loiter position is the start position of the platoon - not the base where it formed
			--- and is where the platoon returns to if it should be drawn away to attack something or has to retreat
			if platPos != nil and (not loiter) then
                
                loiterposition = SetLoiterPosition( self, aiBrain, anchorposition, searchrange, 1, mythreat, 'AIR', 'ANTIAIR', loiterposition )

                loiter = true

                if AirForceDialog then
                    LOG("*AI DEBUG "..aiBrain.Nickname.." AFAI "..self.BuilderName.." "..self.BuilderInstance.." moving to loiter "..repr(loiterposition))
                end
  
                self.UsingTransport = true  --- disable merge and DR while enroute

                local count = 1

                IssueClearCommands( attackers )

                IssueGuard( attackers, loiterposition)
 
                --- while travelling to the loiter
                while PlatoonExists(aiBrain, self) and platPos and (not self.UnderAttack) and VDist3( loiterposition, platPos ) > searchrange do
                  
                    if count > 1 then
                        --- this permits distressresponse and merging to take place
                        self.UsingTransport = false
                    end

                    WaitTicks(11)
  
                    platPos = self:GetSquadPosition( 'Unassigned' )

                    count = count + 1

                end

                self.UsingTransport = false     --- re-enable merge and DR

            else
            
                if loiter then
           
                    IssueClearCommands( attackers )

                    IssueGuard( attackers, loiterposition)
                
                end
 
            end
           
            if not PlatoonExists(aiBrain, self) then
				return
            end

            --if AirForceDialog then
              --  LOG("*AI DEBUG "..aiBrain.Nickname.." AFAI "..self.BuilderName.." "..self.BuilderInstance.." seek target for "..attackercount.." - searchrange "..string.format("%.1f",searchrange).." AirRatio "..string.format("%.2f",aiBrain.AirRatio).." on tick "..GetGameTick() )
            --end
            
			--- locate a target from the loiterposition -- starting with the closest -- least dangerous ones 
            for _,rangemult in mult do

				for _,threatmult in difficulty do
                
                    usethreat = ( mythreat/threatmult ) / rangemult

					target, targetposition, targetdistance = AIFindTargetInRangeInCategoryWithThreatFromPosition(aiBrain, loiterposition, self, 'Unassigned', minrange, searchrange * rangemult, categoryList, false, threatcompare, threatcheckradius, threatavoid )

					if not PlatoonExists(aiBrain, self) then
						return
					end					

					if target then

                        targetdistance = LOUDSQUARE(targetdistance) --- normalize distance

                        Threatmult = threatmult
						break
					end
				end

                -- record Rangemult value for later use --
                Rangemult = rangemult

				if target then
					searchrange = searchrange * rangemult
					break
				end

                minrange = searchrange * rangemult

            end

            --- if we have a target - find secondary targets
            --- issue the attack orders --- disable merge and distress response
			if (target and not target.Dead) and PlatoonExists(aiBrain, self) then
   
                usethreat = AIGetThreatLevelsAroundPoint( platPos, threatavoid )
                
                --- when threat is greater than mine
                if usethreat > mythreat * 0.85 then

                    --- issue a distress call ---
                    if not self.UnderAttack then
                        self:ForkThread( self.PlatoonUnderAttack, aiBrain)
                    end
                
                    if AirForceDialog then
                        LOG("*AI DEBUG "..aiBrain.Nickname.." AFAI "..self.BuilderName.." "..self.BuilderInstance.." - threat check "..usethreat.." - mine is "..mythreat.." at "..repr(platPos).." on tick "..GetGameTick() )
                    end

                end
           
                AACount         = 0
                SecondaryAATargets      = false

                ShieldCount     = 0
                SecondaryShieldTargets  = false

                TertiaryCount   = 0
                TertiaryTargets         = false

                attackers     = GetSquadUnits( self,'Unassigned' )
                attackercount = LOUDGETN(attackers)

                if attackercount > 2 then

                    --- enemy fighters, gunships & bombers 
                    SecondaryAATargets      = GetUnitsAroundPoint( aiBrain, HIGHALTAIR, targetposition, threatcheckradius, 'Enemy')
                    SecondaryShieldTargets  = GetUnitsAroundPoint( aiBrain, GROUNDATTACK, targetposition, threatcheckradius, 'Enemy')
                    TertiaryTargets         = GetUnitsAroundPoint( aiBrain, BOMBER, targetposition, threatcheckradius, 'Enemy')
                
                    if SecondaryAATargets[1] and (not SecondaryAATargets[1].Dead) then
                        if target != SecondaryAATargets[1] then
                            AACount         = LOUDGETN(SecondaryAATargets)
                        else
                            if SecondaryAATargets[2] and (not SecondaryAATargets[2].Dead) then
                                AACount     = LOUDGETN(SecondaryAATargets) - 1
                            end
                        end
                    end
                
                    if SecondaryShieldTargets[1] and (not SecondaryShieldTargets[1].Dead) then
                        ShieldCount     = LOUDGETN(SecondaryShieldTargets)
                    end
                
                    if TertiaryTargets[1] and (not TertiaryTargets[1].Dead) then
                        if target != TertiaryTargets[1] then
                            TertiaryCount   = LOUDGETN(TertiaryTargets)
                        else
                            if TertiaryTargets[2] and (not TertiaryTargets[2].Dead) then
                                TertiaryCount = LOUDGETN(TertiaryTargets) - 1
                            end
                        end
                        
                    end
                    
                end
                
                if AirForceDialog then

                    LOG("*AI DEBUG "..aiBrain.Nickname.." AFAI "..self.BuilderName.." "..self.BuilderInstance.." gets target "..repr(target.BlueprintID).." distance "..string.format("%.1f",LOUDSQUARE(targetdistance)).." at "..repr(targetposition) )

                    if attackercount > 2 then
                        LOG("*AI DEBUG "..aiBrain.Nickname.." AFAI "..self.BuilderName.." "..self.BuilderInstance.." secondaries AA "..AACount.."  Gunship "..ShieldCount.."  Bomb "..TertiaryCount )
                    end

                end

                if PlatoonExists(aiBrain, self) and target and not target.Dead then
                 
                    attackcount = 1

                    local squad = self:GetSquadPosition('Unassigned') or false
                    
                    targetposition = GetPosition(target)
                    
                    if squad and targetposition != nil then

                        self.UsingTransport = true     --- disable merge and DR

                        local attackissued = false
                        local attackissuedcount = 0

                        -- we assign 30% of the units to attack fighters first
                        -- then another 15% of the units to attack gunships and bombers
                        -- the remaining 30% will attack the primary first
                        local shield    = 1
                        local aa        = 1
                        local tertiary  = 1

                        --- calculate a mid-point position to the target
                        local midpointx = (squad[1] + targetposition[1])/2
                        local midpointy = (squad[2] + targetposition[2])/2
                        local midpointz = (squad[3] + targetposition[3])/2
                    
                        local Direction = GetDirectionInDegrees( squad, targetposition )

                        --- and move towards it
                        IssueFormMove( GetSquadUnits( self, 'Unassigned' ), { midpointx, midpointy, midpointz }, 'AttackFormation', Direction )

                        --- sort the fighters by farthest from target -- we'll send them just ahead of the others to get tighter wave integrity
                        LOUDSORT( attackers, function (a,b) local GetPosition = GetPosition local VDist3Sq = VDist3Sq return VDist3Sq(GetPosition(a),targetposition) > VDist3Sq(GetPosition(b),targetposition) end )
                        
                        if AirForceDialog then
                            LOG("*AI DEBUG "..aiBrain.Nickname.." AFAI "..self.BuilderName.." "..self.BuilderInstance.." issues "..attackercount.." orders" )
                        end

                        for key,u in attackers do
                    
                            if not u.Dead then
                            
                                attackissued = false

                                -- first 15% of attacks go for the gunships
                                if key < attackercount * .15 and SecondaryShieldTargets[shield] then
                        
                                    if (not SecondaryShieldTargets[shield].Dead) and SecondaryShieldTargets[shield] != target then
                                    
                                        u.target = SecondaryShieldTargets[shield]

                                        attackissued = true
                                        attackissuedcount = attackissuedcount + 1
                                    end

                                    if shield >= ShieldCount then
                                        shield = 1
                                    else
                                        shield = shield + 1
                                    end 
                                end
                        
                                -- next 35% go for fighters units
                                if (not attackissued) and key <= attackercount * .5 and SecondaryAATargets[aa] then

                                    if (not SecondaryAATargets[aa].Dead) and SecondaryAATargets[aa] != target then
                                    
                                        u.target = SecondaryAATargets[aa]

                                        attackissued = true
                                        attackissuedcount = attackissuedcount + 1
                                    end
                            
                                    if aa >= AACount then
                                        aa = 1
                                    else
                                        aa = aa + 1
                                    end
                                end
                            
                                -- next 15% for bomber targets --
                                if (not attackissued) and key <= attackercount * .65 and TertiaryTargets[tertiary] then
                            
                                    if (not TertiaryTargets[tertiary].Dead) and TertiaryTargets[tertiary] != target then
                                
                                        u.target = TertiaryTargets[tertiary]

                                        attackissued = true
                                        attackissuedcount = attackissuedcount + 1
                                    end
                                
                                    if tertiary >= TertiaryCount then
                                        tertiary = 1
                                    else 
                                        tertiary = tertiary + 1
                                    end
                                end
                        
                                -- all others go for primary
                                if (not target.Dead) and (not attackissued) then

                                   u.target = target 

                                    attackissued = true
                                    attackissuedcount = attackissuedcount + 1
                                end
                                
                                if attackissued then
                                    u:ForkThread( ProsecuteTarget, aiBrain, u.target, searchrange, 3, AirForceDialog )
                                else
                                    u.target = nil
                                end

                                WaitTicks(1)

                            end

                            if attackissuedcount > 8 then
                                break
                            end

                        end
                        
                        attackercount = attackercount - attackissuedcount
                        
                        --- 1 tick for each secondary --
                        WaitTicks( LOUDFLOOR(attackissuedcount/2) + 1 )
                    end
                    
                end
                
			else
                WaitTicks(2)
            end
            
        end

		--- Cycle over the loiterposition or retreat
		if PlatoonExists(aiBrain, self) then
         
            mythreat    = CalculatePlatoonThreat( self, 'Air', UNITCHECK)
            platPos     = GetPlatoonPosition(self) or false

            if platPos and searchrange then

                attackers       = GetSquadUnits( self,'Unassigned' )
                attackercount   = LOUDGETN(attackers)

                usethreat       = AIGetThreatLevelsAroundPoint( loiterposition, threatavoid )
                
                --- when threat is greater than mine
                if usethreat > mythreat * 1.2 and not retreat then
              
                    if AirForceDialog then
                        LOG("*AI DEBUG "..aiBrain.Nickname.." AFAI "..self.BuilderName.." "..self.BuilderInstance.." ABORT - threat "..usethreat.." - mine is "..mythreat.." at "..repr(platPos).." on tick "..GetGameTick() )
                    end

                    --- find a new loiter between anchor and where we are now
                    local lerpresult = LOUDMIN( 1, LOUDMIN( 1, LOUDMAX( 1, (Searchradius*3)/VDist3(anchorposition, platPos) )))

                    lerpresult = lerpresult * LOUDMIN( 0.6, LOUDMIN( mythreat, mythreat * LOUDMAX(0.28, aiBrain.AirRatio) ) / LOUDMAX(1, usethreat/mythreat) )

                    -- build the loiterposition using the platoon position and LERP it against the anchor
                    loiterposition[1] = LOUDFLOOR( LOUDLERP( lerpresult, anchorposition[1], platPos[1] ))
                    loiterposition[2] = anchorposition[2]
                    loiterposition[3] = LOUDFLOOR( LOUDLERP( lerpresult, anchorposition[3], platPos[3] ))
                    
                    self.loiterposition = LOUDCOPY(loiterposition)
                
                    if AirForceDialog then
                        LOG("*AI DEBUG "..aiBrain.Nickname.." AFAI "..self.BuilderName.." "..self.BuilderInstance.." used "..lerpresult.." for new loiter at "..repr(loiterposition).." on tick "..GetGameTick() )
                    end
                    
                    if attackercount > 0 then
                        IssueGuard( attackers, loiterposition)
                    end

                    attackcount = 4
                    retreat = true

                else
                    retreat = false
                end

                --- rebuild the loiterposition every 11th iteration
                if LOUDMOD( attackcount, 11 ) == 0 then

                    loiterposition = SetLoiterPosition( self, aiBrain, anchorposition, searchrange, 1, mythreat, 'AIR', 'ANTIAIR', loiterposition )

                    --if AirForceDialog then
                      --  LOG("*AI DEBUG "..aiBrain.Nickname.." AFAI "..self.BuilderName.." "..self.BuilderInstance.." rebuilding loiterposition on tick "..GetGameTick() )
                    --end

                    attackcount = 0
                end

                attackcount = attackcount + 1

            else
                return  --- platoon dead
            end
           
            --- while loitering space out the target check
            --- based on number of loitering units otherwise if threat
            --- lets find those targets quickly --
            if loiter and not retreat then

                WaitTicks( 5 + LOUDFLOOR(attackercount/2) )
                
            elseif loiter then
            
                WaitTicks( 2 )
                
            end

		end
        
    end
    
    if (LOUDFLOOR(LOUDTIME()) - MissionStartTime) > missiontime then

        if AirForceDialog then
            LOG("*AI DEBUG "..aiBrain.Nickname.." AFAI "..self.BuilderName.." "..self.BuilderInstance.." Mission Time expired on tick "..GetGameTick() )
        end

    end

    if PlatoonExists(aiBrain, self) then
    
        while PlatoonExists(aiBrain,self) and LOUDGETN(GetSquadUnits( self,'Attack' ) or {}) > 0 do
            WaitTicks(3)
        end
    
        IssueClearCommands( GetPlatoonUnits(self) )

        if AirForceDialog then
            LOG("*AI DEBUG "..aiBrain.Nickname.." AFAI "..self.BuilderName.." "..self.BuilderInstance.." exits to RTB on tick "..GetGameTick() )
        end
    
        return self:SetAIPlan('ReturnToBaseAI',aiBrain)
    end
	
end

-- THIS IS AN ALTERNATIVE AirForceAI specifically for bombers
function AirForceAI_Bomber_LOUD( self, aiBrain )

    local AirForceDialog = ScenarioInfo.AirForceDialog or false
    local dialog = "*AI DEBUG "..aiBrain.Nickname.." AFAI Bomber "..self.BuilderName.." "..repr(self.BuilderInstance)

    if AirForceDialog then
        LOG( dialog.." starts on tick "..GetGameTick())
    end
    
    if not GetPlatoonPosition(self) then
        return
    end

    local CalculatePlatoonThreat    = CalculatePlatoonThreat
	local GetUnitsAroundPoint       = GetUnitsAroundPoint
    local GetPlatoonPosition        = GetPlatoonPosition
    local GetPlatoonUnits           = GetPlatoonUnits    
    local GetSquadUnits             = GetSquadUnits    
    local GetThreatsAroundPosition  = GetThreatsAroundPosition
	local PlatoonExists             = PlatoonExists	
    
    local LOUDCOPY  = LOUDCOPY
    local LOUDFLOOR = LOUDFLOOR
    local LOUDGETN  = LOUDGETN
    local LOUDMAX   = LOUDMAX
    local LOUDMOD   = math.mod
    local LOUDSORT  = LOUDSORT
    local VDist2Sq  = VDist2Sq
    local VDist3    = VDist3
    local WaitTicks = WaitTicks

    local categoryList = {}
    local count = 0
    
    if self.PlatoonData.PrioritizedCategories then
	
        for _,v in self.PlatoonData.PrioritizedCategories do
            count = count + 1
            categoryList[count] = v
        end
    end

    local platoonUnits = LOUDCOPY(GetPlatoonUnits(self))
    local oldNumberOfUnitsInPlatoon = LOUDGETN(platoonUnits)

	for _,v in platoonUnits do 
	
		if not v.Dead then
		
			if v:TestToggleCaps('RULEUTC_StealthToggle') then
				v:SetScriptBit('RULEUTC_StealthToggle', false)
			end
			
			if v:TestToggleCaps('RULEUTC_CloakToggle') then
				v:SetScriptBit('RULEUTC_CloakToggle', false)
			end

            --- add weapon callback for bomb
            for i = 1, v:GetWeaponCount() do

                local weapon = v:GetWeapon(i)

                if weapon.bp.Label == 'Bomb' or weapon.bp.NeedToComputeBombDrop then
                
                    weapon:SetTargetingPriorities( categoryList )

                    weapon:AddWeaponCallback( WeaponFired, 'OnWeaponFired')

                end

            end
       
		end
	end

    -- setup escorting fighters if any - pulls out any units in the platoon that are coded as 'guard' in the platoon template
	-- and places them into a separate platoon with its own behavior
    local guardplatoon = false
	local guardunits = GetSquadUnits( self,'guard')

    if guardunits[1] then
    
        local ident = Random(4000001,999999)

        guardplatoon = aiBrain:MakePlatoon('GuardPlatoon'..tostring(ident),'none')
        AssignUnitsToPlatoon( aiBrain, guardplatoon, guardunits, 'Attack', 'none')

		guardplatoon.GuardedPlatoon = self  #-- store the handle of the platoon to be guarded to the guardplatoon
        guardplatoon:SetPrioritizedTargetList( 'Attack', categories.HIGHALTAIR * categories.ANTIAIR )

		guardplatoon:SetAIPlan( 'GuardPlatoonAI', aiBrain)
    end

    guardplatoon = nil
    guardunits = nil
	
	-- Select a target using priority list and by looping thru range and difficulty multipliers until target is found
	-- occurs to me we could pass the multipliers and difficulties from the platoondata if we wished
	-- force the plan name onto the platoon
	self.PlanName = 'AirForceAI_Bomber_LOUD'
    
    local SetLoiterPosition             = import('/lua/ai/aibehaviors.lua').SetLoiterPosition
    local GetDirectionInDegrees         = GetDirectionInDegrees
    local GetEnemyUnitsInRect           = GetEnemyUnitsInRect
    local MergeWithNearbyPlatoons       = self.MergeWithNearbyPlatoons    

	local anchorposition    = LOUDCOPY( GetPlatoonPosition(self) )
    local IMAPblocks        = LOUDFLOOR( 128/ScenarioInfo.IMAPSize)
	local loiter            = false
	local loiterposition    = false
    local MissionStartTime  = LOUDFLOOR(LOUDTIME())
    local missiontime       = self.PlatoonData.MissionTime or 600
    local mergelimit        = self.PlatoonData.MergeLimit or 20
    local PlatoonFormation  = self.PlatoonData.UseFormation or 'None'
    local Searchradius      = self.PlatoonData.SearchRadius or 200
    local strikerange       = LOUDMAX( 128, ScenarioInfo.IMAPSize )
    local target            = false
    local targetdistance    = false
	local targetposition    = false
    local threatavoid       = 'AntiAir'    
    local threatcheckradius = 96    
    local threatcompare     = 'AntiAir'
    local threatrangeadjust = ScenarioInfo.IMAPRadius    
    local threatringrange   = LOUDFLOOR(IMAPblocks/2)

    local SecondaryAA       = categories.ANTIAIR - categories.AIR
    local SecondaryShield   = categories.SHIELD
    local Tertiary          = categories.ALLUNITS - SecondaryAA - SecondaryShield - categories.AIR - categories.WALL
    
    local mult = { 1, 2, 2.65 }				-- this multiplies the searchradius of the platoon when searching for targets
	local difficulty = { 1.2, 1, 0.8 }	    -- this divides the base threat of the platoon, by deflating it and then increasing it, so that easier targets are selected first

    local mythreat, atthreat, minrange, maxrange, platPos, searchrange, usethreat, Rangemult, Threatmult
    local AACount, ShieldCount, TertiaryCount, SecondaryAATargets, SecondaryShieldTargets, TertiaryTargets
    local attackcount, attackercount, attackers, retreat
	
	local AIGetThreatLevelsAroundPoint = function(unitposition,threattype)
    
        if not unitposition then
            LOG("*AI DEBUG AIGetThreatLevelsAroundPoint reports NO UNITPOSITION")
            return 0
        end
        
        local adjust = threatrangeadjust + ( threatringrange * threatrangeadjust ) 

        local units,counter = GetEnemyUnitsInRect( aiBrain, unitposition[1]-adjust, unitposition[3]-adjust, unitposition[1]+adjust, unitposition[3]+adjust )
   
        if units then
        
            local bp, threat
            
            threat = 0
            counter = 0
        
            if threattype == 'Air' or threattype == 'AntiAir' then
            
                for _,v in units do
                
                    bp = __blueprints[v.BlueprintID].Defense.AirThreatLevel or 0
                    
                    if bp then
                        
                        threat = threat + bp
                        counter = counter + 1
                    end
                end
            
            elseif threattype == 'AntiSurface' then
            
                for _,v in units do
                
                    bp = __blueprints[v.BlueprintID].Defense.SurfaceThreatLevel or 0
                    
                    if bp then
                        
                        threat = threat + bp
                        counter = counter + 1
                    end
                end
            
            elseif threattype == 'AntiSub' then
            
                for _,v in units do
                
                    bp = __blueprints[v.BlueprintID].Defense.SubThreatLevel or 0
                    
                    if bp then
                        
                        threat = threat + bp
                        counter = counter + 1
                    end
                end

            elseif threattype == 'Economy' then
            
                for _,v in units do
                
                    bp = __blueprints[v.BlueprintID].Defense.EconomyThreatLevel or 0
                    
                    if bp then
                        
                        threat = threat + bp
                        counter = counter + 1
                    end
                end
        
            else
            
                for _,v in units do
                
                    bp = __blueprints[v.BlueprintID].Defense
                    
                    bp = bp.AirThreatLevel + bp.SurfaceThreatLevel + bp.SubThreatLevel + bp.EconomyThreatLevel
                    
                    if bp > 0 then
                        
                        threat = threat + bp
                        counter = counter + 1
                    end
                end
                
            end

            if counter > 0 then
                return threat
            end
        end
        
        return 0
    end

	local DestinationBetweenPoints = function( destination, start, finish, stepsize )

		local steps = LOUDFLOOR( VDist2(start[1], start[3], finish[1], finish[3]) / stepsize ) + 1
	
		local xstep = (start[1] - finish[1]) / steps
		local ystep = (start[3] - finish[3]) / steps

		for i = 1, steps do
			
			if VDist2Sq(start[1] - (xstep * i), start[3] - (ystep * i), destination[1], destination[3]) < (stepsize * stepsize) then
				return { start[1] - (xstep * i), destination[2], start[3] - (ystep * i) }
			end
		end	
		
		return false
	end

    attackcount = 1
    
    while PlatoonExists(aiBrain, self) and (LOUDFLOOR(LOUDTIME()) - MissionStartTime) <= missiontime do

        --- merge with (take from) other AirForceAI_Bomber_LOUD groups with same plan within strikerange
        if mergelimit and oldNumberOfUnitsInPlatoon < mergelimit then

			if MergeWithNearbyPlatoons( self, aiBrain, self.PlanName, strikerange, true, mergelimit) then

                if PlatoonFormation != 'None' then
                    self:SetPlatoonFormationOverride(PlatoonFormation)
                end
                
				oldNumberOfUnitsInPlatoon = LOUDGETN(GetPlatoonUnits(self))
                
                if ScenarioInfo.PlatoonMergeDialog or AirForceDialog then
                    LOG( dialog.." merges to "..oldNumberOfUnitsInPlatoon.." units")
                end
                
                missiontime = missiontime + 90     --- add 1.5 minutes
                
                loiter = false      --- force a new loiter position
			end
        end

        platoonUnits = LOUDCOPY(GetPlatoonUnits(self))

        attackers     = GetSquadUnits( self,'Unassigned' ) or {}
        attackercount = LOUDGETN(attackers)

        --- this block will look for targets if there are any available 'Unassigned' units in the platoon
        if PlatoonExists(aiBrain, self) and attackercount > 0 then

            mythreat = CalculatePlatoonThreat( self, 'Surface', categories.ALLUNITS) * 1   -- use full value of surface threat
            mythreat = mythreat + CalculatePlatoonThreat( self, 'Air', categories.ALLUNITS)   -- plus any air threat

            if mythreat < 5 then
                mythreat = 5
            end

            --- the searchrange adapts to the current air ratio, the platoon size, and the mergelimit - and is based on the SearchRadius value
            --- this will limit the searchradius to about 1.5x the base value at max, 85% at minimum due to air ratio
            --- and between that, and 1.3x more, based on the size of the platoon and it's mergelimit (maximum platoon size)
            --- this gives range values between 72% and 210% of the platoons searchradius value based upon conditions and size
            searchrange = Searchradius *  LOUDMAX( 0.85, LOUDMIN( 1.5,(aiBrain.AirRatio/1.2))) * LOUDMAX( 0.85, LOUDGETN(platoonUnits)/(mergelimit/1.4))

            usethreat = 0
            minrange = 0

            platPos = GetPlatoonPosition(self) or false

            self.UsingTransport = false     --- re-enable merge and DR

			--- the loiter position is the start position of the platoon - not the base where it formed
			--- and is where the platoon returns to if it should be drawn away to attack something or has to retreat
			if platPos != nil and (not loiter) then
                
                loiterposition = SetLoiterPosition( self, aiBrain, anchorposition, searchrange, 1, mythreat, 'LAND', 'ANTIAIR', loiterposition )

                loiter = true
 
                self.UsingTransport = true  --- disable merge and DR while enroute

                local count = 1

                attackers     = GetSquadUnits( self,'Unassigned' ) or {}

                IssueClearCommands( attackers )

                --- we use IssueAttack to make sure the bombers don't 'autoattack' anything on the way to the loiter
                IssueAttack( attackers, loiterposition )

                if AirForceDialog then
                    LOG( dialog.." moving to loiter "..repr(loiterposition).." on tick "..GetGameTick())
                end
  
                --- while travelling to the loiter
                while PlatoonExists(aiBrain, self) and platPos and (not self.UnderAttack) and VDist3( loiterposition, platPos ) > searchrange do
                  
                    if count > 1 then
                        --- this permits distressresponse and merging to take place
                        self.UsingTransport = false
                    end

                    WaitTicks(11)
                    
                    if PlatoonExists(aiBrain,self) then

                        platPos = GetPlatoonPosition(self) or false

                        if AirForceDialog then
                            LOG( dialog.." enroute - at "..repr(platPos).." on tick "..GetGameTick() )
                        end
                    
                        count = count + 1
                    else

                        if AirForceDialog then
                            LOG( dialog.." no longer exists on tick "..GetGameTick() )
                        end

                        return
                    end

                end

                if AirForceDialog and PlatoonExists(aiBrain,self) then
                    LOG( dialog.." now at loiter "..repr(loiterposition).." on tick "..GetGameTick() )
                end

                IssueClearCommands( attackers )

                IssueGuard( attackers, loiterposition)
  
                self.UsingTransport = false     --- re-enable merge and DR

            else
            
                if loiter then

                    attackers     = GetSquadUnits( self,'Unassigned' ) or {}           

                    IssueClearCommands( attackers )

                    IssueGuard( attackers, loiterposition)
                
                end
 
            end
           
            if not PlatoonExists(aiBrain, self) then
				return
            end

            if AirForceDialog then
                LOG( dialog.." seeks target - "..attackercount.." bombers - searchrange "..string.format("%.1f",searchrange).." on tick "..GetGameTick() )
            end
            
			--- locate a target from the loiterposition -- starting with the closest -- least dangerous ones 
            for _,rangemult in mult do

				for _,threatmult in difficulty do
                
                    usethreat = ( mythreat/threatmult ) / LOUDSQUARE(rangemult)

					target, targetposition, targetdistance = AIFindTargetInRangeInCategoryWithThreatFromPosition(aiBrain, loiterposition, self, 'Unassigned', minrange, searchrange * rangemult, categoryList, usethreat, threatcompare, threatcheckradius, threatavoid, AirForceDialog )

					if not PlatoonExists(aiBrain, self) then
						return
					end					

					if target then

                        targetdistance = LOUDSQUARE(targetdistance) --- normalize distance

                        Threatmult = threatmult
						break
					end
				end

                -- record Rangemult value for later use --
                Rangemult = rangemult

				if target then
					searchrange = searchrange * rangemult
					break
				end

                minrange = searchrange * rangemult

            end

            --- if we have a target - find secondary targets
            --- issue the attack orders --- disable merge and distress response
			if (target and not target.Dead) and PlatoonExists(aiBrain, self) then
   
                usethreat = AIGetThreatLevelsAroundPoint( platPos, threatavoid )
             
                if AirForceDialog then
                    LOG( dialog.." gets "..repr(target:GetBlueprint().Description).." at "..repr(target:GetPosition()))
                    LOG( dialog.." threat check "..usethreat.." - mine is "..mythreat.." at "..repr(platPos).." on tick "..GetGameTick() )
                end
               
                --- when threat is greater than mine
                if usethreat > mythreat * 0.85 then

                    --- issue a distress call ---
                    if not self.UnderAttack then
                        self:ForkThread( self.PlatoonUnderAttack, aiBrain)
                    end

                end
           
                AACount         = 0
                SecondaryAATargets      = false

                ShieldCount     = 0
                SecondaryShieldTargets  = false

                TertiaryCount   = 0
                TertiaryTargets         = false

                attackers     = GetSquadUnits( self,'Unassigned' ) or {}
                attackercount = LOUDGETN(attackers)

                if attackercount > 2 then
            
                    SecondaryAATargets      = GetUnitsAroundPoint( aiBrain, SecondaryAA, targetposition, threatcheckradius, 'Enemy')
                    SecondaryShieldTargets  = GetUnitsAroundPoint( aiBrain, SecondaryShield, targetposition, threatcheckradius, 'Enemy')
                    TertiaryTargets         = GetUnitsAroundPoint( aiBrain, Tertiary, targetposition, threatcheckradius, 'Enemy')
                
                    if SecondaryAATargets[1] and (not SecondaryAATargets[1].Dead) then
                        if target != SecondaryAATargets[1] then
                            AACount         = LOUDGETN(SecondaryAATargets)
                        else
                            if SecondaryAATargets[2] and (not SecondaryAATargets[2].Dead) then
                                AACount     = LOUDGETN(SecondaryAATargets) - 1
                            end
                        end
                    end
                
                    if SecondaryShieldTargets[1] and (not SecondaryShieldTargets[1].Dead) then
                        ShieldCount     = LOUDGETN(SecondaryShieldTargets)
                    end
                
                    if TertiaryTargets[1] and (not TertiaryTargets[1].Dead) then
                        if target != TertiaryTargets[1] then
                            TertiaryCount   = LOUDGETN(TertiaryTargets)
                        else
                            if TertiaryTargets[2] and (not TertiaryTargets[2].Dead) then
                                TertiaryCount = LOUDGETN(TertiaryTargets) - 1
                            end
                        end
                        
                    end
                    
                end
                
                if AirForceDialog then

                    LOG( dialog.." target "..repr(target.BlueprintID).." distance "..string.format("%.1f",targetdistance).." at "..repr(targetposition).." on tick "..GetGameTick() )

                    if attackercount > 2 then
                        LOG( dialog.." Secondaries - AA "..AACount.." Shields "..ShieldCount.." Tertiary "..TertiaryCount )
                    end

                end

                if PlatoonExists(aiBrain, self) and target and not target.Dead then
                 
                    attackcount = 1

                    local squad = self:GetSquadPosition('Unassigned') or false
                    
                    targetposition = GetPosition(target)
                    
                    if squad and targetposition != nil then

                        self.UsingTransport = true     --- disable merge and DR

                        local attackissued = false
                        local attackissuedcount = 0

                        local shield    = 1
                        local aa        = 1
                        local tertiary  = 1
                        
                        --- if the attack group is further away than the strikerange
                        if targetdistance > strikerange then
                        
                            IssueClearCommands( attackers )

                            --- calculate a mid-point position to the target
                            local midpointx = (squad[1] + targetposition[1])/2
                            local midpointy = (squad[2] + targetposition[2])/2
                            local midpointz = (squad[3] + targetposition[3])/2
                    
                            local Direction = GetDirectionInDegrees( squad, targetposition )

                            --- and move towards it
                            --- again, we use an attack order to keep the bombers from 'auto targeting'
                            IssueFormAttack( GetSquadUnits( self, 'Unassigned' ), { midpointx, midpointy, midpointz }, 'AttackFormation', Direction )
                            
                            WaitTicks(36)

                            attackers     = GetSquadUnits( self,'Unassigned' ) or {}
                            attackercount = LOUDGETN(attackers)
                            
                        end

                        LOUDSORT( attackers, function (a,b) local GetPosition = GetPosition local VDist3Sq = VDist3Sq return VDist3Sq(GetPosition(a),targetposition) > VDist3Sq(GetPosition(b),targetposition) end )
                        
                        if AirForceDialog then
                            LOG( dialog.." issues "..attackercount.." orders - targetdistance is "..string.format("%.1f",targetdistance).." strikerange is "..strikerange.." on tick "..GetGameTick() )
                        end

                        for key,u in attackers do
                    
                            if not u.Dead then
                            
                                if AirForceDialog then
                                    LOG( dialog.." issues orders to "..u.Sync.id.." key "..key.." count is "..attackercount )
                                end
                            
                                attackissued = false

                                -- first 30% of attacks go for shields
                                if key < attackercount * .30 and SecondaryShieldTargets[shield] then
                        
                                    if (not SecondaryShieldTargets[shield].Dead) and SecondaryShieldTargets[shield] != target then
                                    
                                        u.target = SecondaryShieldTargets[shield]

                                        attackissued = true
                                        attackissuedcount = attackissuedcount + 1
                                    end

                                    if shield >= ShieldCount then
                                        shield = 1
                                    else
                                        shield = shield + 1
                                    end 
                                end
                        
                                -- next 30% go for AA units
                                if (not attackissued) and key <= attackercount * .6 and SecondaryAATargets[aa] then

                                    if (not SecondaryAATargets[aa].Dead) and SecondaryAATargets[aa] != target then
                                    
                                        u.target =SecondaryAATargets[aa]

                                        attackissued = true
                                        attackissuedcount = attackissuedcount + 1
                                    end
                            
                                    if aa >= AACount then
                                        aa = 1
                                    else
                                        aa = aa + 1
                                    end
                                end
                            
                                -- next 10% for tertiary targets --
                                if (not attackissued) and key <= attackercount * .7 and TertiaryTargets[tertiary] then
                            
                                    if (not TertiaryTargets[tertiary].Dead) and TertiaryTargets[tertiary] != target then
                                
                                        u.target = TertiaryTargets[tertiary]

                                        attackissued = true
                                        attackissuedcount = attackissuedcount + 1
                                    end
                                
                                    if tertiary >= TertiaryCount then
                                        tertiary = 1
                                    else 
                                        tertiary = tertiary + 1
                                    end
                                end
                        
                                -- all others go for primary
                                if (not target.Dead) and (not attackissued) then

                                    u.target = target

                                    attackissued = true
                                    attackissuedcount = attackissuedcount + 1
                                end
                                
                                if attackissued then
                                 
                                    u:ForkThread( ProsecuteTarget, aiBrain, u.target, searchrange, 41, AirForceDialog )

                                    WaitTicks(1)
                                
                                else
                                
                                    u.target = nil
                                    
                                end

                            end

                        end
                        
                        attackercount = attackercount - attackissuedcount
                        
                        --- 1 tick for each secondary --
                        WaitTicks( attackissuedcount + 1 )
                    end
                    
                end
                
			else
                WaitTicks(2)
            end
            
        end

        attackers     = GetSquadUnits( self,'Attack' ) or {}
        attackercount = LOUDGETN(attackers)

        if attackercount < 1 then
            self.UsingTransport = false
        else
            self.UsingTransport = true
        end

		--- Cycle over the loiterposition or retreat
		if PlatoonExists(aiBrain, self) then

            mythreat = CalculatePlatoonThreat( self, 'Surface', categories.ALLUNITS)
            mythreat = mythreat + CalculatePlatoonThreat( self, 'Air', categories.ALLUNITS)

            if mythreat < 5 then
                mythreat = 5
            end

            platPos     = GetPlatoonPosition(self) or false

            if platPos and searchrange then

                attackers       = GetSquadUnits( self,'Unassigned' )
                attackercount   = LOUDGETN(attackers)

                usethreat       = AIGetThreatLevelsAroundPoint( loiterposition, threatavoid )
                
                --- when threat is greater than mine
                if usethreat > mythreat * 1.2 and not retreat then
              
                    if AirForceDialog then
                        LOG( dialog.." ABORT - threat "..usethreat.." - mine is "..mythreat.." at "..repr(platPos).." on tick "..GetGameTick() )
                    end

                    --- find a new loiter between anchor and where we are now
                    local lerpresult = LOUDMIN( 1, LOUDMIN( 1, LOUDMAX( 1, (Searchradius*3)/VDist3(anchorposition, platPos) )))

                    lerpresult = lerpresult * LOUDMIN( 0.66, LOUDMIN( mythreat, mythreat * LOUDMAX(0.28, aiBrain.AirRatio) ) / LOUDMAX(1, usethreat/mythreat) )

                    -- build the loiterposition using the platoon position and LERP it against the anchor
                    loiterposition[1] = LOUDFLOOR( LOUDLERP( lerpresult, anchorposition[1], platPos[1] ))
                    loiterposition[2] = anchorposition[2]
                    loiterposition[3] = LOUDFLOOR( LOUDLERP( lerpresult, anchorposition[3], platPos[3] ))
                    
                    self.loiterposition = LOUDCOPY(loiterposition)
                
                    if AirForceDialog then
                        LOG( dialog.." used "..lerpresult.." for new loiter at "..repr(loiterposition).." on tick "..GetGameTick() )
                    end
                    
                    if attackercount > 0 then
                        IssueGuard( attackers, loiterposition)
                    end

                    attackcount = 4
                    retreat = true

                else
                    retreat = false
                end

                --- rebuild the loiterposition every 15th iteration
                if LOUDMOD( attackcount, 15 ) == 0 and PlatoonExists(aiBrain, self) then

                    loiterposition = SetLoiterPosition( self, aiBrain, anchorposition, searchrange, 1, mythreat, 'LAND', 'ANTIAIR', loiterposition )

                    attackcount = 0
                end

                attackcount = attackcount + 1

            else
                return  --- platoon dead
            end
           
            --- while loitering space out the target check
            --- based on number of loitering units otherwise if threat
            --- lets find those targets quickly --
            if PlatoonExists(aiBrain, self) then

                if loiter and not retreat then

                    WaitTicks( 7 + LOUDFLOOR(attackercount/2) )
                
                elseif loiter then
            
                    WaitTicks( 2 )
                
                end
            
            end

		end
        
    end

    if PlatoonExists(aiBrain, self) then
    
        if (LOUDFLOOR(LOUDTIME()) - MissionStartTime) >= missiontime then

            if AirForceDialog then
                LOG( dialog.." Mission Time expired on tick "..GetGameTick() )
            end

        end
    
        --- wait for existing attackers to complete their business
        while PlatoonExists(aiBrain,self) and LOUDGETN(GetSquadUnits( self,'Attack' ) or {}) > 0 do
            WaitTicks(3)
        end
        
        if PlatoonExists(aiBrain, self) then
    
            IssueClearCommands( GetPlatoonUnits(self) )
        
            self.UsingTransport = false

            if AirForceDialog then
                LOG( dialog.." exits to RTB on tick "..GetGameTick() )
            end
    
            return self:SetAIPlan('ReturnToBaseAI',aiBrain)
        end
    end
	
end

-- THIS IS AN ALTERNATIVE AirForceAI specifically for torpedo bombers
function AirForceAI_Torpedo_LOUD( self, aiBrain )

    local AirForceDialog = ScenarioInfo.AirForceDialog or false
    local dialog = "*AI DEBUG "..aiBrain.Nickname.." AFAI Torpedo "..self.BuilderName.." "..repr(self.BuilderInstance)

    if AirForceDialog then
        LOG( dialog.." starts on tick "..GetGameTick())
    end
    
    if not GetPlatoonPosition(self) then
        return
    end

    local CalculatePlatoonThreat    = CalculatePlatoonThreat
	local GetUnitsAroundPoint       = GetUnitsAroundPoint
    local GetPlatoonPosition        = GetPlatoonPosition
    local GetPlatoonUnits           = GetPlatoonUnits    
    local GetSquadUnits             = GetSquadUnits    
    local GetThreatsAroundPosition  = GetThreatsAroundPosition
	local PlatoonExists             = PlatoonExists	
    
    local LOUDCOPY  = LOUDCOPY
    local LOUDFLOOR = LOUDFLOOR
    local LOUDGETN  = LOUDGETN
    local LOUDMAX   = LOUDMAX
    local LOUDMOD   = math.mod
    local LOUDSORT  = LOUDSORT
    local VDist2Sq  = VDist2Sq
    local VDist3    = VDist3
    local WaitTicks = WaitTicks

    local categoryList = {}
    local count = 0
    
    if self.PlatoonData.PrioritizedCategories then
	
        for _,v in self.PlatoonData.PrioritizedCategories do
            count = count + 1
            categoryList[count] = v
        end
    end

    local platoonUnits = LOUDCOPY(GetPlatoonUnits(self))
    local oldNumberOfUnitsInPlatoon = LOUDGETN(platoonUnits)

	for _,v in platoonUnits do 
	
		if not v.Dead then
		
			if v:TestToggleCaps('RULEUTC_StealthToggle') then
				v:SetScriptBit('RULEUTC_StealthToggle', false)
			end
			
			if v:TestToggleCaps('RULEUTC_CloakToggle') then
				v:SetScriptBit('RULEUTC_CloakToggle', false)
			end

            --- add weapon callback for bomb
            for i = 1, v:GetWeaponCount() do

                local weapon = v:GetWeapon(i)

                if weapon.bp.Label == 'Torpedo' then
                
                    weapon:SetTargetingPriorities( categoryList )

                    weapon:AddWeaponCallback( WeaponFired, 'OnWeaponFired')

                end

            end
       
		end
	end

    -- setup escorting fighters if any - pulls out any units in the platoon that are coded as 'guard' in the platoon template
	-- and places them into a separate platoon with its own behavior
    local guardplatoon = false
	local guardunits = GetSquadUnits( self,'guard')

    if guardunits[1] then
    
        local ident = Random(4000001,999999)

        guardplatoon = aiBrain:MakePlatoon('GuardPlatoon'..tostring(ident),'none')
        AssignUnitsToPlatoon( aiBrain, guardplatoon, guardunits, 'Attack', 'none')

		guardplatoon.GuardedPlatoon = self  #-- store the handle of the platoon to be guarded to the guardplatoon
        guardplatoon:SetPrioritizedTargetList( 'Attack', categories.HIGHALTAIR * categories.ANTIAIR )

		guardplatoon:SetAIPlan( 'GuardPlatoonAI', aiBrain)
    end

    guardplatoon = nil
    guardunits = nil
	
	-- Select a target using priority list and by looping thru range and difficulty multipliers until target is found
	-- occurs to me we could pass the multipliers and difficulties from the platoondata if we wished
	-- force the plan name onto the platoon
	self.PlanName = 'AirForceAI_Torpedo_LOUD'
    
    local SetLoiterPosition             = import('/lua/ai/aibehaviors.lua').SetLoiterPosition
    local GetDirectionInDegrees         = GetDirectionInDegrees
    local GetEnemyUnitsInRect           = GetEnemyUnitsInRect
    local MergeWithNearbyPlatoons       = self.MergeWithNearbyPlatoons    

	local anchorposition    = LOUDCOPY( GetPlatoonPosition(self) )
    local IMAPblocks        = LOUDFLOOR( 128/ScenarioInfo.IMAPSize)
	local loiter            = false
	local loiterposition    = false
    local MissionStartTime  = LOUDFLOOR(LOUDTIME())
    local missiontime       = self.PlatoonData.MissionTime or 600
    local mergelimit        = self.PlatoonData.MergeLimit or 20
    local PlatoonFormation  = self.PlatoonData.UseFormation or 'None'
    local Searchradius      = self.PlatoonData.SearchRadius or 200
    local strikerange       = LOUDMAX( 128, ScenarioInfo.IMAPSize )
    local target            = false
    local targetdistance    = false
	local targetposition    = false
    local threatavoid       = 'AntiAir'    
    local threatcheckradius = 96    
    local threatcompare     = 'AntiAir'
    local threatrangeadjust = ScenarioInfo.IMAPRadius    
    local threatringrange   = LOUDFLOOR(IMAPblocks/2)

    local SecondaryAA       = categories.CRUISER
    local SecondaryShield   = categories.SHIELD * categories.NAVAL
    local Tertiary          = categories.NAVAL - SecondaryAA - SecondaryShield - categories.AIR - categories.WALL
    
    local mult = { 1, 2, 2.65 }				-- this multiplies the searchradius of the platoon when searching for targets
	local difficulty = { 1.2, 1, 0.8 }	    -- this divides the base threat of the platoon, by deflating it and then increasing it, so that easier targets are selected first

    local mythreat, atthreat, minrange, maxrange, platPos, searchrange, usethreat, Rangemult, Threatmult
    local AACount, ShieldCount, TertiaryCount, SecondaryAATargets, SecondaryShieldTargets, TertiaryTargets
    local attackcount, attackercount, attackers, retreat
	
	local AIGetThreatLevelsAroundPoint = function(unitposition,threattype)
    
        if not unitposition then
            LOG("*AI DEBUG AIGetThreatLevelsAroundPoint reports NO UNITPOSITION")
            return 0
        end
        
        local adjust = threatrangeadjust + ( threatringrange * threatrangeadjust ) 

        local units,counter = GetEnemyUnitsInRect( aiBrain, unitposition[1]-adjust, unitposition[3]-adjust, unitposition[1]+adjust, unitposition[3]+adjust )
   
        if units then
        
            local bp, threat
            
            threat = 0
            counter = 0
        
            if threattype == 'Air' or threattype == 'AntiAir' then
            
                for _,v in units do
                
                    bp = __blueprints[v.BlueprintID].Defense.AirThreatLevel or 0
                    
                    if bp then
                        
                        threat = threat + bp
                        counter = counter + 1
                    end
                end
            
            elseif threattype == 'AntiSurface' then
            
                for _,v in units do
                
                    bp = __blueprints[v.BlueprintID].Defense.SurfaceThreatLevel or 0
                    
                    if bp then
                        
                        threat = threat + bp
                        counter = counter + 1
                    end
                end
            
            elseif threattype == 'AntiSub' then
            
                for _,v in units do
                
                    bp = __blueprints[v.BlueprintID].Defense.SubThreatLevel or 0
                    
                    if bp then
                        
                        threat = threat + bp
                        counter = counter + 1
                    end
                end

            elseif threattype == 'Economy' then
            
                for _,v in units do
                
                    bp = __blueprints[v.BlueprintID].Defense.EconomyThreatLevel or 0
                    
                    if bp then
                        
                        threat = threat + bp
                        counter = counter + 1
                    end
                end
        
            else
            
                for _,v in units do
                
                    bp = __blueprints[v.BlueprintID].Defense
                    
                    bp = bp.AirThreatLevel + bp.SurfaceThreatLevel + bp.SubThreatLevel + bp.EconomyThreatLevel
                    
                    if bp > 0 then
                        
                        threat = threat + bp
                        counter = counter + 1
                    end
                end
                
            end

            if counter > 0 then
                return threat
            end
        end
        
        return 0
    end

	local DestinationBetweenPoints = function( destination, start, finish, stepsize )

		local steps = LOUDFLOOR( VDist2(start[1], start[3], finish[1], finish[3]) / stepsize ) + 1
	
		local xstep = (start[1] - finish[1]) / steps
		local ystep = (start[3] - finish[3]) / steps

		for i = 1, steps do
			
			if VDist2Sq(start[1] - (xstep * i), start[3] - (ystep * i), destination[1], destination[3]) < (stepsize * stepsize) then
				return { start[1] - (xstep * i), destination[2], start[3] - (ystep * i) }
			end
		end	
		
		return false
	end

    attackcount = 1
    
    while PlatoonExists(aiBrain, self) and (LOUDFLOOR(LOUDTIME()) - MissionStartTime) <= missiontime do

        --- merge with (take from) other platoons with same plan within strikerange
        if mergelimit and oldNumberOfUnitsInPlatoon < mergelimit then

			if MergeWithNearbyPlatoons( self, aiBrain, self.PlanName, strikerange, true, mergelimit) then

                if PlatoonFormation != 'None' then
                    self:SetPlatoonFormationOverride(PlatoonFormation)
                end
                
				oldNumberOfUnitsInPlatoon = LOUDGETN(GetPlatoonUnits(self))
                
                if ScenarioInfo.PlatoonMergeDialog or AirForceDialog then
                    LOG( dialog.." merges to "..oldNumberOfUnitsInPlatoon.." units")
                end
                
                missiontime = missiontime + 90     --- add 1.5 minutes
                
                loiter = false      --- force a new loiter position
			end
        end

        platoonUnits = LOUDCOPY(GetPlatoonUnits(self))

        attackers     = GetSquadUnits( self,'Unassigned' ) or {}
        attackercount = LOUDGETN(attackers)

        --- this block will look for targets if there are any available 'Unassigned' units in the platoon
        if PlatoonExists(aiBrain, self) and attackercount > 0 then

            mythreat = CalculatePlatoonThreat( self, 'Surface', categories.ALLUNITS) * 1   -- use full value of surface threat if any
            mythreat = mythreat + CalculatePlatoonThreat( self, 'Sub', categories.ALLUNITS)   -- plus any sub threat

            if mythreat < 5 then
                mythreat = 5
            end

            --- the searchrange adapts to the current air ratio, the platoon size, and the mergelimit - and is based on the SearchRadius value
            --- this will limit the searchradius to about 1.5x the base value at max, 85% at minimum due to air ratio
            --- and between that, and 1.3x more, based on the size of the platoon and it's mergelimit (maximum platoon size)
            --- this gives range values between 72% and 210% of the platoons searchradius value based upon conditions and size
            searchrange = Searchradius *  LOUDMAX( 0.85, LOUDMIN( 1.5,(aiBrain.AirRatio/1.2))) * LOUDMAX( 0.85, LOUDGETN(platoonUnits)/(mergelimit/1.4))

            usethreat = 0
            minrange = 0

            platPos = GetPlatoonPosition(self) or false

            self.UsingTransport = false     --- re-enable merge and DR

			--- the loiter position is the start position of the platoon - not the base where it formed
			--- and is where the platoon returns to if it should be drawn away to attack something or has to retreat
			if platPos != nil and (not loiter) then
                
                loiterposition = SetLoiterPosition( self, aiBrain, anchorposition, searchrange, 1, mythreat, 'NAVAL', 'ANTIAIR', loiterposition )

                loiter = true
 
                self.UsingTransport = true  --- disable merge and DR while enroute

                local count = 1

                attackers     = GetSquadUnits( self,'Unassigned' ) or {}

                IssueClearCommands( attackers )

                IssueGuard( attackers, loiterposition )

                if AirForceDialog then
                    LOG( dialog.." moving to loiter "..repr(loiterposition).." on tick "..GetGameTick())
                end
  
                --- while travelling to the loiter
                while PlatoonExists(aiBrain, self) and platPos and (not self.UnderAttack) and VDist3( loiterposition, platPos ) > searchrange do
                  
                    if count > 1 then
                        --- this permits distressresponse and merging to take place
                        self.UsingTransport = false
                    end

                    WaitTicks(11)
                    
                    if PlatoonExists(aiBrain,self) then

                        platPos = GetPlatoonPosition(self) or false

                        if AirForceDialog then
                            LOG( dialog.." enroute - at "..repr(platPos).." on tick "..GetGameTick() )
                        end
                    
                        count = count + 1
                    else

                        if AirForceDialog then
                            LOG( dialog.." no longer exists on tick "..GetGameTick() )
                        end

                        return
                    end

                end

                if AirForceDialog and PlatoonExists(aiBrain,self) then
                    LOG( dialog.." now at loiter "..repr(loiterposition).." on tick "..GetGameTick() )
                end

                IssueClearCommands( attackers )

                IssueGuard( attackers, loiterposition)
  
                self.UsingTransport = false     --- re-enable merge and DR

            else
            
                if loiter then

                    attackers     = GetSquadUnits( self,'Unassigned' ) or {}           

                    IssueClearCommands( attackers )

                    IssueGuard( attackers, loiterposition)
                
                end
 
            end
           
            if not PlatoonExists(aiBrain, self) then
				return
            end

            if AirForceDialog then
                LOG( dialog.." seeks target - "..attackercount.." torpedo bombers - searchrange "..string.format("%.1f",searchrange).." on tick "..GetGameTick() )
            end
            
			--- locate a target from the loiterposition -- starting with the closest -- least dangerous ones 
            for _,rangemult in mult do

				for _,threatmult in difficulty do
                
                    usethreat = ( mythreat/threatmult ) / LOUDSQUARE(rangemult)

					target, targetposition, targetdistance = AIFindTargetInRangeInCategoryWithThreatFromPosition(aiBrain, loiterposition, self, 'Unassigned', minrange, searchrange * rangemult, categoryList, usethreat, threatcompare, threatcheckradius, threatavoid, AirForceDialog )

					if not PlatoonExists(aiBrain, self) then
						return
					end					

					if target then

                        targetdistance = LOUDSQUARE(targetdistance) --- normalize distance

                        Threatmult = threatmult
						break
					end
				end

                -- record Rangemult value for later use --
                Rangemult = rangemult

				if target then
					searchrange = searchrange * rangemult
					break
				end

                minrange = searchrange * rangemult

            end

            --- if we have a target - find secondary targets
            --- issue the attack orders --- disable merge and distress response
			if (target and not target.Dead) and PlatoonExists(aiBrain, self) then
   
                usethreat = AIGetThreatLevelsAroundPoint( platPos, threatavoid )
             
                if AirForceDialog then
                    LOG( dialog.." gets "..repr(target:GetBlueprint().Description).." at "..repr(target:GetPosition()))
                    LOG( dialog.." threat check "..usethreat.." - mine is "..mythreat.." at "..repr(platPos).." on tick "..GetGameTick() )
                end
               
                --- when threat is greater than mine
                if usethreat > mythreat * 0.85 then

                    --- issue a distress call ---
                    if not self.UnderAttack then
                        self:ForkThread( self.PlatoonUnderAttack, aiBrain)
                    end

                end
           
                AACount         = 0
                SecondaryAATargets      = false

                ShieldCount     = 0
                SecondaryShieldTargets  = false

                TertiaryCount   = 0
                TertiaryTargets         = false

                attackers     = GetSquadUnits( self,'Unassigned' ) or {}
                attackercount = LOUDGETN(attackers)

                if attackercount > 2 then
            
                    SecondaryAATargets      = GetUnitsAroundPoint( aiBrain, SecondaryAA, targetposition, threatcheckradius, 'Enemy')
                    SecondaryShieldTargets  = GetUnitsAroundPoint( aiBrain, SecondaryShield, targetposition, threatcheckradius, 'Enemy')
                    TertiaryTargets         = GetUnitsAroundPoint( aiBrain, Tertiary, targetposition, threatcheckradius, 'Enemy')
                
                    if SecondaryAATargets[1] and (not SecondaryAATargets[1].Dead) then
                        if target != SecondaryAATargets[1] then
                            AACount         = LOUDGETN(SecondaryAATargets)
                        else
                            if SecondaryAATargets[2] and (not SecondaryAATargets[2].Dead) then
                                AACount     = LOUDGETN(SecondaryAATargets) - 1
                            end
                        end
                    end
                
                    if SecondaryShieldTargets[1] and (not SecondaryShieldTargets[1].Dead) then
                        ShieldCount     = LOUDGETN(SecondaryShieldTargets)
                    end
                
                    if TertiaryTargets[1] and (not TertiaryTargets[1].Dead) then
                        if target != TertiaryTargets[1] then
                            TertiaryCount   = LOUDGETN(TertiaryTargets)
                        else
                            if TertiaryTargets[2] and (not TertiaryTargets[2].Dead) then
                                TertiaryCount = LOUDGETN(TertiaryTargets) - 1
                            end
                        end
                        
                    end
                    
                end
                
                if AirForceDialog then

                    LOG( dialog.." target "..repr(target.BlueprintID).." distance "..string.format("%.1f",targetdistance).." at "..repr(targetposition).." on tick "..GetGameTick() )

                    if attackercount > 2 then
                        LOG( dialog.." Secondaries - AA "..AACount.." Shields "..ShieldCount.." Tertiary "..TertiaryCount )
                    end

                end

                if PlatoonExists(aiBrain, self) and target and not target.Dead then
                 
                    attackcount = 1

                    local squad = self:GetSquadPosition('Unassigned') or false
                    
                    targetposition = GetPosition(target)
                    
                    if squad and targetposition != nil then

                        self.UsingTransport = true     --- disable merge and DR

                        local attackissued = false
                        local attackissuedcount = 0

                        local shield    = 1
                        local aa        = 1
                        local tertiary  = 1
                        
                        --- if the attack group is further away than the strikerange
                        if targetdistance > strikerange then
                        
                            IssueClearCommands( attackers )

                            --- calculate a mid-point position to the target
                            local midpointx = (squad[1] + targetposition[1])/2
                            local midpointy = (squad[2] + targetposition[2])/2
                            local midpointz = (squad[3] + targetposition[3])/2
                    
                            local Direction = GetDirectionInDegrees( squad, targetposition )

                            --- and move towards it
                            --- again, we use an attack order to keep from 'auto targeting'
                            IssueFormAttack( GetSquadUnits( self, 'Unassigned' ), { midpointx, midpointy, midpointz }, 'AttackFormation', Direction )
                            
                            WaitTicks(36)

                            attackers     = GetSquadUnits( self,'Unassigned' ) or {}
                            attackercount = LOUDGETN(attackers)
                            
                        end

                        LOUDSORT( attackers, function (a,b) local GetPosition = GetPosition local VDist3Sq = VDist3Sq return VDist3Sq(GetPosition(a),targetposition) > VDist3Sq(GetPosition(b),targetposition) end )
                        
                        if AirForceDialog then
                            LOG( dialog.." issues "..attackercount.." orders - targetdistance is "..string.format("%.1f",targetdistance).." strikerange is "..strikerange.." on tick "..GetGameTick() )
                        end

                        for key,u in attackers do
                    
                            if not u.Dead then
                            
                                if AirForceDialog then
                                    LOG( dialog.." issues orders to "..u.Sync.id.." key "..key.." count is "..attackercount )
                                end
                            
                                attackissued = false

                                -- first 30% of attacks go for shields
                                if key < attackercount * .30 and SecondaryShieldTargets[shield] then
                        
                                    if (not SecondaryShieldTargets[shield].Dead) and SecondaryShieldTargets[shield] != target then
                                    
                                        u.target = SecondaryShieldTargets[shield]

                                        attackissued = true
                                        attackissuedcount = attackissuedcount + 1
                                    end

                                    if shield >= ShieldCount then
                                        shield = 1
                                    else
                                        shield = shield + 1
                                    end 
                                end
                        
                                -- next 30% go for AA units
                                if (not attackissued) and key <= attackercount * .6 and SecondaryAATargets[aa] then

                                    if (not SecondaryAATargets[aa].Dead) and SecondaryAATargets[aa] != target then
                                    
                                        u.target =SecondaryAATargets[aa]

                                        attackissued = true
                                        attackissuedcount = attackissuedcount + 1
                                    end
                            
                                    if aa >= AACount then
                                        aa = 1
                                    else
                                        aa = aa + 1
                                    end
                                end
                            
                                -- next 10% for tertiary targets --
                                if (not attackissued) and key <= attackercount * .7 and TertiaryTargets[tertiary] then
                            
                                    if (not TertiaryTargets[tertiary].Dead) and TertiaryTargets[tertiary] != target then
                                
                                        u.target = TertiaryTargets[tertiary]

                                        attackissued = true
                                        attackissuedcount = attackissuedcount + 1
                                    end
                                
                                    if tertiary >= TertiaryCount then
                                        tertiary = 1
                                    else 
                                        tertiary = tertiary + 1
                                    end
                                end
                        
                                -- all others go for primary
                                if (not target.Dead) and (not attackissued) then

                                    u.target = target

                                    attackissued = true
                                    attackissuedcount = attackissuedcount + 1
                                end
                                
                                if attackissued then
                                  
                                    u:ForkThread( ProsecuteTarget, aiBrain, u.target, searchrange, 41, AirForceDialog )

                                    WaitTicks(1)
                                
                                else
                                
                                    u.target = nil
                                    
                                end

                            end

                        end
                        
                        attackercount = attackercount - attackissuedcount
                        
                        --- 1 tick for each secondary --
                        WaitTicks( attackissuedcount + 1 )
                    end
                    
                end
                
			else
                WaitTicks(2)
            end
            
        end

        attackers     = GetSquadUnits( self,'Attack' ) or {}
        attackercount = LOUDGETN(attackers)

        if attackercount < 1 then
            self.UsingTransport = false
        else
            self.UsingTransport = true
        end

		--- Cycle over the loiterposition or retreat
		if PlatoonExists(aiBrain, self) then

            mythreat = CalculatePlatoonThreat( self, 'Surface', categories.ALLUNITS)
            mythreat = mythreat + CalculatePlatoonThreat( self, 'Sub', categories.ALLUNITS)

            if mythreat < 5 then
                mythreat = 5
            end

            platPos     = GetPlatoonPosition(self) or false

            if platPos and searchrange then

                attackers       = GetSquadUnits( self,'Unassigned' )
                attackercount   = LOUDGETN(attackers)

                usethreat       = AIGetThreatLevelsAroundPoint( loiterposition, threatavoid )
                
                --- when threat is greater than mine
                if usethreat > mythreat * 1.2 and not retreat then
              
                    if AirForceDialog then
                        LOG( dialog.." ABORT - threat "..usethreat.." - mine is "..mythreat.." at "..repr(platPos).." on tick "..GetGameTick() )
                    end

                    --- find a new loiter between anchor and where we are now
                    local lerpresult = LOUDMIN( 1, LOUDMIN( 1, LOUDMAX( 1, (Searchradius*3)/VDist3(anchorposition, platPos) )))

                    lerpresult = lerpresult * LOUDMIN( 0.66, LOUDMIN( mythreat, mythreat * LOUDMAX(0.28, aiBrain.AirRatio) ) / LOUDMAX(1, usethreat/mythreat) )

                    -- build the loiterposition using the platoon position and LERP it against the anchor
                    loiterposition[1] = LOUDFLOOR( LOUDLERP( lerpresult, anchorposition[1], platPos[1] ))
                    loiterposition[2] = anchorposition[2]
                    loiterposition[3] = LOUDFLOOR( LOUDLERP( lerpresult, anchorposition[3], platPos[3] ))
                    
                    self.loiterposition = LOUDCOPY(loiterposition)
                
                    if AirForceDialog then
                        LOG( dialog.." used "..lerpresult.." for new loiter at "..repr(loiterposition).." on tick "..GetGameTick() )
                    end
                    
                    if attackercount > 0 then
                        IssueGuard( attackers, loiterposition)
                    end

                    attackcount = 4
                    retreat = true

                else
                    retreat = false
                end

                --- rebuild the loiterposition every 15th iteration
                if LOUDMOD( attackcount, 15 ) == 0 and PlatoonExists(aiBrain, self) then

                    loiterposition = SetLoiterPosition( self, aiBrain, anchorposition, searchrange, 1, mythreat, 'NAVAL', 'ANTIAIR', loiterposition )

                    attackcount = 0
                end

                attackcount = attackcount + 1

            else
                return  --- platoon dead
            end
           
            --- while loitering space out the target check
            --- based on number of loitering units otherwise if threat
            --- lets find those targets quickly --
            if PlatoonExists(aiBrain, self) then

                if loiter and not retreat then

                    WaitTicks( 7 + LOUDFLOOR(attackercount/2) )
                
                elseif loiter then
            
                    WaitTicks( 2 )
                
                end
            
            end

		end
        
    end

    if PlatoonExists(aiBrain, self) then
    
        if (LOUDFLOOR(LOUDTIME()) - MissionStartTime) >= missiontime then

            if AirForceDialog then
                LOG( dialog.." Mission Time expired on tick "..GetGameTick() )
            end

        end
    
        --- wait for existing attackers to complete their business
        while PlatoonExists(aiBrain,self) and LOUDGETN(GetSquadUnits( self,'Attack' ) or {}) > 0 do
            WaitTicks(3)
        end
        
        if PlatoonExists(aiBrain, self) then
    
            IssueClearCommands( GetPlatoonUnits(self) )
        
            self.UsingTransport = false

            if AirForceDialog then
                LOG( dialog.." exits to RTB on tick "..GetGameTick() )
            end
    
            return self:SetAIPlan('ReturnToBaseAI',aiBrain)
        end
    end
	
end

-- THIS IS AN ALTERNATIVE AirForceAI specifically for gunships
function AirForceAI_Gunship_LOUD( self, aiBrain )

    local CalculatePlatoonThreat    = CalculatePlatoonThreat
	local GetUnitsAroundPoint       = GetUnitsAroundPoint
    local GetPlatoonPosition        = GetPlatoonPosition
    local GetPlatoonUnits           = GetPlatoonUnits    
    local GetSquadUnits             = GetSquadUnits    
    local GetThreatsAroundPosition  = GetThreatsAroundPosition
	local PlatoonExists             = PlatoonExists	
    
    local LOUDCOPY  = LOUDCOPY
    local LOUDFLOOR = LOUDFLOOR
    local LOUDGETN  = LOUDGETN
    local LOUDMAX   = LOUDMAX
    local LOUDSORT  = LOUDSORT
    local VDist2Sq  = VDist2Sq
    local VDist3    = VDist3
    local WaitTicks = WaitTicks
  
    if not GetPlatoonPosition(self) then
        return
    end

	local anchorposition    = LOUDCOPY( GetPlatoonPosition(self) )
    local platoonUnits      = LOUDCOPY( GetPlatoonUnits(self) )
    
    local SetLoiterPosition = import('/lua/ai/aibehaviors.lua').SetLoiterPosition
    
    local Searchradius      = self.PlatoonData.SearchRadius or 200
    local missiontime       = self.PlatoonData.MissionTime or 600
    local mergelimit        = self.PlatoonData.MergeLimit or false
    local PlatoonFormation  = self.PlatoonData.UseFormation or 'None'
  
    local categoryList = {}
    local count = 0
    
    if self.PlatoonData.PrioritizedCategories then
	
        for _,v in self.PlatoonData.PrioritizedCategories do
            count = count + 1
            categoryList[count] = v
        end
    end

    local oldNumberOfUnitsInPlatoon = LOUDGETN(platoonUnits)

	for _,v in platoonUnits do 
	
		if not v.Dead then
		
			if v:TestToggleCaps('RULEUTC_StealthToggle') then
				v:SetScriptBit('RULEUTC_StealthToggle', false)
			end
			
			if v:TestToggleCaps('RULEUTC_CloakToggle') then
				v:SetScriptBit('RULEUTC_CloakToggle', false)
			end
		end
	end

    -- setup escorting fighters if any 
	-- pulls out any units in the platoon that are coded as 'guard' in the platoon template
	-- and places them into a seperate platoon with its own behavior
    local guardplatoon = false
	local guardunits = GetSquadUnits( self,'guard')

    if guardunits[1] then
    
        local ident = Random(1,999999)

        guardplatoon = aiBrain:MakePlatoon('GuardPlatoon'..tostring(ident),'none')
        AssignUnitsToPlatoon( aiBrain, guardplatoon, guardunits, 'Attack', 'none')

		guardplatoon.GuardedPlatoon = self  #-- store the handle of the platoon to be guarded to the guardplatoon
        guardplatoon:SetPrioritizedTargetList( 'Attack', categories.HIGHALTAIR * categories.ANTIAIR )

		guardplatoon:SetAIPlan( 'GuardPlatoonAI', aiBrain)
    end

	local DestinationBetweenPoints = function( destination, start, finish, stepsize )

        local VDist2Sq = VDist2Sq

		local steps = LOUDFLOOR( VDist2(start[1], start[3], finish[1], finish[3]) / stepsize ) + 1
	
		local xstep = (start[1] - finish[1]) / steps
		local ystep = (start[3] - finish[3]) / steps

		for i = 1, steps do
			
			if VDist2Sq(start[1] - (xstep * i), start[3] - (ystep * i), destination[1], destination[3]) < (stepsize * stepsize) then
            
				return { start[1] - (xstep * i), destination[2], start[3] - (ystep * i) }
			end
		end	
		
		return false
	end
	
	-- Select a target using priority list and by looping thru range and difficulty multipliers until target is found
	-- occurs to me we could pass the multipliers and difficulties from the platoondata if we wished
	-- force the plan name onto the platoon
	self.PlanName = 'AirForceAI_Gunship_LOUD'

    local MissionStartTime = LOUDFLOOR(LOUDTIME())
    local threatcheckradius = 96
    
    -- block based IMAP threat checks are controlled by this - allowing it to scale properly with map sizes
    local IMAPblocks = LOUDFLOOR(threatcheckradius/ScenarioInfo.IMAPSize)

    local target = false
	local targetposition = false

	local loiter = false
	local loiterposition = false
    
    local mythreat, atthreat
    
    local threatcompare = 'AntiAir'
    local threatavoid = 'AntiAir'
    
    local mult = { 1, 2, 3 }				-- this multiplies the range of the platoon when searching for targets
	local difficulty = { 1.25, 1, 0.72 } 		-- this divides the base threat of the platoon, by deflating it and then increasing it, so that easier targets are selected first
    
    local minrange, maxrange, searchradius, usethreat
    local Rangemult, Threatmult
    
    local SecondaryAATargets, SecondaryShieldTargets, TertiaryTargets
    local AACount, ShieldCount, TertiaryCount

	local path, reason, prevposition, paththreat
    local newpath, pathsize, destiny
    
    strikerange = LOUDMAX( 96, ScenarioInfo.IMAPSize )
	
    while PlatoonExists(aiBrain, self) and (LOUDFLOOR(LOUDTIME()) - MissionStartTime) <= missiontime do

        -- merge with other AirForceAI_Bomber_LOUD groups with same plan within 80
        if mergelimit and oldNumberOfUnitsInPlatoon < mergelimit then

			if self:MergeWithNearbyPlatoons( aiBrain, 'AirForceAI_Gunship_LOUD', 80, false, mergelimit) then

                if PlatoonFormation != 'None' then
                    self:SetPlatoonFormationOverride(PlatoonFormation)
                end
                
				oldNumberOfUnitsInPlatoon = LOUDGETN(GetPlatoonUnits(self))
                
                if ScenarioInfo.PlatoonMergeDialog then
                    LOG("*AI DEBUG "..aiBrain.Nickname.." "..self.BuilderName.." merges to "..oldNumberOfUnitsInPlatoon)
                end
			end
        end

        platoonUnits = LOUDCOPY(GetPlatoonUnits(self))

        if (not target or target.Dead) and PlatoonExists(aiBrain, self) then

            mythreat = CalculatePlatoonThreat( self, 'Surface', categories.ALLUNITS) * .65   -- use only 1/2 of surface threat for target search 
            mythreat = mythreat + CalculatePlatoonThreat( self, 'Air', categories.ALLUNITS)   -- plus any air threat

            if mythreat < 5 then
                mythreat = 5
            end
            
            -- the searchradius adapts to the current air ratio but is limited by formation size
            searchradius = LOUDMAX(Searchradius, (Searchradius *  LOUDMAX(1, (aiBrain.AirRatio/3) * LOUDMIN(1, LOUDGETN(platoonUnits)/15) ) ) )

            usethreat = 0
            minrange = 0

			-- the anchorposition is the start position of the platoon
			-- where the platoon returns to
			-- if it should be drawn away due to distress calls
			if GetPlatoonPosition(self) then
			
				if not loiter then
                
                    loiterposition = SetLoiterPosition( self, aiBrain, anchorposition, searchradius, 3, mythreat, 'LAND', 'ANTIAIR' )

                    IssueClearCommands( GetSquadUnits( self,'Attack') )

                    IssueGuard( GetSquadUnits( self,'Attack'), loiterposition)
                    
                    loiter = true

				end
                
			else
				return self:SetAIPlan('ReturnToBaseAI',aiBrain)
			end

            for _,rangemult in mult do

				for _,threatmult in difficulty do
                
                    usethreat = ( mythreat/threatmult ) / rangemult

					target, targetposition = AIFindTargetInRangeInCategoryWithThreatFromPosition(aiBrain, loiterposition, self, 'Attack', minrange, searchradius * rangemult, categoryList, usethreat, threatcompare, threatcheckradius, threatavoid )

					if not PlatoonExists(aiBrain, self) then
						return
					end					

					if target then
                    
                        self.UsingTransport = true
                        
                        Threatmult = threatmult
						break
					end

				end
                
                -- record Rangemult value for later use --
                Rangemult = rangemult
                
				if target then
					maxrange = searchradius * rangemult
					break
				end

                minrange = searchradius * rangemult
                
                WaitTicks(1)                
            end
        
			if (target and not target.Dead) and PlatoonExists(aiBrain, self) then
            
                SecondaryAATargets = false
                AACount = 0
                SecondaryShieldTargets = false
                ShieldCount = 0
                TertiaryTargets = false
                TertiaryCount = 0
            
                SecondaryAATargets = GetUnitsAroundPoint( aiBrain, categories.ANTIAIR - categories.AIR, targetposition, threatcheckradius/2, 'Enemy')
                SecondaryShieldTargets = GetUnitsAroundPoint( aiBrain, categories.SHIELD, targetposition, threatcheckradius/2, 'Enemy')
                TertiaryTargets = GetUnitsAroundPoint( aiBrain, categories.ALLUNITS - categories.ANTIAIR - categories.AIR - categories.SHIELD - categories.WALL, targetposition, threatcheckradius/4, 'Enemy')
                
                --LOG("*AI DEBUG "..aiBrain.Nickname.." "..self.BuilderName.." with "..LOUDGETN(GetSquadUnits( self,'Attack')).." bombers has target at "..repr(targetposition))
                --LOG("*AI DEBUG "..aiBrain.Nickname.." "..self.BuilderName.." target is "..repr(target:GetBlueprint().Description))
                --LOG("*AI DEBUG "..aiBrain.Nickname.." "..self.BuilderName.." used RangeMult of "..Rangemult.." and Difficulty of "..Threatmult)
                
                if SecondaryAATargets[1] then
                    AACount = LOUDGETN(SecondaryAATargets)
                end
                
                if SecondaryShieldTargets[1] then
                    ShieldCount = LOUDGETN(SecondaryShieldTargets)
                end
                
                if TertiaryTargets[1] then
                    TertiaryCount = LOUDGETN(TertiaryTargets)
                end

                -- Have a target - plot path to target - Use airthreat vs. mythreat for path
                -- use strikerange to determine point from which to switch into attack mode
				prevposition = LOUDCOPY(GetPlatoonPosition(self))

				paththreat = (oldNumberOfUnitsInPlatoon * 1) + CalculatePlatoonThreat( self, 'Air', categories.ALLUNITS)

                path, reason = self.PlatoonGenerateSafePathToLOUD(aiBrain, self, self.MovementLayer, prevposition, targetposition, paththreat, strikerange )

                if path and PlatoonExists(aiBrain, self) then

                    IssueClearCommands( platoonUnits )
                    
                    newpath = {}
                    count = 0
                    pathsize = LOUDGETN(path)

                    -- build a newpath that gets the platoon to within strikerange
                    -- rather than going all the way to target
                    for waypoint,p in path do
                    
                        destiny = DestinationBetweenPoints( targetposition, prevposition, p, strikerange )

                        if waypoint < pathsize and not destiny then

                            count = count + 1
                            newpath[count] = p

                            prevposition = p
                            
						else
                        
                            if destiny then
                            
                                -- if path breakoff point is not the same as the prevposition - add it to the path
                                if destiny[1] != prevposition[1] and destiny[3] != prevposition[3] then
                            
                                    count = count + 1
                                    newpath[count] = LOUDCOPY(destiny)
                                    
                                end
                                
                            end
                            
                            break
                        end
                    end
                    
                    --LOG("*AI DEBUG "..aiBrain.Nickname.." "..self.BuilderName.." has path "..repr(path))
                    --LOG("*AI DEBUG "..aiBrain.Nickname.." "..self.BuilderName.." vs using "..repr(newpath))

                    -- if we have a path - versus direct which will have zero path entries --
                    if newpath[1] then

                        -- move the platoon to within strikerange in formation - the slackvalue is based on the strikerange
                        self.MoveThread = self:ForkThread( self.MovePlatoon, newpath, 'AttackFormation', false, strikerange * .4)

                        -- wait for the movement orders to execute --
                        while PlatoonExists(aiBrain, self) and self.MoveThread and not target.Dead do
                        
                            WaitTicks(1)

                            if target.Dead then

                                loiter = false
                                
                                break
                            end
                        end
                        
                    else
                        WaitTicks(10)   -- let direct move execute for one second
                    end

                    if self.MoveThread then
                        self:KillMoveThread()
                    end

                else

					target = false
                end

                if PlatoonExists(aiBrain, self) and target and not target.Dead then
                
                    -- we assign 30% of the units to attack shields first
                    -- then another 20% of the units to attack AA first
                    -- and another 15% for incidentals
                    -- the remaining 35% will attack the primary first
                    local attackers = GetSquadUnits( self,'Attack')
                    local attackercount = LOUDGETN(attackers)
                    
                    local shield = 1
                    local aa = 1
                    local tertiary = 1

                    local squad = GetPlatoonPosition(self) or false
                    
                    targetposition = GetPosition(target) or false
                    
                    if squad and targetposition then
                    
                        local midpointx = (squad[1]+targetposition[1])/2
                        local midpointy = (squad[2]+targetposition[2])/2
                        local midpointz = (squad[3]+targetposition[3])/2
                    
                        local Direction = GetDirectionInDegrees( squad, targetposition )

                        -- this gets them moving to a point halfway to the targetposition - hopefully
                        IssueFormMove( GetPlatoonUnits(self), { midpointx, midpointy, midpointz }, 'AttackFormation', Direction )

                        -- sort the bombers by farthest from target -- we'll send them just ahead of the others to get tighter wave integrity
                        LOUDSORT( attackers, function (a,b) local GetPosition = GetPosition local VDist3Sq = VDist3Sq return VDist3Sq(GetPosition(a),targetposition) > VDist3Sq(GetPosition(b),targetposition) end )
                   
                        local attackissued = false
                        local attackissuedcount = 0

                        for key,u in attackers do
                    
                            if not u.Dead then
                        
                                IssueClearCommands( {u} )
                            
                                attackissued = false

                                -- first 30% of attacks go for the shields
                                if key < attackercount * .3 and SecondaryShieldTargets[shield] then
                        
                                    if not SecondaryShieldTargets[shield].Dead then
                                        IssueAttack( {u}, SecondaryShieldTargets[shield] )
                                        attackissued = true
                                        attackissuedcount = attackissuedcount + 1
                                    end

                                    if shield >= ShieldCount then
                                        shield = 1
                                    else
                                        shield = shield + 1
                                    end 
                                end
                        
                                -- next 20% go for AA units
                                if not attackissued and key <= attackercount * .5 and SecondaryAATargets[aa] then

                                    if not SecondaryAATargets[aa].Dead then
                                        IssueAttack( {u}, SecondaryAATargets[aa] )
                                        attackissued = true
                                        attackissuedcount = attackissuedcount + 1
                                    end
                            
                                    if aa >= AACount then
                                        aa = 1
                                    else
                                        aa = aa + 1
                                    end
                                end
                            
                                -- next 15% for tertiary targets --
                                if not attackissued and key <= attackercount * .65 and TertiaryTargets[tertiary] then
                            
                                    if not TertiaryTargets[tertiary].Dead and self:CanAttackTarget('Attack', TertiaryTargets[tertiary]) then
                                        IssueAttack( {u}, TertiaryTargets[tertiary] )
                                        attackissued = true
                                        attackissuedcount = attackissuedcount + 1
                                    end
                                
                                    if tertiary >= TertiaryCount then
                                        tertiary = 1
                                    else 
                                        tertiary = tertiary + 1
                                    end
                                end
                        
                                -- all others go for primary
                                if (not target.Dead) and not attackissued then

                                    IssueAttack( {u}, target )
                                    attackissued = true
                                    attackissuedcount = attackissuedcount + 1
                                end
                    
                                if attackissuedcount > 3 then
                                    WaitTicks(1)
                                    attackissuedcount = 0
                                end
                            end
                        end
                        
                    end
                    
                end
                
			else
                target = false
            end
            
        end

		-- Attack until target is dead, beyond maxrange or retreat
		while (target and not target.Dead) and PlatoonExists(aiBrain, self) and (VDist3( GetPosition(target), loiterposition ) <= maxrange) do
           
            mythreat = CalculatePlatoonThreat( self, 'Surface', categories.ALLUNITS) * .65   -- use 65% of surface threat
            mythreat = mythreat + CalculatePlatoonThreat( self, 'Air', categories.ALLUNITS)   -- plus any air threat
            
            atthreat = 0
            
            for _, v in GetThreatsAroundPosition( aiBrain, GetPlatoonPosition(self), LOUDFLOOR(IMAPblocks/2), true, threatavoid ) do
            
                atthreat = atthreat + v[3]
                
                if atthreat > mythreat then
                
                    --LOG("*AI DEBUG "..aiBrain.Nickname.." "..self.BuilderName.." AA threat too high "..atthreat.." - aborting - my threat "..mythreat.." using "..LOUDFLOOR(IMAPblocks/2).." IMAP blocks")
                    
                    return self:SetAIPlan('ReturnToBaseAI',aiBrain)
                end
            end

			WaitTicks(4)
            
            if VDist3( GetPlatoonPosition(self), loiterposition ) > maxrange then
            
                break
                
            end
    
		end

        -- we had a target and target is destroyed
		if target and PlatoonExists(aiBrain, self) then
        
            IssueClearCommands(self)

			target = false
            
            loiter = true
            
            MoveToLocation( self, loiterposition, false )

		end

		-- loiter will be true if we did not find a target or couldn't get to the target
		if loiter then
			WaitTicks(10)
		end

        self.UsingTransport = false
        
    end

    if PlatoonExists(aiBrain, self) then
        return self:SetAIPlan('ReturnToBaseAI',aiBrain)
    end
	
end

-- Basic Naval attack logic
-- Creates a list of naval bases, water based mass and combat markers
-- Will use this list as a target list unless there is local contact
function NavalForceAILOUD( self, aiBrain )

    if ScenarioInfo.NavalForceDialog then
        LOG("*AI DEBUG "..aiBrain.Nickname.." NFAI "..self.BuilderName.." starts")
    end
    
    local platPos = GetPlatoonPosition(self)

	if not platPos then
        return self:SetAIPlan('ReturnToBaseAI',aiBrain)
    end

    local LOUDCOPY      = LOUDCOPY
	local LOUDGETN      = LOUDGETN
    local LOUDINSERT    = LOUDINSERT
	local LOUDPARSE     = ParseEntityCategory
	local VDist3        = VDist3

	local GetHiPriTargetList        = GetHiPriTargetList
	local GetNumUnitsAroundPoint    = GetNumUnitsAroundPoint
    local GetPlatoonPosition        = GetPlatoonPosition
    local GetPlatoonUnits           = GetPlatoonUnits    
    local GetSquadUnits             = GetSquadUnits
    local GetTerrainHeight          = GetTerrainHeight
    local GetSurfaceHeight          = GetSurfaceHeight
	local GetUnitsAroundPoint       = GetUnitsAroundPoint
	local PlatoonExists             = PlatoonExists	
	
	local AIGetMarkerLocations  = AIGetMarkerLocations
	local FindTargetInRange     = import('/lua/ai/aiattackutilities.lua').FindTargetInRange
    local GetDirectionInDegrees = GetDirectionInDegrees

    local armyIndex = aiBrain.ArmyIndex
	local bAggroMove = false        -- Dont move flotillas aggressively - use formation

    local data = self.PlatoonData
    
	local MergeLimit        = data.MergeLimit or 60
    local MissionStartTime  = self.CreationTime			    -- when the mission began (creation of the platoon)
	local MissionTime       = data.MissionTime or 1200		-- how long platoon will operate before RTB
    local SearchRadius      = data.SearchRadius or 350		-- used to locate local targets to attack
	local PlatoonFormation  = data.UseFormation or 'GrowthFormation'

    local categoryList = {}
    local count = 0

    if data.PrioritizedCategories then
	
        for _,v in data.PrioritizedCategories do

            count = count + 1
            categoryList[count] = LOUDPARSE( v )
         end
    else
        count = count + 1
		categoryList[count] = categories.NAVAL
	end

    --self:SetPrioritizedTargetList( 'Attack', categoryList )

	local maxRange, selectedWeaponArc, turretPitch = import('/lua/ai/aiattackutilities.lua').GetNavalPlatoonMaxRange(aiBrain, self)

	local platoonUnits = GetPlatoonUnits(self)
	local oldNumberOfUnitsInPlatoon = LOUDGETN(platoonUnits)

	local OriginalThreat = CalculatePlatoonThreat( self, 'Overall', categories.ALLUNITS)

	local navalmarkers = ScenarioInfo['Naval Area'] or AIGetMarkerLocations('Naval Area')
	local combatmarkers = ScenarioInfo['Combat Zone'] or AIGetMarkerLocations('Combat Zone')
	local massmarkers = ScenarioInfo['Mass'] or AIGetMarkerLocations('Mass')

	-- make a copy of the naval base markers
	local navalAreas = LOUDCOPY(navalmarkers)

    if ScenarioInfo.NavalForceDialog then
        LOG("*AI DEBUG "..aiBrain.Nickname.." NFAI "..self.BuilderName.." "..self.BuilderInstance.." collects areas")
    end

	-- add any combat zones that may be in the water
	for k,v in combatmarkers do
		
		if GetTerrainHeight(v.Position[1], v.Position[3]) < GetSurfaceHeight(v.Position[1], v.Position[3]) then
			LOUDINSERT(navalAreas, v)
		end
	end

	-- add any mass points that might be in the water or near a water path node
	for k,v in massmarkers do
		
		if GetTerrainHeight(v.Position[1], v.Position[3]) < GetSurfaceHeight(v.Position[1], v.Position[3]) then
		
			LOUDINSERT(navalAreas, v)
		else
            -- if platoon capable of bombardment --
            if maxRange then
            
                local nearwater = import('/lua/ai/aiutilities.lua').AIGetMarkersAroundLocation( aiBrain, 'Water Path Node', v.Position, maxRange * .25 )
			
                if nearwater[1] then
                    --LOG("*AI DEBUG "..aiBrain.Nickname.." Mass point in range "..(maxRange *.25).." of "..repr(v.Position).. " Adding "..repr(nearwater[1]))
                    LOUDINSERT(navalAreas, nearwater[1])
                end
			end
		end
	end
	
	navalmarkers = nil
	combatmarkers = nil
	massmarkers = nil

	-- remove any points within 100 of ourselves
	-- or 100 of any Base we may have
	for k,v in navalAreas do
	
		if VDist3( v.Position, platPos ) < 100 then
			navalAreas[k] = nil
		else
		
			for _,base in aiBrain.BuilderManagers do
			
				if VDist3( v.Position, base.Position ) < 100 then
				
					navalAreas[k] = nil
					break
				end
			end
		end			
	end

	-- rebuild the table
	navalAreas = aiBrain:RebuildTable(navalAreas)

	local destination, destinationpath, target, targetposition

	local function StopAttack( self )

		self:Stop()
		
		destination = false
		destinationpath = false
		
		target = false
		targetposition = false
	end

	local EndMissionTime = LOUDFLOOR(LOUDTIME()) + MissionTime
    local MergeWithNearbyPlatoons = self.MergeWithNearbyPlatoons
    local MovementLayer = self.MovementLayer
    local PlatoonGenerateSafePathToLOUD = self.PlatoonGenerateSafePathToLOUD
    
	local ethreat, ecovalue, milvalue, mythreat, sthreat, targetlist, targetvalue, updatedtargetposition, value, waitneeded
	local distancefactor, path, pathlength, PrevPlatPos, reason, SearchPosition, TargetPosition, TargetType
	
	-- force the plan name
	self.PlanName = 'NavalForceAILOUD'

    local targettypes = {}

    targettypes["Naval"] = true
    targettypes["Commander"] = true
    targettypes["StructuresNotMex"] = true
  
    while PlatoonExists(aiBrain, self) do

		target = false
        destination = false

        platPos = GetPlatoonPosition(self)
        
        local AttackUnits = GetSquadUnits( self, 'Attack' )
        local ArtyUnits = GetSquadUnits( self,'Artillery')

		-- seek LOCAL targets in the searchRadius range using the attackpriority list - they must also be on the same layer
        -- sets target and issues attack orders -- can happen during movement --
        if AttackUnits[1] then

            if ScenarioInfo.NavalForceDialog then
                LOG("*AI DEBUG "..aiBrain.Nickname.." NFAI "..self.BuilderName.." "..self.BuilderInstance.." seeks local target -- movement thread is "..repr(self.MoveThread) )
            end

            -- find a target - normally using the platoon position - but SearchPosition keeps the search from drifting from the original position
            target, TargetPosition = FindTargetInRange( self, aiBrain, 'Attack', SearchRadius, categoryList, true, SearchPosition )

            -- if target, insure that destination is in water
            if target and not target.Dead then

                if GetTerrainHeight(TargetPosition[1], TargetPosition[3]) < GetSurfaceHeight(TargetPosition[1], TargetPosition[3]) - 1 then

                    self.UsingTransport = true    -- prevent merges and DistressResponses --

                    if self.MoveThread then
                        self:KillMoveThread()
                    end

                    if ScenarioInfo.NavalForceDialog then
                        LOG("*AI DEBUG "..aiBrain.Nickname.." NFAI "..self.BuilderName.." "..self.BuilderInstance.." gets local target "..repr(target:GetBlueprint().Description) )
                    end
                    
                    -- store the Platoon Position for reference
                    if not SearchPosition then
                        SearchPosition = LOUDCOPY(platPos)
                    end
				
                    self:Stop()
                    
                    if ArtyUnits[1] and PrevPlatPos then
                        IssueFormMove( ArtyUnits, PrevPlatPos, 'AttackFormation', GetDirectionInDegrees( PrevPlatPos, platPos) )     -- move the arty units to the back --
                    end

                    local GuardUnits = GetSquadUnits( self,'Guard')
                    
                    if GuardUnits[1] then
                    
                        IssueClearCommands(GuardUnits)
                        value = 1

                        -- Make sure any units in platoon which are guards are actually guarding attack units
                        for _,unit in AttackUnits do
					
                            if (not unit.Dead) then
							
                                -- issue a guard order to each guard unit to the first attack unit we find --
                                if GuardUnits[value] then

                                    if ScenarioInfo.NavalForceDialog then
                                        LOG("*AI DEBUG "..aiBrain.Nickname.." NFAI "..self.BuilderName.." "..self.BuilderInstance.." sets guard unit "..value.." to unit "..repr(unit:GetBlueprint().Description) )
                                    end

                                    IssueGuard( {GuardUnits[value]}, unit )
                                    value = value + 1
                                else
                                    break
                                end
                            end
                        end

                    end	

                else
                    target = false
                end

            else
                target = false
            end
            
        end

		-- locate HIPRI target if no target and no movement orders -- use HiPri list or random Naval marker
        -- this will set destination but not target
        if AttackUnits[1] and (not target) and (not self.MoveThread) then
        
            SearchPosition = false  -- clear the Search position when we failed to find a local target

            if ScenarioInfo.NavalForceDialog then
                LOG("*AI DEBUG "..aiBrain.Nickname.." NFAI "..self.BuilderName.." "..self.BuilderInstance.." seeks HiPri destination") 
            end
		
			-- get HiPri list
			targetlist = GetHiPriTargetList( aiBrain, platPos, targettypes, 2000, true )
			targetvalue = 0

            mythreat = CalculatePlatoonThreat( self, 'Overall', categories.ALLUNITS)
	
			LOUDSORT(targetlist, function(a,b) return a.Distance < b.Distance end )

			-- use the HIPRI targetlist -- to set a destination
			for _,Target in targetlist do
                
                TargetPosition = Target.Position
                TargetThreats = Target.Threats
                TargetType = Target.Type
                
				if PlatoonExists( aiBrain, self ) then

					if not GetTerrainHeight(TargetPosition[1], TargetPosition[3]) < GetSurfaceHeight(TargetPosition[1], TargetPosition[3]) - 1 then
						continue    -- skip targets that are NOT in or on water
					end					

					sthreat = TargetThreats.Sur + TargetThreats.Sub
					ethreat = TargetThreats.Eco

					if sthreat < 1 then
						sthreat = 1
					end

					if ethreat < 1 then
						ethreat = 1
					end

					ecovalue = LOUDMAX(.5, ethreat/mythreat)

					if ecovalue > 1.5 then
						ecovalue = LOUDMIN( 3, LOUDSQRT(ecovalue) )
                    end

					-- target value is relative to the platoons strength vs. the targets strength
					-- cap the value at 3 to limit chasing worthless targets
					-- anything stronger than us gets devalued to avoid going after targets too strong
					milvalue =  (mythreat/sthreat) 

					if milvalue > 1.5 then 
					
						milvalue = LOUDMIN( 4, LOUDSQRT(milvalue) )
						ecovalue = LOUDMIN( 3, ecovalue * milvalue )

					elseif milvalue < 1 then
					
						milvalue = milvalue * milvalue
						ecovalue = ecovalue * .8
					end

					-- now add in the economic value of the target
					-- this will make targets that we are stronger than, that have eco value, even more valuable
					-- and targets that have overpowering military value made even less valuable
					-- which should focus the platoon on economic goals versus ground units
					value = ecovalue * milvalue

					-- ignore targets we are still too weak against
					if value < 1.0 then
						continue
					end

					-- naval platoons must be able to get to the position
					path, reason, pathlength = PlatoonGenerateSafePathToLOUD( aiBrain, self, MovementLayer, platPos, TargetPosition, mythreat, 250 )

					-- if we have a path to the target and its value is highest one so far then set destination
					-- and store the targetvalue for comparison 
					if path and PlatoonExists( aiBrain, self ) then

						distancefactor = aiBrain.dist_comp/Target.Distance   -- makes closer targets more valuable

						if VDist3( platPos, TargetPosition) < 500 then -- and very close targets even more valuable
							distancefactor = distancefactor * 2
						end
					
						-- store the destination of the most valuable target
						if (value * distancefactor) > targetvalue then
						
							targetvalue = (value * distancefactor)
							destination = LOUDCOPY(TargetPosition)
							destinationpath = LOUDCOPY( path )
						end
					end
				
					WaitTicks(1) -- check next target --
				else
				
					destination = false
					break
				end

			end

        end

        -- no target or destination - seek one of the navalAreas as destination
        if AttackUnits[1] and (not target) and (not destination) and (not self.MoveThread) then

            if ScenarioInfo.NavalForceDialog then
                LOG("*AI DEBUG "..aiBrain.Nickname.." NFAI "..self.BuilderName.." "..self.BuilderInstance.." seeks navalArea destination")
            end

			-- use a navalArea position -- set that as the destinatin but with target == false
            -- this should get the platoon moving somewhere but revert to checking for new choices along the way
			if PlatoonExists( aiBrain,self) then
			
				navalAreas = aiBrain:RebuildTable(navalAreas)
                
                platPos = GetPlatoonPosition(self) or false
				
				if platPos and navalAreas[1] then
				
					for k,v in RandomIter(navalAreas) do
                
                        TargetPosition = v.Position

						-- this is essentially the AVOIDS BASES function -- if we find an allied naval base there we'll just skip this BUT we'll keep it for later checking
						if GetNumUnitsAroundPoint( aiBrain, categories.NAVAL * categories.STRUCTURE, TargetPosition, 75, 'Ally' ) > 0 then
							continue
						end
						
						if PlatoonExists(aiBrain, self) then

							path, reason = self.PlatoonGenerateSafePathToLOUD( aiBrain, self, MovementLayer, platPos, TargetPosition, mythreat, 250 )

							-- remove this entry from the platoons list since are either going there or we cant get there
							navalAreas[k] = nil

							if path then

                                -- set a destination but note the FALSE on the target -- we'll start moving but we'll then cycle back 
                                -- and keep looking for targets --
                                destination = LOUDCOPY( TargetPosition )
                                destinationpath = LOUDCOPY( path )
                                target = false

                                break
                            end

						end

					end

				end

			end

        end

        -- find nothing and not already moving - RTB
		if (not target) and (not destination) and (not self.MoveThread) then

            if ScenarioInfo.NavalForceDialog then
                LOG("*AI DEBUG "..aiBrain.Nickname.." NFAI "..self.BuilderName.." "..self.BuilderInstance.." has no goal - RTB ")
            end
            
			return self:SetAIPlan('ReturnToBaseAI',aiBrain)
		end

        -- if we're not underway - have NO target - but a destination and destinationpath
        if (not self.MoveThread) and (not target) and destination and destinationpath then

            -- Issue Dive Order to ALL SERAPHIM Submersible Units -- that are not already submerged
            for _,v in GetPlatoonUnits(self) do
			
                if v.Dead or v.CacheLayer == 'Sub' then
                    continue
                end

                if LOUDENTITY( categories.SERAPHIM * categories.SUBMERSIBLE, v ) then
                    IssueDive( {v} )
                end
            end

            -- use the destinationpath to start a movement thread to the destination
            if PlatoonExists( aiBrain, self )  then

                if ScenarioInfo.NavalForceDialog then
                    LOG("*AI DEBUG "..aiBrain.Nickname.." NFAI "..self.BuilderName.." "..self.BuilderInstance.." begins path to "..repr(destination).." using path "..repr(destinationpath))
                end
			
                self:Stop()

                self.MoveThread = self:ForkThread( self.MovePlatoon, destinationpath, PlatoonFormation, bAggroMove, 28 )

                WaitTicks(30)
            end
            
        end

		-- if we're moving - watch progress towards destination
		if PlatoonExists( aiBrain, self ) and self.MoveThread then

			-- if we're not moving  --
			if (not self.WaypointCallback) then
			
				if self.MoveThread then
					self:KillMoveThread()
				end 

                if ScenarioInfo.NavalForceDialog then
                    LOG("*AI DEBUG "..aiBrain.Nickname.." NFAI "..self.BuilderName.." "..self.BuilderInstance.." Stops moving" )
                end

				self:Stop()

                if PlatoonFormation != 'None' then
                    self:SetPlatoonFormationOverride(PlatoonFormation)
                end
				
				destination = false
				destinationpath = false

				-- Build in movement delay if platoon has carriers and air units nearby
				-- Account for the surfacing and diving of Atlantis or other submersible air carriers
				waitneeded = false

				-- bring submersibles to the surface if there are friendly air units
				for k,v in GetPlatoonUnits(self) do
					
					if not v.Dead and LOUDENTITY ( categories.AIRSTAGINGPLATFORM, v) then

						if GetOwnUnitsAroundPoint( aiBrain, categories.AIR * categories.MOBILE - categories.TRANSPORTFOCUS, GetPosition(v), 32) then
							
							waitneeded = true

							if (not v.Dead) and v.CacheLayer == 'Sub' then
								IssueDive( {v} )
							end
						end
					end
				end

				-- if friendly air units in area -- wait 30 seconds -- then submerge them
				if waitneeded then

                    if ScenarioInfo.NavalForceDialog then
                        LOG("*AI DEBUG "..aiBrain.Nickname.." NFAI "..self.BuilderName.." "..self.BuilderInstance.." on waitneeded")
                    end
					
					WaitTicks(300)
					
					waitneeded = false

					if PlatoonExists( aiBrain, self ) then
					
						for k,v in GetPlatoonUnits(self) do

							if not v.Dead and LOUDENTITY( categories.AIRSTAGINGPLATFORM * categories.SUBMERSIBLE, v) then
								IssueDive( {v} )	-- submerge Atlantis
							end
						end
					end
				end

				target = false
			else

                if ScenarioInfo.NavalForceDialog then
                    LOG("*AI DEBUG "..aiBrain.Nickname.." NFAI "..self.BuilderName.." "..self.BuilderInstance.." still moving" )
                end
                
                PrevPlatPos = LOUDCOPY(platPos)

				WaitTicks(41)
			end

        end

		-- while there is a target - loop here -- 
		while target and PlatoonExists(aiBrain, self) do

            if ScenarioInfo.NavalForceDialog then
                LOG("*AI DEBUG "..aiBrain.Nickname.." NFAI "..self.BuilderName.." "..self.BuilderInstance.." in combat")  
            end

            platPos = GetPlatoonPosition(self) or false

			updatedtargetposition = GetPosition(target) or false

            if platPos then
            
                if ScenarioInfo.NavalForceDialog then
                    LOG("*AI DEBUG "..aiBrain.Nickname.." NFAI "..self.BuilderName.." "..self.BuilderInstance.." target range to search position "..repr(SearchPosition).." is "..repr(VDist3( updatedtargetposition, SearchPosition )))
                end
            
                -- if the target is gone or beyond the SearchRadius
                if (not updatedtargetposition) or VDist3( updatedtargetposition, SearchPosition ) > SearchRadius then
				
                    if updatedtargetposition and VDist3( updatedtargetposition, SearchPosition ) > SearchRadius then

                        if ScenarioInfo.NavalForceDialog then
                            LOG("*AI DEBUG "..aiBrain.Nickname.." NFAI "..self.BuilderName.." "..self.BuilderInstance.." target is beyond radius "..repr(SearchRadius))
                        end
                    end
    
                    target = false

                end

                if target and (not target.Dead) and updatedtargetposition and updatedtargetposition != targetposition then
                
                    AttackUnits = GetSquadUnits( self, 'Attack' )
			
                    if AttackUnits[1] then

                        if ScenarioInfo.NavalForceDialog then
                            LOG("*AI DEBUG "..aiBrain.Nickname.." NFAI "..self.BuilderName.." "..self.BuilderInstance.." targets "..repr(target.EntityID).." "..repr(target:GetBlueprint().Description) )
                        end

                        IssueStop( AttackUnits )
                        IssueAggressiveMove( AttackUnits, updatedtargetposition )

                        ArtyUnits = GetSquadUnits( self, 'Artillery' )

                        if ArtyUnits[1] then

                            IssueStop( ArtyUnits )                            

                            -- if we can attack the target - do so 
                            if self:CanAttackTarget('Artillery', target) then

                                IssueAttack( ArtyUnits, target )

                            -- if not, close the distance between the two squads, to minimize drift in the overall platoon position
                            else

                                local AttackPosition = self:GetSquadPosition( 'Attack' )
                                local ArtyPosition = self:GetSquadPosition( 'Artillery' )

                                local moveposition = { 0, 0, 0 }

                                moveposition[1] = LOUDFLOOR( LOUDLERP( 1, ArtyPosition[1], AttackPosition[1] ))
                                moveposition[3] = LOUDFLOOR( LOUDLERP( 1, ArtyPosition[3], AttackPosition[3] ))

                                IssueFormMove( ArtyUnits, moveposition, 'AttackFormation', GetDirectionInDegrees( ArtyPosition, moveposition) )

                            end
                        end
    
                        targetposition = LOUDCOPY(updatedtargetposition)

                    else

                        if ScenarioInfo.NavalForceDialog then
                            LOG("*AI DEBUG "..aiBrain.Nickname.." NFAI "..self.BuilderName.." "..self.BuilderInstance.." no attack units left - fight over")
                        end
					
                        if self.MoveThread then
                            self:KillMoveThread()
                        end
                        
                        target = false
					
                        break
                    end

                end
                
            end
			
			if (not target) or target.Dead then

                if ScenarioInfo.NavalForceDialog then
                    LOG("*AI DEBUG "..aiBrain.Nickname.." NFAI "..self.BuilderName.." "..self.BuilderInstance.." ends combat - moving back to "..repr(SearchPosition).." PrevPlatPos is "..repr(PrevPlatPos))
                end
                
                StopAttack(self)
                
                target = false
                
                self.UsingTransport = false     -- allow the platoon to merge and respond to Distress Calls

				IssueStop(self)

                self.MoveThread = self:ForkThread( self.MovePlatoon, { SearchPosition }, PlatoonFormation, bAggroMove, 28 )

				break
			end

			WaitTicks(41)

		end

		-- check mission timer for RTB
		if LOUDFLOOR(LOUDTIME()) > EndMissionTime then

            if ScenarioInfo.NavalForceDialog then
                LOG("*AI DEBUG "..aiBrain.Nickname.." NFAI "..self.BuilderName.." "..self.BuilderInstance.." Mission Time expires")
            end

			return self:SetAIPlan('ReturnToBaseAI',aiBrain)
		end
		
		-- if there is a mergelimit (we allow merging platoons) and we're not underway --
        if PlatoonExists( aiBrain, self ) and MergeLimit and (not self.MoveThread) then

            if ScenarioInfo.NavalForceDialog then
                LOG("*AI DEBUG "..aiBrain.Nickname.." NFAI "..self.BuilderName.." "..self.BuilderInstance.." checking for merge " )
            end
			
			-- otherwise try and grab other smaller platoons --
            if MergeWithNearbyPlatoons( self, aiBrain, 'NavalForceAILOUD', 75, false, MergeLimit) then

                platoonUnits = GetPlatoonUnits(self)
				
                local numberOfUnitsInPlatoon = LOUDGETN(platoonUnits)

				-- if we have a change in the number of units --
                if (oldNumberOfUnitsInPlatoon != numberOfUnitsInPlatoon) then
					
					if self.MoveThread then
						self:KillMoveThread()
					end 

                    StopAttack(self)

					-- reform the platoon --
                    if PlatoonFormation != 'None' then
                        self:SetPlatoonFormationOverride(PlatoonFormation)
                    end
                end

                oldNumberOfUnitsInPlatoon = numberOfUnitsInPlatoon

                OriginalThreat = CalculatePlatoonThreat( self, 'Overall', categories.ALLUNITS)
            end

        end
        
        WaitTicks(3)

    end

end

-- NAVAL BOMBARDMENT --
function NavalBombardAILOUD( self, aiBrain )

    local NavalBombardAIDialog = ScenarioInfo.NavalBombardDialog or false

    local CalculatePlatoonThreat    = CalculatePlatoonThreat
	local GetHiPriTargetList        = GetHiPriTargetList
	local GetNumUnitsAroundPoint    = GetNumUnitsAroundPoint
    local GetPlatoonPosition        = GetPlatoonPosition
    local GetPlatoonUnits           = GetPlatoonUnits    
	local GetUnitsAroundPoint       = GetUnitsAroundPoint
	local LOUDGETN                  = LOUDGETN
	local LOUDPARSE                 = ParseEntityCategory
	local VDist3                    = VDist3    

	if not GetPlatoonPosition(self) then
        return self:SetAIPlan('ReturnToBaseAI',aiBrain)
    end

    local armyIndex = aiBrain.ArmyIndex

	local AIGetMarkerLocations      = AIGetMarkerLocations
	local FindTargetInRange         = import('/lua/ai/aiattackutilities.lua').FindTargetInRange
    local GetDirection              = GetDirectionInDegrees

    local data = self.PlatoonData

	local bAggroMove        = true
    local BombardRange      = data.BombardRange or 100      -- sets range required to perform this mission
	local MergeLimit        = data.MergeLimit or 60
    local MissionRadius     = self.MissionRadius or 1500
    local MissionStartTime  = self.CreationTime	    		-- when the mission began (creation of the platoon)
	local MissionTime       = data.MissionTime or 1200		-- how long platoon will operate before RTB
    local SearchRadius      = data.SearchRadius or 150
	local PlatoonFormation  = data.UseFormation or 'GrowthFormation'

    local categoryList = {}
    local count = 0

    if data.PrioritizedCategories then
	
        for _,v in data.PrioritizedCategories do
            count = count + 1
            categoryList[count] = LOUDPARSE( v )
        end
    else
		count = count + 1
        categoryList[count] = categories.NAVAL
	end

    self:SetPrioritizedTargetList( 'Attack', categoryList )

	local platoonUnits              = GetPlatoonUnits(self)
	local oldNumberOfUnitsInPlatoon = LOUDGETN(platoonUnits)
	local OriginalThreat            = CalculatePlatoonThreat( self,'Overall', categories.ALLUNITS)

	-- get all the possible naval markers that we want the bombardment platoon to operate from
	local navalmarkers = ScenarioInfo['Naval Area'] or AIGetMarkerLocations('Naval Area')

	-- include naval links
	local linkmarkers = ScenarioInfo['Naval Link'] or AIGetMarkerLocations('Naval Link')

	local navalmarkers = table.cat( navalmarkers, linkmarkers )

	-- and water nodes
	local nodemarkers = ScenarioInfo['Water Path Node'] or AIGetMarkerLocations('Water Path Node')

	local navalmarkers = table.cat( navalmarkers, nodemarkers )

	-- make a copy of ALL the above markers
	local navalAreas = LOUDCOPY(navalmarkers)

	navalmarkers = nil
	linkmarkers = nil
	nodemarkers = nil

	local EndMissionTime = LOUDFLOOR(LOUDTIME()) + MissionTime

	local destination, path, target, targetposition
	local mythreat, targetlist, targetvalue, maxRange
	local sthreat, ethreat, ecovalue, milvalue, value
	local path, reason, pathlength, distancefactor
	local direction, previousbombardmentposition, updatedtargetposition

	local function StopAttack( self )

		self:Stop()
		
		destination = false
		destinationpath = false
		
		target = false
		targetposition = false

	end
	
	-- force the plan name 
	self.PlanName = 'NavalBombardAILOUD'	
	
    if NavalBombardAIDialog then
        LOG("*AI DEBUG "..aiBrain.Nickname.." NavalBombardAI "..self.BuilderName.." "..self.BuilderInstance.." begins with "..oldNumberOfUnitsInPlatoon.." units")	
    end

    local targettypes = {}

    targettypes["Economy"]          = true
    targettypes["Commander"]        = true
    targettypes["Land"]             = true
    targettypes["Naval"]            = true
    targettypes["StructuresNotMex"] = true
    
    while PlatoonExists(aiBrain, self) do
    
        local NavalBombardAIDialog = ScenarioInfo.NavalBombardDialog or false

		target = false
        updatedtargetposition = false		

		mythreat = CalculatePlatoonThreat( self, 'Overall', categories.ALLUNITS)

		maxRange = import('/lua/ai/aiattackutilities.lua').GetNavalPlatoonMaxRange(aiBrain, self)
		
		-- platoon no longer qualifies for bombardment
		if maxRange < BombardRange then
        
            if ScenarioInfo.NavalBombardDialog then
                LOG("*AI DEBUG "..aiBrain.Nickname.." NBFAI "..self.BuilderName.." "..self.BuilderInstance.." no longer bombardment capable")
            end
            
			return self:SetAIPlan('ReturnToBaseAI',aiBrain)		
		end
		
		if not self.MoveThread then
        
            if ScenarioInfo.NavalBombardDialog then
                LOG("*AI DEBUG "..aiBrain.Nickname.." NavalBombardAI "..self.BuilderName.." "..self.BuilderInstance.." seeking local target at "..maxRange )
            end
            
			target, targetposition = FindTargetInRange( self, aiBrain, 'Artillery', maxRange, categoryList, true )

		end

		-- if target -- issue attack orders -- no need to move
        if target and not target.Dead then
		
			previousbombardmentposition = false

            if ScenarioInfo.NavalBombardDialog then
                LOG("*AI DEBUG "..aiBrain.Nickname.." NBFAI "..self.BuilderName.." "..self.BuilderInstance.." finds target "..repr( target:GetBlueprint().Description ).." in bombard range")
            end
            
            local ARTILLERY = GetSquadUnits( self,'Artillery' )
            local GUARDS = GetSquadUnits( self, 'Guard' )
            
			-- order the artillery to attack the target
            for k, unit in ARTILLERY do 
                IssueAggressiveMove( {unit}, RandomLocation(targetposition[1],targetposition[3], BombardRange/2) )
            end
            
            WaitTicks(11)

			-- Make sure any units in platoon which are guards are actually guarding
			-- loop thru all the artillery units and clear the guarded marks
			for _,v in ARTILLERY do
				
				if v and not v.Dead then

					v.guardset = nil
					
					-- if there are Guards - and unit is not guarded --
					if GUARDS[1] and not v.guardset then
						
						-- loop thru all guards and issue guard orders
						for _,m in GUARDS do
							
							if m and not m.Dead then
							
								if not m.guardset then
							
									IssueGuard( {m}, v )
									
									m.guardset = true
									v.guardset = true
									
									break
									
								end
								
							end
							
						end
						
					end
                    
                    local SUPPORTS = GetSquadUnits( self, 'Support' )
					
					-- if there are support units - and unit is not guarded --
					if SUPPORTS[1] and not v.guardset then
						
						-- loop thru all guards and issue guard orders
						for _,m in SUPPORTS do
							
							if m and not m.Dead then
							
								if not m.guardset then
							
									IssueGuard( {m}, v )
									
									m.guardset = true
									v.guardset = true
									
									break
								end
							end
						end
					end					
				end
			end
			
			-- at this point all the artillery units should be guarded --
			-- so we'll now clear all the guarding marks
			for _,v in self:GetPlatoonUnits() do
			
				v.guardset = nil
			end
			
        else
		
			target = false
		end

		-- if no target and no movement orders -- use HiPri list
		-- issue movement orders -- if list is empty RTB instead --
        if (not target) and not self.MoveThread then
        
            if NavalBombardAIDialog then
                LOG("*AI DEBUG "..aiBrain.Nickname.." NavalBombardAI "..self.BuilderName.." "..self.BuilderInstance.." seeks HiPri Target location from "..repr(GetPlatoonPosition(self)) )
            end
            
			-- get HiPri list
			targetlist = GetHiPriTargetList( aiBrain, GetPlatoonPosition(self), targettypes, MissionRadius, true )

			targetvalue = 0

            mythreat = CalculatePlatoonThreat( self,'Overall', categories.ALLUNITS)

            if NavalBombardAIDialog then
                LOG("*AI DEBUG "..aiBrain.Nickname.." NavalBombardAI "..repr(self.BuilderName).." "..repr(self.BuilderInstance).." mythreat is "..math.floor(mythreat).." here is the sorted targetlist "..repr(targetlist))
            end

			-- get a HiPri target from the targetlist
			for _,Target in targetlist do
			
				if PlatoonExists( aiBrain, self ) then

					-- sort the markers to see if any are within range of the Target.Position
					LOUDSORT( navalAreas, function(a,b) local VDist3 = VDist3 return VDist3(a.Position, Target.Position) < VDist3(b.Position, Target.Position) end )
					
					if LOUDEQUAL( navalAreas[1].Position, previousbombardmentposition) then
						continue	-- dont pick the same location as last time
					end
					
					if VDist3( navalAreas[1].Position, Target.Position ) > maxRange then
						continue    -- the closest one is outside the range - so onto next HiPri
					end					

					-- get basic threat types at position
					sthreat = Target.Threats.Sur + Target.Threats.Sub
					ethreat = Target.Threats.Eco

					if sthreat < 1 then
						sthreat = 1
					end

					if ethreat < 1 then
						ethreat = 1
					end

					ecovalue = LOUDMAX(1, ethreat/mythreat)

					if ecovalue > 1.5 then
						ecovalue = LOUDMIN( 3, LOUDSQUARE(ecovalue))
					end

					-- target value is relative to the platoons strength vs. the targets strength
					-- cap the value at 3 to limit chasing worthless targets
					-- anything stronger than us gets valued even lower to avoid going after targets too strong
					milvalue =  (mythreat/sthreat) 

					if milvalue > 2 then 
					
						milvalue = 2.0

					-- for BOMBARDMENT we're not much concerned with enemy surface value
					-- so we'll accept relatively low values as nominal
					elseif milvalue < 0.5 then
					
						milvalue = .5
						
					end

					value = ecovalue * milvalue

					-- ignore targets we are still too weak against
					if value < 1.0 then

                        if NavalBombardAIDialog then
                            LOG("*AI DEBUG "..aiBrain.Nickname.." NavalBombardAI "..repr(self.BuilderName).." "..repr(self.BuilderInstance).." ignores "..repr(Target.Type).." target value is "..value.." - mil "..milvalue.." - eco "..ecovalue)
                        end
  
						continue
					end

					-- naval platoons must be able to get to the closest bombardment position
					path, reason, pathlength = self.PlatoonGenerateSafePathToLOUD( aiBrain, self, self.MovementLayer, GetPlatoonPosition(self), navalAreas[1].Position, mythreat, 250 )

					-- if we have a path to the bombardment position and its value is highest one so far then set destination
					-- and store the targetvalue for comparison 
					if path and PlatoonExists( aiBrain, self ) then
                    
                        distancefactor = pathlength/(ScenarioInfo.IMAPSize*.5)
                        
                        distancefactor = 1 / (LOUDLOG(distancefactor))
                        
                        distancefactor = distancefactor * ((SearchRadius*5) / pathlength )

                        if NavalBombardAIDialog then
                            LOG("*AI DEBUG "..aiBrain.Nickname.." NavalBombardAI "..repr(self.BuilderName).." "..repr(self.BuilderInstance).." evaluates "..repr(Target.Type).." pathdistance ("..math.floor(pathlength)..") - factor "..distancefactor.." - mil "..milvalue.." - eco "..ecovalue.." result value "..value * distancefactor )
                        end
 					
						-- store the destination of the most valuable target
						if (value * distancefactor) > targetvalue then
						
							targetvalue = (value * distancefactor)
							destination = LOUDCOPY( navalAreas[1].Position )
							destinationpath = LOUDCOPY( path )

						end
					end
				
					WaitTicks(1) -- check next HiPri target --
					
				else

                    if NavalBombardAIDialog then
                        LOG("*AI DEBUG "..aiBrain.Nickname.." NavalBombardAI "..repr(self.BuilderName).." "..repr(self.BuilderInstance).." ignores target type "..repr(Target.Type).." at "..repr(Target.Position).." no path - "..reason)
                    end
				
					destination = false
                    destinationpath = false
					break
					
				end
				
			end

			-- if no HiPri target then RTB -
			if PlatoonExists( aiBrain,self) and ((not destination) or table.equal(destination, previousbombardmentposition)) then
			
                if NavalBombardAIDialog then
                    LOG("*AI DEBUG "..aiBrain.Nickname.." NavalBombardAI "..self.BuilderName.." "..self.BuilderInstance.." no bombardment position - RTB ")
				end
                
				return self:SetAIPlan('ReturnToBaseAI',aiBrain)
				
			else
			
                if NavalBombardAIDialog then
                    LOG("*AI DEBUG "..aiBrain.Nickname.." NavalBombardAI "..self.BuilderName.." "..self.BuilderInstance.." selects HiPri bombardment position at "..repr(destination).." path is "..repr(destinationpath) )
				end
                
				-- store the selected bombardment position
				previousbombardmentposition = LOUDCOPY(destination)
				
			end

			-- Issue Dive Order to ALL SERAPHIM Submersible Units -- that are not already submerged
			for _,v in GetPlatoonUnits(self) do
			
				if v.Dead or v.CacheLayer == 'Sub' then
					continue
				end

				if LOUDENTITY( categories.SERAPHIM * categories.SUBMERSIBLE, v ) then
				
					IssueDive( {v} )
					
				end
				
			end

			-- we should have a path to a bombardment position at this point --
			-- so issue movement orders --
			if PlatoonExists( aiBrain, self ) and (destination and destinationpath) then
			
				self:Stop()
			
				self.MoveThread = self:ForkThread( self.MovePlatoon, destinationpath, PlatoonFormation, false, 20 )
				
				-- this pause is here for two reasons -
				-- first: to allow the platoon to get moving
				-- second: to allow the WayPointCallback to be set up
				WaitTicks(30)
				
			else
			
                if NavalBombardAIDialog then
                    LOG("*AI DEBUG "..aiBrain.Nickname.." NavalBombardAI "..self.BuilderName.." "..self.BuilderInstance.." has no path")
				end
                
				target = false
				
			end
			
		end

		-- if moving then watch progress towards destination
		if self.MoveThread then

			-- if we're not moving or we're close to destination --
			if (not self.WaypointCallback) or (not destination) then
			
				if self.MoveThread then

					self:KillMoveThread()
					
				end 
			
				self:Stop()

				self:SetPlatoonFormationOverride(PlatoonFormation)
				
				destination = false
				destinationpath = false

			end
			
        end

		-- loop here until target dies or moves out of range -- 
		-- wait 3 seconds between target checks --

		while target and (not target.Dead) and PlatoonExists(aiBrain, self) do
            
            if not updatedtargetposition then
                
                if NavalBombardAIDialog then
                    LOG("*AI DEBUG "..aiBrain.Nickname.." NavalBombardAI "..self.BuilderName.." "..self.BuilderInstance.." BEGINS engaging target "..repr( target:GetBlueprint().Description ).." in bombard range" )
                end
            end

			updatedtargetposition = LOUDCOPY(GetPosition(target)) or false

			if not updatedtargetposition or VDist3( updatedtargetposition, self:GetSquadPosition( 'Artillery' ) ) > maxRange then

				-- if the target is still alive but it's moved out of range - let me know
                if not updatedtargetposition then
                
                    if NavalBombardAIDialog then
                        LOG("*AI DEBUG "..aiBrain.Nickname.." NavalBombardAI "..self.BuilderName.." "..self.BuilderInstance.." target is Dead "..repr(target.Dead) )
                    end
                else
                    if NavalBombardAIDialog then
                        LOG("*AI DEBUG "..aiBrain.Nickname.." NavalBombardAI "..self.BuilderName.." "..self.BuilderInstance.." target is at "..VDist3( updatedtargetposition, self:GetSquadPosition( 'Artillery' ) ).." beyond radius "..repr(maxRange))
                    end
                end

				StopAttack(self)
				
				target = false
                
                updatedtargetposition = false
				
			end

			mythreat = CalculatePlatoonThreat( self, 'Overall', categories.ALLUNITS)

			if PlatoonExists( aiBrain, self) and mythreat <= (OriginalThreat * .40) then
			
				if self.MergeIntoNearbyPlatoons( self, aiBrain, 'BombardForceAI', 100, false) then

                    if NavalBombardAIDialog then
                        LOG("*AI DEBUG "..aiBrain.Nickname.." NavalBombardAI "..self.BuilderName.." "..self.BuilderInstance.." completes MERGEINTO - disbanding ")
                    end

                else

                    if NavalBombardAIDialog then
                        LOG("*AI DEBUG "..aiBrain.Nickname.." NavalBombardAI "..self.BuilderName.." "..self.BuilderInstance.." fatigued - in RTB ")				
                    end

                end
				
                return self:SetAIPlan('ReturnToBaseAI',aiBrain)
			end

			WaitTicks(31)

            -- check mission timer for RTB
            if LOUDFLOOR(LOUDTIME()) > EndMissionTime then
            
                target = false
           
                break

            end
			
            if NavalBombardAIDialog then
                LOG("*AI DEBUG "..aiBrain.Nickname.." NavalBombardAI "..self.BuilderName.." "..self.BuilderInstance.." CONTINUES engaging target - dead "..repr(target.Dead).." "..repr( target:GetBlueprint().Description ).." in bombard range "..maxRange.." at "..VDist3( updatedtargetposition, GetPlatoonPosition(self)) )
            end
		end

		-- check mission timer for RTB
		if LOUDFLOOR(LOUDTIME()) > EndMissionTime then
		
            if NavalBombardAIDialog then
                LOG("*AI DEBUG "..aiBrain.Nickname.." NavalBombardAI "..self.BuilderName.." "..self.BuilderInstance.." Mission Timer expires")
			end
            
			return self:SetAIPlan('ReturnToBaseAI',aiBrain)
			
		end
		
		-- if there is a mergelimit (we allow merging platoons)
        if PlatoonExists( aiBrain, self) and MergeLimit then
		
			-- if weak try and join nearby platoon --
			if mythreat <= (OriginalThreat * .40) then
		
				if self.MergeIntoNearbyPlatoons( self, aiBrain, 'BombardForceAI', 100, false) then

                    if NavalBombardAIDialog then
                        LOG("*AI DEBUG "..aiBrain.Nickname.." NavalBombardAI "..self.BuilderName.." "..self.BuilderInstance.." completes MERGEINTO - disbanding ")
                    end

                else

                    if NavalBombardAIDialog then
                        LOG("*AI DEBUG "..aiBrain.Nickname.." NavalBombardAI "..self.BuilderName.." "..self.BuilderInstance.." fatigued - in RTB ")
                    end

                end
                
				-- leftovers will RTB
				return self:SetAIPlan('ReturnToBaseAI',aiBrain)
			
			end
			
			-- otherwise try and grab other smaller platoons --
            if self.MergeWithNearbyPlatoons( self, aiBrain, 'NavalBombardAILOUD', 100, false, MergeLimit) then

                platoonUnits = GetPlatoonUnits(self)
				
                local numberOfUnitsInPlatoon = LOUDGETN(platoonUnits)

				-- if we have a change in the number of units --
                if (oldNumberOfUnitsInPlatoon != numberOfUnitsInPlatoon) then
					
					if self.MoveThread then
					
						self:KillMoveThread()
						
					end 

                    StopAttack(self)

                    self.MoveThread = self:ForkThread( self.MovePlatoon, GetPlatoonPosition(self), PlatoonFormation, false, 12 )
                end

                oldNumberOfUnitsInPlatoon = numberOfUnitsInPlatoon

                OriginalThreat = CalculatePlatoonThreat( self, 'Overall', categories.ALLUNITS)

                if NavalBombardAIDialog then
                    LOG("*AI DEBUG "..aiBrain.Nickname.." NavalBombardAI "..self.BuilderName.." "..self.BuilderInstance.." completes merge to "..oldNumberOfUnitsInPlatoon.." units")
                end
                
                target = false
            end
			
        end

		-- wait 2 seconds
		WaitTicks(21)
    end
end


-- This function will transfer engineers to a base which does not have one of that specific type
-- and has no means of making one -- weights towards counted and primary bases first
-- primary bases are allowed to exceed the engineer cap by 1
function EngineerTransferAI( self, aiBrain )

    local EngineerTransferDialog = false

	local eng = GetPlatoonUnits(self)[1]
	
	local possibles = {}
	local counter = 0
	
	local Eng_Cat = self.PlatoonData.TransferCategory
	local Eng_Type = self.PlatoonData.TransferType
    
    local BM = aiBrain.BuilderManagers
    
    local engineerManager, factoryManager, numUnits, structurecount, factorycount, capcheck

	-- scan all bases and transfer if they dont have their maximum already
	for k,v in BM do
	
		-- make a list of possible bases
		-- base must have an ACTIVE EM -- ignore MAIN & the base this engineer is presently assigned to
		if v.EngineerManager.Active and (k != 'MAIN' and k != eng.LocationType) then
		
			engineerManager = v.EngineerManager
			factoryManager = v.FactoryManager
            
			numUnits = EntityCategoryCount( Eng_Cat, engineerManager.EngineerList )
            
			structurecount = LOUDGETN(aiBrain:GetUnitsAroundPoint( categories.STRUCTURE - categories.WALL, v.Position, 40, 'Ally'))
			factorycount = LOUDGETN(factoryManager.FactoryList)
			
			capCheck = v.BaseSettings.EngineerCount[Eng_Type] or 1
            
            -- use maximum amount but never let it go below the base value due to AI multiplier being less than 1
            capCheck = LOUDMAX(capCheck, LOUDFLOOR(capCheck * (aiBrain.CheatValue) * aiBrain.CheatValue))
			
			if aiBrain.StartingUnitCap >= 1000 then
			
				capCheck = capCheck + 1
				
			end
            
            if v.PrimaryLandBase or v.PrimarySeaAttackBase then
            
                capCheck = capCheck + 1
                
            end
			
			-- if base has less than maximum allowed engineers and there are structures at that position
			-- base must have no ability to make the engineers itself (no factory)
			if numUnits < capCheck and structurecount > 0 then
			
				if factorycount < 4 or Eng_Type == 'SCU' then
				
					counter = counter + 1
					possibles[counter] = k
					
					-- if its a counted base add it a second time
					if v.CountedBase then
					
						counter = counter + 1
						possibles[counter] = k

                        -- SCU attracted to counted bases more
                        if Eng_Type == 'SCU' then

                            counter = counter + 1                        
                            possibles[counter] = k

                        end
						
					end
					
					-- if its a primary base add it twice more again
					if v.PrimaryLandAttackBase or v.PrimarySeaAttackBase then

						counter = counter + 1					
						possibles[counter] = k

                        -- SCU not as attracted to Primary compensated by
                        -- extra addition IF it has production (CountedBase)
                        if not Eng_Type == 'SCU' then

                            counter = counter + 1
                            possibles[counter] = k

                        end
					end
				end
			end
		end
	end
	
	if counter > 0 then
	
		-- remove engy from his existing base - destroy all existing engy callbacks
		aiBrain.BuilderManagers[eng.LocationType].EngineerManager:RemoveEngineerUnit(eng)
		
		local newbase = possibles[ Random(1,counter) ]
        
        if EngineerTransferDialog then
            LOG("*AI DEBUG "..aiBrain.Nickname.." ENG_TRANSFER "..Eng_Type.." Transfers From "..repr(eng.LocationType).." To "..repr(newbase).." on tick "..GetGameTick() )
        end
		
		-- add him to the selected base - but dont send him to assign task -- setup new engy callbacks
		aiBrain.BuilderManagers[newbase].EngineerManager:AddEngineerUnit( eng, false )
		
		-- force platoon to use the new base as the RTBLocation
		-- if you don't do this then the engineer will just RTB to his original base
		self.RTBLocation = newbase
		
	else
	
        if EngineerTransferDialog then
            LOG("*AI DEBUG "..aiBrain.Nickname.." ENG_TRANSFER "..Eng_Type.." Transfer FROM "..repr(eng.LocationType).." FAILS")
        end
        
	end
	
	self:SetAIPlan('ReturnToBaseAI',aiBrain)
	
end


-- uses the Eye of Rhianne as an intelligence tools
function EyeBehavior( unit, aiBrain )

	local IsIdleState = IsIdleState
    local MustScoutList = aiBrain.IL.MustScout
	
	local function AIGetMustScoutArea()
	
		for k,v in MustScoutList do
		
			if not v.TaggedBy or v.TaggedBy.Dead then
			
				return v, k
				
			end
			
		end
		
		return false, nil
		
	end	

    local targetArea, mustScoutArea, mustScoutIndex
    
    while not unit.Dead do
    
        WaitSeconds(30)
        
        if (GetEconomyTrend( aiBrain, 'ENERGY' ) *10) > 100 and GetEconomyStored( aiBrain, 'ENERGY' ) > 7000 and IsIdleState(unit) then
		
            targetArea = false

            mustScoutArea, mustScoutIndex = AIGetMustScoutArea()
            
            -- 1) If we have any "must scout" (manually added) locations that have not been scouted yet, then scout them
            if mustScoutArea  then
			
				MustScoutList[mustScoutIndex].TaggedBy = unit

                targetArea = mustScoutArea.Position
            end
  
            -- 2) Scout a high priority location    
            if not targetArea and not aiBrain.IL.LastAirScoutHi then
			
				if aiBrain.IL.HiPri[1] then

					targetArea = LOUDCOPY(aiBrain.IL.HiPri[1].Position)
					
					aiBrain.IL.HiPri[1].LastScouted = LOUDFLOOR(LOUDTIME())
					aiBrain.IL.LastAirScoutHi = true

				end
			end

            -- 3) Scout a low priority location               
            if not targetArea then
			
				aiBrain.IL.LastAirScoutHiCount = aiBrain.IL.LastAirScoutHiCount + 1
				
				if aiBrain.IL.LastAirScoutHiCount > 5 then
					aiBrain.IL.LastAirScoutHi = false
					aiBrain.IL.LastAirScoutHiCount = 0
					
				end

				if aiBrain.IL.LowPri[1] then
                
					targetArea = aiBrain.IL.LowPri[1].Position
					aiBrain.IL.LowPri[1].LastScouted = LOUDFLOOR(LOUDTIME())
					
				end
            end
            
            -- Execute the scouting mission
            if targetArea then
				
                -- Ok lets execute the Eye Viz function now
                IssueScript( {unit}, {TaskName = "TargetLocation", Location = targetArea} )
                
				-- when scouting an untagged (must scout) area 
				-- take it off the list of must scout areas
                if mustScoutArea then

					aiBrain.IL.MustScout[mustScoutIndex] = nil
                    
					aiBrain.IL.MustScout = aiBrain:RebuildTable(aiBrain.IL.MustScout)
                    
					mustScoutArea = false
                end
                
            end
            
        end
    end
end

-- uses the Rift Gate to produce elite Sera units
function RiftGateBehavior( unit, aiBrain, manager )

    local BuildUnit = AIBrainMethods.BuildUnit

	local IsIdleState = IsIdleState
	local Random = Random
	
	-- still need one important function here - that is SetRallyPoint
	ForkThread(manager.SetRallyPoint, manager, unit)
	
    local unitlist = { 'bsl0003','bsl0004','bsl0005','bsl0007','bsl0008','bsa0003' }
   
    while not unit.Dead do
	
        WaitTicks(45)
        
        if (GetEconomyTrend(aiBrain,'ENERGY') * 10) > 100 and GetEconomyStored(aiBrain,'ENERGY') > 1500 and IsIdleState(unit) then
        
            BuildUnit( aiBrain, unit, unitlist[ Random(1,6) ], 3 )
        end
    end
end

-- this will fire up the FatBoyThread 
function FatBoyAI( unit, aiBrain )

	if (not unit.Dead) and LOUDENTITY( categories.uel0401, unit ) and not unit.FatBoyThread then
	
		LOG("*AI DEBUG FatBoy Initialization starting")
		
		unit.FatBoyThread = unit:ForkThread( FatBoyThread, aiBrain )
		
	end
	
end	
	
-- this will have FatBoy produce units whenever he is NOT in a platoon (but in the ARMYPOOL platoon) and is idle
function FatBoyThread( fatboy, aiBrain )

	local LOUDGETN = LOUDGETN

	local faction = aiBrain.FactionIndex
	
	local pool = aiBrain.ArmyPool
	local EnergyStorage, MassStorage
	
	LOG("*AI DEBUG FatBoy Thread started")
	
	-- this unitlist is chosen from the units that Fatboy can actually build
	-- I provide it in code here but it could be part of the FATBOY blueprint in the AI section
	local untlist = {'uel0303', 'uel0307', 'uel0304', 'xel0305', 'xel0306', 'delk002', }
	
	while fatboy and (not fatboy.dead) do

		-- while fatboy is NOT in the Army Pool and there is some unit cap available --
		if (not fatboy.PlatoonHandle == pool) and (aiBrain.IgnoreArmyCaps or ( (GetArmyUnitCostTotal(aiBrain.ArmyIndex) / GetArmyUnitCap(aiBrain.ArmyIndex)) < .95) ) then
		
			-- check the current storage levels every 10 seconds
			EnergyStorage = GetEconomyStored( aiBrain, 'ENERGY')
			MassStorage = GetEconomyStored( aiBrain, 'MASS')

			if fatboy:IsIdleState() and (MassStorage >= 200 and EnergyStorage >= 2000) then
			
				local unitbuildtime = 0
			
				-- decide what to build
				local unitToBuild = untlist[Random(1,LOUDGETN(untlist))]
			
				aiBrain:BuildUnit( fatboy, unitToBuild, 1 )
				
				-- loop until we confirm unit is being built
				repeat
				
					WaitTicks(10)
					
					unitbuildtime = unitbuildtime + 2
					
				until fatboy.Dead or fatboy.UnitBeingBuilt or unitbuildtime > 10 
    
				-- loop until idle, in a platoon, or not building
				repeat
				
					WaitTicks(25)
					
				until fatboy.Dead or fatboy:IsIdleState() or fatboy.PlatoonHandle != aiBrain.ArmyPool or (not fatboy.UnitBeingBuilt)
				
			end
			
		end
		
		WaitTicks(100)
		
	end
	
end

-- Carrier Thread -- Here is my attempt to make carriers useful to the AI
-- 	The carrier will produce aircraft thru the use of an ECONOMY EVENT - pay the bill - create the unit above the carrier 
--  the new unit is placed into a platoon that guards the carrier  -- if the carrier gets attached to a platoon those aircraft go with it 
--	The carrier will keep making aircraft until it has 2 Scouts, 16 Fighters & 32 Torpedo bombers
--  If it builds all the above aircraft it will halt until it more are needed
function CarrierThread ( carrier, aiBrain )

	local LOUDGETN = LOUDGETN
	local GetBuildRate = GetBuildRate
	local IsIdleState = IsIdleState

	local ftrlist = { 'uea0303', 'uaa0303', 'ura0303', 'xsa0303' }
	local trplist = { 'uea0204', 'xaa0306', 'ura0204', 'xsa0204' }
	local sctlist = { 'uea0302', 'uaa0302', 'ura0302', 'xsa0302' }
    
	local faction = aiBrain.FactionIndex
	
	carrier.RTB = false
	
	LOG("*AI DEBUG "..aiBrain.Nickname.."CARRIER Thread begins")	
	
	-- a thread to RTB the carrier if it's badly damaged
	local function WatchForDamaged( )
	
		carrier.RTB = false
	
		while (not carrier.dead) and (not carrier.RTB) do
		
			WaitTicks(40)

			if (not carrier.Dead) and (carrier:GetHealthPercent() < .6) and not carrier.RTB then
			
				LOG("*AI DEBUG "..aiBrain.Nickname.." CARRIER issued RTB ")
				
				-- pull the carrier out of its platoon and RTB it
				local workplatoon = MakePlatoon( aiBrain, 'CarrierRTB', 'none')
				
				AssignUnitsToPlatoon( aiBrain, workplatoon, {carrier}, 'Attack', 'none' )
				workplatoon.BuilderName = 'CarrierRTB'
				
				workplatoon:SetAIPlan( 'ReturnToBaseAI', aiBrain )
				
				carrier.RTB = true
				
			end
			
		end
		
	end

    local killedCallback = function( carrier )

		local aiBrain = GetAIBrain(carrier)
		
		LOG("*AI DEBUG "..aiBrain.Nickname.." Carrier OnKilled event callback")
		
		if carrier.SctPlatoon then
		
			LOG("*AI DEBUG "..aiBrain.Nickname.." Carrier had scout platoon")
			
		end
		
		if carrier.TrpPlatoon then
		
			LOG("*AI DEBUG "..aiBrain.Nickname.." Carrier had torpedo platoon")
			
		end
		
		if carrier.FtrPlatoon then
		
			LOG("*AI DEBUG "..aiBrain.Nickname.." carrier had fighter platoon")
			
		end

    end
	
	LOUDINSERT(carrier.EventCallbacks.OnKilled, killedCallback)
	
    local platoondestroyedCallback = function( brain, platoon )
		
		LOG("*AI DEBUG "..brain.Nickname.." CARRIER - Air platoon destroyed "..repr(platoon.BuilderName) )

		if platoon.BuilderName =='CarrierScouts' then
			
			local parent = platoon.Parent
			
			parent.SctPlatoon = nil
			
			LOG("*AI DEBUG "..aiBrain.Nickname.." Carrier "..repr(parent.EntityID).." clears Scout Platoon")
			
		elseif platoon.BuilderName == 'CarrierFighters' then
		
			local parent = platoon.Parent
			
			parent.FtrPlatoon = nil
			
			LOG("*AI DEBUG "..aiBrain.Nickname.." Carrier "..repr(parent.EntityID).." clears Fighter Platoon")			
			
		elseif platoon.BuilderName == 'CarrierTorpedoBombers' then
		
			local parent = platoon.Parent
			
			parent.TrpPlatoon = nil
			
			LOG("*AI DEBUG "..aiBrain.Nickname.." Carrier "..repr(parent.EntityID).." clears Torpedo Platoon")
			
		end

    end
	
	
	-- start up the watch for damage thread 
	carrier:ForkThread( WatchForDamaged )
	
	local building, unitBeingBuilt, unitToBuild
	local unitbp, massneeded,energyneeded,timeneeded
	local cpos
	
	while not carrier.Dead do
	
		-- check the current storage levels and unit cap - and decide what unit to build
		-- here's the beauty of this - the carrier can ALWAYS be building - moving or not - platoon or not
		if (aiBrain.IgnoreArmyCaps or ((GetArmyUnitCostTotal(aiBrain.ArmyIndex) / GetArmyUnitCap(aiBrain.ArmyIndex)) < .95) )	
			and (GetEconomyStored( aiBrain, 'MASS') >= 200 and GetEconomyStored( aiBrain, 'ENERGY') >= 2500) then
			
			building = false
			
			if (not carrier.SctPlatoon) then
				
				building = 'scout'
				unitToBuild = sctlist[faction]
				
			end
			
			if (not building) and (not carrier.FtrPlatoon) then
			
				building = 'fighter'
				unitToBuild = ftrlist[faction]
				
			end

			if (not building) and (not carrier.TrpPlatoon) then
				
				building = 'torpedo'
				unitToBuild = trplist[faction]

			end

			unitBeingBuilt = false
			
			-- if all 3 platoons are active 
			if not building then
			
				-- decide what to build -- scouts first - then fighters -- then torps
				if LOUDGETN(carrier.SctPlatoon:GetPlatoonUnits()) < 2 then
				
					building = 'scout'
					unitToBuild = sctlist[faction]
					
				end
				
				if (not building) and LOUDGETN(carrier.FtrPlatoon:GetPlatoonUnits()) < 16 then
				
					building = 'fighter'
					unitToBuild = ftrlist[faction]
					
				end
				
				if (not building) and LOUDGETN(carrier.TrpPlatoon:GetPlatoonUnits()) < 32 then
				
					building = 'torpedo'
					unitToBuild = trplist[faction]
					
				end
				
			end
			
			-- if we're building something - build it - put into its platoon and then issue guard order
			if building and not carrier.Dead then
			
				-- we'll need the unit blueprint economy section for mass, energy and build time
				unitbp = aiBrain:GetUnitBlueprint(unitToBuild).Economy
				
				massneeded = unitbp.BuildCostMass
				energyneeded = unitbp.BuildCostEnergy
				timeneeded = unitbp.BuildTime
				
				LOG("*AI DEBUG "..aiBrain.Nickname.." CARRIER building "..repr(building))
				
				carrier.UnitDrain = CreateEconomyEvent( carrier, energyneeded, massneeded, (timeneeded/GetBuildRate(carrier)), carrier:SetWorkProgress(0) )
			
				-- WAITFOR the eco event to complete
				WaitFor( carrier.UnitDrain )
				
				if not carrier.Dead then
				
					-- create the unit just above the carrier
					cpos = GetPosition(carrier)
					unitBeingBuilt = CreateUnitHPR( unitToBuild, aiBrain.Name, cpos[1], cpos[2] + 5, cpos[3], 0, 0, 0 )
				
					-- we built something - put it into a platoon
					if building == 'fighter' then
				
						if not carrier.FtrPlatoon or not PlatoonExists(aiBrain,carrier.FtrPlatoon) then
						
							local FtrPlatoon = MakePlatoon( aiBrain, 'CarrierFighters', 'none' )
							
							FtrPlatoon.BuilderName = 'CarrierFighters'
							FtrPlatoon.Parent = carrier
				
							LOUDINSERT(FtrPlatoon.EventCallbacks.OnDestroyed, platoondestroyedCallback)
							
							carrier.FtrPlatoon = FtrPlatoon
							
						end
					
						AssignUnitsToPlatoon( aiBrain, carrier.FtrPlatoon, {unitBeingBuilt}, 'Attack', 'None' )
						IssueGuard( carrier.FtrPlatoon:GetPlatoonUnits(), carrier )
					
					elseif building == 'torpedo' then
					
						if not carrier.TrpPlatoon or not PlatoonExists(aiBrain,carrier.TrpPlatoon) then
						
							local TrpPlatoon = MakePlatoon( aiBrain,'CarrierTorpedoBombers', 'none' )
							
							TrpPlatoon.BuilderName = 'CarrierTorpedoBombers'
							TrpPlatoon.Parent = carrier
				
							LOUDINSERT(TrpPlatoon.EventCallbacks.OnDestroyed, platoondestroyedCallback)
							carrier.TrpPlatoon = TrpPlatoon
							
						end
					
						AssignUnitsToPlatoon( aiBrain, carrier.TrpPlatoon, {unitBeingBuilt}, 'Attack', 'None' )
						IssueGuard( carrier.TrpPlatoon:GetPlatoonUnits(), carrier )
						
					elseif building == 'scout' then
				
						if not carrier.SctPlatoon or not PlatoonExists(aiBrain,carrier.SctPlatoon) then
						
							local SctPlatoon = MakePlatoon( aiBrain, 'CarrierScouts', 'none' )
							SctPlatoon.BuilderName = 'CarrierScouts'
							SctPlatoon.Parent = carrier
							
							LOUDINSERT(SctPlatoon.EventCallbacks.OnDestroyed, platoondestroyedCallback)
							carrier.SctPlatoon = SctPlatoon
							
						end
					
						AssignUnitsToPlatoon( aiBrain, carrier.SctPlatoon, {unitBeingBuilt}, 'scout', 'None' )
						
						IssueGuard( carrier.SctPlatoon:GetPlatoonUnits(), carrier )
						
					end

					-- reset the work progress bar to 0
					carrier:SetWorkProgress(0)

				end
				
			else
			
				FloatingEntityText( carrier.EntityID, " No build needed " )
				
			end
			
		else
		
			FloatingEntityText( carrier.EntityID, " Cannot build " )
		
		end
		
		
		WaitTicks(60)
		
	end
	
end

-- this is a variant of the carrier thread specifically for the Atlantis
function AtlantisCarrierThread ( carrier, aiBrain )

	local LOUDGETN = LOUDGETN
	local GetBuildRate = GetBuildRate
	
	local ftrlist = { 'uea0303' }
	local gunlist = { 'uea0203' }
	local bmblist = { 'uea0304' }
	local trplist = { 'uea0204' }
	local sctlist = { 'uea0302' }
	
	local faction = aiBrain.FactionIndex
	
	LOG("*AI DEBUG "..aiBrain.Nickname.." Atlantis Carrier Thread begins")
	
	-- thread will RTB the Atlantis if badly damaged
	local function WFD(carrier, aiBrain)
	
		carrier.RTB = false
	
		while (not carrier.Dead) and (not carrier.RTB) do
	
			WaitTicks(40)

			if (not carrier.Dead) and (carrier:GetHealthPercent() < .6) and not carrier.RTB then
			
				-- pull the carrier out of its platoon and RTB it
				local workplatoon = MakePlatoon( aiBrain,'AtlantisRTB', 'none')
				
				AssignUnitsToPlatoon( aiBrain, workplatoon, {carrier}, 'Attack', 'none' )
				workplatoon.BuilderName = 'AtlantisRTB'
			
				LOG("*AI DEBUG "..aiBrain.Nickname.." Atlantis issued RTB ")
				
				workplatoon:SetAIPlan( 'ReturnToBaseAI', aiBrain )
				carrier.RTB = true
			end
		end
	end
	
	-- start up the watch for damage thread 
	carrier:ForkThread( WFD, aiBrain )

	while not carrier.Dead do
    
		WaitTicks(60)

		-- check the current storage levels and build if resources good
		if (aiBrain.IgnoreArmyCaps or ((GetArmyUnitCostTotal(aiBrain.ArmyIndex) / GetArmyUnitCap(aiBrain.ArmyIndex)) < .95) )	
			and (GetEconomyStored( aiBrain, 'MASS') >= 200 and GetEconomyStored( aiBrain, 'ENERGY') >= 2500) then
			
			-- initialize the air platoons -- keep in mind that they'll disband shortly if we dont put something in them
			-- we'll recreate them every pass (if not present) so that we can decide what to build
			if not carrier.FtrPlatoon or not PlatoonExists(aiBrain,carrier.FtrPlatoon) then
				carrier.FtrPlatoon = MakePlatoon( aiBrain,'CarrierFighters', 'none')
				carrier.FtrPlatoon.BuilderName = 'CarrierFighters'
			end
			if not carrier.GunPlatoon or not PlatoonExists(aiBrain,carrier.GunPlatoon) then
				carrier.GunPlatoon = MakePlatoon( aiBrain,'CarrierGunships', 'none')
				carrier.GunPlatoon.BuilderName = 'CarrierGunships'			
			end
			if not carrier.BmbPlatoon or not PlatoonExists(aiBrain,carrier.BmbPlatoon) then
				carrier.BmbPlatoon = MakePlatoon( aiBrain,'CarrierBombers', 'none')
				carrier.BmbPlatoon.BuilderName = 'CarrierBombers'
			end
			if not carrier.TrpPlatoon or not PlatoonExists(aiBrain,carrier.TrpPlatoon) then
				carrier.TrpPlatoon = MakePlatoon( aiBrain,'CarrierTorpedoBombers', 'none')
				carrier.TrpPlatoon.BuilderName = 'CarrierTorpedoBombers'
			end
			if not carrier.SctPlatoon or not PlatoonExists(aiBrain,carrier.SctPlatoon) then
				carrier.SctPlatoon = MakePlatoon( aiBrain,'CarrierScouts', 'none')
				carrier.SctPlatoon.BuilderName = 'CarrierScouts'
			end
			
			local building = false
			local unitBeingBuilt = false
            local unitToBuild
			
			-- decide what to build -- scouts first - then fighters, bombers and gunships
			if LOUDGETN(carrier.SctPlatoon:GetPlatoonUnits()) < 2 then
				building = 'scout'
				unitToBuild = sctlist[1]
				
			elseif LOUDGETN(carrier.FtrPlatoon:GetPlatoonUnits()) < 16 then
				building = 'fighter'
				unitToBuild = ftrlist[1]
				
			elseif LOUDGETN(carrier.BmbPlatoon:GetPlatoonUnits()) < 10 then
				building = 'bomber'
				unitToBuild = bmblist[1]
				
			elseif LOUDGETN(carrier.TrpPlatoon:GetPlatoonUnits()) < 25 then
				building = 'torpedo'
				unitToBuild = trplist[1]

			elseif LOUDGETN(carrier.GunPlatoon:GetPlatoonUnits()) < 25 then
				building = 'gunship'
				unitToBuild = gunlist[1]
			end			

			-- if we're building something - build it - put into its platoon and then issue guard order
			if building and not carrier.Dead then
			
				-- we'll need the unit blueprint economy section for mass, energy and build time
				local unitbp = aiBrain:GetUnitBlueprint(unitToBuild).Economy
				local massneeded = unitbp.BuildCostMass
				local energyneeded = unitbp.BuildCostEnergy
				local timeneeded = unitbp.BuildTime
				
				carrier.UnitDrain = CreateEconomyEvent( carrier, energyneeded, massneeded, (timeneeded/GetBuildRate(carrier)), carrier.UpdateTeleportProgress)
			
				-- WAITFOR the eco event to complete
				WaitFor( carrier.UnitDrain )
				
				-- create the unit
				local cpos = carrier:GetPosition()
				local unitBeingBuilt = CreateUnitHPR( unitToBuild, aiBrain.Name, cpos[1], cpos[2] + 5, cpos[3], 0, 0, 0 )
				
				-- we built something - put it into a platoon
				if building == 'fighter' then
					if not carrier.FtrPlatoon or not PlatoonExists(aiBrain,carrier.FtrPlatoon) then
						carrier.FtrPlatoon = MakePlatoon( aiBrain,'CarrierFighters', 'none')
						carrier.FtrPlatoon.BuilderName = 'CarrierFighters'
					end
					AssignUnitsToPlatoon( aiBrain, carrier.FtrPlatoon, {unitBeingBuilt}, 'Attack', 'None' )
					
				elseif building == 'bomber' then
					if not carrier.BmbPlatoon or not PlatoonExists(aiBrain,carrier.BmbPlatoon) then
						carrier.BmbPlatoon = MakePlatoon( aiBrain,'CarrierBombers', 'none')
						carrier.BmbPlatoon.BuilderName = 'CarrierBombers'
					end
					AssignUnitsToPlatoon( aiBrain, carrier.BmbPlatoon, {unitBeingBuilt}, 'Attack', 'None' )
					
				elseif building == 'torpedo' then
					if not carrier.TrpPlatoon or not PlatoonExists(aiBrain,carrier.TrpPlatoon) then
						carrier.TrpPlatoon = MakePlatoon( aiBrain,'CarrierTorpedoBombers', 'none')
						carrier.TrpPlatoon.BuilderName = 'CarrierTorpedoBombers'
					end
					AssignUnitsToPlatoon( aiBrain, carrier.TrpPlatoon, {unitBeingBuilt}, 'Attack', 'None' )

				elseif building == 'gunship' then
					if not carrier.GunPlatoon or not PlatoonExists(aiBrain,carrier.GunPlatoon) then
						carrier.GunPlatoon = MakePlatoon( aiBrain,'CarrierGunships', 'none')
						carrier.GunPlatoon.BuilderName = 'CarrierGunships'
					end
					AssignUnitsToPlatoon( aiBrain, carrier.BmbPlatoon, {unitBeingBuilt}, 'Attack', 'None' )

				elseif building == 'scout' then
					if not carrier.SctPlatoon or not PlatoonExists(aiBrain,carrier.SctPlatoon) then
						carrier.SctPlatoon = MakePlatoon( aiBrain,'CarrierScouts', 'none')
						carrier.SctPlatoon.BuilderName = 'CarrierScouts'
					end				
					AssignUnitsToPlatoon( aiBrain, carrier.SctPlatoon, {unitBeingBuilt}, 'scout', 'None' )
				end

				-- reset the work progress bar to 0
				carrier:SetWorkProgress(0)
				
				IssueGuard( carrier.FtrPlatoon:GetPlatoonUnits(), carrier )
				IssueGuard( carrier.BmbPlatoon:GetPlatoonUnits(), carrier )
				IssueGuard( carrier.TrpPlatoon:GetPlatoonUnits(), carrier )
				IssueGuard( carrier.GunPlatoon:GetPlatoonUnits(), carrier )
				IssueGuard( carrier.SctPlatoon:GetPlatoonUnits(), carrier )
			end
		end
	end
end

-- this is a variant of the carrier thread specifically for the Czar
function CzarCarrierThread ( carrier, aiBrain )

	local LOUDGETN = LOUDGETN
	local GetBuildRate = GetBuildRate
	
	local ftrlist = { 'uaa0303' }
	local gunlist = { 'xaa0305' }
	local bmblist = { 'uaa0304' }
	local sctlist = { 'uaa0302' }
	
	local faction = aiBrain.FactionIndex
	
	LOG("*AI DEBUG "..aiBrain.Nickname.." Czar Carrier Thread begins")
	
	carrier.RTB = false
	
	-- will RTB the Czar if badly damaged
	local function WFD( carrier, aiBrain )
	
		carrier.RTB = false
	
		while not carrier.RTB do
		
			WaitTicks(40)

			if (not carrier.Dead) and (carrier:GetHealthPercent() < .6) and not carrier.RTB then
			
				-- pull the Czar out of its platoon and RTB it
				local workplatoon = MakePlatoon( aiBrain,'CzarRTB', 'none')
				
				AssignUnitsToPlatoon( aiBrain, workplatoon, {carrier}, 'Attack', 'none' )
				workplatoon.BuilderName = 'CzarRTB'

				LOG("*AI DEBUG "..aiBrain.Nickname.." Czar issued RTB ")
				
				workplatoon:SetAIPlan('ReturnToBaseAI',aiBrain)
				
				carrier.RTB = true
				
			end
			
		end
		
	end
	
	-- start up the watch for damage thread 
	carrier:ForkThread( WFD, aiBrain )
	
	local building, unitBeingBuilt, unitToBuild
	local unitbp, massneeded, energyneeded, timeneeded
	local cpos
	
	while not carrier.Dead do
    
		WaitTicks(60)

		-- check the current storage levels and build if resources good
		if (aiBrain.IgnoreArmyCaps or ((GetArmyUnitCostTotal(aiBrain.ArmyIndex) / GetArmyUnitCap(aiBrain.ArmyIndex)) < .95) )	
			and (GetEconomyStored( aiBrain, 'MASS') >= 200 and GetEconomyStored( aiBrain, 'ENERGY') >= 2500) then
			
			-- initialize the air platoons -- keep in mind that they'll disband shortly if we dont put something in them
			-- we'll recreate them every pass (if not present) so that we can decide what to build
			if not carrier.FtrPlatoon or not PlatoonExists(aiBrain,carrier.FtrPlatoon) then
			
				carrier.FtrPlatoon = MakePlatoon( aiBrain,'CarrierFighters', 'none')
				carrier.FtrPlatoon.BuilderName = 'CarrierFighters'
				
			end
			
			if not carrier.GunPlatoon or not PlatoonExists(aiBrain,carrier.GunPlatoon) then
			
				carrier.GunPlatoon = MakePlatoon( aiBrain,'CarrierGunships', 'none')
				carrier.GunPlatoon.BuilderName = 'CarrierGunships'			
				
			end
			
			if not carrier.BmbPlatoon or not PlatoonExists(aiBrain,carrier.BmbPlatoon) then
			
				carrier.BmbPlatoon = MakePlatoon( aiBrain,'CarrierBombers', 'none')
				carrier.BmbPlatoon.BuilderName = 'CarrierBombers'
				
			end
			
			if not carrier.SctPlatoon or not PlatoonExists(aiBrain,carrier.SctPlatoon) then
			
				carrier.SctPlatoon = MakePlatoon( aiBrain,'CarrierScouts', 'none')
				carrier.SctPlatoon.BuilderName = 'CarrierScouts'
				
			end
			
			building = false
			unitBeingBuilt = false
			
			-- decide what to build -- scouts first - then fighters, bombers and gunships
			if LOUDGETN(carrier.SctPlatoon:GetPlatoonUnits()) < 2 then
			
				building = 'scout'
				unitToBuild = sctlist[1]
				
			elseif LOUDGETN(carrier.FtrPlatoon:GetPlatoonUnits()) < 14 then
			
				building = 'fighter'
				unitToBuild = ftrlist[1]
				
			elseif LOUDGETN(carrier.BmbPlatoon:GetPlatoonUnits()) < 10 then
			
				building = 'bomber'
				unitToBuild = bmblist[1]
				
			elseif LOUDGETN(carrier.GunPlatoon:GetPlatoonUnits()) < 10 then
			
				building = 'gunship'
				unitToBuild = gunlist[1]
				
			end			

			-- if we're building something - build it - put into its platoon and then issue guard order
			if building and not carrier.Dead then
			
				-- we'll need the unit blueprint economy section for mass, energy and build time
				unitbp = aiBrain:GetUnitBlueprint(unitToBuild).Economy
				
				massneeded = unitbp.BuildCostMass
				energyneeded = unitbp.BuildCostEnergy
				timeneeded = unitbp.BuildTime
				
				carrier.UnitDrain = CreateEconomyEvent( carrier, energyneeded, massneeded, (timeneeded/GetBuildRate(carrier)), carrier.UpdateTeleportProgress)
			
				-- WAITFOR the eco event to complete
				WaitFor( carrier.UnitDrain )
				
				-- create the unit
				cpos = carrier:GetPosition()
				unitBeingBuilt = CreateUnitHPR( unitToBuild, aiBrain.Name, cpos[1], cpos[2] + 5, cpos[3], 0, 0, 0 )
				
				-- we built something - put it into a platoon
				if building == 'fighter' then
				
					if not carrier.FtrPlatoon or not PlatoonExists(aiBrain,carrier.FtrPlatoon) then
					
						carrier.FtrPlatoon = MakePlatoon( aiBrain,'CarrierFighters', 'none')
						carrier.FtrPlatoon.BuilderName = 'CarrierFighters'
						
					end
					
					AssignUnitsToPlatoon( aiBrain, carrier.FtrPlatoon, {unitBeingBuilt}, 'Attack', 'None' )
					
				elseif building == 'bomber' then
				
					if not carrier.BmbPlatoon or not PlatoonExists(aiBrain,carrier.BmbPlatoon) then
					
						carrier.BmbPlatoon = MakePlatoon( aiBrain,'CarrierBombers', 'none')
						carrier.BmbPlatoon.BuilderName = 'CarrierBombers'
						
					end
					
					AssignUnitsToPlatoon( aiBrain, carrier.BmbPlatoon, {unitBeingBuilt}, 'Attack', 'None' )
					
				elseif building == 'gunship' then
				
					if not carrier.GunPlatoon or not PlatoonExists(aiBrain,carrier.GunPlatoon) then
					
						carrier.GunPlatoon = MakePlatoon( aiBrain,'CarrierGunships', 'none')
						carrier.GunPlatoon.BuilderName = 'CarrierGunships'
						
					end
					
					AssignUnitsToPlatoon( aiBrain, carrier.BmbPlatoon, {unitBeingBuilt}, 'Attack', 'None' )

				elseif building == 'scout' then
				
					if not carrier.SctPlatoon or not PlatoonExists(aiBrain,carrier.SctPlatoon) then
					
						carrier.SctPlatoon = MakePlatoon( aiBrain,'CarrierScouts', 'none')
						carrier.SctPlatoon.BuilderName = 'CarrierScouts'
						
					end

					AssignUnitsToPlatoon( aiBrain, carrier.SctPlatoon, {unitBeingBuilt}, 'scout', 'None' )
					
				end

				-- reset the work progress bar to 0
				carrier:SetWorkProgress(0)
				
				IssueGuard( carrier.FtrPlatoon:GetPlatoonUnits(), carrier )
				IssueGuard( carrier.BmbPlatoon:GetPlatoonUnits(), carrier )
				IssueGuard( carrier.GunPlatoon:GetPlatoonUnits(), carrier )
				IssueGuard( carrier.SctPlatoon:GetPlatoonUnits(), carrier )
				
			end
			
		end
		
	end
	
end

-- this controls the AI TMLs and adjusts to lead targets
function TMLThread( unit, aiBrain )
    
    local maxRadius = unit:GetBlueprint().Weapon[1].MaxRadius
	local position = LOUDCOPY(GetPosition(unit))

	local GetUnitsAroundPoint = GetUnitsAroundPoint
    
	local UnitLeadTarget = import('/lua/ai/sorianutilities.lua').LeadTarget	-- this uses the specific one for TMLs
	local WaitTicks = WaitTicks
    
    --LOG("*AI DEBUG "..aiBrain.Nickname.." TMLThread launched")
    
    unit.HasTMLTarget = false
	
    unit:SetAutoMode(true)

	local atkPri = { 'SHIELD','ANTIMISSILE -SILO','EXPERIMENTAL','ARTILLERY','ECONOMIC','ENGINEER TECH3','MOBILE TECH3', }
	local targetUnits, target, targPos
    
    local u = {unit}
	
    while not unit.Dead do

        -- dont search for targets unless ammo is 2+
        while unit:GetTacticalSiloAmmoCount() > 2 do

            while unit:GetTacticalSiloAmmoCount() > 0 do
            
                --LOG("*AI DEBUG "..aiBrain.Nickname.." TML seeking target")
			
                targetUnits = GetUnitsAroundPoint( aiBrain, categories.ALLUNITS - categories.WALL - categories.AIR - categories.TECH1, position, maxRadius, 'Enemy' )
                
                if targetUnits[1] and not unit.HasTMLTarget then
                
                    --LOG("*AI DEBUG "..aiBrain.Nickname.." TML examining targets")
            
                    -- loop thru each of the attack Priorities
                    for _,v in atkPri do
                
                        target = false
                        
                        for _, targetunit in EntityCategoryFilterDown( ParseEntityCategory(v), targetUnits ) do
                    
                            -- if you find a target then break out
                            if not targetunit.Dead then
                                target = targetunit
                                break
                            end
                        
                        end

                        -- if there is a target -- fire at it
                        if target and (not target.Dead) and not unit.Dead then
			
                            if LOUDENTITY(categories.STRUCTURE, target) then
                            
                                --LOG("*AI DEBUG "..aiBrain.Nickname.." TML firing at structure")
                            
                                IssueClearCommands( u )

                                IssueTactical( u, target)
                                
                                break
                                
                            else
                            
                                -- get a target position based upon movement
                                targPos = UnitLeadTarget(position, target) 
					
                                if targPos then
                            
                                    IssueClearCommands( u )
                                
                                    IssueTactical( u, targPos)
                                    
                                    --LOG("*AI DEBUG "..aiBrain.Nickname.." TML firing at position")

                                    target = false
                                    targPos = false 	-- clear targeting data 
                                    break	-- break out back to ammo loop
                                end
                                
                            end
                            
                        else
                            
                            target = false
                            targPos = false

                        end
                        
                    end

                end

                WaitTicks(16)    -- delay between targeting checks or busy

			end
            
            targetUnits = nil
            
		end
		
		-- wait 10 seconds between ammo checks
        WaitTicks(101)
    end
end

-- Used as a visual aid - this will have a unit from the platoon visually
-- broadcast the platoon handle so you can see what they are every 15 seconds
function BroadcastPlatoonPlan ( platoon, aiBrain )

    local originalplan
    
	local PlatoonExists = PlatoonExists
    local GetPlatoonUnits = GetPlatoonUnits	
	
	local DisplayPlatoonPlans = ScenarioInfo.DisplayPlatoonPlans or false
	
	local armyindex = aiBrain.ArmyIndex
	local units
    
    while PlatoonExists( aiBrain, platoon ) and DisplayPlatoonPlans do
    
		if GetFocusArmy() == armyindex or GetFocusArmy() == -1 then
		
			units = GetPlatoonUnits(platoon)
		
			for _,v in units do
			
				if not v.Dead then

					ForkThread( FloatingEntityText, v.EntityID, repr(v.PlatoonHandle.BuilderName).." "..repr(v.PlatoonHandle.BuilderInstance))
				
					if not originalplan then
					
						originalplan = v.PlatoonHandle.BuilderName
						
					end
					
					break	-- only do once for the whole platoon
					
				end
				
			end
			
		end
		
        WaitTicks(151)
    end
	
end

-- this function is used to monitor any change to the primary base
-- position during the execution of a Return To Base
-- if it changes - the RTB is reissued with new primary base
function PlatoonWatchPrimarySeaAttackBase ( platoon, aiBrain )

    local GetPrimarySeaAttackBase = import('/lua/loudutilities.lua').GetPrimarySeaAttackBase
	local PlatoonExists = PlatoonExists	
    
    -- set the Primary base at the start
    local Base = GetPrimarySeaAttackBase(aiBrain)

    -- if the primary base changes - restart the plan
    -- which should send the platoon to the new primary
    while PlatoonExists( aiBrain, platoon ) do
    
        WaitTicks(81)
        
        local Primary = GetPrimarySeaAttackBase(aiBrain)
        
        if Primary != Base then
        
            LOG("*AI DEBUG "..aiBrain.Nickname.." Platoon "..platoon.BuilderName.." "..repr(platoon.BuilderInstance).." Detects that Primary Sea Base has changed to "..repr(Primary))
            
            platoon.RTBLocation = Primary
            
            for _,v in GetPlatoonUnits(platoon) do
                v.LocationType = platoon.RTBLocation
            end

            platoon:SetAIPlan( 'ReturnToBaseAI', aiBrain )
            
            -- make the target base the primary
            Base = GetPrimarySeaAttackBase(aiBrain)
        end
    end

end

-- SELF ENHANCE THREAD for SUBCOMMANDERS
-- After running into various difficulties in getting SCU to upgrade reliably thru the PFM
-- I felt it was better to go this route and let each SCU decide when to enhance themselves
-- thus saving a lot of confusing effort in the Platoon Form Manager
function SCUSelfEnhanceThread ( unit, faction, aiBrain )

	local WaitTicks = WaitTicks
    
    local HasEnhancement = unit.HasEnhancement
    local SetBlockCommandQueue = unit.SetBlockCommandQueue

	-- one entry for each faction - AEON,UEF,Cybran and Sera -- of course -- it might be more
	-- readable to have this data carried in the unit blueprint as part of the AI or Enhancement data
    local EnhancementTable = {
    { 'ResourceAllocation', 'AdvancedCoolingUpgrade', 'Shield', 'ShieldGeneratorField' },
    { 'ResourceAllocation', 'EngineeringFocusingModule', 'Shield', 'ShieldHeavy' },
    { 'ResourceAllocation', 'Switchback', 'StealthGenerator' },
    { 'EngineeringThroughput', 'Shield', 'Teleporter' },
    }
    
    local EnhanceList = EnhancementTable[faction]
    local final = EnhanceList[LOUDGETN(EnhanceList)]
    
    local EBP = __blueprints[unit.BlueprintID].Enhancements
	
	local GetBuildRate = GetBuildRate
	local IsIdleState = IsIdleState
	local IsUnitState = IsUnitState
    
	local BuildCostE, BuildCostM, BuildCostT, count, CurrentEnhancement, EFFTime, RateNeededE, RateNeededM

    local ArmyPool = aiBrain.ArmyPool
    local NameEngineers = ScenarioInfo.NameEngineers
    local SCUEnhanceDialog = ScenarioInfo.SCUEnhanceDialog
    
    while (not unit.Dead) and not unit.EnhancementsComplete do

        CurrentEnhancement = EnhanceList[1]

		if HasEnhancement( unit, CurrentEnhancement) then

			LOUDREMOVE(EnhanceList, 1)
		end

        -- if unit is idle and not currently in a platoon
        if IsIdleState(unit) and ( (not unit.PlatoonHandle) or unit.PlatoonHandle == ArmyPool) and not HasEnhancement( unit, CurrentEnhancement ) then
        
            unit.AssigningTask = true
		
			BuildCostE = EBP[CurrentEnhancement].BuildCostEnergy
			BuildCostM = EBP[CurrentEnhancement].BuildCostMass
			BuildCostT = EBP[CurrentEnhancement].BuildTime
            
            EffTime = ((100/GetBuildRate(unit)) * BuildCostT) / 100    -- build time in seconds
			
            RateNeededE = BuildCostE / EffTime
            RateNeededM = BuildCostM / EffTime
            
            -- if we can meet 85% of the Energy and Mass needs of the upgrade - go ahead with it
            if ((GetEconomyTrend(aiBrain,'ENERGY') * 10) >= (RateNeededE * .85)) and ((GetEconomyTrend(aiBrain,'MASS') * 10) >= (RateNeededM * .85)) then
			
				-- note that storage requirements for enhancements are just a little higher than those for factories building units
				-- this is to insure that unit building and upgrading take priority over enhancements
				if GetEconomyStored( aiBrain, 'MASS') >= 450 and GetEconomyStored( aiBrain, 'ENERGY') >= 4500 then
			
                    for _,v in unit:GetGuards() do
			
                        if not v.Dead and v.PlatoonHandle then
				
                            v.PlatoonHandle:ReturnToBaseAI(aiBrain)
                        end
                    end

					IssueStop({unit})
					IssueClearCommands({unit})
			
					if NameEngineers then
						unit:SetCustomName("SCU "..unit.EntityID.." "..CurrentEnhancement)
					end
				
					IssueScript( {unit}, {TaskName = "EnhanceTask", Enhancement = CurrentEnhancement} )
                    
                    unit.CurrentBuildOrder = 'Enhance'
                    unit.DesiresAssist = true
                    unit.IssuedBuildCommand = true
                    unit.NumAssistees = 3
				
					count = 0
					
					if SCUEnhanceDialog then
						LOG("*AI DEBUG "..aiBrain.Nickname.." SCUEnhance "..unit.EntityID.." waiting to start "..repr(CurrentEnhancement))
					end

					-- sometimes SCU has a problem getting started so count was necessary
					repeat
						WaitTicks(10)
						count = count + 1
					until unit.Dead or IsUnitState(unit,'Enhancing') or count > 10


					if IsUnitState(unit,'Enhancing') then
                    
                        unit.Upgrading = true
                        
                        unit.UnitBeingBuilt = unit
					
						-- prevent any other orders while enhancing
						SetBlockCommandQueue( unit, true)
						
                        WaitTicks(11)
                        
						if SCUEnhanceDialog then
							LOG("*AI DEBUG "..aiBrain.Nickname.." SCUEnhance "..unit.EntityID.." starting "..repr(CurrentEnhancement))
						end
				
						repeat
							WaitTicks(61)
						until not IsUnitState(unit,'Enhancing') or unit.Dead

					end
                
                    unit.CurrentBuildOrder = false
                    unit.DesiresAssist = false
                    unit.IssuedBuildCommand = false
                    unit.NumAssistees = 1
                    
                    unit.Upgrading = false
                    unit.UnitBeingBuilt = false
                    
					if HasEnhancement( unit, CurrentEnhancement) then
				
						LOUDREMOVE(EnhanceList, 1)
						
						if SCUEnhanceDialog then
							LOG("*AI DEBUG "..aiBrain.Nickname.." SCUEnhance "..unit.EntityID.." completed "..repr(CurrentEnhancement))
						end
                        
                        if CurrentEnhancement == 'Teleporter' then
                            unit.CanTeleport = true
                        end
					
					else
						LOG("*AI DEBUG "..aiBrain.Nickname.." SCU "..unit.EntityID.." Failed Enhancement "..repr(CurrentEnhancement))
					end
				
					-- allow other orders when no longer enhancing
					SetBlockCommandQueue( unit, false )               				
				
					unit.AssigningTask = false
				
					local manager = aiBrain.BuilderManagers[unit.LocationType].EngineerManager
				
					if manager.Active then
				
						manager:ForkThread( manager.DelayAssignEngineerTask, unit, aiBrain )
					
					else
				
						manager:ForkThread( manager.ReassignEngineer, unit, aiBrain)
					end
				end
            end

            unit.AssigningTask = false			
            
            WaitTicks(36)
        end
		
        WaitTicks(12)
        
        if HasEnhancement( unit, final) then
		
			if SCUEnhanceDialog then
				LOG("*AI DEBUG "..aiBrain.Nickname.." SCUEnhance "..unit.EntityID.." all enhancements completed")
			end		
		
			unit.EnhancementsComplete = true
			
            break
        end
    end
	
	KillThread(unit.EnhanceThread)
	
	unit.EnhanceThread = nil
	
end

-- SELF ENHANCE for Other Units
function FactorySelfEnhanceThread ( unit, faction, aiBrain, manager )

    local EBP = __blueprints[unit.BlueprintID].Enhancements or false
	
	if not EBP or unit.EnhancementsComplete then
		return
	end

    local GetFractionComplete = moho.entity_methods.GetFractionComplete
	local WaitTicks = WaitTicks
    
    local HasEnhancement = unit.HasEnhancement
    local SetBlockCommandQueue = unit.SetBlockCommandQueue
	
	while not unit.Dead and GetFractionComplete(unit) < 1 do
		WaitTicks(101)
	end

	-- this gets the sequence of enhancements
    local EnhanceList = LOUDCOPY(EBP.Sequence)
	
    local final = EnhanceList[LOUDGETN(EnhanceList)]
	
	if HasEnhancement( unit, final) then
		return
	end	

	if not EnhanceList[1] then
		EBP = false
	end
	
	local GetBuildRate = GetBuildRate
    
	local IsIdleState = IsIdleState
	local IsUnitState = IsUnitState
    
	local CurrentEnhancement
	local BuildCostE, BuildCostM, BuildCostT
	local EFFTime, RateNeededE, RateNeededM
    
    local DisplayFactoryBuilds = ScenarioInfo.DisplayFactoryBuilds
    local FactoryEnhanceDialog = ScenarioInfo.FactoryEnhanceDialog
  
    while EBP and (not unit.Dead) and not unit.EnhancementsComplete do
	
		WaitTicks(201)

        CurrentEnhancement = EnhanceList[1]

        while (not unit.Dead) and not HasEnhancement(unit, CurrentEnhancement) do

			if IsIdleState(unit) then
		
				BuildCostE = EBP[CurrentEnhancement].BuildCostEnergy
				BuildCostM = EBP[CurrentEnhancement].BuildCostMass
				BuildCostT = EBP[CurrentEnhancement].BuildTime
		
				EffTime = ((100/GetBuildRate(unit)) * BuildCostT) / 100    -- build time in seconds

				RateNeededE = BuildCostE / EffTime
				RateNeededM = BuildCostM / EffTime

				-- if we can meet 95% of the Energy and Mass needs of the enhancement
				-- also - note - we must actually have that data structure - civilians DO NOT have this 
				if (aiBrain.EcoData['OverTime']['EnergyTrend']) and ((aiBrain.EcoData['OverTime']['EnergyTrend'] * 10) >= (RateNeededE * .95)) and ((aiBrain.EcoData['OverTime']['MassTrend'] * 10) >= (RateNeededM * .95)) then
			
					-- note that storage requirements for enhancements are just a little higher than those for factories building units
					-- this is to insure that unit building and upgrading take priority over enhancements
					if GetEconomyStored( aiBrain, 'MASS') >= 450 and GetEconomyStored( aiBrain, 'ENERGY') >= 4500 then
				
						IssueStop({unit})
						IssueClearCommands({unit})
				
						unit.Upgrading = true
						
						if FactoryEnhanceDialog then
							LOG("*AI DEBUG "..aiBrain.Nickname.." FACTORYEnhance "..unit.EntityID.." waiting to start "..repr(CurrentEnhancement))
						end
				
						IssueScript( {unit}, {TaskName = "EnhanceTask", Enhancement = CurrentEnhancement} )

						repeat
							WaitTicks(11)
						until unit.Dead or IsUnitState(unit,'Enhancing')
					
						if IsUnitState(unit,'Enhancing') and not unit.Dead then
						
                            if DisplayFactoryBuilds then
                                unit:SetCustomName(repr(CurrentEnhancement))
                            end						
	
							SetBlockCommandQueue( unit, true)
							
							if FactoryEnhanceDialog then
								LOG("*AI DEBUG "..aiBrain.Nickname.." FACTORYEnhance "..unit.EntityID.." starting "..repr(CurrentEnhancement))
							end							
				
							while not unit.Dead and IsUnitState(unit,'Enhancing') do
								WaitTicks(81)
							end  
				
							if not unit.Dead then
								SetBlockCommandQueue( unit, false)
							end
						end
              
						if HasEnhancement( unit, CurrentEnhancement) and not unit.Dead then
							
							if FactoryEnhanceDialog then
								LOG("*AI DEBUG "..aiBrain.Nickname.." FACTORYEnhance "..unit.EntityID.." completed "..repr(CurrentEnhancement))
							end							
							
							LOUDREMOVE(EnhanceList, 1)
						end
						
						if not unit.Dead then

							unit.Upgrading = nil
				
							unit.failedbuilds = 0
						
							if DisplayFactoryBuilds then
								unit:SetCustomName("")
							end						
				
							-- since a manager will only be provided by a factory
							if manager then
								ForkThread(manager.DelayBuildOrder, manager, unit )
							end
						end

					else
						WaitTicks(41)
					end
					
				else
					WaitTicks(41)
				end
				
			end
			
	        WaitTicks(26)		
        end
        
        if HasEnhancement( unit, final) then
		
			if FactoryEnhanceDialog then
				LOG("*AI DEBUG "..aiBrain.Nickname.." FACTORYEnhance "..unit.EntityID.." all enhancements complete")
			end							
			
			unit.Upgrading = nil
			unit.failedbuilds = 0
			
            EBP = false
        end
    end
	
	unit.EnhancementsComplete = true
	
	KillThread(unit.EnhanceThread)
	
	unit.EnhanceThread = nil
	
end

-- SELF UPGRADE THREAD
-- The entire purpose of this thread is to take load off of the platoon manager
--
-- By allowing units to upgrade themselves based on economic conditions, quite a
-- number of platoon formations are removed & less build conditions have to be
-- checked by the Builder Manager

-- launched by the Engineer Manager when units are completed

-- Each unit class has its own set of triggers for both high and low mass & energy efficiencies
-- The intent is simple, if we meet those economic values - it's ok to consider upgrading
-- then we'll actually check the M & E rates against this specific upgrade
-- and last we'll confirm that a certain % of the resources are actually available

-- When an upgrade thread is started - it has an initial delay period before it can attempt to upgrade
-- this prevents, in most situations, units from immediately going into an upgrade the moment they are built
-- This 'delay' period is only used up during times of having the base eco storage amounts

-- Once the actual checking begins, the rate of the checking has a great influence on just how likely units
-- are to be selected to upgrade - because - we don't want everyone upgrading at once

-- Anytime a unit is allowed to upgrade - the UpgradeIssued counter is increased by one (see SelfUpgradeDelay)
-- and a delay period begins
    -- related to the buildtime of the upgrade
    -- and the economic state at the time the upgrade was issued
    
    -- if we have a lot of stored resources, this delay is shorter than when we dont
    -- this allows the AI to begin another upgrade sooner, in conditions of plenty
    -- while keeping him restrained when things are tight.

-- The conditions of the game limit the AI, in that he's not allowed to start too many upgrades in a hurry
-- so whenever this counter has reached it's limit - ANY attempt to upgrade is inhibited

-- after the delay has elapsed -- this counter will drop by one - 
-- thus providing a dynamic process that adapts nicely to feast and famine
-- and to the needs of the upgrade in question

-- note the addition of the 'notify' parameter, this will pop text over the affected unit, whenever the test process runs, set in AIDebug tools

function SelfUpgradeThread ( unit, faction, aiBrain, masslowtrigger, energylowtrigger, masshightrigger, energyhightrigger, checkperiod, initialdelay, bypassecon, notify)

    local StructureUpgradeDialog    = ScenarioInfo.StructureUpgradeDialog or false
    local GetFractionComplete       = moho.entity_methods.GetFractionComplete

    local Game = import('/lua/game.lua')

	local upgradeID = __blueprints[unit.BlueprintID].General.UpgradesTo or false
	local upgradebp = false

	if upgradeID then
		upgradebp = __blueprints[upgradeID] or false	-- this accounts for upgradeIDs that point to non-existent units (like mod not loaded)
	end
    
    if upgradebp and Game.UnitRestricted( false, upgradeID ) then
    
        LOG("*AI DEBUG Upgrade restricted "..repr(upgradeID) )
    
        unit.UpgradeThread = nil
        unit.UpgradeComplete = true
        return
    end
	
	-- if not upgradeID and blueprint available then kill the thread and exit
	if not (upgradeID and upgradebp) or (not aiBrain.MinorCheatModifier) then
		unit.UpgradeThread = nil
		unit.UpgradesComplete = true
        
        if StructureUpgradeDialog then
            LOG("*AI DEBUG "..aiBrain.Nickname.." STRUCTUREUpgrade "..unit.EntityID.." "..unit:GetBlueprint().Description.." has no upgradeID or upgradebp on tick "..GetGameTick() )
        end

		return
	end
	
	-- set defaults for any without triggers
	if not masslowtrigger then
		local masslowtrigger = .85
		local energylowtrigger = 1.10
	end
    
    if not masshightrigger then
        local masshightrigger = 2
        local energyhightrigger = 2
    end
	
	if not checkperiod then
		local checkperiod = 20
		local initialdelay = 240
	end
	
	if not bypassecon then
		local bypassecon = false
	end
    
    local buildrate = unit:GetBuildRate()               --- build rate of constructing unit
    local massmade  = unit:GetProductionPerSecondMass()
    local enermade  = unit:GetProductionPerSecondEnergy()
    local enerused  = unit:GetConsumptionPerSecondEnergy()
    
    local baseM     = 250
    local baseE     = 3000
    
    -- these two values control resource requirements versus storage rather than rates
    -- and they act as a bypass whenever the storage holds this % of the total upgrade cost
    local masslimit     = .67   --- if we have 67% of the total mass needed - it's ok to upgrade
    local energylimit   = .78   --- and 78% for energy

    local tech2Mex = {
        ueb1202 = true,
        uab1202 = true,
        urb1202 = true,
        xsb1202 = true
    }

    if tech2Mex[upgradeID] then -- aggressively push T2 mass upgrades
        masslimit = .3
        energylimit = .6
    end

    -- basic costs of upgraded unit -- affected both by the limits above AND the cheat values
	local MassNeeded    = (upgradebp.Economy.BuildCostMass * masslimit) / aiBrain.MinorCheatModifier
	local EnergyNeeded  = (upgradebp.Economy.BuildCostEnergy * energylimit) / aiBrain.MinorCheatModifier
    
    local buildtime     = upgradebp.Economy.BuildTime

    -- trend rates needed to sustain this build without serious loss over the buildtime
    -- trend rates take into account current output and are multiplied by .1 to match with the ECO trends
    -- all minimums are capped at 0 so negative values are not possible
    -- this will result in more aggressive upgrading as the cheat level increases (not affected by ACT)
    local MassTrendNeeded   = LOUDMAX(((( (MassNeeded / buildtime) * buildrate) - massmade) * .1) * LOUDMIN( 1, 1), 0)
    local EnergyTrendNeeded = LOUDMAX(((( (EnergyNeeded / buildtime) * buildrate) - enermade) * .1) * LOUDMIN( 1, 1), 0)
	local EnergyMaintenance = LOUDMAX( (( __blueprints[upgradeID].Economy.MaintenanceConsumptionPerSecondEnergy or 10) - enerused) * .1, 0)

	local init_delay        = 1
	local upgradeIssued     = false    
    local workrate          = checkperiod   --- store normal checkperiod

    local body = "*AI DEBUG "..aiBrain.Nickname.." STRUCTUREUpgrade "..unit.EntityID.." "..unit:GetBlueprint().Description    

	if StructureUpgradeDialog then
   		LOG( body.." starts upgrade thread to "..repr(upgradeID).." initial delay is "..(initialdelay*10).." ticks - on tick "..GetGameTick() )
	end

	-- wait the initial delay before upgrading - accounts for unit not finished being built and basic storage requirements
	-- check storage values every 10 seconds -- and only advance the delay counter if we have the basic storage requirements
    -- those that bypassecon advance it by 2 seconds 
	while init_delay < initialdelay do
        
        if EntityCategoryContains( categories.MASSEXTRACTION * categories.TECH1, unit ) and GetFractionComplete(unit) == 1 then -- t2 mass ignores storage requirement
			init_delay = init_delay + 10
		-- uses the same values as factories do for units
		if GetEconomyStored( aiBrain, 'MASS') >= baseM and GetEconomyStored( aiBrain, 'ENERGY') >= baseE and GetFractionComplete(unit) == 1 then
			init_delay = init_delay + 10
		else
            -- units which are permitted to bypass the more stringent eco tests can advance
            -- the init_delay by 2.5 seconds (rather than 10) even when the gateway values fail
            if bypassecon then
                init_delay = init_delay + 2.5
            end

        end
		
		WaitTicks(101)
	end

    if StructureUpgradeDialog then
        LOG( body.." initial delay complete on tick "..GetGameTick() )
    end
		
    local econ  = aiBrain.EcoData.OverTime

	local EnergyStorage, MassStorage
	
	while ((not unit.Dead) or unit.EntityID) and (not upgradeIssued) do
        
        if notify then
            ForkThread( FloatingEntityText, unit.EntityID, "Nxt Upg Chk "..string.format( "%d", math.floor(checkperiod)).."s" )
        end
 	
		WaitTicks(checkperiod * 10)

        --if StructureUpgradeDialog then
          --  LOG( body.." cycles on tick "..GetGameTick() )
        --end
		
        if EntityCategoryContains( categories.MASSEXTRACTION, unit ) and aiBrain.MexUpgradeActive >= aiBrain.MexUpgradeLimit then
            continue
        end

        if aiBrain.UpgradeIssued < aiBrain.UpgradeIssuedLimit and (not unit.BeingReclaimed) then

			EnergyStorage   = GetEconomyStored( aiBrain, 'ENERGY')
			MassStorage     = GetEconomyStored( aiBrain, 'MASS')

            --- basic resource requirement for ALL things (except bypassecon things)
            if (MassStorage < baseM or EnergyStorage < baseE) and not bypassecon then

                if StructureUpgradeDialog then
                    LOG( body.." fails base storage M "..MassStorage.."  E "..EnergyStorage )
                end

                continue
            end

            -- if upgrading a T2 Mex then either efficiency or storage can prevent the upgrade to limit the number running concurrently
            if EntityCategoryContains( categories.MASSEXTRACTION * categories.TECH1, unit ) and 
            ((econ.MassEfficiency < masslowtrigger or MassStorage < MassNeeded) or
            (econ.EnergyEfficiency < energylowtrigger or EnergyStorage < EnergyNeeded)) then
                continue
            end

            -- first we check the low efficiency trigger or needed resources in storage
            -- either one gets you past this check
            if (econ.MassEfficiency >= masslowtrigger and econ.EnergyEfficiency >= energylowtrigger)

				or MassStorage > MassNeeded and EnergyStorage > EnergyNeeded then

				--low_trigger_good = true
                
			else
            
                if StructureUpgradeDialog then
                
                    if (econ.MassEfficiency < masslowtrigger or econ.EnergyEfficiency < energylowtrigger) then
                    
                        if econ.MassEfficiency < masslowtrigger then
                            LOG( body.." fails MIN M efficiency of "..string.format("%.3f",masslowtrigger).." current "..string.format("%.3f",econ.MassEfficiency).." on tick "..GetGameTick())
                        else
                            LOG( body.." fails MIN E efficiency of "..string.format("%.3f",energylowtrigger).." current "..string.format("%.3f",econ.EnergyEfficiency).." on tick "..GetGameTick())
                        end
                        
                    elseif MassStorage < MassNeeded or EnergyStorage < EnergyNeeded then
                        LOG( body.." fails MIN storage percent resource needed on tick "..GetGameTick() )
                    end

                end

				continue
			end
			
            -- then we check the high efficiency limits
			if (econ.MassEfficiency <= masshightrigger and econ.EnergyEfficiency <= energyhightrigger) then
				
				--hi_trigger_good = true
                
			else
            
                if StructureUpgradeDialog then
                
                    if (econ.MassEfficiency > masshightrigger or econ.EnergyEfficiency > energyhightrigger) then
                    
                        if econ.MassEfficiency > masshightrigger then
                            LOG( body.." fails MAX M efficiency of "..string.format("%.3f",masshightrigger).." current "..string.format("%.3f",econ.MassEfficiency).." on tick "..GetGameTick())
                        else
                            LOG( body.." fails MAX E efficiency of "..string.format("%.3f",energyhightrigger).." current "..string.format("%.3f",econ.EnergyEfficiency).." on tick "..GetGameTick())
                        end

                    end

                end
            
				continue
			end

            -- if we pass the efficiency checks
            checkperiod = LOUDMAX(checkperiod - .05, 10)

            -- all values are marginally reduced --
            -- resources required are impacted by ajacency bonuses which takes into account the cheat bonus
            -- the trend requirements are NOT impacted in this way
            MassNeeded          = MassNeeded * math.min(1, unit.MassBuildAdjMod or 1)
            EnergyNeeded        = EnergyNeeded * math.min(1, unit.EnergyBuildAdjMod or 1)
            MassTrendNeeded     = MassTrendNeeded * .995
            EnergyTrendNeeded   = EnergyTrendNeeded * .995
            
            -- Now we check the current trends or the resources in storage
            
			-- if we have the M & E trend to support this build -- and energy consumption of the upgraded item is less than our current energytrend, we're good
			-- or we have the limit values of mass and energy,  in our storage

            if ( econ.MassTrend >= MassTrendNeeded and econ.EnergyTrend >= EnergyTrendNeeded and econ.EnergyTrend >= EnergyMaintenance )
            
				or ( MassStorage >= MassNeeded and EnergyStorage > EnergyNeeded )  then

                -- we may have passed the first check based upon trends - this next check insures having at least 25% resources
				-- anything that has bypassecon always passes this check - basically if we have the efficiency and trends - storage doesn't matter
                -- otherwise if the efficiency and trends got you here - you still must have 25% (modified by low triggers) of the resources
				if (MassStorage >= ( MassNeeded * .25 * masslowtrigger) and EnergyStorage >= ( EnergyNeeded * .25 * energylowtrigger))

                    or bypassecon then
                    
                    if aiBrain.UpgradeIssued < aiBrain.UpgradeIssuedLimit then

						if not unit.Dead then
                        
                            if StructureUpgradeDialog then
                            
                                --if bypassecon then
                                  --  LOG( body.." CAN BYPASS ECO NEEDED")
                                --end
                                
                                if ( econ.MassTrend >= MassTrendNeeded and econ.EnergyTrend >= EnergyTrendNeeded and econ.EnergyTrend >= EnergyMaintenance ) then
                                    LOG( body.." UPGRADING - M Trend "..string.format("%.1f",(econ.MassTrend * 10)).." needed "..string.format("%.1f",(MassTrendNeeded * 10)))
                                    LOG( body.." UPGRADING - E Trend "..string.format("%.1f",(econ.EnergyTrend * 10)).." needed "..string.format("%.1f",(EnergyTrendNeeded * 10)))
                                else
                                    LOG( body.." UPGRADING - M Stored "..string.format("%.1f",MassStorage).." needed "..string.format("%.1f",MassNeeded) )
                                    LOG( body.." UPGRADING - E Stored "..string.format("%.1f",EnergyStorage).." needed "..string.format("%.1f",EnergyNeeded))
                                end
                            end
					

							-- if an upgrade was issued and resources were not completely full then delay is based upon the condition of storage
                            -- moved the premise of the delay period from a fixed amount - to a period based on the buildtime of the upgrade

                            -- if either storage is below the mass or energy limit --
							if GetEconomyStoredRatio(aiBrain, 'MASS') < masslimit or GetEconomyStoredRatio(aiBrain, 'ENERGY') < energylimit then

                                if StructureUpgradeDialog then
                                    LOG( body.." is below storage limit - buildtime is "..buildtime )
                                end
                            
                                -- we'll use the MajorCheatModifier(66% of the full cheat) to reduce the longest delays
								ForkThread(SelfUpgradeDelay, aiBrain, unit, LOUDMIN(480, buildtime*.66)/aiBrain.MajorCheatModifier, body )  -- delay the next upgrade by upto 66% of the upgrade build time
                                
							else
                                -- if either storage is NOT full -- medium delay - unaffected by cheat
                                if GetEconomyStoredRatio(aiBrain, 'MASS') < 1 or GetEconomyStoredRatio(aiBrain, 'ENERGY') < 1 then

                                    if StructureUpgradeDialog then
                                        LOG( body.." storage not full - buildtime is "..buildtime )
                                    end
                                
                                    ForkThread(SelfUpgradeDelay, aiBrain, unit, LOUDMIN(300, buildtime*.33), body )   -- otherwise only 33% the delay period
                                    
                                else

                                    if StructureUpgradeDialog then
                                        LOG( body.." all storage is full - delay is 3 seconds")
                                    end
                                
                                    -- both storages are full -- tiny 3 second delay - no matter what
                                    -- this allows this new upgrade to affect the eco values before another executes
                                    ForkThread(SelfUpgradeDelay, aiBrain, unit, 30, body )
                                end
                            end

							upgradeIssued = true
        
                            if notify then
                                ForkThread( FloatingEntityText, unit.EntityID, "Upgrade to "..repr(upgradeID) )
                            end

							IssueUpgrade({unit}, upgradeID)

							if StructureUpgradeDialog then
								LOG( body.." UPGRADING TO "..repr(upgradeID).." "..repr(__blueprints[upgradeID].Description).." at game tick "..GetGameTick() )
							end

                            continue
                            
						end

                        if unit.Dead then
                            LOG( body.." to "..upgradeID.." failed.  Dead is "..repr(unit.Dead))
                            upgradeIssued = false
                        end

                    end
                    
                else
                    if StructureUpgradeDialog then
                        LOG( body.." can upgrade BUT fails base resources required check")
                    end
                end
                
            else
           
                if StructureUpgradeDialog then
                
                    if econ.MassTrend < MassTrendNeeded then
                        LOG( body.." FAILS Mass Trend needed "..string.format("%.1f",(MassTrendNeeded*10)).." current "..string.format("%.1f",(econ.MassTrend*10)) )
                        continue
                    end
                    
                    if econ.EnergyTrend < EnergyTrendNeeded then
                        LOG( body.." FAILS ENER Trend needed "..string.format("%.1f",(EnergyTrendNeeded*10)).." current "..string.format("%.1f",(econ.EnergyTrend*10)))
                        continue
                    end
                    
                    if econ.EnergyTrend < EnergyMaintenance then
                        LOG( body.." FAILS Maintenance trigger "..string.format("%.1f",econ.EnergyTrend).." needs "..string.format("%.1f",EnergyMaintenance))  
                        continue
                    end
                    
                    if MassStorage < MassNeeded then
                        LOG( body.." FAILS MASS storage trigger "..string.format("%.1f",MassStorage).." needed "..string.format("%.1f",MassNeeded))
                        continue
                    end
                    
                    if EnergyStorage < EnergyNeeded then
                        LOG( body" FAILS ENER storage trigger "..string.format("%.1f",EnergyStorage).." needed "..string.format("%.1f",EnergyNeeded))
                        continue
                    end
                end

			end

        else

            --if StructureUpgradeDialog then
              --  LOG( body.." counter "..aiBrain.UpgradeIssued.." limit "..aiBrain.UpgradeIssuedLimit )
            --end
	        
        end
        
    end

	if upgradeIssued then
        
		unit.Upgrading = true
		unit.DesiresAssist = true
       
        repeat 
            WaitTicks(2)
        until unit.UnitBeingBuilt.BlueprintID == upgradeID
        
        if EntityCategoryContains( categories.FACTORY, unit) and ScenarioInfo.DisplayFactoryBuilds then
            unit:SetCustomName("Upgrade to "..unit.UnitBeingBuilt.BlueprintID)
        end
    
        if StructureUpgradeDialog then    
            LOG( body.." confirms upgrade to "..repr(unit.UnitBeingBuilt.EntityID).." "..unit.UnitBeingBuilt.BlueprintID.." at game tick "..GetGameTick() )
		end
  
		local unitbeingbuilt = GetEntityById(unit.UnitBeingBuilt.EntityID)
                            
        if EntityCategoryContains( categories.MASSEXTRACTION, unit ) then
            ForkThread(MexUpgradesActive, aiBrain, unitbeingbuilt )
        end

        unitbeingbuilt:AddUnitCallback( unit.OnUpgradeComplete, 'OnStopBeingBuilt' )

        upgradeID = __blueprints[unitbeingbuilt.BlueprintID].General.UpgradesTo

        if __blueprints[upgradeID] then
    
            --if StructureUpgradeDialog then    
              --  LOG("*AI DEBUG "..aiBrain.Nickname.." STRUCTUREUpgrade "..unit.EntityID.." has follow on upgrade to "..repr(upgradeID) )
            --end
          
            
        end

        unit.UpgradeThread = nil

    end

end

-- SELF UPGRADE DELAY
-- the purpose of this function is to prevent self-upgradeable structures 
-- from all trying to upgrade at once - when an upgrade is begun - the
-- counter is increased by one -- for a period of time - in operation this prevents
-- more than a certain number of self-upgrades in a short time period
-- and the delays are related to the buildtime of the upgrade itself
function SelfUpgradeDelay( aiBrain, unit, delay, body )

    aiBrain.UpgradeIssued = aiBrain.UpgradeIssued + 1
    
    if ScenarioInfo.StructureUpgradeDialog then
        LOG( body.." counter up to "..aiBrain.UpgradeIssued.."/"..aiBrain.UpgradeIssuedLimit.." - delay period is "..(delay/10).." seconds on tick "..GetGameTick() )
    end
    
    local delayleft = delay

    local normaldelay = 11
    
    local saveddelay = 0
    
    local reduction = 0
    
    local mreduction, ereduction
    
    WaitTicks(11)
    
    delayleft = delayleft - 11
    
    while delayleft > 0 do
    
        reduction = 0
        ereduction = false
        mreduction = false
    
        if (GetEconomyStoredRatio( aiBrain, 'ENERGY') *100) > 75 then

            reduction = 1
            ereduction = true
            
        end
        
        if (GetEconomyStoredRatio( aiBrain, 'MASS') *100) > 67 then
        
            reduction = reduction + 1
            mreduction = true
            
        end
        
        if mreduction and ereduction then
        
            reduction = reduction + 1
            
        end
        
        if reduction > 0 then
            
            --if ScenarioInfo.StructureUpgradeDialog then
              --  LOG( body.." delay period reduced by "..reduction.." ticks ")
            --end

            saveddelay = saveddelay + reduction

        end

        WaitTicks( normaldelay )
        
        delayleft = delayleft - (10 + reduction)

    end

    aiBrain.UpgradeIssued = aiBrain.UpgradeIssued - 1
    
    if ScenarioInfo.StructureUpgradeDialog then
        LOG( body.." counter down to "..aiBrain.UpgradeIssued.."/"..aiBrain.UpgradeIssuedLimit.." saved "..saveddelay.." ticks on tick "..GetGameTick() )
    end
end

-- Limit the amount of simultaneous mex upgrades that can be active
function MexUpgradesActive( aiBrain, unit )

    aiBrain.MexUpgradeActive = aiBrain.MexUpgradeActive + 1

    if ScenarioInfo.StructureUpgradeDialog then
        LOG("*AI DEBUG "..aiBrain.Nickname.." STRUCTUREUpgrade "..unit.EntityID.." mex upgrading up to "..aiBrain.MexUpgradeActive.."/"..aiBrain.MexUpgradeLimit)
    end

    repeat
        WaitTicks(20)
    until moho.entity_methods.GetFractionComplete(unit) == 1 

    aiBrain.MexUpgradeActive = aiBrain.MexUpgradeActive - 1

    if ScenarioInfo.StructureUpgradeDialog then
        LOG("*AI DEBUG "..aiBrain.Nickname.." STRUCTUREUpgrade "..unit.EntityID.." mex upgrading down to "..aiBrain.MexUpgradeActive.."/"..aiBrain.MexUpgradeLimit)
    end
end

-- this function identifies units in a platoon that may have air/land toggle weapons
-- launches the airlandtogglethread on those units - you know - it would be nice if 
-- such units had that thread launched at build rather than as a platoon function
function AirLandToggle(platoon, aiBrain)

    for k,v in GetPlatoonUnits(platoon) do
	
		local weapons = v:GetBlueprint().Weapon
		
		for _,w in weapons do
			if w.ToggleWeapon then
				for n,wType in w.FireTargetLayerCapsTable do
				
					if string.find( wType, 'Air' ) then
						if (not v.Dead) and not v.AirLandToggleThread then
							v.AirLandToggleThread = v:ForkThread( AirLandToggleThread, aiBrain )
							break
						end
					end
				end
			end
		end
    end		
end

-- this function is quite simple - in concept - utilize the weapon toggle that some units have
-- which allow it to shoot both at AIR units and LAND/NAVAL units
function AirLandToggleThread(unit, aiBrain)
	
    local GetNumUnitsAroundPoint = GetNumUnitsAroundPoint
    local WaitTicks = WaitTicks
	
    local bp = __blueprints[unit.BlueprintID]
    
    local weapons = bp.Weapon
    local antiAirRange, landRange, weaponType
	
    local toggleWeapons = {}
    local unitCat = ParseEntityCategory( unit.BlueprintID )
	
    for _,v in weapons do
        if v.ToggleWeapon then
            weaponType = 'Land'
            for n,wType in v.FireTargetLayerCapsTable do
                if string.find( wType, 'Air' ) then
                    weaponType = 'Air'
                    break
                end
            end
            if weaponType == 'Land' then
                landRange = v.MaxRadius
            else
                antiAirRange = v.MaxRadius
            end
        end
    end
	
    if not landRange or not antiAirRange then
        return
    end
	
    while not unit.Dead and IsUnitState( unit, 'Busy') do
        WaitTicks(22)
    end
	
	local position, numAir, numGround, frndAir, frnGround
	local GetPosition = GetPosition
	
    while not unit.Dead do
	
        position = GetPosition(unit)
		
        numAir = GetNumUnitsAroundPoint( aiBrain, ( categories.AIR ), position, antiAirRange, 'Enemy' )
        numGround = GetNumUnitsAroundPoint( aiBrain, ( categories.ALLUNITS - categories.AIR - categories.WALL ), position, landRange, 'Enemy' )
		
        frndAir = GetNumUnitsAroundPoint( aiBrain, ( categories.AIR * categories.ANTIAIR ), position, antiAirRange, 'Ally' )
        frndGround = GetNumUnitsAroundPoint( aiBrain, ( categories.LAND + categories.NAVAL) - unitCat, position, landRange, 'Ally' )
		
        if numAir > 5 and frndAir < 3 then
		
            unit:SetScriptBit('RULEUTC_WeaponToggle', false)	#-- air mode
			
        elseif numGround > ( numAir * 1.5 ) then
		
            unit:SetScriptBit('RULEUTC_WeaponToggle', true)		#-- ground mode
			
        elseif frndAir > frndGround then
		
            unit:SetScriptBit('RULEUTC_WeaponToggle', true)
			
        else
		
            unit:SetScriptBit('RULEUTC_WeaponToggle', false) # default to air mode
			
        end
		
        WaitTicks(100)
    end
end


--	Table: SurfacePriorities AKA "Your stuff just got wrecked" priority list.
--	Provides a list of target priorities an experimental should use when
--	wrecking stuff or deciding what stuff should be wrecked next.
local SurfacePriorities = { 
	'STRUCTURE ARTILLERY -TECH2',

	'MASSEXTRACTION -TECH2',
	
	'MASSFABRICATION -TECH2',

	'STRUCTURE INTELLIGENCE -TECH1',

	'ANTIMISSILE -TECH2',

	'STRUCTURE NUKE',

	'MOBILE LAND EXPERIMENTAL',

	'SHIELD',

	'DEFENSE STRUCTURE ANTIAIR TECH3',
	'DEFENSE STRUCTURE DIRECTFIRE TECH3',
	
	'FACTORY STRUCTURE -TECH1',

	'STRUCTURE ANTINAVY',
	
	'EXPERIMENTAL STRUCTURE',
	
    'ENERGYPRODUCTION STRUCTURE TECH3',
	
	'MOBILE LAND TECH3',	
	
    'COMMAND',
	'SUBCOMMANDER',

}


function AssignArtilleryPriorities( platoon )
	
	for _,v in GetPlatoonUnits(platoon) do
		if v != nil then
			v:SetTargetPriorities( SurfacePriorities )
		end
	end
end

-- Using it's PrioritizeCategories list, loop thru the HiPri list looking for the target
-- with the most number of targets.
-- Returns:  target unit, target base, else nil
function FindExperimentalTarget( self, aiBrain )
   
    if not aiBrain.IL or not aiBrain.IL.HiPri then
		LOG("*AI DEBUG FindExperimentalTarget says it has no interest list")
        return
    end
	
	local GetUnitsAroundPoint = GetUnitsAroundPoint

    local enemyBases = aiBrain.IL.HiPri	

	local SurfacePriorities = self.PlatoonData.PrioritizedCategories
   
    --	For each priority type in SurfacePriorities, check each HiPri position we're aware of (through scouting/intel),
    --	The position with the most number of the targets gets selected. If there's a tie, pick closer. 
	-- this has been changed to locate the closest first --
    for _, priority in SurfacePriorities do
		
        local bestBase = false
        local mostUnits = 0
        local bestUnit = false
        
        for _, base in enemyBases do
		
			--LOG("*AI DEBUG "..aiBrain.Nickname.." FindExperimentalTarget checks threat position at ".. repr(base))
			
			local unitsAtBase = false
			
            local unitsAtBase = GetUnitsAroundPoint( aiBrain, ParseEntityCategory(priority), base.Position, 100, 'Enemy')
			
            local numUnitsAtBase = 0
            local notDeadUnit = false
            
			if unitsAtBase[1] then
			
				--LOG("*AI DEBUG "..aiBrain.Nickname.." FindExperimentalTarget finds "..LOUDGETN(unitsAtBase).." "..repr(priority).." units at "..repr(base.Position) )

				for _,unit in unitsAtBase do
				
					if not unit.Dead and GetPosition(unit) then
					
						notDeadUnit = unit
						numUnitsAtBase = numUnitsAtBase + 1
						
					end
					
				end
            
				WaitTicks(1)
            
				if numUnitsAtBase > 0 then
				
					if not bestBase then
					
						bestBase = base
						bestUnit = notDeadUnit
						
					else
	
						local myPos = GetPlatoonPosition(self)
						
						local dist1 = VDist3( myPos, base.Position )
						local dist2 = VDist3( myPos, bestBase.Position )
                    
						if dist1 < dist2 then
						
							bestBase = base
							bestUnit = notDeadUnit
							
						end
						
					end	

--[[					
					if numUnitsAtBase > mostUnits then
					
						bestBase = base
						mostUnits = numUnitsAtBase
						bestUnit = notDeadUnit
						
					elseif numUnitsAtBase == mostUnits then
					
						local myPos = GetPlatoonPosition(self)
						local dist1 = VDist3( myPos, base.Position )
						local dist2 = VDist3( myPos, bestBase.Position )
                    
						if dist1 < dist2 then
							bestBase = base
							bestUnit = notDeadUnit
						end
						
					end
--]]					
				end
				
			else
				--LOG("*AI DEBUG FindExperimentalTarget finds no units for "..repr(priority).." at "..repr(base.Position))
			end
			
        end
        
        if bestBase and bestUnit then
		
			--LOG("*AI DEBUG "..aiBrain.Nickname.." FindExperimentalTarget returns a "..repr(priority).." target unit at " ..repr(bestBase))
			
            return bestUnit, bestBase
			
        end
		
    end
	
	--LOG("*AI DEBUG "..aiBrain.Nickname.." FindExperimentalTarget returns NO target")
	
	return false, false
	
end

function GetThreatOfUnits(platoon)
    local totalThreat = 0
    local bpThreat = 0
    local layer = platoon.MovementLayer
	local bp
	
    for _,u in GetPlatoonUnits(platoon) do
	
		bpThreat = 0
		
        if not u.Dead then 
		
	        bp = __blueprints[u.BlueprintID].Defense
			
            if layer == 'Land' then
                bpThreat = bp.SurfaceThreatLevel
            elseif layer == 'Water' then
                bpThreat = bp.SurfaceThreatLevel
				if bp.SubThreatLevel then
					bpThreat = bpThreat + bp.SubThreatLevel
				end
            elseif layer == 'Amphibious' then
                bpThreat = bp.SurfaceThreatLevel
				if bp.SubThreatLevel then
					bpThreat = bpThreat + bp.SubThreatLevel
				end
            elseif layer == 'Air' then
                bpThreat = bp.SurfaceThreatLevel
                if bp.AirThreatLevel then
                    bpThreat = bpThreat + bp.AirThreatLevel
                end
				if bp.SubThreatLevel then
					bpThreat = bpThreat + bp.SubThreatLevel
				end
            end
			
			totalThreat = totalThreat + bpThreat
			
        end 
		
    end
	
	LOG("*AI DEBUG Platoon Threat for "..repr(platoon.BuilderName).." on layer "..repr(layer))
	LOG("*AI DEBUG  AIR        is "..repr(platoon:CalculatePlatoonThreat('Air', categories.ALLUNITS)).." versus "..totalThreat)
	LOG("*AI DEBUG ANTIAIR     is "..repr(platoon:CalculatePlatoonThreat('AntiAir', categories.ALLUNITS)).." versus "..totalThreat)
	LOG("*AI DEBUG Artillery   is "..repr(platoon:CalculatePlatoonThreat('Air', categories.ALLUNITS)).." versus "..totalThreat)	
	LOG("*AI DEBUG  LAND       is "..repr(platoon:CalculatePlatoonThreat('Land', categories.ALLUNITS)).." versus "..totalThreat)
	LOG("*AI DEBUG  NAVAL      is "..repr(platoon:CalculatePlatoonThreat('Naval', categories.ALLUNITS)).." versus "..totalThreat)
	LOG("*AI DEBUG SURFACE     is "..repr(platoon:CalculatePlatoonThreat('AntiSurface', categories.ALLUNITS)).." versus "..totalThreat)
	LOG("*AI DEBUG OVERALL IS     "..repr(platoon:CalculatePlatoonThreat('Overall', categories.ALLUNITS)).." versus "..totalThreat)
	
    return totalThreat
	
end

--	Goes through the SurfacePriorities table looking for the enemy base (high priority scouting location. See ScoutingAI in platoon.lua) 
--	with the most number of the highest priority targets.
--	Returns:  target unit, target base, else nil
-- THIS FUNCTION APPEARS TO BE USED ONLY BY THE FATBOY AI
function FindLandExperimentalTargetLOUD( self, aiBrain )

    local enemyBases = aiBrain.IL.HiPri
	
	local mapSizeX = ScenarioInfo.size[1]
	local mapSizeZ = ScenarioInfo.size[2]
	
	local mapsize = LOUDSQUARE( (mapSizeX * mapSizeX) + (mapSizeZ * mapSizeZ) )  # maximum possible distance on this map
	
	local myPos = self:GetPlatoonPosition()
	
	local enemythreattype = 'AntiSurface'	
	
	if self.MovementLayer == 'Air' then
		enemythreattype = 'AntiAir'
	end
	
	local mythreat = GetThreatOfUnits(self)
	
    local bestBase = false
    local bestTotal = 0
    local bestUnit = false
   
    if not aiBrain.IL or not aiBrain.IL.HiPri then
		LOG("*AI DEBUG FindExperimentalTarget says it has no interest list")
        return
    end
    
	for _, base in enemyBases do
	
		-- check if position is on the water - skip 
		if LocationInWaterCheck(base.Position) and self.MovementLayer != 'Air' then
			continue
		end
	
		local distance = VDist3( { self.StartPosX, 0, self.StartPosZ }, base.Position )
		local RangeModifier = mapsize/distance
		
		local numUnitsAtBase = 0
		
		local surfacethreat = 0
		local airthreat = 0
		
		local targetthreat = 0
		local threatfactor = 0
		
		local notDeadUnit = false
		
		local unitsAtBase = aiBrain:GetUnitsAroundPoint( categories.ALLUNITS, base.Position, 70, 'Enemy')
		
        for _, priority in SurfacePriorities do
            
            for _,unit in EntityCategoryFilterDown( ParseEntityCategory(priority), unitsAtBase) do
			
                if not unit.Dead and GetPosition(unit) then
	                notDeadUnit = unit
					break
	            end
            end
			
			numUnitsAtBase = EntityCategoryCount( ParseEntityCategory(priority), unitsAtBase )
		end
		
		targetthreat = 0
		
		if self.MovementLayer == 'Air' then
			targetthreat = base.AirThreat
		else
			targetthreat = base.SurThreat
		end
		
		if targetthreat > 1 then
			threatfactor = mythreat/targetthreat
		else
			threatfactor = 10
		end
		
		if threatfactor < 1 then
			threatfactor = threatfactor * 0.5
		elseif threatfactor > 10 then
			threatfactor = 10
		end
		
		if numUnitsAtBase > 10 then
			numUnitsAtBase = 10
		end
		
		numUnitsAtBase = (numUnitsAtBase * threatfactor) * RangeModifier
		
		LOG("*AI DEBUG Resulting in a value for target of " .. numUnitsAtBase)

        if numUnitsAtBase > bestTotal then
            bestBase = base
            bestTotal = numUnitsAtBase
            bestUnit = notDeadUnit
        end
		
	end

    if bestBase and bestUnit then
        return bestUnit, bestBase
    end
	
	return false, false
	
end


-- =======================
-- CZAR Behaviour - SORIAN
-- =======================
CzarBehaviorSorian = function(self, aiBrain)
	
    if not PlatoonExists( aiBrain, self ) then
        return
    end
	
	LOG("*AI DEBUG "..aiBrain.Nickname.." CzarSorian starts")

	local platoonUnits = GetPlatoonUnits(self)
    
    for _, czar in platoonUnits do
        czar.EventCallbacks['OnHealthChanged'] = nil
    end
	
	local cmd
    
	-- find a target from the PrioritizedCategories data
    local targetUnit = FindExperimentalTarget( self, aiBrain )
	
    local oldTargetUnit = false
	
    while PlatoonExists( aiBrain, self ) do
	
		if not targetUnit then
		
			return self:SetAIPlan('ReturnToBaseAI',aiBrain)
			
		end
		
        if (targetUnit and targetUnit != oldTargetUnit) or not self:IsCommandsActive(cmd) then

			-- move towards the target --
			if targetUnit and VDist3( GetPosition(targetUnit), GetPlatoonPosition(self) ) > 100 then
			
			    IssueClearCommands(platoonUnits)
				
				-- interesting way to get the Czar moving towards target --
				cmd = ExpPathToLocation(aiBrain, self, 'Air', GetPosition(targetUnit), false, 300)
				
			-- in range of the target, issue attack order --
			elseif targetUnit and VDist3( GetPosition(targetUnit), GetPlatoonPosition(self) ) <= 100 then

                cmd = self:AttackTarget( targetUnit )
				
			end
			
        end
		
		-- see if you're near any override target
        local nearCommander = CommanderOverrideCheckSorian(self,aiBrain)
		
        local oldCommander = nil
		
		-- loop here if we have an override target until we don't have an override target anymore
        while nearCommander and PlatoonExists( aiBrain, self ) and self:IsCommandsActive(cmd) do
		
            if nearCommander and nearCommander != oldCommander then
			
                IssueClearCommands(platoonUnits)
				
                cmd = self:AttackTarget( nearCommander)
				
                targetUnit = nearCommander
				
            end
            
            WaitSeconds(8)
			
            oldCommander = nearCommander
			
			-- see if there is a better override target attack
            nearCommander = CommanderOverrideCheckSorian(self,aiBrain)
			
        end
    
		WaitTicks(80)
		
		-- only switch targets when they are dead
		if targetUnit.Dead then

			oldTargetUnit = targetUnit
		
			targetUnit = FindExperimentalTarget(self, aiBrain)
			
		end
		
	end
	
end

CommanderOverrideCheckSorian = function(self, aiBrain)

	local platoonUnits = GetPlatoonUnits(self)
    local experimental
	
	-- identify if we have an experimental or not
	for k,v in platoonUnits do
	
		if not v:IsDead() then
		
			experimental = v
			break
			
		end
		
	end
	
	if not experimental or experimental:IsDead() then
		return false
	end

    local commanders = aiBrain:GetUnitsAroundPoint(categories.COMMAND, GetPlatoonPosition(self), 50, 'Enemy')
    
    if LOUDGETN(commanders) == 0 or commanders[1]:IsDead() or commanders[1]:GetCurrentLayer() == 'Seabed' then
	
		#LOG("*AI DEBUG CommanderOverride reports no commanders found within weapon range")
        return false
    end
    
    local mainWeapon = experimental:GetWeapon(1)
    local currentTarget = mainWeapon:GetCurrentTarget()
    
    if commanders[1] ~= currentTarget then
	
		LOG("*AI DEBUG CommanderOverride resetting main weapon to retarget commander")
		
        --Commander in range who isn't our current target. Force weapons to reacquire targets so they'll grab him.
		for k,v in platoonUnits do
		
			if not v:IsDead() then
			
				for i=1, v:GetWeaponCount() do
				
					v:GetWeapon(i):ResetTarget()
					
				end
				
			end
			
		end
		
    end
    
    -- return the commander so an attack order can be issued or something
    return commanders[1]
end

-- Credit to Sorian - very concise way to handle platoon movement orders
ExpPathToLocation = function(aiBrain, platoon, layer, dest, aggro, markerdist)

	local cmd = false

	local path, reason = platoon.PlatoonGenerateSafePathToLOUD(aiBrain, platoon, layer, GetPlatoonPosition(platoon), dest, 150, markerdist )
	
	if not path then
	
		if aggro == 'AttackMove' then
		
			cmd = platoon:AggressiveMoveToLocation(dest)
			
		elseif aggro == 'AttackDest' then
		
			-- Let the main script issue the move to attack the target
			
		else
		
			cmd = platoon:MoveToLocation(dest, false)
			
		end
		
	else
	
		local pathSize = LOUDGETN(path)
		
		for k, point in path do
		
			if k == pathSize and aggro == 'AttackDest' then
			
				-- Let the main script issue the move to attack the target
				
			elseif aggro == 'AttackMove' then
			
				cmd = platoon:AggressiveMoveToLocation(point)
				
			else
			
				cmd = platoon:MoveToLocation(point, false)
				
			end
			
		end 
		
	end
	
	return cmd
end


function CheckBlockingTerrain( pos, targetPos )

    local GetTerrainHeight = GetTerrainHeight	

	-- This gives us the approx number of 8 ogrid steps in the distance
	local steps = LOUDFLOOR( VDist2(pos[1], pos[3], targetPos[1], targetPos[3]) / 8 ) + 1
	
	local xstep = (pos[1] - targetPos[1]) / steps -- how much the X value will change from step to step
	local ystep = (pos[3] - targetPos[3]) / steps -- how much the Y value will change from step to step

	local lastpos = {pos[1], 0, pos[3]}
    local lastposHeight = GetTerrainHeight( lastpos[1], lastpos[3] )

    local nextpos = { 0, 0, 0 }
	
	-- Iterate thru the number of steps - starting at the pos and adding xstep and ystep to each point
	for i = 1, steps do
		
        nextpos[1] = pos[1] - (xstep * i)
        nextpos[3] = pos[3] - (ystep * i)
			
        nextposHeight = GetTerrainHeight( nextpos[1], nextpos[3] )

		-- if more than 3.6 ogrids change in height over 8 ogrids distance
		if LOUDABS(lastposHeight - nextposHeight) > 3.6 then

            return true
		end

        lastpos[1] = nextpos[1]
        lastpos[3] = nextpos[3]
        lastposHeight = nextposHeight

	end
	
    return false
end


-- returns true if the platoon is presently in the water
function InWaterCheck(platoon)

	local t4Pos = GetPlatoonPosition(platoon)
	
	return GetTerrainHeight(t4Pos[1], t4Pos[3]) < GetSurfaceHeight(t4Pos[1], t4Pos[3])
end

-- returns true if the position is in the water
function LocationInWaterCheck(position)
	return GetTerrainHeight(position[1], position[3]) < GetSurfaceHeight(position[1], position[3])
end


--	Finds the experiemental unit in the platoon (assumes platoons are only experimentals)
--	Assigns any extra experimentals to guard the first
function GetExperimentalUnit( platoon )

    local unit = nil
	
    for _,v in GetPlatoonUnits(platoon) do
	
		if (not v.Dead) and unit then
		
			IssueGuard( {v}, unit )
			
		end
		
        if (not v.Dead) and not unit then
		
            unit = v
			
        end
		
    end
	
    return unit
	
end

-- Sets the experimental's land weapon target priorities to the SurfacePriorities table.
function AssignExperimentalPriorities( platoon )
	local experimental = GetExperimentalUnit(platoon)
	if experimental then
    	experimental:SetTargetPriorities( SurfacePriorities )
	end
end

-- Generic experimental AI. Find closest HiPriTarget and go attack it. 
function BehemothBehavior(self)   

    local aiBrain = GetAIBrain(self)
    local experimental = GetExperimentalUnit(self)
	
	local markerlist = false
	local patrolling = false
	
	LOG("*AI DEBUG Behemoth Behavior starts")
	
    #AssignExperimentalPriorities(self)
	
	local targetlist = GetHiPriTargetList(aiBrain, experimental:GetPosition() )
	local target = false
	local targetLocation = false
    local oldTargetLocation = false
	local targetvalue = 9999999
	
	LOUDSORT(targetlist, function(a,b) return a.Distance < b.Distance end )

	for _, Target in targetlist do
	
		if LocationInWaterCheck(Target.Position) then
			continue # skip water targets
		end

		local distancefactor = aiBrain.dist_comp/Target.Distance   # makes closer targets more valuable
		
		local sthreat = Target.Threats.Sur
		local ethreat = Target.Threats.Eco
		local mythreat = GetThreatOfUnits(self)
		
		if sthreat > mythreat then
			sthreat = mythreat
		end
		if ethreat > mythreat then
			ethreat = mythreat
		end
		
		local allthreat = sthreat + ethreat
		
		local value = LOUDFLOOR( allthreat * distancefactor ) 
		
		if value < targetvalue and value > 0 then
			target = Target
			targetvalue = value
			targetLocation = Target.Position
		end
	end

    while not experimental.Dead do

        if (targetLocation) and experimental:GetHealthPercent() > .75 then
		
            IssueClearCommands({experimental})
			
			local path, reason = self.PlatoonGenerateSafePathToLOUD(aiBrain, self, 'Amphibious', GetPlatoonPosition(self), targetLocation, 150, 200)

			if path then
				local pathsize = LOUDGETN(path)
				
				for waypoint,p in path do
					if LocationInWaterCheck(p) then
						self:MoveToLocation( p, false )
					else
						self:AggressiveMoveToLocation( p )
					end
				end
			else
				self:AggressiveMoveToLocation( targetLocation )
			end
			
            IssueAggressiveMove({experimental}, targetLocation) 
			patrolling = false
			
			while VDist3( experimental:GetPosition(), targetLocation ) > 10 and (not experimental.Dead) and experimental:GetHealthPercent() > .42 do
				WaitTicks(20)
				pos = experimental:GetPosition()
			end
			
            while (not experimental.Dead) and experimental:GetHealthPercent() > .42 and WreckBase( self, target ) and not InWaterCheck(self) do
				LOG("*AI DEBUG Behemoth cleansing target area")
				WaitTicks(20)
            end
		
        elseif (not targetLocation) or experimental:GetHealthPercent() <= .75 then

			if not patrolling then
				IssueClearCommands({experimental})
				self:ForkThread( self.PlatoonPatrolPointAI, aiBrain )
				patrolling = true
				targetLocation = nil
			end
		
			while experimental:GetHealthPercent() <= .85 and not experimental.Dead do
				WaitTicks(150)
			end
		end
       
        WaitTicks(50)
		
        oldTargetLocation = targetLocation
		
		targetlist = GetHiPriTargetList(aiBrain, experimental:GetPosition() )
		target = false
		targetLocation = false
		targetvalue = 9999999
	
		LOUDSORT(targetlist, function(a,b) return a.Distance < b.Distance end )

		for _, Target in targetlist do
	
			if LocationInWaterCheck(Target.Position) and self.MovementLayer != 'Air' then
				continue # skip water targets
			end

			distancefactor = aiBrain.dist_comp/Target.Distance   # makes closer targets more valuable
		
			allthreat = Target.Threats.Sur + Target.Threats.Eco
		
			value = LOUDFLOOR( allthreat * distancefactor ) 
		
			if value < targetvalue and value > 0 then
				target = Target
				targetvalue = value
				targetLocation = Target.Position
			end
		end		
		
		if not targetLocation then
			LOG("*AI DEBUG Behemoth - no target")
		end
    end
end
--]]


--[[
--	Goes through the SurfacePriorities table looking for the enemy base (high priority scouting location. See ScoutingAI in platoon.lua) 
--	with the most number of the highest priority targets.
--	Returns:  target unit, target base, else nil
function FindNavalExperimentalTargetLOUD( self )

    local aiBrain = GetAIBrain(self)
    local enemyBases = aiBrain.IL.HiPri
	
	local mapSizeX = ScenarioInfo.size[1]
	local mapSizeZ = ScenarioInfo.size[2]
	local mapsize = LOUDSQUARE( (mapSizeX * mapSizeX) + (mapSizeZ * mapSizeZ) )  # maximum possible distance on this map
	local myPos = self:GetPlatoonPosition()
	
	local enemythreattype = 'AntiSurface'	
	
	if self.MovementLayer == 'Air' then
		enemythreattype = 'AntiAir'
	end
	
	local mythreat = GetThreatOfUnits(self)
	
    local bestBase = false
    local bestTotal = 0
    local bestUnit = false
   
    if not aiBrain.IL or not aiBrain.IL.HiPri then
		LOG("*AI DEBUG FindNavalExperimentalTarget says it has no interest list")
        return
    end
    
	for _, base in enemyBases do
	
		if not LocationInWaterCheck(base.Position) then
			continue #break
		end
	
		local distance = VDist3( myPos, base.Position )
		local RangeModifier = math.log10( mapsize/distance)
		
		local numUnitsAtBase = 0
		
		local surfacethreat = 0
		local airthreat = 0
		
		local targetthreat = 0
		local threatfactor = 0
		
		local notDeadUnit = false
		
        for _, priority in SurfacePriorities do

            local unitsAtBase = aiBrain:GetUnitsAroundPoint( ParseEntityCategory(priority), base.Position, 60, 'Enemy')
            
            for _,unit in unitsAtBase do
                if not unit.Dead and unit:GetPosition() then
                    notDeadUnit = unit
					numUnitsAtBase = numUnitsAtBase + 1
                end
            end
		end
		
		targetthreat = 0
		
		if self.MovementLayer == 'Air' then
			targetthreat = base.AirThreat
		else
			targetthreat = base.SurThreat
		end
		
		if targetthreat > 1 then
			threatfactor = mythreat/targetthreat
		else
			threatfactor = 10
		end
		
		if threatfactor < .1 then
			threatfactor = .1
		elseif threatfactor > 10 then
			threatfactor = 10
		end
		
		if numUnitsAtBase > 10 then
			numUnitsAtBase = 10
		end
		
		numUnitsAtBase = (numUnitsAtBase * threatfactor) * RangeModifier

        if numUnitsAtBase > bestTotal then
            bestBase = base
            bestTotal = numUnitsAtBase
            bestUnit = notDeadUnit
        end
	end

    if bestBase and bestUnit then
        return bestUnit, bestBase
    end
	
	return false, false
	
end

function FatBoyBehavior(self, aiBrain)   

    local experimental = GetExperimentalUnit(self)
    local lastBase = false
    local mainWeapon = experimental:GetWeapon(1)
	local markerlist = false
	local oldTargetLocation = nil
	local patrolling = false
    local targetUnit = false
	local wavesize = 20
    local weaponRange = mainWeapon:GetBlueprint().MaxRadius
	
    --AssignExperimentalPriorities(self)
    
    experimental.Platoons = experimental.Platoons or {}
    
    while not experimental.Dead do
	
		-- first task is to find a target
        targetUnit, lastBase = FindLandExperimentalTargetLOUD(self, aiBrain)

		if targetUnit and experimental:GetHealthPercent() >= .75 then
			
			IssueClearCommands({experimental})
			patrolling = false
			oldTargetLocation = {lastBase.Position[1], lastBase.Position[2], lastBase.Position[3]}

			local path, reason = self.PlatoonGenerateSafePathToLOUD(aiBrain, self, 'Amphibious', self:GetPlatoonPosition(), oldTargetLocation, 120, 200)
			
			if path then
				local pathsize = LOUDGETN(path)
				
				for waypoint,p in path do
					if LocationInWaterCheck(p) then
						self:MoveToLocation( p, false )
					else
						self:AggressiveMoveToLocation( p )
					end
				end

			else
				self:AggressiveMoveToLocation( oldTargetLocation )
			end
			
			local pos = experimental:GetPosition()

			-- and travel to the target area
            while VDist3( pos, oldTargetLocation ) > weaponRange + 45 and not experimental.Dead	and not experimental:IsIdleState() and experimental:GetHealthPercent() > .5 do
				WaitTicks(50)
				pos = experimental:GetPosition()
            end
			
			while not experimental:IsIdleState() and ( WreckBase(self, lastBase) == nil )
				and not experimental.Dead and experimental:GetHealthPercent() > .5
				or InWaterCheck(self) do
				LOG("*AI DEBUG Fatboy finds no target or is in the water - will keep moving")
				WaitTicks(50)
			end

			
			LOG("*AI DEBUG FatBoy in range of target")
			
            IssueClearCommands({experimental})
            
			# ================================
			# Rebuild list of Fatboys platoons
			# ================================
            local goodList = {}
            
            for _, platoon in experimental.Platoons do
                local platoonUnits = false
                
                if PlatoonExists( aiBrain, platoon ) then
                    platoonUnits = GetPlatoonUnits(platoon)
				end
                if platoonUnits and LOUDGETN(platoonUnits) > 0 then
                    LOUDINSERT(goodList, platoon)
                end
            end
            experimental.Platoons = goodList
			
			# =====================
            # Attack Fatboys target
			# =====================
            for _, platoon in goodList do
                platoon:ForkAIThread(FatboyChildBehavior, self, lastBase)
            end
            # ===========================
            # Build a platoon of 20 units
			# ===========================
            while not experimental.Dead and experimental:GetHealthPercent() > .5 and WreckBase(self, lastBase) and not InWaterCheck(self) do
			
                FatBoyBuildCheck(self)
				
                if experimental.NewPlatoon and LOUDGETN(experimental.NewPlatoon:GetPlatoonUnits()) >= wavesize then
					#LOG("*AI DEBUG Launching Fatboy platoon at target")
                    experimental.NewPlatoon:ForkAIThread(FatboyChildBehavior, self, lastBase)
                    LOUDINSERT(experimental.Platoons, experimental.NewPlatoon)
                    experimental.NewPlatoon = nil
					wavesize = wavesize + 2
                end
                WaitTicks(10)
            end
			
			targetUnit, lastBase = FindLandExperimentalTargetLOUD(self, aiBrain)
			
			if experimental:GetHealthPercent() <= .5 then
				for _, platoon in experimental.Platoons do
					platoon:SetAIPlan( 'ReturnToBaseAI',aiBrain )
				end
				experimental.Platoons = {}
			end
			
        else
			if not patrolling then
				IssueClearCommands({experimental})
				self:ForkThread( self.PlatoonPatrolPointAI, aiBrain )
				patrolling = true
				
				if experimental.NewPlatoon then
					experimental.NewPlatoon:SetAIPlan( 'ReturnToBaseAI', aiBrain )
				end
				
				for _, platoon in experimental.Platoons do
					platoon:SetAIPlan( 'ReturnToBaseAI',aiBrain )
				end
				experimental.Platoons = {}
				
			end
			while experimental:GetHealthPercent() <= .85 and not experimental.Dead do
				WaitTicks(150)
			end
		end
	
        WaitTicks(60)
    end
	
end

-------------------------------------------------------
--   Function: FatBoyBuildCheck
--   Args:
--       self - single-fatboy platoon to build a unit with
--   Description:
--       Builds a random unit
--   Returns:  
--       nil
-------------------------------------------------------
function FatBoyBuildCheck(self)
    local aiBrain = GetAIBrain(self)
    local experimental = GetExperimentalUnit(self)
	local buildUnits = {}
    
    #Randomly build T3 MMLs, percivals, T3 Arty, T2 Shields and siege bots .
    
	if LOUDENTITY( categories.UEF, experimental) then
		buildUnits = {'uel0303', 'uel0307', 'uel0304', 'xel0305', 'xel0306', 'delk002', }
	end
	
	local buildx = Random(1,LOUDGETN(buildUnits))
	local unitToBuild = buildUnits[buildx]
	
	if LOUDENTITY( categories.UEF, experimental) then
	    aiBrain:BuildUnit( experimental, unitToBuild, 1 )
	end
	
    WaitTicks(1)
    
    local unitBeingBuilt = false
	
    repeat 
		LOG("*AI DEBUG FatBoyBuildCheck Wait loop")
        unitBeingBuilt = unitBeingBuilt or experimental.UnitBeingBuilt
        WaitTicks(25)
    until experimental.Dead or unitBeingBuilt 
    
    repeat
        WaitTicks(35)
    until experimental.Dead or experimental:IsIdleState() 
    
    if unitBeingBuilt and not unitBeingBuilt.Dead then
		#LOG("*AI DEBUG FatBoyBuildCheck assigning new unit to platoon")
        
        if not experimental.NewPlatoon or not PlatoonExists( aiBrain, experimental.NewPlatoon ) then
            LOG("*AI DEBUG FatBoyBuildCheck creating new platoon")
            experimental.NewPlatoon = MakePlatoon( aiBrain, 'FatBoyGroup', 'none' )
			experimental.NewPlatoon.BuilderName = 'FatBoyGroup'
        end
        
        AssignUnitsToPlatoon( aiBrain, experimental.NewPlatoon, {unitBeingBuilt}, 'Attack', 'None' )
        IssueClearCommands( {unitBeingBuilt})
--      IssueGuard( {unitBeingBuilt}, experimental)
    end
	
end

-------------------------------------------------------
--   Function: FatboyChildBehavior
--   Args:
--       self - the platoon of fatboy children to run the behavior on
--       parent - the parent fatboy that the child platoon belongs to
--       base - the base to be attacked
--   Description:
--       AI for fatboy child platoons. Wrecks the base that the fatboy has selected.
--       Once the base is wrecked, the units will return to the fatboy until a new
--       target base is reached, at which point they will attack it.
--   Returns:  
--       nil
-------------------------------------------------------
function FatboyChildBehavior(self, parent, base)   
		local aiBrain = GetAIBrain(self)
		local experimental = GetExperimentalUnit(parent)
		local targetUnit = false
     
    #Find target loop
	
    while PlatoonExists( aiBrain, self ) and LOUDGETN( GetPlatoonUnits(self) ) > 0 do

        targetUnit, base = WreckBase( parent, base)
        
        local units = GetPlatoonUnits(self)

        if not base and not experimental.Dead then
            #Wrecked base. Kill AI thread
            IssueClearCommands(units)
            if VDist3(self:GetPlatoonPosition(), experimental:GetPosition()) > 30 then
                self:SetPlatoonFormationOverride('GrowthFormation')
                IssueMove( GetPlatoonUnits(self), experimental:GetPosition() )
--            IssueGuard(units, experimental)
            end
            
            return
            
        elseif not base and experimental.Dead then
			IssueClearCommands(units)
			return self:ReturnToBaseAI(aiBrain)
            
		end
        
        if targetUnit then
            IssueClearCommands(units)
            IssueFormAggressiveMove(units, targetUnit, 'AttackFormation', 0)
        end
        
        #Walk to and kill target loop
        while aiBrain:PlatoonExists(self) and LOUDGETN(self:GetPlatoonUnits()) > 0 and not targetUnit.Dead do           
            WaitTicks(50)
        end
    
        WaitTicks(50)
    end
end

--]]