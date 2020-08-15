-- This is essentially the entry point for any AI --
-- and it is initiated in the OnCreateAI function
function ExecutePlan(aiBrain)

	aiBrain.ConstantEval = false
	
    WaitTicks(5)

    -- put some initial threat at all enemy positions
    for k,brain in ArmyBrains do
        if not brain:IsDefeated() and not IsAlly(aiBrain.ArmyIndex, brain.ArmyIndex) then
        
            local place = brain:GetStartVector3f()
            local threatlayer = 'AntiAir'
            
            -- assign 500 ecothreat for 10 minutes
			aiBrain:AssignThreatAtPosition( place, 5000, 0.005, 'Economy' )

--[[
         Valid Options are:
            Overall
            OverallNotAssigned
            StructuresNotMex
            Structures
            Naval
            Air
            Land
            Experimental
            Commander
            Artillery
            AntiAir
            AntiSurface
            AntiSub
            Economy
            Unknown
--]]         

           
            --aiBrain:AssignThreatAtPosition( place, 6, 0.1, threatlayer )
--[[
            for i = 1,900 do
                LOG("*AI DEBUG Ecothreat after "..i.." ticks is "..repr(aiBrain:GetThreatAtPosition( place, 0, true, threatlayer) ))
                WaitTicks(1)
            end
            
            LOG("*AI DEBUG Ecothreat after 90 seconds is "..aiBrain:GetThreatAtPosition( place, 0, true, 'Economy') )
            
            --aiBrain:AssignThreatAtPosition( place, aiBrain:GetThreatAtPosition( place, 0, true, 'Economy'), 0.01, 'Economy' )
            
            --aiBrain:AssignThreatAtPosition( place, 0, 0.35, threatlayer )
            
            --LOG("*AI DEBUG Ecothreat after decay reset is "..aiBrain:GetThreatAtPosition( place, 0, true, 'Economy') )

            for i = 901,1800 do
                LOG("*AI DEBUG Ecothreat after "..i.." ticks is "..repr(aiBrain:GetThreatAtPosition( place, 0, true, threatlayer) ))
                WaitTicks(1)
            end

            LOG("*AI DEBUG Ecothreat after another 90 seconds is "..aiBrain:GetThreatAtPosition( place, 0, true, 'Economy') )
            
            --aiBrain:AssignThreatAtPosition( place, 0, 0.03, threatlayer )
            
            --LOG("*AI DEBUG Ecothreat after decay reset is "..aiBrain:GetThreatAtPosition( place, 0, true, 'Economy') )

            for i = 1801,2700 do
                LOG("*AI DEBUG Ecothreat after "..i.." ticks is "..repr(aiBrain:GetThreatAtPosition( place, 0, true, threatlayer) ))
                WaitTicks(1)
            end
            
            LOG("*AI DEBUG Ecothreat after final 90 seconds is "..aiBrain:GetThreatAtPosition( place, 0, true, 'Economy') )
--]]
        end
    end
    
    WaitTicks(5)	
    
    if not aiBrain.BuilderManagers.MAIN.FactoryManager.BuilderList then

        aiBrain:SetResourceSharing(true)
        
        SetupMainBase(aiBrain)
        
        -- Get units out of pool and assign them to the managers
        local mainManagers = aiBrain.BuilderManagers.MAIN
        local pool = aiBrain:GetPlatoonUniquelyNamed('ArmyPool')
		
        for _,v in pool:GetPlatoonUnits() do
		
            if EntityCategoryContains( categories.ENGINEER, v ) then
			
                mainManagers.EngineerManager:AddEngineerUnit(v)
				
            elseif EntityCategoryContains( categories.FACTORY * categories.STRUCTURE, v ) then
			
                mainManagers.FactoryManager:AddFactory( v )
				
            end
			
        end
		
		if not aiBrain.IgnoreArmyCaps then
		
			aiBrain:ForkThread(UnitCapWatchThread)
			
		end
		
    end
	
end

function SetupMainBase(aiBrain)

    local base, returnVal, baseType = GetBestBasePlan(aiBrain)

    ScenarioInfo.ArmySetup[aiBrain.Name].AIPersonality = baseType
	
    import('/lua/ai/aiaddbuildertable.lua').AddGlobalBaseTemplate(aiBrain, 'MAIN', base)

    for k,v in aiBrain.BuilderManagers do
	
        v.EngineerManager:SortBuilderList('Any')
        --v.FactoryManager:SortBuilderList('Land')
        --v.FactoryManager:SortBuilderList('Air')
        --v.FactoryManager:SortBuilderList('Sea')
        --v.PlatoonFormManager:SortBuilderList('Any')
		
    end
end


-- the purpose of this function is to select the most viable base plan
-- you can tailor the plan for certain considerations and it would get selected here
-- each Starting Base plan will have a FIRSTBASEFUNCTION that will return a value 
-- the base plan with the highest value is the one that gets selected
function GetBestBasePlan(aiBrain)

    local base = false
    local returnVal = 0
    local aiType = false
    
    for k,v in BaseBuilderTemplates do
	
        if v.FirstBaseFunction then
		
            local baseVal, baseType = v.FirstBaseFunction(aiBrain)
			
            if baseVal > returnVal then
				base = k
                returnVal = baseVal
                aiType = baseType
            end
        end
    end
    
	LOG("*AI DEBUG "..aiBrain.Nickname.." Selected "..base)
	
    return base, returnVal, aiType
end

function EvaluatePlan( aiBrain )

    local base, returnVal = GetBestBasePlan(aiBrain)
    
    return returnVal
end


function UnitCapWatchThread(aiBrain)

	-- these flags alternate the check so that we only kill groups every 3 minutes
	local KillPD = false
	local KillT1Land = false
	local KillT1Air = false

	WaitSeconds(3000)   -- start 50 minutes into the game
    
    local GetListOfUnits = aiBrain.GetListOfUnits
    local armyindex = aiBrain.ArmyIndex
	
    while not aiBrain:IsDefeated() do
	
        WaitSeconds(180)   -- every 3 minutes
		
        if GetArmyUnitCostTotal(armyindex) > 600 then
		
            if not KillT1Land then
			
				local units = GetListOfUnits(aiBrain, categories.TECH1 * categories.MOBILE * categories.LAND - categories.ENGINEER - categories.SCOUT, false)
				local count = 0
				
				for k, v in units do
					v:Kill()
					count = count + 1
					if count >= 40 then break end
				end	
				
				KillT1Land = true
                KillT1Air = false
				
            elseif not KillT1Air then
			
				local units = GetListOfUnits(aiBrain, categories.TECH1 * categories.MOBILE * categories.AIR - categories.SCOUT - categories.TRANSPORTFOCUS, false)
				local count = 0
				
				for k, v in units do
					v:Kill()
					count = count + 1
					if count >= 40 then break end
				end	

				KillT1Air = true
                KillPD = false
                
			elseif not KillPD then
            
                local units = GetListOfUnits(aiBrain, categories.TECH1 * categories.DEFENSE * categories.DIRECTFIRE * categories.STRUCTURE, false)
				
                for k, v in units do
                    v:Kill()
                end
				
                KillPD = true
                KillT1Land = false
            end
        end
    end
end
