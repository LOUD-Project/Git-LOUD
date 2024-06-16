---  File     :  /lua/AI/sorianutilities.lua
---  Author(s): Michael Robbins aka Sorian
---  There are some extensions to certain Sorian functions in here

local AIUtils = import('/lua/ai/aiutilities.lua')
local AltAIUtils = import('/lua/ai/altaiutilities.lua')

local AIChatText = import('/lua/ai/sorianlang.lua').AIChatText

local LOUDABS = math.abs
local LOUDCEIL = math.ceil
local LOUDDEG = math.deg

local LOUDSQRT = math.sqrt
local LOUDFLOOR = math.floor
local LOUDGETN = table.getn
local LOUDINSERT = table.insert

local ForkThread = ForkThread
local GetTerrainHeight = GetTerrainHeight
local type = type
local VDist2 = VDist2
local VDist2Sq = VDist2Sq
local VDist3 = VDist3

-- Table of AI taunts orginized by faction
local AITaunts = {
	{3,4,5,6,7,8,9,10,11,12,14,15,16}, 					-- Aeon
	{19,21,23,24,26,27,28,29,30,31,32}, 				-- UEF
	{33,34,35,36,37,38,39,40,41,43,46,47,48}, 			-- Cybran
	{49,50,51,52,53,54,55,56,57,58,59,60,61,62,63,64}, 	-- Seraphim
}


--  aigroup 		- Group to send chat to (Enemies, Allies or specific army index)
--  ainickname  	- AI that is sending the message
--  aiaction		- Type of AI chat (used to perform specific actions during ReceiveChat)
--	tagetnickname	- Target name
function AISendChat(aigroup, ainickname, aiaction, targetnickname, extrachat)

	local army = GetArmyData(ainickname)

	-- if theres a group to send it to and you're not defeated -- and its not for allies or it is and you have allies -- then send it
	if (army and aigroup) and (not army:IsDefeated()) and (  aigroup !='allies' or AIHasAlly(army) ) then
	
		if aiaction and AIChatText[aiaction] then
		
			local ranchat = Random(1, LOUDGETN(AIChatText[aiaction]))
			local chattext
			
			if targetnickname then
			
				if IsAIArmy(targetnickname) then
				
					targetnickname = string.gsub(targetnickname,'%b()', '' )
					
				end
				
				chattext = string.gsub(AIChatText[aiaction][ranchat],'%[target%]', targetnickname )
				
			elseif extrachat then
			
				chattext = string.gsub(AIChatText[aiaction][ranchat],'%[extra%]', extrachat )
				
			else
			
				chattext = AIChatText[aiaction][ranchat]
				
			end
			
			LOUDINSERT(Sync.AIChat, {group=aigroup, text=chattext, sender=ainickname} )
			
		else
		
			LOUDINSERT(Sync.AIChat, {group=aigroup, text=aiaction, sender=ainickname} )
			
		end
		
	end
	
end

--- Randmonly chooses a taunt and sends it to AISendChat.
function AIRandomizeTaunt(aiBrain)

	local factionIndex = aiBrain.FactionIndex
	
	--LOG("*AI DEBUG Taunt list has "..LOUDGETN(AITaunts[factionIndex]) )
	tauntid = Random(1,LOUDGETN(AITaunts[factionIndex]))
	
	local currentenemy = aiBrain:GetCurrentEnemy()
	
	if currentenemy then
	
		local enemyindex = currentenemy:GetArmyIndex()
	
		AISendChat( enemyindex, aiBrain.Nickname, '/'..AITaunts[factionIndex][tauntid], ArmyBrains[enemyindex].Nickname)
		
	end
	
end


--- Sends a response to a human ally's chat message.

-- Handles all the resulting AI actions from a chat message
function FinishAIChat(data)

	local aiBrain = GetArmyBrain(data.Army)
	
	if data.NewTarget then
	
		if data.NewTarget == 'at will' then
		
			aiBrain.targetoveride = nil
            
			AISendChat('allies', aiBrain.Nickname, 'Targeting at will')
			
		else
		
			if IsEnemy(data.NewTarget, data.Army) then
			
				aiBrain:SetCurrentEnemy( ArmyBrains[data.NewTarget] )
				aiBrain.targetoveride = true
				aiBrain.CurrentEnemyIndex = aiBrain:GetCurrentEnemy().ArmyIndex
				
				AISendChat('allies', aiBrain.Nickname, 'tcrespond', ArmyBrains[data.NewTarget].Nickname)
				
			elseif IsAlly(data.NewTarget, data.Army) then
			
				AISendChat('allies', aiBrain.Nickname, 'tcerrorally', ArmyBrains[data.NewTarget].Nickname)
				
			end
			
		end
		
	elseif data.NewFocus then
	
		aiBrain.Focus = data.NewFocus
		AISendChat('allies', aiBrain.Nickname, 'genericchat')
		
	elseif data.CurrentFocus then
	
		local focus = 'nothing'
		
		if aiBrain.Focus then
		
			focus = aiBrain.Focus
			
		end
		
		AISendChat('allies', aiBrain.Nickname, 'focuschat', nil, focus)
		
	elseif data.CurrentPlan then
	
		if not aiBrain.DisplayAttackPlans then
		
			aiBrain.DisplayAttackPlans = true
			
			AISendChat('allies', aiBrain.Nickname, 'I\'ll show you my plan at my next opportunity')
			
		else
			aiBrain.DisplayAttackPlans = false
			
			if aiBrain.DrawPlanThread then
			
				KillThread(aiBrain.DrawPlanThread)
				
				aiBrain.DrawPlanThread = nil
				
			end
			
			AISendChat('allies', aiBrain.Nickname, 'Ok. I\'ll stop showing the plan')
			
		end
        
    elseif data.CurrentBases then
    
        if not aiBrain.DisplayBaseMonitors then
        
            aiBrain.DisplayBaseMonitors = true
            aiBrain.DisplayBaseNames = true
            
            AISendChat('allies', aiBrain.Nickname, 'Ok. I\'ll start showing my base radii')
            
        else
            aiBrain.DisplayBaseMonitors = false
            aiBrain.DisplayBaseNames = false
            
            AISendChat('allies', aiBrain.Nickname, 'Ok. No longer showing base monitor radii')
            
        end

	elseif data.CurrentStatus then
	
		AISendChat('allies', aiBrain.Nickname, 'My current ENEMY is '..repr(ArmyBrains[aiBrain:GetCurrentEnemy().ArmyIndex].Nickname) )
		AISendChat('allies', aiBrain.Nickname, 'My current LAND ratio is '..repr(aiBrain.LandRatio) )
        AISendChat('allies', aiBrain.Nickname, 'My current AIR ratio is '..repr(aiBrain.AirRatio) )
		AISendChat('allies', aiBrain.Nickname, 'My current LAND BASE is '..repr(aiBrain.PrimaryLandAttackBase) )
	
		if not aiBrain.DeliverStatus then
		
			aiBrain.DeliverStatus = true
			
			AISendChat('allies', aiBrain.Nickname, 'I\'ll start sending my status information')
			
		else
		
			aiBrain.DeliverStatus = false
			
			AISendChat('allies', aiBrain.Nickname, 'I\'ll stop sending my status information')
			
		end
	
	elseif data.GiveEngineer and not GetArmyBrain(data.ToArmy):IsDefeated() then
	
		local cats = {categories.TECH3, categories.TECH2, categories.TECH1}
		local given = false
		
		for _, cat in cats do
			-- get idle engineers 
			local engies = aiBrain:GetListOfUnits(categories.ENGINEER * cat - categories.COMMAND - categories.SUBCOMMANDER - categories.ENGINEERSTATION, true)

            LOG("*AI DEBUG List of Engineer units is "..repr(engies) )
            
			for k,v in engies do
			
				if not v:IsDead() and v:GetParent() == v then
					
					if v.NotBuildingThread then
						continue
					end
                    
                    -- if the engineer actually belongs to a location
                    if v.LocationType then
                        aiBrain.BuilderManagers[v.LocationType].EngineerManager:RemoveEngineerUnit(v)
                    end
					
					IssueStop({v})
					IssueClearCommands({v})
					
					AltAIUtils.AISendPing(v:GetPosition(), 'move', data.Army)
					
					AISendChat(data.ToArmy, aiBrain.Nickname, 'giveengineer')
					
					ChangeUnitArmy(v,data.ToArmy)
					
					given = true
					
					break
					
				end
				
			end
			
			if given then
			
				break
				
			end
			
		end
		
		if not given then
		
			LOG("*AI DEBUG No stinky engineer to send")
			
			AISendChat(data.ToArmy, aiBrain.Nickname, 'noengineer')
			
		end
		
	elseif data.Command then
	
		if data.Text == 'target' then
		
			AISendChat(data.ToArmy, aiBrain.Nickname, 'target <enemy>: <enemy> is the name of the enemy you want me to attack or \'at will\' if you want me to choose targets myself.')
			
		--elseif data.Text == 'focus' then
		
			--AISendChat(data.ToArmy, aiBrain.Nickname, 'focus <strat>: <strat> is the name of the strategy you want me to use or \'at will\' if you want me to choose strategies myself. Available strategies: rush arty, rush nuke, air.')
			
		else
		
			AISendChat(data.ToArmy, aiBrain.Nickname, 'Available Commands: target <enemy or at will>, current <bases, focus, plan or status>, give me an engineer.')
			
		end
	
	elseif data.PrintMult then

		AISendChat(data.ToArmy, aiBrain.Nickname, string.format("My cheat multiplier is %.3f.", aiBrain:TotalCheat()))
		
	end
	
end

-------------------------------------------------------
--   Function: AIHandlePing
--   Args:
--       aiBrain 		- AI Brain
--       pingData   		- Ping data table
--   Description:
--       Handles the AIs reaction to a human ally's ping.
--   Returns:  
--       nil
-------------------------------------------------------
--[[
function AIHandlePing(aiBrain, pingData)

	if pingData.Type == 'move' then
	
		nextping = (LOUDGETN(aiBrain.TacticalBases) + 1)
		
		LOUDINSERT( aiBrain.TacticalBases, { Position = pingData.Location,	Name = 'BasePing'..nextping,} )
		
		AISendChat('allies', ArmyBrains[aiBrain.ArmyIndex].Nickname, 'genericchat')
		
	elseif pingData.Type == 'attack' then
	
		LOUDINSERT(aiBrain.AttackPoints, { Position = pingData.Location, }	)
		
		aiBrain:ForkThread(aiBrain.AttackPointsTimeout, pingData.Location)
		
		AISendChat('allies', ArmyBrains[aiBrain.ArmyIndex].Nickname, 'genericchat')
		
	elseif pingData.Type == 'alert' then
	
		LOUDINSERT(aiBrain.BaseMonitor.AlertsTable,	{ Position = pingData.Location, Threat = 80, }	)
		
        aiBrain.BaseMonitor.AlertSounded = true
		
		aiBrain:ForkThread( aiBrain.BaseMonitorAlertTimeout, pingData.Location)
		
        aiBrain.BaseMonitor.ActiveAlerts = aiBrain.BaseMonitor.ActiveAlerts + 1
		
		AISendChat('allies', ArmyBrains[aiBrain.ArmyIndex].Nickname, 'genericchat')
		
	end
	
end
--]]



-------------------------------------------------------
--   Function: LeadTarget
--   Args:
--       platoon 		- TML firing missile
--       target  		- Target to fire at
--   Description:
--       Allows the TML to lead a target to hit them while moving.
--   Returns:  
--       Map Position or false
--	Notes:
--		TML Specs(MU = Map Units): Max Speed: 12MU/sec
--				                   Acceleration: 3MU/sec/sec
--				                   Launch Time: ~3 seconds
-------------------------------------------------------
function LeadTarget( position, target)

	local TMLRandom = tonumber(ScenarioInfo.Options.TMLRandom) or 0
	
	local pos = target:GetPosition()
	
	--Get firing position height
	local fromheight = GetTerrainHeight(position[1], position[3])
	
	if GetSurfaceHeight(position[1], position[3]) > GetTerrainHeight(position[1], position[3]) then
	
		fromheight = GetSurfaceHeight(position[1], position[3])
		
	end
    
	--Get target position height
	local toheight = GetTerrainHeight(pos[1], pos[3])
	
	if GetSurfaceHeight(pos[1], pos[3]) > GetTerrainHeight(pos[1], pos[3]) then
	
		toheight = GetSurfaceHeight(pos[1], pos[3])
		
	end
	
	--Get height difference between firing position and target position
	local heightdiff = LOUDABS(fromheight - toheight)
	
	--Get target position and then again after 1 second
	--Allows us to get speed and direction
	local Tpos1 = {pos[1], 0, pos[3]}
    
	WaitTicks(10)
	pos = target:GetPosition()
    
	local Tpos2 = {pos[1], 0, pos[3]}
	
	--Get distance moved on X and Y axis
	local xmove = (Tpos1[1] - Tpos2[1])
	local ymove = (Tpos1[3] - Tpos2[3])
	
	--Get distance from firing position to targets starting position and position it moved
	--to after 1 second
	local dist1 = VDist2Sq(position[1], position[3], Tpos1[1], Tpos1[3])
	local dist2 = VDist2Sq(position[1], position[3], Tpos2[1], Tpos2[3])
	
	dist1 = LOUDSQRT(dist1)
	dist2 = LOUDSQRT(dist2)
	
	--Adjust for level off time. 
	local distadjust = 0.25

	--Missile has a faster turn rate when targeting targets < 50 MU away
	--so will level off faster
	if dist2 < 50 then
	
		distadjust = 0.02
		
	end
	
	--Divide both distances by missiles max speed to get time to impact
	local time1 = (dist1 * 0.083) 
	local time2 = (dist2 * 0.083)
	
	--Adjust for height difference by dividing the height difference by the missiles max speed
	local heightadjust = heightdiff * 0.083
	
	--Speed up time is distance the missile will travel while reaching max speed
	--#(~22.47 MU) divided by the missiles max speed which equals 1.8725 seconds flight time
	
	--total travel time + 1.87 (time for missile to speed up, rounded) + 3 seconds for launch
	--+ adjustment for turn rate + adjustment for height difference
	local newtime = time2 - (time1 - time2) + 4.87 + distadjust + heightadjust
	
	--Add some optional randomization to make the AI easier
	local randomize = (100 - Random(0, TMLRandom)) * 0.01
	
	newtime = newtime * randomize
	
	--Create target corrdinates
	local newx = xmove * newtime
	local newy = ymove * newtime
	
	--Cancel firing if target is outside map boundries
    if Tpos2[1] - newx < 0 or Tpos2[3] - newy < 0 or
	  Tpos2[1] - newx > ScenarioInfo.size[1] or Tpos2[3] - newy > ScenarioInfo.size[2] then
	  
        return false
		
    end
    
	return {Tpos2[1] - newx, 0, Tpos2[3] - newy}
	
end

-- this lead target is used by AI nuke launchers
function UnitLeadTarget(unit, target)
	
	local position = unit:GetPosition()
	local pos = target:GetPosition()
	
	-- Get firing position height
	local fromheight = GetTerrainHeight(position[1], position[3])
	
	if GetSurfaceHeight(position[1], position[3]) > GetTerrainHeight(position[1], position[3]) then
	
		fromheight = GetSurfaceHeight(position[1], position[3])
		
	end
	
	-- Get target position height
	local toheight = GetTerrainHeight(pos[1], pos[3])
	
	if GetSurfaceHeight(pos[1], pos[3]) > GetTerrainHeight(pos[1], pos[3]) then
	
		toheight = GetSurfaceHeight(pos[1], pos[3])
		
	end
	
	-- Get height difference between firing position and target position
	local heightdiff = LOUDABS(fromheight - toheight)

	-- == PREDICT FOR MOVEMENT OF TARGET OVER FLIGHTIME == 
	-- Get target position and then again after 1 seconds
	-- Allows us to get speed and direction
	local Tpos1 = {pos[1], 0, pos[3]}
	
	--LOG("*AI DEBUG TML target - start "..repr(Tpos1))
	WaitTicks(9)
	
	pos = target:GetPosition()
	
	local Tpos2 = {pos[1], 0, pos[3]}
	
	--LOG("*AI DEBUG TML target - end   "..repr(Tpos2))
	
	-- Get distance moved on X and Y axis
	local xmove = (Tpos1[1] - Tpos2[1])
	local ymove = (Tpos1[3] - Tpos2[3])
	
	--LOG("*AI DEBUG Target moved X "..repr(xmove).."  and Y "..repr(ymove))
	
	-- Get distance from firing position to targets starting position and position it moved
	-- to after 1 second
	local dist1 = VDist2Sq(position[1], position[3], Tpos1[1], Tpos1[3])
	local dist2 = VDist2Sq(position[1], position[3], Tpos2[1], Tpos2[3])
	
	dist1 = LOUDSQRT(dist1)
	--LOG("*AI DEBUG Original distance to target "..repr(dist1))
	
	dist2 = LOUDSQRT(dist2)
	--LOG("*AI DEBUG Second   distance to target "..repr(dist2))
	
	-- Adjust for level off time. 
	local distadjust = 0.25

	-- Missile has a faster turn rate when targeting targets < 50 MU away
	-- so will level off faster
	if dist2 < 50 then
	
		distadjust = 0.02
		
	end
	
	--LOG("*AI DEBUG Distance adjusment is "..repr(distadjust))
	
	-- Divide both distances by missiles max speed to get time to impact
	local time1 = (dist1 / 12) 
	local time2 = (dist2 / 12)
	
	--LOG("*AI DEBUG travel time to Original target is "..repr(time1))
	--LOG("*AI DEBUG travel time to   Second target is "..repr(time2))
	
	-- Adjust for height difference by dividing the height difference by the missiles max speed
	local heightadjust = heightdiff / 12
	
	--LOG("*AI DEBUG heightadjust is "..repr(heightadjust))
	
	-- Speed up time is distance the missile will travel while reaching max speed
	-- (~22.47 MU) divided by the missiles max speed which equals 1.8725 seconds flight time
	
	-- total travel time + 1.87 (time for missile to speed up, rounded) + 6 seconds for launch
	-- + adjustment for turn rate + adjustment for height difference
	local newtime = time2 - (time1 - time2) + 7.87 + distadjust + heightadjust
	
	--LOG("*AI DEBUG Travel time is "..repr(newtime))
	
	-- Create target corrdinates
	local newx = xmove * newtime
	local newy = ymove * newtime
	
	-- Cancel firing if target is outside map boundries
    if Tpos2[1] - newx < 0 or Tpos2[3] - newy < 0 or
	  Tpos2[1] - newx > ScenarioInfo.size[1] or Tpos2[3] - newy > ScenarioInfo.size[2] then
	  
        return false
		
    end
	
	return {Tpos2[1] - newx, 0, Tpos2[3] - newy}
	
end


-------------------------------------------------------
--   Function: FindDamagedShield
--   Args:
--       aiBrain 		- AI Brain
--       locationType	- Location to look at
--		buildCat		- Building category to search for
--   Description:
--       Finds damaged shields in an area.
--   Returns:  
--       damaged shield or false
-------------------------------------------------------
function FindDamagedShield(aiBrain, locationType, buildCat)

	local BM = aiBrain.BuilderManagers[locationType]
	
	local shields = aiBrain:GetUnitsAroundPoint( buildCat, BM.Position, BM.Radius, 'Ally' )
	
	local retShield = false
	
	for num, unit in shields do
	
		if not unit.Dead and unit:ShieldIsOn() then
		
			shieldPercent = (unit.MyShield:GetHealth() / unit.MyShield:GetMaxHealth())
			
			if shieldPercent < 1 then
				retShield = unit
				break
			end
		end
	end
	
	return retShield
end

-------------------------------------------------------
--   Function: NumberofUnitsBetweenPoints
--   Args:
--       start			- Starting point
--		finish			- Ending point
--		unitCat			- Unit category
--		stepby			- MUs to step along path by
--		alliance		- Unit alliance to check for
--   Description:
--       Counts units between 2 points.
--   Returns:  
--       Number of units
-------------------------------------------------------
function NumberofUnitsBetweenPoints(aiBrain, start, finish, unitCat, stepby, alliance)
    if type(unitCat) == 'string' then
        unitCat = ParseEntityCategory(unitCat)
    end

	local returnNum = 0
	
	#Get distance between the points
	local distance = LOUDSQRT(VDist2Sq(start[1], start[3], finish[1], finish[3]))
	local steps = LOUDFLOOR(distance / stepby)
	
	local xstep = (start[1] - finish[1]) / steps
	local ystep = (start[3] - finish[3]) / steps
	#For each point check to see if the destination is close
	for i = 0, steps do
		local numUnits = aiBrain:GetNumUnitsAroundPoint( unitCat, {finish[1] + (xstep * i),0 , finish[3] + (ystep * i)}, stepby, alliance )
		returnNum = returnNum + numUnits
	end
	
	return returnNum
end

-------------------------------------------------------
--   Function: GetArmyData
--   Args:
--       army		 	- Army
--   Description:
--       Returns army data for an army nickname.
--   Returns:  
--       Army data table
-------------------------------------------------------
function GetArmyData(army)
    
    if type(army) == 'string' then
    
        local Brains = ArmyBrains
	
        for i, v in Brains do
		
            if v.Nickname == army then

                return v
				
            end
			
        end
		
    end
	
    return false
	
end


function IsAIArmy(army)

    if type(army) == 'string' then
    
        local Brains = ArmyBrains
        
	    for i, v in Brains do
        
			if v.Nickname == army and v.BrainType == 'AI' then
				return true
			end
            
        end
        
	elseif type(army) == 'number' then
    
		if ArmyBrains[army].BrainType == 'AI' then
			return true		
		end
        
	end
    
    return false
end


function AIHasAlly(army)

    local Brains = ArmyBrains
    
	for k, v in Brains do
    
		if IsAlly(army.ArmyIndex, v.ArmyIndex) and army.ArmyIndex != v.ArmyIndex and not v:IsDefeated() then
			--LOG("*AI DEBUG "..repr(army.Nickname).." has an ally - "..repr(v.Nickname))
			return true
		end
        
	end
    
	return false
end

-- PRESENTLY ONLY USED BY THE SATELLITE AI
function AIFindUndefendedBrainTargetInRangeSorian( aiBrain, platoon, squad, maxRange, atkPri )

    local position = platoon:GetPlatoonPosition()
	
    if not aiBrain or not position or not maxRange then
        return false
    end
	
	-- maxShields set to number of platoon units divided by 7
	local maxShields = LOUDCEIL( LOUDGETN(platoon:GetPlatoonUnits()) / 7)
    
	-- get all the units within maxRange of platoon 
    local targetUnits = aiBrain:GetUnitsAroundPoint( categories.ALLUNITS, position, maxRange, 'Enemy' )
	
	-- loop thru the attack priority list
    for k,v in atkPri do
	
        local category = ParseEntityCategory( v )
        local retUnit = false
        local distance = false
		local targetShields = 9999
		
		-- loop thru the units 
        for num, unit in targetUnits do
		
			-- if they match and we can attack them
            if not unit:IsDead() and EntityCategoryContains( category, unit ) and platoon:CanAttackTarget( squad, unit ) then
			
                local unitPos = unit:GetPosition()
				local numShields = aiBrain:GetNumUnitsAroundPoint( categories.STRUCTURE * categories.SHIELD - categories.ANTIARTILLERY, unitPos, 46, 'Enemy' )
				
				-- see if they are shielded -- always store the one with the LEAST amount of shields that has LESS shields than the maxShields calculated above
                if numShields < maxShields and (not retUnit or numShields < targetShields or (numShields == targetShields and VDist3( position, unitPos ) < distance)) then
                    retUnit = unit
                    distance = VDist3( position, unitPos )
					targetShields = numShields
                end
            end
        end
		
		-- if we found a target and it has shielding
		-- set the closest shield as the primary target
		if retUnit and targetShields > 0 then
		
			local platoonUnits = platoon:GetPlatoonUnits()
			
			for k,v in platoonUnits do
			
				if not v:IsDead() then
					unit = v
					break
				end
			end
			
			local closestBlockingShield = GetClosestShieldProtectingTarget(unit, retUnit, aiBrain )
			
			if closestBlockingShield then
				return closestBlockingShield
			end
		end
		
		-- if we have a target return it
        if retUnit then
            return retUnit
        end
    end
	
    return false
end

--	Since a shield can be vertically offset, blueprint radius isnt always indicative of its coverage
--	This gets the square of the actual protective radius of the shield
--	Returns:   The square of the shield's radius at the surface.
function GetShieldRadiusAboveGroundSquared(shield)
    local BP = shield:GetBlueprint().Defense.Shield
    local width = BP.ShieldSize
    local height = BP.ShieldVerticalOffset
    
    return width*width - height*height
end

--	Gets the closest shield protecting the target unit or false 
function GetClosestShieldProtectingTarget( attackingUnit, targetUnit, aiBrain )

    local tPos = targetUnit:GetPosition()
    local aPos = attackingUnit:GetPosition()
    
    local blockingList = {}
    
    --	If targetUnit is within the radius of any shields, the shields need to be destroyed.
    local shields = aiBrain:GetUnitsAroundPoint( categories.SHIELD * categories.STRUCTURE, targetUnit:GetPosition(), 60, 'Enemy' )
	
    for _,shield in shields do
        if not shield.Dead then
            local shieldPos = shield:GetPosition()
            local shieldSizeSq = GetShieldRadiusAboveGroundSquared(shield)
            
            if VDist2Sq(tPos[1], tPos[3], shieldPos[1], shieldPos[3]) < shieldSizeSq then
                LOUDINSERT(blockingList, shield)
            end
        end
    end

    --	return the closest blocking shield
    local closest = false
    local closestDistSq = 999999
	
    for _,shield in blockingList do
        local shieldPos = shield:GetPosition()
        local distSq = VDist2Sq(aPos[1], aPos[3], shieldPos[1], shieldPos[3])
        
        if distSq < closestDistSq then
            closest = shield
            closestDistSq = distSq
        end
    end
    
    return closest
end
