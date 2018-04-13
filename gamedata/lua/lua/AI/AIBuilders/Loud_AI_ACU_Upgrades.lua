---  File     :  /lua/ai/Loud_AI_ACU_Upgrades.lua
---  Summary  : Upgrades for the ACU
---  with support for Black Ops Advanced ACU mod
---
--- if you are looking for upgrades for SCU then you need to look for the selfenhance functions
--- in the AIBehaviors file - they use a different method entirely

-- notice the use of the ClearTaskOnComplete flag
-- since an ACU will only use the upgrade task once
-- I wanted a way to remove the builder from the builder list when completed
-- this flag accomplishes this, setting the priority to zero permanently
-- the builder manager will then remove it from the task list

-- Also, note the use of the BuilderType = 'Commander'
-- This new feature seperates the commanders tasks from the other engineers
-- saving both them, and he, from processing tasks they aren't meant to do

local BHVR = '/lua/ai/aibehaviors.lua'
local LUTL = '/lua/loudutilities.lua'
local UCBC = '/lua/editor/UnitCountBuildConditions.lua'

local EBC = '/lua/editor/EconomyBuildConditions.lua'
local SAI = '/lua/scenarioplatoonai.lua'

-- VANILLA COMMANDER UPGRADES --
BuilderGroup {BuilderGroupName = 'ACU Upgrades LOUD',
    BuildersType = 'EngineerBuilder',
	
    Builder {BuilderName = 'UEF CDR Upgrade',
	
        PlatoonTemplate = 'CommanderEnhance',
		PlatoonAddFunctions = { { BHVR, 'CDREnhance'}, },

		FactionIndex = 1,
		
        BuilderConditions = {
			{ LUTL, 'NoBaseAlert', { 'LocationType' }},		
			{ EBC, 'GreaterThanEconEfficiencyOverTime', { 1.02, 1.04 }}, 
			{ UCBC, 'ACUNeedsUpgrade', { 'T3Engineering'}},
			{ UCBC, 'ACUNeedsUpgrade', { 'AdvancedEngineering' }},
        },
		
        Priority = 850,
		
        BuilderType = { 'Commander' },
		
        BuilderData = {
			ClearTaskOnComplete = true,
            Enhancement = { 'ResourceAllocation', 'Shield', 'AdvancedEngineering' },
        },
		
    },

    Builder {BuilderName = 'Aeon CDR Upgrade',
	
        PlatoonTemplate = 'CommanderEnhance',
		PlatoonAddFunctions = { { BHVR, 'CDREnhance'}, },		

		FactionIndex = 2,
		
        BuilderConditions = {
			{ LUTL, 'NoBaseAlert', { 'LocationType' }},		
			{ EBC, 'GreaterThanEconEfficiencyOverTime', { 1.02, 1.04 }}, 
			{ UCBC, 'ACUNeedsUpgrade', { 'T3Engineering'}},
			{ UCBC, 'ACUNeedsUpgrade', { 'EnhancedSensors' }},
        },
		
        Priority = 850,
		
        BuilderType = { 'Commander' },
		
        BuilderData = {
			ClearTaskOnComplete = true,
            Enhancement = { 'ResourceAllocation', 'AdvancedEngineering', 'EnhancedSensors' },
        },
		
    },

    Builder {BuilderName = 'Cybran CDR Upgrade',
	
        PlatoonTemplate = 'CommanderEnhance',
		PlatoonAddFunctions = { { BHVR, 'CDREnhance'}, },		

		FactionIndex = 3,
		
        BuilderConditions = {
			{ LUTL, 'NoBaseAlert', { 'LocationType' }},		
			{ EBC, 'GreaterThanEconEfficiencyOverTime', { 1.02, 1.04 }}, 
			{ UCBC, 'ACUNeedsUpgrade', { 'T3Engineering'}},
			{ UCBC, 'ACUNeedsUpgrade', { 'MicrowaveLaserGenerator' }},
        },
		
        Priority = 850,
		
        BuilderType = { 'Commander' },
		
        BuilderData = {
			ClearTaskOnComplete = true,
            Enhancement = { 'ResourceAllocation', 'AdvancedEngineering', 'MicrowaveLaserGenerator' },
        },
		
    },

    Builder {BuilderName = 'Seraphim CDR Upgrade',
	
        PlatoonTemplate = 'CommanderEnhance',
		PlatoonAddFunctions = { { BHVR, 'CDREnhance'}, },		

		FactionIndex = 4,
		
        BuilderConditions = {
			{ LUTL, 'NoBaseAlert', { 'LocationType' }},		
			{ EBC, 'GreaterThanEconEfficiencyOverTime', { 1.02, 1.04 }}, 
			{ UCBC, 'ACUNeedsUpgrade', { 'T3Engineering'}},
			{ UCBC, 'ACUNeedsUpgrade', { 'RegenAura' }},
        },
		
        Priority = 850,
		
        BuilderType = { 'Commander' },
		
        BuilderData = {
			ClearTaskOnComplete = true,
            Enhancement = { 'ResourceAllocation', 'AdvancedEngineering', 'RegenAura' },
        },
		
    },
	
    Builder {BuilderName = 'ACU T3Engineering Upgrade',
	
        PlatoonTemplate = 'CommanderEnhance',
		PlatoonAddFunctions = { { BHVR, 'CDREnhance'}, },
		PlatoonAddFunctions = { {SAI, 'BuildOnce'}, },
		
        BuilderConditions = {
			{ LUTL, 'NoBaseAlert', { 'LocationType' }},		
            { UCBC, 'PoolGreaterAtLocation', { 'LocationType', 0, categories.uel0001 + categories.ual0001 + categories.url0001 + categories.xsl0001 }},
			{ EBC, 'GreaterThanEconEfficiencyOverTime', { 1.02, 1.04 }}, 
			{ UCBC, 'ACUHasUpgrade', { 'AdvancedEngineering', true }},
			{ UCBC, 'ACUNeedsUpgrade', { 'T3Engineering' }},
        },
		
        Priority = 845,
		
        BuilderType = { 'Commander' },
		
        BuilderData = {
			ClearTaskOnComplete = true,
            Enhancement = { 'T3Engineering' },
        },
		
    },
}


--	Adapted for using the BlackOps Advanced ACU mod

-- 	Only the first upgrade starts turned on, as it finishes, it is removed
--	and the next stage is turned on thru the Priority Function
-- 	This can be more efficient than using multiple builder conditions
--		Each faction will have their commander stage thru their upgrades
--		Note: Due to the way that slots are checked, you can never stack more
--		than 2 upgrades to the same slot in the same enhancement list - so for
--		that reason you'll see I had to split some of slot upgrades into 2 platoons

BuilderGroup {BuilderGroupName = 'BOACU Upgrades LOUD',
    BuildersType = 'EngineerBuilder',
	
    Builder {BuilderName = 'CDR Common Upgrade BOPACU - LCH',
	
        PlatoonTemplate = 'CommanderEnhance',
		PlatoonAddFunctions = { { BHVR, 'CDREnhance'}, },
		
        BuilderConditions = {
			{ LUTL, 'NoBaseAlert', { 'LocationType' }},		
			{ EBC, 'GreaterThanEconTrendEfficiencyOverTime', { 3, 50, 1.02, 1.04 }},
        },
		
        Priority = 850,
	
        BuilderType = { 'Commander' },
		
        BuilderData = {
			ClearTaskOnComplete = true,
            Enhancement = { 'EXImprovedEngineering','EXAdvancedEngineering' },
        },
    },
	
	-- =============
	-- UEF Commander
	-- =============
	
    Builder {BuilderName = 'CDR UEF Upgrade BOPACU - Stage 1',
	
        PlatoonTemplate = 'CommanderEnhance',
		PlatoonAddFunctions = { { BHVR, 'CDREnhance'}, },
		
		FactionIndex = 1,
		
        BuilderConditions = {
			{ LUTL, 'NoBaseAlert', { 'LocationType' }},		
			{ EBC, 'GreaterThanEconEfficiencyOverTime', { 1.01, 1.02 }},
        },
		
        Priority = 10,
		
		-- this function turns on the builder 
		PriorityFunction = function(self, aiBrain, unit)
			if self.Priority == 10 then
				if unit:HasEnhancement('EXAdvancedEngineering') then
					return 850, true
				end
			end
			return self.Priority,true
		end,
		
        BuilderType = { 'Commander' },
		
        BuilderData = {
			ClearTaskOnComplete = true,
            Enhancement = { 'EXAntiMatterCannon','EXImprovedContainmentBottle' },
        },
		
    },	
	
    Builder {BuilderName = 'CDR UEF Upgrade BOPACU - Stage 2',
	
        PlatoonTemplate = 'CommanderEnhance',
		PlatoonAddFunctions = { { BHVR, 'CDREnhance'}, },

		FactionIndex = 1,
		
        BuilderConditions = {
			{ LUTL, 'NoBaseAlert', { 'LocationType' }},		
			{ EBC, 'GreaterThanEconEfficiencyOverTime', { 1.01, 1.02 }},
        },
		
        Priority = 10,
		
		-- this function turns on the builder 
		PriorityFunction = function(self, aiBrain, unit)
			if self.Priority == 10 then
				if unit:HasEnhancement('EXImprovedContainmentBottle') then
					return 850, true
				end
			end
			return self.Priority,true
		end,
		
        BuilderType = { 'Commander' },
		
        BuilderData = {
			ClearTaskOnComplete = true,
            Enhancement = { 'EXShieldBattery','EXActiveShielding' },
        },
		
    },	
	
    Builder {BuilderName = 'CDR UEF Upgrade BOPACU - Final Stage',
	
        PlatoonTemplate = 'CommanderEnhance',
		PlatoonAddFunctions = { { BHVR, 'CDREnhance'}, },

		FactionIndex = 1,
		
        BuilderConditions = {
			{ LUTL, 'NoBaseAlert', { 'LocationType' }},		
			{ EBC, 'GreaterThanEconEfficiencyOverTime', { 1.01, 1.02 }},
        },
		
        Priority = 10,
	
		-- this function turns on the builder 
		PriorityFunction = function(self, aiBrain, unit)
			if self.Priority == 10 then
				if unit:HasEnhancement('EXActiveShielding') then
					return 850, true
				end
			end
			return self.Priority,true
		end,
		
        BuilderType = { 'Commander' },
		
        BuilderData = {
			ClearTaskOnComplete = true,
            Enhancement = { 'EXExperimentalEngineering','EXPowerBooster','EXImprovedShieldBattery' },
        },
		
    },	

	-- ==============
	-- Aeon Commander
	-- ==============
	
    Builder {BuilderName = 'CDR Aeon Upgrade BOPACU - Stage 1',
	
        PlatoonTemplate = 'CommanderEnhance',
		PlatoonAddFunctions = { { BHVR, 'CDREnhance'}, },

		FactionIndex = 2,
		
        BuilderConditions = {
			{ LUTL, 'NoBaseAlert', { 'LocationType' }},		
			{ EBC, 'GreaterThanEconEfficiencyOverTime', { 1.01, 1.02 }},
        },
		
        Priority = 10,
		
		-- this function turns on the builder 
		PriorityFunction = function(self, aiBrain, unit)
			if self.Priority == 10 then
				if unit:HasEnhancement('EXAdvancedEngineering') then
					return 850, true
				end
			end
			return self.Priority,true
		end,
		
        BuilderType = { 'Commander' },
		
        BuilderData = {
			ClearTaskOnComplete = true,
            Enhancement = { 'EXBeamPhason','EXImprovedCoolingSystem' },
        },
		
    },	
	
    Builder {BuilderName = 'CDR Aeon Upgrade BOPACU - Stage 2',
	
        PlatoonTemplate = 'CommanderEnhance',
		PlatoonAddFunctions = { { BHVR, 'CDREnhance'}, },

		FactionIndex = 2,
		
        BuilderConditions = {
			{ LUTL, 'NoBaseAlert', { 'LocationType' }},		
			{ EBC, 'GreaterThanEconEfficiencyOverTime', { 1.01, 1.02 }},
        },
		
        Priority = 10,
		
		-- this function turns on the builder 
		PriorityFunction = function(self, aiBrain, unit)
			if self.Priority == 10 then
				if unit:HasEnhancement('EXImprovedCoolingSystem') then
					return 850, true
				end
			end
			return self.Priority,true
		end,
		
        BuilderType = { 'Commander' },
		
        BuilderData = {
			ClearTaskOnComplete = true,
            Enhancement = { 'EXShieldBattery','EXActiveShielding' },
        },
		
    },	
	
    Builder {BuilderName = 'CDR Aeon Upgrade BOPACU - Final Stage',
	
        PlatoonTemplate = 'CommanderEnhance',
		PlatoonAddFunctions = { { BHVR, 'CDREnhance'}, },

		FactionIndex = 2,
		
        BuilderConditions = {
			{ LUTL, 'NoBaseAlert', { 'LocationType' }},		
			{ EBC, 'GreaterThanEconEfficiencyOverTime', { 1.01, 1.02 }},
        },
		
        Priority = 10,
		
		-- this function turns on the builder 
		PriorityFunction = function(self, aiBrain, unit)
			if self.Priority == 10 then
				if unit:HasEnhancement('EXActiveShielding') then
					return 850, true
				end
			end
			return self.Priority,true
		end,
		
        BuilderType = { 'Commander' },
		
        BuilderData = {
			ClearTaskOnComplete = true,
            Enhancement = { 'EXExperimentalEngineering','EXPowerBooster','EXImprovedShieldBattery' },
        },
		
    },

	-- ================
	-- Cybran Commander
	-- ================
	
    Builder {BuilderName = 'CDR Cybran Upgrade BOPACU - Stage 1',
	
        PlatoonTemplate = 'CommanderEnhance',
		PlatoonAddFunctions = { { BHVR, 'CDREnhance'}, },

		FactionIndex = 3,
		
        BuilderConditions = {
			{ LUTL, 'NoBaseAlert', { 'LocationType' }},		
			{ EBC, 'GreaterThanEconEfficiencyOverTime', { 1.01, 1.02 }},
        },
		
        Priority = 10,
		
		-- this function turns on the builder 
		PriorityFunction = function(self, aiBrain, unit)
			if self.Priority == 10 then
				if unit:HasEnhancement('EXAdvancedEngineering') then
					return 850, true
				end
			end
			return self.Priority,true
		end,
		
        BuilderType = { 'Commander' },
		
        BuilderData = {
			ClearTaskOnComplete = true,
            Enhancement = { 'EXMasor','EXImprovedCoolingSystem' },
        },
		
    },	
	
    Builder {BuilderName = 'CDR Cybran Upgrade BOPACU - Stage 2',
	
        PlatoonTemplate = 'CommanderEnhance',
		PlatoonAddFunctions = { { BHVR, 'CDREnhance'}, },

		FactionIndex = 3,
		
        BuilderConditions = {
			{ LUTL, 'NoBaseAlert', { 'LocationType' }},		
			{ EBC, 'GreaterThanEconEfficiencyOverTime', { 1.01, 1.02 }},
        },
		
        Priority = 10,
		
		-- this function turns on the builder 
		PriorityFunction = function(self, aiBrain, unit)
			if self.Priority == 10 then
				if unit:HasEnhancement('EXImprovedCoolingSystem') then
					return 850, true
				end
			end
			return self.Priority,true
		end,
		
        BuilderType = { 'Commander' },
		
        BuilderData = {
			ClearTaskOnComplete = true,
            Enhancement = { 'EXArmorPlating','EXStructuralIntegrity' },
        },
		
    },	
	
    Builder {BuilderName = 'CDR Cybran Upgrade BOPACU - Final Stage',
	
        PlatoonTemplate = 'CommanderEnhance',
		PlatoonAddFunctions = { { BHVR, 'CDREnhance'}, },

		FactionIndex = 3,
		
        BuilderConditions = {
			{ LUTL, 'NoBaseAlert', { 'LocationType' }},		
			{ EBC, 'GreaterThanEconEfficiencyOverTime', { 1.01, 1.02 }},
        },
		
        Priority = 10,
		
		-- this function turns on the builder 
		PriorityFunction = function(self, aiBrain, unit)
			if self.Priority == 10 then
				if unit:HasEnhancement('EXStructuralIntegrity') then
					return 850, true
				end
			end
			return self.Priority,true
		end,
		
        BuilderType = { 'Commander' },
		
        BuilderData = {
			ClearTaskOnComplete = true,
            Enhancement = { 'EXExperimentalEngineering','EXAdvancedEmitterArray','EXCompositeMaterials' },
        },
		
    },

	-- ==============
	-- Sera Commander
	-- ==============
	
    Builder {BuilderName = 'CDR Sera Upgrade BOPACU - Stage 1',
	
        PlatoonTemplate = 'CommanderEnhance',
		PlatoonAddFunctions = { { BHVR, 'CDREnhance'}, },

		FactionIndex = 4,
		
        BuilderConditions = {
			{ LUTL, 'NoBaseAlert', { 'LocationType' }},		
			{ EBC, 'GreaterThanEconEfficiencyOverTime', { 1.01, 1.02 }},
        },
		
        Priority = 10,
		
		-- this function turns on the builder 
		PriorityFunction = function(self, aiBrain, unit)
			if self.Priority == 10 then
				if unit:HasEnhancement('EXAdvancedEngineering') then
					return 850, true
				end
			end
			return self.Priority,true
		end,
		
        BuilderType = { 'Commander' },
		
        BuilderData = {
			ClearTaskOnComplete = true,
            Enhancement = { 'EXCannonBigBall','EXImprovedContainmentBottle' },
        },
		
    },	
	
    Builder {BuilderName = 'CDR Sera Upgrade BOPACU - Stage 2',
	
        PlatoonTemplate = 'CommanderEnhance',
		PlatoonAddFunctions = { { BHVR, 'CDREnhance'}, },

		FactionIndex = 4,
		
        BuilderConditions = {
			{ LUTL, 'NoBaseAlert', { 'LocationType' }},		
			{ EBC, 'GreaterThanEconEfficiencyOverTime', { 1.01, 1.02 }},
        },
		
        Priority = 10,
		
		-- this function turns on the builder 
		PriorityFunction = function(self, aiBrain, unit)
			if self.Priority == 10 then
				if unit:HasEnhancement('EXImprovedContainmentBottle') then
					return 850, true
				end
			end
			return self.Priority,true
		end,
		
        BuilderType = { 'Commander' },
		
        BuilderData = {
			ClearTaskOnComplete = true,
            Enhancement = { 'EXL1Lambda','EXL2Lambda' },
        },
		
    },	
	
    Builder {BuilderName = 'CDR Sera Upgrade BOPACU - Final Stage',
	
        PlatoonTemplate = 'CommanderEnhance',
		PlatoonAddFunctions = { { BHVR, 'CDREnhance'}, },

		FactionIndex = 4,
		
        BuilderConditions = {
			{ LUTL, 'NoBaseAlert', { 'LocationType' }},		
			{ EBC, 'GreaterThanEconEfficiencyOverTime', { 1.01, 1.02 }},
        },
		
        Priority = 10,
		
		PriorityFunction = function(self, aiBrain, unit)
			if self.Priority == 10 then
				if unit:HasEnhancement('EXL2Lambda') then
					return 850, true
				end
			end
			return self.Priority,true
		end,
		
        BuilderType = { 'Commander' },
		
        BuilderData = {
			ClearTaskOnComplete = true,
            Enhancement = { 'EXExperimentalEngineering','EXPowerBooster' },
        },
		
    },	
}