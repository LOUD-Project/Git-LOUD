-- This is essentially the entry point for any AI --
-- and it is initiated in the OnCreateAI function
function ExecutePlan(aiBrain)
    
    WaitTicks(5)	

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

function SetupMainBase(aiBrain)

    local base, returnVal, baseType = GetBestBasePlan(aiBrain)

    ScenarioInfo.ArmySetup[aiBrain.Name].AIPersonality = baseType
	
    import('/lua/ai/aiaddbuildertable.lua').AddGlobalBaseTemplate(aiBrain, 'MAIN', base)

    for k,v in aiBrain.BuilderManagers do
	
        v.EngineerManager:SortBuilderList('Any')
		
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
