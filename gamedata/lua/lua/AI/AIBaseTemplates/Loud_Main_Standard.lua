-- this is the full base layout suitable for 20k+ maps and large unit caps
BaseBuilderTemplate {
    BaseTemplateName = 'Loud_Main_Standard',
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
		'Quantum Gate Construction',

        # Engineer Support buildings
		'Engineering Support Builder',

        # ACU Builders
        'Loud Initial ACU Builders',
        'ACU Builders',
        
        # ==== EXPANSIONS ==== #
		'Land Expansion Builders',
		'DP Builders Standard',
        
        # ==== DEFENSES ==== #
        'Base Defenses',
		'Experimental Base Defenses',
		
		'T1 Perimeter Defenses',
		'T2 Perimeter Defenses',
		'T3 Perimeter Defenses',
		
		'Picket Line Defenses',
		
		'Shields - Experimental',
        
        'Misc Engineer Builders',
        
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
		'Mass Adjacency Defenses - LOUD_IS',
		'Mass Fab Builders - LOUD_IS',
		'Energy Facility - LOUD_IS',
		'Economic Experimental Defense Builders - LOUD_IS',
		'Shields - LOUD_IS',
	},
	
	LOUD_IS_Not_Installed_Builders = {
		'Mass Adjacency Defenses',
		'Mass Fab Builders',
		'Mass Storage',
		'Energy Storage',
		'Energy Facility',
		'Economic Experimental Defense Builders',
		'Perimeter Shield Augmentation',
        'Shields',
	},
	
    
    NonCheatBuilders = {
        'Radar Builders',
    },
    
    BaseSettings = {
		-- This controls the upper limit on the engineers at this base
        EngineerCount = {
            Tech1 = 7,
            Tech2 = 9,
            Tech3 = 8,
            SCU = 10,
        },
		-- This controls the upper limit on factories at this base
        FactoryCount = {
            LAND = 6,
            AIR = 6,
            SEA = 0,
            GATE = 1,
        },
		
        -- This is not so easy to understand but what it does is tell the AI that he needs X amount of mass for each factory
        -- this is used to tell the AI when he has enough excess mass to build new factories and start new bases
        MassToFactoryValues = {
            T1Value = 6,
            T2Value = 11,
            T3Value = 18,
        },
		
		-- this controls the generation of rally points around the base
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
		
		--LOG("*AI DEBUG Map Water Ratio is "..repr(aiBrain:GetMapWaterRatio()).."  Size is "..ScenarioInfo.size[1].."  Unit Cap for "..aiBrain.Nickname.." is "..GetArmyUnitCap(aiBrain.ArmyIndex))

        -- If we're playing on a 5k or 10k map
        if mapSizeX <= 512 or mapSizeZ <= 512 or GetArmyUnitCap(aiBrain.ArmyIndex) < 1000 then	--tonumber(ScenarioInfo.Options.UnitCap) < 1000 then
            return 10, 'loud'
			
        -- If we're playing on a 20k map or low pop
        elseif ((mapSizeX >= 1024 and mapSizeX < 2048) and (mapSizeZ >= 1024 and mapSizeZ < 2048)) then
            return Random(10,60), 'loud'
			
		end
		
		-- anything else
        return 100, 'loud'
    end,
}