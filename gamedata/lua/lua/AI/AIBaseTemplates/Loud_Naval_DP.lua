--   /lua/ai/AIBaseTemplates/Loud_Naval_Tiny.lua

-- This is the first Naval DP base template
-- This plan will be selected for Naval DP points

BaseBuilderTemplate {

    BaseTemplateName = 'Loud_Naval_DP',
	
    Builders = {},
	
	WaterMapBuilders = {
	
		# Engineer Tasks
		'Engineer Tasks - Active DP', -- basic reclaim, repair and assist functions
		
		'Engineer T4 Naval Construction - Expansions',

        # ==== DEFENSES ==== #
		'Engineer Defenses DP Naval',		-- rebuild the DP
		
        # ==== EXPANSION ==== #
		'Engineer Land Expansion Construction',
		'Engineer Defensive Point Construction STD',
		'Engineer Defensive Point Construction - Naval',
		
        # ==== OPERATIONS ==== #		
        'Naval Formations',

		'Air Formations - Scouts',		
		'Sea Scout Formations',

		'Air Formations - Hunt',
		'Air Formations - Water Map',
		'Air Formations - Point Guards',
		
		'Land Formations - Amphibious',
		
		'Land Formations - Experimentals',
		'Air Formations - Experimentals',
		
	},
	
	LandOnlyBuilders = {},
    NonCheatBuilders = {},
	LOUD_IS_Installed_Builders = {},
	LOUD_IS_Not_Installed_Builders = {},
	
    BaseSettings = {
	
        EngineerCount = {
            Tech1 = 0,
            Tech2 = 1,
            Tech3 = 1,
            SCU = 1,
        },
		
        FactoryCount = {
            LAND = 0,
            AIR = 0,
            SEA = 1,
            GATE = 0,
        },
		
        MassToFactoryValues = {
            T1Value = 8,
            T2Value = 14,
            T3Value = 19,
        },
		
		RallyPointRadius = 15,
    },
	
    ExpansionFunction = function(aiBrain, location, markerType)
	
        if markerType != 'Naval Defensive Point' then
            return 0, false
        end
		
        local mapSizeX, mapSizeZ = GetMapSize()		
		local basevalue = 0
		
        -- If we're playing on a 20k or less or low pop
        if (mapSizeX <= 1025 or mapSizeZ <= 1025) or tonumber(ScenarioInfo.Options.UnitCap) < 1000 then
		
            basevalue = 20
			
		-- if we're playing on anything larger
        else
		
			basevalue = 100

        end

		-- get distance to closest threat greater than 50 -- we'll use it to suppress building DP's
		-- too far from the action or too close
        local distance = import('/lua/ai/AIUtilities.lua').GetThreatDistance( aiBrain, location, 50 )
		
		-- if no threat or distance to threat > 10km -- reduce value
        if not distance or distance > 500 then
			return basevalue/2, false
			
		-- increase value for nearby threats between 3.5km and 10km	
        elseif distance > 175 then
			return ( basevalue * ( 500 / (distance or 500) ) ), false
			
		-- otherwise too close
        end
        
        return 0, false
		
    end,
}