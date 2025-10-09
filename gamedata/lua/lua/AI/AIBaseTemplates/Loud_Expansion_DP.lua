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
		'Land Formations - Scouts',
		'Land Formations - Point Guards',
		'Land Formations - Base Guards',
		'Land Formations - Experimentals',
        'Land Formations - Land Only Map',
		'Land Formations - Reinforcement',

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

        # ==== EXPERIMENTALS ==== #
		'Engineer T4 Construction Land - Expansions',
        'Engineer T4 Construction Air - Land Map - Expansions',

		# ==== INTELLIGENCE ===== #
        'Engineer Radar Construction - Expansions',
        'Engineer Optics Construction',
    },
	
	WaterMapBuilders = {
		'Air Formations - Water Map',
		'Land Formations - Water Map',
		'Engineer T4 Construction Air - Water Map - Expansions',
	},
	
	LandOnlyBuilders = {},
	
	LOUD_IS_Installed_Builders = {
		'Engineer Mass Fab Construction - Expansions - LOUD_IS',
	},
	
	LOUD_IS_Not_Installed_Builders = {
		'Engineer Mass Fab Construction - Expansions',
		'Mass Storage',
	},

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
            T3Value = 20,
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