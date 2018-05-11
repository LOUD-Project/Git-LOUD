
BaseBuilderTemplate {
    BaseTemplateName = 'Loud_Expansion_Small',
    Builders = {

        # Build Engineers from Factories
        'Engineer Factory Builders Expansion',
     	
		# Engineers reclaim, repair, assist
        'Engineer Builders',
		'Engineer Tasks - Aux',
        
        # Build energy at this base
        'Energy Builders - Expansions',
		
		# Engineers Build Mass 
		'Extractor Builders - Expansions',
       
		# Engineers build new factories
        'Factory Construction - Expansions',

        # Create New Land Bases & Active DP
		'Land Expansion Builders',
		'DP Builders Small',
        
        # Build Defenses within the base
        'Base Defenses - Expansions',
		'Experimental Base Defenses - Expansions',
		
		# Build Defenses at perimeter of base
		'T2 Perimeter Expansions',
		'T3 Perimeter Expansions',
        
		# Build Shield Matrix at Base
		'Shields - Experimental - Expansions',
        
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
		'Transport Factory Builders',

		# Create Platoons with Air Units
		'Air Hunt Formations',
		'Point Guard Air Formations',        

		# ==== ARTILLERY BUILDERS ==== #
		'Artillery Builders - Expansions',
		'Artillery Formations',
        
		'Nuke Builders - Expansions',
		'Nuke Formations',
	
        # ==== EXPERIMENTALS ==== #
		'Land Experimentals - Expansions',
		'Economic Experimental Builders - Expansions',
		
		'Land Experimental Formations',
		'Air Experimental Formations',


		# ==== INTELLIGENCE ===== #
		'Air Scout Formations',
		'Land Scout Formations',
      
        'Radar Builders - Expansions',
        'Optics Builders',
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
		'Mass Fab Builders - Expansions - LOUD_IS',
        'Shields - Expansions - LOUD_IS',
	},
	
	LOUD_IS_Not_Installed_Builders = {
		'Mass Fab Builders - Expansions',
		'Mass Storage',
		'Energy Storage',
        'Shields - Expansions',
	},
	
    BaseSettings = {
        EngineerCount = {
            Tech1 = 2,
            Tech2 = 3,
            Tech3 = 3,
            SCU = 8,
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
            T3Value = 19,
        },
		RallyPointRadius = 42,
    },
	
    ExpansionFunction = function(aiBrain, location, markerType)
	
        if markerType != 'Start Location' and markerType != 'Large Expansion Area' and markerType != 'Small Expansion Area' then
            return 0
        end

		-- get the distance to closest threat greater than 10
        local distance = import('/lua/ai/AIUtilities.lua').GetThreatDistance( aiBrain, location, 10 )
		-- get any island markers within 50
		local island = import('/lua/ai/AIUtilities.lua').AIGetMarkersAroundLocation( aiBrain, 'Island', location, 50 )
		
		if table.getn(island) > 0 then
			LOG("*AI DEBUG This DP is on an island..and BTW the threat distance value is "..distance)
			island = true
		else 
			island = false
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