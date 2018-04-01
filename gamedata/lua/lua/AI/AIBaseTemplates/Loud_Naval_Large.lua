--   /lua/ai/AIBaseTemplates/Loud_Naval_Large.lua

-- This is the full size naval base template
-- It will be selected by LOUD on any map where the Water/Land ratio is above 20%
-- or where the map is larger than 20km
BaseBuilderTemplate {
    BaseTemplateName = 'Loud_Naval_Large',
    Builders = {},
	
	WaterMapBuilders = {

        # Build Engineers
        'Engineer Factory Builders Naval',
		
		# Engineer Tasks
		'Engineer Builders',
		
		# Engineers Build Factories
        'Naval Factory Builders',
        
        # Mass
        'Extractor Builders Naval Expansions',
		'Economic Experimental Builders Naval',
        
        # ==== EXPANSION ==== #
		'Land Expansion Builders',
		'DP Builders Standard',
		'Naval Base Builders - Expansion', 
		
        # ==== DEFENSES ==== #
		'Base Defenses - Naval',
		'Misc Engineer Builders - Naval',

        'Sonar Builders',
		'Naval Defensive Points',

        # ==== UNIT BUILDING ==== #
        'Sea Builders',
		'Sea Experimental Builders',
		
        # ==== OPERATIONS ==== #		
        'Sea Attack Formations',

		'Air Scout Formations',		
		'Sea Scout Formations',

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
            Tech2 = 3,
            Tech3 = 3,
            SCU = 5,
        },
        FactoryCount = {
            LAND = 0,
            AIR = 0,
            SEA = 8,
            GATE = 0,
        },
        MassToFactoryValues = {
            T1Value = 8,
            T2Value = 14,
            T3Value = 19,
        },
		RallyPointRadius = 42,
    },
	
    ExpansionFunction = function(aiBrain, location, markerType)
	
        if markerType != 'Naval Area' then
            return 0,false
        end
        
        local personality = ScenarioInfo.ArmySetup[aiBrain.Name].AIPersonality
		
        if personality == 'loud' then
			
			-- must be lots of water on a larger map with a high unit cap
			if (aiBrain:GetMapWaterRatio() > .20 and ScenarioInfo.size[1] >= 1024) and GetArmyUnitCap(aiBrain.ArmyIndex) > 750 then	--tonumber(ScenarioInfo.Options.UnitCap) > 750 then
				return 100,false
			end
			
			-- if it's a large water map but unit cap less is 750 or less
			if (aiBrain:GetMapWaterRatio() > .20 and ScenarioInfo.size[1] >= 1024) then
				return 50,false		-- return only 50 should promote the selection of the small naval base
			end
        end
        
        return 0,false
    end,
}