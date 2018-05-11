
BaseBuilderTemplate {
    BaseTemplateName = 'Loud_Expansion_Tiny',
    Builders = {
	
        # Build Engineers from Factories
        'Engineer Factory Builders Expansion',
     	
		# Engineers reclaim, repair, assist
        'Engineer Builders',
		'Engineer Tasks - Aux',
        
        # Build energy at this base

		
		# Engineers Build Mass 
		'Extractor Builders - Expansions',
       
		# Engineers build new factories
        'Factory Construction - Expansions',

        # Engineer Support buildings


        # Create New Land Bases & Active DP

        
        # Build Defenses within the base

		
		# Build Defenses at perimeter of base

        
		# Build Shield Matrix at Base
        
		# Various builds
        'Misc Engineer Builders - Expansions',
        
        # ==== LAND UNIT BUILDERS ==== #
		'Land Factory Builders',
        
		# Create Platoons with Land Units
		'Point Guard Land Formations',
		'Base Guard Formations',
		--'Base Reinforcement Formations',

        # ==== AIR UNIT BUILDERS ==== #
		'Air Factory Builders',

		# Create Platoons with Air Units
		'Air Hunt Formations',
		'Point Guard Air Formations',        
	
        # ==== EXPERIMENTALS ==== #
		'Land Experimentals - Expansions',
		
		'Land Experimental Formations',
		'Air Experimental Formations',

		# ==== INTELLIGENCE ===== #
		'Air Scout Formations',
		'Land Scout Formations',
      
        'Radar Builders - Expansions',
    },
	
	WaterMapBuilders = {
        'Naval Base Builders',
		'Naval Defensive Points',
		
		'Air Builders - Water Map',
		'Air Formations - Water Map',
		
		'Land Builders - Water Map',
		'Land Formations - Water Map',

		'Amphibious Formations',
		
		'Air Experimentals - Expansions - Water',
	},
	
	LandOnlyBuilders = {
		'Land Builders - Land Map',
		'Land Formations - Land Map',
		'Air Experimentals - Expansions - Land',
	},
	
    NonCheatBuilders = {
	},
	
	LOUD_IS_Installed_Builders = {
	},
	
	LOUD_IS_Not_Installed_Builders = {
		'Mass Storage',
		'Energy Storage',
	},

	
    BaseSettings = {
        EngineerCount = {
            Tech1 = 1,
            Tech2 = 1,
            Tech3 = 1,
            SCU = 2,
        },
        FactoryCount = {
            LAND = 1, 
            AIR = 1, 
            SEA = 0,
            GATE = 0,
        },
        MassToFactoryValues = {
            T1Value = 8,
            T2Value = 14,
            T3Value = 18,
        },
		RallyPointRadius = 36,
    },
	
    ExpansionFunction = function(aiBrain, location, markerType)
    
        if markerType !='Small Expansion Area' then
            return 0
        end
 
		-- get distance to closest threat greater than 10
        local distance = import('/lua/ai/AIUtilities.lua').GetThreatDistance( aiBrain, location, 10 )
		-- get island markers within 50
		local island = import('/lua/ai/AIUtilities.lua').AIGetMarkersAroundLocation( aiBrain, 'Island', location, 50 )
		
		if table.getn(island) > 0 then
			LOG("*AI DEBUG This DP is on an island..and BTW the threat distance value is "..distance)
			island = true
		else 
			island = false
		end
		
        if not distance or distance > 500 then
            return 100,island
        elseif distance > 250 then
            return 75,island
        else # within 250
            return 10,island
        end
        
        return 0,island
    end,
}