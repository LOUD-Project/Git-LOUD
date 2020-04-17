#**  File     :  /lua/ai/Loud_AI_Formation_Air_Builders.lua

local UCBC = '/lua/editor/UnitCountBuildConditions.lua'
local EBC = '/lua/editor/EconomyBuildConditions.lua'
local LUTL = '/lua/loudutilities.lua'
local BHVR = '/lua/ai/aibehaviors.lua'


local NotPrimaryBase = function( self,aiBrain,manager)

	if (not aiBrain.BuilderManagers[manager.LocationType].PrimaryLandAttackBase) and (not aiBrain.BuilderManagers[manager.LocationType].PrimarySeaAttackBase)  then
		return 720, false
	end

	return self.Priority, true
end

local IsPrimaryBase = function(self,aiBrain,manager)
	
	if aiBrain.BuilderManagers[manager.LocationType].PrimaryLandAttackBase or aiBrain.BuilderManagers[manager.LocationType].PrimarySeaAttackBase then
		return self.Priority, true
	end

	return 10, true
end

-- These are the standard air scout patrols around a base
BuilderGroup {BuilderGroupName = 'Air Formations - Scouts',
    BuildersType = 'PlatoonFormBuilder',
	
    -- Perimeter air scouts are maintained at all bases
    Builder {BuilderName = 'Air Scout Peri - 200',
	
        PlatoonTemplate = 'Air Scout Formation',
        
		PlatoonAIPlan = 'PlatoonPatrolPointAI',
		
        Priority = 810,
		
        BuilderType = 'Any',
		
		BuilderConditions = {
			{ UCBC, 'PoolGreaterAtLocation', { 'LocationType', 0, categories.AIR * categories.SCOUT }},
		},
		
		BuilderData = {
			BasePerimeterOrientation = 'ALL',        
			Radius = 200,
			PatrolTime = 1000,
		},
    },
	
    Builder {BuilderName = 'Air Scout Peri - 290',
	
        PlatoonTemplate = 'Air Scout Formation',
        
		PlatoonAIPlan = 'PlatoonPatrolPointAI',
		
        Priority = 809,
		
        InstanceCount = 1,
		
        BuilderType = 'Any',
		
		BuilderConditions = {
			{ UCBC, 'PoolGreaterAtLocation', { 'LocationType', 0, categories.AIR * categories.SCOUT - categories.TECH1 }},
		},
		
		BuilderData = {
			BasePerimeterOrientation = 'ALL',        
			Radius = 290,
			PatrolTime = 1200,
		},
    },

    Builder {BuilderName = 'Air Scout Peri - 380',
	
        PlatoonTemplate = 'Air Scout Formation',
        
		PlatoonAIPlan = 'PlatoonPatrolPointAI',
		
        Priority = 808,
		
        InstanceCount = 2,
		
        BuilderType = 'Any',
		
		BuilderConditions = {
			{ UCBC, 'PoolGreaterAtLocation', { 'LocationType', 0, categories.AIR * categories.SCOUT - categories.TECH1 }},
		},
		
		BuilderData = {
			BasePerimeterOrientation = 'ALL',
			Radius = 380,
			PatrolTime = 1200,
		},
    },

    -- this one only appears at PRIMARY bases
    Builder {BuilderName = 'Air Scout Peri - 460',
	
        PlatoonTemplate = 'Air Scout Formation',
        
		PlatoonAIPlan = 'PlatoonPatrolPointAI',
		
        Priority = 807,
        
        PriorityFunction = IsPrimaryBase,
		
		InstanceCount = 3,
		
        BuilderType = 'Any',
		
		BuilderConditions = {
			{ UCBC, 'PoolGreaterAtLocation', { 'LocationType', 0, categories.AIR * categories.SCOUT - categories.TECH1 }},
		},
		
		BuilderData = {
			BasePerimeterOrientation = 'ALL',        
			Radius = 460,
			PatrolTime = 1200,
		},
    },


-- Field air scouts come after that
	
    -- single plane formation for first 30 minutes
    Builder {BuilderName = 'Air Scout - Standard',
    
        PlatoonTemplate = 'Air Scout Formation',
        
		PlatoonAIPlan = 'ScoutingAI',
        
		Priority = 806,
		
		-- this function removes the builder after 45 minutes
		PriorityFunction = function(self, aiBrain)
		
			if self.Priority != 0 then
				if aiBrain.CycleTime > 2700 then
					return 0, false
				end
			end
			
			return self.Priority,true
		end,
		
        InstanceCount = 10,
		
        BuilderType = 'Any',
		
		BuilderConditions = {
			{ UCBC, 'PoolGreaterAtLocation', { 'LocationType', 0, categories.AIR * categories.SCOUT }},
		},
		
		BuilderData = {},
    },
    
	-- double plane formation for 30-75 minutes - 8 instances
    Builder {BuilderName = 'Air Scout - Pair',
    
        PlatoonTemplate = 'Air Scout Group',
        
		PlatoonAIPlan = 'ScoutingAI',
        
        Priority = 10,
		
		-- this function turns the builder on at 30 minutes and removes it at 70 minutes 
		PriorityFunction = function(self, aiBrain)
			
			if self.Priority != 0 then
				
				if aiBrain.CycleTime > 1800 then
					return 806, true
				end
			
				if aiBrain.CycleTime > 4500 then
					return 0, false
				end
			end
			
			return self.Priority,true
		end,

        InstanceCount = 8,
		
        BuilderType = 'Any',
		
		BuilderConditions = {
			{ UCBC, 'PoolGreaterAtLocation', { 'LocationType', 1, categories.AIR * categories.SCOUT }},
		},
		
		BuilderData = {},
    },

	-- wing (5) formations at 60 minutes - 6 instances
    Builder {BuilderName = 'Air Scout - Wing',
    
        PlatoonTemplate = 'Air Scout Group Large',
        
		PlatoonAIPlan = 'ScoutingAI',
        
        Priority = 10,
		
		-- this function turns the builder on at the 60 minute mark
		PriorityFunction = function(self, aiBrain)
			
			if self.Priority != 805 then
			
				if aiBrain.CycleTime > 3600 then
					return 805, false
				end
			end
			
			return self.Priority,true
		end,
		
        InstanceCount = 6,
		
        BuilderType = 'Any',
		
		BuilderConditions = {
			{ UCBC, 'PoolGreaterAtLocation', { 'LocationType', 4, categories.AIR * categories.SCOUT * categories.TECH3 }},
		},
		
		BuilderData = {},
    },
    
	-- squadron (9) formations after 75 minutes - 5 instances
    Builder {BuilderName = 'Air Scout - Group',
    
        PlatoonTemplate = 'Air Scout Group Huge',
        
		PlatoonAIPlan = 'ScoutingAI',
        
        Priority = 10,
		
		-- this function will turn the builder on at the 75 minute mark
		PriorityFunction = function(self, aiBrain)
		
			if self.Priority != 806 then
			
				if aiBrain.CycleTime > 4500 then
					return 806, false
				end
			end
			
			return self.Priority,true
		end,

        InstanceCount = 5,
		
        BuilderType = 'Any',
		
		BuilderConditions = {
			{ UCBC, 'PoolGreaterAtLocation', { 'LocationType', 8, categories.AIR * categories.SCOUT * categories.TECH3 }},
		},
		
		BuilderData = {},
    },

}

BuilderGroup {BuilderGroupName = 'Air Formations - Hunt',
    BuildersType = 'PlatoonFormBuilder',
    
    ---------------
    --- BOMBERS ---
    ---------------
    -- small size short range groups that can merge quickly
    -- operates at ANY kind of base 
    Builder {BuilderName = 'Hunt Bombers Defensive',
	
        PlatoonTemplate = 'BomberAttack Small',
        
		PlatoonAddFunctions = { {BHVR, 'BroadcastPlatoonPlan'} },
		
		PlatoonAddPlans = { 'DistressResponseAI' },
		
		PlatoonAIPlan = 'AttackForceAI_Bomber',		
		
        Priority = 700,
        InstanceCount = 3,
		
        BuilderConditions = {
			{ UCBC, 'PoolGreaterAtLocation', { 'LocationType', 0, categories.HIGHALTAIR * categories.BOMBER - categories.ANTINAVY }},
        },
		
        BuilderData = {
			DistressRange = 100,
			DistressTypes = 'Land',
			DistressThreshold = 5,
			
			LocationType = 'LocationType',
			
            MergeLimit = 12,
			
            MissionTime = 90,
			
            PrioritizedCategories = {categories.MOBILE - categories.AIR},
			
			SearchRadius = 30,	
			
            UseFormation = 'AttackFormation',
        },
		
        BuilderType = 'Any',
    },

	-- medium sized group for close targets and distress response
    -- operates only from a PRIMARY BASE - Land or Naval
    Builder {BuilderName = 'Hunt Bombers Local',
	
        PlatoonTemplate = 'BomberAttack',
        
		PlatoonAddFunctions = { {BHVR, 'BroadcastPlatoonPlan'} },
		
		PlatoonAddPlans = { 'DistressResponseAI' },
		
		PlatoonAIPlan = 'AttackForceAI_Bomber',		

        Priority = 710,
		
		PriorityFunction = IsPrimaryBase,
		
        InstanceCount = 2,

        BuilderConditions = {
			{ UCBC, 'PoolGreaterAtLocation', { 'LocationType', 11, categories.HIGHALTAIR * categories.BOMBER - categories.ANTINAVY }},
        },
		
        BuilderData = {
			DistressRange = 150,
			DistressTypes = 'Land',
			DistressThreshold = 10,
			
			LocationType = 'LocationType',
			
            MergeLimit = 25,
			
            MissionTime = 150,
			
            PrioritizedCategories = { categories.MOBILE - categories.AIR, categories.MASSEXTRACTION, categories.ENERGYPRODUCTION - categories.TECH1, categories.FACTORY},
			
			SearchRadius = 50,
			
            UseFormation = 'AttackFormation',
        },
		
        BuilderType = 'Any',
    },

	-- large group for most targets on 20k maps and distress response 
    -- operates only from a PRIMARY BASE - Land or Naval	
    Builder {BuilderName = 'Hunt Bombers Large',
	
        PlatoonTemplate = 'BomberAttack Large',
        
		PlatoonAddFunctions = { {BHVR, 'BroadcastPlatoonPlan'} },
		
		PlatoonAddPlans = { 'DistressResponseAI' },
		
		PlatoonAIPlan = 'AttackForceAI_Bomber',		

        Priority = 720,

		PriorityFunction = IsPrimaryBase,
		
        InstanceCount = 2,

        BuilderConditions = {
            { LUTL, 'AirStrengthRatioGreaterThan', { 3 } },  
			
			-- none of the major SUPER triggers can be true
			{ UCBC, 'HaveLessThanUnitsWithCategoryAndAlliance', { 1, categories.NUKE + categories.ANTIMISSILE - categories.TECH2, 'Enemy' }},
			{ UCBC, 'HaveLessThanUnitsWithCategoryAndAlliance', { 1, (categories.OPTICS) * categories.STRUCTURE, 'Enemy' }},
			{ UCBC, 'HaveLessThanUnitsWithCategoryAndAlliance', { 1, categories.ARTILLERY * categories.STRUCTURE * (categories.EXPERIMENTAL + categories.TECH3), 'Enemy' }},
			{ UCBC, 'HaveLessThanUnitsWithCategoryAndAlliance', { 1, categories.ECONOMIC * categories.EXPERIMENTAL, 'Enemy' }},			
			
			{ UCBC, 'PoolGreaterAtLocation', { 'LocationType', 19, categories.HIGHALTAIR * categories.BOMBER - categories.ANTINAVY }},
        },
		
        BuilderData = {
			DistressRange = 220,
			DistressTypes = 'Land',
			DistressThreshold = 20,
			LocationType = 'LocationType',
            MergeLimit = 64,
            MissionTime = 240,
            PrioritizedCategories = {categories.COMMAND, categories.SUBCOMMANDER, categories.MOBILE - categories.AIR, categories.MASSEXTRACTION, categories.SHIELD, categories.FACTORY, categories.ECONOMIC - categories.TECH1},
			SearchRadius = 125,
            UseFormation = 'AttackFormation',
        },
		
        BuilderType = 'Any',
    },

	-- ALL SUPER groups are specifically targeted and come into play when the selected targets are available
	-- the DO NOT respond to distress calls	-- they'll search for targets upto 30km away
	-- they all have short mission timers so they go - fight - and go home
    -- affectionately called 'Cambodia Raids'
    Builder {BuilderName = 'Hunt Bombers - AntiAir',
	
        PlatoonTemplate = 'BomberAttack Super',
		
		PlatoonAddFunctions = { {BHVR, 'BroadcastPlatoonPlan'} },
		
		PlatoonAIPlan = 'AttackForceAI_Bomber',		
		
        Priority = 710,
		
		PriorityFunction = IsPrimaryBase,

        InstanceCount = 1,
		
        BuilderConditions = {
            { LUTL, 'NoBaseAlert', { 'LocationType' }},		
            { LUTL, 'AirStrengthRatioGreaterThan', { 3 } },
			{ LUTL, 'HaveGreaterThanUnitsWithCategoryAndAlliance', { 0, categories.ANTIAIR * categories.STRUCTURE * categories.EXPERIMENTAL, 'Enemy' }},

			{ UCBC, 'PoolGreaterAtLocation', { 'LocationType', 24, categories.HIGHALTAIR * categories.BOMBER - categories.ANTINAVY }},
        },
		
        BuilderData = {
			LocationType = 'LocationType',
            MergeLimit = false,
            MissionTime = 400,
            PrioritizedCategories = {categories.ANTIAIR * categories.STRUCTURE * categories.EXPERIMENTAL},
			SearchRadius = 850,
            UseFormation = 'AttackFormation',
        },
		
        BuilderType = 'Any',        
    },
	
    Builder {BuilderName = 'Hunt Bombers - Artillery',
	
        PlatoonTemplate = 'BomberAttack Super',
		
		PlatoonAddFunctions = { {BHVR, 'BroadcastPlatoonPlan'} },
		
		PlatoonAIPlan = 'AttackForceAI_Bomber',		
		
        Priority = 710,
		
		PriorityFunction = IsPrimaryBase,

        InstanceCount = 1,
		
        BuilderConditions = {
            { LUTL, 'NoBaseAlert', { 'LocationType' }},		
            { LUTL, 'AirStrengthRatioGreaterThan', { 3 } },
			{ LUTL, 'HaveGreaterThanUnitsWithCategoryAndAlliance', { 0, categories.ARTILLERY * categories.STRUCTURE * (categories.EXPERIMENTAL + categories.TECH3), 'Enemy' }},

			{ UCBC, 'PoolGreaterAtLocation', { 'LocationType', 24, categories.HIGHALTAIR * categories.BOMBER - categories.ANTINAVY }},
        },
		
        BuilderData = {
			LocationType = 'LocationType',
            MergeLimit = false,
            MissionTime = 400,
            PrioritizedCategories = {categories.ARTILLERY * categories.STRUCTURE * (categories.EXPERIMENTAL + categories.TECH3)},
			SearchRadius = 850,
            UseFormation = 'AttackFormation',
        },
		
        BuilderType = 'Any',		
    },

    Builder {BuilderName = 'Hunt Bombers - Economic Experimental',
	
        PlatoonTemplate = 'BomberAttack Super',
        
		PlatoonAddFunctions = { {BHVR, 'BroadcastPlatoonPlan'} },
		
		PlatoonAIPlan = 'AttackForceAI_Bomber',		
		
        Priority = 710,
		
		PriorityFunction = IsPrimaryBase,

        InstanceCount = 1,

        BuilderConditions = {
            { LUTL, 'NoBaseAlert', { 'LocationType' }},		
            { LUTL, 'AirStrengthRatioGreaterThan', { 3 } },
			{ LUTL, 'HaveGreaterThanUnitsWithCategoryAndAlliance', { 0, categories.ECONOMIC * categories.EXPERIMENTAL, 'Enemy' }},

			{ UCBC, 'PoolGreaterAtLocation', { 'LocationType', 24, categories.HIGHALTAIR * categories.BOMBER - categories.ANTINAVY }},
        },
		
        BuilderData = {
			LocationType = 'LocationType',
            MergeLimit = false,
            MissionTime = 400,
            PrioritizedCategories = {categories.ECONOMIC * categories.EXPERIMENTAL},
			SearchRadius = 850,
            UseFormation = 'AttackFormation',
        },
		
        BuilderType = 'Any',        
    },
	
    Builder {BuilderName = 'Hunt Bombers - Nuke Antinuke',
	
        PlatoonTemplate = 'BomberAttack Super',
        
		PlatoonAddFunctions = { {BHVR, 'BroadcastPlatoonPlan'} },
		
		PlatoonAIPlan = 'AttackForceAI_Bomber',		

        Priority = 710,
		
		PriorityFunction = IsPrimaryBase,
		
        InstanceCount = 2,
		
        BuilderConditions = {
            { LUTL, 'AirStrengthRatioGreaterThan', { 3 } },
			{ LUTL, 'HaveGreaterThanUnitsWithCategoryAndAlliance', { 0, categories.NUKE + categories.ANTIMISSILE - categories.TECH2, 'Enemy' }},

			{ UCBC, 'PoolGreaterAtLocation', { 'LocationType', 24, categories.HIGHALTAIR * categories.BOMBER - categories.ANTINAVY }},
        },
		
        BuilderData = {
			LocationType = 'LocationType',
            MergeLimit = false,
            MissionTime = 400,
            PrioritizedCategories = {categories.NUKE + categories.ANTIMISSILE - categories.TECH2},
			SearchRadius = 850,
            UseFormation = 'AttackFormation',
        },
		
        BuilderType = 'Any',        
    },
	
    Builder {BuilderName = 'Hunt Bombers - Optics',
	
        PlatoonTemplate = 'BomberAttack Super',
        
		PlatoonAddFunctions = { {BHVR, 'BroadcastPlatoonPlan'} },
		
		PlatoonAIPlan = 'AttackForceAI_Bomber',		
		
        Priority = 710,
		
		PriorityFunction = IsPrimaryBase,
		
        InstanceCount = 1,
		
        BuilderConditions = {
            { LUTL, 'NoBaseAlert', { 'LocationType' }},		
            { LUTL, 'AirStrengthRatioGreaterThan', { 3 } },
			{ LUTL, 'HaveGreaterThanUnitsWithCategoryAndAlliance', { 0, (categories.OPTICS) * categories.STRUCTURE, 'Enemy' }},

			{ UCBC, 'PoolGreaterAtLocation', { 'LocationType', 24, categories.HIGHALTAIR * categories.BOMBER - categories.ANTINAVY }},
        },
		
        BuilderData = {
			LocationType = 'LocationType',
            MergeLimit = false,
            MissionTime = 400,
            PrioritizedCategories = { (categories.OPTICS) * categories.STRUCTURE},
			SearchRadius = 850,
            UseFormation = 'AttackFormation',
        },
		
        BuilderType = 'Any',		
    },

    ---------------
    --- FIGHTERS --
    ---------------
    -- small size short range groups that can merge quickly
    -- operates at ANY kind of base 
    Builder {BuilderName = 'Hunt Fighters Defensive',
	
        PlatoonTemplate = 'FighterAttack Small',
        
		PlatoonAddFunctions = { {BHVR, 'BroadcastPlatoonPlan'} },
		
		PlatoonAddPlans = { 'DistressResponseAI' },
		
		PlatoonAIPlan = 'AttackForceAI',		
		
        Priority = 700,
        InstanceCount = 2,
		
        BuilderConditions = {
			{ UCBC, 'PoolGreaterAtLocation', { 'LocationType', 0, categories.HIGHALTAIR * categories.ANTIAIR - categories.ANTINAVY }},
        },
		
        BuilderData = {
			DistressRange = 120,
			DistressTypes = 'Air',
			DistressThreshold = 4,
			
			LocationType = 'LocationType',
			
            MergeLimit = 16,
			
            MissionTime = 90,
			
            PrioritizedCategories = {categories.MOBILE * categories.AIR - categories.INTELLIGENCE},
			
			SearchRadius = 40,	
			
            UseFormation = 'AttackFormation',
        },
		
        BuilderType = 'Any',
    },

	-- medium sized group for close targets and distress response
    -- operates only from a PRIMARY BASE - Land or Naval   
    Builder {BuilderName = 'Hunt Fighters Local',
	
        PlatoonTemplate = 'FighterAttack',
        
		PlatoonAddFunctions = { {BHVR, 'BroadcastPlatoonPlan'} },
		
		PlatoonAddPlans = { 'DistressResponseAI' },
		
		PlatoonAIPlan = 'AttackForceAI',		

        Priority = 710,
		
		PriorityFunction = IsPrimaryBase,
		
        InstanceCount = 2,

        BuilderConditions = {
			{ UCBC, 'PoolGreaterAtLocation', { 'LocationType', 15, categories.HIGHALTAIR * categories.ANTIAIR }},
        },
		
        BuilderData = {
			DistressRange = 160,
			DistressTypes = 'Air',
			DistressThreshold = 8,
			
			LocationType = 'LocationType',
			
            MergeLimit = 32,
			
            MissionTime = 150,
			
            PrioritizedCategories = { categories.MOBILE * categories.AIR - categories.INTELLIGENCE},
			
			SearchRadius = 65,
			
            UseFormation = 'AttackFormation',
        },
		
        BuilderType = 'Any',
    },

	-- large group for most targets on 20k maps and distress response 
    -- operates only from a PRIMARY BASE - Land or Naval	    
    Builder {BuilderName = 'Hunt Fighters Large',
	
        PlatoonTemplate = 'FighterAttack Large',
        
		PlatoonAddFunctions = { {BHVR, 'BroadcastPlatoonPlan'} },
		
		PlatoonAddPlans = { 'DistressResponseAI' },
		
		PlatoonAIPlan = 'AttackForceAI',		

        Priority = 720,

		PriorityFunction = IsPrimaryBase,
		
        InstanceCount = 1,

        BuilderConditions = {
			
			-- none of the major SUPER triggers can be true
			--{ UCBC, 'HaveLessThanUnitsWithCategoryAndAlliance', { 1, categories.NUKE + categories.ANTIMISSILE - categories.TECH2, 'Enemy' }},
			--{ UCBC, 'HaveLessThanUnitsWithCategoryAndAlliance', { 1, (categories.OPTICS) * categories.STRUCTURE, 'Enemy' }},
			--{ UCBC, 'HaveLessThanUnitsWithCategoryAndAlliance', { 1, categories.ARTILLERY * categories.STRUCTURE * (categories.EXPERIMENTAL + categories.TECH3), 'Enemy' }},
			--{ UCBC, 'HaveLessThanUnitsWithCategoryAndAlliance', { 1, categories.ECONOMIC * categories.EXPERIMENTAL, 'Enemy' }},			
			
			{ UCBC, 'PoolGreaterAtLocation', { 'LocationType', 27, categories.HIGHALTAIR * categories.ANTIAIR }},
        },
		
        BuilderData = {
			DistressRange = 200,
			DistressTypes = 'Air',
			DistressThreshold = 16,
            
			LocationType = 'LocationType',
            
            MergeLimit = 32,
            
            MissionTime = 200,
            
            PrioritizedCategories = { categories.MOBILE * categories.AIR * categories.EXPERIMENTAL, categories.MOBILE * categories.AIR - categories.INTELLIGENCE },
            
			SearchRadius = 125,
            
            UseFormation = 'AttackFormation',
        },
		
        BuilderType = 'Any',
    },

    ----------------
    --- GUNSHIPS ---
    ----------------
    -- small size short range groups that can merge quickly
    -- operates at ANY kind of base 
    Builder {BuilderName = 'Hunt Gunships Defensive',
	
        PlatoonTemplate = 'GunshipAttack Small',
        
		PlatoonAddFunctions = { {BHVR, 'BroadcastPlatoonPlan'} },
		
		PlatoonAddPlans = { 'PlatoonCallForHelpAI','DistressResponseAI' },
		
		PlatoonAIPlan = 'AttackForceAI_Gunship',		

        Priority = 700,
        InstanceCount = 4,

        BuilderConditions = {
			{ UCBC, 'PoolGreaterAtLocation', { 'LocationType', 0, categories.AIR * categories.GROUNDATTACK }},
        },
		
        BuilderData = {
			DistressRange = 90,
			DistressTypes = 'Land',
			DistressThreshold = 5,
			
			LocationType = 'LocationType',
			
            MergeLimit = 20,
			
            MissionTime = 100,
			
            PrioritizedCategories = {categories.MOBILE - categories.AIR, categories.INTELLIGENCE - categories.AIR},
			
			SearchRadius = 35,
			
            UseFormation = 'AttackFormation',
        },
		
        BuilderType = 'Any',
    },

	-- medium sized group for close targets and distress response	
    -- operates only from a PRIMARY BASE - Land or Naval
    -- may include ANTIAIR EXPERIMENTALS
    Builder {BuilderName = 'Hunt Gunships Local',
	
        PlatoonTemplate = 'GunshipAttack',
        
		PlatoonAddFunctions = { {BHVR, 'BroadcastPlatoonPlan'} },
		
		PlatoonAddPlans = { 'PlatoonCallForHelpAI', 'DistressResponseAI' },
		
		PlatoonAIPlan = 'AttackForceAI_Gunship',		
		
        Priority = 710,
		
		PriorityFunction = IsPrimaryBase,

        InstanceCount = 2,

        BuilderConditions = {
            { LUTL, 'AirStrengthRatioGreaterThan', { 2 } },
			{ UCBC, 'PoolGreaterAtLocation', { 'LocationType', 14, categories.AIR * categories.GROUNDATTACK }},
        },
		
        BuilderData = {
			DistressRange = 120,
			DistressTypes = 'Land',
			DistressThreshold = 10,
			
			LocationType = 'LocationType',
			
            MergeLimit = 30,
			
            MissionTime = 180,
			
            PrioritizedCategories = {categories.GROUNDATTACK, categories.EXPERIMENTAL - categories.AIR, categories.MOBILE - categories.AIR, categories.ECONOMIC, categories.ENGINEER, categories.NUKE, categories.DEFENSE - categories.WALL},
			
			SearchRadius = 55,
			
            UseFormation = 'AttackFormation',
        },
		
        BuilderType = 'Any',
    },	

	-- large group for most targets on 20k maps and distress response 
    -- operates only from a PRIMARY BASE - Land or Naval
    -- may include ANTIAIR EXPERIMENTALS	
    Builder {BuilderName = 'Hunt Gunships Large',
	
        PlatoonTemplate = 'GunshipAttack Large',
        
		PlatoonAddFunctions = { {BHVR, 'BroadcastPlatoonPlan'} },
		
		PlatoonAddPlans = { 'PlatoonCallForHelpAI', 'DistressResponseAI' },
		
		PlatoonAIPlan = 'AttackForceAI_Gunship',		

        Priority = 720,

		PriorityFunction = IsPrimaryBase,
		
        InstanceCount = 1,

        BuilderConditions = {
			{ UCBC, 'PoolGreaterAtLocation', { 'LocationType', 27, categories.AIR * categories.GROUNDATTACK }},
        },
		
        BuilderData = {
			DistressRange = 180,
			DistressTypes = 'Land',
			DistressThreshold = 15,
            
			LocationType = 'LocationType',
            
            MergeLimit = 64,
            
            MissionTime = 300,
            
            PrioritizedCategories = {categories.MOBILE * categories.SHIELD, categories.LAND * categories.MOBILE * categories.ANTIAIR, categories.ANTIAIR, categories.SHIELD, categories.ENGINEER, categories.MOBILE - categories.AIR, categories.STRUCTURE},
            
			SearchRadius = 110,
            
            UseFormation = 'AttackFormation',
        },
		
        BuilderType = 'Any',
    },

    --- REINFORCMENTS ---

	-- this will forward ANY bombers to the primary land attack base
    Builder {BuilderName = 'Reinforce Primary - Bomber Squadron',
	
        PlatoonTemplate = 'BomberReinforce',
        
		PlatoonAddFunctions = { {BHVR, 'BroadcastPlatoonPlan'}, },
		
        InstanceCount = 1,
        
        Priority = 10,
		
		PriorityFunction = NotPrimaryBase,
		
        BuilderConditions = {
            { LUTL, 'NoBaseAlert', { 'LocationType' }},		
			{ UCBC, 'PoolGreaterAtLocation', { 'LocationType', 2, categories.HIGHALTAIR * categories.BOMBER - categories.ANTINAVY }},
        },
		
        BuilderData = {
            LocationType = 'LocationType',
        },
		
        BuilderType = 'Any',
    },  

	-- this will forward ALL Fighters to either primary land or sea attack base
    Builder {BuilderName = 'Reinforce Primary - Fighter Squadron',
	
        PlatoonTemplate = 'FighterReinforce',
        
		PlatoonAddFunctions = { {BHVR, 'BroadcastPlatoonPlan'}, },
		
        InstanceCount = 1,
        
        Priority = 10,

		PriorityFunction = NotPrimaryBase,
		
        BuilderConditions = {
            { LUTL, 'NoBaseAlert', { 'LocationType' }},		
			{ UCBC, 'PoolGreaterAtLocation', { 'LocationType', 2, (categories.HIGHALTAIR * categories.ANTIAIR) - categories.EXPERIMENTAL }},
        },
		
        BuilderData = {
            LocationType = 'LocationType',
        }, 
		
        BuilderType = 'Any',		
    },
	
	-- this will forward ANY Gunships to either primary land or sea attack base
    Builder {BuilderName = 'Reinforce Primary - Gunship Squadron',
	
        PlatoonTemplate = 'GunshipReinforce',
        
		PlatoonAddFunctions = { {BHVR, 'BroadcastPlatoonPlan'}, },

        InstanceCount = 1,
        
        Priority = 10,

		PriorityFunction = NotPrimaryBase,

        BuilderConditions = {
            { LUTL, 'NoBaseAlert', { 'LocationType' }},		
			{ UCBC, 'PoolGreaterAtLocation', { 'LocationType', 2, categories.AIR * categories.GROUNDATTACK }},
        },
		
        BuilderData = {
            LocationType = 'LocationType',
        },    
		
        BuilderType = 'Any',
    },

}


BuilderGroup {BuilderGroupName = 'Air Formations - Point Guards',
    BuildersType = 'PlatoonFormBuilder',

    -- forms patrols around a base and distress response
--[[   
 
    Builder {BuilderName = 'Home Fighter Squadron',
	
        PlatoonTemplate = 'FighterEscort Large',
		PlatoonAddFunctions = { {BHVR, 'BroadcastPlatoonPlan'}, },
		
		PlatoonAddPlans = { 'DistressResponseAI' },
		
        Priority = 0,
        InstanceCount = 3,
		
        BuilderType = 'Any',
		
        BuilderConditions = {
		
			{ UCBC, 'PoolGreaterAtLocation', { 'LocationType', 0, (categories.HIGHALTAIR * categories.ANTIAIR) - categories.EXPERIMENTAL }},
			
        },
		
        BuilderData = {
		
			DistressRange = 200,
			DistressTypes = 'Air',
			DistressThreshold = 6,
			
            LocationType = 'LocationType',
			
			PointType = 'Marker',
			PointCategory = 'BASE',
			PointSourceSelf = true,
			PointFaction = 'Self',
			PointRadius = 150,
			PointSort = 'Closest',
			PointMin = 0,
			PointMax = 150,
			
			StrCategory = nil,
			StrRadius = 50,
			StrTrigger = false,
			StrMin = 0,
			StrMax = 0,
			
			UntCategory = nil,
			UntRadius = 50,
			UntTrigger = false,
			UntMin = 0,
			UntMax = 0,
			
            PrioritizedCategories = {'AIR MOBILE -INTELLIGENCE'},
			
			GuardRadius = 300,
			GuardTimer = 120,
			
			MissionTime = 180,
			MergeLimit = 60,
			
			AggressiveMove = true,
			
			UseFormation = 'AttackFormation',
			
			SetPatrol = true,
			PatrolRadius = 95,
			
        },    
    },
	
	-- forms patrols around vacant DPs (within 5k) and distress response
    Builder {BuilderName = 'Standard Fighter Squadron DP',
	
        PlatoonTemplate = 'FighterEscort Large',
		PlatoonAddFunctions = { {BHVR, 'BroadcastPlatoonPlan'}, },
		
		PlatoonAddPlans = { 'DistressResponseAI','PlatoonCallForHelpAI' },
		
        InstanceCount = 2,
		
        BuilderType = 'Any',
		
        Priority = 0,
		
        BuilderConditions = {
		
            { LUTL, 'AirStrengthRatioGreaterThan', { 3 } },
			{ UCBC, 'PoolGreaterAtLocation', { 'LocationType', 2, (categories.HIGHALTAIR * categories.ANTIAIR) - categories.EXPERIMENTAL }},
			
        },
		
        BuilderData = {
		
			DistressRange = 200,
			DistressTypes = 'Air',
			DistressThreshold = 6,
			
            LocationType = 'LocationType',
			
			PointType = 'Marker',		-- find closest DP marker within 200-500 --
			PointCategory = { 'Defensive Point', 'Naval Defensive Point' },
			PointSourceSelf = true,
			PointFaction = 'Self',
			PointRadius = 750,
			PointSort = 'Closest',
			PointMin = 200,
			PointMax = 750,
			
			StrCategory = categories.AIRSTAGINGPLATFORM - categories.MOBILE,	-- go only to those that DONT have an airstaging pad --
			StrRadius = 50,
			StrTrigger = true,
			StrMin = -1,		--<< notice use of negative values to induce a NOT condition
			StrMax = -1,
			
			UntCategory = (categories.HIGHALTAIR * categories.ANTIAIR) - categories.EXPERIMENTAL,	-- and those that have less than 20 there already
			UntRadius = 90,
			UntTrigger = true,
			UntMin = 0,
			UntMax = 20,
			
            PrioritizedCategories = {'AIR EXPERIMENTAL', 'TRANSPORTFOCUS', 'BOMBER', 'GROUNDATTACK', 'AIR MOBILE -OVERLAYOMNI'},
			
			GuardRadius = 300,
			GuardTimer = 120,	-- patrol there for 2 minutes --
			
			MissionTime = 360,	-- 6 minutes --
			
			MergeLimit = 50,	-- merge upto 50 units
			
			AggressiveMove = true,
			
			UseFormation = 'AttackFormation',
			
			SetPatrol = true,
			PatrolRadius = 40,
			
        },    
    },

	
    Builder {BuilderName = 'Home Gunship Squadron',
	
        PlatoonTemplate = 'GunshipSquadron',
		PlatoonAddFunctions = { {BHVR, 'BroadcastPlatoonPlan'}, },
		
		PlatoonAddPlans = { 'DistressResponseAI' },
		
        InstanceCount = 2,
		
        BuilderType = 'Any',
		
        Priority = 0,
		
        BuilderConditions = {
		
			{ UCBC, 'PoolGreaterAtLocation', { 'LocationType', 4, categories.AIR * categories.GROUNDATTACK }},
			
        },
		
        BuilderData = {
		
			DistressRange = 150,
			DistressTypes = 'Land',
			DistressThreshold = 6,
            LocationType = 'LocationType',
			PointType = 'Marker',
			PointCategory = 'BASE',
			PointSourceSelf = true,
			PointFaction = 'Self',
			PointRadius = 150,
			PointSort = 'Closest',
			PointMin = 0,
			PointMax = 150,
			StrCategory = nil,
			StrRadius = 50,
			StrTrigger = false,
			StrMin = 0,
			StrMax = 0,
			UntCategory = nil,
			UntRadius = 50,
			UntTrigger = false,
			UntMin = 0,
			UntMax = 0,
            PrioritizedCategories = {'GROUNDATTACK, LAND MOBILE, MASSEXTRACTION, STRUCTURE -WALL, AIR MOBILE -HIGHALTAIR, NAVAL MOBILE', },
			GuardRadius = 200,
			GuardTimer = 150,
			MissionTime = 210,
			MergeLimit = 60,
			AggressiveMove = true,
			UseFormation = 'GrowthFormation',
			SetPatrol = true,
			PatrolRadius = 85,
			
        },    
    },

	-- forms  patrols around Expansion Base markers
    Builder {BuilderName = 'Standard Fighter Squadron Expansion',
	
        PlatoonTemplate = 'FighterEscort Large',
		
		PlatoonAddFunctions = { {BHVR, 'BroadcastPlatoonPlan'}, },
		
		PlatoonAddPlans = { 'DistressResponseAI','PlatoonCallForHelpAI' },
		
        InstanceCount = 2,
		
        BuilderType = 'Any',
		
        Priority = 0,
		
		RTBLocation = 'Any',
		
        BuilderConditions = {
		
			{ UCBC, 'PoolGreaterAtLocation', { 'LocationType', 2, (categories.HIGHALTAIR * categories.ANTIAIR) - categories.EXPERIMENTAL }},
			
        },
		
        BuilderData = {
		
			DistressRange = 200,
			DistressTypes = 'Air',
			DistressThreshold = 5,
			
            LocationType = 'LocationType',
			
			PointType = 'Marker',
			PointCategory = 'Large Expansion Area',
			PointSourceSelf = true,
			PointFaction = 'Ally',
			PointRadius = 9999999,
			PointSort = 'Furthest',
			PointMin = 250,
			PointMax = 4000,
			
			StrCategory = categories.AIRSTAGINGPLATFORM - categories.MOBILE,
			StrRadius = 50,
			StrTrigger = true,
			StrMin = 0,
			StrMax = 6,
			
			UntCategory = (categories.HIGHALTAIR * categories.ANTIAIR) - categories.EXPERIMENTAL,
			UntRadius = 90,
			UntTrigger = false,
			UntMin = 0,
			UntMax = 50,
			
            PrioritizedCategories = {'AIR EXPERIMENTAL', 'TRANSPORTFOCUS', 'BOMBER', 'GROUNDATTACK', 'AIR MOBILE -OVERLAYOMNI'},
			
			GuardRadius = 300,
			GuardTimer = 600,
			
			MergeLimit = 50,
			
			AggressiveMove = true,
			
			UseFormation = 'AttackFormation',
			
			SetPatrol = true,
			PatrolRadius = 75,
			
        },    
    },

	-- forms patrols around Mass points that are open
    Builder {BuilderName = 'Standard Fighter Squadron Mass Point',
	
        PlatoonTemplate = 'FighterEscort Large',
		
		PlatoonAddFunctions = { {BHVR, 'BroadcastPlatoonPlan'}, },
		
		PlatoonAddPlans = { 'PlatoonCallForHelpAI', 'DistressResponseAI' },
		
        Priority = 0,
		
		RTBLocation = 'Any',
		
        InstanceCount = 1,
		
        BuilderType = 'Any',
		
        BuilderConditions = {
            { LUTL, 'NoBaseAlert', { 'LocationType' }},		
            { LUTL, 'AirStrengthRatioGreaterThan', { 3 } },
			
			{ EBC, 'CanBuildOnMassLessThanDistance', { 'LocationType', 750, -9999, 150, 1, 'AntiAir', 1 }},

			{ UCBC, 'PoolGreaterAtLocation', { 'LocationType', 2, (categories.HIGHALTAIR * categories.ANTIAIR) - categories.EXPERIMENTAL }},
			
        },
		
        BuilderData = {
		
			DistressRange = 200,
			DistressTypes = 'Air',
			DistressThreshold = 10,
			
            LocationType = 'LocationType',
			
			PointType = 'Marker',
			PointCategory = 'Mass',
			PointSourceSelf = true,
			PointFaction = 'Ally',
			PointRadius = 750,
			PointSort = 'Closest',
			PointMin = 250,
			PointMax = 750,
			
			StrCategory = categories.MASSEXTRACTION,
			StrRadius = 10,
			StrTrigger = true,
			StrMin = 0,
			StrMax = 0,
			
			UntCategory = (categories.HIGHALTAIR * categories.ANTIAIR) - categories.EXPERIMENTAL,
			UntRadius = 90,
			UntTrigger = false,
			UntMin = 0,
			UntMax = 20,
			
            PrioritizedCategories = {'AIR EXPERIMENTAL', 'TRANSPORTFOCUS', 'BOMBER', 'GROUNDATTACK', 'AIR MOBILE -OVERLAYOMNI'},
			
			GuardRadius = 250,
			GuardTimer = 90,
			
			MergeLimit = 50,
			
			AggressiveMove = false,
			
			UseFormation = 'AttackFormation',
			
			SetPatrol = true,
			PatrolRadius = 55,
			
        },
	},

    Builder {BuilderName = 'Standard Gunship Squadron Mass Point',
	
        PlatoonTemplate = 'GunshipSquadron',
		
		PlatoonAddFunctions = { {BHVR, 'BroadcastPlatoonPlan'}, },
		
		PlatoonAddPlans = { 'PlatoonCallForHelpAI', 'DistressResponseAI' },
		
        Priority = 0,
		
		RTBLocation = 'Any',
		
        InstanceCount = 2,
		
        BuilderType = 'Any',
		
        BuilderConditions = {
            { LUTL, 'NoBaseAlert', { 'LocationType' }},		
            { LUTL, 'AirStrengthRatioGreaterThan', { 3 } },
			{ UCBC, 'PoolGreaterAtLocation', { 'LocationType', 4, categories.AIR * categories.GROUNDATTACK }},
			{ EBC, 'CanBuildOnMassLessThanDistance', { 'LocationType', 750, -9999, 150, 1, 'AntiAir', 1 }},
			
        },
		
        BuilderData = {
		
			DistressRange = 150,
			DistressTypes = 'Air',
			DistressThreshold = 8,
			
            LocationType = 'LocationType',
			
			PointType = 'Marker',			
			PointCategory = 'Mass',
			PointSourceSelf = true,			
			PointFaction = 'Ally',	 		
			PointRadius = 750,		    	
			PointSort = 'Closest',			
			PointMin = 200,					
			PointMax = 750,
			
			StrCategory = categories.MASSEXTRACTION,
			StrRadius = 10,
			StrTrigger = true,
			StrMin = 0,
			StrMax = 15,
			
			UntCategory = (categories.AIR * categories.GROUNDATTACK) - categories.EXPERIMENTAL,
			UntRadius = 90,
			UntTrigger = false,
			UntMin = 0,
			UntMax = 16,
			
            PrioritizedCategories = {'GROUNDATTACK, LAND MOBILE, MASSEXTRACTION, STRUCTURE -WALL'},
			
			GuardRadius = 200,
			GuardTimer = 120,
			
			MergeLimit = 50,
			
			AggressiveMove = false,
			
			UseFormation = 'AttackFormation',
			
			SetPatrol = true,
			PatrolRadius = 55,
			
        },
	},
--]]
}

BuilderGroup {BuilderGroupName = 'Air Formations - Water Map',

	BuildersType = 'PlatoonFormBuilder',

	-- torpedo bomber groups kept close to home for defensive work and distress response
	-- a short term formation that will merge up into larger groups
    Builder {BuilderName = 'Hunt Torpedos Defensive',
	
        PlatoonTemplate = 'TorpedoAttack Small',
        
		PlatoonAddFunctions = { {BHVR, 'BroadcastPlatoonPlan'} },
		
		PlatoonAddPlans = { 'DistressResponseAI' },
		
		PlatoonAIPlan = 'AttackForceAI_Bomber',		
		
        Priority = 700,
        InstanceCount = 3,
		
        BuilderConditions = {
			{ UCBC, 'PoolGreaterAtLocation', { 'LocationType', 0, categories.HIGHALTAIR * categories.BOMBER * categories.ANTINAVY }},
        },
		
        BuilderData = {
			DistressRange = 120,
			DistressTypes = 'Naval',
			DistressThreshold = 4,
			
			LocationType = 'LocationType',
			
            MergeLimit = 12,
			
            MissionTime = 100,
			
            PrioritizedCategories = {categories.MOBILE * categories.NAVAL, categories.MOBILE},
			
			SearchRadius = 40,	
			
            UseFormation = 'AttackFormation',
        },
		
        BuilderType = 'Any',
    },

    Builder {BuilderName = 'Hunt Torpedos Local',
	
        PlatoonTemplate = 'TorpedoAttack',
        
		PlatoonAddFunctions = { {BHVR, 'BroadcastPlatoonPlan'} },
		
		PlatoonAddPlans = { 'DistressResponseAI' },
		
		PlatoonAIPlan = 'AttackForceAI_Bomber',

        Priority = 710,
		
		PriorityFunction = IsPrimaryBase,
		
        InstanceCount = 2,

        BuilderConditions = {
			{ UCBC, 'PoolGreaterAtLocation', { 'LocationType', 12, categories.HIGHALTAIR * categories.BOMBER * categories.ANTINAVY }},
        },
		
        BuilderData = {
			DistressRange = 150,
			DistressTypes = 'NaVal',
			DistressThreshold = 8,
			
			LocationType = 'LocationType',
			
            MergeLimit = 28,
			
            MissionTime = 150,
			
            PrioritizedCategories = { categories.MOBILE * categories.NAVAL, categories.MOBILE, categories.STRUCTURE},
			
			SearchRadius = 65,
			
            UseFormation = 'AttackFormation',
        },
		
        BuilderType = 'Any',
    },

    Builder {BuilderName = 'Hunt Torpedos Large',
	
        PlatoonTemplate = 'TorpedoAttack Large',
        
		PlatoonAddFunctions = { {BHVR, 'BroadcastPlatoonPlan'} },
		
		PlatoonAddPlans = { 'DistressResponseAI' },
		
		PlatoonAIPlan = 'AttackForceAI_Bomber',

        Priority = 720,
		
		PriorityFunction = IsPrimaryBase,
		
        InstanceCount = 2,

        BuilderConditions = {
			{ UCBC, 'PoolGreaterAtLocation', { 'LocationType', 29, categories.HIGHALTAIR * categories.BOMBER * categories.ANTINAVY }},
        },
		
        BuilderData = {
			DistressRange = 220,
			DistressTypes = 'NaVal',
			DistressThreshold = 8,
			
			LocationType = 'LocationType',
			
            MergeLimit = 64,
			
            MissionTime = 260,
			
            PrioritizedCategories = { categories.MOBILE * categories.NAVAL * categories.EXPERIMENTAL, categories.MOBILE * categories.ANTIAIR, categories.MOBILE, categories.STRUCTURE},
			
			SearchRadius = 120,
			
            UseFormation = 'AttackFormation',
        },
		
        BuilderType = 'Any',
    },

	-- ALL these torpedo bomber groups are very specifically targeted and only come into play when the selected targets are available
	-- this first one hunts nukes and antinukes - but will go after mobile experimentals as well
    -- this is turned off since the build conditions can't identify if it's in the water or not
--[[
    Builder {BuilderName = 'Hunt Torps - Nuke Antinuke',
	
        PlatoonTemplate = 'TorpedoBomberAttack',
		
		PlatoonAddFunctions = { {BHVR, 'BroadcastPlatoonPlan'} },
		
		PlatoonAIPlan = 'AttackForceAI',		
		
        Priority = 0,
		
		-- this will only form at primary bases
		PriorityFunction = IsPrimaryBase,

        InstanceCount = 1,
		
        BuilderType = 'Any',
		
        BuilderConditions = {
            { LUTL, 'AirStrengthRatioGreaterThan', { 3 } },
			{ LUTL, 'HaveGreaterThanUnitsWithCategoryAndAlliance', { 0, categories.NUKE + categories.ANTIMISSILE - categories.TECH2, 'Enemy' }},
			{ UCBC, 'PoolGreaterAtLocation', { 'LocationType', 23, categories.HIGHALTAIR * categories.ANTINAVY } },			
        },
		
        BuilderData = {
			LocationType = 'LocationType',
            
            MergeLimit = false,
            
            MissionTime = 300,
            
            PrioritizedCategories = {categories.NUKE + categories.ANTIMISSILE - categories.TECH2, categories.EXPERIMENTAL * categories.MOBILE - categories.AIR},
            
			SearchRadius = 500,
            
            UseFormation = 'AttackFormation',
        },
    },
--]]	

	-- this one goes after sonar
    Builder {BuilderName = 'Hunt Torps - Sonar',
	
        PlatoonTemplate = 'TorpedoBomberAttack',
		
		PlatoonAddFunctions = { {BHVR, 'BroadcastPlatoonPlan'} },
		
		PlatoonAIPlan = 'AttackForceAI_Bomber',
		
        Priority = 710,
		
		-- this will only form at primary bases
		PriorityFunction = IsPrimaryBase,
		
        InstanceCount = 1,
		
        BuilderType = 'Any',
		
        BuilderConditions = {
			{ LUTL, 'HaveGreaterThanUnitsWithCategoryAndAlliance', { 0, categories.SONAR * categories.STRUCTURE, 'Enemy' }},			
			{ UCBC, 'PoolGreaterAtLocation', { 'LocationType', 23, categories.HIGHALTAIR * categories.ANTINAVY } },
        },
		
        BuilderData = {
			LocationType = 'LocationType',
            
            MergeLimit = false,
            
            MissionTime = 150,
            
            PrioritizedCategories = { categories.SONAR, categories.MOBILE },
            
			SearchRadius = 250,
            
            UseFormation = 'AttackFormation',
        },
    },

	-- self explanatory - goes after Economic experimentals - but also massfabrication
    -- again - turned off - conditions can't identify if it's in the water or not
--[[
    Builder {BuilderName = 'Hunt Torps - Economic Experimental',
	
        PlatoonTemplate = 'TorpedoBomberAttack',
		
		PlatoonAddFunctions = { {BHVR, 'BroadcastPlatoonPlan'} },
		
		PlatoonAIPlan = 'AttackForceAI',		
		
        Priority = 0,
		
		-- this will only form at primary bases
		PriorityFunction = IsPrimaryBase,
		
        InstanceCount = 1,
		
        BuilderType = 'Any',
		
        BuilderConditions = {
            { LUTL, 'AirStrengthRatioGreaterThan', { 3 } },
			{ LUTL, 'HaveGreaterThanUnitsWithCategoryAndAlliance', { 0, categories.ECONOMIC * categories.EXPERIMENTAL, 'Enemy' }},			
			{ UCBC, 'PoolGreaterAtLocation', { 'LocationType', 23, categories.HIGHALTAIR * categories.ANTINAVY } },
        },
		
        BuilderData = {
			LocationType = 'LocationType',
            
            MergeLimit = false,
            
            MissionTime = 300,
            
            PrioritizedCategories = {categories.ECONOMIC * categories.EXPERIMENTAL, categories.MASSFABRICATION},
            
			SearchRadius = 500,
            
            UseFormation = 'AttackFormation',
        },
    },
--]]    

    Builder {BuilderName = 'Reinforce Primary - Torpedo Squadron',
	
        PlatoonTemplate = 'TorpedoReinforce',
		
		PlatoonAddFunctions = { {BHVR, 'BroadcastPlatoonPlan'}, },
		
        InstanceCount = 2,
	
        Priority = 10,
		
		-- this function turns the builder on
		PriorityFunction = NotPrimaryBase,

        BuilderConditions = {
            { LUTL, 'NoBaseAlert', { 'LocationType' }},
			{ UCBC, 'PoolGreaterAtLocation', { 'LocationType', 5, categories.HIGHALTAIR * categories.ANTINAVY } },
        },
		
        BuilderData = {
            LocationType = 'LocationType',
        },
		
        BuilderType = 'Any',
    }, 	
    

    -- Naval Flotilla Air Groups -- Large Support Groups
    Builder {BuilderName = 'Naval Fighter Squadron',
	
        PlatoonTemplate = 'FighterEscort Large',
		
		PlatoonAddFunctions = { {BHVR, 'BroadcastPlatoonPlan'}, },
		
		PlatoonAddPlans = { 'PlatoonCallForHelpAI', 'DistressResponseAI' },
		
        InstanceCount = 1,
		
        BuilderType = 'Any',
		
        Priority = 710,
		
        BuilderConditions = {
            { LUTL, 'NoBaseAlert', { 'LocationType' }},        
            { UCBC, 'PoolGreaterAtLocation', { 'LocationType', 27, (categories.HIGHALTAIR * categories.ANTIAIR) - categories.EXPERIMENTAL }},
			{ UCBC, 'HaveGreaterThanUnitsWithCategory', { 0, categories.CRUISER + (categories.NAVAL * categories.CARRIER)}},            
        },
		
        BuilderData = {
			DistressRange = 200,
			DistressTypes = 'Air',
			DistressThreshold = 16,
			
            LocationType = 'LocationType',
			
			PointType = 'Unit',
			PointCategory = categories.CRUISER + (categories.NAVAL * categories.CARRIER),
			PointSourceSelf = false,
			PointFaction = 'Self',
			PointRadius = 9999999,
			PointSort = 'Furthest',
			PointMin = 200,
			PointMax = 9999999,
			
			StrCategory = nil,
			StrRadius = 65,
			StrTrigger = true,
			StrMin = 2,
			StrMax = 50,
			
			UntCategory = (categories.HIGHALTAIR * categories.ANTIAIR) - categories.EXPERIMENTAL,
			UntRadius = 60,
			UntTrigger = true,
			UntMin = 2,
			UntMax = 50,
			
            PrioritizedCategories = {'AIR MOBILE -INTELLIGENCE'},
			
			GuardRadius = 140,
			GuardTimer = 300,
			
			MergeLimit = 50,
			
			AggressiveMove = true,
			
			UseFormation = 'AttackFormation',
			SetPatrol = true,
			PatrolRadius = 60,
        },    
    },     
	
    Builder {BuilderName = 'Naval Gunship Squadron',
	
        PlatoonTemplate = 'GunshipSquadron',
		
		PlatoonAddFunctions = { {BHVR, 'BroadcastPlatoonPlan'}, },
		
		PlatoonAddPlans = { 'PlatoonCallForHelpAI' },
		
        InstanceCount = 1,
		
        BuilderType = 'Any',
		
        Priority = 710,
		
		RTBLocation = 'Any',
		
        BuilderConditions = {
		
			{ UCBC, 'PoolGreaterAtLocation', { 'LocationType', 4, categories.AIR * categories.GROUNDATTACK }},
			{ UCBC, 'HaveGreaterThanUnitsWithCategory', { 0, categories.CRUISER + categories.CARRIER }},
        },
		
        BuilderData = {
		
            LocationType = 'LocationType',
			DistressRange = 125,
			PointType = 'Unit',
			PointCategory = categories.CRUISER + categories.CARRIER,
			PointSourceSelf = false,
			PointFaction = 'Self',
			PointRadius = 9999999,
			PointSort = 'Furthest',
			PointMin = 200,
			PointMax = 9999999,
			StrCategory = categories.CRUISER + categories.CARRIER,
			StrRadius = 65,
			StrTrigger = true,
			StrMin = 1,
			StrMax = 12,
			UntCategory = (categories.AIR * categories.GROUNDATTACK) - categories.TRANSPORTFOCUS - categories.EXPERIMENTAL,
			UntRadius = 50,
			UntTrigger = true,
			UntMin = 0,
			UntMax = 30,
            PrioritizedCategories = {'NAVAL MOBILE SHIELD', 'NAVAL MOBILE -SUBMERSIBLE', 'GROUNDATTACK', 'LAND MOBILE', 'STRUCTURE'},
			GuardRadius = 210,
			GuardTimer = 400,
			MergeLimit = 30,
			AggressiveMove = true,
			UseFormation = 'AttackFormation',
			
        },    
    },
	
    Builder {BuilderName = 'Naval Torpedo Squadron',
	
        PlatoonTemplate = 'TorpedoEscort Large',
		
		PlatoonAddFunctions = { {BHVR, 'BroadcastPlatoonPlan'}, },
		
		PlatoonAddPlans = { 'PlatoonCallForHelpAI','DistressResponseAI' },
		
        InstanceCount = 2,
		
        BuilderType = 'Any',
		
        Priority = 710,
		
		RTBLocation = 'Any',
		
        BuilderConditions = {
            { LUTL, 'NoBaseAlert', { 'LocationType' }},        
			{ UCBC, 'PoolGreaterAtLocation', { 'LocationType', 29, categories.HIGHALTAIR * categories.ANTINAVY } },
			{ UCBC, 'HaveGreaterThanUnitsWithCategory', { 0, categories.CRUISER + (categories.NAVAL * categories.CARRIER)}},
        },
		
        BuilderData = {
			DistressRange = 150,
			DistressTypes = 'Naval',
			DistressThreshold = 8,
            
            LocationType = 'LocationType',
            
			PointType = 'Unit',
			PointCategory = categories.CRUISER + (categories.NAVAL * categories.CARRIER),
			PointSourceSelf = false,
			PointFaction = 'Self',
			PointRadius = 9999999,
			PointSort = 'Furthest',
			PointMin = 200,
			PointMax = 9999999,
            
			StrCategory = nil,
			StrRadius = 65,
			StrTrigger = true,
			StrMin = 1,
			StrMax = 12,
            
			UntCategory = categories.HIGHALTAIR * categories.ANTINAVY,
			UntRadius = 50,
			UntTrigger = true,
			UntMin = 0,
			UntMax = 48,
            
            PrioritizedCategories = {'MOBILE','STRUCTURE'},
            
			GuardRadius = 200,
			GuardTimer = 420,
            
			MergeLimit = 48,
            
			AggressiveMove = true,
			UseFormation = 'AttackFormation',
        },    
    }, 
	

}


BuilderGroup {BuilderGroupName = 'Air Formations - Experimentals',
    BuildersType = 'PlatoonFormBuilder',
	
    Builder {BuilderName = 'Experimental Bombers',
	
        PlatoonTemplate = 'Experimental Bomber',
        
		PlatoonAddFunctions = { {BHVR, 'BroadcastPlatoonPlan'},{BHVR, 'AirForceAI_Bomber_LOUD'} },		
		
		PlatoonAddPlans = { 'PlatoonCallForHelpAI', 'DistressResponseAI' },
		
        Priority = 730,
		
		-- this function turns the builder off --
		PriorityFunction = function(self, aiBrain, manager)
			
			if aiBrain.BuilderManagers[manager.LocationType].PrimaryLandAttackBase or aiBrain.BuilderManagers[manager.LocationType].PrimarySeaAttackBase then
				return 730, true
			end
			
			return 10, true
		end,
		
        InstanceCount = 2,
		
        BuilderType = 'Any',
		
        BuilderConditions = {
            { LUTL, 'AirStrengthRatioGreaterThan', { 2 } },        
			{ UCBC, 'PoolGreaterAtLocation', { 'LocationType', 2, categories.AIR * categories.EXPERIMENTAL * categories.BOMBER } },
        },
		
        BuilderData = {
			DistressRange = 200,
			DistressTypes = 'Land',
			DistressThreshold = 15,
            MergeLimit = 6,
            MissionTime = 360,
            PrioritizedCategories = {categories.EXPERIMENTAL * categories.STRUCTURE, categories.NUKE, categories.EXPERIMENTAL * categories.MOBILE - categories.AIR, categories.ECONOMIC * categories.TECH3, categories.COMMAND},
			SearchRadius = 1000,
            UseFormation = 'BlockFormation',
        },
    },
	
    Builder {BuilderName = 'Experimental Gunships',
	
        PlatoonTemplate = 'Experimental Gunship',
        
		PlatoonAddFunctions = { {BHVR, 'BroadcastPlatoonPlan'},{BHVR, 'AirForceAILOUD'} },
		
		PlatoonAddPlans = { 'PlatoonCallForHelpAI', 'DistressResponseAI' },
		
        Priority = 730,
		
		-- this function turns the builder off --
		PriorityFunction = function(self, aiBrain, manager)
			
			if aiBrain.BuilderManagers[manager.LocationType].PrimaryLandAttackBase or aiBrain.BuilderManagers[manager.LocationType].PrimarySeaAttackBase then
				return 730, true
			end
			
			return 10, true
		end,
		
        InstanceCount = 2,
		
        BuilderType = 'Any',
		
        BuilderConditions = {
            { LUTL, 'AirStrengthRatioGreaterThan', { 2 } },
			{ UCBC, 'PoolGreaterAtLocation', { 'LocationType', 3, categories.AIR * categories.EXPERIMENTAL * categories.GROUNDATTACK } },
        },
		
        BuilderData = {
			DistressRange = 200,
			DistressTypes = 'Land',
			DistressThreshold = 15,
            MergeLimit = 6,
            MissionTime = 480,
            PrioritizedCategories = {categories.EXPERIMENTAL * categories.STRUCTURE, categories.EXPERIMENTAL * categories.MOBILE - categories.AIR, categories.NUKE, categories.ECONOMIC * categories.TECH3, categories.COMMAND},
			SearchRadius = 900,
            UseFormation = 'BlockFormation',
        },
    },

    -- group Czar attacks under normal conditions
	Builder {BuilderName = 'Czar Group',
	
        PlatoonTemplate = 'T4ExperimentalAirCzar',
		
		PlatoonAddPlans = { 'PlatoonCallForHelpAI', 'DistressResponseAI' },

		PlatoonAIPlan = 'CzarAttack',
		
		FactionIndex = 2,
		
        Priority = 730,
		
		-- this function removes the builder 
		PriorityFunction = function(self, aiBrain, manager)
			
			if aiBrain.BuilderManagers[manager.LocationType].PrimaryLandAttackBase or aiBrain.BuilderManagers[manager.LocationType].PrimarySeaAttackBase then
				return 730, true
			end
			
			return 10, true
		end,

        InstanceCount = 2,
		
        BuilderType = 'Any',
		
        BuilderConditions = {
            { UCBC, 'PoolGreaterAtLocation', { 'LocationType', 3, categories.uaa0310 } },
		},
		
        BuilderData = {
			DistressRange = 200,
			DistressTypes = 'Land',
			DistressThreshold = 25,

            PrioritizedCategories = { 'SHIELD STRUCTURE','ANTIAIR STRUCTURE','COMMAND','ENGINEER','EXPERIMENTAL','ENERGYPRODUCTION','FACTORY','STRUCTURE' }, -- list in order
        },
    },

    -- lone Czar Attacks when we have huge air advantage
	Builder {BuilderName = 'Czar Terror Attack',
	
        PlatoonTemplate = 'CzarTerrorAttack',
		
        PlatoonAddBehaviors = {'BroadcastPlatoonPlan' },
		
		PlatoonAddPlans = { 'PlatoonCallForHelpAI' },
		
		FactionIndex = 2,
		
		PlatoonAIPlan = 'CzarAttack',
		
        Priority = 730,
		
		-- this function removes the builder 
		PriorityFunction = function(self, aiBrain, manager)
			
			if aiBrain.BuilderManagers[manager.LocationType].PrimaryLandAttackBase or aiBrain.BuilderManagers[manager.LocationType].PrimarySeaAttackBase then
				return 730, true
			end
			
			return 10, true
		end,

        InstanceCount = 2,
		
        BuilderType = 'Any',
		
        BuilderConditions = {
            { UCBC, 'PoolGreaterAtLocation', { 'LocationType', 0, categories.uaa0310 } },
            { LUTL, 'AirStrengthRatioGreaterThan', { 9 } },
		},
		
        BuilderData = {
            PrioritizedCategories = { 'ANTIAIR STRUCTURE','EXPERIMENTAL MOBILE -AIR', 'FACTORY STRUCTURE -TECH1', 'EXPERIMENTAL STRUCTURE', 'COMMAND' }, -- list in order
        },
    },
	
	Builder {BuilderName = 'Reinforce Primary - Air Experimental',
	
		PlatoonTemplate = 'ReinforceAirExperimental',
		
        PlatoonAddBehaviors = {'BroadcastPlatoonPlan' },
		
		PlatoonAddPlans = { 'PlatoonCallForHelpAI' },
		
        Priority = 10,
		
		PriorityFunction = NotPrimaryBase,
	
        InstanceCount = 2,
		
        BuilderType = 'Any',
		
        BuilderConditions = {
            { LUTL, 'NoBaseAlert', { 'LocationType' }},
			{ UCBC, 'PoolGreaterAtLocation', { 'LocationType', 0, categories.AIR * categories.EXPERIMENTAL } },
        },
		
        BuilderData = {
            UseFormation = 'GrowthFormation',
        },
	},
}

