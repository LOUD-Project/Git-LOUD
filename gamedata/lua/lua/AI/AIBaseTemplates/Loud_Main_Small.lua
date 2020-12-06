-- This template is used on smaller maps and where unit cap may be an issue
-- it has only 10 factories and some buildergroups are disabled
BaseBuilderTemplate {
    BaseTemplateName = 'Loud_Main_Small',
    Builders = {
        # ==== ECONOMY ==== #

        # Build Engineers from Factories
        'Factory Production - Engineers',
     	
		# Engineers reclaim, repair, assist
        'Engineer Tasks',
		'Engineer Tasks - Reclaim Old Structures',
		
		'Engineer Transfers',		-- MAIN will transfer to expansions
        
        # Build Economy at this base
        'Engineer Energy Builders',
        'Engineer Mass Builders',
		'Engineer T4 Economy Construction - Small Base',        
  
		# Engineers & Bob build new factories
        'Engineer Factory Construction',
		'Engineer Quantum Gate Construction - Small Base',

        # Engineer Support buildings
		'Engineer Eng Station Construction',

        # ACU Tasks
        'ACU Tasks - Start Game',
        'ACU Tasks',
        
        # ==== EXPANSIONS ==== #
		'Engineer Land Expansion Construction',
		'Engineer Defensive Point Construction - Small',
        
        # ==== DEFENSES ==== #
        'Engineer Base Defense Construction - Core',
		'Engineer Base Defense Construction - Perimeter',

		'Engineer T4 Shield Construction',
       
        'Engineer Misc Construction - Small',
        
        # ==== LAND UNIT BUILDERS ==== #
		'Factory Production - Land',

        'Factory Producion - Land - Land Only Map',
        
		'Land Formations - Point Guards',
		'Land Formations - Base Guards',
		'Land Formations - Reinforcement',
        
        'Land Formations - Land Only Map',

        # ==== AIR UNIT BUILDERS ==== #
		'Factory Production - Air',
		'Factory Production - Transports',
		
		'Air Formations - Hunt',
		'Air Formations - Point Guards',        
		
		# ==== ARTILLERY BUILDERS ==== #
		'Engineer Artillery Construction',
		'Land Formations - Artillery',
        
		'Engineer Nuke Construction',
		'Land Formations - Nukes',
		
        # ==== EXPERIMENTALS ==== #
		'Engineer T4 Land Construction',
        
        'Engineer T4 Air Construction - Land Only Map',
        
		'Land Formations - Experimentals',

		'Air Formations - Experimentals',

		# ==== INTELLIGENCE ===== #
		'Air Formations - Scouts',
		'Land Formations - Scouts',

        'Engineer Optics Construction',
    },
	
	WaterMapBuilders = {
		'Engineer T4 Air Construction - Water Map',
		
        'Engineer Naval Expansion Construction',
		'Engineer Defensive Point Construction - Naval',
		
		'Factory Production - Torpedo Bombers',
		'Air Formations - Water Map',
		
		'Factory Producion - Land - Water Map',
		'Land Formations - Water Map',
		'Land Formations - Amphibious',
	},
	
	LandOnlyBuilders = {
		--'Factory Producion - Land - Land Only Map',
		--'Land Formations - Land Only Map',
		
		--'Engineer T4 Air Construction - Land Only Map',
	},
	
	StandardCommanderUpgrades = {
		'ACU Upgrades LOUD',
	},
	
	BOACUCommanderUpgrades = {
		'BOACU Upgrades LOUD',
	},
	
    -- IS = Integrated Storage --
	LOUD_IS_Installed_Builders = {

		'Engineer T4 Economy Defense Construction - LOUD IS - Small Base',
		'Engineer Shield Construction - LOUD_IS',
	},
	
	LOUD_IS_Not_Installed_Builders = {

		'Engineer Mass Storage Construction',
		'Engineer Energy Storage Construction',
		'Engineer T4 Economy Defense Construction - Small Base',
        'Engineer Shield Construction',
	},

    BaseSettings = {
	
        EngineerCount = {
            Tech1 = 6,
            Tech2 = 8,
            Tech3 = 6,
            SCU = 12,
        },
        FactoryCount = {
            LAND = 4,
            AIR = 5,
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