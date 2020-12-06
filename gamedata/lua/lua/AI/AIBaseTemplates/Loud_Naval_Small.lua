--   /lua/ai/AIBaseTemplates/Loud_Naval_Small.lua

-- This is the reduced size Naval base template
-- This plan will be selected for Naval bases on maps where the Water/Land ratio is 20% or less
-- and the map is 20km or less
-- The main differences are only 4 yards, less point defense, and less engineers and no energy buildings
BaseBuilderTemplate {
    BaseTemplateName = 'Loud_Naval_Small',
	
    Builders = {},
	
	WaterMapBuilders = {
	
        # Build Engineers
        'Factory Production - Engineers',
		
		# Engineer Tasks
		'Engineer Tasks',
		'Engineer Tasks - Reclaim Old Structures',
		
		# Engineers Build Factories
        'Engineer Factory Construction - Naval',
        
        # Mass
        'Engineer Mass Builders - Naval',
        
        # ==== DEFENSES ==== #
		'Engineer Misc Construction - Naval',
		
        'Engineer Sonar Builders',

        # ==== UNIT BUILDING ==== #
        'Factory Production - Naval - Small',
		'Engineer T4 Naval Construction',
		
        # ==== OPERATIONS ==== #		
        'Naval Formations',

		'Air Formations - Scouts',		
		'Sea Scout Formations - Small',

		'Air Formations - Hunt',
		'Air Formations - Water Map',
		'Air Formations - Point Guards',
		
		'Land Formations - Amphibious',
		
		'Land Formations - Experimentals',
		'Air Formations - Experimentals',
		
	},
	
	LandOnlyBuilders = {},

	LOUD_IS_Installed_Builders = {},
	LOUD_IS_Not_Installed_Builders = {},
	
    BaseSettings = {
        EngineerCount = {
            Tech1 = 1,
            Tech2 = 3,
            Tech3 = 3,
            SCU = 3,
        },
        FactoryCount = {
            LAND = 0,
            AIR = 0,
            SEA = 4,
            GATE = 0,
        },
        MassToFactoryValues = {
            T1Value = 8,
            T2Value = 14,
            T3Value = 19,
        },
		RallyPointRadius = 40,
    },
	
    ExpansionFunction = function(aiBrain, location, markerType)
	
        if markerType != 'Naval Area' then
            return 0, false
        end
        
        local personality = ScenarioInfo.ArmySetup[aiBrain.Name].AIPersonality
        
        if personality == 'loud' then
		
			if aiBrain:GetMapWaterRatio() <= .10 or GetArmyUnitCap(aiBrain.ArmyIndex) < 750 then
				return 80, false
			end

			if aiBrain:GetMapWaterRatio() <= .20 or ScenarioInfo.size[1] <= 1024 or GetArmyUnitCap(aiBrain.ArmyIndex) < 1000 then
				return 100, false
			end
			
			if (aiBrain:GetMapWaterRatio() > .20 and ScenarioInfo.size[1] >= 1024) and GetArmyUnitCap(aiBrain.ArmyIndex) > 750 then
				return 90,false
			end
		end
        
        return 0, false
    end,
}