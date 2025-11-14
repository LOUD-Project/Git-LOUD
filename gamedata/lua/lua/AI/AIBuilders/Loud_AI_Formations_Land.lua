--  Loud_AI_Land_Attack_Builders.lua
--- all platoon taskS for land combat units

local MIBC  = '/lua/editor/MiscBuildConditions.lua'
local UCBC  = '/lua/editor/UnitCountBuildConditions.lua'
local EBC   = '/lua/editor/EconomyBuildConditions.lua'
local LUTL  = '/lua/loudutilities.lua'
local TBC   = '/lua/editor/ThreatBuildConditions.lua'
local BHVR  = '/lua/ai/aibehaviors.lua'

local NotPrimaryBase = function( self,aiBrain,manager)

	if aiBrain.BuilderManagers[manager.LocationType].PrimaryLandAttackBase or aiBrain.BuilderManagers[manager.LocationType].PrimarySeaAttackBase then

		return self.OldPriority or self.Priority, true
		
	end

	return 650, true
	
end

local IsPrimaryBase = function(self,aiBrain,manager)
	
	if aiBrain.BuilderManagers[manager.LocationType].PrimaryLandAttackBase or aiBrain.BuilderManagers[manager.LocationType].PrimarySeaAttackBase then
	
		return self.OldPriority or self.Priority, true
		
	end

	return 10, true
	
end

local PlatoonCategoryCount                  = moho.platoon_methods.PlatoonCategoryCount
local PlatoonCategoryCountAroundPosition    = moho.platoon_methods.PlatoonCategoryCountAroundPosition

local DEFENSESTRUCTURE  = categories.STRUCTURE * categories.DEFENSE * (categories.DIRECTFIRE + categories.INDIRECTFIRE)

local LAND              = categories.LAND * categories.MOBILE

local LANDAMPHIB        = LAND * categories.AMPHIBIOUS - categories.SCOUT - categories.ENGINEER - categories.EXPERIMENTAL
local LANDANTIAIR       = LAND * categories.ANTIAIR
local LANDARTILLERY     = LAND * categories.INDIRECTFIRE - categories.EXPERIMENTAL
local LANDDIRECTFIRE    = LAND * categories.DIRECTFIRE - categories.SCOUT - categories.ENGINEER - categories.EXPERIMENTAL
local LANDSCOUT         = LAND * categories.SCOUT

-- used to group T3 artillery into platoons
BuilderGroup {BuilderGroupName = 'Land Formations - Artillery',
    BuildersType = 'PlatoonFormBuilder',
	
	Builder {BuilderName = 'T3 Artillery Formation',

        PlatoonTemplate = 'StrategicArtilleryStructure',

        Priority = 600,
		
		PriorityFunction = function(self, aiBrain, manager)

            if PlatoonCategoryCountAroundPosition( aiBrain.ArmyPool, categories.ARTILLERY * categories.STRUCTURE - categories.TACTICAL - categories.TECH2 - categories.TECH1, manager.Location, manager.Radius ) < 1 then
                return 10,true
            else
                return 600,true
            end
        end,

        InstanceCount = 12,

        BuilderType = 'Any',
        
        BuilderConditions = {},
    },
}

-- used to group nuke launchers into platoons
BuilderGroup {BuilderGroupName = 'Land Formations - Nukes',
    BuildersType = 'PlatoonFormBuilder',
	
    Builder {BuilderName = 'Nuke Silo Formation',

        PlatoonTemplate = 'T3Nuke',

        Priority = 600,
		
		PriorityFunction = function(self, aiBrain, manager)

            if PlatoonCategoryCountAroundPosition( aiBrain.ArmyPool, categories.STRATEGIC * categories.STRUCTURE * categories.NUKE, manager.Location, manager.Radius ) < 1 then
                return 10,true
            else
                return 600,true
            end
        end,

        InstanceCount = 4,

        BuilderType = 'Any',

        BuilderConditions = {},
    },
}

BuilderGroup {BuilderGroupName = 'Land Formations - Scouts',
    BuildersType = 'PlatoonFormBuilder',
	
    Builder {BuilderName = 'Land Scout Formation - Aeon',
	
        PlatoonTemplate = 'T1LandScoutForm',
		PlatoonAIPlan = 'ScoutingAI',
		FactionIndex = 2,
        Priority = 800,
		
		PriorityFunction = function(self, aiBrain, manager)

            if PlatoonCategoryCountAroundPosition( aiBrain.ArmyPool, LANDSCOUT, manager.Location, manager.Radius ) < 2 then
                return 10,true
            else
                return 800,true
            end

        end,

        InstanceCount = 7,

        BuilderType = 'Any',

		BuilderConditions = {
			{ LUTL, 'NoBaseAlert', { 'LocationType' }},
		},

        BuilderData = {
			Patrol = true,
        },
		
    },
	
    Builder {BuilderName = 'Land Scout Formation - UEF',
	
        PlatoonTemplate = 'T1LandScoutForm',
		PlatoonAIPlan = 'ScoutingAI',
		FactionIndex = 1,
        Priority = 800,
		
		PriorityFunction = function(self, aiBrain, manager)

            if PlatoonCategoryCountAroundPosition( aiBrain.ArmyPool, LANDSCOUT, manager.Location, manager.Radius ) < 2 then
                return 10,true
            else
                return 800,true
            end

        end,

        InstanceCount = 7,

        BuilderType = 'Any',

		BuilderConditions = {
			{ LUTL, 'NoBaseAlert', { 'LocationType' }},
		},

        BuilderData = {
			Patrol = true,
        },
		
    },
	
    Builder {BuilderName = 'Land Scout Formation - Cybran',
	
        PlatoonTemplate = 'T1LandScoutForm',
		PlatoonAIPlan = 'ScoutingAI',
		FactionIndex = 3,
        Priority = 800,
		
		PriorityFunction = function(self, aiBrain, manager)

            if PlatoonCategoryCountAroundPosition( aiBrain.ArmyPool, LANDSCOUT, manager.Location, manager.Radius ) < 1 then
                return 10,true
            else
                return 800,true
            end

        end,

        InstanceCount = 10,

        BuilderType = 'Any',

		BuilderConditions = {
			{ LUTL, 'NoBaseAlert', { 'LocationType' }},
		},

        BuilderData = {
			Patrol = true,
			HoldFireOnPatrol = false, -- not needed since they don't have a weapon
        },
		
    },
	
    Builder {BuilderName = 'Land Scout Formation - Sera',
        PlatoonTemplate = 'T1LandScoutForm',
		PlatoonAIPlan = 'ScoutingAI',
		FactionIndex = 4,
        Priority = 800,
		
		PriorityFunction = function(self, aiBrain, manager)

            if PlatoonCategoryCountAroundPosition( aiBrain.ArmyPool, LANDSCOUT, manager.Location, manager.Radius ) < 2 then
                return 10,true
            else
                return 800,true
            end

        end,

        InstanceCount = 7,

        BuilderType = 'Any',

		BuilderConditions = {
			{ LUTL, 'NoBaseAlert', { 'LocationType' }},
		},

        BuilderData = {
			Patrol = false,	-- unlike other scouts, by being stationary they become cloaked
			HoldFireOnPatrol = true,	-- so we also hold fire when we are on our patrol station
        },
		
    },
	
}

BuilderGroup {BuilderGroupName = 'Land Formations - Land Only Map',
    BuildersType = 'PlatoonFormBuilder',
    
    -- this is the VENTING attack -- no odds required
	-- primarily looking for fights with units before fixed enemy positions
	
	-- Base Alerts will now stop venting forces from moving out
	-- This will allow LOUD to continue his buildup until HE sees its time to push out
	-- We do not want to force him out if he feels he can not push himself
    Builder {BuilderName = 'Land Attack - Unit Forced',
	
        PlatoonTemplate = 'LandAttackHugeNW',
        
		PlatoonAddFunctions = { {BHVR, 'AirLandToggle'}, {BHVR, 'BroadcastPlatoonPlan'} },		
		
		PlatoonAddPlans = { 'PlatoonCallForHelpAI','DistressResponseAI' },
		
        Priority = 803,
		
		PriorityFunction = function(self, aiBrain, manager)

            if PlatoonCategoryCountAroundPosition( aiBrain.ArmyPool, LANDDIRECTFIRE, manager.Location, manager.Radius ) < 56 then
                return 10,true
            elseif PlatoonCategoryCountAroundPosition( aiBrain.ArmyPool, LANDARTILLERY, manager.Location, manager.Radius ) < 12 then
                return 10,true
            else
                return 803,true
            end
        end,
		
		RTBLocation = 'Any',
		
        InstanceCount = 3,
		
        BuilderType = 'Any',
		
        BuilderConditions = {
			{ LUTL, 'NoBaseAlert', { 'LocationType' }},
            { LUTL, 'BaseInLandMode', { 'LocationType' }},
        },
		
        BuilderData = {
			DistressRange = 80,
			DistressTypes = 'Land',
			DistressThreshold = 10,

            PrioritizedCategories = { 'LAND MOBILE','ENGINEER','SHIELD','STRUCTURE -WALL'},		-- controls target selection

			MergeLimit = 100,	-- controls merging with others - nil = original platoon size

            AggressiveMove = true,            

			UseFormation = 'AttackFormation',

            WaypointSlackDistance = 36,     -- controls the slack distance when using pathed movement - large platoons require more 		
        },
    },

	-- this is the primary economic attack platoon
    -- specifically target economic targets first then bases
    Builder {BuilderName = 'MEX Attack Land - Large',
	
        PlatoonTemplate = 'T3MassAttack',
		PlatoonAddFunctions = { {BHVR, 'AirLandToggle'}, {BHVR, 'BroadcastPlatoonPlan'} },
		
		PlatoonAddPlans = { 'PlatoonCallForHelpAI','DistressResponseAI' },
		
        Priority = 802,
		
		PriorityFunction = function(self, aiBrain, manager)
            
            if IsPrimaryBase(self,aiBrain,manager) == 802 then

                if PlatoonCategoryCountAroundPosition( aiBrain.ArmyPool, LANDDIRECTFIRE, manager.Location, manager.Radius ) < 45 then
                    return 10,true
                elseif PlatoonCategoryCountAroundPosition( aiBrain.ArmyPool, LANDARTILLERY, manager.Location, manager.Radius ) < 15 then
                    return 10,true
                else
                    return 802,true
                end
                
            else
                return 10, true
            end

        end,

        InstanceCount = 2,
		
        BuilderType = 'Any',
		
        BuilderConditions = {
			{ LUTL, 'NoBaseAlert', { 'LocationType' }},
            { LUTL, 'BaseInLandMode', { 'LocationType' }},
            
			-- economic targets within 20km
			{ LUTL, 'GreaterThanEnemyUnitsAroundBase', { 'LocationType', 0, categories.ECONOMIC, 1000 }},

			{ TBC, 'ThreatFurtherThan', { 'LocationType', 175, 'Land', 200 }},            
        },
		
        BuilderData = {
			DistressRange = 100,
			DistressTypes = 'Land',
			DistressThreshold = 5,
			
			PointType = 'Unit',
			PointCategory = categories.ECONOMIC,
			PointSourceSelf = true,
			PointFaction = 'Enemy',
			PointRadius = 1000,
			PointSort = 'Closest',
			PointMin = 100,
			PointMax = 1000,
			
			StrCategory = DEFENSESTRUCTURE,
			StrRadius = 50,
			StrTrigger = true,
			StrMin = 0,
			StrMax = 20,
            
            -- this high threatmaxratio allows him to ignore IMAP threat levels better
            -- allowing the Structure & Unit triggers to operate more effectively in the selection process
            -- it can make him seem 'rabid' in this respect - but if his intel is good - this will be effective
            ThreatMaxRatio = 1.25,
			
			UntCategory = LANDDIRECTFIRE + LANDARTILLERY,
			UntRadius = 60,
			UntTrigger = true,
			UntMin = 0,
			UntMax = 45,
			
            PrioritizedCategories = { 'ECONOMIC','FACTORY','SHIELD','DEFENSE STRUCTURE','LAND MOBILE','ENGINEER'},
			
			GuardRadius = 70,
			GuardTimer = 30,
			
			MergeLimit = 100,
			
			AggressiveMove = true,
			
			AllowInWater = false,
			
			UseFormation = 'AttackFormation',

            WaypointSlackDistance = 32,     -- controls the slack distance when using pathed movement - large platoons require more
        },
    },

	-- attack enemy ANTIAIR STRUCTURES - essentially harrass isolated AA positions
    Builder {BuilderName = 'AA Attack Land',
	
        PlatoonTemplate = 'T2MassAttack',
        
		PlatoonAddFunctions = { {BHVR, 'AirLandToggle'}, {BHVR, 'BroadcastPlatoonPlan'}, {BHVR, 'RetreatAI'} },
		
		PlatoonAddPlans = { 'PlatoonCallForHelpAI' },
		
        Priority = 801,
		
		PriorityFunction = function(self, aiBrain, manager)
            
            if IsPrimaryBase(self,aiBrain,manager) == 801 then

                if PlatoonCategoryCountAroundPosition( aiBrain.ArmyPool, LANDDIRECTFIRE, manager.Location, manager.Radius ) < 24 then
                    return 10,true
                else
                    return 801,true
                end
                
            else
                return 10, true
            end

        end,

        InstanceCount = 2,
		
        BuilderType = 'Any',
		
        BuilderConditions = {
			{ LUTL, 'NoBaseAlert', { 'LocationType' }},
			{ LUTL, 'AirStrengthRatioGreaterThan', { 1 } },
			{ LUTL, 'LandStrengthRatioGreaterThan', { 1 } },
			{ TBC, 'ThreatFurtherThan', { 'LocationType', 175, 'Land', 200 }},            

			-- enemy AA structures within 20km
			{ LUTL, 'GreaterThanEnemyUnitsAroundBase', { 'LocationType', 0, categories.ANTIAIR * categories.STRUCTURE, 1000 }},
        },
		
        BuilderData = {
			PointType = 'Unit',
			PointCategory = categories.ANTIAIR * categories.STRUCTURE,
			PointSourceSelf = true,
			PointFaction = 'Enemy',
			PointRadius = 1000,
			PointSort = 'Closest',
			PointMin = 300,
			PointMax = 1000,
			
			StrCategory = DEFENSESTRUCTURE,
			StrRadius = 50,
			StrTrigger = true,
			StrMin = 0,
			StrMax = 8,
            
            -- this high threatmaxratio allows him to ignore IMAP threat levels better
            -- allowing the Structure & Unit triggers to operate more effectively in the selection process
            -- it can make him seem 'rabid' in this respect - but if his intel is good - this will be effective
            ThreatMaxRatio = 1.5,
			
			UntCategory = LANDDIRECTFIRE + LANDARTILLERY,
			UntRadius = 60,
			UntTrigger = true,
			UntMin = 0,
			UntMax = 24,
			
            PrioritizedCategories = { 'ANTIAIR STRUCTURE','DEFENSE STRUCTURE','ECONOMIC','ENGINEER','STRUCTURE -WALL','LAND MOBILE'},
			
			GuardRadius = 45,
			GuardTimer = 12,
			
			MergeLimit = 48,
			
			AggressiveMove = true,
			
			AllowInWater = false,
			
			UseFormation = 'AttackFormation',
            
            WaypointSlackDistance = 28,     -- controls the slack distance when using pathed movement - large platoons require more            
        },
	},

	-- modest sized base attack platoon
    -- forms when odds ok at (>.9)
    -- focused on bases first -- no distance restriction
    Builder {BuilderName = 'Land Attack Large NW',
	
        PlatoonTemplate = 'T3LandAttackNW',
        
		PlatoonAddFunctions = { {BHVR, 'AirLandToggle'}, {BHVR, 'BroadcastPlatoonPlan'}, {BHVR, 'RetreatAI'} },
		
		PlatoonAddPlans = { 'PlatoonCallForHelpAI' },
		
        Priority = 800,
		
		PriorityFunction = function(self, aiBrain, manager)
            
            if IsPrimaryBase(self,aiBrain,manager) == 800 then

                if PlatoonCategoryCountAroundPosition( aiBrain.ArmyPool, LANDDIRECTFIRE, manager.Location, manager.Radius ) < 45 then
                    return 10,true
                elseif PlatoonCategoryCountAroundPosition( aiBrain.ArmyPool, LANDARTILLERY, manager.Location, manager.Radius ) < 12 then
                    return 10,true
                else
                    return 800,true
                end
                
            else
                return 10, true
            end

        end,

        InstanceCount = 2,
		
        BuilderType = 'Any',
		
        BuilderConditions = {
			{ LUTL, 'NoBaseAlert', { 'LocationType' }},
            { LUTL, 'BaseInLandMode', { 'LocationType' }},
			{ LUTL, 'LandStrengthRatioGreaterThan', { 0.9 } },
        },
		
        BuilderData = {
		
			MergeLimit = 100,
			
            PrioritizedCategories = { 'FACTORY','DEFENSE STRUCTURE','ECONOMIC','DEFENSE'},
			
			UseFormation = 'AttackFormation',
			
            AggressiveMove = true,

            WaypointSlackDistance = 32,     -- controls the slack distance when using pathed movement - large platoons require more                        
        },
	},
	
	-- This Attacks are more modest in size, only deployed when we have a landstrength advantage.
	-- Notice how this platoon focuses on more specific categories. 
	-- modest sized production attack platoon
    -- forms when odds are good at (>1)
    -- focused on production first -- no distance restriction
    Builder {BuilderName = 'Land Attack Large',
	
        PlatoonTemplate = 'T2LandAttack',
        
		PlatoonAddFunctions = { {BHVR, 'AirLandToggle'}, {BHVR, 'BroadcastPlatoonPlan'}, {BHVR, 'RetreatAI'} },
		
		PlatoonAddPlans = { 'PlatoonCallForHelpAI','DistressResponseAI' },
        
        PlatoonAIPlan = 'LandForceAILOUD',
        
        Priority = 800,
		
		PriorityFunction = function(self, aiBrain, manager)
            
            if IsPrimaryBase(self,aiBrain,manager) == 800 then

                if PlatoonCategoryCountAroundPosition( aiBrain.ArmyPool, LANDDIRECTFIRE, manager.Location, manager.Radius ) < 24 then
                    return 10,true
                else
                    return 800,true
                end
                
            else
                return 10, true
            end

        end,

        InstanceCount = 2,
		
        BuilderType = 'Any',
		
        BuilderConditions = {
			{ LUTL, 'NoBaseAlert', { 'LocationType' }},
            { LUTL, 'BaseInLandMode', { 'LocationType' }},
			{ LUTL, 'LandStrengthRatioGreaterThan', { 1 } },
        },
		
        BuilderData = {
			DistressRange = 100,
			DistressTypes = 'Land',
			DistressThreshold = 5,
		
			MergeLimit = 80,
			
            PrioritizedCategories = { 'FACTORY','DEFENSE STRUCTURE','ECONOMIC','DEFENSE'},		# controls target selection 
			
			UseFormation = 'AttackFormation',
			
            AggressiveMove = true,

            WaypointSlackDistance = 28,
        },
	},
	
	-- another modest sized attack platoon
    -- forms when odds are hohum (>.8) but more of them
    -- focus on economic structures within 25km
    Builder {BuilderName = 'MEX Attack Land',
	
        PlatoonTemplate = 'T2MassAttack',
		PlatoonAddFunctions = { {BHVR, 'AirLandToggle'}, {BHVR, 'BroadcastPlatoonPlan'}, {BHVR, 'RetreatAI'} },
		
		PlatoonAddPlans = { 'PlatoonCallForHelpAI','DistressResponseAI' },
		
        Priority = 800,
		
		PriorityFunction = function(self, aiBrain, manager)
            
            if IsPrimaryBase(self,aiBrain,manager) == 800 then

                if PlatoonCategoryCountAroundPosition( aiBrain.ArmyPool, LANDDIRECTFIRE, manager.Location, manager.Radius ) < 24 then
                    return 10,true
                else
                    return 800,true
                end
                
            else
                return 10, true
            end

        end,

        InstanceCount = 3,
		
        BuilderType = 'Any',
		
        BuilderConditions = {
			{ LUTL, 'NoBaseAlert', { 'LocationType' }},
            { LUTL, 'BaseInLandMode', { 'LocationType' }},
			{ LUTL, 'LandStrengthRatioGreaterThan', { 0.7 } },

			{ TBC, 'ThreatFurtherThan', { 'LocationType', 200, 'Land', 300 }},            
        },
		
        BuilderData = {
			DistressRange = 100,
			DistressTypes = 'Land',
			DistressThreshold = 5,
			
			PointType = 'Unit',
			PointCategory = categories.MASSPRODUCTION,
			PointSourceSelf = true,
			PointFaction = 'Enemy',
			PointRadius = 1250,
			PointSort = 'Closest',
			PointMin = 150,
			PointMax = 1250,
			
			StrCategory = DEFENSESTRUCTURE,
			StrRadius = 60,
			StrTrigger = true,
			StrMin = 0,
			StrMax = 10,
            
            ThreatMaxRatio = 1.25,
			
			UntCategory = LANDDIRECTFIRE + LANDARTILLERY,
			UntRadius = 60,
			UntTrigger = true,
			UntMin = 0,
			UntMax = 20,
			
            PrioritizedCategories = { 'ENGINEER','MASSPRODUCTION','FACTORY','DEFENSE STRUCTURE','SHIELD','ECONOMIC'},
			
			GuardRadius = 75,
			GuardTimer = 25,
			
			MergeLimit = 60,
			
			AggressiveMove = true,
			
			AllowInWater = false,
			
			UseFormation = 'AttackFormation',

            WaypointSlackDistance = 28,
        },
    },
	
	-- another MASSEXTRACTION attack but smaller
    -- formed when team does not have it's mass share
    -- attacks MASSPRODUCTION positions within 15 km
    Builder {BuilderName = 'MEX Attack Land Need Mass',
	
        PlatoonTemplate = 'T2MassAttack',
		PlatoonAddFunctions = { {BHVR, 'AirLandToggle'}, {BHVR, 'BroadcastPlatoonPlan'}, {BHVR, 'RetreatAI'} },
		
		PlatoonAddPlans = { 'PlatoonCallForHelpAI','DistressResponseAI' },
		
        Priority = 800,
		
		PriorityFunction = function(self, aiBrain, manager)
            
            if IsPrimaryBase(self,aiBrain,manager) == 800 then

                if PlatoonCategoryCountAroundPosition( aiBrain.ArmyPool, LANDDIRECTFIRE, manager.Location, manager.Radius ) < 24 then
                    return 10,true
                else
                    return 800,true
                end
                
            else
                return 10, true
            end

        end,

        InstanceCount = 2,
		
        BuilderType = 'Any',
		
        BuilderConditions = {
			{ LUTL, 'NeedTeamMassPointShare', {}},
			{ LUTL, 'NoBaseAlert', { 'LocationType' }},
            { LUTL, 'BaseInLandMode', { 'LocationType' }},
			{ LUTL, 'LandStrengthRatioGreaterThan', { 0.7 } },
			-- enemy mass points within 16km
			{ LUTL, 'GreaterThanEnemyUnitsAroundBase', { 'LocationType', 0, categories.ECONOMIC, 800 }},
        },
		
        BuilderData = {
		
			DistressRange = 100,
			DistressTypes = 'Land',
			DistressThreshold = 5,
			
			PointType = 'Unit',
			PointCategory = categories.ECONOMIC,
			PointSourceSelf = true,
			PointFaction = 'Enemy',
			PointRadius = 800,
			PointSort = 'Closest',
			PointMin = 100,
			PointMax = 1000,
			
			StrCategory = DEFENSESTRUCTURE,
			StrRadius = 50,
			StrTrigger = true,
			StrMin = 0,
			StrMax = 10,
            
            ThreatMaxRatio = 1.5,
			
			UntCategory = LANDDIRECTFIRE + LANDARTILLERY,
			UntRadius = 60,
			UntTrigger = true,
			UntMin = 0,
			UntMax = 22,
			
            PrioritizedCategories = { 'ECONOMIC','DIRECTFIRE','LAND MOBILE','ENGINEER'},
			
			GuardRadius = 50,
			GuardTimer = 5,
			
			MergeLimit = 60,
			
			AggressiveMove = true,
			
			AllowInWater = false,
			
			UseFormation = 'AttackFormation',
        },
    },
    
	-- Small Version of Mex Attack Land Need Mass, this is more for "Early Raiding"
	-- another MASSEXTRACTION attack but smaller
    -- formed when team does not have it's mass share
    -- attacks MASSPRODUCTION positions within 15 km
	Builder {BuilderName = 'MEX Attack Small Land Need Mass',
	
        PlatoonTemplate = 'T1MassAttack',
		PlatoonAddFunctions = { {BHVR, 'AirLandToggle'}, {BHVR, 'BroadcastPlatoonPlan'}, {BHVR, 'RetreatAI'} },
		
		PlatoonAddPlans = { 'PlatoonCallForHelpAI','DistressResponseAI' },
		
        Priority = 800,
		
		PriorityFunction = function(self, aiBrain, manager)
        
            -- remove it entirely
            if GetGameTimeSeconds() > 900 then
                return 0, false
            end

            if PlatoonCategoryCountAroundPosition( aiBrain.ArmyPool, LANDDIRECTFIRE, manager.Location, manager.Radius ) < 5 then
                return 10,true
            else
                return 800,true
            end

        end,

        InstanceCount = 2,
		
        BuilderType = 'Any',
		
        BuilderConditions = {
			{ LUTL, 'NeedTeamMassPointShare', {}},
			{ LUTL, 'NoBaseAlert', { 'LocationType' }},
            { LUTL, 'BaseInLandMode', { 'LocationType' }},
			{ TBC, 'ThreatFurtherThan', { 'LocationType', 200, 'Land', 300 }},            

			-- enemy mass points within 12km
			{ LUTL, 'GreaterThanEnemyUnitsAroundBase', { 'LocationType', 0, categories.MASSPRODUCTION, 650 }},
        },
		
        BuilderData = {
		
			DistressRange = 100,
			DistressTypes = 'Land',
			DistressThreshold = 3,
			
			PointType = 'Unit',
			PointCategory = categories.MASSPRODUCTION,
			PointSourceSelf = true,
			PointFaction = 'Enemy',
			PointRadius = 650,
			PointSort = 'Closest',
			PointMin = 100,
			PointMax = 650,
			
			StrCategory = DEFENSESTRUCTURE,
			StrRadius = 38,
			StrTrigger = true,
			StrMin = 0,
			StrMax = 5,
            
            ThreatMaxRatio = 1.1,
			
			UntCategory = LANDDIRECTFIRE + LANDARTILLERY,
			UntRadius = 48,
			UntTrigger = true,
			UntMin = 0,
			UntMax = 12,
			
            PrioritizedCategories = { 'MASSPRODUCTION','ECONOMIC','ENGINEER'},
			
			GuardRadius = 60,
			GuardTimer = 15,
			
			MergeLimit = 25,
			
			AggressiveMove = true,
			
			AllowInWater = false,
			
			UseFormation = 'AttackFormation',
        },
    },

	-- PD Attack Former -- 
	-- This Platoon are the counter part to AA Attack Former
	-- This Platoon hunts for Defenses and Shields 


	-- attack enemy DEFENSE STRUCTURES with small groups
    -- forms when odds are modest(>0.7) 
    Builder {BuilderName = 'PD Attack Land',
	
        PlatoonTemplate = 'T1ArtilleryAttack',
        
		PlatoonAddFunctions = { {BHVR, 'AirLandToggle'}, {BHVR, 'BroadcastPlatoonPlan'}, {BHVR, 'RetreatAI'} },
		
		PlatoonAddPlans = { 'PlatoonCallForHelpAI' },
		
        Priority = 800,
		
		PriorityFunction = function(self, aiBrain, manager)
            
            if IsPrimaryBase(self,aiBrain,manager) == 800 then

                if PlatoonCategoryCountAroundPosition( aiBrain.ArmyPool, LANDARTILLERY, manager.Location, manager.Radius ) < 12 then
                    return 10,true
                else
                    return 800,true
                end

            else
                return 10, true
            end

        end,

        InstanceCount = 4,
		
        BuilderType = 'Any',
		
        BuilderConditions = {
			{ LUTL, 'NoBaseAlert', { 'LocationType' }},
            { LUTL, 'BaseInLandMode', { 'LocationType' }},
			{ LUTL, 'LandStrengthRatioGreaterThan', { 0.7 } },
			{ TBC, 'ThreatFurtherThan', { 'LocationType', 200, 'Land', 300 }},            

			-- enemy DEFENSE structures within 15km
			{ LUTL, 'GreaterThanEnemyUnitsAroundBase', { 'LocationType', 0, categories.DEFENSE * categories.STRUCTURE * categories.DIRECTFIRE, 1750 }},
        },
		
        BuilderData = {
			PointType = 'Unit',
			PointCategory = categories.DEFENSE * categories.STRUCTURE,
			PointSourceSelf = true,
			PointFaction = 'Enemy',
			PointRadius = 1750,
			PointSort = 'Closest',
			PointMin = 100,
			PointMax = 1750,
			
			StrCategory = DEFENSESTRUCTURE,
			StrRadius = 50,
			StrTrigger = true,
			StrMin = 0,
			StrMax = 4,
            
            ThreatMaxRatio = 1.5,
			
			UntCategory = LANDDIRECTFIRE + LANDARTILLERY,
			UntRadius = 60,
			UntTrigger = true,
			UntMin = 0,
			UntMax = 6,
			
            PrioritizedCategories = {'SHIELD STRUCTURE', 'DEFENSE STRUCTURE DIRECTFIRE', 'ANTIAIR STRUCTURE', 'ECONOMIC', 'ENGINEER', 'STRUCTURE -WALL', 'LAND MOBILE'},
			
			GuardRadius = 80,
			GuardTimer = 20,
			
			MergeLimit = 32,
			
			AggressiveMove = true,
			
			AllowInWater = false,
			
			UseFormation = 'AttackFormation',
        },
	},
}

BuilderGroup {BuilderGroupName = 'Land Formations - Water Map',
    BuildersType = 'PlatoonFormBuilder',
	
	-- this is the water map Land Attack used for venting
	-- available at ALL types of bases
    Builder {BuilderName = 'T3 Land Attack - Water Map',
	
        PlatoonTemplate = 'T3LandAttack',
        
		PlatoonAddFunctions = { {BHVR, 'AirLandToggle'}, {BHVR, 'BroadcastPlatoonPlan'} },
		
		PlatoonAddPlans = { 'PlatoonCallForHelpAI','DistressResponseAI' },
		
        Priority = 802,
		
		PriorityFunction = function(self, aiBrain, manager)

            if PlatoonCategoryCountAroundPosition( aiBrain.ArmyPool, LANDDIRECTFIRE, manager.Location, manager.Radius ) < 45 then
                return 10,true
            elseif PlatoonCategoryCountAroundPosition( aiBrain.ArmyPool, LANDARTILLERY, manager.Location, manager.Radius ) < 15 then
                return 10,true
            else
                return 802,true
            end

        end,
	
		RTBLocation = 'Any',
		
        InstanceCount = 1,
		
        BuilderType = 'Any',
		
        BuilderConditions = {},
		
        BuilderData = {
			MergeLimit = 90,
			
            PrioritizedCategories = { 'LAND MOBILE','ENGINEER','SHIELD','STRUCTURE -WALL'},
			
			UseFormation = 'AttackFormation',
			
            AggressiveMove = true,
            
            MaxAttackRange = 900,
        },
    },

    Builder {BuilderName = 'T2 Land Attack - Water Map',
	
        PlatoonTemplate = 'T2LandAttack',
        
		PlatoonAddFunctions = { {BHVR, 'AirLandToggle'}, {BHVR, 'BroadcastPlatoonPlan'}, {BHVR, 'RetreatAI'} },
		
		PlatoonAddPlans = { 'PlatoonCallForHelpAI','DistressResponseAI' },
        
        PlatoonAIPlan = 'LandForceAILOUD',

        Priority = 801,
		
		PriorityFunction = function(self, aiBrain, manager)

            if PlatoonCategoryCountAroundPosition( aiBrain.ArmyPool, LANDDIRECTFIRE - LANDAMPHIB, manager.Location, manager.Radius ) < 24 then
                return 10,true
            else
                return 802,true
            end

        end,

		RTBLocation = 'Any',
		
        InstanceCount = 2,
		
        BuilderType = 'Any',
		
        BuilderConditions = {
			{ LUTL, 'NoBaseAlert', { 'LocationType' }},
        },
		
        BuilderData = {
			MergeLimit = 60,
			
            PrioritizedCategories = { 'LAND MOBILE','ENGINEER','SHIELD','STRUCTURE -WALL'},
			
			UseFormation = 'AttackFormation',
			
            AggressiveMove = true,
            
            MaxAttackRange = 650,
        },
    },
    
    Builder {BuilderName = 'T1 Land Attack - Water Map',
	
        PlatoonTemplate = 'T1LandAttack',
        
		PlatoonAddFunctions = { {BHVR, 'AirLandToggle'}, {BHVR, 'BroadcastPlatoonPlan'}, {BHVR, 'RetreatAI'} },
		
		PlatoonAddPlans = { 'PlatoonCallForHelpAI','DistressResponseAI', },
        
        PlatoonAIPlan = 'LandForceAILOUD',
        
        Priority = 800,
		
		PriorityFunction = function(self, aiBrain, manager)
        
            -- remove it entirely
            if GetGameTimeSeconds() > 900 then
                return 0, false
            end

            if PlatoonCategoryCountAroundPosition( aiBrain.ArmyPool, LANDDIRECTFIRE - LANDAMPHIB, manager.Location, manager.Radius ) < 5 then
                return 10,true
            else
                return 800,true
            end

        end,

		RTBLocation = 'Any',
		
        InstanceCount = 2,
		
        BuilderType = 'Any',
		
        BuilderConditions = {
			{ LUTL, 'NoBaseAlert', { 'LocationType' }},
        },
		
        BuilderData = {
			MergeLimit = 30,
			
            PrioritizedCategories = { 'LAND MOBILE','ENGINEER','SHIELD','STRUCTURE -WALL'},
			
			UseFormation = 'AttackFormation',
			
            AggressiveMove = true,
            
            MaxAttackRange = 400,
        },
    },

	-- attack enemy mass points when team needs mass point share
    Builder {BuilderName = 'MEX Attack Large Need Mass',
	
        PlatoonTemplate = 'T3MassAttack',
        
		PlatoonAddFunctions = { {BHVR, 'AirLandToggle'}, {BHVR, 'BroadcastPlatoonPlan'}, {BHVR, 'RetreatAI'} },
		
		PlatoonAddPlans = { 'PlatoonCallForHelpAI','DistressResponseAI' },
		
        Priority = 802,
		
		PriorityFunction = function(self, aiBrain, manager)
            
            if IsPrimaryBase(self,aiBrain,manager) == 802 then

                if PlatoonCategoryCountAroundPosition( aiBrain.ArmyPool, LANDDIRECTFIRE, manager.Location, manager.Radius ) < 45 then
                    return 10,true
                elseif PlatoonCategoryCountAroundPosition( aiBrain.ArmyPool, LANDARTILLERY, manager.Location, manager.Radius ) < 12 then
                    return 10,true
                else
                    return 802,true
                end
                
            else
                return 10, true
            end

        end,

        InstanceCount = 2,
		
        BuilderType = 'Any',
		
        BuilderConditions = {
            { LUTL, 'UnitCapCheckLess', { .95 } },
			{ LUTL, 'NeedTeamMassPointShare', {}},
			{ LUTL, 'NoBaseAlert', { 'LocationType' }},
			{ LUTL, 'LandStrengthRatioGreaterThan', { 0.7 } },

			-- enemy mass points within 15km
			{ LUTL, 'GreaterThanEnemyUnitsAroundBase', { 'LocationType', 0, categories.MASSPRODUCTION, 1250 }},
        },
		
        BuilderData = {
			PointType = 'Unit',
			PointCategory = 'ECONOMIC',
			PointSourceSelf = true,
			PointFaction = 'Enemy',
			PointRadius = 1250,
			PointSort = 'Closest',
			PointMin = 100,
			PointMax = 1250,
			
			StrCategory = DEFENSESTRUCTURE,
			StrRadius = 60,
			StrTrigger = true,
			StrMin = 0,
			StrMax = 10,
            
            ThreatMaxRatio = 1.1,
			
			UntCategory = LANDDIRECTFIRE + LANDARTILLERY,
			UntRadius = 64,
			UntTrigger = true,
			UntMin = 0,
			UntMax = 36,
			
            PrioritizedCategories = { 'ENGINEER','MASSPRODUCTION','FACTORY','SHIELD','ECONOMIC','DEFENSE STRUCTURE'},
			
			GuardRadius = 80,
			GuardTimer = 60,
			
			MergeLimit = 75,
			
			AggressiveMove = true,
			
			AllowInWater = false,
			
			UseFormation = 'AttackFormation',
        },
    },

	-- goes after enemy mass extractors
    Builder {BuilderName = 'MEX Attack Water',
	
        PlatoonTemplate = 'T1MassAttack',
        
		PlatoonAddFunctions = { {BHVR, 'AirLandToggle'}, {BHVR, 'BroadcastPlatoonPlan'}, {BHVR, 'RetreatAI'} },
		
		PlatoonAddPlans = { 'PlatoonCallForHelpAI','DistressResponseAI' },
		
        Priority = 801,
		
		PriorityFunction = function(self, aiBrain, manager)

            if PlatoonCategoryCountAroundPosition( aiBrain.ArmyPool, LANDDIRECTFIRE, manager.Location, manager.Radius ) < 5 then
                return 10,true
            else
                return 801,true
            end
        end,
		
        InstanceCount = 2,
		
        BuilderType = 'Any',
		
        BuilderConditions = {
			{ LUTL, 'NoBaseAlert', { 'LocationType' }},
			{ LUTL, 'BaseInAmphibiousMode', { 'LocationType' }},
            
			-- enemy mass production within 15km
			{ LUTL, 'GreaterThanEnemyUnitsAroundBase', { 'LocationType', 0, categories.MASSPRODUCTION, 1250 }},
        },
		
        BuilderData = {
			DistressRange = 160,
			DistressTypes = 'Land',
			DistressThreshold = 4,

			PointType = 'Unit',
			PointCategory = 'ECONOMIC',
			PointSourceSelf = true,
			PointFaction = 'Enemy',
			PointRadius = 1250,
			PointSort = 'Closest',
			PointMin = 100,
			PointMax = 1250,
			
			StrCategory = DEFENSESTRUCTURE,
			StrRadius = 60,
			StrTrigger = true,
			StrMin = 0,
			StrMax = 3,
            
            ThreatMaxRatio = 1.1,
			
			UntCategory = LANDDIRECTFIRE + LANDARTILLERY,
			UntRadius = 70,
			UntTrigger = true,
			UntMin = 0,
			UntMax = 10,
			
            PrioritizedCategories = { 'MASSPRODUCTION','ENGINEER','ECONOMIC','FACTORY','SHIELD','DEFENSE STRUCTURE'},
			
			GuardRadius = 80,
			GuardTimer = 60,
			
			MergeLimit = 36,
			
			AggressiveMove = true,
			
			AllowInWater = false,
			
			UseFormation = 'AttackFormation',
        },
	},


}

BuilderGroup {BuilderGroupName = 'Land Formations - Experimentals',
    BuildersType = 'PlatoonFormBuilder',
	
    -- Basically a balls to the wall experimental venting attack
    -- will take whatever loose units around the base it can
    -- focused upon engaging units first
	Builder {BuilderName = 'Exp Group - Forced',
	
        PlatoonTemplate = 'T4ExperimentalGroup',
		
        PlatoonAddBehaviors = {'BroadcastPlatoonPlan' },
		
		PlatoonAddPlans = { 'PlatoonCallForHelpAI' },
		
        Priority = 802,
		
		-- this function alters the builder 
		PriorityFunction = function(self, aiBrain, manager)

            if PlatoonCategoryCountAroundPosition( aiBrain.ArmyPool, (categories.LAND * categories.MOBILE * categories.EXPERIMENTAL) - categories.url0401 - categories.INSIGNIFICANTUNIT, manager.Location, manager.Radius ) < 11 then
                return 10,true
            end

			if aiBrain.BuilderManagers[manager.LocationType].PrimaryLandAttackBase or aiBrain.BuilderManagers[manager.LocationType].PrimarySeaAttackBase then
			
				if aiBrain.AttackPlan.Method != 'Amphibious' then
					return 802, true
				end
			end
			
			return 10, true
		end,
		
        InstanceCount = 3,
		
        BuilderType = 'Any',
		
		BuilderConditions = {},
		
        BuilderData = {

            PrioritizedCategories = { 'LAND MOBILE','SHIELD','STRUCTURE -WALL','ENGINEER'},		-- controls target selection
			
			MaxAttackRange = 1500,
			
			MergeLimit = 120,
			
			AggressiveMove = true,
			
			UseFormation = 'AttackFormation',
			
        },
    },	
	
	Builder {BuilderName = 'Exp Group Amphibious - Forced',
	
        PlatoonTemplate = 'T4ExperimentalGroupAmphibious',
		
        PlatoonAddBehaviors = {'BroadcastPlatoonPlan' },
		
		PlatoonAddPlans = { 'PlatoonCallForHelpAI' },
		
        Priority = 802,
		
		PriorityFunction = function(self, aiBrain, manager)

            if PlatoonCategoryCountAroundPosition( aiBrain.ArmyPool, (categories.LAND * categories.MOBILE * categories.EXPERIMENTAL) - categories.url0401 - categories.INSIGNIFICANTUNIT, manager.Location, manager.Radius ) < 11 then
                return 10,true
            end
		
			-- effectively - if this is a primary base - and the attack plan requires amphibious attack --			
			if aiBrain.BuilderManagers[manager.LocationType].PrimaryLandAttackBase or aiBrain.BuilderManagers[manager.LocationType].PrimarySeaAttackBase then
			
				if aiBrain.AttackPlan.Method == 'Amphibious' then
					return 802, true
				end
			end
			
            if ScenarioInfo.MapWaterRatio > 0 then
                return 10, true
            else
                return 0, false
            end
		end,
		
        InstanceCount = 3,
		
        BuilderType = 'Any',
		
		BuilderConditions = {},
		
        BuilderData = {

            PrioritizedCategories = { 'ECONOMIC','SHIELD','STRUCTURE -WALL','LAND MOBILE','ENGINEER'},		-- controls target selection
			
			MaxAttackRange = 2500,
			
			MergeLimit = 120,
			
			AggressiveMove = true,
			
			UseFormation = 'AttackFormation',
			
        },
    },	
	
	Builder {BuilderName = 'Exp Group Amphibious',
	
        PlatoonTemplate = 'T4ExperimentalGroupAmphibious',
		
        PlatoonAddBehaviors = {'BroadcastPlatoonPlan' },
		
		PlatoonAddPlans = { 'PlatoonCallForHelpAI', 'DistressResponseAI' },
		
        Priority = 800,
		
		PriorityFunction = function(self, aiBrain, manager)
        
            if ScenarioInfo.MapWaterRatio == 0 then
                return 0, false
            end

            if PlatoonCategoryCountAroundPosition( aiBrain.ArmyPool, (categories.LAND * categories.MOBILE * categories.EXPERIMENTAL) - categories.url0401 - categories.INSIGNIFICANTUNIT, manager.Location, manager.Radius ) < 7 then
                return 10, true
            end
			
			-- effectively - if this is a primary base - and the attack plan requires amphbious attack --
			if aiBrain.BuilderManagers[manager.LocationType].PrimaryLandAttackBase or aiBrain.BuilderManagers[manager.LocationType].PrimarySeaAttackBase then
			
				if aiBrain.AttackPlan.Method == 'Amphibious' then
					return 800, true
				end
			end

            return 10, true
		end,
		
        InstanceCount = 2,
		
        BuilderType = 'Any',
		
		BuilderConditions = {
			{ LUTL, 'LandStrengthRatioGreaterThan', { 0.8 } },
		},
		
        BuilderData = {
		
			DistressRange = 120,
			DistressTypes = 'Land',
			DistressThreshold = 10,
			
            PrioritizedCategories = { 'SHIELD','STRUCTURE -WALL','LAND MOBILE','ENGINEER'},		-- controls target selection
			
			MaxAttackRange = 1500,
			
			MergeLimit = 120,
			
			AggressiveMove = true,
			
            UseFormation = 'AttackFormation',
        },
    },

	Builder {BuilderName = 'Exp Group',
	
        PlatoonTemplate = 'T4ExperimentalGroup',
		
        PlatoonAddBehaviors = {'BroadcastPlatoonPlan' },
		
		PlatoonAddPlans = { 'PlatoonCallForHelpAI', 'DistressResponseAI' },
		
        Priority = 800,
		
		PriorityFunction = function(self, aiBrain, manager)

            if PlatoonCategoryCountAroundPosition( aiBrain.ArmyPool, (LAND * categories.EXPERIMENTAL) - categories.url0401 - categories.INSIGNIFICANTUNIT, manager.Location, manager.Radius ) < 7 then
                return 10,true
            elseif PlatoonCategoryCountAroundPosition( aiBrain.ArmyPool, LANDDIRECTFIRE, manager.Location, manager.Radius ) < 13 then
                return 10,true
            elseif PlatoonCategoryCountAroundPosition( aiBrain.ArmyPool, LANDARTILLERY, manager.Location, manager.Radius ) < 6 then
                return 10,true
            end
			
			if aiBrain.BuilderManagers[manager.LocationType].PrimaryLandAttackBase or aiBrain.BuilderManagers[manager.LocationType].PrimarySeaAttackBase then
			
				if aiBrain.AttackPlan.Method != 'Amphibious' then
					return 800, true
				end
			end
			
			return 10, true
		end,
		
        InstanceCount = 2,
		
        BuilderType = 'Any',
		
		BuilderConditions = {
			{ LUTL, 'LandStrengthRatioGreaterThan', { 0.8 } },
		},
		
        BuilderData = {
			DistressRange = 120,
			DistressTypes = 'Land',
			DistressThreshold = 10,
			
            PrioritizedCategories = { 'SHIELD','STRUCTURE -WALL','LAND MOBILE','ENGINEER'},		-- controls target selection
			
			MaxAttackRange = 1500,
			
			MergeLimit = 120,
			
			AggressiveMove = true,
			
			UseFormation = 'AttackFormation',
        },
    },

	Builder {BuilderName = 'Reinforce Primary - Land Experimental',
	
		PlatoonTemplate = 'ReinforceLandExperimental',

        PlatoonAddBehaviors = {'BroadcastPlatoonPlan' },

		PlatoonAddPlans = { 'PlatoonCallForHelpAI' },

		PlatoonAIPlan = 'ReinforceAmphibAI',

        Priority = 10,

		-- this function turns on the builder 
		PriorityFunction = function(self, aiBrain, manager)
            
            if PlatoonCategoryCountAroundPosition( aiBrain.ArmyPool, LAND * categories.EXPERIMENTAL, manager.Location, manager.Radius ) < 1 then
                return 10,true
            end

            return NotPrimaryBase(self,aiBrain,manager), true
		end,

        InstanceCount = 2,

        BuilderType = 'Any',

        BuilderConditions = {},

        BuilderData = {
            UseFormation = 'GrowthFormation',
        },
    },

}


-- On Water Maps the Amphib formations will carry most of the big combat load
BuilderGroup {BuilderGroupName = 'Land Formations - Amphibious',
    BuildersType = 'PlatoonFormBuilder',
	
	-- this is the VENTING attack for amphibious maps
    Builder {BuilderName = 'Amphib Attk - Unit Forced',
	
        PlatoonTemplate = 'AmphibAttackHuge',

		PlatoonAddFunctions = { {BHVR, 'BroadcastPlatoonPlan'} },
		
		PlatoonAddPlans = { 'PlatoonCallForHelpAI' },
		
        Priority = 803,
		
		PriorityFunction = function(self, aiBrain, manager)
            
            if IsPrimaryBase(self,aiBrain,manager) == 803 then

                if PlatoonCategoryCountAroundPosition( aiBrain.ArmyPool, LANDAMPHIB - categories.SCOUT, manager.Location, manager.Radius ) < 48 then
                    return 10,true
                else
                    return 803,true
                end
                
            else
                return 10, true
            end

        end,

		RTBLocation = 'Any',
		
        InstanceCount = 3,
		
        BuilderType = 'Any',
		
		BuilderConditions = {},
		
        BuilderData = {
        
            PrioritizedCategories = { 'ENGINEER','ECONOMY','LAND MOBILE','SHIELD','NAVAL MOBILE','STRUCTURE -WALL'},		-- controls target selection
			
			MaxAttackRange = 2000,
			
			MergeLimit = 100,
			
			AggressiveMove = false,
			
			UseFormation = 'AttackFormation',
        },
    },
	
	-- large attack at 30 km
    Builder {BuilderName = 'Amphib Attk Large',
	
        PlatoonTemplate = 'T3AmphibAttack',
        
		PlatoonAddFunctions = { {BHVR, 'BroadcastPlatoonPlan'} },
		
        Priority = 802,
		
		PriorityFunction = function(self, aiBrain, manager)
            
            if IsPrimaryBase(self,aiBrain,manager) == 802 then

                if PlatoonCategoryCountAroundPosition( aiBrain.ArmyPool, LANDAMPHIB - categories.SCOUT, manager.Location, manager.Radius ) < 36 then
                    return 10,true
                else
                    return 802,true
                end
                
            else
                return 10, true
            end

        end,

		RTBLocation = 'Any',
		
        InstanceCount = 3,
		
        BuilderType = 'Any',
		
		BuilderConditions = {
			{ LUTL, 'LandStrengthRatioGreaterThan', { 0.7 } },
        },
		
        BuilderData = {
		
            PrioritizedCategories = { 'FACTORY','STRUCTURE -WALL','ECONOMIC','DEFENSE','SHIELD','ENGINEER'},
			
			MaxAttackRange = 1500,
			
			MergeLimit = 80,
			
			AggressiveMove = true,
			
			UseFormation = 'AttackFormation',
        },
    },
    
	-- general attack at 24km 
    Builder {BuilderName = 'Amphib Attk',
	
        PlatoonTemplate = 'T2AmphibAttack',
        
		PlatoonAddFunctions = { {BHVR, 'BroadcastPlatoonPlan'}, {BHVR, 'RetreatAI'} },
		
        Priority = 801,
		
		PriorityFunction = function(self, aiBrain, manager)
            
            if IsPrimaryBase(self,aiBrain,manager) == 801 then

                if PlatoonCategoryCountAroundPosition( aiBrain.ArmyPool, LANDAMPHIB - categories.SCOUT, manager.Location, manager.Radius ) < 24 then
                    return 10,true
                else
                    return 801,true
                end
                
            else
                return 10, true
            end

        end,

		RTBLocation = 'Any',		
		
        InstanceCount = 3,
		
        BuilderType = 'Any',
		
        BuilderConditions = {
			{ LUTL, 'LandStrengthRatioGreaterThan', { 0.8 } },
		},
		
        BuilderData = {
		
            PrioritizedCategories = { 'FACTORY','STRUCTURE -WALL','ECONOMIC','DEFENSE','SHIELD','ENGINEER'},
			
			MaxAttackRange = 1200,
			
			MergeLimit = 65,
			
			AggressiveMove = false,
			
			UseFormation = 'AttackFormation',
        },
    },

	-- attack extractors within 16km 
    Builder {BuilderName = 'Amphib MEX Attack',
	
        PlatoonTemplate = 'T1AmphibAttack',
        
		PlatoonAddFunctions = { {BHVR, 'AirLandToggle'}, {BHVR, 'BroadcastPlatoonPlan'}, {BHVR, 'RetreatAI'} },
		
		PlatoonAddPlans = { 'PlatoonCallForHelpAI','DistressResponseAI' },
		
        Priority = 800,
		
		PriorityFunction = function(self, aiBrain, manager)
            
            if IsPrimaryBase(self,aiBrain,manager) == 800 then

                if PlatoonCategoryCountAroundPosition( aiBrain.ArmyPool, LANDAMPHIB - categories.SCOUT, manager.Location, manager.Radius ) < 16 then
                    return 10,true
                else
                    return 800,true
                end
                
            else
                return 10, true
            end

        end,

		RTBLocation = 'Any',
		
        InstanceCount = 4,
		
        BuilderType = 'Any',
		
        BuilderConditions = {
			{ LUTL, 'NoBaseAlert', { 'LocationType' }},
			{ LUTL, 'LandStrengthRatioGreaterThan', { 0.9 } },
        },
		
        BuilderData = {
			DistressRange = 120,
			DistressTypes = 'Land',
			DistressThreshold = 5,
			
			PointType = 'Unit',
			PointCategory = 'ECONOMIC',
			PointSourceSelf = true,
			PointFaction = 'Enemy',
			PointRadius = 800,
			PointSort = 'Closest',
			PointMin = 100,
			PointMax = 800,
			
			StrCategory = DEFENSESTRUCTURE,
			StrRadius = 50,
			StrTrigger = true,
			StrMin = 0,
			StrMax = 8,
			
			UntCategory = LANDDIRECTFIRE + LANDARTILLERY,
			UntRadius = 60,
			UntTrigger = true,
			UntMin = 0,
			UntMax = 12,
			
            PrioritizedCategories = { 'ECONOMIC','FACTORY','SHIELD','DEFENSE STRUCTURE','ENGINEER'},
			
			GuardRadius = 80,
			GuardTimer = 25,
			
			MergeLimit = 48,
			
			AggressiveMove = true,
			
			AllowInWater = false,
			
			UseFormation = 'AttackFormation',
        },
	},

	-- attack extractors within 8km 
    Builder {BuilderName = 'Amphib MEX Raid',
	
        PlatoonTemplate = 'T1AmphibMassGuard',
        
		PlatoonAddFunctions = { {BHVR, 'AirLandToggle'}, {BHVR, 'BroadcastPlatoonPlan'}, {BHVR, 'RetreatAI'} },
		
		PlatoonAddPlans = { 'PlatoonCallForHelpAI','DistressResponseAI' },

        PlatoonAIPlan = 'AmphibForceAILOUD',		

        Priority = 800,
		
		PriorityFunction = function(self, aiBrain, manager)
            
            if IsPrimaryBase(self,aiBrain,manager) == 800 then

                if PlatoonCategoryCountAroundPosition( aiBrain.ArmyPool, LANDAMPHIB - categories.SCOUT, manager.Location, manager.Radius ) < 3 then
                    return 10,true
                else
                    return 800,true
                end
                
            else
                return 10, true
            end

        end,

		RTBLocation = 'Any',
		
        InstanceCount = 2,
		
        BuilderType = 'Any',
		
        BuilderConditions = {
			{ LUTL, 'NoBaseAlert', { 'LocationType' }},
			{ LUTL, 'LandStrengthRatioGreaterThan', { 0.9 } },
        },
		
        BuilderData = {
			DistressRange = 80,
			DistressTypes = 'Land',
			DistressThreshold = 5,
			
			PointType = 'Unit',
			PointCategory = 'ECONOMIC',
			PointSourceSelf = true,
			PointFaction = 'Enemy',
			PointRadius = 400,
			PointSort = 'Closest',
			PointMin = 80,
			PointMax = 400,
			
			StrCategory = DEFENSESTRUCTURE,
			StrRadius = 50,
			StrTrigger = true,
			StrMin = 0,
			StrMax = 2,
			
			UntCategory = LANDDIRECTFIRE + LANDARTILLERY,
			UntRadius = 60,
			UntTrigger = true,
			UntMin = 0,
			UntMax = 3,
			
            PrioritizedCategories = { 'ENGINEER','ECONOMIC','FACTORY','SHIELD','DEFENSE STRUCTURE'},
			
			GuardRadius = 80,
			GuardTimer = 15,
			
			MergeLimit = 10,
            
            MissionTime = 480,  -- operate for about 8 minutes
			
			AggressiveMove = true,
			
			AllowInWater = false,
			
			UseFormation = 'LOUDClusterFormation',			
        },
	},

	-- Platoon designed to go to empty mass points within 15km and stay there until an extractor is built
	-- runs until AI team has its share of mass points
    Builder {BuilderName = 'Amphib Mass Point Guard',
	
        PlatoonTemplate = 'T1AmphibMassGuard',
        
		PlatoonAddFunctions = { {BHVR, 'AirLandToggle'}, {BHVR, 'BroadcastPlatoonPlan'}, {BHVR, 'RetreatAI'} },
		
		PlatoonAddPlans = { 'PlatoonCallForHelpAI','DistressResponseAI' },
        
        PlatoonAIPlan = 'GuardPointAmphibious',
        
        Priority = 802,
		
		PriorityFunction = function(self, aiBrain, manager)

            if PlatoonCategoryCountAroundPosition( aiBrain.ArmyPool, LANDAMPHIB - categories.SCOUT - categories.EXPERIMENTAL, manager.Location, manager.Radius ) < 3 then
                return 10,true
            else
                return 802,true
            end

        end,
		
		RTBLocation = 'Any',
		
        InstanceCount = 3,
		
        BuilderType = 'Any',
		
        BuilderConditions = {
            { LUTL, 'UnitCapCheckLess', { .85 } },
			{ LUTL, 'NeedTeamMassPointShare', {}},
			{ LUTL, 'NoBaseAlert', { 'LocationType' }},
            { LUTL, 'LandStrengthRatioLessThan', { 2 } },
            
			{ TBC, 'ThreatFurtherThan', { 'LocationType', 175, 'Land', 200 }},                        

			-- empty mass point within 20km with less than 75 threat 
			{ EBC, 'CanBuildOnMassAtRange', { 'LocationType', 120, 1000, 0, 75, 1, 'AntiSurface', 1 }},
        },
		
        BuilderData = {
			DistressRange = 125,
            DistressReactionTime = 20,
			DistressTypes = 'Land',
			DistressThreshold = 2,
			
			PointType = 'Marker',			-- either Unit or Marker
			PointCategory = 'Mass',
			PointSourceSelf = true,			-- true AI will use its base as source, false will use current Enemy Main Base location
			PointFaction = 'Ally',	 		-- must be Self, Ally or Enemy - determines which Structures and Units to check
			PointRadius = 1000,		    	-- controls the finding of points based upon distance from PointSource
			PointSort = 'MostThreat',		-- options are Closest or Furthest or MostThreat
			PointMin = 100,					-- filter points by range from PointSource
			PointMax = 1000,
			
			StrCategory = categories.MASSEXTRACTION,		-- filter points based upon presence of units/strucutres at point
			StrRadius = 5,
			StrTrigger = true,				-- structure parameters trigger end to guardtimer
			StrMin = 0,
			StrMax = 0,
            
            ThreatMin = 0,
            ThreatMaxRatio = 0.8,
            ThreatRings = 1,
			
			UntCategory = LANDDIRECTFIRE + LANDARTILLERY,
			UntRadius = 45,
			UntTrigger = true,
			UntMin = 0,
			UntMax = 8,
			
            AssistRange = 3,
			
            PrioritizedCategories = {'LAND','STRUCTURE','ENGINEER'},
			
			GuardRadius = 65,				-- range at which platoon will engage targets
			GuardTimer = 240,				-- period that platoon will guard the point unless triggers are met
			
			MissionTime = 960,				-- platoon will operate 16 minutes then RTB
			
			MergeLimit = 16,				-- level to which merging is allowed
			
			AggressiveMove = true,
			
			AllowInWater = true,            -- this formation is allowed to guard positions in the water
			
			AvoidBases = true,
			
			UseFormation = 'LOUDClusterFormation',
        },
    },

	Builder {BuilderName = 'Reinforce Primary - Amphibious',
	
        PlatoonTemplate = 'ReinforceAmphibiousPlatoon',
        
		PlatoonAddFunctions = { {BHVR, 'AirLandToggle'}, {BHVR, 'BroadcastPlatoonPlan'}, {BHVR, 'RetreatAI'} },
        
        PlatoonAIPlan = 'ReinforceAmphibAI',

        Priority = 10,

		PriorityFunction = function(self, aiBrain, manager)
            
            if PlatoonCategoryCountAroundPosition( aiBrain.ArmyPool, LANDAMPHIB - LANDSCOUT, manager.Location, manager.Radius ) < 7 then
                return 10,true
            end

            return NotPrimaryBase(self,aiBrain,manager), true
		end,
		
        InstanceCount = 4,
		
        BuilderType = 'Any',
		
        BuilderConditions = {
            { LUTL, 'NoBaseAlert', { 'LocationType' }},
			{ TBC, 'ThreatFurtherThan', { 'LocationType', 200, 'Land', 300 }},
        },
		
        BuilderData = {
            UseFormation = 'GrowthFormation',
        },  
    },    
}


-- Guard Markers/Structures --
-- these are mostly early platoons - designed to skirmish
-- focused on mass points, extractors, DPs and Expansions
-- these platoons usually stop once the AI has attained his share of mass point control
-- many of these platoons are suppressed on 5k and 10k maps thus promoting a more aggressive attack posture
BuilderGroup {BuilderGroupName = 'Land Formations - Point Guards',
    BuildersType = 'PlatoonFormBuilder',

	-- Platoon designed to go to empty mass points within 15km and stay there until an extractor is built
	-- runs until AI team has its share of mass points
    Builder {BuilderName = 'Mass Point Guard',
	
        PlatoonTemplate = 'T1MassGuard',
        
		PlatoonAddFunctions = { {BHVR, 'AirLandToggle'}, {BHVR, 'BroadcastPlatoonPlan'}, {BHVR, 'RetreatAI'} },
		
		PlatoonAddPlans = { 'PlatoonCallForHelpAI','DistressResponseAI' },
        
        PlatoonAIPlan = 'GuardPoint',
        
        Priority = 802,
		
		PriorityFunction = function(self, aiBrain, manager)

            if PlatoonCategoryCountAroundPosition( aiBrain.ArmyPool, LANDDIRECTFIRE - LANDAMPHIB, manager.Location, manager.Radius ) < 1 then
                return 10,true
            else
                return 802,true
            end
        end,
		
		RTBLocation = 'Any',
		
        InstanceCount = 7,
		
        BuilderType = 'Any',
		
        BuilderConditions = {
            { LUTL, 'UnitCapCheckLess', { .85 } },
			{ LUTL, 'NoBaseAlert', { 'LocationType' }},
            { LUTL, 'LandStrengthRatioLessThan', { 2 } },

			-- empty mass point within 12km with less than 75 threat 
			{ EBC, 'CanBuildOnMassAtRange', { 'LocationType', 120, 600, 0, 75, 1, 'AntiSurface', 1 }},
        },
		
        BuilderData = {
			DistressRange = 120,
            DistressReactionTime = 16,
			DistressTypes = 'Land',
			DistressThreshold = 1,
			
			PointType = 'Marker',			-- either Unit or Marker
			PointCategory = 'Mass',
			PointSourceSelf = true,			-- true AI will use its base as source, false will use current Enemy Main Base location
			PointFaction = 'Ally',	 		-- must be Self, Ally or Enemy - determines which Structures and Units to check
			PointRadius = 1000,		    	-- controls the finding of points based upon distance from PointSource
			PointSort = 'Closest',			-- options are Closest or Furthest
			PointMin = 120,					-- filter points by range from PointSource
			PointMax = 1000,
			
			StrCategory = categories.MASSEXTRACTION,		-- filter points based upon presence of units/strucutres at point
			StrRadius = 5,
			StrTrigger = true,				-- structure parameters trigger end to guardtimer
			StrMin = 0,
			StrMax = 0,
            
            ThreatMin = 0,
            ThreatMaxRatio = 0.8,
            ThreatRings = 1,
			
			UntCategory = LANDDIRECTFIRE + LANDARTILLERY,
			UntRadius = 45,
			UntTrigger = true,				-- unit parameters trigger end to guardtimer
			UntMin = 0,
			UntMax = 10,

            UseMassPointList = true,        -- use the pre-generated mass point list if populated, ahead of using findpoint
            
            AssistRange = 3,
			
            PrioritizedCategories = {'LAND MOBILE','STRUCTURE -WALL','ENGINEER'},		-- target selection when at point --
			
			GuardRadius = 65,				-- range at which platoon will engage targets
			GuardTimer = 210,				-- period that platoon will guard the point unless triggers are met
			
			MissionTime = 960,				-- platoon will operate 16 minutes then RTB
			
			MergeLimit = 12,				-- level to which merging is allowed
			
			AggressiveMove = true,
			
			AllowInWater = false,
			
			AvoidBases = true,
			
			UseFormation = 'LOUDClusterFormation',
        },
    },
	
    -- this one guards existing extractors
    Builder {BuilderName = 'MEX Guard',
	
        PlatoonTemplate = 'T1MassGuard',
        
		PlatoonAddFunctions = { {BHVR, 'AirLandToggle'}, {BHVR, 'BroadcastPlatoonPlan'}, {BHVR, 'RetreatAI'} },
		
		PlatoonAddPlans = { 'DistressResponseAI','PlatoonCallForHelpAI' },

        PlatoonAIPlan = 'GuardPoint',
		
        Priority = 802,
		
		PriorityFunction = function(self, aiBrain, manager)

            if PlatoonCategoryCountAroundPosition( aiBrain.ArmyPool, LANDDIRECTFIRE - LANDAMPHIB, manager.Location, manager.Radius ) < 2 then
                return 10,true
            else
                return 802,true
            end

        end,

		RTBLocation = 'Any',
		
        InstanceCount = 7,

        BuilderType = 'Any',
		
        BuilderConditions = {
            { LUTL, 'UnitCapCheckLess', { .75 } },
			{ LUTL, 'NoBaseAlert', { 'LocationType' }},
            { LUTL, 'LandStrengthRatioLessThan', { 2 } },

			-- we have a mass extractor within 2-10km with less than 4 defense structures, and > 15 threat within 1 ring 
            { UCBC, 'MassExtractorInRangeHasLessThanDefense', { 'LocationType', 75, 650, 3, 15, 125, 1 }},
        },
		
        BuilderData = {
			DistressRange = 90,
            DistressReactionTime = 16,
			DistressTypes = 'Land',
			DistressThreshold = 1,
			
			PointType = 'Unit',					-- either Unit or Marker
			PointCategory = categories.MASSEXTRACTION + categories.HYDROCARBON,
			PointSourceSelf = false,			-- will use current Enemy Main Base location
			PointFaction = 'Ally',	 			-- must be either Ally or Enemy - determines which Structures and Units to check
			PointRadius = 999999,				-- finding of points based upon distance from PointSource
			PointSort = 'MostThreat',			-- options are Closest, Furthest or MostThreat
			PointMin = 75,						-- filter points by range from PointSource
			PointMax = 650,
			
			StrCategory = DEFENSESTRUCTURE,
			StrRadius = 50,
			StrTrigger = true,				    -- structure parameters trigger end to guardtimer
			StrMin = 0,
			StrMax = 3,
            
            ThreatMin = 15,                     -- pick points with at least this threat
            ThreatMaxRatio = 1,                 -- and no more than this (based on this platoons threat)
            ThreatRings = 1,                    -- at this range

			UntCategory = LANDDIRECTFIRE + LANDARTILLERY,
			UntRadius = 35,
			UntTrigger = true,				    -- unit parameters trigger end to guardtimer
			UntMin = 0,
			UntMax = 7,

            PrioritizedCategories = {'LAND MOBILE','STRUCTURE -WALL','ENGINEER'},
			
			AssistRange = 3,
			
			GuardRadius = 72,   				-- range at which platoon will engage targets
			GuardTimer = 150,   				-- platoon will guard 2.5 minutes
			
			MissionTime = 1080, 				-- platoon will operate 18 minutes
			
			MergeLimit = 12,    				-- unit count at which merging is denied
            MergePlanMatch = true,              -- only merge with other MEX Guard platoons
			
			AggressiveMove = true,
			
			AllowInWater = false,
			
			AvoidBases = true,                  -- this will avoid guarding any point within PointMin of an existing base
			
			UseFormation = 'BlockFormation',
        },
    },

	-- This platoon will go to the closest DP that has no defense structures - reduced priority on maps < 20k
    Builder {BuilderName = 'DP Guard',
	
        PlatoonTemplate = 'T1MassGuard',
        
		PlatoonAddFunctions = { {BHVR, 'AirLandToggle'}, {BHVR, 'BroadcastPlatoonPlan'}, {BHVR, 'RetreatAI'} },
		
		PlatoonAddPlans = { 'PlatoonCallForHelpAI','DistressResponseAI', },

        PlatoonAIPlan = 'GuardPoint',
		
        Priority = 801,
		
		PriorityFunction = function(self, aiBrain, manager)
          
            if PlatoonCategoryCountAroundPosition( aiBrain.ArmyPool, LANDDIRECTFIRE - LANDAMPHIB, manager.Location, manager.Radius ) < 2 then
                return 10, true
            end

            if ScenarioInfo.size[1] < 1024 or ScenarioInfo.size[2] < 1024 then
                return 800, true
            else
                return 801, true
            end
  
        end,
		
		RTBLocation = 'Any',
		
        InstanceCount = 3,
		
        BuilderType = 'Any',
		
        BuilderConditions = {
            { LUTL, 'UnitCapCheckLess', { .75 } },
			{ LUTL, 'NoBaseAlert', { 'LocationType' }},
            { LUTL, 'LandStrengthRatioLessThan', { 2 } },
			{ TBC, 'ThreatFurtherThan', { 'LocationType', 200, 'Land', 300 }},                        

            { UCBC, 'DefensivePointNeedsStructure', { 'LocationType', 1250, 'DEFENSE STRUCTURE DIRECTFIRE', 60, 3, 0, 100, 0, 'AntiSurface' }},
        },
		
        BuilderData = {
			DistressRange = 125,
            DistressReactionTime = 16,
			DistressTypes = 'Land',
			DistressThreshold = 6,
			
			PointType = 'Marker',
			PointCategory = 'Defensive Point',
			PointSourceSelf = true,			-- will use itself as the location
			PointFaction = 'Ally',
			PointRadius = 1250,
			PointSort = 'Closest',
			PointMin = 250,
			PointMax = 999999,
			
			StrCategory = DEFENSESTRUCTURE,
			StrRadius = 60,
			StrTrigger = true,				-- structure parameters trigger an end to guardtimer
			StrMin = 0,
			StrMax = 3,
            
            ThreatMin = 0,                  -- pick points with at least 1 threat
            ThreatMaxRatio = 1,
            ThreatRings = 1,                -- at this range

			UntCategory = LANDDIRECTFIRE + LANDARTILLERY,
			UntRadius = 45,
			UntTrigger = true,				-- unit parameters trigger end to guardtimer
			UntMin = 0,
			UntMax = 18,                    -- ignore this point if more than 18 Allied LAND MOBILE units
			
            AssistRange = 2,
			
            PrioritizedCategories = {'LAND MOBILE','STRUCTURE -WALL','ENGINEER'},
			
			GuardRadius = 72,
			GuardTimer = 360,
			
			MergeLimit = 18,
            MergePlanMatch = true,			

			AggressiveMove = true,
			
			UseFormation = 'LOUDClusterFormation',
        },
    },
	
    -- this one guards Expansion points - reduced priority on maps < 20k
    Builder {BuilderName = 'Expansion Guard',
	
        PlatoonTemplate = 'T1MassGuard',
        
		PlatoonAddFunctions = { {BHVR, 'AirLandToggle'}, {BHVR, 'BroadcastPlatoonPlan'}, {BHVR, 'RetreatAI'} },
		
		PlatoonAddPlans = { 'PlatoonCallForHelpAI','DistressResponseAI' },

        PlatoonAIPlan = 'GuardPoint',
		
        Priority = 801,
		
		PriorityFunction = function(self, aiBrain, manager)
            
            if PlatoonCategoryCountAroundPosition( aiBrain.ArmyPool, LANDDIRECTFIRE - LANDAMPHIB, manager.Location, manager.Radius ) < 2 then
                return 10, true
            end

            if ScenarioInfo.size[1] < 1024 or ScenarioInfo.size[2] < 1024 then
                return 800, true
            else
                return 801, true
            end
  
        end,
        
		RTBLocation = 'Any',
		
        InstanceCount = 3,
		
        BuilderType = 'Any',
		
        BuilderConditions = {
            { LUTL, 'UnitCapCheckLess', { .65 } },
			{ LUTL, 'NoBaseAlert', { 'LocationType' }},
            { LUTL, 'LandStrengthRatioLessThan', { 3 } },
			{ TBC, 'ThreatFurtherThan', { 'LocationType', 200, 'Land', 300 }},                        

            { UCBC, 'ExpansionPointNeedsStructure', { 'LocationType', 1250, 'STRUCTURE -ECONOMIC', 60, 4, 0, 100, 0, 'AntiSurface' }},
        },
		
        BuilderData = {
			DistressRange = 125,
            DistressReactionTime = 16,
			DistressTypes = 'Land',
			DistressThreshold = 6,
			
			PointType = 'Marker',				-- either Unit or Marker
			PointCategory = 'Large Expansion Area',
			PointSourceSelf = true,				-- true AI will use its base as source, false will use current Enemy Main Base location
			PointFaction = 'Ally',	 			-- must be either Ally or Enemy - determines which Structures and Units to check
			PointRadius = 1250,					-- controls the finding of points based upon distance from PointSource
			PointSort = 'Closest',				-- options are Closest or Furthest
			PointMin = 200,						-- allows you to filter found points by range from PointSource
			PointMax = 1250,
			
			StrCategory = DEFENSESTRUCTURE,		-- filter points based upon units/strucutres at point
			StrRadius = 60,
			StrTrigger = true,					-- structure parameters trigger end to guardtimer
			StrMin = 0,
			StrMax = 4,
            
            ThreatMin = 0,
            ThreatMaxRatio = 1,
            ThreatRings = 0,                -- at this range
			
			UntCategory = LANDDIRECTFIRE + LANDARTILLERY,
			UntRadius = 60,
			UntTrigger = true,					-- unit parameters trigger an early end to guardtimer
			UntMin = 0,
			UntMax = 26,
			
            AssistRange = 2,
			
            PrioritizedCategories = {'LAND','STRUCTURE','ENGINEER'},		-- controls target selection
			
			GuardRadius = 72,					-- range at which platoon will engage targets
			GuardTimer = 1050,					-- period that platoon will guard the point 
			
			MergeLimit = 26,					-- limit to which unit merging is allowed - nil = original platoon size
            MergePlanMatch = true,			

			AggressiveMove = true,
			
			AvoidBases = true,
			
			UseFormation = 'LOUDClusterFormation',
        },
    }, 

    -- and this one guards empty start positions
    Builder {BuilderName = 'Start Guard',
	
        PlatoonTemplate = 'T1MassGuard',
        
		PlatoonAddFunctions = { {BHVR, 'AirLandToggle'}, {BHVR, 'BroadcastPlatoonPlan'}, {BHVR, 'RetreatAI'} },
		
		PlatoonAddPlans = { 'PlatoonCallForHelpAI','DistressResponseAI' },
        
        PlatoonAIPlan = 'GuardPoint',
		
        Priority = 801,
        
        PriorityFunction = function(self, aiBrain, manager)
            
            if IsPrimaryBase(self,aiBrain,manager) == 801 then

                if PlatoonCategoryCountAroundPosition( aiBrain.ArmyPool, LANDDIRECTFIRE - LANDAMPHIB, manager.Location, manager.Radius ) < 2 then
                    return 10,true
                else
                    return 801,true
                end
                
            else
                return 10, true
            end

        end,

		RTBLocation = 'Any',
		
        InstanceCount = 3,
		
        BuilderType = 'Any',
		
        BuilderConditions = {
            { LUTL, 'UnitCapCheckLess', { .65 } },
			{ LUTL, 'NoBaseAlert', { 'LocationType' }},
            { LUTL, 'LandStrengthRatioLessThan', { 3 } },
			{ TBC, 'ThreatFurtherThan', { 'LocationType', 200, 'Land', 300 }},                        

			-- a starting point within 15km that has <= 6 non-economic structures within 60 and no more than 100 threat
            { UCBC, 'StartingPointNeedsStructure', { 'LocationType', 1250, 'STRUCTURE -ECONOMIC', 60, 4, 0, 100, 0, 'AntiSurface' }},
        },
		
        BuilderData = {
			DistressRange = 125,
            DistressReactionTime = 16,
			DistressTypes = 'Land',
			DistressThreshold = 6,
			
			PointType = 'Marker',
			PointCategory = 'Blank Marker',
			PointSourceSelf = true,
			PointFaction = 'Ally',
			PointRadius = 1250,
			PointSort = 'Closest',
			PointMin = 200,
			PointMax = 1250,
			
			StrCategory = DEFENSESTRUCTURE,
			StrRadius = 60,
			StrTrigger = true,
			StrMin = 0,
			StrMax = 4,
            
            ThreatMin = 0,
            ThreatMaxRatio = 1.1,
            ThreatRings = 0,

			UntCategory = LANDDIRECTFIRE + LANDARTILLERY,
			UntRadius = 60,
			UntTrigger = true,
			UntMin = 0,
			UntMax = 30,
			
            AssistRange = 2,
			
            PrioritizedCategories = {'LAND MOBILE','ECONOMIC', 'STRUCTURE -WALL','ENGINEER'},
			
			GuardRadius = 75,
			GuardTimer = 1050,
			
			MergeLimit = 30,
            MergePlanMatch = true,			

			AggressiveMove = true,
			
			AvoidBases = true,
			
			UseFormation = 'LOUDClusterFormation',
        },
    },
    
    -- a pure artillery guard formation for empty DP positions
    Builder {BuilderName = 'DP Guard Artillery',
	
        PlatoonTemplate = 'T1PointGuardArtillery',
        
		PlatoonAddFunctions = { {BHVR, 'AirLandToggle'}, {BHVR, 'BroadcastPlatoonPlan'}, {BHVR, 'RetreatAI'} },
		
		PlatoonAddPlans = { 'PlatoonCallForHelpAI' },

        PlatoonAIPlan = 'GuardPoint',
		
        Priority = 800,

        PriorityFunction = function(self, aiBrain, manager)            

            if IsPrimaryBase(self,aiBrain,manager) == 800 then

                if PlatoonCategoryCountAroundPosition( aiBrain.ArmyPool, LANDARTILLERY - categories.EXPERIMENTAL, manager.Location, manager.Radius ) < 6 then
                    return 10,true
                else
                    return 800,true
                end
                
            else
                return 10, true
            end

        end,

		RTBLocation = 'Any',
		
        InstanceCount = 3,
		
        BuilderType = 'Any',
		
        BuilderConditions = {
            { LUTL, 'UnitCapCheckLess', { .75 } },
			{ LUTL, 'NoBaseAlert', { 'LocationType' }},
            { LUTL, 'LandStrengthRatioLessThan', { 4 } },
			{ TBC, 'ThreatFurtherThan', { 'LocationType', 200, 'Land', 300 }},                        

			-- a DP marker with less than 100 enemy threat
            { UCBC, 'DefensivePointForExpansion', { 'LocationType', 1250, 0, 100, 0, 'AntiSurface' }},
        },
		
        BuilderData = {
			DistressRange = 100,
			DistressTypes = 'Land',
			DistressThreshold = 6,
			
			PointType = 'Marker',
			PointCategory = 'Defensive Point',
			PointSourceSelf = true,
			PointFaction = 'Ally',
			PointRadius = 1250,
			PointSort = 'Closest',
			PointMin = 200,
			PointMax = 999999,
			
			StrCategory = DEFENSESTRUCTURE,
			StrRadius = 60,
			StrTrigger = true,
			StrMin = 0,
			StrMax = 3,
            
            ThreatMin = 0,
            ThreatMaxRatio = 1.6,
            ThreatRings = 0,

			UntCategory = LANDDIRECTFIRE + LANDARTILLERY,
			UntRadius = 60,
			UntTrigger = false,
			UntMin = 0,
			UntMax = 8,
			
            AssistRange = 2,
			
            PrioritizedCategories = {'LAND MOBILE','STRUCTURE -WALL','ENGINEER'},
			
			GuardRadius = 85,
			GuardTimer = 480,
			
			MergeLimit = 25,
            MergePlanMatch = true,			

			AggressiveMove = true,
			
			UseFormation = 'AttackFormation',
        },
    },

    Builder {BuilderName = 'Start Guard Artillery',
	
        PlatoonTemplate = 'T1PointGuardArtillery',
        
		PlatoonAddFunctions = { {BHVR, 'AirLandToggle'}, {BHVR, 'BroadcastPlatoonPlan'}, {BHVR, 'RetreatAI'} },
		
		PlatoonAddPlans = { 'PlatoonCallForHelpAI' },

        PlatoonAIPlan = 'GuardPoint',
		
        Priority = 800,

        PriorityFunction = function(self, aiBrain, manager)            

            if IsPrimaryBase(self,aiBrain,manager) == 800 then

                if PlatoonCategoryCountAroundPosition( aiBrain.ArmyPool, LANDARTILLERY - categories.EXPERIMENTAL, manager.Location, manager.Radius ) < 6 then
                    return 10,true
                else
                    return 800,true
                end
                
            else
                return 10, true
            end

        end,

		RTBLocation = 'Any',
		
        InstanceCount = 2,
		
        BuilderType = 'Any',
		
        BuilderConditions = {
            { LUTL, 'UnitCapCheckLess', { .65 } },
			{ LUTL, 'NoBaseAlert', { 'LocationType' }},
            { LUTL, 'LandStrengthRatioLessThan', { 3 } },
			{ TBC, 'ThreatFurtherThan', { 'LocationType', 200, 'Land', 300 }},                        

            { UCBC, 'StartingPointNeedsStructure', { 'LocationType', 1000, 'STRUCTURE -ECONOMIC', 60, 4, 0, 100, 0, 'AntiSurface' }},
        },
		
        BuilderData = {
			DistressRange = 100,
			DistressTypes = 'Land',
			DistressThreshold = 8,
			
			PointType = 'Marker',
			PointCategory = 'Blank Marker',
			PointSourceSelf = true,
			PointFaction = 'Ally',
			PointRadius = 1000,
			PointSort = 'Closest',
			PointMin = 200,
			PointMax = 1000,
			
			StrCategory = DEFENSESTRUCTURE,
			StrRadius = 60,
			StrTrigger = true,
			StrMin = 0,
			StrMax = 4,
            
            ThreatMin = 0,
            ThreatRings = 1,
			
			UntCategory = LANDDIRECTFIRE + LANDARTILLERY,
			UntRadius = 60,
			UntTrigger = true,
			UntMin = 0,
			UntMax = 12,
			
            AssistRange = 2,
			
            PrioritizedCategories = {'LAND MOBILE','STRUCTURE -WALL','ENGINEER'},
			
			GuardRadius = 85,
			GuardTimer = 900,
			
			MergeLimit = 30,
            MergePlanMatch = true,			

			AggressiveMove = true,
			
			AvoidBases = true,
			
			UseFormation = 'AttackFormation',
        },
    }, 

    Builder {BuilderName = 'Expansion Guard Artillery',
	
        PlatoonTemplate = 'T1PointGuardArtillery',
        
		PlatoonAddFunctions = { {BHVR, 'AirLandToggle'}, {BHVR, 'BroadcastPlatoonPlan'}, {BHVR, 'RetreatAI'} },
		
		PlatoonAddPlans = { 'PlatoonCallForHelpAI' },

        PlatoonAIPlan = 'GuardPoint',
		
        Priority = 800,

        PriorityFunction = function(self, aiBrain, manager)            

            if IsPrimaryBase(self,aiBrain,manager) == 800 then

                if PlatoonCategoryCountAroundPosition( aiBrain.ArmyPool, LANDARTILLERY - categories.EXPERIMENTAL, manager.Location, manager.Radius ) < 6 then
                    return 10,true
                else
                    return 800,true
                end
                
            else
                return 10, true
            end

        end,

		RTBLocation = 'Any',
		
        InstanceCount = 2,
		
        BuilderType = 'Any',
		
        BuilderConditions = {
            { LUTL, 'UnitCapCheckLess', { .65 } },
			{ LUTL, 'NoBaseAlert', { 'LocationType' }},
            { LUTL, 'LandStrengthRatioLessThan', { 4 } },
			{ TBC, 'ThreatFurtherThan', { 'LocationType', 200, 'Land', 300 }},                        

            { UCBC, 'ExpansionPointNeedsStructure', { 'LocationType', 1250, 'STRUCTURE -ECONOMIC', 75, 4, 0, 100, 0, 'AntiSurface' }},            
        },
		
        BuilderData = {
			DistressRange = 100,
			DistressTypes = 'Land',
			DistressThreshold = 10,
			
			PointType = 'Marker',
			PointCategory = 'Large Expansion Area',
			PointSourceSelf = true,
			PointFaction = 'Ally',
			PointRadius = 1000,
			PointSort = 'Closest',
			PointMin = 200,
			PointMax = 1250,
			
			StrCategory = DEFENSESTRUCTURE,
			StrRadius = 75,
			StrTrigger = true,
			StrMin = 0,
			StrMax = 4,
            
            ThreatMin = 0,
            ThreatMaxRatio = 0.8,
            ThreatRings = 0,
			
			UntCategory = LANDDIRECTFIRE + LANDARTILLERY,
			UntRadius = 60,
			UntTrigger = true,
			UntMin = 0,
			UntMax = 12,
			
            AssistRange = 2,
			
            PrioritizedCategories = {'LAND MOBILE','STRUCTURE -WALL','ENGINEER'},
			
			GuardRadius = 85,
			GuardTimer = 900,
			
			MergeLimit = 30,
            MergePlanMatch = true,			

			AggressiveMove = true,
			
			AvoidBases = true,
			
			UseFormation = 'AttackFormation',
        },
    }, 
    
	Builder {BuilderName = 'Extractor Attack',
	
        PlatoonTemplate = 'T1MassGuard',
        
		PlatoonAddFunctions = { {BHVR, 'AirLandToggle'}, {BHVR, 'BroadcastPlatoonPlan'}, {BHVR, 'RetreatAI'} },
		
		PlatoonAddPlans = { 'PlatoonCallForHelpAI','DistressResponseAI' },
        
        PlatoonAIPlan = 'GuardPoint',
		
        Priority = 800,
		
		PriorityFunction = function(self, aiBrain, manager)

            if PlatoonCategoryCountAroundPosition( aiBrain.ArmyPool, LANDDIRECTFIRE - LANDAMPHIB, manager.Location, manager.Radius ) < 2 then
                return 10,true
            else
                return 805,true
            end

        end,

        RTBLocation = 'Any',

        InstanceCount = 5,
		
        BuilderType = 'Any',
		
        BuilderConditions = {
            { LUTL, 'UnitCapCheckLess', { .85 } },
			{ LUTL, 'NeedTeamMassPointShare', {}},
			{ LUTL, 'NoBaseAlert', { 'LocationType' }},
			{ TBC, 'ThreatFurtherThan', { 'LocationType', 200, 'Land', 300 }},                        

			-- enemy mass points within 20km
			{ LUTL, 'GreaterThanEnemyUnitsAroundBase', { 'LocationType', 0, categories.STRUCTURE * (categories.MASSPRODUCTION + categories.HYDROCARBON), 1000 }},
        },
		
        BuilderData = {
			DistressRange = 90,
            DistressReactionTime = 20,
			DistressTypes = 'Land',
			DistressThreshold = 4,
			
			PointType = 'Unit',
			PointCategory = categories.STRUCTURE * (categories.MASSPRODUCTION + categories.HYDROCARBON),
			PointSourceSelf = true,
			PointFaction = 'Enemy',
			PointRadius = 1000,
			PointSort = 'Closest',
			PointMin = 25,
			PointMax = 1000,
			
			StrCategory = DEFENSESTRUCTURE,
			StrRadius = 30,
			StrTrigger = true,
			StrMin = 0,
			StrMax = 2,
            
            ThreatMaxRatio = 0.9,
			
			UntCategory = LANDDIRECTFIRE + LANDARTILLERY,
			UntRadius = 36,
			UntTrigger = true,
			UntMin = 0,
			UntMax = 8,
			
            PrioritizedCategories = { 'MASSPRODUCTION','HYDROCARBON','ECONOMIC','ENGINEER -COMMAND'},
			
			GuardRadius = 30,
			GuardTimer = 5,
			
			MergeLimit = 25,
            MergePlanMatch = false,

			AggressiveMove = true,
			
			AllowInWater = false,
			
			UseFormation = 'LOUDClusterFormation',
        },
    },
	
}

-- Land Formations - Base Guards --
-- essentially patrols around the base --
-- new patrols are suspended once a base is under alert
BuilderGroup {BuilderGroupName = 'Land Formations - Base Guards',
	BuildersType = 'PlatoonFormBuilder',
	
	-- in general - we want base guards before anything else
    -- but there must be a land threat within 6km of base
    -- distress reaction time is very high so responses will carry on well after threat recedes
    Builder {BuilderName = 'Base Guard Patrol',
	
        PlatoonTemplate = 'BaseGuardMedium',
        
		PlatoonAddFunctions = { {BHVR, 'AirLandToggle'}, {BHVR, 'BroadcastPlatoonPlan'}, {BHVR, 'RetreatAI'} },
		
		PlatoonAddPlans = { 'DistressResponseAI' },
		
		PlatoonAIPlan = 'PlatoonPatrolPointAI',
		
		InstanceCount = 2,
		
        Priority =  805,
		
		PriorityFunction = function(self, aiBrain, manager)

            if PlatoonCategoryCountAroundPosition( aiBrain.ArmyPool, LANDDIRECTFIRE, manager.Location, manager.Radius ) < 6 then
                return 10,true
            else
                return 805,true
            end

        end,
		
        BuilderType = 'Any',
		
        BuilderConditions = { 
            { LUTL, 'UnitCapCheckLess', { .85 } },
			{ TBC, 'ThreatCloserThan', { 'LocationType', 300, 75, 'Land' }},
        },
		
        BuilderData = {
			DistressRange = 125,
            DistressReactionTime = 22,
			DistressTypes = 'Land',
			DistressThreshold = 4,
			
			BasePerimeterOrientation = '',
			
			Radius = 78,
			
			PatrolTime = 400,
			PatrolType = true,
        },
    }, 
    
    -- AA base patrols appear if our air ratio is below 3
    Builder {BuilderName = 'Base Guard Patrol - AA',
	
        PlatoonTemplate = 'BaseGuardAAPatrol',
        
		PlatoonAddFunctions = { {BHVR, 'AirLandToggle'}, {BHVR, 'BroadcastPlatoonPlan'}, {BHVR, 'RetreatAI'} },
		
		PlatoonAddPlans = { 'DistressResponseAI' },
		
		PlatoonAIPlan = 'PlatoonPatrolPointAI',
		
        Priority =  805,
		
		PriorityFunction = function(self, aiBrain, manager)

            if PlatoonCategoryCountAroundPosition( aiBrain.ArmyPool, LANDANTIAIR, manager.Location, manager.Radius ) < 6 then
                return 10,true
            else
                return 805,true
            end

        end,
		
        BuilderType = 'Any',
		
        BuilderConditions = {
            { LUTL, 'UnitCapCheckLess', { .85 } },
			{ LUTL, 'NoBaseAlert', { 'LocationType' }},		
			{ LUTL, 'AirStrengthRatioLessThan', { 1.5 }},
        },
		
        BuilderData = {
			DistressRange = 100,
			DistressTypes = 'Air',
			DistressThreshold = 4,
			
			BasePerimeterOrientation = '',
			
			Radius = 72,
			
			PatrolTime = 350,
			PatrolType = true,
        },
    }, 

}

-- Reinforcement Formation --
-- move Units to the PRIMARY Base --
-- these only run when a base is NOT the PRIMARY
-- and are suspended when the base is under alert or has threat nearby
BuilderGroup {BuilderGroupName = 'Land Formations - Reinforcement',
	BuildersType = 'PlatoonFormBuilder',

    --- triggered by 5 Directfire units
	Builder {BuilderName = 'Reinforce Primary - Directfire',
	
        PlatoonTemplate = 'ReinforceLandPlatoonDirect',
        
		PlatoonAddFunctions = { {BHVR, 'AirLandToggle'}, {BHVR, 'BroadcastPlatoonPlan'}, },
		
		PlatoonAIPlan = 'ReinforceLandAI',
		
        Priority = 10,

		PriorityFunction = function(self, aiBrain, manager)
            
            if PlatoonCategoryCountAroundPosition( aiBrain.ArmyPool, LANDDIRECTFIRE, manager.Location, manager.Radius ) < 5 then
                return 10,true
            end

            return NotPrimaryBase(self,aiBrain,manager), true
		end,
		
        InstanceCount = 4,
		
        BuilderType = 'Any',
		
        BuilderConditions = {
            { LUTL, 'NoBaseAlert', { 'LocationType' }},
			{ TBC, 'ThreatFurtherThan', { 'LocationType', 200, 'Land', 300 }},
        },
		
        BuilderData = {
            UseFormation = 'GrowthFormation',
        },    
    },

    --- triggered by 5 Indirectfire units    
	Builder {BuilderName = 'Reinforce Primary - Indirectfire',
	
        PlatoonTemplate = 'ReinforceLandPlatoonIndirect',
        
		PlatoonAddFunctions = { {BHVR, 'AirLandToggle'}, {BHVR, 'BroadcastPlatoonPlan'}, },
		
		PlatoonAIPlan = 'ReinforceLandAI',
		
        Priority = 10,

		PriorityFunction = function(self, aiBrain, manager)
            
            if PlatoonCategoryCountAroundPosition( aiBrain.ArmyPool, LANDARTILLERY - categories.EXPERIMENTAL, manager.Location, manager.Radius ) < 5 then
                return 10,true
            end

            return NotPrimaryBase(self,aiBrain,manager), true
		end,
		
        InstanceCount = 2,
		
        BuilderType = 'Any',
		
        BuilderConditions = {
            { LUTL, 'NoBaseAlert', { 'LocationType' }},
			{ TBC, 'ThreatFurtherThan', { 'LocationType', 200, 'Land', 300 }},
        },
		
        BuilderData = {
            UseFormation = 'GrowthFormation',
        },
    },

    --- triggered by 3 directfire units    
	Builder {BuilderName = 'Reinforce Primary - Support',
	
        PlatoonTemplate = 'ReinforceLandPlatoonSupport',
        
		PlatoonAddFunctions = { {BHVR, 'AirLandToggle'}, {BHVR, 'BroadcastPlatoonPlan'}, },
		
		PlatoonAIPlan = 'ReinforceLandAI',
		
        Priority = 10,

		PriorityFunction = function(self, aiBrain, manager)
            
            if PlatoonCategoryCountAroundPosition( aiBrain.ArmyPool, LANDDIRECTFIRE, manager.Location, manager.Radius ) < 3 then
                return 10,true
            end

            return NotPrimaryBase(self,aiBrain,manager), true
		end,
		
        InstanceCount = 2,
		
        BuilderType = 'Any',
		
        BuilderConditions = {
            { LUTL, 'NoBaseAlert', { 'LocationType' }},
			{ TBC, 'ThreatFurtherThan', { 'LocationType', 200, 'Land', 300 }},
        },
		
        BuilderData = {
            UseFormation = 'GrowthFormation',
        },
    },


}

