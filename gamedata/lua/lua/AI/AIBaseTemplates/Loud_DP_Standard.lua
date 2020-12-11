-- /lua/ai/AIBaseTemplates/Loud_DP_Standard.lua
-- This layout is used for Land DP Points

BaseBuilderTemplate {

    BaseTemplateName = 'Loud_DP_Standard',
	
    Builders = {
  
		'Engineer Tasks - Active DP', -- basic reclaim, repair and assist functions
		
		'Engineer Defenses DP Standard',	-- builds the structures at the active DP

		-- These allow the Active DP to utilize units

		'Land Formations - Point Guards',
		'Land Formations - Base Guards',
		'Land Formations - Reinforcement',
        
        'Land Formations - Land Only Map',
		
		'Air Formations - Hunt',
		'Air Formations - Point Guards', 
		
		'Land Formations - Experimentals',
		'Air Formations - Experimentals',
		
		'Air Formations - Scouts',
		'Land Formations - Scouts',
    },
	
	WaterMapBuilders = {
		'Air Formations - Water Map',
		'Land Formations - Water Map',
		'Land Formations - Amphibious',		
	},
	
	LandOnlyBuilders = {
		--'Land Formations - Land Only Map',
	},
	
	LOUD_IS_Installed_Builders = {
	},
	
	LOUD_IS_Not_Installed_Builders = {
		'Engineer Mass Storage Construction - Active DP',
	},

    BaseSettings = {
	
        EngineerCount = {
            Tech1 = 0,
            Tech2 = 1,
            Tech3 = 1,
            SCU = 1,
        },
		
        FactoryCount = {
            LAND = 1, 
            AIR = 1, 
            SEA = 0,
            GATE = 0,
        },
		
        MassToFactoryValues = {
            T1Value = 9,
            T2Value = 14,
            T3Value = 18,
        },
		
		RallyPointRadius = 32,
    },
	
    ExpansionFunction = function(aiBrain, location, markerType)
        
        if markerType !='Defensive Point' then
            return 0, false
        end
        
		-- get island markers within 50
		local island = import('/lua/ai/AIUtilities.lua').AIGetMarkersAroundLocation( aiBrain, 'Island', location, 50 )
		
		if table.getn(island) > 0 then
			island = true
		else 
			island = false
		end

        local mapSizeX, mapSizeZ = GetMapSize()		
		local basevalue = 0
		
        -- If we're playing on a 20k or less or low pop
        if (mapSizeX <= 1025 or mapSizeZ <= 1025) or tonumber(aiBrain.StartingUnitCap) < 1000 then
		
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
		
			return basevalue/2, island
			
		-- increase value for nearby threats between 3.5km and 10km	
        elseif distance > 175 then
		
			return ( basevalue * ( 500 / (distance or 500) ) ),island
			
		-- otherwise too close
        end
        
        return 0,island
		
    end,
}