--**  File     :  /lua/ai/AIBaseTemplates/LoudExpansion.lua
--**  Summary  : Manage engineers for a location
--**  Copyright � 2005 Gas Powered Games, Inc.  All rights reserved.

BaseBuilderTemplate {
    BaseTemplateName = 'Loud_Expansion_Island',
    Builders = {

        # Build Engineers from Factories
        'Factory Production - Engineers',
     	
		# Engineers reclaim, repair, assist
        'Engineer Tasks',
		'Engineer Tasks - Reclaim Old Structures',
        
        # Build energy at this base
        'Engineer Energy Builders - Expansions',
		
		# Engineers Build Mass 
		'Engineer Mass Builders - Expansions',
       
		# Engineers build new factories
        'Engineer Factory Construction - Expansions',

        # Create New Land Bases & Active DP
		'Engineer Construction - Land Base',
		'Engineer Construction - Land DP',
        
        # Build Defenses within the base
        'Engineer Base Defense Construction - Core - Expansions',
		
		# Build Defenses at perimeter of base
        
		# Build Shield Matrix at Base
		'Engineer T4 Shield Construction - Expansions',
        
		# Various builds
        'Engineer Misc Construction - Expansions',
        
        # Create Platoons with Land Units
		'Land Formations - Scouts',
		'Land Formations - Point Guards',
		'Land Formations - Base Guards',
		'Land Formations - Experimentals',

        # ==== AIR UNIT BUILDERS ==== #
		'Factory Production Air - Scouts',
		'Factory Production Air - Fighters',
		'Factory Production Air - Bombers',
		'Factory Production Air - Gunships',
		'Factory Production Air - Transports',

		# Create Platoons with Air Units
		'Air Formations - Scouts',
		'Air Formations - Bombers',
        'Air Formations - Fighters',
        'Air Formations - Gunships',
		'Air Formations - Experimentals',

		# ==== ARTILLERY BUILDERS ==== #
		'Engineer Artillery Construction T3 Expansions',
		'Engineer Artillery Construction T4 Expansions',

		'Land Formations - Artillery',
        
		'Engineer Nuke Construction Expansions',
		'Land Formations - Nukes',
	
        # ==== EXPERIMENTALS ==== #
		'Engineer T4 Construction Land - Expansions',
		'Engineer T4 Economy Construction - Expansions',
		
		# ==== INTELLIGENCE ===== #
        'Engineer Radar Construction - Expansions',
    },
	
	WaterMapBuilders = {
        'Engineer Construction - Naval Base',
		'Engineer Construction - Naval DP',
		
		'Factory Production Air - Torpedo Bombers',
		'Factory Production Land - Water Map',

		'Air Formations - Water Map',
		'Land Formations - Water Map',
		'Land Formations - Amphibious',
		
		'Engineer T4 Construction Air - Water Map - Expansions',
	},
	
	LandOnlyBuilders = {},

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
            Tech1 = 1,
            Tech2 = 3,
            Tech3 = 4,
            SCU = 6,
        },
        FactoryCount = {
            LAND = 4,
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

		-- look for island markers within 50 of this location
		local island = import('/lua/ai/AIUtilities.lua').AIGetMarkersAroundLocation( aiBrain, 'Island', location, 50 )
		-- get the distance to any threat greater than 10
        local distance = import('/lua/ai/AIUtilities.lua').GetThreatDistance( aiBrain, location, 10 )
		
		if table.getn(island) > 0 then
			--LOG("*AI DEBUG This DP is on an island..and BTW the threat distance value is "..distance)
			island = true
		else 
			return 0
		end
		
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