-- /lua/ai/Loud_AI_Engineer_Defense_Builders.lua

-- Constructs All Base Defenses and Shields

local UCBC  = '/lua/editor/UnitCountBuildConditions.lua'
local MIBC  = '/lua/editor/MiscBuildConditions.lua'
local EBC   = '/lua/editor/EconomyBuildConditions.lua'
local TBC   = '/lua/editor/ThreatBuildConditions.lua'
local LUTL  = '/lua/loudutilities.lua'

local GreaterThanEnergyIncome                       = import(LUTL).GreaterThanEnergyIncome
local HaveGreaterThanUnitsWithCategoryAndAlliance   = import(UCBC).HaveGreaterThanUnitsWithCategoryAndAlliance
local UnitsGreaterAtLocation                        = import(UCBC).UnitsGreaterAtLocation
local UnitsGreaterAtLocationInRange                 = import(UCBC).UnitsGreaterAtLocationInRange
local UnitsLessAtLocation                           = import(UCBC).UnitsLessAtLocation
local UnitsLessAtLocationInRange                    = import(UCBC).UnitsLessAtLocationInRange

local AA        = categories.STRUCTURE * categories.ANTIAIR
local PD        = categories.STRUCTURE * categories.DIRECTFIRE
local SMD       = categories.STRUCTURE * categories.ANTIMISSILE * categories.SILO * categories.TECH3
local TMD       = categories.STRUCTURE * categories.ANTIMISSILE - categories.SILO
local ENERGY    = categories.STRUCTURE * categories.ENERGYPRODUCTION
local FACTORY   = categories.STRUCTURE * categories.FACTORY
local SHIELD    = categories.STRUCTURE * categories.SHIELD

local LOUDFLOOR = math.floor

local GetArmyUnitCap        = GetArmyUnitCap
local GetArmyUnitCostTotal  = GetArmyUnitCostTotal
local GetPosition           = moho.entity_methods.GetPosition
local GetThreatAtPosition   = moho.aibrain_methods.GetThreatAtPosition

local AboveUnitCap65 = function( self,aiBrain )
	
	if GetArmyUnitCostTotal(aiBrain.ArmyIndex) / GetArmyUnitCap(aiBrain.ArmyIndex) > .65 then
		return 10, true
	end
	
	return (self.OldPriority or self.Priority), true
end

local AboveUnitCap75 = function( self,aiBrain )
	
	if GetArmyUnitCostTotal(aiBrain.ArmyIndex) / GetArmyUnitCap(aiBrain.ArmyIndex) > .75 then
		return 10, true
	end
	
	return (self.OldPriority or self.Priority), true
end

local AboveUnitCap85 = function( self,aiBrain )
	
	if GetArmyUnitCostTotal(aiBrain.ArmyIndex) / GetArmyUnitCap(aiBrain.ArmyIndex) > .85 then
		return 10, true
	end
	
	return (self.OldPriority or self.Priority), true
end

-- Just a note -- many of these builders use the 'BasePerimeterSelection = true' function
-- This will direct the AI to build only one of these positions at a time -- selecting randomly
-- from the available positions (which depends upon the BasePerimeterOrientation)
-- This keeps the AI in check when building these expensive items rather than building
-- all the positions in a single go 
-- the only exception is the shields which, when they meet conditions, all positions will be produced

-- this function will turn a builder off if the enemy is not active in the water
-- this differs as we use 5 as the upper limit, rather than 10
local IsEnemyNavalActive = function(self,aiBrain,manager)

	if aiBrain.NavalRatio and (aiBrain.NavalRatio > .011 and aiBrain.NavalRatio <= 5) then
	
		return self.OldPriority or self.Priority, true	-- standard naval priority -- 

	end

	return 10, true
	
end

local IsPrimaryBase = function(self,aiBrain,manager)
	
	if aiBrain.BuilderManagers[manager.LocationType].PrimarySeaAttackBase then
		return self.OldPriority or self.Priority, true
	end

	return 10, true
end

-- this function will remove the builder if this is not a NAVAL map (water - but no naval markers)
local IsNavalMap = function( self, aiBrain, manager)

    if aiBrain.IsNavalMap then
        return self.Priority, false
    end
    
    return 0, false

end

-- These 3 functions need some consideration - as they force the priority up by 100 - which seems like a guess
-- Review the Engineer Builders priorities, 850 blows pretty much all others out of the water
-- you may wish to consider that it may override some very important tasks (like reclaim or energy)

-- These 2 New Functions will enable LOUD to prioritize defenses if a ratio falls below a certain value
-- This is mostly for the players that rush him but this should also effect how prepared his bases are.
local IsEnemyCrushingLand = function( builder, aiBrain, unit )

    if aiBrain.LandRatio <= 1.0 and aiBrain.CycleTime > 360 then
	
		return (builder.OldPriority or builder.Priority) + 100, true	

    end
    
    local threat = GetThreatAtPosition( aiBrain, GetPosition(unit), ScenarioInfo.IMAPBlocks, true, 'AntiSurface' )

    if threat > 150 then

        return (builder.OldPriority or builder.Priority) + 100, true
        
    end
    
    return (builder.OldPriority or builder.Priority), true
end

local IsEnemyCrushingAir = function( builder, aiBrain, unit )

    if aiBrain.AirRatio <= 1.0 and aiBrain.CycleTime > 480 then
	
		return (builder.OldPriority or builder.Priority) + 100, true	

    end
    
    return (builder.OldPriority or builder.Priority), true
end

local IsEnemyCrushingNaval = function( builder, aiBrain, unit )

	if aiBrain.NavalRatio and ( aiBrain.NavalRatio > .011 and aiBrain.NavalRatio <= 1.0 ) then

        if aiBrain.CycleTime > 480 then
	
            return (builder.OldPriority or builder.Priority) + 100, true	

        end
    
    end

    return (builder.OldPriority or builder.Priority), true
end

---------------------
--- THE MAIN BASE ---
---------------------
--- CORE ---
BuilderGroup {BuilderGroupName = 'Engineer Base Defense Construction - Core',
    BuildersType = 'EngineerBuilder',

    Builder {BuilderName = 'T1 Base Defense - PD',
	
        PlatoonTemplate = 'EngineerBuilder',
        
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
		
		InstanceCount = 1,
		
        Priority = 750,
		
		PriorityFunction = function(builder, aiBrain, unit, manager)
		
			if builder.Priority != 0 then

				-- remove after 25 minutes
				if aiBrain.CycleTime > 1500 then
					return 0, false
				end
        
                if not GreaterThanEnergyIncome( aiBrain, 550 ) then
                    return 10, true
                end
                
                if UnitsGreaterAtLocation( aiBrain, manager.LocationType, 0, ENERGY - categories.TECH1 ) then
                    return 10, true
                end

                if UnitsGreaterAtLocationInRange( aiBrain, manager.LocationType, 17, PD, 30, 50 ) then
                    return 10, true
                end
 
                if aiBrain.LandRatio < 1 and aiBrain.CycleTime > 360 then
                    return (builder.OldPriority or builder.Priority) + 50, true
                end
    
                local threat = GetThreatAtPosition( aiBrain, GetPosition(unit), ScenarioInfo.IMAPBlocks, true, 'AntiSurface' )

                if threat > 125 then

                    return (builder.OldPriority or builder.Priority) + 100, true
        
                elseif threat < 25 then
            
                    return (builder.OldPriority or builder.Priority) - 50, true
                
                end				
			end
			
			return (builder.OldPriority or builder.Priority)
			
		end,
		
        BuilderConditions = {
            { MIBC, 'BaseInPlayableArea', { 'LocationType' }},

			{ EBC, 'GreaterThanEconStorageCurrent', { 300, 3000 }},

			{ UCBC, 'UnitsLessAtLocationInRange', { 'LocationType', 18, PD, 30, 50}},
        },
		
        BuilderType = { 'T1' },
		
        BuilderData = {
            Construction = {
				Radius = 36,
                NearBasePerimeterPoints = true,
				ThreatMax = 50,
				
				BasePerimeterOrientation = 'FRONT',
				BasePerimeterSelection = true,	-- pick a random point from the 9 FRONT rotations

				BaseTemplateFile = '/lua/ai/aibuilders/loud_perimeter_defense_templates.lua',
				BaseTemplate = 'PerimeterDefenseTemplates',
				
                BuildStructures = {'T1GroundDefense','T1Artillery'},
            }
        }
    },	

    Builder {BuilderName = 'T1 Base Defense - AA',
	
        PlatoonTemplate = 'EngineerBuilder',
        
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
		
		InstanceCount = 1,
		
        Priority = 750,
		
		PriorityFunction = function(self, aiBrain, unit, manager)
		
			if self.Priority != 0 then

				-- remove after 25 minutes
				if aiBrain.CycleTime > 1500 then
					return 0, false
				end
                
                -- ignore this for first 7 minutes
                if aiBrain.CycleTime < 420 then
                    return 10, true
                end
        
                if aiBrain.AirRatio >= 2.5 or not GreaterThanEnergyIncome( aiBrain, 400 ) then
                    return 10, true
                end

                if UnitsGreaterAtLocation( aiBrain, manager.LocationType, 0, ENERGY - categories.TECH1 ) then
                    return 10, true
                end

                if UnitsGreaterAtLocationInRange( aiBrain, manager.LocationType, 8, AA, 30, 42 ) then
                    return 10, true
                end
 
                -- if air ratio poor 
                if aiBrain.AirRatio < 1.5 then
                    return (self.OldPriority or self.Priority) + 50, true
                end
				
			end
			
			return self.Priority
			
		end,
		
        BuilderConditions = {
            { MIBC, 'BaseInPlayableArea', { 'LocationType' }},

			{ EBC, 'GreaterThanEconStorageCurrent', { 250, 2500 }},
        },
		
        BuilderType = { 'T1' },
		
        BuilderData = {
            Construction = {
				Radius = 36,
                NearBasePerimeterPoints = true,
				ThreatMax = 50,
				
				BasePerimeterOrientation = 'FRONT',
				BasePerimeterSelection = true,	-- pick a random point from the 9 FRONT rotations

				BaseTemplateFile = '/lua/ai/aibuilders/loud_perimeter_defense_templates.lua',
				BaseTemplate = 'PerimeterDefenseTemplates',
				
                BuildStructures = {'T1AADefense'},
            }
        }
    },

    Builder {BuilderName = 'T2 Base PD - Base Template',
	
        PlatoonTemplate = 'EngineerBuilder',
        
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
		
		InstanceCount = 1,
		
        Priority = 750,

        PriorityFunction = function( builder, aiBrain, unit, manager )
        
            if aiBrain.LandRatio >= 2 or GetArmyUnitCostTotal(aiBrain.ArmyIndex) / GetArmyUnitCap(aiBrain.ArmyIndex) > .65 then
            
                return 10, true
               
            end
            
            if UnitsGreaterAtLocationInRange( aiBrain, manager.LocationType, 9, PD * categories.TECH3, 15, 42 ) then
            
                return 10, true
                
            end
            
            if UnitsGreaterAtLocationInRange( aiBrain, manager.LocationType, 19, PD * categories.TECH2, 15, 42 ) then
            
                return 10, true
                
            end

            if aiBrain.LandRatio <= 1.0 and aiBrain.CycleTime > 360 then
	
                return (builder.OldPriority or builder.Priority) + 100, true	

            end
    
            local threat = GetThreatAtPosition( aiBrain, GetPosition(unit), ScenarioInfo.IMAPBlocks, true, 'AntiSurface' )

            if threat > 175 then

                return (builder.OldPriority or builder.Priority) + 100, true
        
            elseif threat < 25 then
            
                return (builder.OldPriority or builder.Priority) - 50, true
                
            end
    
            return (builder.OldPriority or builder.Priority), true
        end,
		
        BuilderConditions = {
            { MIBC, 'BaseInPlayableArea', { 'LocationType' }},            

			{ EBC, 'GreaterThanEconStorageCurrent', { 300, 3000 }},
        },
		
        BuilderType = {'T2','T3'},
		
        BuilderData = {
            DesiresAssist = true,
            NumAssistees = 1,
            
            Construction = {
				NearBasePerimeterPoints = true,
				ThreatMax = 50,
				
				BaseTemplateFile = '/lua/ai/aibuilders/Loud_MAIN_Base_templates.lua',
				BaseTemplate = 'BaseDefenseLayout',
				
                BuildStructures = {'T2GroundDefense'},
            }
        }
    },
	
    Builder {BuilderName = 'T2 Base AA - Base Template',
	
        PlatoonTemplate = 'EngineerBuilder',
        
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
        
        InstanceCount = 2,
		
        Priority = 750,

        PriorityFunction = function( builder, aiBrain, unit, manager )
        
            if aiBrain.AirRatio >= 3 or GetArmyUnitCostTotal(aiBrain.ArmyIndex) / GetArmyUnitCap(aiBrain.ArmyIndex) > .65 then
            
                return 10, true
               
            end
            
            if UnitsGreaterAtLocationInRange( aiBrain, manager.LocationType, 7, AA, 15, 42 ) then
            
                return 10, true
                
            end

            if aiBrain.AirRatio <= 1.0 and aiBrain.CycleTime > 360 then
	
                return (builder.OldPriority or builder.Priority) + 100, true	

            end
    
            return (builder.OldPriority or builder.Priority), true
        end,
		
        BuilderConditions = {
            { MIBC, 'BaseInPlayableArea', { 'LocationType' }},

			{ EBC, 'GreaterThanEconStorageCurrent', { 250, 3000 }},
        },
		
        BuilderType = {'T2'},
		
        BuilderData = {
            Construction = {
				NearBasePerimeterPoints = true,
				ThreatMax = 50,				
				
				BaseTemplateFile = '/lua/ai/aibuilders/Loud_MAIN_Base_templates.lua',
				BaseTemplate = 'BaseDefenseLayout',
				
                BuildStructures = {'T2AADefense'},
            }
        }
    },

    Builder {BuilderName = 'T2 Base TMD - Base Template',
	
        PlatoonTemplate = 'EngineerBuilder',
        
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
		
        Priority = 740,

        PriorityFunction = function( builder, aiBrain, unit, manager )
        
            if aiBrain.LandRatio >= 2.0 or GetArmyUnitCostTotal(aiBrain.ArmyIndex) / GetArmyUnitCap(aiBrain.ArmyIndex) > .75 then
            
                return 10, true
               
            end
            
            if UnitsGreaterAtLocationInRange( aiBrain, manager.LocationType, 9, TMD, 14, 42 ) then
            
                return 10, true
                
            end

            if aiBrain.LandRatio <= 1 and aiBrain.CycleTime > 480 then
	
                return (builder.OldPriority or builder.Priority) + 100, true	

            end
    
            local threat = GetThreatAtPosition( aiBrain, GetPosition(unit), ScenarioInfo.IMAPBlocks, true, 'AntiSurface' )

            if threat > 175 then

                return (builder.OldPriority or builder.Priority) + 100, true
        
            elseif threat < 25 then
            
                return (builder.OldPriority or builder.Priority) - 50, true
                
            end
        
            return (builder.OldPriority or builder.Priority), true
        end,

        BuilderConditions = {
            { MIBC, 'BaseInPlayableArea', { 'LocationType' }},

			{ EBC, 'GreaterThanEconStorageCurrent', { 400, 5000 }},
        },
		
        BuilderType = {'T2'},
		
        BuilderData = {
            Construction = {
				NearBasePerimeterPoints = true,
                
				ThreatMax = 50,				
				
				BaseTemplateFile = '/lua/ai/aibuilders/Loud_MAIN_Base_templates.lua',
				BaseTemplate = 'BaseDefenseLayout',
				
                BuildStructures = {'T2MissileDefense' },
            }
        }
    },

    Builder {BuilderName = 'T3 Base PD - Base Template',
	
        PlatoonTemplate = 'EngineerBuilder',
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
		
        Priority = 751,

        PriorityFunction = function( builder, aiBrain, unit, manager )
        
            if aiBrain.LandRatio >= 2.0 or GetArmyUnitCostTotal(aiBrain.ArmyIndex) / GetArmyUnitCap(aiBrain.ArmyIndex) > .80 or not GreaterThanEnergyIncome( aiBrain, 12600 ) then
            
                return 10, true
               
            end
            
            if UnitsGreaterAtLocationInRange( aiBrain, manager.LocationType, 35, PD * categories.TECH3, 15, 42 ) then
            
                return 10, true
                
            end

            if aiBrain.LandRatio <= 1.0  then
	
                return (builder.OldPriority or builder.Priority) + 100, true	

            end
    
            local threat = GetThreatAtPosition( aiBrain, GetPosition(unit), ScenarioInfo.IMAPBlocks, true, 'AntiSurface' )

            if threat > 175 then

                return (builder.OldPriority or builder.Priority) + 100, true
        
            end
    
            return (builder.OldPriority or builder.Priority), true
        end,

        BuilderConditions = {
            { MIBC, 'BaseInPlayableArea', { 'LocationType' }},

			{ EBC, 'GreaterThanEconStorageCurrent', { 400, 5000 }},

            { EBC, 'GreaterThanEconTrendEfficiencyOverTime', { 0.8, 15, 1.01, 1.02 }},
        },
		
        BuilderType = { 'T3','SubCommander'},
		
        BuilderData = {
			DesiresAssist = true,
            NumAssistees = 2,
			
            Construction = {
				NearBasePerimeterPoints = true,
                
				ThreatMax = 100,
				
				BaseTemplateFile = '/lua/ai/aibuilders/Loud_MAIN_Base_templates.lua',
				BaseTemplate = 'BaseDefenseLayout',
				
                BuildStructures = {'T3GroundDefense'},
            }
        }
    },

    Builder {BuilderName = 'T3 Base AA - Base Template',
	
        PlatoonTemplate = 'EngineerBuilder',
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
		
        Priority = 750, 

        PriorityFunction = function( builder, aiBrain, unit, manager )
        
            if aiBrain.AirRatio >= 2.5 or GetArmyUnitCostTotal(aiBrain.ArmyIndex) / GetArmyUnitCap(aiBrain.ArmyIndex) > .80 then
            
                return 10, true
               
            end
            
            if UnitsGreaterAtLocationInRange( aiBrain, manager.LocationType, 11, AA * categories.TECH3, 15, 42 ) then
            
                return 10, true
                
            end

            if aiBrain.AirRatio <= 1.2  then
	
                return (builder.OldPriority or builder.Priority) + 100, true	

            end
    
            return (builder.OldPriority or builder.Priority), true
        end,
		
        BuilderConditions = {
            { MIBC, 'BaseInPlayableArea', { 'LocationType' }},

			{ EBC, 'GreaterThanEconStorageCurrent', { 400, 5000 }},

            { EBC, 'GreaterThanEconTrendEfficiencyOverTime', { 0.8, 15, 1.01, 1.02 }},
        },
		
        BuilderType = {'T3','SubCommander'},
		
        BuilderData = {
		
			DesiresAssist = true,
            NumAssistees = 2,
			
            Construction = {
				NearBasePerimeterPoints = true,
				ThreatMax = 75,
				
				BaseTemplateFile = '/lua/ai/aibuilders/Loud_MAIN_Base_templates.lua',
				BaseTemplate = 'BaseDefenseLayout',
				
				BuildStructures = {'T3AADefense' },
            }
        }
    },

    Builder {BuilderName = 'T3 Base TMD - Base Template',
	
        PlatoonTemplate = 'EngineerBuilder',
        
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
		
        Priority = 750,

        PriorityFunction = function( builder, aiBrain, unit, manager )
        
            if aiBrain.LandRatio >= 2.0 or GetArmyUnitCostTotal(aiBrain.ArmyIndex) / GetArmyUnitCap(aiBrain.ArmyIndex) > .80 or not GreaterThanEnergyIncome( aiBrain, 12600 ) then
            
                return 10, true
               
            end
            
            if UnitsGreaterAtLocationInRange( aiBrain, manager.LocationType, 9, TMD, 14, 42 ) then
            
                return 10, true
                
            end

            if aiBrain.LandRatio <= 1.0  then
	
                return (builder.OldPriority or builder.Priority) + 100, true	

            end
    
            local threat = GetThreatAtPosition( aiBrain, GetPosition(unit), ScenarioInfo.IMAPBlocks, true, 'AntiSurface' )

            if threat > 175 then

                return (builder.OldPriority or builder.Priority) + 100, true
        
            end
    
            return (builder.OldPriority or builder.Priority), true
        end,
		
        BuilderConditions = {
            { MIBC, 'BaseInPlayableArea', { 'LocationType' }},

			{ EBC, 'GreaterThanEconStorageCurrent', { 400, 5000 }},

            { EBC, 'GreaterThanEconTrendEfficiencyOverTime', { 0.8, 15, 1.01, 1.02 }},

			{ TBC, 'ThreatCloserThan', { 'LocationType', 350, 75, 'AntiSurface' }},
        },
		
        BuilderType = {'T3','SubCommander'},
		
        BuilderData = {
            Construction = {
				NearBasePerimeterPoints = true,
                
				ThreatMax = 50,				
				
				BaseTemplateFile = '/lua/ai/aibuilders/Loud_MAIN_Base_templates.lua',
				BaseTemplate = 'BaseDefenseLayout',
				
                BuildStructures = {'T3MissileDefense' },
            }
        }
    },
    
    -- this artillery is built in the defense boxes - not the core
    Builder {BuilderName = 'T2 Artillery - Base Template - Boxes',
	
        PlatoonTemplate = 'EngineerBuilder',
        
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
		
        Priority = 740,

        PriorityFunction = function( builder, aiBrain, unit, manager )
        
            if aiBrain.LandRatio >= 3.0 or GetArmyUnitCostTotal(aiBrain.ArmyIndex) / GetArmyUnitCap(aiBrain.ArmyIndex) > .80 or not GreaterThanEnergyIncome( aiBrain, 12600 ) then
            
                return 10, true
               
            end
            
            if UnitsGreaterAtLocationInRange( aiBrain, manager.LocationType, 3, categories.ARTILLERY * categories.STRUCTURE * categories.TECH2, 21, 42 ) then
            
                return 10, true
                
            end

            if aiBrain.LandRatio <= 1.0  then
	
                return (builder.OldPriority or builder.Priority) + 100, true	

            end
    
            local threat = GetThreatAtPosition( aiBrain, GetPosition(unit), ScenarioInfo.IMAPBlocks, true, 'AntiSurface' )

            if threat > 175 then

                return (builder.OldPriority or builder.Priority) + 100, true
        
            elseif threat < 30 then
            
                return (builder.OldPriority or builder.Priority) - 50, true
                
            end
    
            return (builder.OldPriority or builder.Priority), true
        end,
		
        BuilderConditions = {
            { MIBC, 'BaseInPlayableArea', { 'LocationType' }},

			{ EBC, 'GreaterThanEconStorageCurrent', { 400, 5000 }},

            { EBC, 'GreaterThanEconTrendEfficiencyOverTime', { 1, 50, 1.012, 1.025 }},
        },
		
        BuilderType = {'T2','T3'},
		
        BuilderData = {
            Construction = {
				NearBasePerimeterPoints = true,
                
				ThreatMax = 75,
				
				BaseTemplateFile = '/lua/ai/aibuilders/Loud_MAIN_Base_templates.lua',
				BaseTemplate = 'BaseDefenseLayout',
				
                BuildStructures = {'T2Artillery'},
            }
	    }
    },		

    -- this artillery is built in the core - not the defense boxes
    Builder {BuilderName = 'T2 Artillery - Base Template - Core',
	
        PlatoonTemplate = 'EngineerBuilder',
        
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
		
        Priority = 740,

        PriorityFunction = function( builder, aiBrain, unit, manager )
        
            if aiBrain.LandRatio >= 3.0 or GetArmyUnitCostTotal(aiBrain.ArmyIndex) / GetArmyUnitCap(aiBrain.ArmyIndex) > .80 or not GreaterThanEnergyIncome( aiBrain, 12600 ) then
            
                return 10, true
               
            end
            
            if UnitsGreaterAtLocationInRange( aiBrain, manager.LocationType, 9, categories.ARTILLERY * categories.STRUCTURE * categories.TECH2, 10, 20 ) then
            
                return 10, true
                
            end

            if aiBrain.LandRatio <= 1.0  then
	
                return (builder.OldPriority or builder.Priority) + 100, true	

            end
    
            local threat = GetThreatAtPosition( aiBrain, GetPosition(unit), ScenarioInfo.IMAPBlocks, true, 'AntiSurface' )

            if threat > 175 then

                return (builder.OldPriority or builder.Priority) + 100, true
        
            end
    
            return (builder.OldPriority or builder.Priority), true
        end,

        BuilderConditions = {
            { MIBC, 'BaseInPlayableArea', { 'LocationType' }},			

			{ EBC, 'GreaterThanEconStorageCurrent', { 400, 5000 }},

            { EBC, 'GreaterThanEconTrendEfficiencyOverTime', { 0.9, 20, 1.012, 1.02 }},
        },
		
        BuilderType = {'T2','T3'},
		
        BuilderData = {
            Construction = {
				NearBasePerimeterPoints = true,
				ThreatMax = 100,
				
				BaseTemplateFile = '/lua/ai/aibuilders/Loud_MAIN_Base_templates.lua',
				BaseTemplate = 'SupportLayout',
				
                BuildStructures = {'T2Artillery'},
            }
	    }
    },
	
    Builder {BuilderName = 'T2 TML - Base Template - Core',
	
        PlatoonTemplate = 'EngineerBuilder',
        
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
		
        Priority = 740,

        PriorityFunction = function( builder, aiBrain, unit, manager )
         
            if aiBrain.LandRatio >= 2.0 or GetArmyUnitCostTotal(aiBrain.ArmyIndex) / GetArmyUnitCap(aiBrain.ArmyIndex) > .80 or not GreaterThanEnergyIncome( aiBrain, 12600 ) then
            
                return 10, true
               
            end
            
            if UnitsGreaterAtLocationInRange( aiBrain, manager.LocationType, 5, categories.TACTICALMISSILEPLATFORM * categories.STRUCTURE, 10, 20 ) then
            
                return 10, true
                
            end

            if aiBrain.LandRatio <= 1.0  then
	
                return (builder.OldPriority or builder.Priority) + 100, true	

            end
    
            local threat = GetThreatAtPosition( aiBrain, GetPosition(unit), ScenarioInfo.IMAPBlocks, true, 'AntiSurface' )

            if threat > 175 then

                return (builder.OldPriority or builder.Priority) + 100, true
        
            end
    
            return (builder.OldPriority or builder.Priority), true
        end,
        
        BuilderConditions = {
            { MIBC, 'BaseInPlayableArea', { 'LocationType' }},			

			{ EBC, 'GreaterThanEconStorageCurrent', { 400, 5000 }},

            { EBC, 'GreaterThanEconTrendEfficiencyOverTime', { 1, 30, 1.012, 1.02 }}, 

			{ TBC, 'ThreatCloserThan', { 'LocationType', 350, 75, 'AntiSurface' }},
        },
		
        BuilderType = {'T2','T3','SubCommander' },
		
        BuilderData = {
            Construction = {
                NearBasePerimeterPoints = true,
				
				ThreatMax = 100,
				
				BaseTemplateFile = '/lua/ai/aibuilders/Loud_MAIN_Base_templates.lua',
				BaseTemplate = 'SupportLayout',
				
                BuildStructures = {'T2StrategicMissile','T2StrategicMissile'},
            }
        }
    },

    Builder {BuilderName = 'T3 Teleport Jamming',
	
        PlatoonTemplate = 'EngineerBuilder',
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
		
        Priority = 745,

        PriorityFunction = function( builder, aiBrain, unit, manager )
         
            if GetArmyUnitCostTotal(aiBrain.ArmyIndex) / GetArmyUnitCap(aiBrain.ArmyIndex) > .80 or not GreaterThanEnergyIncome( aiBrain, 16800 ) then
            
                return 10, true
               
            end
            
            if UnitsGreaterAtLocation( aiBrain, manager.LocationType, 3, categories.ANTITELEPORT * categories.STRUCTURE * categories.TECH3 ) then
            
                return 10, true
                
            end
    
            return (builder.OldPriority or builder.Priority), true
        end,
		
        BuilderConditions = {
            { MIBC, 'BaseInPlayableArea', { 'LocationType' }},

			{ EBC, 'GreaterThanEconStorageCurrent', { 400, 5000 }},

            { EBC, 'GreaterThanEconTrendEfficiencyOverTime', { 1, 50, 1.012, 1.02 }}, 
        },
		
        BuilderType = {'T3','SubCommander'},
		
        BuilderData = {
		
			Construction = {
				NearBasePerimeterPoints = true,
				ThreatMax = 35,				

				BaseTemplateFile = '/lua/ai/aibuilders/Loud_MAIN_Base_templates.lua',
				BaseTemplate = 'BaseDefenseLayout',
                
                BuildStructures = {'T3TeleportJammer'},
            }
        }
    },	
	
    Builder {BuilderName = 'T3 Tactical Artillery - Boxes',
	
        PlatoonTemplate = 'EngineerBuilder',
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
		
        Priority = 745,

        PriorityFunction = function( builder, aiBrain, unit, manager )
         
            if aiBrain.LandRatio >= 2.0 or GetArmyUnitCostTotal(aiBrain.ArmyIndex) / GetArmyUnitCap(aiBrain.ArmyIndex) > .95 or not GreaterThanEnergyIncome( aiBrain, 16800 ) then
            
                return 10, true
               
            end
            
            if UnitsGreaterAtLocation( aiBrain, manager.LocationType, 3, categories.ARTILLERY * categories.TACTICAL ) then
            
                return 10, true
                
            end

            local threat = GetThreatAtPosition( aiBrain, GetPosition(unit), ScenarioInfo.IMAPBlocks, true, 'AntiSurface' )

            if threat > 175 then

                return (builder.OldPriority or builder.Priority) + 100, true
        
            end
    
            return (builder.OldPriority or builder.Priority), true
        end,

        BuilderConditions = {
            { MIBC, 'BaseInPlayableArea', { 'LocationType' }},

			{ EBC, 'GreaterThanEconStorageCurrent', { 400, 5000 }},

            { EBC, 'GreaterThanEconTrendEfficiencyOverTime', { 1, 30, 1.01, 1.02 }}, 

			{ TBC, 'ThreatCloserThan', { 'LocationType', 350, 75, 'AntiSurface' }},

            { UCBC, 'UnitsLessAtLocation', { 'LocationType', 4, categories.ARTILLERY * categories.TACTICAL }},
        },
		
        BuilderType = {'T3','SubCommander'},
		
        BuilderData = {
		
			DesiresAssist = true,
            NumAssistees = 2,

			Construction = {
				NearBasePerimeterPoints = true,
				ThreatMax = 100,				

				BaseTemplateFile = '/lua/ai/aibuilders/Loud_MAIN_Base_templates.lua',
				BaseTemplate = 'BaseDefenseLayout',
                
                BuildStructures = {'T3TacticalArtillery'},
            }
        }
    },	

	-- setup so that we always build one
    Builder {BuilderName = 'AntiNuke',
	
        PlatoonTemplate = 'EngineerBuilder',
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
		
        Priority = 900,
        
        PriorityFunction = function( self, aiBrain, unit, manager)

            if GreaterThanEnergyIncome( aiBrain, 12600) and UnitsLessAtLocation( aiBrain, manager.LocationType, 1, SMD) then
                return (self.OldPriority or self.Priority), true
            else
                return 10, true
            end
        
        end,

        BuilderConditions = {
            { MIBC, 'BaseInPlayableArea', { 'LocationType' }},        

			{ EBC, 'GreaterThanEnergyTrendOverTime', { 260 }},            
        },
		
        BuilderType = {'SubCommander'},
		
        BuilderData = {
			DesiresAssist = true,
			
            Construction = {
				BasePerimeterOrientation = 'FRONT',			
				NearBasePerimeterPoints = true,
				ThreatMax = 50,

				BaseTemplateFile = '/lua/ai/aibuilders/Loud_MAIN_Base_templates.lua',
				BaseTemplate = 'BaseDefenseLayout',
				
                BuildStructures = {'T3StrategicMissileDefense'},
            }
        }
    },
	
	-- and build more if enemy has more than 1
    Builder {BuilderName = 'AntiNuke - Response',
	
        PlatoonTemplate = 'EngineerBuilder',
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
		
        Priority = 910,
        
        PriorityFunction = function( self, aiBrain, unit, manager)
        
            if GreaterThanEnergyIncome( aiBrain, 12600) and UnitsGreaterAtLocation( aiBrain, manager.LocationType, 0, SMD) then
            
                if import(UCBC).HaveGreaterThanUnitsWithCategoryAndAlliance( aiBrain, 1, categories.NUKE * categories.SILO * categories.STRUCTURE,'Enemy') then
                    return (self.OldPriority or self.Priority), true
                end
            else
                return 10, true
            end
        
        end,
		
        BuilderConditions = {
            { MIBC, 'BaseInPlayableArea', { 'LocationType' }},        
            
			{ EBC, 'GreaterThanEnergyTrendOverTime', { 260 }},            

            { UCBC, 'UnitsLessAtLocationInRange', { 'LocationType', 4, SMD, 5, 45 }},
        },
		
        BuilderType = {'SubCommander'},
		
        BuilderData = {
			DesiresAssist = true,
			
            Construction = {
				NearBasePerimeterPoints = true,
				ThreatMax = 75,
				
				BaseTemplateFile = '/lua/ai/aibuilders/Loud_MAIN_Base_templates.lua',
				BaseTemplate = 'BaseDefenseLayout',
				
                BuildStructures = {'T3StrategicMissileDefense'},
            }
        }
    },
	
    Builder {BuilderName = 'Experimental PD',
	
        PlatoonTemplate = 'EngineerBuilder',
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
		
        Priority = 750,

        PriorityFunction = function( builder, aiBrain, unit, manager )
        
            if aiBrain.LandRatio >= 2.0 or GetArmyUnitCostTotal(aiBrain.ArmyIndex) / GetArmyUnitCap(aiBrain.ArmyIndex) > .95 or not GreaterThanEnergyIncome( aiBrain, 18600 ) then
            
                return 10, true
               
            end
            
            if UnitsGreaterAtLocationInRange( aiBrain, manager.LocationType, 3, PD * categories.EXPERIMENTAL, 10, 42 ) then
            
                return 10, true
                
            end

            if aiBrain.LandRatio <= 1.0  then
	
                return (builder.OldPriority or builder.Priority) + 100, true	

            end
    
            local threat = GetThreatAtPosition( aiBrain, GetPosition(unit), ScenarioInfo.IMAPBlocks, true, 'AntiSurface' )

            if threat > 175 then

                return (builder.OldPriority or builder.Priority) + 100, true
        
            end
    
            return (builder.OldPriority or builder.Priority), true
        end,
		
        BuilderConditions = {
            { MIBC, 'BaseInPlayableArea', { 'LocationType' }},

			{ EBC, 'GreaterThanEconStorageCurrent', { 400, 5000 }},

            { EBC, 'GreaterThanEconTrendEfficiencyOverTime', { 1.5, 100, 1.012, 1.02 }},

			{ TBC, 'ThreatCloserThan', { 'LocationType', 350, 75, 'AntiSurface' }},

        },
		
        BuilderType = {'SubCommander'},
		
        BuilderData = {
			DesiresAssist = true,
			NumAssistees = 4,
			
            Construction = {
				NearBasePerimeterPoints = true,
				ThreatMax = 100,

				BaseTemplateFile = '/lua/ai/aibuilders/Loud_MAIN_Base_templates.lua',
				BaseTemplate = 'BaseDefenseLayout',
				
                BuildStructures = {'T4GroundDefense'},
            }
        }
    },

    Builder {BuilderName = 'Experimental AA Defense',
	
        PlatoonTemplate = 'EngineerBuilder',
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
        
        Priority = 750,

        PriorityFunction = function( builder, aiBrain, unit, manager )
        
            if aiBrain.AirRatio >= 2.5 or GetArmyUnitCostTotal(aiBrain.ArmyIndex) / GetArmyUnitCap(aiBrain.ArmyIndex) > .95 or not GreaterThanEnergyIncome( aiBrain, 21000 ) then
            
                return 10, true
               
            end
            
            if UnitsGreaterAtLocationInRange( aiBrain, manager.LocationType, 3, AA * categories.EXPERIMENTAL, 10, 40 ) then
            
                return 10, true
                
            end

            if aiBrain.AirRatio <= 1.1 or import(UCBC).HaveGreaterThanUnitsWithCategoryAndAlliance( aiBrain, 0, categories.AIR * categories.EXPERIMENTAL,'Enemy')  then
	
                return (builder.OldPriority or builder.Priority) + 100, true	

            end
    
            local threat = GetThreatAtPosition( aiBrain, GetPosition(unit), ScenarioInfo.IMAPBlocks, true, 'Air' )

            if threat > 200 then

                return (builder.OldPriority or builder.Priority) + 100, true
        
            end
    
            return (builder.OldPriority or builder.Priority), true
        end,
		
        BuilderConditions = {
            { MIBC, 'BaseInPlayableArea', { 'LocationType' }},

			{ EBC, 'GreaterThanEnergyTrendOverTime', { 260 }},            

			{ EBC, 'GreaterThanEconStorageCurrent', { 400, 5000 }},

            { EBC, 'GreaterThanEconTrendEfficiencyOverTime', { 1.5, 50, 1.012, 1.02 }},			
        },
		
        BuilderType = {'SubCommander'},
		
        BuilderData = {
			DesiresAssist = true,
            NumAssistees = 3,
			
            Construction = {
				NearBasePerimeterPoints = true,
				ThreatMax = 75,
				
				BaseTemplateFile = '/lua/ai/aibuilders/Loud_MAIN_Base_templates.lua',
				BaseTemplate = 'BaseDefenseLayout',
				
                BuildStructures = {'T4AADefense'},
            }
        }
    },
}

BuilderGroup {BuilderGroupName = 'Engineer Shield Construction',
    BuildersType = 'EngineerBuilder',
	
    Builder {BuilderName = 'Shields - Core',
    
        PlatoonTemplate = 'EngineerBuilder',
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
        
        Priority = 820,

        PriorityFunction = function( builder, aiBrain, unit, manager )
        
            if GetArmyUnitCostTotal(aiBrain.ArmyIndex) / GetArmyUnitCap(aiBrain.ArmyIndex) > .95 or not GreaterThanEnergyIncome( aiBrain, 12600 ) then
            
                return 10, true
               
            end

            if UnitsGreaterAtLocationInRange( aiBrain, manager.LocationType, 3, SHIELD - categories.ANTIARTILLERY, 5, 16 ) then
            
                return 10, true
             
            end

            if aiBrain.LandRatio <= 1.0 and aiBrain.CycleTime > 900 then
	
                return (builder.OldPriority or builder.Priority) + 100, true	

            end
    
            local threat = GetThreatAtPosition( aiBrain, GetPosition(unit), ScenarioInfo.IMAPBlocks, true, 'AntiSurface' )

            if threat > 50 then

                return (builder.OldPriority or builder.Priority) + 100, true
        
            end
    
            return (builder.OldPriority or builder.Priority), true
        end,

        InstanceCount = 1,
        
        BuilderConditions = {
            { MIBC, 'BaseInPlayableArea', { 'LocationType' }},			

			{ EBC, 'GreaterThanEconStorageCurrent', { 400, 5000 }},

			{ EBC, 'GreaterThanEconTrendEfficiencyOverTime', { 0.8, 15, 1.01, 1.02 }},

			{ UCBC, 'UnitsGreaterAtLocation', { 'LocationType', 3, FACTORY}},
        },
		
        BuilderType = {'T2','T3','SubCommander'},
		
        BuilderData = {
			DesiresAssist = true,
            
            Construction = {
				NearBasePerimeterPoints = true,
                
				BaseTemplateFile = '/lua/ai/aibuilders/Loud_MAIN_Base_templates.lua',
				BaseTemplate = 'ShieldLayoutInner',
                
                BuildStructures = {'T2ShieldDefense','EnergyStorage','EnergyStorage','EnergyStorage'},
            }
        }
    },
	
    Builder {BuilderName = 'Shields - Outer',
    
        PlatoonTemplate = 'EngineerBuilder',
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
        
        Priority = 800,

        PriorityFunction = function( builder, aiBrain, unit, manager )
        
            if GetArmyUnitCostTotal(aiBrain.ArmyIndex) / GetArmyUnitCap(aiBrain.ArmyIndex) > .95 or not GreaterThanEnergyIncome( aiBrain, 16800 ) then
            
                return 10, true
               
            end

            if UnitsLessAtLocationInRange( aiBrain, manager.LocationType, 4, SHIELD - categories.ANTIARTILLERY, 5, 16 ) then
            
                return 10, true
             
            end

            if UnitsGreaterAtLocationInRange( aiBrain, manager.LocationType, 7, SHIELD - categories.ANTIARTILLERY, 16, 45 ) then
            
                return 10, true
             
            end

            if aiBrain.LandRatio <= 1.0 and aiBrain.CycleTime > 900 then
	
                return (builder.OldPriority or builder.Priority) + 100, true	

            end
    
            local threat = GetThreatAtPosition( aiBrain, GetPosition(unit), ScenarioInfo.IMAPBlocks, true, 'AntiSurface' )

            if threat > 50 then

                return (builder.OldPriority or builder.Priority) + 100, true
        
            end
    
            return (builder.OldPriority or builder.Priority), true
        end,

		InstanceCount = 1,
        
        BuilderConditions = {
            { MIBC, 'BaseInPlayableArea', { 'LocationType' }},

			{ EBC, 'GreaterThanEconStorageCurrent', { 400, 5000 }},

			{ EBC, 'GreaterThanEconTrendEfficiencyOverTime', { 1, 50, 1.012, 1.02 }},
        },
		
        BuilderType = {'T3','SubCommander'},
		
        BuilderData = {
			DesiresAssist = true,
            
            Construction = {
				NearBasePerimeterPoints = true,
				MaxThreat = 75,
                
				BaseTemplateFile = '/lua/ai/aibuilders/Loud_MAIN_Base_templates.lua',
				BaseTemplate = 'ShieldLayout',
                
                BuildStructures = {'T3ShieldDefense','EnergyStorage','EnergyStorage','EnergyStorage'},
            }
        }
    },

	Builder {BuilderName = 'Shield Augmentations',
    
        PlatoonTemplate = 'EngineerBuilder',
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
        
        Priority = 745,
        
        PriorityFunction = AboveUnitCap75,
		
		InstanceCount = 2,
        
        BuilderConditions = {
            { MIBC, 'BaseInPlayableArea', { 'LocationType' }},			

			{ EBC, 'GreaterThanEconStorageCurrent', { 400, 5000 }},

            { EBC, 'GreaterThanEconEfficiencyOverTime', { 1.05, 1.1 }},

			{ UCBC, 'UnitsGreaterAtLocationInRange', { 'LocationType', 10, SHIELD - categories.ANTIARTILLERY, 0,45 }},
        },
		
        BuilderType = {'T3','SubCommander'},
		
        BuilderData = {
            Construction = {
				NearBasePerimeterPoints = true,
                
				BaseTemplateFile = '/lua/ai/aibuilders/Loud_MAIN_Base_templates.lua',
				BaseTemplate = 'ShieldLayout',
                
                BuildStructures = {'EnergyStorage'},
            }
        }
    },

    Builder {BuilderName = 'T3 Artillery Defense Shield - UEF',
	
        PlatoonTemplate = 'EngineerBuilder',
        
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
        
        FactionIndex = 1,
        
        Priority = 800,
        
        PriorityFunction = function( self, aiBrain, unit, manager)
        
            if GetArmyUnitCostTotal(aiBrain.ArmyIndex) / GetArmyUnitCap(aiBrain.ArmyIndex) > .90 or not GreaterThanEnergyIncome( aiBrain, 18900 ) then
            
                return 10, true
               
            end

            if UnitsLessAtLocation( aiBrain, manager.LocationType, 9, SHIELD - categories.ANTIARTILLERY ) then
            
                return 10, true
             
            end

            if UnitsGreaterAtLocation( aiBrain, manager.LocationType, 2, SHIELD * categories.ANTIARTILLERY ) then
            
                return 10, true
             
            end
    
            return (self.OldPriority or self.Priority), true        
        end,

        BuilderConditions = {
            { MIBC, 'BaseInPlayableArea', { 'LocationType' }},

			{ EBC, 'GreaterThanEconStorageCurrent', { 400, 5000 }},

			{ EBC, 'GreaterThanEconTrendEfficiencyOverTime', { 1, 50, 1.012, 1.02 }},
        },
		
        BuilderType = {'T3','SubCommander'},
		
        BuilderData = {
			DesiresAssist = true,
            NumAssistees = 1,
			
            Construction = {
				NearBasePerimeterPoints = true,
				MaxThreat = 75,
				
				BaseTemplateFile = '/lua/ai/aibuilders/Loud_MAIN_Base_templates.lua',
				BaseTemplate = 'ShieldLayout',
				
                BuildStructures = {'T3ArtilleryDefenseShield'},
            }
        }
    },
    
    Builder {BuilderName = 'T3 Artillery Defense Shield - Aeon',
	
        PlatoonTemplate = 'EngineerBuilder',
        
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
        
        FactionIndex = 2,
        
        Priority = 800,
        
        PriorityFunction = function( self, aiBrain, unit, manager)
        
            if GetArmyUnitCostTotal(aiBrain.ArmyIndex) / GetArmyUnitCap(aiBrain.ArmyIndex) > .90 or not GreaterThanEnergyIncome( aiBrain, 21000 ) then
                return 10, true
            end

            if UnitsLessAtLocation( aiBrain, manager.LocationType, 9, SHIELD - categories.ANTIARTILLERY ) then
            
                return 10, true
             
            end

            if UnitsGreaterAtLocation( aiBrain, manager.LocationType, 2, SHIELD * categories.ANTIARTILLERY ) then
            
                return 10, true
             
            end
     
            return (self.OldPriority or self.Priority), true        
        end,
		
        BuilderConditions = {
            { MIBC, 'BaseInPlayableArea', { 'LocationType' }},

			{ EBC, 'GreaterThanEconStorageCurrent', { 400, 5000 }},

			{ EBC, 'GreaterThanEconTrendEfficiencyOverTime', { 1, 50, 1.012, 1.02 }},
        },
		
        BuilderType = {'SubCommander'},
		
        BuilderData = {
			DesiresAssist = true,
            NumAssistees = 1,
			
            Construction = {
				NearBasePerimeterPoints = true,
				MaxThreat = 75,
				
				BaseTemplateFile = '/lua/ai/aibuilders/Loud_MAIN_Base_templates.lua',
				BaseTemplate = 'ShieldLayout',
				
                BuildStructures = {'T3ArtilleryDefenseShield'},
            }
        }
    },
    
    Builder {BuilderName = 'T3 Artillery Defense Shield - Cybran',
	
        PlatoonTemplate = 'EngineerBuilder',
        
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
        
        FactionIndex = 3,
        
        Priority = 800,
        
        PriorityFunction = function( self, aiBrain, unit, manager)
        
            if GetArmyUnitCostTotal(aiBrain.ArmyIndex) / GetArmyUnitCap(aiBrain.ArmyIndex) > .90 or not GreaterThanEnergyIncome( aiBrain, 18900 ) then
                return 10, true
            end

            if UnitsLessAtLocation( aiBrain, manager.LocationType, 9, SHIELD - categories.ANTIARTILLERY ) then
            
                return 10, true
             
            end

            if UnitsGreaterAtLocation( aiBrain, manager.LocationType, 2, SHIELD * categories.ANTIARTILLERY ) then
            
                return 10, true
             
            end
    
            return (self.OldPriority or self.Priority), true
        end,

        BuilderConditions = {
            { MIBC, 'BaseInPlayableArea', { 'LocationType' }},

			{ EBC, 'GreaterThanEconStorageCurrent', { 400, 5000 }},

			{ EBC, 'GreaterThanEconTrendEfficiencyOverTime', { 1, 50, 1.012, 1.02 }},
        },
		
        BuilderType = {'T3','SubCommander'},
		
        BuilderData = {
			DesiresAssist = true,
            NumAssistees = 1,
			
            Construction = {
				NearBasePerimeterPoints = true,
				MaxThreat = 75,
				
				BaseTemplateFile = '/lua/ai/aibuilders/Loud_MAIN_Base_templates.lua',
				BaseTemplate = 'ShieldLayout',
				
                BuildStructures = {'T3ArtilleryDefenseShield'},
            }
        }
    },
}

BuilderGroup {BuilderGroupName = 'Engineer Shield Construction - LOUD_IS',
    BuildersType = 'EngineerBuilder',
	
    Builder {BuilderName = 'Shields - Core - IS ',
    
        PlatoonTemplate = 'EngineerBuilder',
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
        
        Priority = 800,

        PriorityFunction = function( builder, aiBrain, unit, manager )
        
            if GetArmyUnitCostTotal(aiBrain.ArmyIndex) / GetArmyUnitCap(aiBrain.ArmyIndex) > .95 or not GreaterThanEnergyIncome( aiBrain, 12600 ) then
            
                return 10, true
               
            end

            if UnitsGreaterAtLocationInRange( aiBrain, manager.LocationType, 3, SHIELD - categories.ANTIARTILLERY, 5, 16 ) then
            
                return 10, true
             
            end

            if aiBrain.LandRatio <= 1.0 and aiBrain.CycleTime > 900 then
	
                return (builder.OldPriority or builder.Priority) + 100, true	

            end
    
            local threat = GetThreatAtPosition( aiBrain, GetPosition(unit), ScenarioInfo.IMAPBlocks, true, 'AntiSurface' )

            if threat > 50 then

                return (builder.OldPriority or builder.Priority) + 100, true
        
            end
    
            return (builder.OldPriority or builder.Priority), true
        end,

		InstanceCount = 1,
		
        BuilderConditions = {
            { MIBC, 'BaseInPlayableArea', { 'LocationType' }},			

			{ EBC, 'GreaterThanEconStorageCurrent', { 400, 5000 }},

			{ EBC, 'GreaterThanEconTrendEfficiencyOverTime', { 0.8, 15, 1.01, 1.02 }},

			{ UCBC, 'UnitsGreaterAtLocation', { 'LocationType', 3, FACTORY}},
        },
		
        BuilderType = {'T2','T3','SubCommander'},
		
        BuilderData = {
			DesiresAssist = true,
            
            Construction = {
				NearBasePerimeterPoints = true,
				MaxThreat = 90,
                
				BaseTemplateFile = '/lua/ai/aibuilders/Loud_MAIN_Base_templates.lua',
				BaseTemplate = 'ShieldLayoutInner',
                
                BuildStructures = {'T2ShieldDefense'},
            }
        }
    },
	
    Builder {BuilderName = 'Shields - Outer - IS',
    
        PlatoonTemplate = 'EngineerBuilder',
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
        
        Priority = 800,

        PriorityFunction = function( builder, aiBrain, unit, manager )
        
            if GetArmyUnitCostTotal(aiBrain.ArmyIndex) / GetArmyUnitCap(aiBrain.ArmyIndex) > .95 or not GreaterThanEnergyIncome( aiBrain, 16800 ) then
            
                return 10, true
               
            end

            if UnitsLessAtLocationInRange( aiBrain, manager.LocationType, 4, SHIELD - categories.ANTIARTILLERY, 5, 16 ) then
            
                return 10, true
             
            end

            if UnitsGreaterAtLocationInRange( aiBrain, manager.LocationType, 7, SHIELD - categories.ANTIARTILLERY, 16, 45 ) then
            
                return 10, true
             
            end

            if aiBrain.LandRatio <= 1.0 and aiBrain.CycleTime > 900 then
	
                return (builder.OldPriority or builder.Priority) + 100, true	

            end
    
            local threat = GetThreatAtPosition( aiBrain, GetPosition(unit), ScenarioInfo.IMAPBlocks, true, 'AntiSurface' )

            if threat > 50 then

                return (builder.OldPriority or builder.Priority) + 100, true
        
            end
    
            return (builder.OldPriority or builder.Priority), true
        end,
		
		InstanceCount = 1,
		
        BuilderConditions = {
            { MIBC, 'BaseInPlayableArea', { 'LocationType' }},

			{ EBC, 'GreaterThanEconStorageCurrent', { 400, 5000 }},

			{ EBC, 'GreaterThanEconTrendEfficiencyOverTime', { 1, 50, 1.012, 1.02 }},
        },
		
        BuilderType = {'T3','SubCommander'},
		
        BuilderData = {
			DesiresAssist = true,
            
            Construction = {
				NearBasePerimeterPoints = true,
				MaxThreat = 75,
                
				BaseTemplateFile = '/lua/ai/aibuilders/Loud_MAIN_Base_templates.lua',
				BaseTemplate = 'ShieldLayout',
                
                BuildStructures = {'T3ShieldDefense'},
            }
        }
    },

    Builder {BuilderName = 'T3 Artillery Defense Shield - UEF - IS',
	
        PlatoonTemplate = 'EngineerBuilder',
        
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
        
        FactionIndex = 1,
        
        Priority = 800,
        
        PriorityFunction = function( self, aiBrain, unit, manager)
        
            if GetArmyUnitCostTotal(aiBrain.ArmyIndex) / GetArmyUnitCap(aiBrain.ArmyIndex) > .90 or not GreaterThanEnergyIncome( aiBrain, 18900 ) then
            
                return 10, true
               
            end

            if UnitsLessAtLocation( aiBrain, manager.LocationType, 9, SHIELD - categories.ANTIARTILLERY ) then
            
                return 10, true
             
            end

            if UnitsGreaterAtLocation( aiBrain, manager.LocationType, 2, SHIELD * categories.ANTIARTILLERY ) then
            
                return 10, true
             
            end
    
            return (self.OldPriority or self.Priority), true        
        end,
		
        BuilderConditions = {
            { MIBC, 'BaseInPlayableArea', { 'LocationType' }},

			{ EBC, 'GreaterThanEconStorageCurrent', { 400, 5000 }},

			{ EBC, 'GreaterThanEconTrendEfficiencyOverTime', { 1, 50, 1.012, 1.02 }},
        },
		
        BuilderType = {'T3','SubCommander'},
		
        BuilderData = {
			DesiresAssist = true,
            NumAssistees = 1,
			
            Construction = {
				NearBasePerimeterPoints = true,
				MaxThreat = 75,
				
				BaseTemplateFile = '/lua/ai/aibuilders/Loud_MAIN_Base_templates.lua',
				BaseTemplate = 'ShieldLayout',
				
                BuildStructures = {'T3ArtilleryDefenseShield'},
            }
        }
    },
    
    Builder {BuilderName = 'T3 Artillery Defense Shield - Aeon - IS',
	
        PlatoonTemplate = 'EngineerBuilder',
        
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
        
        FactionIndex = 2,
        
        Priority = 800,
        
        PriorityFunction = function( self, aiBrain, unit, manager)
        
            if GetArmyUnitCostTotal(aiBrain.ArmyIndex) / GetArmyUnitCap(aiBrain.ArmyIndex) > .90 or not GreaterThanEnergyIncome( aiBrain, 21000 ) then
                return 10, true
            end

            if UnitsLessAtLocation( aiBrain, manager.LocationType, 9, SHIELD - categories.ANTIARTILLERY ) then
            
                return 10, true
             
            end

            if UnitsGreaterAtLocation( aiBrain, manager.LocationType, 2, SHIELD * categories.ANTIARTILLERY ) then
            
                return 10, true
             
            end
     
            return (self.OldPriority or self.Priority), true        
        end,

        BuilderConditions = {
            { MIBC, 'BaseInPlayableArea', { 'LocationType' }},

			{ EBC, 'GreaterThanEconStorageCurrent', { 400, 5000 }},

			{ EBC, 'GreaterThanEconTrendEfficiencyOverTime', { 1, 50, 1.012, 1.02 }},
        },
		
        BuilderType = {'SubCommander'},
		
        BuilderData = {
			DesiresAssist = true,
            NumAssistees = 1,
			
            Construction = {
				NearBasePerimeterPoints = true,
				MaxThreat = 75,
				
				BaseTemplateFile = '/lua/ai/aibuilders/Loud_MAIN_Base_templates.lua',
				BaseTemplate = 'ShieldLayout',
				
                BuildStructures = {'T3ArtilleryDefenseShield'},
            }
        }
    },
    
    Builder {BuilderName = 'T3 Artillery Defense Shield - Cybran - IS',
	
        PlatoonTemplate = 'EngineerBuilder',
        
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
        
        FactionIndex = 3,
        
        Priority = 800,
        
        PriorityFunction = function( self, aiBrain, unit, manager)
        
            if GetArmyUnitCostTotal(aiBrain.ArmyIndex) / GetArmyUnitCap(aiBrain.ArmyIndex) > .90 or not GreaterThanEnergyIncome( aiBrain, 18900 ) then
                return 10, true
            end

            if UnitsLessAtLocation( aiBrain, manager.LocationType, 9, SHIELD - categories.ANTIARTILLERY ) then
            
                return 10, true
             
            end

            if UnitsGreaterAtLocation( aiBrain, manager.LocationType, 2, SHIELD * categories.ANTIARTILLERY ) then
            
                return 10, true
             
            end
    
            return (self.OldPriority or self.Priority), true
        end,
		
        BuilderConditions = {
            { MIBC, 'BaseInPlayableArea', { 'LocationType' }},

			{ EBC, 'GreaterThanEconStorageCurrent', { 400, 5000 }},

			{ EBC, 'GreaterThanEconTrendEfficiencyOverTime', { 1, 50, 1.012, 1.02 }},
        },
		
        BuilderType = {'T3','SubCommander'},
		
        BuilderData = {
			DesiresAssist = true,
            NumAssistees = 1,
			
            Construction = {
				NearBasePerimeterPoints = true,
				MaxThreat = 75,
				
				BaseTemplateFile = '/lua/ai/aibuilders/Loud_MAIN_Base_templates.lua',
				BaseTemplate = 'ShieldLayout',
				
                BuildStructures = {'T3ArtilleryDefenseShield'},
            }
        }
    },
}

BuilderGroup {BuilderGroupName = 'Engineer T4 Shield Construction',
    BuildersType = 'EngineerBuilder',
	
    Builder {BuilderName = 'Experimental Shield',
	
        PlatoonTemplate = 'EngineerBuilder',
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },

		-- this should turn this off if there is less than 30 minutes left in the game
		PriorityFunction = function( self, aiBrain, unit, manager)
			
			if aiBrain.VictoryTime then
			
				if aiBrain.VictoryTime < ( aiBrain.CycleTime + ( 60 * 45 ) ) then	-- less than 45 minutes left
					return 0, false
				end
			end
        
            if GetArmyUnitCostTotal(aiBrain.ArmyIndex) / GetArmyUnitCap(aiBrain.ArmyIndex) > .90 or not GreaterThanEnergyIncome( aiBrain, 50000 ) then
                return 10, true
            end

            if UnitsLessAtLocation( aiBrain, manager.LocationType, 9, SHIELD - categories.ANTIARTILLERY ) then
            
                return 10, true
             
            end

            if UnitsGreaterAtLocation( aiBrain, manager.LocationType, 0, categories.EXPERIMENTAL * categories.SHIELD ) then
            
                return 10, true
             
            end

            return (self.OldPriority or self.Priority), true
		end,
		
        Priority = 745,
		
        BuilderConditions = {
            { MIBC, 'BaseInPlayableArea', { 'LocationType' }},

			{ EBC, 'GreaterThanEconStorageCurrent', { 400, 5000 }},

			{ EBC, 'GreaterThanEconTrendEfficiencyOverTime', { 1.5, 75, 1.012, 1.02 }},

			{ UCBC, 'UnitsGreaterAtLocation', { 'LocationType', 6, ENERGY * categories.TECH3 }},
        },

        BuilderType = {'SubCommander'},

        BuilderData = {
			DesiresAssist = true,
            NumAssistees = 3,

            Construction = {
				NearBasePerimeterPoints = true,
				MaxThreat = 100,

				BaseTemplateFile = '/lua/ai/aibuilders/Loud_MAIN_Base_templates.lua',
				BaseTemplate = 'ShieldLayoutInner',

                BuildStructures = {'T4ShieldDefense'},
            }
        }
    },

}

--- AIRSTAGING, etc. --
BuilderGroup {BuilderGroupName = 'Engineer Misc Construction',
    BuildersType = 'EngineerBuilder',
	
    Builder {BuilderName = 'Air Staging T1',
	
        PlatoonTemplate = 'EngineerBuilder',
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
		
        Priority = 850,
        
        PriorityFunction = function( self, aiBrain, unit, manager)
        
            if GetArmyUnitCostTotal(aiBrain.ArmyIndex) / GetArmyUnitCap(aiBrain.ArmyIndex) > .85 then
                return 10, true
            end

            if UnitsGreaterAtLocation( aiBrain, manager.LocationType, 0, categories.AIRSTAGINGPLATFORM ) then
            
                return 10, true
             
            end
    
            return (self.OldPriority or self.Priority), true
        end,

        BuilderConditions = {
			{ EBC, 'GreaterThanEconStorageCurrent', { 300, 3000 }},
            { LUTL, 'FactoryGreaterAtLocation', { 'LocationType', 0, FACTORY * categories.AIR }},
        },
		
        BuilderType = {'T1' },
		
        BuilderData = {
			DesiresAssist = false,
			
			Construction = {
				Radius = 50,			
                NearBasePerimeterPoints = true,
				
				ThreatMax = 50,
				
				BasePerimeterOrientation = 'REAR',
				BasePerimeterSelection = 2,

				BaseTemplateFile = '/lua/ai/aibuilders/Loud_MAIN_Base_templates.lua',
				BaseTemplate = 'T3AirStagingComplex',
				
                BuildStructures = {'T1AirStagingPlatform'},
            }
        }
    },		

    Builder {BuilderName = 'Air Staging T2',
	
        PlatoonTemplate = 'EngineerBuilder',
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
		
        Priority = 850,
        
        PriorityFunction = function( self, aiBrain, unit, manager)
        
            if GetArmyUnitCostTotal(aiBrain.ArmyIndex) / GetArmyUnitCap(aiBrain.ArmyIndex) > .85 then
                return 10, true
            end

            if UnitsGreaterAtLocation( aiBrain, manager.LocationType, 0, categories.AIRSTAGINGPLATFORM * categories.TECH2 ) then
            
                return 10, true
             
            end
    
            return (self.OldPriority or self.Priority), true
        end,

        BuilderConditions = {
			{ EBC, 'GreaterThanEconStorageCurrent', { 300, 3000 }},
        },
		
        BuilderType = {'T2','T3','SubCommander'},
		
        BuilderData = {
			DesiresAssist = false,
			
			Construction = {
				Radius = 50,			
                NearBasePerimeterPoints = true,
				
				ThreatMax = 50,
				
				BasePerimeterOrientation = 'REAR',
				BasePerimeterSelection = 2,

				BaseTemplateFile = '/lua/ai/aibuilders/Loud_MAIN_Base_templates.lua',
				BaseTemplate = 'T3AirStagingComplex',
				
                BuildStructures = {'T2AirStagingPlatform'},
            }
        }
    },	
}

--- this tucks the Airpad in tighter at the back centre of the base - next to the Gate
BuilderGroup {BuilderGroupName = 'Engineer Misc Construction - Small',
    BuildersType = 'EngineerBuilder',
	
    Builder {BuilderName = 'Air Staging T1 - Small Base',
	
        PlatoonTemplate = 'EngineerBuilder',
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
		
        Priority = 850,
        
        PriorityFunction = function( self, aiBrain, unit, manager)
        
            if GetArmyUnitCostTotal(aiBrain.ArmyIndex) / GetArmyUnitCap(aiBrain.ArmyIndex) > .85 then
                return 10, true
            end

            if UnitsGreaterAtLocation( aiBrain, manager.LocationType, 0, categories.AIRSTAGINGPLATFORM ) then
            
                return 10, true
             
            end
    
            return (self.OldPriority or self.Priority), true
        end,

        BuilderConditions = {
			{ EBC, 'GreaterThanEconStorageCurrent', { 300, 3000 }},
            { LUTL, 'FactoryGreaterAtLocation', { 'LocationType', 0, FACTORY * categories.AIR }},
        },
		
        BuilderType = {'T1'},
		
        BuilderData = {
			DesiresAssist = false,
			
			Construction = {
				Radius = 26,			
                NearBasePerimeterPoints = true,
                
                ThreatMax = 50,
				
				BasePerimeterOrientation = 'REAR',
				BasePerimeterSelection = 2,

				BaseTemplateFile = '/lua/ai/aibuilders/Loud_MAIN_Base_templates.lua',
				BaseTemplate = 'T3AirStagingComplex',
				
                BuildStructures = {'T1AirStagingPlatform'},
            }
        }
    },	
	
    Builder {BuilderName = 'Air Staging T2 - Small Base',
	
        PlatoonTemplate = 'EngineerBuilder',
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
		
        Priority = 850,
        
        PriorityFunction = function( self, aiBrain, unit, manager)
        
            if GetArmyUnitCostTotal(aiBrain.ArmyIndex) / GetArmyUnitCap(aiBrain.ArmyIndex) > .85 then
                return 10, true
            end

            if UnitsGreaterAtLocation( aiBrain, manager.LocationType, 0, categories.AIRSTAGINGPLATFORM * categories.TECH2 ) then
            
                return 10, true
             
            end
    
            return (self.OldPriority or self.Priority), true
        end,

        BuilderConditions = {
			{ EBC, 'GreaterThanEconStorageCurrent', { 300, 3000 }},
        },
		
        BuilderType = {'T2','T3'},
		
        BuilderData = {
			DesiresAssist = false,
			
			Construction = {
				Radius = 26,			
                NearBasePerimeterPoints = true,
                
                ThreatMax = 50,
				
				BasePerimeterOrientation = 'REAR',
				BasePerimeterSelection = 2,

				BaseTemplateFile = '/lua/ai/aibuilders/Loud_MAIN_Base_templates.lua',
				BaseTemplate = 'T3AirStagingComplex',
				
                BuildStructures = {'T2AirStagingPlatform'},
            }
        }
    },	
	
}

--- PERIMETER -- 
BuilderGroup {BuilderGroupName = 'Engineer Base Defense Construction - Perimeter',
    BuildersType = 'EngineerBuilder',
	
    Builder {BuilderName = 'T1 Perimeter PD - Small Map',
	
        PlatoonTemplate = 'EngineerBuilder',
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
		
		InstanceCount = 1,
		
        Priority = 745,
	
		PriorityFunction = function(self, aiBrain)
			
			if self.Priority != 0 then
			
				if (ScenarioInfo.size[1] >= 1028 or ScenarioInfo.size[2] >= 1028) then
					return 0, false
				end
        
                if not GreaterThanEnergyIncome( aiBrain, 550 ) then
                    return 10, true
                end
   				
				-- remove after 25 minutes
				if aiBrain.CycleTime > 1500 then
					return 0, false
				end
                
                if aiBrain.LandRatio < 1 and aiBrain.CycleTime > 300 then
                    return (self.OldPriority or self.Priority) + 100, true
                end
				
			end
			
			return self.Priority
			
		end,
		
        BuilderConditions = {
            { MIBC, 'BaseInPlayableArea', { 'LocationType' }},

			{ EBC, 'GreaterThanEconStorageCurrent', { 300, 3000 }},
            
            { EBC, 'GreaterThanEconTrendEfficiencyOverTime', { 0.8, 15, 1.01, 1.02 }},

			-- dont have any advanced power built -- makes this gun obsolete
			{ UCBC, 'UnitsLessAtLocation', { 'LocationType', 1, ENERGY - categories.TECH1 }},
            
			-- the 12 accounts for the 12 T1 Base PD that may get built in this ring
			{ UCBC, 'UnitsLessAtLocationInRange', { 'LocationType', 18, PD, 50, 75}},
        },
		
        BuilderType = { 'T1' },
		
        BuilderData = {
            Construction = {
			
				Radius = 51,
                NearBasePerimeterPoints = true,
				
				BasePerimeterOrientation = 'ALL',
				BasePerimeterSelection = true,
				
				BaseTemplateFile = '/lua/ai/aibuilders/loud_perimeter_defense_templates.lua',
				BaseTemplate = 'PerimeterDefenseTemplates',
				
                BuildStructures = {'T1GroundDefense','T1Artillery'},
            }
        }
    },

    Builder {BuilderName = 'T1 Perimeter PD - Large Map',
	
        PlatoonTemplate = 'EngineerBuilder',
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
		
		InstanceCount = 1,
		
        Priority = 700,
		
		PriorityFunction = function(self, aiBrain)

			if self.Priority != 0 then
			
				if (ScenarioInfo.size[1] <= 1028 or ScenarioInfo.size[2] <= 1028) then
					return 0, false
				end
				
				-- remove after 25 minutes
				if aiBrain.CycleTime > 1500 then
					return 0, false
				end
        
                if not GreaterThanEnergyIncome( aiBrain, 550 ) then
                    return 10, true
                end
                
                if aiBrain.LandRatio < 1.5 and aiBrain.CycleTime > 480 then
                    return (self.OldPriority or self.Priority) + 100, true
                end
				
			end
			
			return self.Priority		
			
		end,
		
        BuilderConditions = {
            { MIBC, 'BaseInPlayableArea', { 'LocationType' }},

			{ EBC, 'GreaterThanEconStorageCurrent', { 300, 3000 }},

            { EBC, 'GreaterThanEconTrendEfficiencyOverTime', { 0.8, 15, 1.01, 1.02 }},

			-- dont have any advanced units
			{ UCBC, 'UnitsLessAtLocation', { 'LocationType', 1, categories.STRUCTURE - categories.TECH1 }},

			{ UCBC, 'UnitsLessAtLocation', { 'LocationType', 18, PD}},
        },
		
        BuilderType = { 'T1' },
		
        BuilderData = {
		
            Construction = {
				Radius = 51,
                NearBasePerimeterPoints = true,
				
				BasePerimeterSelection = true,
				BasePerimeterOrientation = 'FRONT',
				
				BaseTemplateFile = '/lua/ai/aibuilders/loud_perimeter_defense_templates.lua',
				BaseTemplate = 'PerimeterDefenseTemplates',
				
                BuildStructures = {'T1GroundDefense'},
            }
        }
    },
	
    Builder {BuilderName = 'T1 Perimeter - AA',
	
        PlatoonTemplate = 'EngineerBuilder',
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
		
		InstanceCount = 1,
		
        Priority = 10,

		PriorityFunction = function(self, aiBrain)
		
			-- remove after 25 minutes
			if aiBrain.CycleTime > 1500 then
				return 0, false
			end
			
			-- turn on after 6 minutes
			if aiBrain.CycleTime > 360 then
				return 800, false
			end

			return self.Priority
			
		end,
		
        BuilderConditions = {
            { LUTL, 'AirStrengthRatioLessThan', { 1.5 }},

            { MIBC, 'BaseInPlayableArea', { 'LocationType' }},            

			{ EBC, 'GreaterThanEconStorageCurrent', { 250, 2500 }},

			-- dont have any advanced units
			{ UCBC, 'UnitsLessAtLocation', { 'LocationType', 1, categories.STRUCTURE - categories.TECH1 }},

			{ UCBC, 'UnitsLessAtLocationInRange', { 'LocationType', 18, AA, 45, 75}},
        },
		
        BuilderType = { 'T1' },
		
        BuilderData = {
			DesiresAssist = true,
            NumAssistees = 2,
			
            Construction = {
				Radius = 51,
                NearBasePerimeterPoints = true,
				
				BasePerimeterOrientation = 'FRONT',
				BasePerimeterSelection = true,
				
				BaseTemplateFile = '/lua/ai/aibuilders/loud_perimeter_defense_templates.lua',
				BaseTemplate = 'PerimeterDefenseTemplates',
				
                BuildStructures = {'T1AADefense'},
            }
        }
    },

    Builder {BuilderName = 'T2 Perimeter TMD',
	
        PlatoonTemplate = 'EngineerBuilder',
        
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
		
		InstanceCount = 1,
		
        Priority = 740,

        PriorityFunction = function( builder, aiBrain, unit, manager )
        
            if aiBrain.LandRatio >= 2.0 or GetArmyUnitCostTotal(aiBrain.ArmyIndex) / GetArmyUnitCap(aiBrain.ArmyIndex) > .75 or not GreaterThanEnergyIncome( aiBrain, 16800 ) then
            
                return 10, true
               
            end
            
            if UnitsGreaterAtLocationInRange( aiBrain, manager.LocationType, 9, TMD, 56, 80 ) then
            
                return 10, true
                
            end

            local threat = GetThreatAtPosition( aiBrain, GetPosition(unit), ScenarioInfo.IMAPBlocks, true, 'AntiSurface' )

            if threat > 175 then

                return (builder.OldPriority or builder.Priority) + 100, true
        
            end
    
            return (builder.OldPriority or builder.Priority), true
        end,
		
        BuilderConditions = {
            { MIBC, 'BaseInPlayableArea', { 'LocationType' }},

			{ EBC, 'GreaterThanEconStorageCurrent', { 400, 5000 }},

			{ TBC, 'ThreatCloserThan', { 'LocationType', 350, 75, 'AntiSurface' }},
        },
		
		BuilderType = { 'T2' },

        BuilderData = {
            Construction = {
				Radius = 68,
                NearBasePerimeterPoints = true,
				
				BasePerimeterOrientation = 'FRONT',
				BasePerimeterSelection = true,
				
				BaseTemplateFile = '/lua/ai/aibuilders/loud_perimeter_defense_templates.lua',
				BaseTemplate = 'PerimeterDefenseTemplates',
				
                BuildStructures = {'T2MissileDefense'},
            }
        }
    },
	
    Builder {BuilderName = 'T2 Perimeter Artillery',
	
        PlatoonTemplate = 'EngineerBuilder',
        
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
		
		InstanceCount = 1,
        
        Priority = 740,

        PriorityFunction = function( builder, aiBrain, unit, manager )
        
            if aiBrain.LandRatio >= 2.0 or GetArmyUnitCostTotal(aiBrain.ArmyIndex) / GetArmyUnitCap(aiBrain.ArmyIndex) > .75 or not GreaterThanEnergyIncome( aiBrain, 16800 ) then
            
                return 10, true
               
            end
            
            if UnitsGreaterAtLocationInRange( aiBrain, manager.LocationType, 26, categories.STRUCTURE * categories.ARTILLERY * categories.TECH2, 55, 83 ) then
            
                return 10, true
                
            end

            local threat = GetThreatAtPosition( aiBrain, GetPosition(unit), ScenarioInfo.IMAPBlocks, true, 'AntiSurface' )

            if threat > 175 then

                return (builder.OldPriority or builder.Priority) + 100, true
        
            end
    
            return (builder.OldPriority or builder.Priority), true
        end,

        BuilderConditions = {
            { MIBC, 'BaseInPlayableArea', { 'LocationType' }},

			{ EBC, 'GreaterThanEconStorageCurrent', { 400, 5000 }},

			{ EBC, 'GreaterThanEconTrendEfficiencyOverTime', { 1, 30, 1.01, 1.02 }},

			{ TBC, 'ThreatCloserThan', { 'LocationType', 350, 75, 'AntiSurface' }},
        },
		
		BuilderType = { 'T3','SubCommander' },

        BuilderData = {
			DesiresAssist = true,
            NumAssistees = 2,
            
            Construction = {
				Radius = 68,
                NearBasePerimeterPoints = true,
                
                ThreatMax = 75,
				
				BasePerimeterOrientation = 'FRONT',
				BasePerimeterSelection = true,

				BaseTemplateFile = '/lua/ai/aibuilders/loud_perimeter_defense_templates.lua',
				BaseTemplate = 'PerimeterDefenseTemplates',
				
                BuildStructures = {'T2Artillery'},
            }
        }
    },

    Builder {BuilderName = 'T3 Perimeter PD',
	
        PlatoonTemplate = 'EngineerBuilder',
        
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
		
		InstanceCount = 2,
		
        Priority = 750,

        PriorityFunction = function( builder, aiBrain, unit, manager )
        
            if aiBrain.LandRatio >= 1.2 or GetArmyUnitCostTotal(aiBrain.ArmyIndex) / GetArmyUnitCap(aiBrain.ArmyIndex) > .95 or not GreaterThanEnergyIncome( aiBrain, 16800 ) then
            
                return 10, true
               
            end
            
            if UnitsGreaterAtLocationInRange( aiBrain, manager.LocationType, 17, PD * categories.TECH3, 56, 80 ) then
            
                return 10, true
                
            end

            local threat = GetThreatAtPosition( aiBrain, GetPosition(unit), ScenarioInfo.IMAPBlocks, true, 'AntiSurface' )

            if threat > 175 then

                return (builder.OldPriority or builder.Priority) + 100, true
        
            end
    
            return (builder.OldPriority or builder.Priority), true
        end,
		
        BuilderConditions = {
            { MIBC, 'BaseInPlayableArea', { 'LocationType' }},            

			{ EBC, 'GreaterThanEconStorageCurrent', { 400, 5000 }},

            { EBC, 'GreaterThanEconTrendEfficiencyOverTime', { 1, 30, 1.012, 1.02 }}, 
        },
		
		BuilderType = { 'SubCommander' },

        BuilderData = {
			DesiresAssist = true,
            NumAssistees = 2,
			
            Construction = {
				Radius = 68,
                NearBasePerimeterPoints = true,
                
				ThreatMax = 100,	

				BasePerimeterOrientation = 'FRONT',
				BasePerimeterSelection = true,
				
				BaseTemplateFile = '/lua/ai/aibuilders/loud_perimeter_defense_templates.lua',
				BaseTemplate = 'PerimeterDefenseTemplates',
				
                BuildStructures = {'T3GroundDefense'},
            }
        }
    },
	
    Builder {BuilderName = 'T3 Perimeter AA',
	
        PlatoonTemplate = 'EngineerBuilder',
        
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
		
		InstanceCount = 2,
		
        Priority = 750,

        PriorityFunction = function( builder, aiBrain, unit, manager )
        
            if aiBrain.AirRatio >= 1.5 or GetArmyUnitCostTotal(aiBrain.ArmyIndex) / GetArmyUnitCap(aiBrain.ArmyIndex) > .80 or not GreaterThanEnergyIncome( aiBrain, 16800 ) then
            
                return 10, true
               
            end
            
            if UnitsGreaterAtLocationInRange( aiBrain, manager.LocationType, 35, AA * categories.TECH3, 56, 80 ) then
            
                return 10, true
                
            end
    
            return (builder.OldPriority or builder.Priority), true
        end,
		
        BuilderConditions = {
            { MIBC, 'BaseInPlayableArea', { 'LocationType' }},

            { EBC, 'GreaterThanEconTrendEfficiencyOverTime', { 2, 30, 1.02, 1.04 }},

			{ EBC, 'GreaterThanEconStorageCurrent', { 400, 5000 }},
        },
		
		BuilderType = { 'T3','SubCommander' },

        BuilderData = {
            Construction = {
				Radius = 68,
                NearBasePerimeterPoints = true,
                
				ThreatMax = 60,	
				
				BasePerimeterOrientation = 'FRONT',
				BasePerimeterSelection = true,
				
				BaseTemplateFile = '/lua/ai/aibuilders/loud_perimeter_defense_templates.lua',
				BaseTemplate = 'PerimeterDefenseTemplates',
				
                BuildStructures = {'T3AADefense'},
            }
        }
    },

    Builder {BuilderName = 'T3 Perimeter TMD',
	
        PlatoonTemplate = 'EngineerBuilder',
        
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
		
		InstanceCount = 1,
		
        Priority = 740,

        PriorityFunction = function( builder, aiBrain, unit, manager )
        
            if aiBrain.LandRatio >= 2.0 or GetArmyUnitCostTotal(aiBrain.ArmyIndex) / GetArmyUnitCap(aiBrain.ArmyIndex) > .75 or not GreaterThanEnergyIncome( aiBrain, 16800 ) then
            
                return 10, true
               
            end
            
            if UnitsGreaterAtLocationInRange( aiBrain, manager.LocationType, 15, TMD, 56, 80 ) then
            
                return 10, true
                
            end

            local threat = GetThreatAtPosition( aiBrain, GetPosition(unit), ScenarioInfo.IMAPBlocks, true, 'AntiSurface' )

            if threat > 175 then

                return (builder.OldPriority or builder.Priority) + 100, true
        
            end
    
            return (builder.OldPriority or builder.Priority), true
        end,

        BuilderConditions = {
            { MIBC, 'BaseInPlayableArea', { 'LocationType' }},

			{ EBC, 'GreaterThanEconStorageCurrent', { 400, 5000 }},

			{ TBC, 'ThreatCloserThan', { 'LocationType', 350, 75, 'AntiSurface' }},
        },
		
		BuilderType = { 'T3','SubCommander' },

        BuilderData = {
            Construction = {
				Radius = 68,
                NearBasePerimeterPoints = true,
				
				BasePerimeterOrientation = 'FRONT',
				BasePerimeterSelection = true,
				
				BaseTemplateFile = '/lua/ai/aibuilders/loud_perimeter_defense_templates.lua',
				BaseTemplate = 'PerimeterDefenseTemplates',
				
                BuildStructures = {'T3MissileDefense'},
            }
        }
    },

    Builder {BuilderName = 'T3 Perimeter Shields',
	
        PlatoonTemplate = 'EngineerBuilder',
        
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
		
		InstanceCount = 1,
		
        Priority = 750,

        PriorityFunction = function( builder, aiBrain, unit, manager )
        
            if aiBrain.LandRatio >= 2.0 or GetArmyUnitCostTotal(aiBrain.ArmyIndex) / GetArmyUnitCap(aiBrain.ArmyIndex) > .80 or not GreaterThanEnergyIncome( aiBrain, 18900 ) then
            
                return 10, true
               
            end

            if UnitsGreaterAtLocationInRange( aiBrain, manager.LocationType, 17, SHIELD - categories.ANTIARTILLERY, 60, 88 ) then
            
                return 10, true
             
            end

            if aiBrain.LandRatio <= 1.0 and aiBrain.CycleTime > 900 then
	
                return (builder.OldPriority or builder.Priority) + 100, true	

            end
    
            local threat = GetThreatAtPosition( aiBrain, GetPosition(unit), ScenarioInfo.IMAPBlocks, true, 'AntiSurface' )

            if threat > 125 then

                return (builder.OldPriority or builder.Priority) + 100, true
        
            end
    
            return (builder.OldPriority or builder.Priority), true
        end,
		
        BuilderConditions = {
            { MIBC, 'BaseInPlayableArea', { 'LocationType' }},            

			{ EBC, 'GreaterThanEconStorageCurrent', { 400, 5000 }},

            { EBC, 'GreaterThanEconTrendEfficiencyOverTime', { 1, 30, 1.02, 1.02 }},

			{ TBC, 'ThreatCloserThan', { 'LocationType', 350, 75, 'AntiSurface' }},
        },
		
		BuilderType = { 'SubCommander' },

        BuilderData = {
			DesiresAssist = true,
			
            Construction = {
				Radius = 68,
                NearBasePerimeterPoints = true,
                
                ThreatMax = 75,
				
				BasePerimeterOrientation = 'FRONT',
				BasePerimeterSelection = true,
				
				BaseTemplateFile = '/lua/ai/aibuilders/loud_perimeter_defense_templates.lua',
				BaseTemplate = 'PerimeterDefenseTemplates',
				
                BuildStructures = {'T3ShieldDefense'},
            }
        }
    },

    Builder {BuilderName = 'T4 Perimeter AA',
	
        PlatoonTemplate = 'EngineerBuilder',		
        
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
		
		InstanceCount = 1,
		
        Priority = 730,

        PriorityFunction = function( builder, aiBrain, unit, manager )
        
            if aiBrain.AirRatio >= 2.0 or GetArmyUnitCostTotal(aiBrain.ArmyIndex) / GetArmyUnitCap(aiBrain.ArmyIndex) > .80 or not GreaterThanEnergyIncome( aiBrain, 21000 ) then
            
                return 10, true
               
            end

            if UnitsGreaterAtLocationInRange( aiBrain, manager.LocationType, 8, AA * categories.EXPERIMENTAL, 50, 88 ) then
            
                return 10, true
             
            end

            if aiBrain.AirRatio <= 1.0 and aiBrain.CycleTime > 900 then
	
                return (builder.OldPriority or builder.Priority) + 100, true	

            end
    
            return (builder.OldPriority or builder.Priority), true
        end,
		
        PriorityFunction = IsEnemyCrushingAir,
		
        BuilderConditions = {
            { MIBC, 'BaseInPlayableArea', { 'LocationType' }},

			{ EBC, 'GreaterThanEnergyTrendOverTime', { 260 }},            

			{ EBC, 'GreaterThanEconStorageCurrent', { 400, 5000 }},

            { EBC, 'GreaterThanEconTrendEfficiencyOverTime', { 2, 75, 1.015, 1.025 }},
        },
		
		BuilderType = { 'SubCommander' },

        BuilderData = {
			DesiresAssist = true,
            NumAssistees = 4,
			
            Construction = {
				Radius = 68,
                NearBasePerimeterPoints = true,
                
                ThreatMax = 75,

				BasePerimeterOrientation = 'FRONT',				
				BasePerimeterSelection = true,
				
				BaseTemplateFile = '/lua/ai/aibuilders/loud_perimeter_defense_templates.lua',
				BaseTemplate = 'PerimeterDefenseTemplates',
				
                BuildStructures = {'T4AADefense'},
            }
        }
    },
	
    Builder {BuilderName = 'T4 Perimeter PD',
	
        PlatoonTemplate = 'EngineerBuilder',
        
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
		
		InstanceCount = 1,
		
        Priority = 730,

        PriorityFunction = function( builder, aiBrain, unit, manager )
        
            if aiBrain.LandRatio >= 1.2 or GetArmyUnitCostTotal(aiBrain.ArmyIndex) / GetArmyUnitCap(aiBrain.ArmyIndex) > .90 or not GreaterThanEnergyIncome( aiBrain, 21000 ) then
            
                return 10, true
               
            end

            if UnitsGreaterAtLocationInRange( aiBrain, manager.LocationType, 8, PD * categories.EXPERIMENTAL, 50, 88 ) then
            
                return 10, true
             
            end

            if aiBrain.LandRatio <= 1.0 and aiBrain.CycleTime > 900 then
	
                return (builder.OldPriority or builder.Priority) + 100, true	

            end
    
            local threat = GetThreatAtPosition( aiBrain, GetPosition(unit), ScenarioInfo.IMAPBlocks, true, 'AntiSurface' )

            if threat > 175 then

                return (builder.OldPriority or builder.Priority) + 100, true
        
            end
    
            return (builder.OldPriority or builder.Priority), true
        end,

        BuilderConditions = {
            { MIBC, 'BaseInPlayableArea', { 'LocationType' }},
            
			{ EBC, 'GreaterThanEnergyTrendOverTime', { 260 }},            

			{ EBC, 'GreaterThanEconStorageCurrent', { 400, 5000 }},
            
            { EBC, 'GreaterThanEconTrendEfficiencyOverTime', { 2, 75, 1.015, 1.025 }},
        },
		
		BuilderType = { 'SubCommander' },

        BuilderData = {
			DesiresAssist = true,
            NumAssistees = 5,
			
            Construction = {
				Radius = 68,
                NearBasePerimeterPoints = true,
                
                ThreatMax = 100,

				BasePerimeterOrientation = 'FRONT',
				BasePerimeterSelection = true,
				
				BaseTemplateFile = '/lua/ai/aibuilders/loud_perimeter_defense_templates.lua',
				BaseTemplate = 'PerimeterDefenseTemplates',
				
                BuildStructures = {'T4GroundDefense'},
            }
        }
    },
	
    Builder {BuilderName = 'AntiNuke Perimeter',
	
        PlatoonTemplate = 'EngineerBuilder',
        
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
		
		InstanceCount = 1,
		
        Priority = 730,
        
        PriorityFunction = function( self, aiBrain, unit, manager)
        
            if GreaterThanEnergyIncome( aiBrain, 21000) and UnitsGreaterAtLocation( aiBrain, manager.LocationType, 4, SMD) then
            
                if import(UCBC).HaveGreaterThanUnitsWithCategoryAndAlliance( aiBrain, 3, categories.NUKE * categories.SILO * categories.STRUCTURE,'Enemy') then
                    return (self.OldPriority or self.Priority), true
                end
            else
                return 10, true
            end
        
        end,

        BuilderConditions = {
            { MIBC, 'BaseInPlayableArea', { 'LocationType' }},            
            
			{ EBC, 'GreaterThanEnergyTrendOverTime', { 260 }},            
            
            { EBC, 'GreaterThanEconTrendEfficiencyOverTime', { 1.5, 50, 1.0125, 1.02 }},
            
            { UCBC, 'UnitsLessAtLocationInRange', { 'LocationType', 9, SMD, 50, 88 }},
        },
		
		BuilderType = { 'SubCommander' },
		
        BuilderData = {
			DesiresAssist = true,
            NumAssistees = 4,
			
            Construction = {
				Radius = 68,
                NearBasePerimeterPoints = true,
                
                ThreatMax = 60,

				BasePerimeterOrientation = 'FRONT',
				BasePerimeterSelection = true,
				
				BaseTemplateFile = '/lua/ai/aibuilders/loud_perimeter_defense_templates.lua',
				BaseTemplate = 'PerimeterDefenseTemplates',
				
                BuildStructures = {'T3StrategicMissileDefense'},
            }
        }
    },
	
    Builder {BuilderName = 'Sera Perimeter Restoration Field',
	
        PlatoonTemplate = 'EngineerBuilder',
        
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
		
		FactionIndex = 4,

        Priority = 730,

        PriorityFunction = function( builder, aiBrain, unit, manager )
        
            if aiBrain.LandRatio >= 1.2 or GetArmyUnitCostTotal(aiBrain.ArmyIndex) / GetArmyUnitCap(aiBrain.ArmyIndex) > .80 or not GreaterThanEnergyIncome( aiBrain, 21000 ) then
            
                return 10, true
               
            end

            if UnitsGreaterAtLocationInRange( aiBrain, manager.LocationType, 8, categories.bsb4205, 50, 88 ) then
            
                return 10, true
             
            end

            if aiBrain.LandRatio <= 1.0 and aiBrain.CycleTime > 900 then
	
                return (builder.OldPriority or builder.Priority) + 100, true	

            end
    
            local threat = GetThreatAtPosition( aiBrain, GetPosition(unit), ScenarioInfo.IMAPBlocks, true, 'AntiSurface' )

            if threat > 125 then

                return (builder.OldPriority or builder.Priority) + 100, true
        
            end
    
            return (builder.OldPriority or builder.Priority), true
        end,

        BuilderConditions = {
            { MIBC, 'BaseInPlayableArea', { 'LocationType' }},            

			{ EBC, 'GreaterThanEconStorageCurrent', { 400, 5000 }},

            { EBC, 'GreaterThanEconTrendEfficiencyOverTime', { 1, 30, 1.02, 1.02 }},
        },
		
		BuilderType = { 'T3','SubCommander' },
		
        BuilderData = {
			DesiresAssist = true,
            NumAssistees = 1,
			
            Construction = {
				Radius = 68,
                NearBasePerimeterPoints = true,

				BasePerimeterOrientation = 'FRONT',
				BasePerimeterSelection = true,
				
				BaseTemplateFile = '/lua/ai/aibuilders/loud_perimeter_defense_templates.lua',
				BaseTemplate = 'PerimeterDefenseTemplates',
				
                BuildStructures = {'RestorationField'},
            }
        }
    },
}

BuilderGroup {BuilderGroupName = 'Engineer Shield Augmentation - Perimeter',
    BuildersType = 'EngineerBuilder',
	
    Builder {BuilderName = 'T3 Perimeter Shield Augmentation',
    
        PlatoonTemplate = 'EngineerBuilder',
        
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
        
		InstanceCount = 1,
        
        Priority = 745,
        
        PriorityFunction = AboveUnitCap75,
		
        BuilderConditions = {
			{ LUTL, 'LandStrengthRatioLessThan', { 1.1 } },

            { LUTL, 'UnitCapCheckLess', { .75 } },

            { MIBC, 'BaseInPlayableArea', { 'LocationType' }},			

			{ EBC, 'GreaterThanEconStorageCurrent', { 300, 3000 }},

            { EBC, 'GreaterThanEconTrendEfficiencyOverTime', { 2, 30, 1.02, 1.04 }}, 

			-- check the outer perimeter for shields
			{ UCBC, 'UnitsGreaterAtLocationInRange', { 'LocationType', 6, SHIELD - categories.ANTIARTILLERY, 60, 80 }},

			-- check outer perimeter for storage
			{ UCBC, 'UnitsLessAtLocationInRange', { 'LocationType', 54, categories.ENERGYSTORAGE * categories.TECH3, 60, 80 }}, 
        },
		
		BuilderType = { 'T3','SubCommander' },

        BuilderData = {
			DesiresAssist = true,
            Construction = {
			
				Radius = 68,
                NearBasePerimeterPoints = true,
				
				BasePerimeterOrientation = 'FRONT',
				BasePerimeterSelection = true,
				
				BaseTemplateFile = '/lua/ai/aibuilders/loud_perimeter_defense_templates.lua',
				BaseTemplate = 'PerimeterDefenseTemplates',
				
                BuildStructures = {'T3Storage',
					'T3Storage',
					'T3Storage',
					'T3Storage',
					'T3Storage',
					'T3Storage',
					'T3Storage',
					'T3Storage',
					'T3Storage',
					'T3Storage',
					'T3Storage',
					'T3Storage',
                },
            }
        }
    },
}

--- PICKET LINE -- the most exterior belt of defense - usually AA
BuilderGroup {BuilderGroupName = 'Engineer Base Defense Construction - Picket Line',
	BuildersType = 'EngineerBuilder',
	
    Builder {BuilderName = 'T3 Picket AA',
    
        PlatoonTemplate = 'EngineerBuilder',
        
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
        
		InstanceCount = 1,
        
        Priority = 745,

        PriorityFunction = function( builder, aiBrain, unit, manager )
        
            if aiBrain.AirRatio >= 2 or GetArmyUnitCostTotal(aiBrain.ArmyIndex) / GetArmyUnitCap(aiBrain.ArmyIndex) > .80 or not GreaterThanEnergyIncome( aiBrain, 21000 ) then
            
                return 10, true
               
            end

            if UnitsGreaterAtLocationInRange( aiBrain, manager.LocationType, 36, AA * categories.TECH3, 90, 120 ) then
            
                return 10, true
             
            end

            return (builder.OldPriority or builder.Priority), true
        end,
        
        PriorityFunction = AboveUnitCap75,
        
        BuilderConditions = {
            { MIBC, 'BaseInPlayableArea', { 'LocationType' }},			

			{ EBC, 'GreaterThanEconStorageCurrent', { 300, 3000 }},

            { EBC, 'GreaterThanEconTrendEfficiencyOverTime', { 2, 30, 1.02, 1.04 }}, 
        },
		
		BuilderType = { 'T3' },

        BuilderData = {
            Construction = {
			
				Radius = 100,
                NearBasePerimeterPoints = true,
				
				BasePerimeterOrientation = 'ALL',
				BasePerimeterSelection = true,
				
				BaseTemplateFile = '/lua/ai/aibuilders/loud_perimeter_defense_templates.lua',
				BaseTemplate = 'PerimeterDefenseTemplates',
				
                BuildStructures = {'T3AADefense','T3AADefense','T3AADefense'},
            }
        }
    },			
}

--- DEFEND LOCAL MASS POINTS
BuilderGroup {BuilderGroupName = 'Engineer Mass Point Defense Construction',
    BuildersType = 'EngineerBuilder',
	
    Builder {BuilderName = 'T1 Extractor Defense',
	
        PlatoonTemplate = 'EngineerGeneral',
        
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
        
        PlatoonAIPlan = 'EngineerBuildMassDefenseAdjacencyAI',
		
        Priority = 760,

        PriorityFunction = function( builder, aiBrain, unit, manager )
        
            if aiBrain.LandRatio >= 2 or GetArmyUnitCostTotal(aiBrain.ArmyIndex) / GetArmyUnitCap(aiBrain.ArmyIndex) > .65 or not GreaterThanEnergyIncome( aiBrain, 550 ) then
            
                return 10, true
               
            end
    
            return (builder.OldPriority or builder.Priority), true
        end,
		
        BuilderConditions = {
			{ EBC, 'GreaterThanEconStorageCurrent', { 400, 5000 }},

            { EBC, 'GreaterThanEconTrendEfficiencyOverTime', { 0.9, 20, 1.012, 1.02 }},

			{ UCBC, 'MassExtractorHasStorageAndLessDefense', { 'LocationType', 100, 600, 2, 2, categories.STRUCTURE * categories.DEFENSE }},
        },
		
        BuilderType = {'T1'},
		
        BuilderData = {
		
            Construction = {
			
				LoopBuild = true,
				
				MinRadius = 100,
				Radius = 600,
				
				MinStructureUnits = 2,
				MaxDefenseStructures = 2,
				MaxDefenseCategories = categories.STRUCTURE * categories.DEFENSE,
				
				BaseTemplateFile = '/lua/ai/aibuilders/Loud_MAIN_Base_templates.lua',
				BaseTemplate = 'MassAdjacencyDefense',
				
                BuildStructures = {'T1GroundDefense',
                    'Wall',
                    'Wall',
                    'Wall',
                    'Wall',
                    'Wall',
                    'Wall',
                    'Wall',
                    'Wall',
                    'Wall',
                    'T1GroundDefense',
                    'Wall',
                    'Wall',
                    'Wall',
                    'Wall',
                    'Wall',
                    'Wall',
                    'Wall',
                    'Wall',
                    'Wall',
                    'Wall',
                    'Wall',
                    'Wall',
                    'Wall',
                    'Wall',
                    'Wall',
                    'Wall',
                    'Wall',
                    'Wall',
                    'Wall',
                    'Wall',
                    'Wall',
                    'Wall',
                    'Wall',
                    'Wall',
                    'Wall',
                    'Wall',
                    'Wall',                    
                }
            }
        }
    },
	
    Builder {BuilderName = 'T2 Extractor Defense',
	
        PlatoonTemplate = 'EngineerGeneral',
        
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
        
        PlatoonAIPlan = 'EngineerBuildMassDefenseAdjacencyAI',
		
        Priority = 750,

        PriorityFunction = function( builder, aiBrain, unit, manager )
        
            if aiBrain.LandRatio >= 2 or GetArmyUnitCostTotal(aiBrain.ArmyIndex) / GetArmyUnitCap(aiBrain.ArmyIndex) > .75 or not GreaterThanEnergyIncome( aiBrain, 3000 ) then
            
                return 10, true
               
            end
    
            return (builder.OldPriority or builder.Priority), true
        end,
		
        BuilderConditions = {
			{ EBC, 'GreaterThanEconStorageCurrent', { 400, 5000 }},

            { EBC, 'GreaterThanEconTrendEfficiencyOverTime', { 0.9, 20, 1.012, 1.02 }},

			{ UCBC, 'MassExtractorHasStorageAndLessDefense', { 'LocationType', 150, 750, 2, 4, categories.STRUCTURE * categories.DEFENSE * categories.TECH2 }},
        },
		
        BuilderType = {'T2'},
		
        BuilderData = {
		
            Construction = {
			
				LoopBuild = true,
				
				MinRadius = 150,
				Radius = 750,
				
				MinStructureUnits = 2,
				MaxDefenseStructures = 4,
				MaxDefenseCategories = categories.STRUCTURE * categories.DEFENSE * categories.TECH2,
				
				BaseTemplateFile = '/lua/ai/aibuilders/Loud_MAIN_Base_templates.lua',
				BaseTemplate = 'MassAdjacencyDefense',
				
                BuildStructures = {'T2AADefense',
					'T2GroundDefense',
                    'T2MissileDefense',
					'T2GroundDefense',
                }
            }
        }
    },
	
    Builder {BuilderName = 'T3 Extractor Defense',
	
        PlatoonTemplate = 'EngineerGeneral',
        
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
        
        PlatoonAIPlan = 'EngineerBuildMassDefenseAdjacencyAI',
		
        Priority = 750,

        PriorityFunction = function( builder, aiBrain, unit, manager )
        
            if aiBrain.LandRatio >= 2 or GetArmyUnitCostTotal(aiBrain.ArmyIndex) / GetArmyUnitCap(aiBrain.ArmyIndex) > .75 or not GreaterThanEnergyIncome( aiBrain, 12600 ) then
            
                return 10, true
               
            end
    
            return (builder.OldPriority or builder.Priority), true
        end,

        BuilderConditions = {
			{ EBC, 'GreaterThanEconStorageCurrent', { 400, 5000 }},

			{ EBC, 'GreaterThanEconTrendEfficiencyOverTime', { 0.9, 25, 1.012, 1.025 }},

			{ UCBC, 'MassExtractorHasStorageAndLessDefense', { 'LocationType', 150, 750, 3, 3, categories.STRUCTURE * categories.DEFENSE * categories.TECH3 }},
        },
		
        BuilderType = {'T3'},
		
        BuilderData = {
		
            Construction = {
			
				MinRadius = 150,
				Radius = 750,
				
				MinStructureUnits = 3,
				MaxDefenseStructures = 3,
				MaxDefenseCategories = categories.STRUCTURE * categories.DEFENSE * categories.TECH3,
				
				BaseTemplateFile = '/lua/ai/aibuilders/Loud_MAIN_Base_templates.lua',
				BaseTemplate = 'MassAdjacencyDefense',
				
                BuildStructures = {'T3AADefense',
					'T3GroundDefense',
					'T3AADefense',
                    'T3MissileDefense',
					'T1MassCreation',
					'T3ShieldDefense',
                }
            }
        }
    },
	
}


-----------------------
--- LAND EXPANSIONS ---

--- CORE ---
BuilderGroup {BuilderGroupName = 'Engineer Base Defense Construction - Core - Expansions',
    BuildersType = 'EngineerBuilder',
	
    Builder {BuilderName = 'T2 Base PD - Expansion',
	
        PlatoonTemplate = 'EngineerBuilder',
        
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
		
        Priority = 760,

        PriorityFunction = function( builder, aiBrain, unit, manager )
        
            if aiBrain.LandRatio >= 2.0 or GetArmyUnitCostTotal(aiBrain.ArmyIndex) / GetArmyUnitCap(aiBrain.ArmyIndex) > .75 then
            
                return 10, true
               
            end
            
            if UnitsGreaterAtLocationInRange( aiBrain, manager.LocationType, 9, PD * categories.TECH3, 14, 48 ) then
            
                return 10, true
                
            end
            
            if UnitsGreaterAtLocationInRange( aiBrain, manager.LocationType, 15, PD * categories.TECH2, 14, 48 ) then
            
                return 10, true
                
            end

            if aiBrain.LandRatio <= 1.0 and aiBrain.CycleTime > 360 then
	
                return (builder.OldPriority or builder.Priority) + 100, true	

            end
    
            local threat = GetThreatAtPosition( aiBrain, GetPosition(unit), ScenarioInfo.IMAPBlocks, true, 'AntiSurface' )

            if threat > 75 then

                return (builder.OldPriority or builder.Priority) + 100, true
        
            end
    
            return (builder.OldPriority or builder.Priority), true
        end,

        BuilderConditions = {
			{ EBC, 'GreaterThanEconStorageCurrent', { 300, 3000 }},

            { EBC, 'GreaterThanEconTrendEfficiencyOverTime', { 0.8, 15, 1.01, 1.02 }}, 
        },
		
        BuilderType = {'T2','T3','SubCommander'},
		
        BuilderData = {
            Construction = {
				NearBasePerimeterPoints = true,
                
				ThreatMax = 75,
				
				BaseTemplateFile = '/lua/ai/aibuilders/Loud_Expansion_Base_Templates.lua',
				BaseTemplate = 'ExpansionLayout_II',
				
                BuildStructures = {'T2GroundDefense'},
            }
        }
    },

    Builder {BuilderName = 'T2 Base AA - Expansion',
	
        PlatoonTemplate = 'EngineerBuilder',
        
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
		
        Priority = 760,

        PriorityFunction = function( builder, aiBrain, unit, manager )
        
            if aiBrain.AirRatio >= 2.5 or GetArmyUnitCostTotal(aiBrain.ArmyIndex) / GetArmyUnitCap(aiBrain.ArmyIndex) > .75 then
            
                return 10, true
               
            end
            
            if UnitsGreaterAtLocationInRange( aiBrain, manager.LocationType, 7, AA * categories.TECH2, 15, 42 ) then
            
                return 10, true
                
            end

            if aiBrain.AirRatio <= 1.2 and aiBrain.CycleTime > 360 then
	
                return (builder.OldPriority or builder.Priority) + 100, true	

            end
    
            return (builder.OldPriority or builder.Priority), true
        end,

        BuilderConditions = {
			{ EBC, 'GreaterThanEconStorageCurrent', { 250, 2500 }},

            { EBC, 'GreaterThanEconTrendEfficiencyOverTime', { 0.8, 15, 1.01, 1.02 }}, 
        },
		
        BuilderType = {'T2'},
		
        BuilderData = {
            Construction = {
				NearBasePerimeterPoints = true,
				
				ThreatMax = 60,				
				
				BaseTemplateFile = '/lua/ai/aibuilders/Loud_Expansion_Base_Templates.lua',
				BaseTemplate = 'ExpansionLayout_II',
				
                BuildStructures = {'T2AADefense'},
            }
        }
    },
	
    Builder {BuilderName = 'T2 Base TMD - Expansion',
	
        PlatoonTemplate = 'EngineerBuilder',
        
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
		
        Priority = 760,

        PriorityFunction = function( builder, aiBrain, unit, manager )
        
            if aiBrain.LandRatio >= 2.0 or GetArmyUnitCostTotal(aiBrain.ArmyIndex) / GetArmyUnitCap(aiBrain.ArmyIndex) > .75 then
            
                return 10, true
               
            end
            
            if UnitsGreaterAtLocationInRange( aiBrain, manager.LocationType, 3, TMD, 15, 48 ) then
            
                return 10, true
                
            end

            if aiBrain.LandRatio <= 1.1 and aiBrain.CycleTime > 480 then
	
                return (builder.OldPriority or builder.Priority) + 100, true	

            end
    
            return (builder.OldPriority or builder.Priority), true
        end,

        BuilderConditions = {
			{ EBC, 'GreaterThanEconStorageCurrent', { 300, 3000 }},

            { EBC, 'GreaterThanEconTrendEfficiencyOverTime', { 0.8, 15, 1.01, 1.02 }}, 
        },
		
        BuilderType = {'T2'},
		
        BuilderData = {
            Construction = {
				NearBasePerimeterPoints = true,
				
				ThreatMax = 75,				
				
				BaseTemplateFile = '/lua/ai/aibuilders/Loud_Expansion_Base_Templates.lua',
				BaseTemplate = 'ExpansionLayout_II',
				
                BuildStructures = {'T2MissileDefense'},
            }
        }
    },

    Builder {BuilderName = 'T3 Base PD - Expansions',
	
        PlatoonTemplate = 'EngineerBuilder',
        
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
		
        Priority = 755,

        PriorityFunction = function( builder, aiBrain, unit, manager )
        
            if aiBrain.LandRatio >= 2.0 or GetArmyUnitCostTotal(aiBrain.ArmyIndex) / GetArmyUnitCap(aiBrain.ArmyIndex) > .85 or not GreaterThanEnergyIncome( aiBrain, 16800 ) then
            
                return 10, true
               
            end
            
            if UnitsGreaterAtLocationInRange( aiBrain, manager.LocationType, 11, PD * categories.TECH3, 15, 58 ) then
            
                return 10, true
                
            end

            if aiBrain.LandRatio <= 1.0  then
	
                return (builder.OldPriority or builder.Priority) + 100, true	

            end
    
            local threat = GetThreatAtPosition( aiBrain, GetPosition(unit), ScenarioInfo.IMAPBlocks, true, 'AntiSurface' )

            if threat > 125 then

                return (builder.OldPriority or builder.Priority) + 100, true
        
            end
    
            return (builder.OldPriority or builder.Priority), true
        end,

        BuilderConditions = {
			{ EBC, 'GreaterThanEconStorageCurrent', { 300, 3000 }},

            { EBC, 'GreaterThanEconTrendEfficiencyOverTime', { 0.85, 20, 1.012, 1.02 }},

			{ TBC, 'ThreatCloserThan', { 'LocationType', 350, 75, 'AntiSurface' }},
        },
		
        BuilderType = { 'T3','SubCommander'},
		
        BuilderData = {
			DesiresAssist = true,
			NumAssistees = 4,
			
            Construction = {
				Radius = 1,			
				NearBasePerimeterPoints = true,
				
				ThreatMax = 100,
				
				BaseTemplateFile = '/lua/ai/aibuilders/Loud_Expansion_Base_Templates.lua',
				BaseTemplate = 'ExpansionLayout_II',
				
                BuildStructures = {'T3GroundDefense'},
            }
        }
    },

    Builder {BuilderName = 'T3 Base AA - Expansions',
	
        PlatoonTemplate = 'EngineerBuilder',
        
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
		
        Priority = 755, 

        PriorityFunction = function( builder, aiBrain, unit, manager )
        
            if aiBrain.AirRatio >= 3.0 or GetArmyUnitCostTotal(aiBrain.ArmyIndex) / GetArmyUnitCap(aiBrain.ArmyIndex) > .85 then
            
                return 10, true
               
            end
            
            if UnitsGreaterAtLocationInRange( aiBrain, manager.LocationType, 7, AA * categories.TECH3, 15, 48 ) then
            
                return 10, true
                
            end

            if aiBrain.AirRatio <= 1.2  then
	
                return (builder.OldPriority or builder.Priority) + 100, true	

            end
    
            return (builder.OldPriority or builder.Priority), true
        end,

        BuilderConditions = {
			{ EBC, 'GreaterThanEconStorageCurrent', { 250, 2500 }},

            { EBC, 'GreaterThanEconTrendEfficiencyOverTime', { 0.85, 20, 1.012, 1.02 }},
        },
		
        BuilderType = {'T3','SubCommander'},
		
        BuilderData = {
			DesiresAssist = true,
            NumAssistees = 3,
			
            Construction = {
				NearBasePerimeterPoints = true,
				
				ThreatMax = 75,
				
				BaseTemplateFile = '/lua/ai/aibuilders/Loud_Expansion_Base_Templates.lua',
				BaseTemplate = 'ExpansionLayout_II',
				
				BuildStructures = {'T3AADefense'},
            }
        }
    },

    Builder {BuilderName = 'T3 Base TMD - Expansion',
	
        PlatoonTemplate = 'EngineerBuilder',
        
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
		
        Priority = 760,

        PriorityFunction = function( builder, aiBrain, unit, manager )
        
            if aiBrain.LandRatio >= 2.0 or GetArmyUnitCostTotal(aiBrain.ArmyIndex) / GetArmyUnitCap(aiBrain.ArmyIndex) > .80 or not GreaterThanEnergyIncome( aiBrain, 12600 ) then
            
                return 10, true
               
            end
            
            if UnitsGreaterAtLocationInRange( aiBrain, manager.LocationType, 6, TMD, 15, 48 ) then
            
                return 10, true
                
            end

            if aiBrain.LandRatio <= 1.0  then
	
                return (builder.OldPriority or builder.Priority) + 100, true	

            end
    
            local threat = GetThreatAtPosition( aiBrain, GetPosition(unit), ScenarioInfo.IMAPBlocks, true, 'AntiSurface' )

            if threat > 125 then

                return (builder.OldPriority or builder.Priority) + 100, true
        
            end
    
            return (builder.OldPriority or builder.Priority), true
        end,

        BuilderConditions = {
			{ EBC, 'GreaterThanEconStorageCurrent', { 300, 3000 }},

            { EBC, 'GreaterThanEconTrendEfficiencyOverTime', { 0.8, 15, 1.01, 1.02 }}, 
        },
		
        BuilderType = {'T3'},
		
        BuilderData = {
            Construction = {
				NearBasePerimeterPoints = true,
				
				ThreatMax = 75,				
				
				BaseTemplateFile = '/lua/ai/aibuilders/Loud_Expansion_Base_Templates.lua',
				BaseTemplate = 'ExpansionLayout_II',
				
                BuildStructures = {'T3MissileDefense'},
            }
        }
    },

    Builder {BuilderName = 'T2 TML - Expansions',
	
        PlatoonTemplate = 'EngineerBuilder',
        
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
		
        Priority = 710,

        PriorityFunction = function( builder, aiBrain, unit, manager )
         
            if aiBrain.LandRatio >= 2.0 or GetArmyUnitCostTotal(aiBrain.ArmyIndex) / GetArmyUnitCap(aiBrain.ArmyIndex) > .80 or not GreaterThanEnergyIncome( aiBrain, 21000 ) then
            
                return 10, true
               
            end
            
            if UnitsGreaterAtLocationInRange( aiBrain, manager.LocationType, 3, categories.TACTICALMISSILEPLATFORM * categories.STRUCTURE, 15, 48 ) then
            
                return 10, true
                
            end

            if aiBrain.LandRatio <= 1.0  then
	
                return (builder.OldPriority or builder.Priority) + 100, true	

            end
    
            local threat = GetThreatAtPosition( aiBrain, GetPosition(unit), ScenarioInfo.IMAPBlocks, true, 'AntiSurface' )

            if threat > 125 then

                return (builder.OldPriority or builder.Priority) + 100, true
        
            end
    
            return (builder.OldPriority or builder.Priority), true
        end,

        BuilderConditions = {
			{ TBC, 'ThreatCloserThan', { 'LocationType', 350, 75, 'AntiSurface' }},

			{ EBC, 'GreaterThanEconStorageCurrent', { 400, 5000 }},

            { EBC, 'GreaterThanEconTrendEfficiencyOverTime', { 1.5, 30, 1.012, 1.025 }}, 
        },
		
        BuilderType = {'T2','T3'},
		
        BuilderData = {
            Construction = {
                NearBasePerimeterPoints = true,
				
				ThreatMax = 60,
				
				BaseTemplateFile = '/lua/ai/aibuilders/Loud_Expansion_Base_Templates.lua',
				BaseTemplate = 'ExpansionLayout_II',
				
                BuildStructures = {'T2StrategicMissile'},
            }
        }
    },
 
    Builder {BuilderName = 'T3 Tactical Artillery - Expansions',
	
        PlatoonTemplate = 'EngineerBuilder',
        
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
		
        Priority = 750,

        PriorityFunction = function( builder, aiBrain, unit, manager )
        
            if aiBrain.LandRatio >= 3.0 or GetArmyUnitCostTotal(aiBrain.ArmyIndex) / GetArmyUnitCap(aiBrain.ArmyIndex) > .80 or not GreaterThanEnergyIncome( aiBrain, 21000 ) then
            
                return 10, true
               
            end
            
            if UnitsGreaterAtLocation( aiBrain, manager.LocationType, 3, categories.ARTILLERY * categories.TACTICAL ) then
            
                return 10, true
                
            end

            if aiBrain.LandRatio <= 1.0  then
	
                return (builder.OldPriority or builder.Priority) + 100, true	

            end
    
            local threat = GetThreatAtPosition( aiBrain, GetPosition(unit), ScenarioInfo.IMAPBlocks, true, 'AntiSurface' )

            if threat > 125 then

                return (builder.OldPriority or builder.Priority) + 100, true
        
            end
    
            return (builder.OldPriority or builder.Priority), true
        end,

        BuilderConditions = {
			{ EBC, 'GreaterThanEconStorageCurrent', { 400, 5000 }},

            { EBC, 'GreaterThanEconTrendEfficiencyOverTime', { 1, 25, 1.012, 1.02 }},

			{ TBC, 'ThreatCloserThan', { 'LocationType', 350, 75, 'AntiSurface' }},
        },
		
        BuilderType = { 'T3','SubCommander'},
		
        BuilderData = {
			DesiresAssist = true,
			NumAssistees = 4,
			
            Construction = {
				Radius = 1,			
				NearBasePerimeterPoints = true,
				
				ThreatMax = 90,
				
				BaseTemplateFile = '/lua/ai/aibuilders/Loud_Expansion_Base_Templates.lua',
				BaseTemplate = 'ExpansionLayout_II',
				
                BuildStructures = {'T3TacticalArtillery'},
            }
        }
    },    

    Builder {BuilderName = 'AntiNuke - Expansion',
	
        PlatoonTemplate = 'EngineerBuilder',
        
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
		
        Priority = 900,
        
        PriorityFunction = function( self, aiBrain, unit, manager)

            if GreaterThanEnergyIncome( aiBrain, 21000) and UnitsLessAtLocation( aiBrain, manager.LocationType, 1, SMD) then
                return (self.OldPriority or self.Priority), true
            else
                return 10, true
            end
        
        end,
		
        BuilderConditions = {
			{ LUTL, 'FactoryGreaterAtLocation', { 'LocationType', 2, FACTORY - categories.TECH1 }},

			{ EBC, 'GreaterThanEconStorageCurrent', { 400, 5000 }},
        },
		
        BuilderType = {'SubCommander'},
		
        BuilderData = {
		
			DesiresAssist = true,
			
            Construction = {
				NearBasePerimeterPoints = true,
				BasePerimeterOrientation = 'FRONT',
                
                ThreatMax = 60,
				
				BaseTemplateFile = '/lua/ai/aibuilders/Loud_Expansion_Base_Templates.lua',
				BaseTemplate = 'ExpansionLayout_II',
				
                BuildStructures = {'T3StrategicMissileDefense'},
            }
        }
    },
	
    Builder {BuilderName = 'Experimental PD - Expansions',
	
        PlatoonTemplate = 'EngineerBuilder',
        
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
		
        Priority = 750,

        PriorityFunction = function( builder, aiBrain, unit, manager )
        
            if GetArmyUnitCostTotal(aiBrain.ArmyIndex) / GetArmyUnitCap(aiBrain.ArmyIndex) > .90 or not GreaterThanEnergyIncome( aiBrain, 21000 ) then
            
                return 10, true
               
            end
            
            if UnitsGreaterAtLocationInRange( aiBrain, manager.LocationType, 3, PD * categories.EXPERIMENTAL, 10, 42 ) then
            
                return 10, true
                
            end

            if aiBrain.LandRatio <= 1.0  then
	
                return (builder.OldPriority or builder.Priority) + 100, true	

            end
    
            local threat = GetThreatAtPosition( aiBrain, GetPosition(unit), ScenarioInfo.IMAPBlocks, true, 'AntiSurface' )

            if threat > 125 then

                return (builder.OldPriority or builder.Priority) + 100, true
        
            end
    
            return (builder.OldPriority or builder.Priority), true
        end,

        BuilderConditions = {
			{ TBC, 'ThreatCloserThan', { 'LocationType', 350, 75, 'AntiSurface' }},

			{ EBC, 'GreaterThanEconStorageCurrent', { 400, 5000 }},

            { EBC, 'GreaterThanEconTrendEfficiencyOverTime', { 1.5, 50, 1.012, 1.02 }},
        },
		
        BuilderType = {'SubCommander'},
		
        BuilderData = {
			DesiresAssist = true,
			NumAssistees = 4,
            Construction = {
				NearBasePerimeterPoints = true,
				
				ThreatMax = 100,

				BaseTemplateFile = '/lua/ai/aibuilders/Loud_Expansion_Base_Templates.lua',
				BaseTemplate = 'ExpansionLayout_II',
				
                BuildStructures = {'T4GroundDefense'},
            }
        }
    },
	
    Builder {BuilderName = 'Experimental AA Defense - Expansions',
	
        PlatoonTemplate = 'EngineerBuilder',
        
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
		
        Priority = 750,

        PriorityFunction = function( builder, aiBrain, unit, manager )
        
            if aiBrain.AirRatio >= 2.5 or GetArmyUnitCostTotal(aiBrain.ArmyIndex) / GetArmyUnitCap(aiBrain.ArmyIndex) > .90 or not GreaterThanEnergyIncome( aiBrain, 21000 ) then
            
                return 10, true
               
            end
            
            if UnitsGreaterAtLocation( aiBrain, manager.LocationType, 3, AA * categories.EXPERIMENTAL ) then
            
                return 10, true
                
            end

            if aiBrain.AirRatio <= 1.1 or import(UCBC).HaveGreaterThanUnitsWithCategoryAndAlliance( aiBrain, 0, categories.AIR * categories.EXPERIMENTAL,'Enemy')  then
	
                return (builder.OldPriority or builder.Priority) + 100, true	

            end
    
            local threat = GetThreatAtPosition( aiBrain, GetPosition(unit), ScenarioInfo.IMAPBlocks, true, 'Air' )

            if threat > 150 then

                return (builder.OldPriority or builder.Priority) + 100, true
        
            end
    
            return (builder.OldPriority or builder.Priority), true
        end,

        BuilderConditions = {
			{ EBC, 'GreaterThanEconStorageCurrent', { 400, 5000 }},
            
            { EBC, 'GreaterThanEconTrendEfficiencyOverTime', { 1.5, 50, 1.012, 1.02 }},
        },
		
        BuilderType = {'SubCommander'},
		
        BuilderData = {
			DesiresAssist = true,
            NumAssistees = 3,
			
            Construction = {
				NearBasePerimeterPoints = true,
				
				ThreatMax = 90,

				BaseTemplateFile = '/lua/ai/aibuilders/Loud_Expansion_Base_Templates.lua',
				BaseTemplate = 'ExpansionLayout_II',
				
                BuildStructures = {'T4AADefense'},
            }
        }
    },
	
}

BuilderGroup {BuilderGroupName = 'Engineer Shield Construction - Expansions',
    BuildersType = 'EngineerBuilder',
	
    Builder {BuilderName = 'Shields - Inner - Expansion',
    
        PlatoonTemplate = 'EngineerBuilder',
        
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
        
        Priority = 800,

        PriorityFunction = function( builder, aiBrain, unit, manager )
        
            if GetArmyUnitCostTotal(aiBrain.ArmyIndex) / GetArmyUnitCap(aiBrain.ArmyIndex) > .85 or not GreaterThanEnergyIncome( aiBrain, 21000 ) then
            
                return 10, true
               
            end

            if UnitsGreaterAtLocationInRange( aiBrain, manager.LocationType, 3, SHIELD - categories.ANTIARTILLERY, 5, 16 ) then
            
                return 10, true
             
            end

            if aiBrain.LandRatio <= 1.0 and aiBrain.CycleTime > 900 then
	
                return (builder.OldPriority or builder.Priority) + 100, true	

            end
    
            local threat = GetThreatAtPosition( aiBrain, GetPosition(unit), ScenarioInfo.IMAPBlocks, true, 'AntiSurface' )

            if threat > 50 then

                return (builder.OldPriority or builder.Priority) + 100, true
        
            end
    
            return (builder.OldPriority or builder.Priority), true
        end,

		InstanceCount = 1,
        
        BuilderConditions = {
			{ EBC, 'GreaterThanEconStorageCurrent', { 400, 5000 }},
			
			{ EBC, 'GreaterThanEconTrendEfficiencyOverTime', { 1.5, 50, 1.012, 1.02 }},

			{ UCBC, 'UnitsGreaterAtLocation', { 'LocationType', 1, FACTORY}},
        },
		
        BuilderType = {'T2','T3','SubCommander'},
		
        BuilderData = {
			DesiresAssist = true,
            Construction = {
				NearBasePerimeterPoints = true,
                
				MaxThreat = 75,
                
				BaseTemplateFile = '/lua/ai/aibuilders/Loud_Expansion_Base_Templates.lua',
				BaseTemplate = 'ExpansionLayout_II',
                
                BuildStructures = {'T2ShieldDefense',
					'EnergyStorage',
					'EnergyStorage',
					'EnergyStorage',
                },
            }
        }
    },

    Builder {BuilderName = 'Shields - Outer - Outer',
    
        PlatoonTemplate = 'EngineerBuilder',
        
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
        
        Priority = 800,

        PriorityFunction = function( builder, aiBrain, unit, manager )
        
            if GetArmyUnitCostTotal(aiBrain.ArmyIndex) / GetArmyUnitCap(aiBrain.ArmyIndex) > .85 or not GreaterThanEnergyIncome( aiBrain, 21000 ) then
            
                return 10, true
               
            end

            if UnitsLessAtLocationInRange( aiBrain, manager.LocationType, 4, SHIELD - categories.ANTIARTILLERY, 5, 16 ) then
            
                return 10, true
             
            end

            if UnitsGreaterAtLocationInRange( aiBrain, manager.LocationType, 7, SHIELD - categories.ANTIARTILLERY, 16, 45 ) then
            
                return 10, true
             
            end

            if aiBrain.LandRatio <= 1.0 and aiBrain.CycleTime > 900 then
	
                return (builder.OldPriority or builder.Priority) + 100, true	

            end
    
            local threat = GetThreatAtPosition( aiBrain, GetPosition(unit), ScenarioInfo.IMAPBlocks, true, 'AntiSurface' )

            if threat > 50 then

                return (builder.OldPriority or builder.Priority) + 100, true
        
            end
    
            return (builder.OldPriority or builder.Priority), true
        end,

		InstanceCount = 1,
        
        BuilderConditions = {
			{ EBC, 'GreaterThanEconStorageCurrent', { 400, 5000 }},
			
			{ EBC, 'GreaterThanEconTrendEfficiencyOverTime', { 1.5, 50, 1.012, 1.02 }},
        },
		
        BuilderType = {'T3','SubCommander'},
		
        BuilderData = {
			DesiresAssist = true,
            Construction = {
				NearBasePerimeterPoints = true,
                
				MaxThreat = 45,
                
				BaseTemplateFile = '/lua/ai/aibuilders/Loud_Expansion_Base_Templates.lua',
				BaseTemplate = 'ExpansionLayout_II',
                
                BuildStructures = {'T3ShieldDefense','EnergyStorage','EnergyStorage','EnergyStorage'},
            }
        }
    },
}

BuilderGroup {BuilderGroupName = 'Engineer Shield Construction - Expansions - LOUD_IS',
    BuildersType = 'EngineerBuilder',
	
    Builder {BuilderName = 'Shields - Inner - Expansion - IS ',
    
        PlatoonTemplate = 'EngineerBuilder',
        
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
        
        Priority = 800,

        PriorityFunction = function( builder, aiBrain, unit, manager )
        
            if GetArmyUnitCostTotal(aiBrain.ArmyIndex) / GetArmyUnitCap(aiBrain.ArmyIndex) > .85 or not GreaterThanEnergyIncome( aiBrain, 21000 ) then
            
                return 10, true
               
            end

            if UnitsGreaterAtLocationInRange( aiBrain, manager.LocationType, 3, SHIELD - categories.ANTIARTILLERY, 5, 16 ) then
            
                return 10, true
             
            end

            if aiBrain.LandRatio <= 1.0 and aiBrain.CycleTime > 900 then
	
                return (builder.OldPriority or builder.Priority) + 100, true	

            end
    
            local threat = GetThreatAtPosition( aiBrain, GetPosition(unit), ScenarioInfo.IMAPBlocks, true, 'AntiSurface' )

            if threat > 50 then

                return (builder.OldPriority or builder.Priority) + 100, true
        
            end
    
            return (builder.OldPriority or builder.Priority), true
        end,

		InstanceCount = 1,

        BuilderConditions = {
			{ EBC, 'GreaterThanEconStorageCurrent', { 400, 5000 }},

			{ EBC, 'GreaterThanEconTrendEfficiencyOverTime', { 1.5, 50, 1.012, 1.02 }},

			{ UCBC, 'UnitsGreaterAtLocation', { 'LocationType', 1, FACTORY}},
        },
		
        BuilderType = {'T2','T3','SubCommander'},
		
        BuilderData = {
			DesiresAssist = true,
            Construction = {
				NearBasePerimeterPoints = true,
                
				MaxThreat = 75,
				
				BaseTemplateFile = '/lua/ai/aibuilders/Loud_Expansion_Base_Templates.lua',
				BaseTemplate = 'ExpansionLayout_II',
				
                BuildStructures = {'T2ShieldDefense'},
            }
        }
    },	
	
    Builder {BuilderName = 'Shields - Outer - Expansion - IS',
    
        PlatoonTemplate = 'EngineerBuilder',
        
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
        
        Priority = 800,

        PriorityFunction = function( builder, aiBrain, unit, manager )
        
            if GetArmyUnitCostTotal(aiBrain.ArmyIndex) / GetArmyUnitCap(aiBrain.ArmyIndex) > .85 or not GreaterThanEnergyIncome( aiBrain, 21000 ) then
            
                return 10, true
               
            end

            if UnitsLessAtLocationInRange( aiBrain, manager.LocationType, 4, SHIELD - categories.ANTIARTILLERY, 5, 16 ) then
            
                return 10, true
             
            end

            if UnitsGreaterAtLocationInRange( aiBrain, manager.LocationType, 7, SHIELD - categories.ANTIARTILLERY, 16, 45 ) then
            
                return 10, true
             
            end

            if aiBrain.LandRatio <= 1.0 and aiBrain.CycleTime > 900 then
	
                return (builder.OldPriority or builder.Priority) + 100, true	

            end
    
            local threat = GetThreatAtPosition( aiBrain, GetPosition(unit), ScenarioInfo.IMAPBlocks, true, 'AntiSurface' )

            if threat > 50 then

                return (builder.OldPriority or builder.Priority) + 100, true
        
            end
    
            return (builder.OldPriority or builder.Priority), true
        end,

		InstanceCount = 1,
        
        BuilderConditions = {
			{ EBC, 'GreaterThanEconStorageCurrent', { 400, 5000 }},
			
			{ EBC, 'GreaterThanEconTrendEfficiencyOverTime', { 1.5, 50, 1.012, 1.02 }},
        },
		
        BuilderType = {'T3','SubCommander'},
		
        BuilderData = {
			DesiresAssist = true,
            Construction = {
				NearBasePerimeterPoints = true,
                
				MaxThreat = 60,
                
				BaseTemplateFile = '/lua/ai/aibuilders/Loud_Expansion_Base_Templates.lua',
				BaseTemplate = 'ExpansionLayout_II',
                
                BuildStructures = {'T3ShieldDefense'},
            }
        }
    },	
}

BuilderGroup {BuilderGroupName = 'Engineer T4 Shield Construction - Expansions',
    BuildersType = 'EngineerBuilder',
	
    Builder {BuilderName = 'Experimental Shield - Expansion',
	
        PlatoonTemplate = 'EngineerBuilder',
        
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
		
        Priority = 750,

		-- this should turn this off if there is less than 30 minutes left in the game
		PriorityFunction = function( self, aiBrain, unit, manager)
			
			if aiBrain.VictoryTime then
			
				if aiBrain.VictoryTime < ( aiBrain.CycleTime + ( 60 * 45 ) ) then	-- less than 45 minutes left
					return 0, false
				end
			end
        
            if GetArmyUnitCostTotal(aiBrain.ArmyIndex) / GetArmyUnitCap(aiBrain.ArmyIndex) > .90 or not GreaterThanEnergyIncome( aiBrain, 50000 ) then
                return 10, true
            end

            if UnitsLessAtLocation( aiBrain, manager.LocationType, 9, SHIELD - categories.ANTIARTILLERY ) then
            
                return 10, true
             
            end

            if UnitsGreaterAtLocation( aiBrain, manager.LocationType, 0, categories.EXPERIMENTAL * categories.SHIELD ) then
            
                return 10, true
             
            end

            return (self.OldPriority or self.Priority), true
		end,

        BuilderConditions = {
			{ EBC, 'GreaterThanEconStorageCurrent', { 400, 5000 }},
            
			{ EBC, 'GreaterThanEconTrendEfficiencyOverTime', { 1.5, 100, 1.012, 1.02 }},
        },
		
        BuilderType = {'SubCommander'},
		
        BuilderData = {
			DesiresAssist = true,
            NumAssistees = 3,
            
            Construction = {
				NearBasePerimeterPoints = true,
                
				MaxThreat = 60,
                
				BaseTemplateFile = '/lua/ai/aibuilders/Loud_Expansion_Base_Templates.lua',
				BaseTemplate = 'ExpansionLayout_II',
                
                BuildStructures = {'T4ShieldDefense'},
            }
        }
    },
}

--- PERIMETER ---
BuilderGroup {BuilderGroupName = 'Engineer Base Defense Construction - Perimeter - Expansions',
    BuildersType = 'EngineerBuilder',
	
    Builder {BuilderName = 'T2 Perimeter PD - Expansion',
    
        PlatoonTemplate = 'EngineerBuilder',
        
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
        
		InstanceCount = 1,
        
        Priority = 710,

        PriorityFunction = function( builder, aiBrain, unit, manager )
        
            if aiBrain.LandRatio >= 1.2 or GetArmyUnitCostTotal(aiBrain.ArmyIndex) / GetArmyUnitCap(aiBrain.ArmyIndex) > .75 or not GreaterThanEnergyIncome( aiBrain, 16800 ) then
            
                return 10, true
               
            end
            
            if UnitsGreaterAtLocationInRange( aiBrain, manager.LocationType, 17, PD * categories.TECH2, 46, 75 ) then
            
                return 10, true
                
            end

            local threat = GetThreatAtPosition( aiBrain, GetPosition(unit), ScenarioInfo.IMAPBlocks, true, 'AntiSurface' )

            if threat > 125 then

                return (builder.OldPriority or builder.Priority) + 100, true
        
            end
    
            return (builder.OldPriority or builder.Priority), true
        end,

        BuilderConditions = {
			{ EBC, 'GreaterThanEconStorageCurrent', { 400, 5000 }},

            { EBC, 'GreaterThanEconTrendEfficiencyOverTime', { 1, 25, 1.012, 1.025 }}, 
        },
		
		BuilderType = { 'T2','T3','SubCommander' },		

        BuilderData = {
            Construction = {
			
				AddRotations = 1,			
				Radius = 55,
                
                NearBasePerimeterPoints = true,
				BasePerimeterOrientation = 'FRONT',
                
				MaxThreat = 60,

				BaseTemplateFile = '/lua/ai/aibuilders/loud_perimeter_defense_templates.lua',
				BaseTemplate = 'PerimeterDefenseExpansionTemplates',
				
                BuildStructures = {'T2GroundDefense','T2GroundDefense'},
            }
        }
    },
	
    Builder {BuilderName = 'T2 Perimeter AA - Expansion',
    
        PlatoonTemplate = 'EngineerBuilder',
        
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
        
		InstanceCount = 1,
        
        Priority = 710,

        PriorityFunction = function( builder, aiBrain, unit, manager )
        
            if aiBrain.AirRatio >= 3 or GetArmyUnitCostTotal(aiBrain.ArmyIndex) / GetArmyUnitCap(aiBrain.ArmyIndex) > .75 or not GreaterThanEnergyIncome( aiBrain, 21000 ) then
            
                return 10, true
               
            end
            
            if UnitsGreaterAtLocationInRange( aiBrain, manager.LocationType, 17, AA * categories.TECH2, 46, 75 ) then
            
                return 10, true
                
            end
    
            return (builder.OldPriority or builder.Priority), true
        end,
	
        PriorityFunction = IsEnemyCrushingAir,
        
        BuilderConditions = {
			{ EBC, 'GreaterThanEconStorageCurrent', { 400, 5000 }},

            { EBC, 'GreaterThanEconTrendEfficiencyOverTime', { 1, 25, 1.012, 1.025 }}, 
        },
		
		BuilderType = { 'T2','T3','SubCommander' },

        BuilderData = {
            Construction = {
			
				AddRotations = 1,
				Radius = 55,

                NearBasePerimeterPoints = true,
				BasePerimeterOrientation = 'FRONT',
                
				MaxThreat = 45,
                
				BaseTemplateFile = '/lua/ai/aibuilders/loud_perimeter_defense_templates.lua',
				BaseTemplate = 'PerimeterDefenseExpansionTemplates',
				
                BuildStructures = {'T2AADefense','T2AADefense','T2MissileDefense'},
            }
        }
    },
	
    Builder {BuilderName = 'T2 Perimeter TMD - Expansion',
    
        PlatoonTemplate = 'EngineerBuilder',
        
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
        
		InstanceCount = 1,
        
        Priority = 710,

        PriorityFunction = function( builder, aiBrain, unit, manager )
        
            if aiBrain.LandRatio >= 2.0 or GetArmyUnitCostTotal(aiBrain.ArmyIndex) / GetArmyUnitCap(aiBrain.ArmyIndex) > .75 or not GreaterThanEnergyIncome( aiBrain, 21000 ) then
            
                return 10, true
               
            end
            
            if UnitsGreaterAtLocationInRange( aiBrain, manager.LocationType, 9, TMD, 46, 75 ) then
            
                return 10, true
                
            end

            if aiBrain.LandRatio <= 1.0  then
	
                return (builder.OldPriority or builder.Priority) + 100, true	

            end
    
            local threat = GetThreatAtPosition( aiBrain, GetPosition(unit), ScenarioInfo.IMAPBlocks, true, 'AntiSurface' )

            if threat > 125 then

                return (builder.OldPriority or builder.Priority) + 100, true
        
            end
    
            return (builder.OldPriority or builder.Priority), true
        end,

        BuilderConditions = {
			{ EBC, 'GreaterThanEconStorageCurrent', { 400, 5000 }},

			{ EBC, 'GreaterThanEconTrendEfficiencyOverTime', { 1, 25, 1.012, 1.025 }}, 
        },
		
		BuilderType = { 'T2' },

        BuilderData = {
            Construction = {
			
				AddRotations = 1,
				Radius = 55,

                NearBasePerimeterPoints = true,
				BasePerimeterOrientation = 'FRONT',
                
				MaxThreat = 50,

				BaseTemplateFile = '/lua/ai/aibuilders/loud_perimeter_defense_templates.lua',
				BaseTemplate = 'PerimeterDefenseExpansionTemplates',
				
                BuildStructures = {'T2MissileDefense'},
            }
        }
    },
	
    Builder {BuilderName = 'T3 Perimeter PD - Expansion',
    
        PlatoonTemplate = 'EngineerBuilder',
        
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
        
        Priority = 710,

        PriorityFunction = function( builder, aiBrain, unit, manager )
        
            if aiBrain.LandRatio >= 1.2 or GetArmyUnitCostTotal(aiBrain.ArmyIndex) / GetArmyUnitCap(aiBrain.ArmyIndex) > .85 or not GreaterThanEnergyIncome( aiBrain, 21000 ) then
            
                return 10, true
               
            end
            
            if UnitsGreaterAtLocationInRange( aiBrain, manager.LocationType, 17, PD * categories.TECH3, 46, 75 ) then
            
                return 10, true
                
            end

            local threat = GetThreatAtPosition( aiBrain, GetPosition(unit), ScenarioInfo.IMAPBlocks, true, 'AntiSurface' )

            if threat > 125 then

                return (builder.OldPriority or builder.Priority) + 100, true
        
            end
    
            return (builder.OldPriority or builder.Priority), true
        end,

        BuilderConditions = {
			{ LUTL, 'FactoryGreaterAtLocation', { 'LocationType', 3, FACTORY - categories.TECH1 }},

			{ TBC, 'ThreatCloserThan', { 'LocationType', 350, 75, 'AntiSurface' }},

			{ EBC, 'GreaterThanEconStorageCurrent', { 400, 5000 }},

            { EBC, 'GreaterThanEconTrendEfficiencyOverTime', { 1, 25, 1.012, 1.025 }}, 
        },
		
		BuilderType = { 'T3','SubCommander' },

        BuilderData = {
			DesiresAssist = true,
			NumAssistees = 2,
            Construction = {
			
				AddRotations = 1,
				Radius = 55,

                NearBasePerimeterPoints = true,
				BasePerimeterOrientation = 'FRONT',
                
                MaxThreat = 100,
				
				BaseTemplateFile = '/lua/ai/aibuilders/loud_perimeter_defense_templates.lua',
				BaseTemplate = 'PerimeterDefenseExpansionTemplates',
				
                BuildStructures = {'T3GroundDefense','T3GroundDefense'},
            }
        }
    },
	
    Builder {BuilderName = 'T3 Perimeter AA - Expansion',
    
        PlatoonTemplate = 'EngineerBuilder',
        
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
        
        Priority = 710,

        PriorityFunction = function( builder, aiBrain, unit, manager )
        
            if aiBrain.AirRatio >= 3.0 or GetArmyUnitCostTotal(aiBrain.ArmyIndex) / GetArmyUnitCap(aiBrain.ArmyIndex) > .85 or not GreaterThanEnergyIncome( aiBrain, 21000 ) then
            
                return 10, true
               
            end
            
            if UnitsGreaterAtLocationInRange( aiBrain, manager.LocationType, 17, AA * categories.TECH3, 46, 75 ) then
            
                return 10, true
                
            end
    
            return (builder.OldPriority or builder.Priority), true
        end,

        BuilderConditions = {
			{ LUTL, 'FactoryGreaterAtLocation', { 'LocationType', 3, FACTORY - categories.TECH1 }},

			{ TBC, 'ThreatCloserThan', { 'LocationType', 500, 35, 'Air' }},

			{ EBC, 'GreaterThanEconStorageCurrent', { 400, 5000 }},

            { EBC, 'GreaterThanEconTrendEfficiencyOverTime', { 1, 25, 1.012, 1.025 }},
        },
		
		BuilderType = { 'T3','SubCommander' },

        BuilderData = {
			DesiresAssist = true,
            NumAssistees = 2,
            Construction = {
			
				AddRotations = 1,
				Radius = 55,
				
                NearBasePerimeterPoints = true,
				BasePerimeterOrientation = 'FRONT',
                
                MaxThreat = 75,
				
				BaseTemplateFile = '/lua/ai/aibuilders/loud_perimeter_defense_templates.lua',
				BaseTemplate = 'PerimeterDefenseExpansionTemplates',
				
                BuildStructures = {'T3AADefense','T3AADefense'},
            }
        }
    },
	
    Builder {BuilderName = 'T3 Perimeter TMD - Expansion',
    
        PlatoonTemplate = 'EngineerBuilder',
        
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
        
		InstanceCount = 1,
        
        Priority = 710,

        PriorityFunction = function( builder, aiBrain, unit, manager )
        
            if aiBrain.LandRatio >= 2.0 or GetArmyUnitCostTotal(aiBrain.ArmyIndex) / GetArmyUnitCap(aiBrain.ArmyIndex) > .85 or not GreaterThanEnergyIncome( aiBrain, 21000 ) then
            
                return 10, true
               
            end
            
            if UnitsGreaterAtLocationInRange( aiBrain, manager.LocationType, 8, TMD, 46, 75 ) then
            
                return 10, true
                
            end

            if aiBrain.LandRatio <= 1.0  then
	
                return (builder.OldPriority or builder.Priority) + 100, true	

            end
    
            local threat = GetThreatAtPosition( aiBrain, GetPosition(unit), ScenarioInfo.IMAPBlocks, true, 'AntiSurface' )

            if threat > 125 then

                return (builder.OldPriority or builder.Priority) + 100, true
        
            end
    
            return (builder.OldPriority or builder.Priority), true
        end,

        BuilderConditions = {
			{ EBC, 'GreaterThanEconStorageCurrent', { 400, 5000 }},

			{ EBC, 'GreaterThanEconTrendEfficiencyOverTime', { 1, 25, 1.012, 1.025 }}, 

			-- check perimeter for less than 9 TMD
            { UCBC, 'UnitsLessAtLocationInRange', { 'LocationType', 9, TMD, 46, 75 }},
        },
		
		BuilderType = { 'T3','SubCommander' },

        BuilderData = {
            Construction = {
			
				AddRotations = 1,
				Radius = 55,

                NearBasePerimeterPoints = true,
				BasePerimeterOrientation = 'FRONT',
                
				MaxThreat = 50,

				BaseTemplateFile = '/lua/ai/aibuilders/loud_perimeter_defense_templates.lua',
				BaseTemplate = 'PerimeterDefenseExpansionTemplates',
				
                BuildStructures = {'T3MissileDefense'},
            }
        }
    },

    Builder {BuilderName = 'T3 Perimeter Shields - Expansion',
    
        PlatoonTemplate = 'EngineerBuilder',
        
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
        
        Priority = 710,

        PriorityFunction = function( builder, aiBrain, unit, manager )
        
            if GetArmyUnitCostTotal(aiBrain.ArmyIndex) / GetArmyUnitCap(aiBrain.ArmyIndex) > .85 or not GreaterThanEnergyIncome( aiBrain, 21000 ) then
            
                return 10, true
               
            end

            if UnitsGreaterAtLocationInRange( aiBrain, manager.LocationType, 8, SHIELD - categories.ANTIARTILLERY, 46, 75 ) then
            
                return 10, true
             
            end

            if aiBrain.LandRatio <= 1.0 and aiBrain.CycleTime > 900 then
	
                return (builder.OldPriority or builder.Priority) + 100, true	

            end
    
            local threat = GetThreatAtPosition( aiBrain, GetPosition(unit), ScenarioInfo.IMAPBlocks, true, 'AntiSurface' )

            if threat > 125 then

                return (builder.OldPriority or builder.Priority) + 100, true
        
            end
    
            return (builder.OldPriority or builder.Priority), true
        end,

        BuilderConditions = {
			{ LUTL, 'FactoryGreaterAtLocation', { 'LocationType', 3, FACTORY - categories.TECH1 }},
            
			{ TBC, 'ThreatCloserThan', { 'LocationType', 350, 75, 'AntiSurface' }},

			{ EBC, 'GreaterThanEconStorageCurrent', { 400, 5000 }},
            
            { EBC, 'GreaterThanEconTrendEfficiencyOverTime', { 1.5, 50, 1.012, 1.02 }},
        },
		
		BuilderType = { 'T3','SubCommander' },

        BuilderData = {
			DesiresAssist = true,
			NumAssistees = 2,
            Construction = {
			
				AddRotations = 1,
				Radius = 55,

                NearBasePerimeterPoints = true,
				BasePerimeterOrientation = 'FRONT',
                
                MaxThreat = 75,
				
				BaseTemplateFile = '/lua/ai/aibuilders/loud_perimeter_defense_templates.lua',
				BaseTemplate = 'PerimeterDefenseExpansionTemplates',
				
                BuildStructures = {'T3ShieldDefense'},
            }
        }
    },

}

-- AIRSTAGING, etc.
BuilderGroup {BuilderGroupName = 'Engineer Misc Construction - Expansions',
    BuildersType = 'EngineerBuilder',
	
    Builder {BuilderName = 'Air Staging - Expansion',
	
        PlatoonTemplate = 'EngineerBuilder',
        
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
		
        Priority = 775,
        
        PriorityFunction = function( self, aiBrain, unit, manager)
        
            if GetArmyUnitCostTotal(aiBrain.ArmyIndex) / GetArmyUnitCap(aiBrain.ArmyIndex) > .95 then
                return 10, true
            end

            if UnitsGreaterAtLocation( aiBrain, manager.LocationType, 0, categories.AIRSTAGINGPLATFORM ) then
            
                return 10, true
             
            end
    
            return (self.OldPriority or self.Priority), true
        end,

        BuilderConditions = {
			{ EBC, 'GreaterThanEconStorageCurrent', { 250, 2500 }},
        },
		
        BuilderType = {'T2','T3','SubCommander'},
		
        BuilderData = {
			DesiresAssist = true,
			Construction = {
                NearBasePerimeterPoints = true,

				BaseTemplateFile = '/lua/ai/aibuilders/Loud_Expansion_Base_Templates.lua',
				BaseTemplate = 'ExpansionLayout_II',
                
                MaxThreat = 75,
				
                BuildStructures = {'T2AirStagingPlatform'},
            }
        }
    },	
	
    Builder {BuilderName = 'T2 Radar Jamming - Expansion',
	
        PlatoonTemplate = 'EngineerBuilder',
        
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
		
        Priority = 745,
        
        PriorityFunction = AboveUnitCap75,
		
        BuilderConditions = {
			{ LUTL, 'GreaterThanEnergyIncome', { 16800 }},

			{ EBC, 'GreaterThanEconStorageCurrent', { 300, 3000 }},
            
            { EBC, 'GreaterThanEconTrendEfficiencyOverTime', { 1, 25, 1.012, 1.02 }}, 

            { UCBC, 'UnitsLessAtLocation', { 'LocationType', 3, categories.COUNTERINTELLIGENCE * categories.STRUCTURE }},
        },
		
        BuilderType = {'T2','T3'},
		
        BuilderData = {
			Construction = {
			
				Radius = 1,			
				NearBasePerimeterPoints = true,
				
				MaxThreat = 30,
				
				BasePerimeterOrientation = 'FRONT',

				BaseTemplateFile = '/lua/ai/aibuilders/Loud_Expansion_Base_Templates.lua',
				BaseTemplate = 'ExpansionLayout_II',
				
                BuildStructures = {'T2RadarJammer'},
            }
        }
    },
	
    Builder {BuilderName = 'T3 Teleport Jamming - Expansion',
	
        PlatoonTemplate = 'EngineerBuilder',
        
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
		
        Priority = 0,
		
        BuilderConditions = {
            { LUTL, 'UnitCapCheckLess', { .75 } },

			{ LUTL, 'GreaterThanEnergyIncome', { 21000 }},

			-- trigger this build if enemy has an Aeon scry device
			--{ LUTL, 'HaveGreaterThanUnitsWithCategoryAndAlliance', { 0, categories.AEON * categories.OPTICS * categories.STRUCTURE, 'Enemy' }},

			{ EBC, 'GreaterThanEconStorageCurrent', { 400, 5000 }},

            { EBC, 'GreaterThanEconTrendEfficiencyOverTime', { 1.5, 50, 1.012, 1.02 }}, 

            { UCBC, 'UnitsLessAtLocation', { 'LocationType', 4, categories.ANTITELEPORT * categories.STRUCTURE * categories.TECH3 }},

        },
		
        BuilderType = {'T3','SubCommander'},
		
        BuilderData = {
		
			Construction = {
			
				Radius = 1,
				NearBasePerimeterPoints = true,
				
				BasePerimeterOrientation = 'FRONT',

				BaseTemplateFile = '/lua/ai/aibuilders/Loud_Expansion_Base_Templates.lua',
				BaseTemplate = 'ExpansionLayout_II',
				
                BuildStructures = {'T3TeleportJammer'},
            }
        }
    },	
	
}


------------------------
--- NAVAL EXPANSIONS ---

BuilderGroup {BuilderGroupName = 'Engineer Base Defense Construction - Naval',
    BuildersType = 'EngineerBuilder',

    Builder {BuilderName = 'T2 Defenses Naval',
	
        PlatoonTemplate = 'EngineerBuilder',
        
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
		
        Priority = 750,
		
		PriorityFunction = IsEnemyNavalActive,		
		
        BuilderConditions = {
            { LUTL, 'UnitCapCheckLess', { .75 } },

			{ LUTL, 'FactoryGreaterAtLocation', { 'LocationType', 1, FACTORY }},

			{ LUTL, 'NavalStrengthRatioLessThan', { 1.5 } },

			{ EBC, 'GreaterThanEconStorageCurrent', { 300, 3000 }},

            { EBC, 'GreaterThanEconTrendEfficiencyOverTime', { 0.8, 15, 1.01, 1.02 }},

            { UCBC, 'UnitsLessAtLocationInRange', { 'LocationType', 18, categories.STRUCTURE * categories.ANTINAVY * categories.TECH2, 50, 85 }},
        },
		
		BuilderType = { 'T2','T3','SubCommander'},

        BuilderData = {
		
			DesiresAssist = true,
        
            Construction = {
			
				Radius = 63,
				AddRotations = 1,
                NearBasePerimeterPoints = true,
                
				BasePerimeterOrientation = 'FRONT',
				BasePerimeterSelection = true,
                
				ThreatMax = 90,

				BaseTemplateFile = '/lua/ai/aibuilders/loud_perimeter_defense_templates.lua',
				BaseTemplate = 'NavalPerimeterDefenseTemplate',
				
                BuildStructures = {'T2NavalDefense',
                    'T2GroundDefenseAmphibious',                
					'T2MissileDefense',
                    'T2NavalDefense',
                },
            }
        }
    },

    Builder {BuilderName = 'T2 AA Defenses - Naval',
	
        PlatoonTemplate = 'EngineerBuilder',
        
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
		
        Priority = 750,
        
        PriorityFunction = IsEnemyCrushingAir,
		
        BuilderConditions = {
            { LUTL, 'UnitCapCheckLess', { .75 } },
            
            { LUTL, 'AirStrengthRatioLessThan', { 1.5 }},
            
			{ LUTL, 'FactoryGreaterAtLocation', { 'LocationType', 1, FACTORY }},
            
			{ EBC, 'GreaterThanEconStorageCurrent', { 250, 2500 }},
            
            { UCBC, 'UnitsLessAtLocationInRange', { 'LocationType', 9, AA * categories.TECH2, 50, 85 }},
        },
		
		BuilderType = { 'T2','T3' },

        BuilderData = {
            
            Construction = {
			
				Radius = 63,
				AddRotations = 1,
                NearBasePerimeterPoints = true,
                
				BasePerimeterOrientation = 'FRONT',
				BasePerimeterSelection = true,
                
				ThreatMax = 60,

				BaseTemplateFile = '/lua/ai/aibuilders/loud_perimeter_defense_templates.lua',
				BaseTemplate = 'NavalPerimeterDefenseTemplate',
				
                BuildStructures = {'T2AADefenseAmphibious'},
            }
        }
    },
	
    Builder {BuilderName = 'T3 Defenses Naval',
	
        PlatoonTemplate = 'EngineerBuilder',
        
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
		
        Priority = 750,
		
		PriorityFunction = IsEnemyNavalActive,		
		
        BuilderConditions = {
            { LUTL, 'UnitCapCheckLess', { .85 } },
            
            { LUTL, 'NavalStrengthRatioLessThan', { 2 } },
            
			{ LUTL, 'FactoryGreaterAtLocation', { 'LocationType', 2, FACTORY - categories.TECH1 }},

			{ EBC, 'GreaterThanEconStorageCurrent', { 400, 5000 }},

            { EBC, 'GreaterThanEconTrendEfficiencyOverTime', { 0.8, 15, 1.01, 1.02 }},

            { UCBC, 'UnitsLessAtLocationInRange', { 'LocationType', 9, categories.STRUCTURE * categories.ANTINAVY * categories.TECH3, 50, 85 }},
        },
		
		BuilderType = { 'T3','SubCommander'},

        BuilderData = {
		
			DesiresAssist = true,
			
            Construction = {
			
				Radius = 63,
				AddRotations = 1,
                NearBasePerimeterPoints = true,
				
				ThreatMax = 100,
				
				BasePerimeterOrientation = 'FRONT',
				BasePerimeterSelection = true,
				
				BaseTemplateFile = '/lua/ai/aibuilders/loud_perimeter_defense_templates.lua',
				BaseTemplate = 'NavalPerimeterDefenseTemplate',
				
                BuildStructures = {'T3NavalDefense'},
            }
        }
    },
	
    Builder {BuilderName = 'T3 Base AA - Naval',
	
        PlatoonTemplate = 'EngineerBuilder',
        
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
		
        Priority = 750,
        
        PriorityFunction = IsEnemyCrushingAir,

        BuilderConditions = {
            { LUTL, 'UnitCapCheckLess', { .85 } },
            
            { LUTL, 'AirStrengthRatioLessThan', { 1.5 }},
            
			{ LUTL, 'FactoryGreaterAtLocation', { 'LocationType', 1, FACTORY - categories.TECH1 }},

			{ EBC, 'GreaterThanEconStorageCurrent', { 300, 3000 }},

            { EBC, 'GreaterThanEconTrendEfficiencyOverTime', { 0.8, 15, 1.01, 1.02 }},

            { UCBC, 'UnitsLessAtLocationInRange', { 'LocationType', 8, AA * categories.TECH3, 1, 40 }},
        },
		
		BuilderType = { 'T3','SubCommander'},

        BuilderData = {

            Construction = {
                NearBasePerimeterPoints = true,
				
				ThreatMax = 75,

				BasePerimeterSelection = true,

				BaseTemplateFile = '/lua/ai/aibuilders/Loud_Expansion_Base_Templates.lua',
				BaseTemplate = 'NavalExpansionBase',
				
                BuildStructures = {'T3AADefense'},
            }
        }
    },	

    Builder {BuilderName = 'Naval AntiNuke',
	
        PlatoonTemplate = 'EngineerBuilder',
        
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
		
        Priority = 850,

        BuilderConditions = {
			{ LUTL, 'GreaterThanEnergyIncome', { 21000 }},
            
			{ LUTL, 'FactoryGreaterAtLocation', { 'LocationType', 1, categories.NAVAL * categories.TECH3 }},
            
            { EBC, 'GreaterThanEconTrendEfficiencyOverTime', { 1, 30, 1.02, 1.02 }},
            
			{ UCBC, 'UnitsLessAtLocation', { 'LocationType', 1, SMD }},
        },
		
        BuilderType = {'SubCommander'},
		
        BuilderData = {
        
			DesiresAssist = true,
			
            Construction = {
                NearBasePerimeterPoints = true,
                
				ThreatMax = 60,
				
				BaseTemplateFile = '/lua/ai/aibuilders/Loud_Expansion_Base_Templates.lua',
				BaseTemplate = 'NavalExpansionBase',
				
                BuildStructures = {'T3StrategicMissileDefense'},
            }
        }
    },

--[[	
    Builder {BuilderName = 'T1 Defenses Naval',
	
        PlatoonTemplate = 'EngineerBuilder',
        
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
		
        Priority = 800,
		
		PriorityFunction = function(self, aiBrain)
		
			if self.Priority != 0 then

				-- remove after 40 minutes
				if aiBrain.CycleTime > 2400 then
					return 0, false
				end
				
			end
			
			return self.Priority
			
		end,
		
        BuilderConditions = {
            { LUTL, 'UnitCapCheckLess', { .65 } },
            
            -- obsolete once T2 or better available
			{ UCBC, 'FactoryLessAtLocation', { 'LocationType', 1, FACTORY - categories.TECH1 }},
            
			{ EBC, 'GreaterThanEconStorageCurrent', { 175, 1250 }},

            { UCBC, 'UnitsLessAtLocationInRange', { 'LocationType', 9, categories.STRUCTURE * categories.ANTINAVY, 50, 85 }},
        },
		
		BuilderType = { 'T1','T2'},

        BuilderData = {
            Construction = {
			
				Radius = 63,
				AddRotations = 1,
                NearBasePerimeterPoints = true,
                
				BasePerimeterOrientation = 'FRONT',
				BasePerimeterSelection = true,
                
				ThreatMax = 90,

				BaseTemplateFile = '/lua/ai/aibuilders/loud_perimeter_defense_templates.lua',
				BaseTemplate = 'NavalPerimeterDefenseTemplate',
				
                BuildStructures = {'T1NavalDefense'},
            }
        }
    },
--]]	
	
}

BuilderGroup {BuilderGroupName = 'Engineer Misc Construction - Naval',
    BuildersType = 'EngineerBuilder',
	
    Builder {BuilderName = 'Naval AirStaging',
	
        PlatoonTemplate = 'EngineerBuilder',
        
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
		
        Priority = 751,
        
        PriorityFunction = AboveUnitCap75,
		
        BuilderConditions = {
            { LUTL, 'UnitCapCheckLess', { .75 } },

			{ EBC, 'GreaterThanEconStorageCurrent', { 250, 2500 }},

			{ UCBC, 'UnitsLessAtLocation', { 'LocationType', 1, categories.AIRSTAGINGPLATFORM }},
        },
		
		BuilderType = { 'T2','T3' },

        BuilderData = {
            Construction = {
                NearBasePerimeterPoints = true,

				BaseTemplateFile = '/lua/ai/aibuilders/Loud_Expansion_Base_Templates.lua',
				BaseTemplate = 'NavalExpansionBase',
                
                MaxThreat = 75,
				
                BuildStructures = {'T2AirStagingPlatform' },
            }
        }
    },	
	
}


------------------------
--- DEFENSIVE POINTS ---

BuilderGroup {BuilderGroupName = 'Engineer Defenses DP Standard',
	BuildersType = 'EngineerBuilder',
	
    Builder {BuilderName = 'T2 DP STD Power',
	
        PlatoonTemplate = 'EngineerBuilder',
        
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
		
        Priority = 750,

        BuilderConditions = {
            { LUTL, 'UnitsGreaterAtLocation', { 'LocationType', 0, AA }},

            { LUTL, 'UnitsLessAtLocation', { 'LocationType', 1, ENERGY }},

			{ TBC, 'ThreatFurtherThan', { 'LocationType', 150, 'Land', 125 }},            
        
			{ EBC, 'LessThanEnergyTrend', { 45 }},        
			{ EBC, 'LessThanEnergyTrendOverTime', { 40 }},
			{ EBC, 'LessThanEconEnergyStorageRatio', { 80 }},

			{ EBC, 'GreaterThanEconStorageCurrent', { 400, 5000 }},
        },
		
		BuilderType = { 'T3','SubCommander' },

        BuilderData = {
			DesiresAssist = true,
			
            Construction = {
				NearBasePerimeterPoints = true,
                
                ThreatMax = 40,
                
				BaseTemplateFile = '/lua/ai/aibuilders/Loud_DP_Templates.lua',
				BaseTemplate = 'DefensivePointSmall',
                
                BuildStructures = {'T2EnergyProduction'}
            }
        }
    },	

    Builder {BuilderName = 'T2 DP STD Artillery',
	
        PlatoonTemplate = 'EngineerBuilder',
        
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
		
		InstanceCount = 1,
        
        Priority = 751,

        PriorityFunction = IsEnemyCrushingLand,
		
        BuilderConditions = {
            { LUTL, 'UnitCapCheckLess', { .85 } },

			{ LUTL, 'GreaterThanEnergyIncome', { 12600 }},

			{ TBC, 'ThreatCloserThan', { 'LocationType', 350, 75, 'AntiSurface' }},

			{ EBC, 'GreaterThanEconStorageCurrent', { 400, 5000 }},

			{ EBC, 'GreaterThanEconTrendEfficiencyOverTime', { 1, 30, 1.01, 1.02 }},

            { UCBC, 'UnitsLessAtLocation', { 'LocationType', 4, categories.STRUCTURE * categories.ARTILLERY * categories.TECH2 }},
        },
		
		BuilderType = { 'T2','T3','SubCommander' },

        BuilderData = {
			DesiresAssist = true,
            NumAssistees = 2,
            
            Construction = {
	            NearBasePerimeterPoints = true,
                
                ThreatMax = 100,

				BaseTemplateFile = '/lua/ai/aibuilders/LOUD_DP_Templates.lua',
				BaseTemplate = 'DefensivePointSmall',
				
                BuildStructures = {'T2Artillery'},
            }
        }
    },

    Builder {BuilderName = 'T2 DP STD PD',
	
        PlatoonTemplate = 'EngineerBuilder',
        
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
        
        Priority = 751,
        
        PriorityFunction = AboveUnitCap75,

        BuilderConditions = {
            { LUTL, 'LandStrengthRatioLessThan', { 2 } },

			{ TBC, 'ThreatCloserThan', { 'LocationType', 350, 75, 'AntiSurface' }},

			{ EBC, 'GreaterThanEconStorageCurrent', { 400, 5000 }},

            { EBC, 'GreaterThanEconTrendEfficiencyOverTime', { 0.9, 20, 1.012, 1.02 }},

            { UCBC, 'UnitsLessAtLocation', { 'LocationType', 4, PD * categories.TECH2 }},
        },
		
		BuilderType = { 'T2','T3','SubCommander' },

        BuilderData = {
		
			DesiresAssist = true,
			
            Construction = {
			
				NearBasePerimeterPoints = true,

                ThreatMin = 20,
                ThreatMax = 125,
                
				BaseTemplateFile = '/lua/ai/aibuilders/Loud_DP_Templates.lua',
				BaseTemplate = 'DefensivePointSmall',
				
                BuildStructures = {'T2GroundDefense','T2GroundDefense'}
            }
        }
		
    },
	
    Builder {BuilderName = 'T2 DP STD AA',
	
        PlatoonTemplate = 'EngineerBuilder',
        
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
        
        Priority = 751,
        
        PriorityFunction = IsEnemyCrushingAir,
		
        BuilderConditions = {
            { LUTL, 'UnitCapCheckLess', { .75 } },

            { LUTL, 'AirStrengthRatioLessThan', { 1.5 }},

			{ EBC, 'GreaterThanEconStorageCurrent', { 250, 2500 }},

            { EBC, 'GreaterThanEconTrendEfficiencyOverTime', { 0.8, 15, 1.01, 1.02 }},

            -- less than 4 AA guns at location - total
            { UCBC, 'UnitsLessAtLocation', { 'LocationType', 4, AA }},
        },
		
		BuilderType = { 'T2','T3','SubCommander' },

        BuilderData = {
		
			DesiresAssist = true,
			
            Construction = {
			
				NearBasePerimeterPoints = true,

                ThreatMin = 20,
                ThreatMax = 90,
                
				BaseTemplateFile = '/lua/ai/aibuilders/Loud_DP_Templates.lua',
				BaseTemplate = 'DefensivePointSmall',
				
                BuildStructures = {'T2AADefense',
					'T2AADefense',
					'Wall',
					'T2Wall',
					'Wall',
					'T2Wall',
					'Wall',
					'T2Wall',
					'Wall',
					'T2Wall',
					'Wall',
					'T2Wall',
                }
            }
        }
		
    },

    Builder {BuilderName = 'DP STD Radar',
	
        PlatoonTemplate = 'EngineerBuilder',
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
		
        Priority = 751,

        BuilderConditions = {
            { LUTL, 'UnitsGreaterAtLocation', { 'LocationType', 0, AA }},

            { LUTL, 'UnitsLessAtLocation', { 'LocationType', 1, categories.STRUCTURE * categories.OVERLAYRADAR * categories.INTELLIGENCE }},
            
            { LUTL, 'UnitCapCheckLess', { .95 } },

			{ EBC, 'GreaterThanEconStorageCurrent', { 400, 5000 }},

            { EBC, 'GreaterThanEconTrendEfficiencyOverTime', { 0.9, 25, 1.012, 1.025 }},
        },
		
		BuilderType = { 'T2','T3','SubCommander' },

        BuilderData = {
			
            Construction = {
				NearBasePerimeterPoints = true,
                
                ThreatMax = 60,
                
				BaseTemplateFile = '/lua/ai/aibuilders/Loud_DP_Templates.lua',
				BaseTemplate = 'DefensivePointSmall',
                
                BuildStructures = {'T2Radar'}
            }
        }
    },
	
    Builder {BuilderName = 'T2 DP STD AirStaging',
	
        PlatoonTemplate = 'EngineerBuilder',
        
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
		
        Priority = 751,
        
        PriorityFunction = AboveUnitCap85,

        BuilderConditions = {
            { LUTL, 'UnitsGreaterAtLocation', { 'LocationType', 0, AA }},

			{ EBC, 'GreaterThanEconStorageCurrent', { 300, 3000 }},

            { UCBC, 'UnitsLessAtLocation', { 'LocationType', 1, categories.AIRSTAGINGPLATFORM }},
        },
		
		BuilderType = { 'T2','T3','SubCommander' },

        BuilderData = {
			DesiresAssist = true,
			
            Construction = {
				NearBasePerimeterPoints = true,
                
                ThreatMax = 60,
                
				BaseTemplateFile = '/lua/ai/aibuilders/Loud_DP_Templates.lua',
				BaseTemplate = 'DefensivePointSmall',
                
                BuildStructures = {'T2AirStagingPlatform'}
            }
        }
    },	

    Builder {BuilderName = 'T2 DP STD Shields',
	
        PlatoonTemplate = 'EngineerBuilder',
        
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
		
        Priority = 751,
        
        PriorityFunction = AboveUnitCap75,
		
        BuilderConditions = {
            { LUTL, 'UnitsGreaterAtLocation', { 'LocationType', 0, AA }},
            
			{ EBC, 'GreaterThanEconStorageCurrent', { 300, 3000 }},

            { EBC, 'GreaterThanEconTrendEfficiencyOverTime', { 0.9, 20, 1.012, 1.02 }},
            
            { UCBC, 'UnitsLessAtLocation', { 'LocationType', 1, SHIELD - categories.ANTIARTILLERY }},
        },
		
		BuilderType = { 'T2','T3' },

        BuilderData = {
			DesiresAssist = true,
			
            Construction = {
				NearBasePerimeterPoints = true,
                
                ThreatMax = 90,
                
				BaseTemplateFile = '/lua/ai/aibuilders/Loud_DP_Templates.lua',
				BaseTemplate = 'DefensivePointSmall',
                
                BuildStructures = {'T2ShieldDefense'}
            }
        }
    },

    Builder {BuilderName = 'T3 DP STD Shields',
	
        PlatoonTemplate = 'EngineerBuilder',
        
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
		
        Priority = 751,
		
        BuilderConditions = {
			{ LUTL, 'GreaterThanEnergyIncome', { 16800 }},
            
            { LUTL, 'UnitCapCheckLess', { .85 } },

			{ TBC, 'ThreatCloserThan', { 'LocationType', 350, 75, 'AntiSurface' }},

			{ EBC, 'GreaterThanEconStorageCurrent', { 400, 5000 }},

            { EBC, 'GreaterThanEconTrendEfficiencyOverTime', { 1, 30, 1.012, 1.025 }},

            { UCBC, 'UnitsLessAtLocation', { 'LocationType', 2, SHIELD - categories.ANTIARTILLERY }},
        },
		
		BuilderType = { 'T3','SubCommander' },

        BuilderData = {
			DesiresAssist = true,
			
            Construction = {
				NearBasePerimeterPoints = true,
                
                ThreatMax = 75,
                
				BaseTemplateFile = '/lua/ai/aibuilders/Loud_DP_Templates.lua',
				BaseTemplate = 'DefensivePointSmall',
                
                BuildStructures = {'T3ShieldDefense'}
            }
        }
    },


    Builder {BuilderName = 'T3 DP STD AA',
	
        PlatoonTemplate = 'EngineerBuilder',
        
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
		
        Priority = 750,
        
        PriorityFunction = IsEnemyCrushingAir,
		
        BuilderConditions = {
            { LUTL, 'UnitCapCheckLess', { .85 } },

            { LUTL, 'AirStrengthRatioLessThan', { 1.5 }},

			{ EBC, 'GreaterThanEconStorageCurrent', { 300, 3000 }},

            { EBC, 'GreaterThanEconTrendEfficiencyOverTime', { 0.9, 20, 1.012, 1.02 }},

            { UCBC, 'UnitsLessAtLocation', { 'LocationType', 4, AA * categories.TECH3 }},
        },
		
		BuilderType = { 'T3','SubCommander' },

        BuilderData = {
			DesiresAssist = true,
			
            Construction = {
				NearBasePerimeterPoints = true,
                
                ThreatMax = 90,
                
				BaseTemplateFile = '/lua/ai/aibuilders/Loud_DP_Templates.lua',
				BaseTemplate = 'DefensivePointSmall',
                
                BuildStructures = {'T3AADefense','T3AADefense'}
            }
        }
    },

    Builder {BuilderName = 'T3 DP STD PD',
	
        PlatoonTemplate = 'EngineerBuilder',
        
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
		
        Priority = 750,
		
        BuilderConditions = {
            { LUTL, 'UnitCapCheckLess', { .85 } },
            
            { LUTL, 'LandStrengthRatioLessThan', { 3 } },

			{ TBC, 'ThreatCloserThan', { 'LocationType', 350, 75, 'AntiSurface' }},

			{ EBC, 'GreaterThanEconStorageCurrent', { 400, 5000 }},

            { EBC, 'GreaterThanEconTrendEfficiencyOverTime', { 1, 30, 1.012, 1.02 }}, 
            
            { UCBC, 'UnitsLessAtLocation', { 'LocationType', 4, categories.STRUCTURE * categories.DEFENSE * categories.TECH3 * categories.DIRECTFIRE }},
        },
		
		BuilderType = { 'T3','SubCommander' },

        BuilderData = {
			DesiresAssist = true,
			
            Construction = {
				NearBasePerimeterPoints = true,
                
                ThreatMax = 120,
                
				BaseTemplateFile = '/lua/ai/aibuilders/Loud_DP_Templates.lua',
				BaseTemplate = 'DefensivePointSmall',
                
                BuildStructures = {'T3GroundDefense','T3GroundDefense'}
            }
        }
    },

	
    Builder {BuilderName = 'T2 DP STD Walls',
	
        PlatoonTemplate = 'EngineerBuilder',
        
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
		
        Priority = 750,
        
        PriorityFunction = AboveUnitCap75,

        BuilderConditions = {
			{ TBC, 'ThreatCloserThan', { 'LocationType', 350, 75, 'AntiSurface' }},

			{ EBC, 'GreaterThanEconStorageCurrent', { 400, 5000 }},

            { EBC, 'GreaterThanEconTrendEfficiencyOverTime', { 0.8, 15, 1.01, 1.02 }},

            { UCBC, 'UnitsLessAtLocation', { 'LocationType', 47, categories.WALL }},
        },
		
		BuilderType = { 'T2','T3','SubCommander' },

        BuilderData = {
			
            Construction = {
				NearBasePerimeterPoints = true,
                
                ThreatMax = 120,
                
				BaseTemplateFile = '/lua/ai/aibuilders/Loud_DP_Templates.lua',
				BaseTemplate = 'DefensivePointSmall',
                
                BuildStructures = {'T2Wall','Wall','T2Wall','Wall','T2Wall'}
            }
        }
    },	

    Builder {BuilderName = 'T2 DP STD TMD',
	
        PlatoonTemplate = 'EngineerBuilder',
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
		
        Priority = 751,

        BuilderConditions = {
            { LUTL, 'UnitCapCheckLess', { .85 } },

			{ EBC, 'GreaterThanEconStorageCurrent', { 250, 2500 }},

            { EBC, 'GreaterThanEconTrendEfficiencyOverTime', { 0.8, 15, 1.01, 1.02 }},
        
            { LUTL, 'UnitsLessAtLocation', { 'LocationType', 4, TMD }},
        },
		
		BuilderType = { 'T2' },

        BuilderData = {
			
            Construction = {
				NearBasePerimeterPoints = true,
                
                ThreatMax = 150,
                
				BaseTemplateFile = '/lua/ai/aibuilders/Loud_DP_Templates.lua',
				BaseTemplate = 'DefensivePointSmall',
                
                BuildStructures = {'T2MissileDefense'}
            }
        }
    },

	
    Builder {BuilderName = 'T2 DP STD Jammer',
	
        PlatoonTemplate = 'EngineerBuilder',
        
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
		
        Priority = 750,
        
        PriorityFunction = AboveUnitCap75,

        BuilderConditions = {
			{ TBC, 'ThreatCloserThan', { 'LocationType', 350, 75, 'AntiSurface' }},

			{ EBC, 'GreaterThanEconStorageCurrent', { 400, 5000 }},

            { EBC, 'GreaterThanEconTrendEfficiencyOverTime', { 0.9, 25, 1.012, 1.025 }},

            { UCBC, 'UnitsLessAtLocation', { 'LocationType', 1, categories.COUNTERINTELLIGENCE * categories.STRUCTURE }},
        },
		
		BuilderType = { 'T2','T3','SubCommander' },

        BuilderData = {
			DesiresAssist = true,
			
            Construction = {
				NearBasePerimeterPoints = true,
                
                ThreatMax = 75,
                
				BaseTemplateFile = '/lua/ai/aibuilders/Loud_DP_Templates.lua',
				BaseTemplate = 'DefensivePointSmall',
                
                BuildStructures = {'T2RadarJammer'}
            }
        }
    },	
	
    Builder {BuilderName = 'T2 DP STD TML',
	
        PlatoonTemplate = 'EngineerBuilder',
        
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
		
        Priority = 750,
        
        PriorityFunction = AboveUnitCap75,

        BuilderConditions = {
			{ TBC, 'ThreatCloserThan', { 'LocationType', 350, 75, 'AntiSurface' }},

			{ EBC, 'GreaterThanEconStorageCurrent', { 400, 5000 }},

            { EBC, 'GreaterThanEconTrendEfficiencyOverTime', { 1, 30, 1.02, 1.04 }}, 
            
            { UCBC, 'UnitsLessAtLocation', { 'LocationType', 4, categories.TACTICALMISSILEPLATFORM * categories.STRUCTURE }},			
        },
		
        BuilderType = {'T2','T3','SubCommander' },
		
        BuilderData = {
            Construction = {
                NearBasePerimeterPoints = true,
				
				ThreatMax = 60,
				
				BaseTemplateFile = '/lua/ai/aibuilders/Loud_DP_Templates.lua',
				BaseTemplate = 'DefensivePointSmall',
				
                BuildStructures = {'T2StrategicMissile'},
            }
        }
    },

    Builder {BuilderName = 'T3 DP STD TMD',
	
        PlatoonTemplate = 'EngineerBuilder',
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
		
        Priority = 750,

        BuilderConditions = {
            { LUTL, 'UnitCapCheckLess', { .85 } },

			{ EBC, 'GreaterThanEconStorageCurrent', { 300, 3000 }},

            { EBC, 'GreaterThanEconTrendEfficiencyOverTime', { 0.8, 15, 1.01, 1.02 }},
        
            { LUTL, 'UnitsLessAtLocation', { 'LocationType', 4, TMD }},
        },
		
		BuilderType = { 'T3','SubCommander' },

        BuilderData = {
			
            Construction = {
				NearBasePerimeterPoints = true,
                
                ThreatMax = 75,
                
				BaseTemplateFile = '/lua/ai/aibuilders/Loud_DP_Templates.lua',
				BaseTemplate = 'DefensivePointSmall',
                
                BuildStructures = {'T3MissileDefense'}
            }
        }
    },
	
    Builder {BuilderName = 'T3 DP STD Storage',
	
        PlatoonTemplate = 'EngineerBuilder',
        
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
		
        Priority = 750,
        
        PriorityFunction = AboveUnitCap75,

        BuilderConditions = {

            { UCBC, 'UnitsGreaterAtLocation', { 'LocationType', 0, ENERGY }},

			{ EBC, 'GreaterThanEconStorageCurrent', { 400, 5000 }},

            { EBC, 'GreaterThanEconTrendEfficiencyOverTime', { 1, 30, 1.02, 1.04 }},

            { UCBC, 'UnitsLessAtLocation', { 'LocationType', 4, categories.ENERGYSTORAGE * categories.TECH3 }},
        },
		
		BuilderType = { 'T3','SubCommander' },

        BuilderData = {
			
            Construction = {
				NearBasePerimeterPoints = true,
                
                ThreatMax = 60,
                
				BaseTemplateFile = '/lua/ai/aibuilders/Loud_DP_Templates.lua',
				BaseTemplate = 'DefensivePointSmall',
                
                BuildStructures = {'T3Storage'}
            }
        }
    },	
        
    Builder {BuilderName = 'T3 DP STD Tac Arty',
	
        PlatoonTemplate = 'EngineerBuilder',
        
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
		
        Priority = 751,
		
        BuilderConditions = {
            { LUTL, 'UnitCapCheckLess', { .75 } },
            
			{ TBC, 'ThreatCloserThan', { 'LocationType', 350, 75, 'AntiSurface' }},

			{ EBC, 'GreaterThanEconStorageCurrent', { 400, 5000 }},

            { EBC, 'GreaterThanEconTrendEfficiencyOverTime', { 1.5, 50, 1.012, 1.025 }},
            
            { UCBC, 'UnitsLessAtLocation', { 'LocationType', 1, categories.ARTILLERY * categories.TACTICAL }},
        },
		
        BuilderType = { 'T3','SubCommander'},
		
        BuilderData = {
			DesiresAssist = true,
			NumAssistees = 4,
			
            Construction = {
				Radius = 1,
				NearBasePerimeterPoints = true,

				ThreatMax = 60,

				BaseTemplateFile = '/lua/ai/aibuilders/Loud_DP_Templates.lua',
				BaseTemplate = 'DefensivePointSmall',

                BuildStructures = {'T3TacticalArtillery'},
            }
        }
    },    
    
    Builder {BuilderName = 'T4 DP STD AA',
	
        PlatoonTemplate = 'EngineerBuilder',
        
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
		
        Priority = 750,
		
		PriorityFunction = IsPrimaryBase,
		
        BuilderConditions = {
            { LUTL, 'UnitCapCheckLess', { .85 } },

            { LUTL, 'AirStrengthRatioLessThan', { 2 }},

			{ EBC, 'GreaterThanEconStorageCurrent', { 400, 5000 }},

            { EBC, 'GreaterThanEconTrendEfficiencyOverTime', { 1.5, 50, 1.012, 1.025 }},

			-- must have 2 shields here
            { UCBC, 'UnitsGreaterAtLocation', { 'LocationType', 1, SHIELD - categories.ANTIARTILLERY }},

            -- must not have other T4 AA
            { UCBC, 'UnitsLessAtLocation', { 'LocationType', 1, AA * categories.EXPERIMENTAL }},
        },
		
		BuilderType = { 'SubCommander' },

        BuilderData = {
			DesiresAssist = true,
			NumAssistees = 2,

            Construction = {
				NearBasePerimeterPoints = true,
                
                ThreatMax = 60,
				
				BaseTemplateFile = '/lua/ai/aibuilders/Loud_DP_Templates.lua',
				BaseTemplate = 'DefensivePointSmall',
				
                BuildStructures = {'T4AADefense'}
            }
        }
    },
    
    Builder {BuilderName = 'T4 DP STD PD',
	
        PlatoonTemplate = 'EngineerBuilder',
        
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
		
        Priority = 751,
		
		--PriorityFunction = IsPrimaryBase,
		
        BuilderConditions = {
            { LUTL, 'UnitCapCheckLess', { .85 } },

            { LUTL, 'LandStrengthRatioLessThan', { 3 }},

			{ EBC, 'GreaterThanEconStorageCurrent', { 400, 5000 }},

            { EBC, 'GreaterThanEconTrendEfficiencyOverTime', { 1.5, 75, 1.012, 1.02 }},

			-- must have shields here
            { UCBC, 'UnitsGreaterAtLocation', { 'LocationType', 1, SHIELD - categories.ANTIARTILLERY }},
            
            -- must not have other T4 PD
            { UCBC, 'UnitsLessAtLocation', { 'LocationType', 1, categories.STRUCTURE * categories.DEFENSE * categories.EXPERIMENTAL - categories.ANTIAIR }},
        },
		
		BuilderType = { 'SubCommander' },

        BuilderData = {
			DesiresAssist = true,
			NumAssistees = 2,

            Construction = {
				NearBasePerimeterPoints = true,
                
                ThreatMax = 60,
				
				BaseTemplateFile = '/lua/ai/aibuilders/Loud_DP_Templates.lua',
				BaseTemplate = 'DefensivePointSmall',
				
                BuildStructures = {'T4GroundDefense'}
            }
        }
    },
	
    Builder {BuilderName = 'T4 DP STD Antinuke',
	
        PlatoonTemplate = 'EngineerBuilder',
        
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
		
        Priority = 752,
        
        PriorityFunction = AboveUnitCap75,
		
        BuilderConditions = {
			{ LUTL, 'GreaterThanEnergyIncome', { 21000 }},

			{ EBC, 'GreaterThanEconStorageCurrent', { 400, 5000 }},

            { EBC, 'GreaterThanEconTrendEfficiencyOverTime', { 1.5, 50, 1.012, 1.025 }},

            -- must not already have an antinuke
            { UCBC, 'UnitsLessAtLocation', { 'LocationType', 1, SMD }},

			-- must have 2 shields here
            { UCBC, 'UnitsGreaterAtLocation', { 'LocationType', 1, SHIELD - categories.ANTIARTILLERY }},

            -- enemy must have a visible nuke            
			{ UCBC, 'HaveGreaterThanUnitsWithCategoryAndAlliance', { 0, categories.NUKE * categories.SILO + categories.STRUCTURE, 'Enemy' }},
        },
		
		BuilderType = { 'SubCommander' },

        BuilderData = {
			DesiresAssist = true,
			
            Construction = {
				NearBasePerimeterPoints = true,
                
                ThreatMax = 60,
				
				BaseTemplateFile = '/lua/ai/aibuilders/Loud_DP_Templates.lua',
				BaseTemplate = 'DefensivePointSmall',
				
                BuildStructures = {'T3StrategicMissileDefense'}
            }
        }
    },
	
    Builder {BuilderName = 'T2 DP Engineering Support',
	
        PlatoonTemplate = 'EngineerBuilder',
        
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
		
        Priority = 751,
        
        PriorityFunction = AboveUnitCap75,
		
        BuilderConditions = {
 			{ MIBC, 'FactionIndex', { 1, 3 } },

            { UCBC, 'UnitsLessAtLocation', { 'LocationType', 3, categories.ENGINEERSTATION}},

			{ EBC, 'GreaterThanEconStorageCurrent', { 400, 5000 }},

            { EBC, 'GreaterThanEconTrendEfficiencyOverTime', { 1.5, 50, 1.012, 1.025 }},
        },
		
		BuilderType = { 'T2','T3','SubCommander' },
		
        BuilderData = {
            Construction = {
				NearBasePerimeterPoints = true,
                
				ThreatMax = 60,
				
				BaseTemplateFile = '/lua/ai/aibuilders/Loud_DP_Templates.lua',
				BaseTemplate = 'DefensivePointSmall',
				
                BuildStructures = { 'T2EngineerSupport' },
            }
        }
    },

	Builder {BuilderName = 'T3 DP Engineering Support',
	
        PlatoonTemplate = 'EngineerBuilder',
        
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
		
        Priority = 750,
        
        PriorityFunction = AboveUnitCap75,
		
        BuilderConditions = {
 			{ MIBC, 'FactionIndex', { 2, 4 } },

            { UCBC, 'UnitsLessAtLocation', { 'LocationType', 3, categories.ENGINEERSTATION}},

			{ EBC, 'GreaterThanEconStorageCurrent', { 400, 5000 }},

            { EBC, 'GreaterThanEconTrendEfficiencyOverTime', { 1.5, 50, 1.012, 1.025 }},
        },
		
		BuilderType = { 'T3','SubCommander' },
		
        BuilderData = {
            Construction = {
				NearBasePerimeterPoints = true,
                
				ThreatMax = 60,
				
				BaseTemplateFile = '/lua/ai/aibuilders/Loud_DP_Templates.lua',
				BaseTemplate = 'DefensivePointSmall',

                BuildStructures = { 'T3EngineerSupport' },
            }
        }
    },
	
	
}

BuilderGroup {BuilderGroupName = 'Engineer Defenses DP Naval',
	BuildersType = 'EngineerBuilder',

    Builder {BuilderName = 'Naval DP Sonar',
	
        PlatoonTemplate = 'EngineerBuilder',
        
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
		
        Priority = 760,

		PriorityFunction = IsNavalMap,
        
        BuilderConditions = {
            { LUTL, 'UnitCapCheckLess', { .95 } },

			{ LUTL, 'UnitsLessAtLocation', { 'LocationType', 1, categories.STRUCTURE * categories.OVERLAYSONAR * categories.INTELLIGENCE }},

			{ LUTL, 'UnitsLessAtLocation', { 'LocationType', 1, categories.MOBILESONAR * categories.INTELLIGENCE * categories.TECH3 }},

			{ EBC, 'GreaterThanEconStorageCurrent', { 300, 3000 }},

            { EBC, 'GreaterThanEconTrendEfficiencyOverTime', { 1, 30, 1.012, 1.025 }}, 			
        },
		
		BuilderType = { 'T2','T3','SubCommander' },

        BuilderData = {
			DesiresAssist = true,
			
            Construction = {
				NearBasePerimeterPoints = true,
                
                ThreatMax = 60,
				
				BaseTemplateFile = '/lua/ai/aibuilders/Loud_DP_Templates.lua',
				BaseTemplate = 'NavalDefensivePoint',
				
                BuildStructures = {'T2Sonar'}
            }
        }
    },

    Builder {BuilderName = 'Naval DP Airstaging',
	
        PlatoonTemplate = 'EngineerBuilder',
        
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
		
        Priority = 760,
        
        PriorityFunction = AboveUnitCap75,

        BuilderConditions = {
			{ EBC, 'GreaterThanEconStorageCurrent', { 250, 2500 }},

            { UCBC, 'UnitsLessAtLocationInRange', { 'LocationType', 1, categories.AIRSTAGINGPLATFORM - categories.MOBILE, 0, 28 }},
        },
		
		BuilderType = { 'T2','T3','SubCommander' },

        BuilderData = {
			DesiresAssist = true,
            
            Construction = {
				NearBasePerimeterPoints = true,
                
                ThreatMax = 60,
				
				BaseTemplateFile = '/lua/ai/aibuilders/Loud_DP_Templates.lua',
				BaseTemplate = 'NavalDefensivePoint',
				
                BuildStructures = {'T2AirStagingPlatform'}
            }
        }
    },	

    Builder {BuilderName = 'Naval DP TMD',
	
        PlatoonTemplate = 'EngineerBuilder',
        
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
		
        Priority = 760,

        BuilderConditions = {
            { LUTL, 'UnitCapCheckLess', { .85 } },

			{ EBC, 'GreaterThanEconStorageCurrent', { 300, 3000 }},

            { UCBC, 'UnitsLessAtLocationInRange', { 'LocationType', 1, TMD, 0, 28 }},
        },
		
		BuilderType = { 'T2','T3','SubCommander' },

        BuilderData = {
            
            Construction = {
				NearBasePerimeterPoints = true,
                
                ThreatMax = 75,
				
				BaseTemplateFile = '/lua/ai/aibuilders/Loud_DP_Templates.lua',
				BaseTemplate = 'NavalDefensivePoint',
				
                BuildStructures = {'T2MissileDefense'}
            }
        }
    },	

    Builder {BuilderName = 'Naval DP T2 AA Defenses',
	
        PlatoonTemplate = 'EngineerBuilder',
        
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
		
        Priority = 700,
        
        PriorityFunction = AboveUnitCap75,
		
        BuilderConditions = {
            { LUTL, 'AirStrengthRatioLessThan', { 2 }},

			{ EBC, 'GreaterThanEconStorageCurrent', { 300, 3000 }},

            { EBC, 'GreaterThanEconTrendEfficiencyOverTime', { 0.8, 15, 1.01, 1.02 }},

            { UCBC, 'UnitsLessAtLocationInRange', { 'LocationType', 2, AA * categories.TECH2, 0, 24 }},
        },
		
		BuilderType = { 'T2','T3','SubCommander' },

        BuilderData = {
			DesiresAssist = true,
			
            Construction = {
				NearBasePerimeterPoints = true,
				
				BaseTemplateFile = '/lua/ai/aibuilders/Loud_DP_Templates.lua',
				BaseTemplate = 'NavalDefensivePoint',
				
                BuildStructures = {'T2AADefenseAmphibious'}
            }
        }
    },

    Builder {BuilderName = 'Naval DP T2 Surface Defenses',
	
        PlatoonTemplate = 'EngineerBuilder',
        
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
		
        Priority = 700,
        
        PriorityFunction = AboveUnitCap75,
		
        BuilderConditions = {
            { LUTL, 'UnitCapCheckLess', { .75 } },

			{ EBC, 'GreaterThanEconStorageCurrent', { 300, 3000 }},

            { EBC, 'GreaterThanEconTrendEfficiencyOverTime', { 0.8, 15, 1.01, 1.02 }},

            { UCBC, 'UnitsLessAtLocationInRange', { 'LocationType', 3, categories.STRUCTURE * categories.DEFENSE * categories.DIRECTFIRE, 0, 24 }},
        },
		
		BuilderType = { 'T2','T3','SubCommander' },

        BuilderData = {
			DesiresAssist = true,
			
            Construction = {
				NearBasePerimeterPoints = true,
                
                ThreatMax = 50,
				
				BaseTemplateFile = '/lua/ai/aibuilders/Loud_DP_Templates.lua',
				BaseTemplate = 'NavalDefensivePoint',
				
                BuildStructures = {'T2GroundDefenseAmphibious'}
            }
        }
    },
	
    Builder {BuilderName = 'Naval DP T2 Naval Defenses',
	
        PlatoonTemplate = 'EngineerBuilder',
        
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
		
        Priority = 700,
        
		PriorityFunction = IsNavalMap,		        
		
        BuilderConditions = {
            { LUTL, 'UnitCapCheckLess', { .85 } },
            
            { LUTL, 'NavalStrengthRatioLessThan', { 1.5 } },

			{ EBC, 'GreaterThanEconStorageCurrent', { 300, 3000 }},

            { EBC, 'GreaterThanEconTrendEfficiencyOverTime', { 0.8, 15, 1.01, 1.02 }},

            { UCBC, 'UnitsLessAtLocationInRange', { 'LocationType', 2, categories.STRUCTURE * categories.ANTINAVY * categories.TECH2, 0, 24 }},
        },
		
		BuilderType = { 'T2','T3','SubCommander' },

        BuilderData = {
			DesiresAssist = true,
			
            Construction = {
				NearBasePerimeterPoints = true,
                
                ThreatMax = 60,
				
				BaseTemplateFile = '/lua/ai/aibuilders/Loud_DP_Templates.lua',
				BaseTemplate = 'NavalDefensivePoint',
				
                BuildStructures = {'T2NavalDefense'}
            }
        }
    },

    Builder {BuilderName = 'Naval DP T3 AA Defenses',
	
        PlatoonTemplate = 'EngineerBuilder',
        
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
		
        Priority = 750,
		
        BuilderConditions = {
            { LUTL, 'UnitCapCheckLess', { .85 } },

            { LUTL, 'AirStrengthRatioLessThan', { 2 }},

			{ EBC, 'GreaterThanEconStorageCurrent', { 400, 5000 }},

            { EBC, 'GreaterThanEconTrendEfficiencyOverTime', { 0.8, 15, 1.01, 1.02 }},

            { UCBC, 'UnitsLessAtLocationInRange', { 'LocationType', 2, AA * categories.TECH3, 0, 24 }},
        },
		
		BuilderType = { 'T3','SubCommander' },

        BuilderData = {
			DesiresAssist = true,
			
            Construction = {
				NearBasePerimeterPoints = true,
                
                ThreatMax = 75,
				
				BaseTemplateFile = '/lua/ai/aibuilders/Loud_DP_Templates.lua',
				BaseTemplate = 'NavalDefensivePoint',
				
                BuildStructures = {'T3AADefense'}
            }
        }
    },
    
    Builder {BuilderName = 'Naval DP T3 Naval Defenses',
	
        PlatoonTemplate = 'EngineerBuilder',
        
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
		
        Priority = 750,
		
		PriorityFunction = IsEnemyNavalActive,		
		
        BuilderConditions = {
            { LUTL, 'UnitCapCheckLess', { .85 } },
            
            { LUTL, 'NavalStrengthRatioLessThan', { 1.5 } },

			{ EBC, 'GreaterThanEconStorageCurrent', { 400, 5000 }},

            { EBC, 'GreaterThanEconTrendEfficiencyOverTime', { 0.8, 15, 1.01, 1.02 }},

            { UCBC, 'UnitsLessAtLocationInRange', { 'LocationType', 1, categories.STRUCTURE * categories.ANTINAVY * categories.TECH3, 0, 24 }},
            
        },
		
		BuilderType = { 'T3','SubCommander'},

        BuilderData = {
		
			DesiresAssist = true,
			
            Construction = {

                NearBasePerimeterPoints = true,
				
				ThreatMax = 100,

				BaseTemplateFile = '/lua/ai/aibuilders/Loud_DP_Templates.lua',
				BaseTemplate = 'NavalDefensivePoint',

                BuildStructures = {'T3NavalDefense'},
            }
        }
    },
	
    Builder {BuilderName = 'Naval DP Antinuke',
	
        PlatoonTemplate = 'EngineerBuilder',
        
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
		
		InstanceCount = 1,
		
        Priority = 740,
		
        BuilderConditions = {
            { LUTL, 'UnitCapCheckLess', { .85 } },

			{ LUTL, 'GreaterThanEnergyIncome', { 21000 }},

			{ EBC, 'GreaterThanEconStorageCurrent', { 400, 5000 }},

            { EBC, 'GreaterThanEconTrendEfficiencyOverTime', { 1.5, 50, 1.012, 1.025 }},

            { UCBC, 'UnitsLessAtLocationInRange', { 'LocationType', 1, SMD, 0, 15 }},
        },
		
		BuilderType = { 'SubCommander' },
		
        BuilderData = {
			DesiresAssist = true,
            NumAssistees = 2,
			
            Construction = {
                NearBasePerimeterPoints = true,
                
                ThreatMax = 50,
				
				BaseTemplateFile = '/lua/ai/aibuilders/Loud_DP_Templates.lua',
				BaseTemplate = 'NavalDefensivePoint',
				
                BuildStructures = {'T3StrategicMissileDefense'},
            }
        }
    },	
}


--[[
BuilderGroup {BuilderGroupName = 'Engineer Defenses DP Small',
	BuildersType = 'EngineerBuilder',

    Builder {BuilderName = 'DP SML Radar',
	
        PlatoonTemplate = 'EngineerBuilder',
        
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
		
        Priority = 751,

        BuilderConditions = {
        
            { LUTL, 'UnitCapCheckLess', { .85 } },
            
            { LUTL, 'UnitsLessAtLocation', { 'LocationType', 1, categories.STRUCTURE * categories.OVERLAYRADAR * categories.INTELLIGENCE }},
			
            { EBC, 'GreaterThanEconTrendEfficiencyOverTime', { 1, 30, 1.012, 1.025 }}, 			
        },
		
		BuilderType = { 'T2','T3','SubCommander' },

        BuilderData = {
			DesiresAssist = true,
			
            Construction = {
				NearBasePerimeterPoints = true,
                
                ThreatMax = 75,
                
				BaseTemplateFile = '/lua/ai/aibuilders/Loud_DP_Templates.lua',
				BaseTemplate = 'DefensivePointSmall',
                
                BuildStructures = {
                    'T2Radar',
                    'T2MissileDefense',
                    'T2EnergyProduction',
                    'T2RadarJammer',
                }
            }
        }
    },

    Builder {BuilderName = 'T2 DP SML Auxiliary Defenses',
	
        PlatoonTemplate = 'EngineerBuilder',
        
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
		
        Priority = 751,

        BuilderConditions = {

            { LUTL, 'UnitCapCheckLess', { .85 } },

            { UCBC, 'UnitsLessAtLocationInRange', { 'LocationType', 1, categories.AIRSTAGINGPLATFORM - categories.MOBILE, 0, 28 }},
        },
		
		BuilderType = { 'T2','T3','SubCommander' },

        BuilderData = {
			DesiresAssist = true,
            
            Construction = {
				NearBasePerimeterPoints = true,
                
                ThreatMax = 75,
                
				BaseTemplateFile = '/lua/ai/aibuilders/Loud_DP_Templates.lua',
				BaseTemplate = 'DefensivePointSmall',
                
                BuildStructures = {
					'T2AirStagingPlatform',
                }
            }
        }
    },	

    Builder {BuilderName = 'T3 DP SML AA Defenses',
	
        PlatoonTemplate = 'EngineerBuilder',
        
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
		
        Priority = 750,
		
        BuilderConditions = {
        
			{ LUTL, 'GreaterThanEnergyIncome', { 16800 }},
            
            { LUTL, 'UnitCapCheckLess', { .85 } },

            { EBC, 'GreaterThanEconTrendEfficiencyOverTime', { 1, 30, 1.012, 1.025 }}, 
            
            { UCBC, 'UnitsLessAtLocationInRange', { 'LocationType', 4, AA * categories.TECH3, 0, 24 }},
        },
		
		BuilderType = { 'T3','SubCommander' },

        BuilderData = {
			DesiresAssist = true,
			
            Construction = {
				NearBasePerimeterPoints = true,
                
                ThreatMax = 75,
                
				BaseTemplateFile = '/lua/ai/aibuilders/Loud_DP_Templates.lua',
				BaseTemplate = 'DefensivePointSmall',
                
                BuildStructures = {
					'T3AADefense',
                }
            }
        }
    },

    Builder {BuilderName = 'T2 DP SML Shields',
	
        PlatoonTemplate = 'EngineerBuilder',
        
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
		
        Priority = 750,
		
        BuilderConditions = {
        
			{ LUTL, 'GreaterThanEnergyIncome', { 12600 }},
            
            { LUTL, 'UnitCapCheckLess', { .85 } },
            
			{ EBC, 'GreaterThanEconTrendEfficiencyOverTime', { 2, 30, 1.02, 1.04 }},
            
            { UCBC, 'UnitsLessAtLocationInRange', { 'LocationType', 1, SHIELD - categories.ANTIARTILLERY, 0, 24 }},
        },
		
		BuilderType = { 'T2','T3','SubCommander' },

        BuilderData = {
			DesiresAssist = true,
			
            Construction = {
				NearBasePerimeterPoints = true,
                
                ThreatMax = 100,
                
				BaseTemplateFile = '/lua/ai/aibuilders/Loud_DP_Templates.lua',
				BaseTemplate = 'DefensivePointSmall',
                
                BuildStructures = {'T2ShieldDefense'}
            }
        }
    },

    Builder {BuilderName = 'T3 DP SML PD Defenses',
	
        PlatoonTemplate = 'EngineerBuilder',
        
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
		
        Priority = 750,
		
        BuilderConditions = {
        
			{ LUTL, 'GreaterThanEnergyIncome', { 16800 }},
            
            { LUTL, 'UnitCapCheckLess', { .85 } },
            
			{ TBC, 'ThreatCloserThan', { 'LocationType', 350, 75, 'AntiSurface' }},

            { EBC, 'GreaterThanEconTrendEfficiencyOverTime', { 2, 30, 1.02, 1.04 }}, 
            
            { UCBC, 'UnitsLessAtLocationInRange', { 'LocationType', 2, categories.STRUCTURE * categories.DEFENSE * categories.TECH3 * categories.DIRECTFIRE, 0, 24 }},
        },
		
		BuilderType = { 'T3','SubCommander' },

        BuilderData = {
			DesiresAssist = true,
			
            Construction = {
				NearBasePerimeterPoints = true,
                
                ThreatMax = 100,
                
				BaseTemplateFile = '/lua/ai/aibuilders/Loud_DP_Templates.lua',
				BaseTemplate = 'DefensivePointSmall',
                
                BuildStructures = {'T3GroundDefense'}
            }
        }
    },
	
    Builder {BuilderName = 'T2 DP SML TML',
	
        PlatoonTemplate = 'EngineerBuilder',
        
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
		
        Priority = 750,

        BuilderConditions = {
            { LUTL, 'UnitCapCheckLess', { .85 } },
            
			--{ TBC, 'ThreatCloserThan', { 'LocationType', 400, 75, 'AntiSurface' }},

            { EBC, 'GreaterThanEconTrendEfficiencyOverTime', { 1, 30, 1.012, 1.025 }}, 
            
            { UCBC, 'UnitsLessAtLocation', { 'LocationType', 4, categories.TACTICALMISSILEPLATFORM * categories.STRUCTURE }},			
        },
		
        BuilderType = {'T2','T3','SubCommander' },
		
        BuilderData = {
            Construction = {
                NearBasePerimeterPoints = true,
				
				ThreatMax = 100,
				
				BaseTemplateFile = '/lua/ai/aibuilders/Loud_DP_Templates.lua',
				BaseTemplate = 'DefensivePointSmall',
				
                BuildStructures = {'T2StrategicMissile'},
            }
        }
    },
    
    Builder {BuilderName = 'T3 DP SML Tactical Artillery',
	
        PlatoonTemplate = 'EngineerBuilder',
        
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
		
        Priority = 750,
		
        BuilderConditions = {
            { LUTL, 'UnitCapCheckLess', { .75 } },
            { EBC, 'GreaterThanEconTrendEfficiencyOverTime', { 1, 30, 1.012, 1.025 }},
            
            { UCBC, 'UnitsLessAtLocation', { 'LocationType', 1, categories.ARTILLERY * categories.TACTICAL }},
        },
		
        BuilderType = { 'T3','SubCommander'},
		
        BuilderData = {
			DesiresAssist = true,
			NumAssistees = 4,
			
            Construction = {
				Radius = 1,
				NearBasePerimeterPoints = true,

				ThreatMax = 100,

				BaseTemplateFile = '/lua/ai/aibuilders/Loud_DP_Templates.lua',
				BaseTemplate = 'DefensivePointSmall',

                BuildStructures = {'T3TacticalArtillery'},
            }
        }
    },    

    Builder {BuilderName = 'T4 DP SML AA Defenses',
	
        PlatoonTemplate = 'EngineerBuilder',
        
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
		
        Priority = 750,
		
		PriorityFunction = IsPrimaryBase,
		
        BuilderConditions = {
            { LUTL, 'UnitCapCheckLess', { .85 } },

			{ TBC, 'ThreatCloserThan', { 'LocationType', 500, 35, 'Air' }},
            
			{ EBC, 'GreaterThanEconTrendEfficiencyOverTime', { 2, 60, 1.02, 1.04 }},
            
			-- must have shields here
            { UCBC, 'UnitsGreaterAtLocationInRange', { 'LocationType', 0, SHIELD - categories.ANTIARTILLERY, 0, 24 }},
            { UCBC, 'UnitsLessAtLocationInRange', { 'LocationType', 1, AA * categories.EXPERIMENTAL, 0, 24 }},
        },
		
		BuilderType = { 'SubCommander' },

        BuilderData = {
			DesiresAssist = true,
			NumAssistees = 2,
			
            Construction = {
				NearBasePerimeterPoints = true,
                
                ThreatMax = 90,
                
				BaseTemplateFile = '/lua/ai/aibuilders/Loud_DP_Templates.lua',
				BaseTemplate = 'DefensivePointSmall',
                
                BuildStructures = {'T4AADefense'}
            }
        }
    },
	
    Builder {BuilderName = 'T4 DP SML Antinuke Defenses',
	
        PlatoonTemplate = 'EngineerBuilder',
        
		PlatoonAddFunctions = { { LUTL, 'NameEngineerUnits'}, },
		
        Priority = 740,
		
		PriorityFunction = IsPrimaryBase,
		
        BuilderConditions = {
            { LUTL, 'UnitCapCheckLess', { .85 } },
			{ LUTL, 'GreaterThanEnergyIncome', { 21000 }},
			
		    { UCBC, 'UnitsLessAtLocation', { 'LocationType', 1, SMD }},			

			-- must have shields here
            { UCBC, 'UnitsGreaterAtLocationInRange', { 'LocationType', 0, SHIELD - categories.ANTIARTILLERY, 0, 24 }},
			{ UCBC, 'HaveGreaterThanUnitsWithCategoryAndAlliance', { 0, categories.NUKE + categories.ANTIMISSILE - categories.TECH2, 'Enemy' }},
        },
		
		BuilderType = { 'SubCommander' },

        BuilderData = {
			DesiresAssist = true,
			
            Construction = {
				NearBasePerimeterPoints = true,
                
                ThreatMax = 60,
                
				BaseTemplateFile = '/lua/ai/aibuilders/Loud_DP_Templates.lua',
				BaseTemplate = 'DefensivePointSmall',
                
                BuildStructures = {'T3StrategicMissileDefense'}
            }
        }
    },
	
}
--]]
