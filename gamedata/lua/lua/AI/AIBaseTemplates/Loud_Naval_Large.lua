--   /lua/ai/AIBaseTemplates/Loud_Naval_Large.lua

-- This is the full size naval base template
-- It will be selected by LOUD on any map where the Water/Land ratio is above 20%
-- or where the map is larger than 20km
BaseBuilderTemplate {
    BaseTemplateName = 'Loud_Naval_Large',
    Builders = {},
	
	WaterMapBuilders = {
		
		# Engineers reclaim, repair, assist
		'Engineer Tasks',
		'Engineer Tasks - Reclaim Old Structures',        
		
		# Engineers Build Factories
        'Engineer Factory Construction - Naval',
        
        # Engineers Build Economy
        'Engineer Mass Builders - Naval',
        'Engineer Energy Builders - Naval',
		'Engineer T4 Economy Construction - Naval',
        
        # ==== EXPANSIONS ==== #
		'Engineer Land Base Construction',
		'Engineer Naval Base Construction', 
        
		'Engineer Land DP Construction',
		'Engineer Naval DP Construction',        
		
        # ==== DEFENSES ==== #
		'Engineer Base Defense Construction - Naval',
		'Engineer Misc Construction - Naval',

        'Engineer Sonar Builders',


        # ==== UNIT BUILDING ==== #
        'Factory Production - Engineers',        
        'Factory Production - Naval',
        
		'Engineer T4 Naval Construction',
		
        # ==== OPERATIONS ==== #		
        'Naval Formations',
		'Land Formations - Amphibious',

		'Air Formations - Hunt',
		'Air Formations - Water Map',
		'Air Formations - Point Guards',

		'Air Formations - Experimentals',		
		'Land Formations - Experimentals',
        
		'Air Formations - Scouts',		
		'Sea Scout Formations',
	},
	
	LandOnlyBuilders = {},

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
            SEA = 10,
            GATE = 0,
        },
        
        MassToFactoryValues = {
            T1Value = 8,
            T2Value = 14,
            T3Value = 20,
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
			if (aiBrain:GetMapWaterRatio() > .20 and ScenarioInfo.size[1] >= 1024) and GetArmyUnitCap(aiBrain.ArmyIndex) >= 1000 then
				return 100,false
			end
			
			-- if it's a large water map but unit cap less is 1000 or less
			if (aiBrain:GetMapWaterRatio() > .10 and ScenarioInfo.size[1] >= 1024) then
				return 80,false		-- return 80 should match the small naval base for random choice
			end
        end

        return 0,false
    end,
}