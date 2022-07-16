-- this is the full base layout suitable for 20k+ maps and large unit caps
BaseBuilderTemplate {
    BaseTemplateName = 'Loud_Main_Standard',
    Builders = {

        # ACU Tasks
        'ACU Tasks - Start Game',
        'ACU Tasks',

		# Build Factories
        'Engineer Factory Construction',
		'Engineer Quantum Gate Construction',

		# Engineers reclaim, repair, assist
        'Engineer Tasks',
		'Engineer Tasks - Reclaim Old Structures',

		'Engineer Transfers',		-- MAIN will transfer to expansions

        # Engineers Build Economy
        'Engineer Energy Builders',
        'Engineer Mass Builders',
		'Engineer T4 Economy Construction',
		'Engineer Eng Station Construction',

        # ==== EXPANSIONS ==== #
		'Engineer Land Expansion Construction',
		'Engineer Defensive Point Construction STD',

        # ==== DEFENSES ==== #
        'Engineer Base Defense Construction - Core',
		'Engineer Base Defense Construction - Perimeter',
		'Engineer Base Defense Construction - Picket Line',
		'Engineer T4 Shield Construction',
        'Engineer Misc Construction',
		'Engineer Mass Point Defense Construction',
		'Engineer Artillery Construction',
        'Engineer Optics Construction',        
		'Engineer Nuke Construction',

        'Engineer T4 Air Construction - Land Only Map',
        
        # ==== UNIT BUILDERS ==== #
        'Factory Production - Engineers',
		'Factory Production - Land',
		'Factory Production - Air',
		'Factory Production - Transports',
        
        'Factory Producion - Land - Land Only Map',
        
		'Engineer T4 Land Construction',

        # ==== PLATOON FORMATIONS ==== #
		'Land Formations - Scouts',        
		'Land Formations - Point Guards',
		'Land Formations - Base Guards',
		'Land Formations - Reinforcement',
		'Land Formations - Artillery',
		'Land Formations - Nukes',
		'Land Formations - Experimentals',
        
        'Land Formations - Land Only Map',
        
		'Air Formations - Scouts',        
		'Air Formations - Hunt',
		'Air Formations - Point Guards',
		'Air Formations - Experimentals',
    },
	
	WaterMapBuilders = {
		'Engineer T4 Air Construction - Water Map',
		
        'Engineer Naval Expansion Construction',
		'Engineer Defensive Point Construction - Naval',
		
		'Factory Production - Torpedo Bombers',
		'Factory Producion - Land - Water Map',

		'Air Formations - Water Map',		
		'Land Formations - Amphibious',
		'Land Formations - Water Map',
	},
	
	LandOnlyBuilders = {
		--'Engineer T4 Air Construction - Land Only Map',
        
		--'Factory Producion - Land - Land Only Map',
        
		--'Land Formations - Land Only Map',
	},
	
	StandardCommanderUpgrades = {
		'ACU Upgrades LOUD',
	},
	
	BOACUCommanderUpgrades = {
		'BOACU Upgrades LOUD',
	},
    
	-- Integrated Storage --
	LOUD_IS_Installed_Builders = {
    
        'Engineer Mass Energy Construction',
		'Engineer T4 Economy Defense Construction - LOUD IS',
		'Engineer Shield Construction - LOUD_IS',
	},
	
    -- Standard Storage --
	LOUD_IS_Not_Installed_Builders = {
		'Engineer Mass Storage Construction',
		'Engineer Energy Storage Construction',

		'Engineer T4 Economy Defense Construction',
		'Engineer Perimeter Shield Augmentation',
        'Engineer Shield Construction',
	},

    BaseSettings = {
    
		-- This controls the upper limit on the engineers at this base
        -- and are multiplied by cheating build multiplier        
        -- additionally these limits go up for unit caps of 1000+
        -- especially for the higher tier engineers
        -- these limits are calculated in the BelowEngineerCapCheck function
        EngineerCount = {
            Tech1 = 7,
            Tech2 = 9,
            Tech3 = 8,
            SCU = 12,
        },
        
		-- This controls the upper limit on factories at this base
        FactoryCount = {
            LAND = 7,
            AIR = 8,
            SEA = 0,
            GATE = 1,
        },
		
        -- This is not so easy to understand but what it does is tell the AI that he needs X amount of mass for each factory
        -- this is used to tell the AI when he has enough excess mass to build new factories and start new bases
        MassToFactoryValues = {
            T1Value = 8,
            T2Value = 14,
            T3Value = 20,
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
        local startX, startZ = aiBrain:GetArmyStartPos()
		
		LOG("*AI DEBUG Map Water Ratio is "..repr(aiBrain:GetMapWaterRatio()).."  Size is "..ScenarioInfo.size[1].."  Unit Cap for "..aiBrain.Nickname.." is "..GetArmyUnitCap(aiBrain.ArmyIndex))
        LOG("*AI DEBUG "..aiBrain.Nickname.." Start Position is "..repr( { startX, startZ } ))
        
        -- too close to the edge of the map for large footprint
        if (startX < 65 or startX > (mapSizeX - 65)) or (startZ < 65 or startZ > (mapSizeZ - 65)) then
        
            LOG("*AI DEBUG "..aiBrain.Nickname.." cannot use Standard base layout at this position - too close to edge of map")
        
            return 10, 'loud'
            
        end

        -- If we're playing on a 5k or 10k map we'll want the Small base
        if mapSizeX <= 512 or mapSizeZ <= 512 or GetArmyUnitCap(aiBrain.ArmyIndex) < 1000 then	--tonumber(ScenarioInfo.Options.UnitCap) < 1000 then
            return 10, 'loud'
			
        -- If we're playing on a 20k map or low pop - then maybe we'll go Standard
        elseif ((mapSizeX >= 1024 and mapSizeX < 2048) and (mapSizeZ >= 1024 and mapSizeZ < 2048)) then
        
            
            -- so - if it's a 20k map and there is a fair bit of water - there is not likely
            -- enough land for the large base
            if aiBrain:GetMapWaterRatio() > .20 then
            
                return 10, 'loud'
                
            else
                
                -- if it's a 20k map and the unit cap is less than 1500
                -- we'll make the large base as attractive as the small one 
                if GetArmyUnitCap(aiBrain.ArmyIndex) < 1500 then
            
                    return Random(10,60), 'loud'
                    
                else
                
                    -- otherwise we prefer the large base
                    return Random(50,100),'loud'
                    
                end
                
            end

		end
        
        -- any 40k+ map where the unit cap is less than 1500 or there is considerable water
        -- then go with the small base layout -- too much ground to cover for such a limited
        -- cap, or one that clearly is intended to be a water conflict
        if GetArmyUnitCap(aiBrain.ArmyIndex) < 1500 and aiBrain:GetMapWaterRatio() > .30 then
        
            return 10, 'loud'
            
        end
		
		-- anything else - go full size
        return 100, 'loud'
    end,
}