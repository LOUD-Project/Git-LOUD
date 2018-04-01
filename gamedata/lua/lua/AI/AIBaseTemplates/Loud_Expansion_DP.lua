--   /lua/ai/AIBaseTemplates/Loud_Expansion_DP.lua
--   tasks for a DP built on an Expansion/Start Point

BaseBuilderTemplate {
    BaseTemplateName = 'Loud_Expansion_DP',
    Builders = {
     	
		# Engineers reclaim, repair, assist
        'Engineer Builders',
		
		# Engineers Build Mass 
		'Extractor Builders - Expansions',

        # Build Defenses within the base
        'Base Defenses - Expansions',
		'Experimental Base Defenses - Expansions',
        
		# Various builds
        'Misc Engineer Builders - Expansions',
        
		# Create Platoons with Land Units
		'Point Guard Land Formations',
		'Base Guard Formations',
		'Base Reinforcement Formations',

		# Create Platoons with Air Units
		'Air Hunt Formations',
		'Point Guard Air Formations',        

		# ==== ARTILLERY BUILDERS ==== #
		'Artillery Builders - Expansions',
		'Artillery Formations',

        # ==== EXPERIMENTALS ==== #
		'Land Experimentals - Expansions',
		
		'Land Experimental Formations',
		'Air Experimental Formations',

		# ==== INTELLIGENCE ===== #
		'Air Scout Formations',
		'Land Scout Formations',
      
        'Radar Builders - Expansions',
        'Optics Builders',
    },
	
	WaterMapBuilders = {
		'Air Formations - Water Map',
		'Land Formations - Water Map',
		'Air Experimentals - Expansions - Water',

--		'Amphibious Formations',
	},
	
	LandOnlyBuilders = {
		'Land Formations - Land Map',
		'Air Experimentals - Expansions - Land',
	},
	
	LOUD_IS_Installed_Builders = {
--		'Mass Adjacency Defenses - LOUD_IS',
		'Mass Fab Builders - Expansions - LOUD_IS',
	},
	
	LOUD_IS_Not_Installed_Builders = {
--		'Mass Adjacency Defenses',
		'Mass Fab Builders - Expansions',
		'Mass Storage',
	},
	
    NonCheatBuilders = {},
	
    BaseSettings = {
        EngineerCount = {
            Tech1 = 1,
            Tech2 = 1,
            Tech3 = 1,
            SCU = 1,
        },
        FactoryCount = {
            LAND = 0,
            AIR = 0,
            SEA = 0,
            GATE = 0,
        },
        MassToFactoryValues = {
            T1Value = 8,
            T2Value = 14,
            T3Value = 19,
        },
		RallyPointRadius = 32,
    },
	
    ExpansionFunction = function(aiBrain, location, markerType)
        if markerType != 'Expansion Area' then
            return 0
        end
		
        local distance = import('/lua/ai/AIUtilities.lua').GetThreatDistance( aiBrain, location, 10 )
		local island = import('/lua/ai/AIUtilities.lua').AIGetMarkersAroundLocation( aiBrain, 'Island', location, 50 )
		
		if table.getn(island) > 0 then
			island = true
		else 
			island = false
		end
		
        if not distance or distance > 1000 then
            return 25,island
			
        elseif distance > 250 then
            return 100,island
			
        else
            return 10,island
        end
    end,
}