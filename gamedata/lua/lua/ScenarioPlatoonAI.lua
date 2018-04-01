#****************************************************************************
#**  File     :  /lua/ai/scenarioplatoonai.lua
#**  Author(s):  Drew Staltman
#**
#**  Summary  :  Houses a number of AI threads that are used in operations
#**
#**  Copyright © 2005 Gas Powered Games, Inc.  All rights reserved.

--local Utilities = import('/lua/utilities.lua')
--local AIBuildStructures = import('/lua/ai/aibuildstructures.lua')
--local ScenarioFramework = import('/lua/ScenarioFramework.lua')
--local BuildingTemplates = import('/lua/buildingtemplates.lua').BuildingTemplates
--local ScenarioUtils = import('/lua/sim/scenarioutilities.lua')

function BuildOnce(platoon)

	local aiBrain = platoon:GetBrain()
	local manager = 'PlatoonFormManager'

	if platoon.BuilderManager == 'EM' then
		manager = 'EngineerManager'
	end
	if platoon.BuilderManager == 'FBM' then
		manager = 'FactoryManager'
	end

	local buildertable = aiBrain.BuilderManagers[platoon.BuilderLocation][manager]['BuilderData'][platoon.BuilderType]
	
	aiBrain.BuilderManagers[platoon.BuilderLocation][manager]:SetBuilderPriority(platoon.BuilderName, 0, false)
--[[
	for a,b in buildertable['Builders'] do

		if b.BuilderName == platoon.BuilderName then
			b:SetPriority(0,false)
			break
		end
	end
--]]
end
