
BaseBuilderTemplate {
    BaseTemplateName = 'Loud_Expansion_Tiny',
    Builders = {
	
        # Build Engineers from Factories
        'Factory Production - Engineers',
     	
		# Engineers reclaim, repair, assist
        'Engineer Tasks',
		'Engineer Tasks - Reclaim Old Structures',

		# Engineers Build Mass 
		'Engineer Mass Builders - Expansions',
       
		# Engineers build new factories
        'Engineer Factory Construction - Expansions',

		# Various builds
        'Engineer Misc Construction - Expansions',
        
        # ==== LAND UNIT BUILDERS ==== #
		'Factory Production - Land',
        
        'Factory Producion - Land - Land Only Map',
        
		# Create Platoons with Land Units
		'Land Formations - Point Guards',
		'Land Formations - Base Guards',
		'Land Formations - Reinforcement',
        
        'Land Formations - Land Only Map',

        # ==== AIR UNIT BUILDERS ==== #
		'Factory Production - Air',

		# Create Platoons with Air Units
		'Air Formations - Hunt',
		'Air Formations - Point Guards',        
	
        # ==== EXPERIMENTALS ==== #
		'Engineer T4 Land Construction - Expansions',
        
        'Engineer T4 Air Construction - Expansions',
		
		'Land Formations - Experimentals',
		'Air Formations - Experimentals',

		# ==== INTELLIGENCE ===== #
		'Air Formations - Scouts',
		'Land Formations - Scouts',
      
        'Engineer Radar Construction - Expansions',
    },
	
	WaterMapBuilders = {
        'Engineer Naval Expansion Construction',
		'Engineer Defensive Point Construction - Naval',
		
		'Factory Production - Torpedo Bombers',
		'Air Formations - Water Map',
		
		'Factory Producion - Land - Water Map',
		'Land Formations - Water Map',

		'Land Formations - Amphibious',
		
		'Engineer T4 Air Construction - Water Map - Expansions',
	},
	
	LandOnlyBuilders = {
		--'Factory Producion - Land - Land Only Map',
		--'Land Formations - Land Only Map',
		--'Engineer T4 Air Construction - Expansions',
	},

	LOUD_IS_Installed_Builders = {
	},
	
	LOUD_IS_Not_Installed_Builders = {
		'Engineer Mass Storage Construction',
		'Engineer Energy Storage Construction',
	},

	
    BaseSettings = {
        EngineerCount = {
            Tech1 = 1,
            Tech2 = 2,
            Tech3 = 2,
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
            T3Value = 20,
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
			--LOG("*AI DEBUG This DP is on an island..and BTW the threat distance value is "..distance)
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