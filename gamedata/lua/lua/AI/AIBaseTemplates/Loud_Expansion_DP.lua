--   /lua/ai/AIBaseTemplates/Loud_Expansion_DP.lua
--   tasks for a DP built on an Expansion/Start Point

BaseBuilderTemplate {
    BaseTemplateName = 'Loud_Expansion_DP',
    Builders = {
     	
		# Engineers reclaim, repair, assist
        'Engineer Tasks',
		
		# Engineers Build Mass 
		'Engineer Mass Builders - Expansions',

        # Build Defenses within the base
        'Engineer Base Defense Construction - Core - Expansions',
        
		# Various builds
        'Engineer Misc Construction - Expansions',
        
		# Create Platoons with Land Units
		'Land Formations - Point Guards',
		'Land Formations - Base Guards',
		'Land Formations - Reinforcement',

		# Create Platoons with Air Units
		'Air Formations - Hunt',
		'Air Formations - Point Guards',        

		# ==== ARTILLERY BUILDERS ==== #
		'Engineer Artillery Construction - Expansions',
		'Land Formations - Artillery',

        # ==== EXPERIMENTALS ==== #
		'Engineer T4 Land Construction - Expansions',
		
		'Land Formations - Experimentals',
		'Air Formations - Experimentals',

		# ==== INTELLIGENCE ===== #
		'Air Formations - Scouts',
		'Land Formations - Scouts',
      
        'Engineer Radar Construction - Expansions',
        'Engineer Optics Construction',
    },
	
	WaterMapBuilders = {
		'Air Formations - Water Map',
		'Land Formations - Water Map',
		'Engineer T4 Air Construction - Water Map - Expansions',

--		'Land Formations - Amphibious',
	},
	
	LandOnlyBuilders = {
		'Land Formations - Land Map',
		'Engineer T4 Air Construction - Expansions',
	},
	
	LOUD_IS_Installed_Builders = {
--		'Mass Adjacency Defenses - LOUD_IS',
		'Engineer Mass Fab Construction - Expansions - LOUD_IS',
	},
	
	LOUD_IS_Not_Installed_Builders = {
--		'Mass Adjacency Defenses',
		'Engineer Mass Fab Construction - Expansions',
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