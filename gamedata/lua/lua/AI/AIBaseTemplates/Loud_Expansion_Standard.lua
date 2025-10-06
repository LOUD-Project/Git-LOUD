--***************************************************************************
--**  File     :  /lua/ai/AIBaseTemplates/LoudExpansion.lua
--**  Summary  : Manage engineers for a location
--**  Copyright � 2005 Gas Powered Games, Inc.  All rights reserved.
--****************************************************************************
-- this is a full sized expansion base with production facilities
BaseBuilderTemplate {
    BaseTemplateName = 'Loud_Expansion_Standard',
    Builders = {
        
		# Build Factories
        'Engineer Factory Construction - Expansions',
        
		# Engineers reclaim, repair, assist
        'Engineer Tasks',
		'Engineer Tasks - Reclaim Old Structures',
        
        # Engineers Build Economy
        'Engineer Energy Builders - Expansions',
		'Engineer Mass Builders - Expansions',
		'Engineer T4 Economy Construction - Expansions',

        # === EXPANSIONS ==== #
		'Engineer Land Base Construction',
		'Engineer Land DP Construction',
        
        # === DEFENSES === #
        'Engineer Base Defense Construction - Core - Expansions',
		'Engineer Base Defense Construction - Perimeter - Expansions',
        'Engineer Radar Construction - Expansions',
		'Engineer T4 Shield Construction - Expansions',
        'Engineer Misc Construction - Expansions',
		'Engineer Artillery Construction Expansions',
		'Engineer Nuke Construction Expansions',
        'Engineer Optics Construction',
        
        # ==== UNIT BUILDERS ==== #
        'Factory Production - Engineers',        
		'Factory Production - Land',
		'Factory Production - Air',
		'Factory Production - Transports',
        
        'Factory Production - Land - Land Only Map',
        
		'Engineer T4 Construction Land - Expansions',
        'Engineer T4 Construction Air - Expansions',
        
		# === PLATOON FORMATIONS === #
		'Land Formations - Point Guards',
		'Land Formations - Base Guards',
        
        'Land Formations - Land Only Map',

		'Air Formations - Hunt',
		'Air Formations - Point Guards',        

		'Land Formations - Artillery',
		'Land Formations - Nukes',

		'Air Formations - Experimentals',		
		'Land Formations - Experimentals',

		'Air Formations - Scouts',
		'Land Formations - Scouts',
        
		'Land Formations - Reinforcement',
    },
	
	WaterMapBuilders = {
		'Engineer T4 Construction Air - Water Map - Expansions',
        
        'Engineer Naval Base Construction',
		'Engineer Naval DP Construction',
		
		'Factory Production - Torpedo Bombers',
		'Factory Production - Land - Water Map',
        
		'Air Formations - Water Map',
		'Land Formations - Amphibious',		
		'Land Formations - Water Map',
	},
	
	LandOnlyBuilders = {
		--'Engineer T4 Construction Air - Expansions',
        
		--'Factory Production - Land - Land Only Map',
        
		--'Land Formations - Land Only Map',
	},

	LOUD_IS_Installed_Builders = {
		'Engineer Mass Fab Construction - Expansions - LOUD_IS',
        'Engineer Shield Construction - Expansions - LOUD_IS',
	},
	
	LOUD_IS_Not_Installed_Builders = {
		'Engineer Mass Fab Construction - Expansions',
		'Engineer Mass Storage Construction',
		'Engineer Energy Storage Construction',
        'Engineer Shield Construction - Expansions',
	},
	
    BaseSettings = {
        EngineerCount = {
            Tech1 = 2,
            Tech2 = 3,
            Tech3 = 4,
            SCU = 9,
        },
        FactoryCount = {
            LAND = 3,
            AIR = 4,
            SEA = 0,
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
        if markerType != 'Start Location' and markerType != 'Large Expansion Area' then
            return 0
        end

		local island = import('/lua/ai/AIUtilities.lua').AIGetMarkersAroundLocation( aiBrain, 'Island', location, 50 )
		
		if table.getn(island) > 0 then
			return 0, island
		end
		
		-- get distance to closest threat greater than 10
        local distance = import('/lua/ai/AIUtilities.lua').GetThreatDistance( aiBrain, location, 10 )
		
        if not distance or distance > 1000 then
            return 25,island
        elseif distance > 250 then
            return 100,island
        else # within 250
            return 10,island
        end
        
        return 0,island
    end,
}