-- This template is used on smaller maps and where unit cap may be an issue
-- it has only 10 factories and some buildergroups are disabled
BaseBuilderTemplate {
    BaseTemplateName = 'Loud_Main_Small',
    Builders = {
        # ==== ECONOMY ==== #

        # Build Engineers from Factories
        'Engineer Factory Builders',
     	
		# Engineers reclaim, repair, assist
        'Engineer Builders',
		'Engineer Tasks - Aux',
		
		'Engineer Transfers',		-- MAIN will transfer to expansions
        
        # Build energy at this base
        'Energy Builders',
     
		# Engineers Build Mass 
        'Extractor Builders',
  
		# Engineers & Bob build new factories
        'Factory Construction',
		'Quantum Gate Construction - Small Base',

        # Engineer Support buildings
		'Engineering Support Builder',

        # ACU Builders
        'Loud Initial ACU Builders',
        'ACU Builders',
        
        # ==== EXPANSIONS ==== #
		'Land Expansion Builders',
		'DP Builders Small',
        
        # ==== DEFENSES ==== #
        'Base Defenses',
		'Experimental Base Defenses',
		
		'T1 Perimeter Defenses',
		'T2 Perimeter Defenses',
		'T3 Perimeter Defenses',
		
		'Shields - Experimental',
       
        'Misc Engineer Builders - Small Base',
        
        # ==== LAND UNIT BUILDERS ==== #
		'Land Factory Builders',

		'Point Guard Land Formations',
		'Base Guard Formations',
		--'Base Reinforcement Formations',

        # ==== AIR UNIT BUILDERS ==== #
		'Air Factory Builders',
		'Transport Factory Builders',
		
		'Air Hunt Formations',
		'Point Guard Air Formations',        
		
		# ==== ARTILLERY BUILDERS ==== #
		'Artillery Builders',
		'Artillery Formations',
        
		'Nuke Builders',
		'Nuke Formations',
		
        # ==== EXPERIMENTALS ==== #
		'Land Experimental Builders',
		'Land Experimental Formations',

		'Air Experimental Formations',
		
		'Economic Experimental Builders',

		# ==== INTELLIGENCE ===== #
		'Air Scout Formations',
		'Land Scout Formations',

        'Optics Builders',
    },
	
	WaterMapBuilders = {
		'Air Experimental Builders - Water Map',
		
        'Naval Base Builders',
		'Naval Defensive Points',
		
		'Air Builders - Water Map',
		'Air Formations - Water Map',
		
		'Land Builders - Water Map',
		'Land Formations - Water Map',
		'Amphibious Formations',
	},
	
	LandOnlyBuilders = {
		'Land Builders - Land Map',
		'Land Formations - Land Map',
		
		'Air Experimental Builders - Land Map',
	},
	
	StandardCommanderUpgrades = {
		'ACU Upgrades LOUD',
		'ACU Builders - Standard',
	},
	
	BOACUCommanderUpgrades = {
		'BOACU Upgrades LOUD',
		'ACU Builders - BOACU',
	},
	
	LOUD_IS_Installed_Builders = {
		'Mass Fab Builders - LOUD_IS',
		'Economic Experimental Defense Builders - LOUD_IS',
		'Shields - LOUD_IS',
	},
	
	LOUD_IS_Not_Installed_Builders = {
		'Mass Fab Builders',
		'Mass Storage',
		'Energy Storage',
		'Economic Experimental Defense Builders',
        'Shields',
	},
	
    
    NonCheatBuilders = {
        'Radar Builders',
    },
    
    BaseSettings = {
	
        EngineerCount = {
            Tech1 = 6,
            Tech2 = 8,
            Tech3 = 6,
            SCU = 10,
        },
        FactoryCount = {
            LAND = 5,
            AIR = 4,
            SEA = 0,
            GATE = 1,
        },
        MassToFactoryValues = {
            T1Value = 6,
            T2Value = 12,
            T3Value = 19,
        },
		RallyPointRadius = 42,
    },
	
	-- this type of base can never be built once the game is underway
	-- it is only built at the start of a game -- therefore it will
	-- always return a value of zero 
    ExpansionFunction = function(aiBrain, location, markerType)
        return 0
    end,
	
	-- it is however the primary Starting base so it has this function
    FirstBaseFunction = function(aiBrain)

        local mapSizeX, mapSizeZ = GetMapSize()

        -- If we're playing on a 5k or 10k map or low pop
        if (mapSizeX <= 512 or mapSizeZ <= 512) or GetArmyUnitCap(aiBrain.ArmyIndex) < 1000 then 	--tonumber(ScenarioInfo.Options.UnitCap) < 1000 then
            return 100, 'loud'
			
        -- If we're playing on a 20k map
        elseif (mapSizeX >= 1024 and mapSizeX <= 2047) and (mapSizeZ >= 1024 and mapSizeZ <= 2048) then
            return Random(60, 100), 'loud'
		
		end

		-- if we're playing on anything larger
        return 25, 'loud'
    end,
}