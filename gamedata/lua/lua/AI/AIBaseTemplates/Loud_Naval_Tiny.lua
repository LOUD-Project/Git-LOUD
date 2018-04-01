--   /lua/ai/AIBaseTemplates/Loud_Naval_Tiny.lua

-- This is the tiny sized Naval base template
-- This plan may be selected for Naval bases on maps where the Water/Land ratio is 20% or less
-- AND the map is 20km or less - it will be randomly chosen alongside the SMALL Naval Base footprint
-- The main differences are only 2 yards, no point defense, less engineers, no economy buildings and no expansions
BaseBuilderTemplate {
    BaseTemplateName = 'Loud_Naval_Tiny',
    Builders = {},
	WaterMapBuilders = {
	
        # Build Engineers
        'Engineer Factory Builders Naval',
		
		# Engineer Tasks
		'Engineer Builders',
		
		# Engineers Build Factories
        'Naval Factory Builders',

        # ==== DEFENSES ==== #
		'Misc Engineer Builders - Naval',		
        'Sonar Builders',

        # ==== UNIT BUILDING ==== #
        'Sea Builders - Small',
		'Sea Experimental Builders',
		
        # ==== OPERATIONS ==== #		
        'Sea Attack Formations',

		'Air Scout Formations',		
		'Sea Scout Formations - Small',

		'Air Hunt Formations',
		'Air Formations - Water Map',
		'Point Guard Air Formations',
		
		'Amphibious Formations',
		
		'Land Experimental Formations',
		'Air Experimental Formations',
		
	},
	
	LandOnlyBuilders = {},
    NonCheatBuilders = {},
	LOUD_IS_Installed_Builders = {},
	LOUD_IS_Not_Installed_Builders = {},
	
    BaseSettings = {
        EngineerCount = {
            Tech1 = 1,
            Tech2 = 1,
            Tech3 = 1,
            SCU = 2,
        },
        FactoryCount = {
            LAND = 0,
            AIR = 0,
            SEA = 2,
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
		
			if aiBrain:GetMapWaterRatio() <= .10 or GetArmyUnitCap(aiBrain.ArmyIndex) < 650 then	--tonumber(ScenarioInfo.Options.UnitCap) < 750 then
				return 100, false
			end
        
			if aiBrain:GetMapWaterRatio() <= .20 and ScenarioInfo.size[1] <= 1024 then
				return 90, false
			end
		end
        
        return 0, false
    end,
}