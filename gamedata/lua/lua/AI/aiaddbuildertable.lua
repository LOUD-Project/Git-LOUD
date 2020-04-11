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

	local function AddGlobalBuilderGroup(builderGroupName)

		if BuilderGroups[builderGroupName] then

			local tableType 

			if BuilderGroups[builderGroupName].BuildersType == 'PlatoonFormBuilder' then
		
				tableType = 'PlatoonFormManager'
		
			elseif BuilderGroups[builderGroupName].BuildersType == 'EngineerBuilder' then
	
				tableType = 'EngineerManager'
		
			elseif BuilderGroups[builderGroupName].BuildersType == 'FactoryBuilder' then
	
				tableType = 'FactoryManager'
		
			end
            
            --LOG("*AI DEBUG Adding Group "..repr(builderGroupName))
	
			for k,v in BuilderGroups[builderGroupName] do
	
				-- filter out the Group Headers 
				if k != 'BuildersType' and k != 'BuilderGroupName' then
		
					aiBrain.BuilderManagers[locationType][tableType]:AddBuilder( aiBrain, Builders[v], locationType)
			
				end
		
			end	
	
			--AddBuilderTable( aiBrain, locationType, BuilderGroups[builderGroupName])
		
		end
	
	end
	
	-- test the map for naval markers or naval defensive points --
	local navalMarker = import('/lua/ai/aiutilities.lua').AIGetClosestMarkerLocation(aiBrain, 'Naval Area', 0, 0)
	
	if not navalMarker then
		navalMarker = import('/lua/ai/aiutilities.lua').AIGetClosestMarkerLocation(aiBrain, 'Naval Defensive Point', 0, 0)
	end
	
	-- load the primary base templates
    for k,v in BaseBuilderTemplates[baseBuilderName].Builders do
	
        AddGlobalBuilderGroup( v )
		
    end
	
	--  Load Commander Templates Only at MAIN base
	if locationType == 'MAIN' then
	
		-- load either the BOACU templates or standard commander templates
		if ScenarioInfo.BOACU_Installed then
		
			for k,v in BaseBuilderTemplates[baseBuilderName].BOACUCommanderUpgrades do
			
				AddGlobalBuilderGroup( v )
				
			end	
			
		else
		
			for k,v in BaseBuilderTemplates[baseBuilderName].StandardCommanderUpgrades do
			
				AddGlobalBuilderGroup( v )
				
			end	

		end
		
	end
	
	-- load the water map templates	else load land only templates
	if navalMarker then
	
		-- record this on the brain
		ScenarioInfo.IsWaterMap = true

		for k,v in BaseBuilderTemplates[baseBuilderName].WaterMapBuilders do
		
			AddGlobalBuilderGroup( v )
			
		end
		
	else
	
		for k,v in BaseBuilderTemplates[baseBuilderName].LandOnlyBuilders do
		
			AddGlobalBuilderGroup( v )
			
		end
		
	end
	
	-- load the LOUD Integrated Storage templates
	if ScenarioInfo.LOUD_IS_Installed then

		for k,v in BaseBuilderTemplates[baseBuilderName].LOUD_IS_Installed_Builders do
		
			AddGlobalBuilderGroup( v )
			
		end	

	else

		for k,v in BaseBuilderTemplates[baseBuilderName].LOUD_IS_Not_Installed_Builders do
		
			AddGlobalBuilderGroup( v )
			
		end

	end
	
	-- store the settings for this base
    aiBrain.BuilderManagers[locationType].BaseSettings = BaseBuilderTemplates[baseBuilderName].BaseSettings
	
	-- get rid of the data sets that we build this from - they get reloaded if needed
	BaseBuilderTemplates = nil
	BuilderGroups = nil
	
end
