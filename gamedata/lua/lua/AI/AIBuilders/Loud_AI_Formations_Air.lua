--**  File     :  /lua/ai/Loud_AI_Formation_Air_Builders.lua

local UCBC  = '/lua/editor/UnitCountBuildConditions.lua'
local EBC   = '/lua/editor/EconomyBuildConditions.lua'
local LUTL  = '/lua/loudutilities.lua'
local BHVR  = '/lua/ai/aibehaviors.lua'

local NotPrimaryBase = function( self,aiBrain,manager)

	if aiBrain.BuilderManagers[manager.LocationType].PrimaryLandAttackBase or aiBrain.BuilderManagers[manager.LocationType].PrimarySeaAttackBase then
		return self.OldPriority or self.Priority, true
	end

	return 720, true
end

local IsPrimaryBase = function(self,aiBrain,manager)
	
	if aiBrain.BuilderManagers[manager.LocationType].PrimaryLandAttackBase or aiBrain.BuilderManagers[manager.LocationType].PrimarySeaAttackBase then
		return self.OldPriority or self.Priority, true
	end

	return 10, true
end

local PlatoonCategoryCount                  = moho.platoon_methods.PlatoonCategoryCount
local PlatoonCategoryCountAroundPosition    = moho.platoon_methods.PlatoonCategoryCountAroundPosition

local AIRSCOUT      = categories.AIR * categories.SCOUT
local AIRBOMBER     = categories.HIGHALTAIR * categories.BOMBER
local AIRFIGHTER    = categories.HIGHALTAIR * categories.ANTIAIR
local AIRGUNSHIP    = categories.AIR * categories.GROUNDATTACK
local AIRTORPEDO    = categories.HIGHALTAIR * categories.ANTINAVY
local AIRT4         = categories.AIR * categories.EXPERIMENTAL

-- These are the standard air scout patrols around all bases
-- and will consume the first 5/6 scouts
BuilderGroup {BuilderGroupName = 'Air Formations - Scouts', BuildersRestriction = 'AIRSCOUTS', BuildersType = 'PlatoonFormBuilder',
	
    Builder {BuilderName = 'Air Scout - Peri - 200',
	
        PlatoonTemplate = 'Air Scout Formation',
        
		PlatoonAIPlan = 'PlatoonPatrolPointAI',
		
        Priority = 812,
		
		PriorityFunction = function(self, aiBrain, manager)
        
            if aiBrain.CycleTime < 150 then
                return 10, true
            end

            -- remove task after 45 minutes
			if aiBrain.CycleTime > 2700 then
				return 0, false
			end

            if PlatoonCategoryCountAroundPosition( aiBrain.ArmyPool, AIRSCOUT, manager.Location, manager.Radius ) < 1 then
                return 10,true
            else
                return 812,true
            end

        end,

        BuilderType = 'Any',
		
		BuilderConditions = {},
		
		BuilderData = {
			BasePerimeterOrientation = 'ALL',        
			Radius = 200,
			PatrolTime = 1200,
		},
    },
	
    Builder {BuilderName = 'Air Scout - Peri - 290',
	
        PlatoonTemplate = 'Air Scout Formation',
        
		PlatoonAIPlan = 'PlatoonPatrolPointAI',
		
        Priority = 811,
		
		PriorityFunction = function(self, aiBrain, manager)
        
            if aiBrain.CycleTime < 150 then
                return 10, true
            end

            if PlatoonCategoryCountAroundPosition( aiBrain.ArmyPool, AIRSCOUT, manager.Location, manager.Radius ) < 1 then
                return 10,true
            else
                return 811,true
            end

        end,

        BuilderType = 'Any',
		
		BuilderConditions = {},
		
		BuilderData = {
			BasePerimeterOrientation = 'ALL',        
			Radius = 290,
			PatrolTime = 1200,
		},
    },

    Builder {BuilderName = 'Air Scout - Peri - 380',
	
        PlatoonTemplate = 'Air Scout Formation',
        
		PlatoonAIPlan = 'PlatoonPatrolPointAI',
		
        Priority = 810,
		
		PriorityFunction = function(self, aiBrain, manager)
        
            if aiBrain.CycleTime < 150 then
                return 10, true
            end

            if PlatoonCategoryCountAroundPosition( aiBrain.ArmyPool, AIRSCOUT, manager.Location, manager.Radius ) < 1 then
                return 10,true
            else
                return 810,true
            end

        end,

        InstanceCount = 2,
		
        BuilderType = 'Any',
		
		BuilderConditions = {},
		
		BuilderData = {
			BasePerimeterOrientation = 'ALL',
			Radius = 380,
			PatrolTime = 1200,
		},
    },

    Builder {BuilderName = 'Air Scout - Peri - 460',
	
        PlatoonTemplate = 'Air Scout Formation',
        
		PlatoonAIPlan = 'PlatoonPatrolPointAI',
		
        Priority = 810,

		PriorityFunction = function(self, aiBrain, manager)
        
            if aiBrain.CycleTime < 150 then
                return 10, true
            end

            if PlatoonCategoryCountAroundPosition( aiBrain.ArmyPool, AIRSCOUT, manager.Location, manager.Radius ) < 1 then
                return 10,true
            else
                return 810,true
            end

        end,
		
		InstanceCount = 2,
		
        BuilderType = 'Any',
		
		BuilderConditions = {},
		
		BuilderData = {
			BasePerimeterOrientation = 'ALL',        
			Radius = 460,
			PatrolTime = 1200,
		},
    },

    --- Field air scouts come after that
    Builder {BuilderName = 'Air Scout Standard',
    
        PlatoonTemplate = 'Air Scout Formation',
        
		PlatoonAIPlan = 'ScoutingAI',
        
		Priority = 810,
		
		-- this function removes the builder after 45 minutes
		PriorityFunction = function(self, aiBrain, manager)

			if aiBrain.CycleTime > 2700 then
				return 0, false
			end

            if PlatoonCategoryCountAroundPosition( aiBrain.ArmyPool, AIRSCOUT, manager.Location, manager.Radius ) < 1 then
                return 10, true
            else
                return 810,true
            end

		end,
		
        InstanceCount = 10,
		
        BuilderType = 'Any',
		
		BuilderConditions = {},
		
		BuilderData = {},
    },
    
    Builder {BuilderName = 'Air Scout Pair',
    
        PlatoonTemplate = 'Air Scout Group',
        
		PlatoonAIPlan = 'ScoutingAI',
        
        Priority = 10,
		
		-- this function starts it at 12
        -- and removes it at 75 minutes 
		PriorityFunction = function(self, aiBrain, manager)
			
            if aiBrain.CycleTime > 4500 then
				return 0, false
			end

            if PlatoonCategoryCountAroundPosition( aiBrain.ArmyPool, AIRSCOUT, manager.Location, manager.Radius ) < 2 then
                return 10, true
            end
   
            if aiBrain.CycleTime > 720 then
                return 810, true
            else
                return 10, true
			end
		end,

        InstanceCount = 6,
		
        BuilderType = 'Any',
		
		BuilderConditions = {
            { LUTL, 'AirStrengthRatioGreaterThan', { 1 } },
        },
		
		BuilderData = {},
    },

    Builder {BuilderName = 'Air Scout Wing',
    
        PlatoonTemplate = 'Air Scout Group Large',
        
		PlatoonAIPlan = 'ScoutingAI',
        
        Priority = 10,
		
		-- this function starts it at 25
		PriorityFunction = function(self, aiBrain, manager)

            if PlatoonCategoryCountAroundPosition( aiBrain.ArmyPool, AIRSCOUT, manager.Location, manager.Radius ) < 5 then
                return 10, true
            end

            if aiBrain.CycleTime > 1500 then
                return 810, false
            else
                return 10, true
			end
		end,
		
        InstanceCount = 6,
		
        BuilderType = 'Any',
		
		BuilderConditions = {
            { LUTL, 'AirStrengthRatioGreaterThan', { 0.6 } },
		},
		
		BuilderData = {},
    },

    Builder {BuilderName = 'Air Scout Group',
    
        PlatoonTemplate = 'Air Scout Group Huge',
        
		PlatoonAIPlan = 'ScoutingAI',
        
        Priority = 10,
		
		-- this function will turn the builder on at the 75 minute mark
		PriorityFunction = function(self, aiBrain, manager)

            if PlatoonCategoryCountAroundPosition( aiBrain.ArmyPool, AIRSCOUT, manager.Location, manager.Radius ) < 9 then
                return 10, true
            end

			if aiBrain.CycleTime > 4500 then
				return 810, true
			else
                return 10, true
			end

		end,

        InstanceCount = 7,
		
        BuilderType = 'Any',
		
		BuilderConditions = {
            { LUTL, 'AirStrengthRatioGreaterThan', { 0.3 } },
		},
		
		BuilderData = {},
    },

	-- this will forward Scouts to either primary land or sea attack base
    Builder {BuilderName = 'Air Scout Reinforce Primary',
	
        PlatoonTemplate = 'Air Scout Group',
        
		PlatoonAddFunctions = { {BHVR, 'BroadcastPlatoonPlan'}, },
		
        InstanceCount = 2,
        
        PlatoonAIPlan = 'ReinforceAirAI',
        
        Priority = 10,

		PriorityFunction = function(self, aiBrain, manager)
            
            if PlatoonCategoryCountAroundPosition( aiBrain.ArmyPool, AIRSCOUT, manager.Location, manager.Radius ) < 2 then
                return 10,true
            end

            return NotPrimaryBase(self,aiBrain,manager), true
		end,
		
        BuilderConditions = {},
		
        BuilderData = {
            LocationType = 'LocationType',
        }, 
		
        BuilderType = 'Any',		
    },
	
}

BuilderGroup {BuilderGroupName = 'Air Formations - Hunt', BuildersType = 'PlatoonFormBuilder',
    
    ---------------
    --- BOMBERS ---
    ---------------
    -- small size short range groups that can merge quickly
    -- operates at ANY kind of base 
    Builder {BuilderName = 'Hunt Bombers Defensive Small',
	
        PlatoonTemplate = 'BomberAttack Small',
        
		PlatoonAddFunctions = { {BHVR, 'BroadcastPlatoonPlan'}, {BHVR, 'RetreatAI'} },

		PlatoonAddPlans = { 'PlatoonCallForHelpAI','DistressResponseAI' },

		PlatoonAIPlan = 'AttackForceAI_Bomber',		
		
        Priority = 700,
		
		PriorityFunction = function(self, aiBrain, manager)

            if PlatoonCategoryCountAroundPosition( aiBrain.ArmyPool, AIRBOMBER, manager.Location, manager.Radius ) < 1 then
                return 10,true
            else
                return 700,true
            end

        end,
	
        InstanceCount = 3,
		
        BuilderConditions = {},
		
        BuilderData = {
			DistressRange = 120,
            DistressReactionTime = 6,
			DistressTypes = 'Land',
			DistressThreshold = 3,
			
			LocationType = 'LocationType',
			
            MergeLimit = 12,
			
            MissionTime = 80,
			
            PrioritizedCategories = {categories.ENGINEER, categories.ECONOMY, categories.MOBILE - categories.SHIELD - categories.AIR - categories.SCOUT},
			
			SearchRadius = 50,	
			
            UseFormation = 'AttackFormation',
        },
		
        BuilderType = 'Any',
    },
    
    -- specifically hunts engineers
    Builder {BuilderName = 'Hunt Bombers Economic Small',
	
        PlatoonTemplate = 'BomberAttack Small',
        
		PlatoonAddFunctions = { {BHVR, 'BroadcastPlatoonPlan'}, {BHVR, 'RetreatAI'} },
		
		PlatoonAddPlans = { 'PlatoonCallForHelpAI','DistressResponseAI' },

		PlatoonAIPlan = 'AttackForceAI_Bomber',		
		
        Priority = 700,
		
		PriorityFunction = function(self, aiBrain, manager)

            if PlatoonCategoryCountAroundPosition( aiBrain.ArmyPool, AIRBOMBER, manager.Location, manager.Radius ) < 1 then
                return 10,true
            else
                return 700,true
            end

        end,
	
        InstanceCount = 2,
		
        BuilderConditions = {
            { LUTL, 'AirStrengthRatioGreaterThan', { 2.2 } },
        },
		
        BuilderData = {
			DistressRange = 125,
            DistressReactionTime = 6,
			DistressTypes = 'Land',
			DistressThreshold = 6,
			
			LocationType = 'LocationType',
			
            MergeLimit = false,     -- no merging for this platoon
			
            MissionTime = 90,
			
            PrioritizedCategories = { categories.MASSEXTRACTION, categories.ECONOMIC, categories.ENGINEER },
			
			SearchRadius = 60,	
			
            UseFormation = 'GrowthFormation',
        },
		
        BuilderType = 'Any',
    },

	-- medium sized group for close targets and distress response
    -- operates only from a PRIMARY BASE - Land or Naval
    Builder {BuilderName = 'Hunt Bombers Defensive Medium',
	
        PlatoonTemplate = 'BomberAttack',
        
		PlatoonAddFunctions = { {BHVR, 'BroadcastPlatoonPlan'}, {BHVR, 'RetreatAI'} },
		
		PlatoonAddPlans = { 'PlatoonCallForHelpAI','DistressResponseAI' },
		
		PlatoonAIPlan = 'AttackForceAI_Bomber',		

        Priority = 710,
		
		PriorityFunction = function(self, aiBrain, manager)
            
            if IsPrimaryBase(self,aiBrain,manager) == 710 then

                if PlatoonCategoryCountAroundPosition( aiBrain.ArmyPool, AIRBOMBER, manager.Location, manager.Radius ) < 12 then
                    return 10,true
                else
                    return 710,true
                end
                
            else
                return 10, true
            end
        end,

        InstanceCount = 3,

        BuilderConditions = {},
		
        BuilderData = {
			DistressRange = 165,
            DistressReactionTime = 6,            
			DistressTypes = 'Land',
			DistressThreshold = 4,
			
			LocationType = 'LocationType',
			
            MergeLimit = 25,
			
            MissionTime = 90,
			
            PrioritizedCategories = { categories.MOBILE - categories.AIR, categories.ECONOMIC },
			
			SearchRadius = 65,
			
            UseFormation = 'GrowthFormation',
        },
		
        BuilderType = 'Any',
    },
	
	-- medium sized group for mass targets and distress response
	Builder {BuilderName = 'Hunt Bombers Economic Medium',
	
        PlatoonTemplate = 'BomberAttack',
        
		PlatoonAddFunctions = { {BHVR, 'BroadcastPlatoonPlan'}, {BHVR, 'RetreatAI'} },
		
		PlatoonAddPlans = { 'PlatoonCallForHelpAI','DistressResponseAI' },
		
		PlatoonAIPlan = 'AttackForceAI_Bomber',		

        Priority = 710,
		
		PriorityFunction = function(self, aiBrain, manager)

            if PlatoonCategoryCountAroundPosition( aiBrain.ArmyPool, AIRBOMBER, manager.Location, manager.Radius ) < 12 then
                return 10,true
            else
                return 710,true
            end
        end,

        InstanceCount = 3,

        BuilderConditions = {
            { LUTL, 'AirStrengthRatioGreaterThan', { 2.2 } },
        },
		
        BuilderData = {
			DistressRange = 180,
            DistressReactionTime = 6,            
			DistressTypes = 'Land',
			DistressThreshold = 8,
			
			LocationType = 'LocationType',
			
            MergeLimit = 25,
			
            MissionTime = 125,
			
            PrioritizedCategories = { categories.ECONOMIC, categories.ENGINEER, categories.MASSPRODUCTION },
			
			SearchRadius = 100,
			
            UseFormation = 'AttackFormation',
        },
		
        BuilderType = 'Any',
    },

	-- large group for most targets on 20k maps and distress response 
    -- operates only from a PRIMARY BASE - Land or Naval	
    Builder {BuilderName = 'Hunt Bombers Large',
	
        PlatoonTemplate = 'BomberAttack Large',
        
		PlatoonAddFunctions = { {BHVR, 'BroadcastPlatoonPlan'}, {BHVR, 'RetreatAI'} },
		
		PlatoonAddPlans = { 'PlatoonCallForHelpAI','DistressResponseAI' },
		
		PlatoonAIPlan = 'AttackForceAI_Bomber',		

        Priority = 710,
		
		PriorityFunction = function(self, aiBrain, manager)
            
            if IsPrimaryBase(self,aiBrain,manager) == 710 then

                if PlatoonCategoryCountAroundPosition( aiBrain.ArmyPool, AIRBOMBER, manager.Location, manager.Radius ) < 24 then
                    return 10,true
                else
                    return 710,true
                end
                
            else
                return 10, true
            end
        end,
		
        InstanceCount = 2,

        BuilderConditions = {
            { LUTL, 'AirStrengthRatioGreaterThan', { 2.2 } },

			-- none of the major SUPER triggers can be true
			{ LUTL, 'GreaterThanEnemyUnitsAroundBase', { 'LocationType',  1, categories.NUKE + categories.ANTIMISSILE - categories.TECH2, 2000 }},
			{ LUTL, 'GreaterThanEnemyUnitsAroundBase', { 'LocationType',  1, categories.OPTICS * categories.STRUCTURE, 2500 }},
			{ LUTL, 'GreaterThanEnemyUnitsAroundBase', { 'LocationType',  1, categories.FACTORY * categories.STRUCTURE, 1000 }},
			{ LUTL, 'GreaterThanEnemyUnitsAroundBase', { 'LocationType',  1, categories.ANTIAIR * categories.STRUCTURE * categories.EXPERIMENTAL, 1000 }},            
			{ LUTL, 'GreaterThanEnemyUnitsAroundBase', { 'LocationType',  1, categories.ARTILLERY * categories.STRUCTURE * (categories.EXPERIMENTAL + categories.TECH3), 2000 }},
			{ LUTL, 'GreaterThanEnemyUnitsAroundBase', { 'LocationType',  1, categories.ECONOMIC * categories.EXPERIMENTAL, 2000 }},
			{ LUTL, 'GreaterThanEnemyUnitsAroundBase', { 'LocationType',  1, categories.MOBILE - categories.SNIPER - categories.TECH2, 1000 }},
        },
		
        BuilderData = {
			DistressRange = 200,
            DistressReactionTime = 10,            
			DistressTypes = 'Land',
			DistressThreshold = 15,
            
			LocationType = 'LocationType',
            
            MergeLimit = 64,
            
            MissionTime = 150,
            
            PrioritizedCategories = {categories.COMMAND, categories.ENGINEER, categories.SHIELD, categories.MOBILE - categories.AIR, categories.ECONOMIC - categories.TECH1},
            
			SearchRadius = 120,
            
            UseFormation = 'AttackFormation',
        },
		
        BuilderType = 'Any',
    },

	-- ALL SUPER groups are specifically targeted and come into play when the selected targets are available
	-- they DO NOT respond to distress calls	-- 
	-- they all have short mission timers so they go - fight - and go home
    -- affectionately called 'Cambodia Raids'

    Builder {BuilderName = 'Super Bombers - Artillery',
	
        PlatoonTemplate = 'BomberAttack Super',
		
		PlatoonAddFunctions = { {BHVR, 'BroadcastPlatoonPlan'}, {BHVR, 'RetreatAI'} },
		
		PlatoonAddPlans = { 'PlatoonCallForHelpAI','DistressResponseAI' },

		PlatoonAIPlan = 'AttackForceAI_Bomber',		
		
        Priority = 720,
		
		PriorityFunction = function(self, aiBrain, manager)
            
            if IsPrimaryBase(self,aiBrain,manager) == 720 then

                if PlatoonCategoryCount( aiBrain.ArmyPool, AIRBOMBER ) < 24 then
                    return 10,true
                else
                    return 720,true
                end
                
            else
                return 10, true
            end

        end,
        
        InstanceCount = 2,
		
        BuilderConditions = {
            { LUTL, 'AirStrengthRatioGreaterThan', { 2.2 } },
            
            { LUTL, 'PoolGreater', { 24, AIRBOMBER }},            
            
			{ LUTL, 'HaveGreaterThanUnitsWithCategoryAndAlliance', { 0, categories.ARTILLERY * categories.STRUCTURE, 'Enemy' }},

			{ UCBC, 'PoolGreaterAtLocation', { 'LocationType', 24, AIRBOMBER }},
        },
		
        BuilderData = {
			DistressRange = 150,
            DistressReactionTime = 10,            
			DistressTypes = 'Land',
			DistressThreshold = 50,
        
			LocationType = 'LocationType',
            MergeLimit = 50,
            MissionTime = 400,
            PrioritizedCategories = {categories.ARTILLERY * categories.STRUCTURE},
			SearchRadius = 850,
            UseFormation = 'AttackFormation',
        },
		
        BuilderType = 'Any',		
    },

    Builder {BuilderName = 'Super Bombers - AntiAir',
	
        PlatoonTemplate = 'BomberAttack Super',
		
		PlatoonAddFunctions = { {BHVR, 'BroadcastPlatoonPlan'}, {BHVR, 'RetreatAI'} },
		
		PlatoonAddPlans = { 'PlatoonCallForHelpAI','DistressResponseAI' },

		PlatoonAIPlan = 'AttackForceAI_Bomber',		
		
        Priority = 720,
		
		PriorityFunction = function(self, aiBrain, manager)
            
            if IsPrimaryBase(self,aiBrain,manager) == 720 then

                if PlatoonCategoryCount( aiBrain.ArmyPool, AIRBOMBER ) < 24 then
                
                    return 10,true
                    
                else
            
                    return 720,true

                end
                
            else
            
                return 10, true
                
            end

        end,

        InstanceCount = 1,
		
        BuilderConditions = {
          
            { LUTL, 'AirStrengthRatioGreaterThan', { 2.2 } },
            
            { LUTL, 'PoolGreater', { 24, AIRBOMBER }},
            
			{ LUTL, 'HaveGreaterThanUnitsWithCategoryAndAlliance', { 0, categories.ANTIAIR * categories.STRUCTURE - categories.TECH2, 'Enemy' }},

			{ UCBC, 'PoolGreaterAtLocation', { 'LocationType', 24, AIRBOMBER }},
        },
		
        BuilderData = {
			DistressRange = 150,
            DistressReactionTime = 10,            
			DistressTypes = 'Land',
			DistressThreshold = 50,

			LocationType = 'LocationType',
            
            MergeLimit = false,
            
            MissionTime = 360,

            PrioritizedCategories = {categories.ANTIAIR * categories.STRUCTURE - categories.TECH2},
            
			SearchRadius = 700,
            
            UseFormation = 'AttackFormation',
        },
		
        BuilderType = 'Any',        
    },

    Builder {BuilderName = 'Super Bombers - Nuke Antinuke',
	
        PlatoonTemplate = 'BomberAttack Super',
        
		PlatoonAddFunctions = { {BHVR, 'BroadcastPlatoonPlan'}, {BHVR, 'RetreatAI'} },

		PlatoonAIPlan = 'AttackForceAI_Bomber',		

        Priority = 720,
		
		PriorityFunction = function(self, aiBrain, manager)
            
            if IsPrimaryBase(self,aiBrain,manager) == 720 then

                if PlatoonCategoryCount( aiBrain.ArmyPool, AIRBOMBER ) < 24 then
                
                    return 10,true
                    
                else
            
                    return 720,true

                end
                
            else
            
                return 10, true
                
            end

        end,

        InstanceCount = 1,
		
        BuilderConditions = {
        
            { LUTL, 'AirStrengthRatioGreaterThan', { 2.5 } },
            
            { LUTL, 'PoolGreater', { 24, AIRBOMBER }},
            
			{ LUTL, 'HaveGreaterThanUnitsWithCategoryAndAlliance', { 0, categories.NUKE + categories.ANTIMISSILE - categories.TECH2, 'Enemy' }},

			{ UCBC, 'PoolGreaterAtLocation', { 'LocationType', 24, AIRBOMBER }},
        },
		
        BuilderData = {
			DistressRange = 150,
            DistressReactionTime = 10,            
			DistressTypes = 'Land',
			DistressThreshold = 50,

			LocationType = 'LocationType',
            MergeLimit = false,
            MissionTime = 400,
            PrioritizedCategories = {categories.NUKE + categories.ANTIMISSILE - categories.TECH2},
			SearchRadius = 700,
            UseFormation = 'AttackFormation',
        },
		
        BuilderType = 'Any',        
    },
	
    Builder {BuilderName = 'Super Bombers - Sniper',
	
        PlatoonTemplate = 'BomberAttack Super',
        
		PlatoonAddFunctions = { {BHVR, 'BroadcastPlatoonPlan'}, {BHVR, 'RetreatAI'} },
		
		PlatoonAddPlans = { 'PlatoonCallForHelpAI','DistressResponseAI' },

		PlatoonAIPlan = 'AttackForceAI_Bomber',		

        Priority = 720,
		
		PriorityFunction = function(self, aiBrain, manager)
            
            if IsPrimaryBase(self,aiBrain,manager) == 720 then

                if PlatoonCategoryCount( aiBrain.ArmyPool, AIRBOMBER ) < 24 then
                
                    return 10,true
                    
                else
            
                    return 720,true

                end
                
            else
            
                return 10, true
                
            end

        end,

        InstanceCount = 1,
		
        BuilderConditions = {
            { LUTL, 'AirStrengthRatioGreaterThan', { 2.5 } },
            
            { LUTL, 'PoolGreater', { 24, AIRBOMBER }},
            
			{ LUTL, 'HaveGreaterThanUnitsWithCategoryAndAlliance', { 0, categories.MOBILE + categories.SNIPER - categories.TECH2, 'Enemy' }},

			{ UCBC, 'PoolGreaterAtLocation', { 'LocationType', 24, AIRBOMBER }},
        },
		
        BuilderData = {
			DistressRange = 150,
            DistressReactionTime = 10,            
			DistressTypes = 'Land',
			DistressThreshold = 50,
        
			LocationType = 'LocationType',
            MergeLimit = false,
            MissionTime = 400,
            PrioritizedCategories = {categories.MOBILE + categories.SNIPER - categories.TECH2},
			SearchRadius = 700,
            UseFormation = 'AttackFormation',
        },
		
        BuilderType = 'Any',        
    },

    Builder {BuilderName = 'Super Bombers - Optics',
	
        PlatoonTemplate = 'BomberAttack Super',
        
		PlatoonAddFunctions = { {BHVR, 'BroadcastPlatoonPlan'}, {BHVR, 'RetreatAI'} },
		
		PlatoonAddPlans = { 'PlatoonCallForHelpAI','DistressResponseAI' },
		
		PlatoonAIPlan = 'AttackForceAI_Bomber',		
		
        Priority = 720,
		
		PriorityFunction = function(self, aiBrain, manager)
            
            if IsPrimaryBase(self,aiBrain,manager) == 720 then

                if PlatoonCategoryCount( aiBrain.ArmyPool, AIRBOMBER ) < 24 then
                
                    return 10,true
                    
                else
            
                    return 720,true

                end
                
            else
            
                return 10, true
                
            end

        end,

        InstanceCount = 2,
		
        BuilderConditions = {
            { LUTL, 'AirStrengthRatioGreaterThan', { 2.5 } },
            
            { LUTL, 'PoolGreater', { 24, AIRBOMBER }},
            
			{ LUTL, 'HaveGreaterThanUnitsWithCategoryAndAlliance', { 0, (categories.OPTICS) * categories.STRUCTURE, 'Enemy' }},

			{ UCBC, 'PoolGreaterAtLocation', { 'LocationType', 24, AIRBOMBER }},
        },
		
        BuilderData = {
			DistressRange = 150,
            DistressReactionTime = 10,            
			DistressTypes = 'Land',
			DistressThreshold = 50,
        
			LocationType = 'LocationType',
            MergeLimit = 50,
            MissionTime = 400,
            PrioritizedCategories = { (categories.OPTICS) * categories.STRUCTURE, categories.INTELLIGENCE * categories.STRUCTURE},
			SearchRadius = 850,
            UseFormation = 'AttackFormation',
        },
		
        BuilderType = 'Any',		
    },

    Builder {BuilderName = 'Super Bombers - Factory',
	
        PlatoonTemplate = 'BomberAttack Super',
        
		PlatoonAddFunctions = { {BHVR, 'BroadcastPlatoonPlan'}, {BHVR, 'RetreatAI'} },
		
		PlatoonAddPlans = { 'PlatoonCallForHelpAI','DistressResponseAI' },
		
		PlatoonAIPlan = 'AttackForceAI_Bomber',		
		
        Priority = 720,
		
		PriorityFunction = function(self, aiBrain, manager)
            
            if IsPrimaryBase(self,aiBrain,manager) == 720 then

                if PlatoonCategoryCount( aiBrain.ArmyPool, AIRBOMBER ) < 24 then
                
                    return 10,true
                    
                else
            
                    return 720,true

                end
                
            else
            
                return 10, true
                
            end

        end,

        InstanceCount = 2,
		
        BuilderConditions = {
            { LUTL, 'AirStrengthRatioGreaterThan', { 2.5 } },
            
            { LUTL, 'PoolGreater', { 24, AIRBOMBER }},
            
			{ LUTL, 'HaveGreaterThanUnitsWithCategoryAndAlliance', { 0, (categories.FACTORY) * categories.STRUCTURE, 'Enemy' }},

			{ UCBC, 'PoolGreaterAtLocation', { 'LocationType', 24, AIRBOMBER }},
        },
		
        BuilderData = {
			DistressRange = 150,
            DistressReactionTime = 10,            
			DistressTypes = 'Land',
			DistressThreshold = 50,
        
			LocationType = 'LocationType',
            MergeLimit = false,
            MissionTime = 480,
            PrioritizedCategories = { (categories.FACTORY) * categories.STRUCTURE},
			SearchRadius = 1000,
            UseFormation = 'AttackFormation',
        },
		
        BuilderType = 'Any',		
    },

    Builder {BuilderName = 'Super Bombers - Economic Experimental',
	
        PlatoonTemplate = 'BomberAttack Super',
        
		PlatoonAddFunctions = { {BHVR, 'BroadcastPlatoonPlan'}, {BHVR, 'RetreatAI'} },
		
		PlatoonAddPlans = { 'PlatoonCallForHelpAI','DistressResponseAI' },
		
		PlatoonAIPlan = 'AttackForceAI_Bomber',		

        Priority = 720,
		
		PriorityFunction = function(self, aiBrain, manager)
            
            if IsPrimaryBase(self,aiBrain,manager) == 720 then

                if PlatoonCategoryCount( aiBrain.ArmyPool, AIRBOMBER ) < 24 then
                
                    return 10,true
                    
                else
            
                    return 720,true

                end
                
            else
            
                return 10, true
                
            end

        end,

        InstanceCount = 1,

        BuilderConditions = {
            { LUTL, 'AirStrengthRatioGreaterThan', { 3 } },
            
            { LUTL, 'PoolGreater', { 24, AIRBOMBER }},            
            
			{ LUTL, 'HaveGreaterThanUnitsWithCategoryAndAlliance', { 0, categories.ECONOMIC * categories.EXPERIMENTAL, 'Enemy' }},

			{ UCBC, 'PoolGreaterAtLocation', { 'LocationType', 24, AIRBOMBER }},
        },
		
        BuilderData = {
			DistressRange = 150,
            DistressReactionTime = 10,            
			DistressTypes = 'Land',
			DistressThreshold = 50,
        
			LocationType = 'LocationType',
            MergeLimit = false,
            MissionTime = 480,
            PrioritizedCategories = {categories.ECONOMIC * categories.EXPERIMENTAL},
			SearchRadius = 1000,
            UseFormation = 'AttackFormation',
        },
		
        BuilderType = 'Any',        
    },
	
    ---------------
    --- FIGHTERS --
    ---------------
    -- small size short range groups that can merge quickly
    -- operates at ANY kind of base 
    
    -- upto 16 ASF for local air defense
    Builder {BuilderName = 'Hunt Fighters Defensive',
	
        PlatoonTemplate = 'FighterAttack Small',
        
		PlatoonAddFunctions = { {BHVR, 'BroadcastPlatoonPlan'} },
		
		PlatoonAddPlans = { 'PlatoonCallForHelpAI','DistressResponseAI' },

		PlatoonAIPlan = 'AttackForceAI',		
		
        Priority = 700,
		
		PriorityFunction = function(self, aiBrain, manager)

            if PlatoonCategoryCountAroundPosition( aiBrain.ArmyPool, AIRFIGHTER, manager.Location, manager.Radius ) < 2 then
                return 10,true
            else
                return 700,true
            end

        end,

        InstanceCount = 2,
		
        BuilderConditions = {},
		
        BuilderData = {
			DistressRange           = 200,
            DistressReactionTime    = 3,            
			DistressTypes           = 'Air',
			DistressThreshold       = 3,
			
			LocationType = 'LocationType',
			
            MergeLimit = 16,
			
            MissionTime = 80,
			
            PrioritizedCategories = { categories.AIR - categories.INTELLIGENCE - categories.TRANSPORTFOCUS, categories.TRANSPORTFOCUS },
			
			SearchRadius = 60,	
			
            UseFormation = 'GrowthFormation',
        },
		
        BuilderType = 'Any',
    },

    -- upto 16 ASF for hunting air scouts - short duration
    Builder {BuilderName = 'Hunt Fighters Defensive - Intel First',
	
        PlatoonTemplate = 'FighterAttack Small',
        
		PlatoonAddFunctions = { {BHVR, 'BroadcastPlatoonPlan'}, {BHVR, 'RetreatAI'} },
		
		PlatoonAddPlans = { 'PlatoonCallForHelpAI','DistressResponseAI' },

		PlatoonAIPlan = 'AttackForceAI',		
		
        Priority = 710,
		
		PriorityFunction = function(self, aiBrain, manager)

            if PlatoonCategoryCountAroundPosition( aiBrain.ArmyPool, AIRFIGHTER, manager.Location, manager.Radius ) < 2 then
                return 10,true
            else
                return 710,true
            end

        end,

        InstanceCount = 2,
		
        BuilderConditions = {
            { LUTL, 'AirStrengthRatioGreaterThan', { 1.5 } },
			{ LUTL, 'HaveGreaterThanUnitsWithCategoryAndAlliance', { 0, categories.AIR * categories.INTELLIGENCE, 'Enemy' }},
        },
		
        BuilderData = {
			DistressRange           = 150,
            DistressReactionTime    = 3,            
			DistressTypes           = 'Air',
			DistressThreshold       = 3,

			LocationType = 'LocationType',
			
            MergeLimit = 4,
			
            MissionTime = 60,
			
            PrioritizedCategories = { categories.AIR * categories.INTELLIGENCE, categories.TRANSPORTFOCUS },
			
			SearchRadius = 60,	
			
            UseFormation = 'AttackFormation',
        },
		
        BuilderType = 'Any',
    },

    -- upto 16 ASF for hunting Transports - short duration
    Builder {BuilderName = 'Hunt Fighters Defensive - Transport First',
	
        PlatoonTemplate = 'FighterAttack Small',
        
		PlatoonAddFunctions = { {BHVR, 'BroadcastPlatoonPlan'}, {BHVR, 'RetreatAI'} },
		
		PlatoonAddPlans = { 'PlatoonCallForHelpAI','DistressResponseAI' },
		
		PlatoonAIPlan = 'AttackForceAI',		
		
        Priority = 700,
		
		PriorityFunction = function(self, aiBrain, manager)

            if PlatoonCategoryCountAroundPosition( aiBrain.ArmyPool, AIRFIGHTER, manager.Location, manager.Radius ) < 2 then
                return 10,true
            else
                return 710,true
            end

        end,
        
        InstanceCount = 2,
		
        BuilderConditions = {
            { LUTL, 'AirStrengthRatioGreaterThan', { 1.5 } },
			{ LUTL, 'HaveGreaterThanUnitsWithCategoryAndAlliance', { 0, categories.TRANSPORTFOCUS, 'Enemy' }},
        },
		
        BuilderData = {
			DistressRange           = 150,
            DistressReactionTime    = 3,            
			DistressTypes           = 'Air',
			DistressThreshold       = 3,
			
			LocationType = 'LocationType',
			
            MergeLimit = 4,
			
            MissionTime = 60,
			
            PrioritizedCategories = { categories.TRANSPORTFOCUS, categories.AIR * categories.INTELLIGENCE },
			
			SearchRadius = 60,	
			
            UseFormation = 'AttackFormation',
        },
		
        BuilderType = 'Any',
    },


	-- medium sized group for close targets and distress response
    -- operates only from a PRIMARY BASE - Land or Naval   
    Builder {BuilderName = 'Hunt Fighters Local',
	
        PlatoonTemplate = 'FighterAttack',
        
		PlatoonAddFunctions = { {BHVR, 'BroadcastPlatoonPlan'}, {BHVR, 'RetreatAI'} },
		
		PlatoonAddPlans = { 'PlatoonCallForHelpAI','DistressResponseAI' },

		PlatoonAIPlan = 'AttackForceAI',		

        Priority = 710,
		
		PriorityFunction = function(self, aiBrain, manager)
            
            if IsPrimaryBase(self,aiBrain,manager) == 710 then

                if PlatoonCategoryCountAroundPosition( aiBrain.ArmyPool, AIRFIGHTER, manager.Location, manager.Radius ) < 18 then
                    return 10,true
                else
                    return 710,true
                end
                
            else
                return 10, true
            end

        end,

        InstanceCount = 2,

        BuilderConditions = {},
		
        BuilderData = {
			DistressRange = 220,
            DistressReactionTime = 3,
			DistressTypes = 'Air',
			DistressThreshold = 3,
			
			LocationType = 'LocationType',
			
            MergeLimit = 26,
			
            MissionTime = 120,
			
            PrioritizedCategories = { categories.AIR * categories.GROUNDATTACK, categories.AIR - categories.INTELLIGENCE - categories.TRANSPORTFOCUS},
			
			SearchRadius = 65,
			
            UseFormation = 'GrowthFormation',
        },
		
        BuilderType = 'Any',
    },

	-- large group for most targets on 20k maps and distress response 
    -- operates only from a PRIMARY BASE - Land or Naval	    
    Builder {BuilderName = 'Hunt Fighters Large',
	
        PlatoonTemplate = 'FighterAttack Large',
        
		PlatoonAddFunctions = { {BHVR, 'BroadcastPlatoonPlan'}, {BHVR, 'RetreatAI'} },
		
		PlatoonAddPlans = { 'PlatoonCallForHelpAI','DistressResponseAI' },

		PlatoonAIPlan = 'AttackForceAI',		

        Priority = 720,
		
		PriorityFunction = function(self, aiBrain, manager)
            
            if IsPrimaryBase(self,aiBrain,manager) == 720 then

                if PlatoonCategoryCountAroundPosition( aiBrain.ArmyPool, AIRFIGHTER, manager.Location, manager.Radius ) < 24 then
                    return 10,true
                else
                    return 720,true
                end
                
            else
                return 10, true
            end

        end,

        InstanceCount = 3,

        BuilderConditions = {},
		
        BuilderData = {
			DistressRange = 250,
            DistressReactionTime = 3,
			DistressTypes = 'Air',
			DistressThreshold = 3,
            
			LocationType = 'LocationType',
            
            MergeLimit = 48,
            
            MissionTime = 135,
            
            PrioritizedCategories = { categories.AIR * categories.EXPERIMENTAL, categories.AIR * categories.GROUNDATTACK, categories.AIR - categories.INTELLIGENCE - categories.TRANSPORTFOCUS },
            
			SearchRadius = 72,
            
            UseFormation = 'GrowthFormation',
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
		
		PriorityFunction = function(self, aiBrain, manager)

            if PlatoonCategoryCountAroundPosition( aiBrain.ArmyPool, AIRGUNSHIP, manager.Location, manager.Radius ) < 1 then
                return 10,true
            else
                return 700,true
            end

        end,

        InstanceCount = 3,

        BuilderConditions = {},
		
        BuilderData = {
			DistressRange = 120,
            DistressReactionTime = 8,
			DistressTypes = 'Land',
			DistressThreshold = 5,
			
			LocationType = 'LocationType',
			
            MergeLimit = 20,
			
            MissionTime = 100,
			
            PrioritizedCategories = {categories.ANTIAIR, categories.ENGINEER, categories.MOBILE - categories.AIR},
			
			SearchRadius = 48,
			
            UseFormation = 'AttackFormation',
        },
		
        BuilderType = 'Any',
    },

	-- medium sized group for close targets and distress response	
    -- operates only from a PRIMARY BASE - Land or Naval
    -- may include ANTIAIR EXPERIMENTALS
    Builder {BuilderName = 'Hunt Gunships Local',
	
        PlatoonTemplate = 'GunshipAttack',
        
		PlatoonAddFunctions = { {BHVR, 'BroadcastPlatoonPlan'}, {BHVR, 'RetreatAI'} },
		
		PlatoonAddPlans = { 'PlatoonCallForHelpAI', 'DistressResponseAI' },
		
		PlatoonAIPlan = 'AttackForceAI_Gunship',		
		
        Priority = 710,
		
		PriorityFunction = function(self, aiBrain, manager)
            
            if IsPrimaryBase(self,aiBrain,manager) == 710 then

                if PlatoonCategoryCountAroundPosition( aiBrain.ArmyPool, AIRGUNSHIP, manager.Location, manager.Radius ) < 16 then
                    return 10,true
                else
                    return 710,true
                end
                
            else
                return 10, true
            end

        end,

        InstanceCount = 3,

        BuilderConditions = {
            { LUTL, 'AirStrengthRatioGreaterThan', { 1 } },
        },
		
        BuilderData = {
			DistressRange = 140,
            DistressReactionTime = 8,
			DistressTypes = 'Land',
			DistressThreshold = 6,
			
			LocationType = 'LocationType',
			
            MergeLimit = 30,
			
            MissionTime = 180,
			
            PrioritizedCategories = {categories.GROUNDATTACK, categories.LAND * categories.ANTIAIR, categories.EXPERIMENTAL - categories.AIR, categories.MOBILE - categories.AIR, categories.ECONOMIC, categories.ENGINEER, categories.NUKE, categories.DEFENSE - categories.WALL},
			
			SearchRadius = 55,
			
            UseFormation = 'AttackFormation',
        },
		
        BuilderType = 'Any',
	},	
	
	-- Hunts economic targets, mainly Engineers
	-- medium sized group for Engineers targets and distress response	
    -- operates only from a PRIMARY BASE - Land or Naval
    -- may include ANTIAIR EXPERIMENTALS
    Builder {BuilderName = 'Hunt Gunships Economic',
	
        PlatoonTemplate = 'GunshipAttack Small',
        
		PlatoonAddFunctions = { {BHVR, 'BroadcastPlatoonPlan'}, {BHVR, 'RetreatAI'} },
		
		PlatoonAddPlans = { 'PlatoonCallForHelpAI', 'DistressResponseAI' },
		
		PlatoonAIPlan = 'AttackForceAI_Gunship',		
		
        Priority = 710,
		
		PriorityFunction = function(self, aiBrain, manager)
            
            if IsPrimaryBase(self,aiBrain,manager) == 710 then

                if PlatoonCategoryCountAroundPosition( aiBrain.ArmyPool, AIRGUNSHIP, manager.Location, manager.Radius ) < 6 then
                    return 10,true
                else
                    return 710,true
                end
                
            else
                return 10, true
            end

        end,

        InstanceCount = 4,

        BuilderConditions = {
            { LUTL, 'AirStrengthRatioGreaterThan', { 1 } },
        },
		
        BuilderData = {
			DistressRange = 180,
            DistressReactionTime = 10,            
			DistressTypes = 'Land',
			DistressThreshold = 10,
			
			LocationType = 'LocationType',
			
            MergeLimit = 45,
			
            MissionTime = 240,
			
            PrioritizedCategories = {categories.ENGINEER, categories.ANTIAIR - categories.AIR, categories.ECONOMIC, categories.MASSEXTRACTION},
			
			SearchRadius = 70,
			
            UseFormation = 'AttackFormation',
        },
		
        BuilderType = 'Any',
    },

	-- large group for most targets on 20k maps and distress response 
    -- operates only from a PRIMARY BASE - Land or Naval
    -- may include ANTIAIR EXPERIMENTALS	
    Builder {BuilderName = 'Hunt Gunships Large',
	
        PlatoonTemplate = 'GunshipAttack Large',
        
		PlatoonAddFunctions = { {BHVR, 'BroadcastPlatoonPlan'}, {BHVR, 'RetreatAI'} },
		
		PlatoonAddPlans = { 'PlatoonCallForHelpAI', 'DistressResponseAI' },
		
		PlatoonAIPlan = 'AttackForceAI_Gunship',		

        Priority = 720,
		
		PriorityFunction = function(self, aiBrain, manager)
            
            if IsPrimaryBase(self,aiBrain,manager) == 720 then

                if PlatoonCategoryCountAroundPosition( aiBrain.ArmyPool, AIRGUNSHIP, manager.Location, manager.Radius ) < 28 then
                    return 10,true
                else
                    return 720,true
                end
                
            else
                return 10, true
            end

        end,

        InstanceCount = 3,

        BuilderConditions = {},
		
        BuilderData = {
			DistressRange = 210,
            DistressReactionTime = 10,
			DistressTypes = 'Land',
			DistressThreshold = 12,
            
			LocationType = 'LocationType',
            
            MergeLimit = 64,
            
            MissionTime = 360,
            
            PrioritizedCategories = {categories.MOBILE * categories.SHIELD, categories.LAND * categories.MOBILE * categories.ANTIAIR, categories.ANTIAIR, categories.SHIELD, categories.ENGINEER, categories.MOBILE - categories.AIR, categories.STRUCTURE},
            
			SearchRadius = 85,
            
            UseFormation = 'AttackFormation',
        },
		
        BuilderType = 'Any',
    },

    --- REINFORCMENTS ---

	-- this will forward ANY bombers to the primary land attack base
    Builder {BuilderName = 'Reinforce Primary - Bomber Squadron',
	
        PlatoonTemplate = 'BomberReinforce',
        
		PlatoonAddFunctions = { {BHVR, 'BroadcastPlatoonPlan'}, },
		
        InstanceCount = 2,
        
        Priority = 10,

		PriorityFunction = function(self, aiBrain, manager)
            
            if PlatoonCategoryCountAroundPosition( aiBrain.ArmyPool, AIRBOMBER, manager.Location, manager.Radius ) < 3 then
                return 10,true
            end

            return NotPrimaryBase(self,aiBrain,manager), true
		end,
		
        BuilderConditions = {
            { LUTL, 'NoBaseAlert', { 'LocationType' }},		
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
		
        InstanceCount = 2,
        
        Priority = 10,

		PriorityFunction = function(self, aiBrain, manager)
            
            if PlatoonCategoryCountAroundPosition( aiBrain.ArmyPool, AIRFIGHTER, manager.Location, manager.Radius ) < 3 then
                return 10,true
            end

            return NotPrimaryBase(self,aiBrain,manager), true
		end,
		
        BuilderConditions = {
            { LUTL, 'NoBaseAlert', { 'LocationType' }},		
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

        InstanceCount = 2,
        
        Priority = 10,

		PriorityFunction = function(self, aiBrain, manager)
            
            if PlatoonCategoryCountAroundPosition( aiBrain.ArmyPool, AIRGUNSHIP, manager.Location, manager.Radius ) < 3 then
                return 10,true
            end

            return NotPrimaryBase(self,aiBrain,manager), true
		end,

        BuilderConditions = {
            { LUTL, 'NoBaseAlert', { 'LocationType' }},		
        },
		
        BuilderData = {
            LocationType = 'LocationType',
        },    
		
        BuilderType = 'Any',
    },

}

BuilderGroup {BuilderGroupName = 'Air Formations - Water Map', BuildersType = 'PlatoonFormBuilder',

	-- torpedo bomber groups kept close to home for defensive work and distress response
	-- a short term formation that will merge up into larger groups
    Builder {BuilderName = 'Hunt Torpedos Defensive',
	
        PlatoonTemplate = 'TorpedoAttack Small',
        
		PlatoonAddFunctions = { {BHVR, 'BroadcastPlatoonPlan'}, {BHVR, 'RetreatAI'} },
		
		PlatoonAddPlans = { 'PlatoonCallForHelpAI', 'DistressResponseAI' },
		
		PlatoonAIPlan = 'AttackForceAI_Torpedo',		
		
        Priority = 700,
		
		PriorityFunction = function(self, aiBrain, manager)

            if PlatoonCategoryCountAroundPosition( aiBrain.ArmyPool, AIRTORPEDO, manager.Location, manager.Radius ) < 1 then
                return 10,true
            else
                return 700,true
            end

        end,

        InstanceCount = 3,
		
        BuilderConditions = {},
		
        BuilderData = {
			DistressRange = 90,
            DistressReactionTime = 10,            
			DistressTypes = 'Naval',
			DistressThreshold = 3,
			
			LocationType = 'LocationType',
			
            MergeLimit = 12,
			
            MissionTime = 60,
			
            PrioritizedCategories = {categories.SUBMARINE, categories.MOBILE * categories.NAVAL, categories.SUBMERSIBLE},
			
			SearchRadius = 60,	
			
            UseFormation = 'AttackFormation',
        },
		
        BuilderType = 'Any',
    },

    Builder {BuilderName = 'Hunt Torpedos Local',
	
        PlatoonTemplate = 'TorpedoAttack',
        
		PlatoonAddFunctions = { {BHVR, 'BroadcastPlatoonPlan'}, {BHVR, 'RetreatAI'} },
		
		PlatoonAddPlans = { 'PlatoonCallForHelpAI', 'DistressResponseAI' },
		
		PlatoonAIPlan = 'AttackForceAI_Torpedo',

        Priority = 710,
		
		PriorityFunction = function(self, aiBrain, manager)
            
            if IsPrimaryBase(self,aiBrain,manager) == 710 then

                if PlatoonCategoryCountAroundPosition( aiBrain.ArmyPool, AIRTORPEDO, manager.Location, manager.Radius ) < 16 then
                    return 10,true
                else
                    return 710,true
                end
                
            else
                return 10, true
            end

        end,

        InstanceCount = 3,

        BuilderConditions = {},
		
        BuilderData = {
			DistressRange = 150,
            DistressReactionTime = 10,            
			DistressTypes = 'NaVal',
			DistressThreshold = 6,
			
			LocationType = 'LocationType',
			
            MergeLimit = 32,
			
            MissionTime = 120,
			
            PrioritizedCategories = { categories.CRUISER, categories.SUBMARINE, categories.MOBILE * categories.NAVAL, categories.SUBMERSIBLE },
			
			SearchRadius = 70,
			
            UseFormation = 'AttackFormation',
        },
		
        BuilderType = 'Any',
    },

    Builder {BuilderName = 'Hunt Torpedos Large',
	
        PlatoonTemplate = 'TorpedoAttack Large',
        
		PlatoonAddFunctions = { {BHVR, 'BroadcastPlatoonPlan'}, {BHVR, 'RetreatAI'} },
		
		PlatoonAddPlans = { 'PlatoonCallForHelpAI', 'DistressResponseAI' },
		
		PlatoonAIPlan = 'AttackForceAI_Torpedo',

        Priority = 715,
		
		PriorityFunction = function(self, aiBrain, manager)
            
            if IsPrimaryBase(self,aiBrain,manager) == 715 then

                if PlatoonCategoryCountAroundPosition( aiBrain.ArmyPool, AIRTORPEDO, manager.Location, manager.Radius ) < 32 then
                    return 10,true
                else
                    return 715,true
                end
                
            else
                return 10, true
            end

        end,
		
        InstanceCount = 2,

        BuilderConditions = {},
		
        BuilderData = {
			DistressRange = 180,
            DistressReactionTime = 12,            
			DistressTypes = 'NaVal',
			DistressThreshold = 8,
			
			LocationType = 'LocationType',
			
            MergeLimit = 64,
			
            MissionTime = 260,
			
            PrioritizedCategories = { categories.CRUISER, categories.SUBMARINE, categories.MOBILE * categories.NAVAL, categories.SUBMERSIBLE },
			
			SearchRadius = 100,
			
            UseFormation = 'AttackFormation',
        },
		
        BuilderType = 'Any',
    },

	-- this one goes after sonar
    Builder {BuilderName = 'Hunt Torps - Sonar',
	
        PlatoonTemplate = 'TorpedoAttack',
		
		PlatoonAddFunctions = { {BHVR, 'BroadcastPlatoonPlan'}, {BHVR, 'RetreatAI'} },
		
		PlatoonAddPlans = { 'PlatoonCallForHelpAI' },
		
		PlatoonAIPlan = 'AttackForceAI_Torpedo',
		
        Priority = 710,
		
		-- this will only form at primary bases
		PriorityFunction = function(self, aiBrain, manager)
            
            if IsPrimaryBase(self,aiBrain,manager) == 710 then

                if PlatoonCategoryCountAroundPosition( aiBrain.ArmyPool, AIRTORPEDO, manager.Location, manager.Radius ) < 16 then
                    return 10,true
                else
                    return 710,true
                end
                
            else
                return 10, true
            end

        end,

        InstanceCount = 1,
		
        BuilderType = 'Any',
		
        BuilderConditions = {
			{ LUTL, 'HaveGreaterThanUnitsWithCategoryAndAlliance', { 0, categories.SONAR * categories.STRUCTURE, 'Enemy' }},			
        },
		
        BuilderData = {
			LocationType = 'LocationType',
            
            MergeLimit = false,
            
            MissionTime = 150,
            
            PrioritizedCategories = { categories.SONAR * categories.STRUCTURE },
            
			SearchRadius = 250,
            
            UseFormation = 'AttackFormation',
        },
    },


    Builder {BuilderName = 'Reinforce Primary - Torpedo Squadron',
	
        PlatoonTemplate = 'TorpedoReinforce',
		
		PlatoonAddFunctions = { {BHVR, 'BroadcastPlatoonPlan'}, },
		
		PlatoonAddPlans = { 'PlatoonCallForHelpAI' },
        
        PlatoonAIPlan = 'ReinforceAirNavalAI',
        
        InstanceCount = 3,
	
        Priority = 10,
		
		-- this function turns the builder on at any base that is NOT the primary naval base
		PriorityFunction = function(self, aiBrain, manager)

            if PlatoonCategoryCountAroundPosition( aiBrain.ArmyPool, AIRTORPEDO, manager.Location, manager.Radius ) < 3 then
                return 10,true
            end

            if aiBrain.BuilderManagers[manager.LocationType].PrimarySeaAttackBase then
                return 10, true
            else
                return 720, true
            end
        end,

        BuilderConditions = {
            { LUTL, 'NoBaseAlert', { 'LocationType' }},
        },
		
        BuilderData = {
            LocationType = 'LocationType',
        },
		
        BuilderType = 'Any',
    }, 	

    -- Naval Flotilla Air Groups -- Large Support Groups
    Builder {BuilderName = 'Naval Fighter Squadron',
	
        PlatoonTemplate = 'FighterAttack',
		
		PlatoonAddFunctions = { {BHVR, 'BroadcastPlatoonPlan'}, {BHVR, 'RetreatAI'} },
		
		PlatoonAddPlans = { 'PlatoonCallForHelpAI', 'DistressResponseAI' },
        
        PlatoonAIPlan = 'GuardPointAir',
  		
        InstanceCount = 3,
		
        BuilderType = 'Any',
		
        Priority = 720,
		
		PriorityFunction = function(self, aiBrain, manager)

            if PlatoonCategoryCountAroundPosition( aiBrain.ArmyPool, AIRFIGHTER, manager.Location, manager.Radius ) < 18 then
                return 10,true
            else
                return 720,true
            end

        end,
		
        BuilderConditions = {
            { LUTL, 'NoBaseAlert', { 'LocationType' }},
            { LUTL, 'AirStrengthRatioGreaterThan', { 1.5 } },
            
			{ UCBC, 'HaveGreaterThanUnitsWithCategory', { 0, categories.CRUISER + categories.DESTROYER + (categories.NAVAL * categories.CARRIER) }},            
        },
		
        BuilderData = {
            AvoidBases = true,      -- don't seek points within a base managers radius --

			DistressRange = 240,
            DistressReactionTime = 6,            
			DistressTypes = 'Air',
			DistressThreshold = 16,
			
            LocationType = 'LocationType',
			
			PointType = 'Unit',
			PointCategory = categories.CRUISER + categories.DESTROYER + (categories.NAVAL * categories.CARRIER),
			PointSourceSelf = false,
			PointFaction = 'Self',
			PointRadius = 1200,
			PointSort = 'Furthest',
			PointMin = 120,
			PointMax = 1200,
            
            SetPatrol = true,
            PatrolRadius = 42,
			
			StrCategory = false,
			StrRadius = 65,
			StrTrigger = false,
			StrMin = 2,
			StrMax = 50,
            
            ThreatMaxRatio = 1.2,
            ThreatType = 'AntiAir',
			
			UntCategory = false,
			UntRadius = 100,
			UntTrigger = false,
			UntMin = 2,
			UntMax = 50,
			
            PrioritizedCategories = {'AIR MOBILE -INTELLIGENCE'},
			
			GuardRadius = 140,
			GuardTimer = 400,
			
			MergeLimit = 50,
			
			AggressiveMove = true,
			UseFormation = 'None',
        },    
    },     
	
    Builder {BuilderName = 'Naval Gunship Squadron',
	
        PlatoonTemplate = 'GunshipAttack',
		
		PlatoonAddFunctions = { {BHVR, 'BroadcastPlatoonPlan'},  {BHVR, 'RetreatAI'} },
		
		PlatoonAddPlans = { 'PlatoonCallForHelpAI','DistressResponseAI' },
        
        PlatoonAIPlan = 'GuardPointAir',
  
        InstanceCount = 6,
		
        BuilderType = 'Any',
		
        Priority = 720,
		
		PriorityFunction = function(self, aiBrain, manager)

            if PlatoonCategoryCountAroundPosition( aiBrain.ArmyPool, AIRGUNSHIP, manager.Location, manager.Radius ) < 16 then
                return 10,true
            else
                return 720,true
            end

        end,

		RTBLocation = 'Any',
		
        BuilderConditions = {
            { LUTL, 'NoBaseAlert', { 'LocationType' }},
            { LUTL, 'AirStrengthRatioGreaterThan', { 2 } },

			{ UCBC, 'HaveGreaterThanUnitsWithCategory', { 0, categories.CRUISER + categories.DESTROYER + (categories.NAVAL * categories.CARRIER) }},
        },
		
        BuilderData = {
            AvoidBases = false,     -- get them out onto the field
            
			DistressRange = 200,
            DistressReactionTime = 25,            
			DistressTypes = 'Naval',
			DistressThreshold = 8,
        
            LocationType = 'LocationType',
            
			PointType = 'Unit',
			PointCategory = categories.CRUISER + categories.DESTROYER + (categories.NAVAL * categories.CARRIER),
			PointSourceSelf = false,
			PointFaction = 'Self',
			PointRadius = 1200,
			PointSort = 'Furthest',
			PointMin = 120,
			PointMax = 1200,

            SetPatrol = true,
            PatrolRadius = 20,
			
			StrCategory = false,
			StrRadius = 65,
			StrTrigger = false,
			StrMin = 2,
			StrMax = 50,
            
            ThreatMaxRatio = 1.2,
            ThreatType = 'AntiSurface',

			UntCategory = false,
			UntRadius = 100,
			UntTrigger = false,
			UntMin = 2,
			UntMax = 50,
            
            PrioritizedCategories = {'NAVAL MOBILE SHIELD', 'NAVAL MOBILE -SUBMERSIBLE', 'GROUNDATTACK', 'LAND MOBILE', 'STRUCTURE'},
            
			GuardRadius = 125,
			GuardTimer = 420,
            
			MergeLimit = 20,
            
			AggressiveMove = true,
			UseFormation = 'None',
			
        },    
    },
	
    Builder {BuilderName = 'Naval Torpedo Squadron',
	
        PlatoonTemplate = 'TorpedoAttack',
		
		PlatoonAddFunctions = { {BHVR, 'BroadcastPlatoonPlan'}, {BHVR, 'RetreatAI'} },
		
		PlatoonAddPlans = { 'PlatoonCallForHelpAI','DistressResponseAI' },
        
        PlatoonAIPlan = 'GuardPointAir',
  		
        InstanceCount = 3,
		
        BuilderType = 'Any',
		
        Priority = 720,
		
		PriorityFunction = function(self, aiBrain, manager)

            if PlatoonCategoryCountAroundPosition( aiBrain.ArmyPool, AIRTORPEDO, manager.Location, manager.Radius ) < 16 then
                return 10,true
            else
                return 720,true
            end

        end,
		
		RTBLocation = 'Any',
		
        BuilderConditions = {
            { LUTL, 'NoBaseAlert', { 'LocationType' }},        
			{ UCBC, 'HaveGreaterThanUnitsWithCategory', { 0, categories.CRUISER + categories.DESTROYER + (categories.NAVAL * categories.CARRIER)}},
        },
		
        BuilderData = {
            AvoidBases = false,      -- we always want our torpedo bombers out there --
            
			DistressRange = 180,
            DistressReactionTime = 15,            
			DistressTypes = 'Naval',
			DistressThreshold = 8,
            
            LocationType = 'LocationType',
            RTBLocation = 'Any',
            
			PointType = 'Unit',
			PointCategory = categories.CRUISER + categories.DESTROYER + (categories.NAVAL * categories.CARRIER),
			PointSourceSelf = false,
			PointFaction = 'Self',
			PointRadius = 1200,
			PointSort = 'Furthest',
			PointMin = 120,
			PointMax = 1200,
            
            SetPatrol = true,
            PatrolRadius = 32,
            
			StrCategory = false,
			StrRadius = 65,
			StrTrigger = false,
			StrMin = 2,
			StrMax = 50,
            
            ThreatMaxRatio = 1.2,
            ThreatType = 'AntiNaval',
            
			UntCategory = false,
			UntRadius = 100,
			UntTrigger = false,
			UntMin = 2,
			UntMax = 50,
            
            PrioritizedCategories = {'CRUISER','SUBMARINE','NAVAL'},
            
			GuardRadius = 125,
			GuardTimer = 420,
            
			MergeLimit = 48,
            
			AggressiveMove = true,
			UseFormation = 'None',
        },    
    }, 
	

}

BuilderGroup {BuilderGroupName = 'Air Formations - Experimentals', BuildersRestriction = 'AIREXPERIMENTALS', BuildersType = 'PlatoonFormBuilder',
	
    Builder {BuilderName = 'Experimental Bombers',
	
        PlatoonTemplate = 'Experimental Bomber',
        
		PlatoonAddFunctions = { {BHVR, 'BroadcastPlatoonPlan'},{BHVR, 'AirForceAI_Bomber_LOUD'}, {BHVR, 'RetreatAI'} },		
		
		PlatoonAddPlans = { 'PlatoonCallForHelpAI', 'DistressResponseAI' },
		
        Priority = 730,
		
		PriorityFunction = function(self, aiBrain, manager)
            
            if IsPrimaryBase(self,aiBrain,manager) == 730 then

                if PlatoonCategoryCountAroundPosition( aiBrain.ArmyPool, AIRT4 * categories.BOMBER, manager.Location, manager.Radius ) < 3 then
                    return 10,true
                else
                    return 730,true
                end
                
            else
                return 10, true
            end

        end,

        InstanceCount = 2,
		
        BuilderType = 'Any',
		
        BuilderConditions = {
            { LUTL, 'AirStrengthRatioGreaterThan', { 2 } },
        },
		
        BuilderData = {
			DistressRange = 250,
            DistressReactionTime = 25,
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
		
		PriorityFunction = function(self, aiBrain, manager)
            
            if IsPrimaryBase(self,aiBrain,manager) == 730 then

                if PlatoonCategoryCountAroundPosition( aiBrain.ArmyPool, AIRT4 * categories.GROUNDATTACK, manager.Location, manager.Radius ) < 4 then
                    return 10,true
                else
                    return 730,true
                end
                
            else
                return 10, true
            end

        end,
		
        InstanceCount = 2,
		
        BuilderType = 'Any',
		
        BuilderConditions = {
            { LUTL, 'AirStrengthRatioGreaterThan', { 2 } },
        },
		
        BuilderData = {
			DistressRange = 250,
            DistressReactionTime = 25,            
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
		
		PriorityFunction = function(self, aiBrain, manager)
            
            if IsPrimaryBase(self,aiBrain,manager) == 730 then

                if PlatoonCategoryCountAroundPosition( aiBrain.ArmyPool, categories.uaa0310, manager.Location, manager.Radius ) < 3 then
                    return 10,true
                else
                    return 730,true
                end
                
            else
                return 10, true
            end

        end,

        InstanceCount = 2,
		
        BuilderType = 'Any',
		
        BuilderConditions = {
            { LUTL, 'AirStrengthRatioGreaterThan', { 2.2 } },
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
		
		PriorityFunction = function(self, aiBrain, manager)
            
            if IsPrimaryBase(self,aiBrain,manager) == 730 then

                if PlatoonCategoryCountAroundPosition( aiBrain.ArmyPool, categories.uaa0310, manager.Location, manager.Radius ) < 1 then
                    return 10,true
                else
                    return 730,true
                end
                
            else
                return 10, true
            end

        end,

        InstanceCount = 2,
		
        BuilderType = 'Any',
		
        BuilderConditions = {
            { LUTL, 'AirStrengthRatioGreaterThan', { 3 } },
		},
		
        BuilderData = {
            PrioritizedCategories = { 'ANTIAIR STRUCTURE','EXPERIMENTAL MOBILE -AIR', 'FACTORY STRUCTURE -TECH1', 'EXPERIMENTAL STRUCTURE', 'COMMAND' }, -- list in order
        },
    },
	
    -- defensive behavior for individual Czars when attack conditions not met
    -- this is the prototype behavior - but note this - it's only responsive to 'LAND' distress calls
	Builder {BuilderName = 'Czar Defensive Behavior - Land',
	
        PlatoonTemplate = 'CzarTerrorAttack',
		
        PlatoonAddBehaviors = {'BroadcastPlatoonPlan' },
        
		PlatoonAIPlan = 'PlatoonPatrolPointAI',
		
		PlatoonAddPlans = { 'PlatoonCallForHelpAI','DistressResponseAI'},
		
		FactionIndex = 2,

        Priority = 730,

		-- this function turns the builder on for Primary Land Base
		PriorityFunction = function(self, aiBrain, manager)

            if PlatoonCategoryCountAroundPosition( aiBrain.ArmyPool, categories.uaa0310, manager.Location, manager.Radius ) < 1 then
                return 10,true
            end
  			
			if aiBrain.BuilderManagers[manager.LocationType].PrimaryLandAttackBase then
				return 730, true
			end
			
			return 10, true
		end,
        
        InstanceCount = 2,
		
        BuilderType = 'Any',
		
        BuilderConditions = {
            { LUTL, 'AirStrengthRatioLessThan', { 3 } },
		},
		
        BuilderData = {
			DistressRange = 150,
            DistressReactionTime = 25,
			DistressTypes = 'Land',
			DistressThreshold = 10,

			BasePerimeterOrientation = 'FRONT',        
			Radius = 85,
			PatrolTime = 360,   -- approx 6 minute patrol --
            
            PrioritizedCategories = { 'ANTIAIR', 'ENGINEER', 'EXPERIMENTAL -AIR', 'NAVAL MOBILE', 'LAND MOBILE', 'COMMAND' }, -- list in order
        },
    },
    
    -- this one should work at naval positions
	Builder {BuilderName = 'Czar Defensive Behavior - Naval',
	
        PlatoonTemplate = 'CzarTerrorAttack',
		
        PlatoonAddBehaviors = {'BroadcastPlatoonPlan' },
        
		PlatoonAIPlan = 'PlatoonPatrolPointAI',
		
		PlatoonAddPlans = { 'PlatoonCallForHelpAI','DistressResponseAI'},
		
		FactionIndex = 2,

        Priority = 730,

		-- this function turns the builder on for Primary Sea Base 
		PriorityFunction = function(self, aiBrain, manager)

            if PlatoonCategoryCountAroundPosition( aiBrain.ArmyPool, categories.uaa0310, manager.Location, manager.Radius ) < 1 then
                return 10,true
            end
 			
			if aiBrain.BuilderManagers[manager.LocationType].PrimarySeaAttackBase then
				return 730, true
			end
			
			return 10, true
		end,
        
        InstanceCount = 2,
		
        BuilderType = 'Any',
		
        BuilderConditions = {
            { LUTL, 'AirStrengthRatioLessThan', { 3 } },
		},
		
        BuilderData = {
			DistressRange = 150,
            DistressReactionTime = 25,
			DistressTypes = 'Naval',
			DistressThreshold = 10,

			BasePerimeterOrientation = 'ALL',        
			Radius = 85,
			PatrolTime = 360,   -- approx 6 minute patrol --
            
            PrioritizedCategories = { 'ANTIAIR', 'ENGINEER', 'EXPERIMENTAL -AIR', 'NAVAL MOBILE', 'LAND MOBILE', 'COMMAND' }, -- list in order
        },
    },


	Builder {BuilderName = 'Reinforce Primary - Air Experimental',
	
		PlatoonTemplate = 'ReinforceAirExperimental',
		
        PlatoonAddBehaviors = {'BroadcastPlatoonPlan' },
		
		PlatoonAddPlans = { 'PlatoonCallForHelpAI' },
		
        Priority = 10,

		PriorityFunction = function(self, aiBrain, manager)
            
            if PlatoonCategoryCountAroundPosition( aiBrain.ArmyPool, AIRT4, manager.Location, manager.Radius ) < 1 then
                return 10,true
            end

            return NotPrimaryBase(self,aiBrain,manager), true
		end,

        InstanceCount = 2,
		
        BuilderType = 'Any',
		
        BuilderConditions = {
            { LUTL, 'NoBaseAlert', { 'LocationType' }},
        },
		
        BuilderData = {
            UseFormation = 'GrowthFormation',
        },
	},
}

