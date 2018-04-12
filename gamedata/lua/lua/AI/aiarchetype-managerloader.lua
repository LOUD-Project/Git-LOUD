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

function ExecutePlan(aiBrain)

	aiBrain.ConstantEval = false
	
    WaitTicks(10)
	
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
		
			ForkThread(UnitCapWatchThread, aiBrain)
			
		end
		
    end
	
end

function SetupMainBase(aiBrain)

    local base, returnVal, baseType = GetBestBasePlan(aiBrain)

    local per = ScenarioInfo.ArmySetup[aiBrain.Name].AIPersonality
	
    if per != 'adaptive' then
        ScenarioInfo.ArmySetup[aiBrain.Name].AIPersonality = baseType
    end
	
    import('/lua/ai/aiaddbuildertable.lua').AddGlobalBaseTemplate(aiBrain, 'MAIN', base)

    for k,v in aiBrain.BuilderManagers do
	
        v.EngineerManager:SortBuilderList('Any')
        v.FactoryManager:SortBuilderList('Land')
        v.FactoryManager:SortBuilderList('Air')
        v.FactoryManager:SortBuilderList('Sea')
        v.PlatoonFormManager:SortBuilderList('Any')
		
    end
end

function UnitCapWatchThread(aiBrain)

	-- these flags alternate the check so that we only kill groups every 10 minutes
	-- if we actually killed something in the previous pass
	local KillPD = false
	local KillT1Land = false
	local KillT1Air = false

	WaitSeconds(3600)
    
    local GetListOfUnits = aiBrain.GetListOfUnits
    local armyindex = aiBrain.ArmyIndex
	
    while true do
	
        WaitSeconds(300)
		
        if GetArmyUnitCostTotal(armyindex) > 500 then
		
            if not KillT1Land then
			
				local units = GetListOfUnits(aiBrain, categories.TECH1 * categories.MOBILE * categories.LAND - categories.ENGINEER - categories.SCOUT, false)
				local count = 0
				
				for k, v in units do
					v:Kill()
					count = count + 1
					if count >= 40 then break end
				end	
				
				KillT1Land = true
				
            elseif not KillT1Air then
			
				local units = GetListOfUnits(aiBrain, categories.TECH1 * categories.MOBILE * categories.AIR - categories.SCOUT - categories.TRANSPORTFOCUS, false)
				local count = 0
				
				for k, v in units do
					v:Kill()
					count = count + 1
					if count >= 40 then break end
				end	

				KillT1Air = true
                
			elseif not KillPD then
            
                local units = GetListOfUnits(aiBrain, categories.TECH1 * categories.DEFENSE * categories.DIRECTFIRE * categories.STRUCTURE, false)
				
                for k, v in units do
                    v:Kill()
                end
				
                KillPD = true

            else
                KillPD = false
				KillT1Land = false
				KillT1Air = false
				
            end
        end
    end
end
