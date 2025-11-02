--  File     :  /lua/ai/AIAddBuilderTable.lua

-- This routine runs everytime a new base is added - loading all the platoons that this base may use
--
-- Reducing the number of platoons is one way of improving performance and saving memory
-- platoons that won't be built or can't be used under certain conditions is helpful
--
-- this gave me the idea that we could test other conditions to load or not load other platoons
-- for example only on water maps would we load naval expansion platoons
-- 
-- We now have WaterMapBuilders that only get loaded if the map has naval markers
-- 
-- We now have LandOnly to load platoons unique to land only maps 
--
-- Additionally we make a distinction between Standard and BlackOps ACU upgrades
-- and those platoons that work with Integrated Storage and those which don't
-- ideally I should put those into the mod itself, but hey...
-- 
-- This will also a good way to filter out faction specific platoons as well
-- since we already know the faction index of the brain
function AddGlobalBaseTemplate(aiBrain, locationType, baseBuilderName)

    local CategoryRestricted = import('/lua/game.lua').CategoryRestricted

    local buildercount = 0

	local function AddGlobalBuilderGroup(builderGroupName)

		if BuilderGroups[builderGroupName] then

            local BuilderGroup          = BuilderGroups[builderGroupName]
            local BuildersRestriction   = BuilderGroups[builderGroupName].BuildersRestriction or false
            local BuildersType          = BuilderGroups[builderGroupName].BuildersType  
            
            --LOG("*AI DEBUG "..aiBrain.Nickname.." "..baseBuilderName.." "..locationType.." Type "..BuildersType.." adding Group "..builderGroupName.." Restriction "..repr(BuildersRestriction) )

            if BuildersRestriction and CategoryRestricted(BuildersRestriction) then
                LOG("*AI DEBUG "..aiBrain.Nickname.." "..builderGroupName.." restricted due to "..BuildersRestriction )
                return
            end

			local tableType 

			if BuildersType == 'PlatoonFormBuilder' then
		
				tableType = 'PlatoonFormManager'
		
			elseif BuildersType == 'EngineerBuilder' then
	
				tableType = 'EngineerManager'
		
			elseif BuildersType == 'FactoryBuilder' then
	
				tableType = 'FactoryManager'
		
			end

			for k,v in BuilderGroup do
	
				-- filter out the Group Headers 
				if k != 'BuildersType' and k != 'BuilderGroupName' and k != 'BuildersRestriction' then
                    
                    --if tableType == 'PlatoonFormManager' then
                        --LOG("*AI DEBUG "..aiBrain.Nickname.." adding "..repr(tableType).." Builder "..repr(Builders[v].BuilderName).." at "..repr(Builders[v].Priority) )
                    --end
                    
					aiBrain.BuilderManagers[locationType][tableType]:AddBuilder( aiBrain, Builders[v], locationType)
                    
                    buildercount = buildercount + 1
                end

			end	
        end
	end
    
    -- flag for true Naval maps
    aiBrain.IsNavalMap = true
	
	-- test the map for naval markers or naval defensive points --
	local navalMarker = import('/lua/ai/aiutilities.lua').AIGetClosestMarkerLocation(aiBrain, 'Naval Area', 0, 0)
	
	if not navalMarker then
    
        aiBrain.IsNavalMap = false
        
		navalMarker = import('/lua/ai/aiutilities.lua').AIGetClosestMarkerLocation(aiBrain, 'Naval Defensive Point', 0, 0)
	end

    --LOG("*AI DEBUG "..aiBrain.Nickname.." "..baseBuilderName.." loading Builders "..repr(BaseBuilderTemplates[baseBuilderName].Builders) )
    
	-- load the primary base templates
    for k,v in BaseBuilderTemplates[baseBuilderName].Builders do
	
        AddGlobalBuilderGroup( v )
		
    end

	--  Load Commander Templates Only at MAIN base
	if locationType == 'MAIN' then
	
		-- load either the BOACU templates or standard commander templates
		if ScenarioInfo.BOACU_Installed then

            --LOG("*AI DEBUG "..aiBrain.Nickname.." "..baseBuilderName.." loading BOACU Builders "..repr(BaseBuilderTemplates[baseBuilderName].BOACUCommanderUpgrades) )
		
			for k,v in BaseBuilderTemplates[baseBuilderName].BOACUCommanderUpgrades do
			
				AddGlobalBuilderGroup( v )
				
			end	
			
		else

            --LOG("*AI DEBUG "..aiBrain.Nickname.." "..baseBuilderName.." loading ACU Builders "..repr(BaseBuilderTemplates[baseBuilderName].StandardCommanderUpgrades) )

			for k,v in BaseBuilderTemplates[baseBuilderName].StandardCommanderUpgrades do
			
				AddGlobalBuilderGroup( v )
				
			end	

		end
		
	end
	
	-- load the water map templates	else load land only templates
	if navalMarker then
	
		-- record this on the brain
		aiBrain.IsWaterMap = true

        --LOG("*AI DEBUG "..aiBrain.Nickname.." "..baseBuilderName.." loading WaterMap Builders "..repr(BaseBuilderTemplates[baseBuilderName].WaterMapBuilders) )
    
		for k,v in BaseBuilderTemplates[baseBuilderName].WaterMapBuilders do
		
			AddGlobalBuilderGroup( v )
			
		end
        
        aiBrain.BuilderManagers[locationType].LandMode = false
		
	else

        --LOG("*AI DEBUG "..aiBrain.Nickname.." "..baseBuilderName.." loading WaterMap Builders "..repr(BaseBuilderTemplates[baseBuilderName].LandOnlyBuilders) )
    	
		for k,v in BaseBuilderTemplates[baseBuilderName].LandOnlyBuilders do
		
			AddGlobalBuilderGroup( v )
			
		end
        
        aiBrain.BuilderManagers[locationType].LandMode = true
		
	end
	
	-- load the LOUD Integrated Storage templates
	if ScenarioInfo.LOUD_IS_Installed then

        --LOG("*AI DEBUG "..aiBrain.Nickname.." "..baseBuilderName.." loading Integrated Storage Builders "..repr(BaseBuilderTemplates[baseBuilderName].LOUD_IS_Installed_Builders) )
    	
		for k,v in BaseBuilderTemplates[baseBuilderName].LOUD_IS_Installed_Builders do
		
			AddGlobalBuilderGroup( v )
			
		end	

	else

        --LOG("*AI DEBUG "..aiBrain.Nickname.." "..baseBuilderName.." loading Standard Storage Builders "..repr(BaseBuilderTemplates[baseBuilderName].LOUD_IS_Not_Installed_Builders) )

		for k,v in BaseBuilderTemplates[baseBuilderName].LOUD_IS_Not_Installed_Builders do
		
			AddGlobalBuilderGroup( v )
			
		end

	end
	
	-- store the settings for this base
    aiBrain.BuilderManagers[locationType].BaseSettings = BaseBuilderTemplates[baseBuilderName].BaseSettings
    
    if ScenarioInfo.BaseMonitorDialog then
        LOG("*AI DEBUG "..aiBrain.Nickname.." loaded "..buildercount.." builders for base "..repr(locationType).." on tick "..GetGameTick() )
    end
	
	-- get rid of the data sets that we build this from - they get reloaded if needed
	BaseBuilderTemplates = nil
	BuilderGroups = nil
	
end
